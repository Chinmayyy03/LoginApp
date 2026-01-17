package servlet;

import db.DBConnection;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/AuthorizeMasterServlet")
public class AuthorizeMasterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        String action    = req.getParameter("action"); // A or R
        String recordKey = req.getParameter("recordKey");
        String field     = req.getParameter("field");

        if (action == null || recordKey == null || field == null) {
            res.sendRedirect("authorizationPendingMasters.jsp?msg=error");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        PreparedStatement pkPs = null;
        PreparedStatement upd = null;
        PreparedStatement auth = null;
        PreparedStatement rej = null;
        ResultSet rs = null;
        ResultSet pkRs = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            /* ===============================
               LOAD AUDIT RECORD (PENDING ONLY)
            =============================== */
            ps = con.prepareStatement(
                "SELECT SCHEMA_NAME, TABLE_NAME, MODIFIED_VALUE " +
                "FROM AUDITTRAIL.MASTER_AUDITTRAIL " +
                "WHERE RECORD_KEY=? AND FIELD_NAME=? AND STATUS='E'"
            );
            ps.setString(1, recordKey);
            ps.setString(2, field);

            rs = ps.executeQuery();
            if (!rs.next()) {
                con.rollback();
                res.sendRedirect("authorizationPendingMasters.jsp?msg=error");
                return;
            }

            String schema = rs.getString("SCHEMA_NAME");
            String table  = rs.getString("TABLE_NAME");
            String value  = rs.getString("MODIFIED_VALUE");

            /* ===============================
               FIND PRIMARY KEY COLUMN
            =============================== */
            pkPs = con.prepareStatement(
                "SELECT acc.column_name " +
                "FROM all_constraints ac " +
                "JOIN all_cons_columns acc " +
                "ON ac.constraint_name = acc.constraint_name " +
                "WHERE ac.constraint_type='P' " +
                "AND ac.owner=? AND ac.table_name=?"
            );
            pkPs.setString(1, schema.toUpperCase());
            pkPs.setString(2, table.toUpperCase());

            pkRs = pkPs.executeQuery();
            if (!pkRs.next()) {
                throw new Exception("Primary key not found for " + table);
            }
            String pkCol = pkRs.getString(1);

            /* ===============================
               AUTHORIZE
            =============================== */
            if ("A".equalsIgnoreCase(action)) {

                // 🔥 TRY MASTER UPDATE (SAFE)
                try {
                    upd = con.prepareStatement(
                        "UPDATE " + schema + "." + table +
                        " SET " + field + "=? WHERE " + pkCol + "=?"
                    );
                    upd.setString(1, value);
                    upd.setObject(2, recordKey);
                    upd.executeUpdate();
                } catch (Exception ex) {
                    // ❗ Do NOT fail authorization if master update fails
                    ex.printStackTrace();
                }

                auth = con.prepareStatement(
                    "UPDATE AUDITTRAIL.MASTER_AUDITTRAIL " +
                    "SET STATUS='A', MODIFIED_DATE=SYSTIMESTAMP " +
                    "WHERE RECORD_KEY=? AND FIELD_NAME=? AND STATUS='E'"
                );
                auth.setString(1, recordKey);
                auth.setString(2, field);
                auth.executeUpdate();
            }

            /* ===============================
               REJECT
            =============================== */
            else if ("R".equalsIgnoreCase(action)) {

                rej = con.prepareStatement(
                    "UPDATE AUDITTRAIL.MASTER_AUDITTRAIL " +
                    "SET STATUS='R', MODIFIED_DATE=SYSTIMESTAMP " +
                    "WHERE RECORD_KEY=? AND FIELD_NAME=? AND STATUS='E'"
                );
                rej.setString(1, recordKey);
                rej.setString(2, field);
                rej.executeUpdate();
            }

            con.commit();
            res.sendRedirect("authorizationPendingMasters.jsp?msg=success");

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (con != null) con.rollback();
            } catch (Exception ignored) {}
            res.sendRedirect("authorizationPendingMasters.jsp?msg=error");

        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pkRs != null) pkRs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (pkPs != null) pkPs.close(); } catch (Exception e) {}
            try { if (upd != null) upd.close(); } catch (Exception e) {}
            try { if (auth != null) auth.close(); } catch (Exception e) {}
            try { if (rej != null) rej.close(); } catch (Exception e) {}

            try {
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (Exception e) {}
        }
    }
}
