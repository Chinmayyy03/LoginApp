package servlet;

import db.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
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

        if (schema == null || table == null ||
            schema.trim().isEmpty() || table.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Schema or table missing");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {

            /* ===============================
               1. FIND PRIMARY KEY
            =============================== */
            String primaryKey;

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

            ResultSet pkRs = pkStmt.executeQuery();
            if (!pkRs.next()) {
                throw new ServletException("Primary key not found");
            }
            primaryKey = pkRs.getString(1);

            String pkValue = req.getParameter(primaryKey);
            if (pkValue == null || pkValue.trim().isEmpty()) {
                throw new ServletException("Primary key value missing");
            }

            /* ===============================
               2. LOAD DATE / TIMESTAMP COLUMNS
            =============================== */
            Set<String> dateColumns = new HashSet<>();

            PreparedStatement metaStmt = con.prepareStatement(
                "SELECT column_name, data_type " +
                "FROM all_tab_columns " +
                "WHERE owner = ? AND table_name = ?"
            );
            metaStmt.setString(1, schema.toUpperCase());
            metaStmt.setString(2, table.toUpperCase());

            ResultSet metaRs = metaStmt.executeQuery();
            while (metaRs.next()) {
                String type = metaRs.getString("DATA_TYPE");
                if (type != null && (
                        type.startsWith("DATE") ||
                        type.startsWith("TIMESTAMP")
                )) {
                    dateColumns.add(metaRs.getString("COLUMN_NAME").toUpperCase());
                }
            }

            /* ===============================
               3. BUILD UPDATE (NON-DATE ONLY)
            =============================== */
            List<String> setClauses = new ArrayList<>();
            List<String> values = new ArrayList<>();

            for (Map.Entry<String, String[]> e : req.getParameterMap().entrySet()) {

                String col = e.getKey();
                String val = e.getValue()[0];

                if (col.equals("schema") ||
                    col.equals("table") ||
                    col.equals(primaryKey)) continue;

                // 🚫 NEVER update DATE / TIMESTAMP from UI
                if (dateColumns.contains(col.toUpperCase())) continue;

                if (val == null || val.trim().isEmpty()) continue;

                setClauses.add(col + " = ?");
                values.add(val);
            }

            // ✅ Let Oracle manage MODIFIED_DATE safely
            if (dateColumns.contains("MODIFIED_DATE")) {
                setClauses.add("MODIFIED_DATE = SYSDATE");
            }

            if (setClauses.isEmpty()) {
                req.setAttribute(
                    "errorMessage",
                    "Update not allowed. Some fields are system-managed."
                );

                // 🔹 RELOAD EDIT PAGE WITH EXISTING DATA
                req.getRequestDispatcher(
                    "/editRow?schema=" + schema +
                    "&table=" + table +
                    "&pk=" + pkValue
                ).forward(req, resp);
                return;
            }


            String sql =
                "UPDATE " + schema + "." + table +
                " SET " + String.join(", ", setClauses) +
                " WHERE " + primaryKey + " = ?";

            PreparedStatement ps = con.prepareStatement(sql);

            int idx = 1;
            for (String v : values) {
                ps.setString(idx++, v);
            }
            ps.setString(idx, pkValue);

            ps.executeUpdate();

            /* ===============================
               SUCCESS
            =============================== */
            resp.sendRedirect(
                req.getContextPath() +
                "/masters?schema=" + schema +
                "&table=" + table +
                "&updated=true"
            );

        } catch (Exception e) {
            e.printStackTrace();

            req.setAttribute(
                "errorMessage",
                "Update not allowed. Some fields are system-managed."
            );

            req.getRequestDispatcher("/Master/editRow.jsp")
               .forward(req, resp);
        }

    }
}
