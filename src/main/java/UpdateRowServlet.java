

import db.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/updateRow")
public class UpdateRowServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String schema = req.getParameter("schema");
        String table  = req.getParameter("table");

        if (schema == null || table == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Schema or table missing");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {

            // 🔑 Find primary key
            PreparedStatement pkStmt = con.prepareStatement(
                "SELECT acc.column_name " +
                "FROM all_constraints ac " +
                "JOIN all_cons_columns acc " +
                "ON ac.constraint_name = acc.constraint_name " +
                "WHERE ac.constraint_type = 'P' " +
                "AND ac.owner = ? " +
                "AND ac.table_name = ?"
            );

            pkStmt.setString(1, schema.toUpperCase());
            pkStmt.setString(2, table.toUpperCase());

            ResultSet rs = pkStmt.executeQuery();
            if (!rs.next()) {
                throw new ServletException("Primary key not found");
            }

            String pkColumn = rs.getString(1);
            String pkValue  = req.getParameter(pkColumn);

            if (pkValue == null || pkValue.isEmpty()) {
                throw new ServletException("Primary key value missing");
            }

            // 🧱 Build update
            List<String> setClauses = new ArrayList<>();
            List<String> values = new ArrayList<>();

            for (Map.Entry<String, String[]> e : req.getParameterMap().entrySet()) {
                String key = e.getKey();
                if (key.equals("schema") || key.equals("table") || key.equals(pkColumn))
                    continue;

                setClauses.add(key + " = ?");
                values.add(e.getValue()[0]);
            }

            if (setClauses.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/masters");
                return;
            }

            String sql =
                "UPDATE " + schema + "." + table +
                " SET " + String.join(", ", setClauses) +
                " WHERE " + pkColumn + " = ?";

            PreparedStatement ps = con.prepareStatement(sql);

            int i = 1;
            for (String v : values) {
                ps.setString(i++, v);
            }
            ps.setString(i, pkValue);

            ps.executeUpdate();

            resp.sendRedirect(
                req.getContextPath() +
                "/masters?schema=" + schema +
                "&table=" + table +
                "&updated=true"
            );

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
