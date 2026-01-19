import db.DBConnection;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/insertRow")
public class InsertRowServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String schema = req.getParameter("schema");
        String table  = req.getParameter("table");

        HttpSession session = req.getSession(false);
        String userId = session != null
                ? (String) session.getAttribute("userId")
                : "SYSTEM";

        if (schema == null || table == null ||
            schema.trim().isEmpty() || table.trim().isEmpty()) {

            resp.sendRedirect(req.getContextPath() + "/masters");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();

            /* =========================
               FIND PRIMARY KEY COLUMN
            ========================= */
            ps = con.prepareStatement(
                "SELECT acc.column_name " +
                "FROM all_constraints ac " +
                "JOIN all_cons_columns acc " +
                "ON ac.constraint_name = acc.constraint_name " +
                "WHERE ac.constraint_type='P' " +
                "AND ac.owner=? AND ac.table_name=?"
            );
            ps.setString(1, schema.toUpperCase());
            ps.setString(2, table.toUpperCase());

            rs = ps.executeQuery();
            if (!rs.next()) {
                throw new Exception("Primary key not found");
            }
            String pkCol = rs.getString(1);

            rs.close();
            ps.close();

            String pkVal = req.getParameter(pkCol);
            if (pkVal == null || pkVal.trim().isEmpty()) {
                throw new Exception("Primary key value missing");
            }

            /* =========================
               INSERT AUDIT RECORDS (ADD)
            ========================= */
            for (Map.Entry<String,String[]> e : req.getParameterMap().entrySet()) {

                String column = e.getKey();

                if ("schema".equals(column) ||
                    "table".equals(column)) {
                    continue;
                }

                String newVal = e.getValue()[0];

                // ✅ skip empty values
                if (newVal == null || newVal.trim().isEmpty()) {
                    continue;
                }

                ps = con.prepareStatement(
                    "INSERT INTO AUDITTRAIL.MASTER_AUDITTRAIL (" +
                    "MASTER_NAME, SCHEMA_NAME, TABLE_NAME, RECORD_KEY, " +
                    "FIELD_NAME, ORIGINAL_VALUE, MODIFIED_VALUE, " +
                    "USER_ID, STATUS, CREATED_DATE" +
                    ") VALUES (?,?,?,?,?,?,?,?, 'E', SYSTIMESTAMP)"
                );

                ps.setString(1, table);
                ps.setString(2, schema);
                ps.setString(3, table);
                ps.setString(4, pkVal);     // PK value
                ps.setString(5, column);   // column name
                ps.setString(6, null);     // original value (ADD)
                ps.setString(7, newVal);   // new value
                ps.setString(8, userId);

                ps.executeUpdate();
                ps.close();
            }

        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }

        /* =========================
           REDIRECT TO PENDING AUTH
        ========================= */
        resp.sendRedirect(
            req.getContextPath() +
            "/masters?schema=" + schema +
            "&table=" + table +
            "&pendingAuth=true"
        );
    }
}
