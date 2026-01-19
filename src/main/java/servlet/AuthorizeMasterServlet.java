package servlet;

import db.DBConnection;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/AuthorizeMasterServlet")
public class AuthorizeMasterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        String action    = req.getParameter("action"); // A or R
        String recordKey = req.getParameter("recordKey");

        if (action == null || recordKey == null) {
            res.sendRedirect("authorizationPendingMasters.jsp?msg=error");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        PreparedStatement updAudit = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            /* ================= LOAD AUDIT DATA ================= */
            ps = con.prepareStatement(
                "SELECT SCHEMA_NAME, TABLE_NAME, FIELD_NAME, MODIFIED_VALUE " +
                "FROM AUDITTRAIL.MASTER_AUDITTRAIL " +
                "WHERE RECORD_KEY=? AND STATUS='E'"
            );
            ps.setString(1, recordKey);
            rs = ps.executeQuery();

            Map<String,String> fieldMap = new LinkedHashMap<>();
            String schema = null;
            String table  = null;

            while (rs.next()) {
                schema = rs.getString("SCHEMA_NAME");
                table  = rs.getString("TABLE_NAME");
                fieldMap.put(
                    rs.getString("FIELD_NAME").toUpperCase(),
                    rs.getString("MODIFIED_VALUE")
                );
            }

            rs.close();
            ps.close();

            if (fieldMap.isEmpty()) {
                con.rollback();
                res.sendRedirect("authorizationPendingMasters.jsp?msg=error");
                return;
            }

            /* ================= FIND PRIMARY KEY ================= */
            String pkCol = null;

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

            if (rs.next()) {
                pkCol = rs.getString(1).toUpperCase();
            } else {
                throw new Exception("Primary key not found");
            }

            rs.close();
            ps.close();

            /* ================= CLEAN AUDIT DATA ================= */
            fieldMap.remove(pkCol);              // PK
            fieldMap.remove("CREATED_DATE");     // SYSTEM DATE
            fieldMap.remove("MODIFIED_DATE");    // SYSTEM DATE
            fieldMap.remove("CREATED_ON");
            fieldMap.remove("UPDATED_DATE");
            fieldMap.remove("UPDATED_ON");

            /* ================= AUTHORIZE ================= */
            if ("A".equalsIgnoreCase(action)) {

                boolean exists = false;

                ps = con.prepareStatement(
                    "SELECT COUNT(*) FROM " + schema + "." + table +
                    " WHERE " + pkCol + "=?"
                );
                ps.setString(1, recordKey);
                rs = ps.executeQuery();

                if (rs.next() && rs.getInt(1) > 0) {
                    exists = true;
                }

                rs.close();
                ps.close();

                /* ---------- UPDATE ---------- */
                if (exists) {

                    StringBuilder sql =
                        new StringBuilder("UPDATE " + schema + "." + table + " SET ");

                    for (String col : fieldMap.keySet()) {
                        sql.append(col).append("=?,");
                    }
                    sql.setLength(sql.length() - 1);
                    sql.append(" WHERE ").append(pkCol).append("=?");

                    ps = con.prepareStatement(sql.toString());

                    int i = 1;
                    for (String val : fieldMap.values()) {
                        ps.setString(i++, val);
                    }
                    ps.setString(i, recordKey);

                    ps.executeUpdate();
                    ps.close();

                }
                /* ---------- INSERT (ONCE ONLY) ---------- */
                else {

                    StringBuilder cols = new StringBuilder(pkCol + ",");
                    StringBuilder qs   = new StringBuilder("?,");

                    for (String col : fieldMap.keySet()) {
                        cols.append(col).append(",");
                        qs.append("?,");
                    }

                    cols.setLength(cols.length() - 1);
                    qs.setLength(qs.length() - 1);

                    ps = con.prepareStatement(
                        "INSERT INTO " + schema + "." + table +
                        " (" + cols + ") VALUES (" + qs + ")"
                    );

                    int i = 1;
                    ps.setString(i++, recordKey);

                    for (String val : fieldMap.values()) {
                        ps.setString(i++, val);
                    }

                    ps.executeUpdate();
                    ps.close();
                }

                /* ---------- MARK AUDIT AUTHORIZED ---------- */
                updAudit = con.prepareStatement(
                    "UPDATE AUDITTRAIL.MASTER_AUDITTRAIL " +
                    "SET STATUS='A', MODIFIED_DATE=SYSTIMESTAMP " +
                    "WHERE RECORD_KEY=? AND STATUS='E'"
                );
                updAudit.setString(1, recordKey);
                updAudit.executeUpdate();
                updAudit.close();
            }

            /* ================= REJECT ================= */
            else if ("R".equalsIgnoreCase(action)) {

                updAudit = con.prepareStatement(
                    "UPDATE AUDITTRAIL.MASTER_AUDITTRAIL " +
                    "SET STATUS='R', MODIFIED_DATE=SYSTIMESTAMP " +
                    "WHERE RECORD_KEY=? AND STATUS='E'"
                );
                updAudit.setString(1, recordKey);
                updAudit.executeUpdate();
                updAudit.close();
            }

            con.commit();
            res.sendRedirect("authorizationPendingMasters.jsp?msg=success");

        } catch (Exception e) {
            e.printStackTrace();
            try { if (con != null) con.rollback(); } catch (Exception ignored) {}
            res.sendRedirect("authorizationPendingMasters.jsp?msg=error");
        } finally {
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}
