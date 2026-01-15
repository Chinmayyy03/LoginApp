import db.DBConnection;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/getTables")
public class GetTablesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        // Accept both "schema" and "prefix" (UI safety)
        String schema = req.getParameter("schema");
        if (schema == null || schema.trim().isEmpty()) {
            schema = req.getParameter("prefix");
        }

        List<String> tables = new ArrayList<>();

        if (schema == null || schema.trim().isEmpty()) {
            resp.setContentType("application/json");
            resp.getWriter().write("[]");
            return;
        }

        try (Connection con = DBConnection.getConnection();
        		PreparedStatement ps = con.prepareStatement(
        			    "SELECT table_name " +
        			    "FROM all_tables " +
        			    "WHERE owner = ? " +
        			    "AND table_name NOT LIKE 'SYS_%' " +
        			    "ORDER BY table_name"
             )) {

            ps.setString(1, schema.toUpperCase());

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                tables.add(rs.getString("table_name"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        // Send JSON response
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < tables.size(); i++) {
            json.append("\"").append(tables.get(i)).append("\"");
            if (i < tables.size() - 1) json.append(",");
        }
        json.append("]");

        resp.getWriter().write(json.toString());
    }
}
