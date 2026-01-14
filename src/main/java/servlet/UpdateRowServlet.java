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

    private static final String SCHEMA = "GLOBALCONFIG"; // change if needed

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        System.out.println(">>> UpdateRowServlet CALLED <<<");

        String table = req.getParameter("table");

        if (table == null || table.trim().isEmpty()) {
            throw new ServletException("Table name missing");
        }

        try (Connection con = DBConnection.getConnection()) {

            /* ===============================
               1. FIND PRIMARY KEY
            =============================== */
            String primaryKey = null;

            PreparedStatement pkStmt = con.prepareStatement(
                "SELECT acc.column_name " +
                "FROM all_constraints ac " +
                "JOIN all_cons_columns acc " +
                "ON ac.constraint_name = acc.constraint_name " +
                "WHERE ac.constraint_type = 'P' " +
                "AND ac.table_name = ? " +
                "AND ac.owner = ?"
            );

            pkStmt.setString(1, table);
            pkStmt.setString(2, SCHEMA);

            ResultSet pkRs = pkStmt.executeQuery();
            if (pkRs.next()) {
                primaryKey = pkRs.getString(1);
            } else {
                throw new ServletException("Primary key not found");
            }

            String pkValue = req.getParameter(primaryKey);

            System.out.println(">>> PK COLUMN : " + primaryKey);
            System.out.println(">>> PK VALUE  : " + pkValue);

            if (pkValue == null || pkValue.trim().isEmpty()) {
                throw new ServletException("Primary key value missing");
            }

            /* ===============================
               2. BUILD UPDATE QUERY
            =============================== */
            Set<String> excludedColumns = new HashSet<>(Arrays.asList(
                    "CREATED_DATE",
                    "MODIFIED_DATE",
                    "CREATED_BY",
                    "MODIFIED_BY"
            ));

            Map<String, String[]> params = req.getParameterMap();
            List<String> setClauses = new ArrayList<>();
            List<String> values = new ArrayList<>();

            for (String param : params.keySet()) {

                if (param.equals("table") || param.equals(primaryKey)) {
                    continue;
                }

                if (excludedColumns.contains(param.toUpperCase())) {
                    continue; // skip audit/date columns
                }

                setClauses.add(param + " = ?");
                values.add(req.getParameter(param));
            }

            // auto update modified date
            setClauses.add("MODIFIED_DATE = SYSDATE");

            if (setClauses.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/masters");
                return;
            }

            String sql =
                "UPDATE " + SCHEMA + "." + table +
                " SET " + String.join(", ", setClauses) +
                " WHERE " + primaryKey + " = ?";

            System.out.println(">>> SQL: " + sql);

            PreparedStatement ps = con.prepareStatement(sql);

            int index = 1;
            for (String val : values) {
                ps.setString(index++, val);
            }
            ps.setString(index, pkValue);

            int updated = ps.executeUpdate();
            System.out.println(">>> ROWS UPDATED: " + updated);

            /* ===============================
               SUCCESS → REDIRECT
            =============================== */
            resp.sendRedirect(req.getContextPath() + "/masters");
            return;

        } catch (SQLException e) {

            /* ===============================
               ERROR → BACK TO EDIT PAGE
            =============================== */
            e.printStackTrace();

            String errorMessage = "Invalid input. Please check values.";

            if (e.getMessage().contains("ORA-01722")) {
                errorMessage = "Invalid number format.";
            } else if (e.getMessage().contains("ORA-018")) {
                errorMessage = "Invalid date or time format.";
            } else if (e.getMessage().contains("ORA-12899")) {
                errorMessage = "Value too long for column.";
            }

            // preserve user input
            Map<String, String> row = new HashMap<>();
            for (String key : req.getParameterMap().keySet()) {
                row.put(key, req.getParameter(key));
            }

            req.setAttribute("errorMessage", errorMessage);
            req.setAttribute("table", table);
            req.setAttribute("row", row);
            req.setAttribute("columns", row.keySet());
            req.setAttribute("primaryKey", null);
            req.setAttribute("mode", "EDIT");

            req.getRequestDispatcher("/Master/editRow.jsp")
               .forward(req, resp);
        }
    }
}
