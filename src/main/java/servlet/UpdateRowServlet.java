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

        Connection con = null;
        PreparedStatement pkStmt = null;
        PreparedStatement oldPs = null;
        PreparedStatement mps = null;
        PreparedStatement aps = null;
        ResultSet pkRs = null;
        ResultSet rsOld = null;
        ResultSet mrs = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            /* ===============================
               FIND PRIMARY KEY
            =============================== */
            String primaryKey;

            pkStmt = con.prepareStatement(
                "SELECT acc.column_name " +
                "FROM all_constraints ac " +
                "JOIN all_cons_columns acc " +
                "ON ac.constraint_name = acc.constraint_name " +
                "WHERE ac.constraint_type='P' " +
                "AND ac.owner=? AND ac.table_name=?"
            );
            pkStmt.setString(1, schema.toUpperCase());
            pkStmt.setString(2, table.toUpperCase());

            pkRs = pkStmt.executeQuery();
            if (!pkRs.next()) {
                throw new ServletException("Primary key not found");
            }
            primaryKey = pkRs.getString(1);

            String pkValue = req.getParameter(primaryKey);
            if (pkValue == null || pkValue.trim().isEmpty()) {
                throw new ServletException("Primary key value missing");
            }

            /* ===============================
               LOAD OLD VALUES
            =============================== */
            Map<String, String> oldValues = new HashMap<>();

            oldPs = con.prepareStatement(
                "SELECT * FROM " + schema + "." + table +
                " WHERE " + primaryKey + "=?"
            );
            oldPs.setString(1, pkValue);
            rsOld = oldPs.executeQuery();

            if (!rsOld.next()) {
                throw new ServletException("Record not found");
            }

            ResultSetMetaData md = rsOld.getMetaData();
            for (int i = 1; i <= md.getColumnCount(); i++) {
                oldValues.put(
                    md.getColumnName(i).toUpperCase(),
                    rsOld.getString(i)
                );
            }

            /* ===============================
               GET MASTER NAME
            =============================== */
            String masterName = table;

            mps = con.prepareStatement(
                "SELECT DESCRIPTION FROM GLOBALCONFIG.MASTERS WHERE TABLE_NAME=?"
            );
            mps.setString(1, table.toUpperCase());
            mrs = mps.executeQuery();

            if (mrs.next()) {
                masterName = mrs.getString(1);
            }

            HttpSession session = req.getSession(false);
            String userId = session != null
                    ? (String) session.getAttribute("userId")
                    : "SYSTEM";

            /* ===============================
               INSERT AUDIT ONLY
            =============================== */
            boolean anyChange = false;

            for (Map.Entry<String, String[]> e : req.getParameterMap().entrySet()) {

                String column = e.getKey();
                String newVal = e.getValue()[0];

                if (column.equals("schema") ||
                    column.equals("table") ||
                    column.equals(primaryKey)) continue;

                if (newVal == null || newVal.trim().isEmpty()) continue;

                String oldVal = oldValues.get(column.toUpperCase());

                if (Objects.equals(
                        oldVal == null ? "" : oldVal.trim(),
                        newVal.trim())) continue;

                aps = con.prepareStatement(
                    "INSERT INTO AUDITTRAIL.MASTER_AUDITTRAIL (" +
                    "MASTER_NAME, SCHEMA_NAME, TABLE_NAME, RECORD_KEY, " +
                    "FIELD_NAME, ORIGINAL_VALUE, MODIFIED_VALUE, " +
                    "USER_ID, MODIFICATION_DATE, CREATED_DATE, STATUS) " +
                    "VALUES (?,?,?,?,?,?,?,?,SYSDATE,SYSTIMESTAMP,'E')"
                );

                aps.setString(1, masterName);
                aps.setString(2, schema);
                aps.setString(3, table);
                aps.setString(4, pkValue);
                aps.setString(5, column);
                aps.setString(6, oldVal);
                aps.setString(7, newVal);
                aps.setString(8, userId);
                aps.executeUpdate();

                aps.close();
                aps = null;

                anyChange = true;
            }

            if (!anyChange) {
                con.rollback();
                req.setAttribute("errorMessage", "No data changed");
                req.getRequestDispatcher("/Master/editRow.jsp")
                   .forward(req, resp);
                return;
            }

            con.commit();

            resp.sendRedirect(
                req.getContextPath() +
                "/masters?schema=" + schema +
                "&table=" + table +
                "&pendingAuth=true"
            );

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (con != null) con.rollback();
            } catch (Exception ex) {}

            req.setAttribute("errorMessage", "Unable to submit for authorization");
            req.getRequestDispatcher("/Master/editRow.jsp")
               .forward(req, resp);

        } finally {
            try { if (pkRs != null) pkRs.close(); } catch (Exception e) {}
            try { if (rsOld != null) rsOld.close(); } catch (Exception e) {}
            try { if (mrs != null) mrs.close(); } catch (Exception e) {}
            try { if (pkStmt != null) pkStmt.close(); } catch (Exception e) {}
            try { if (oldPs != null) oldPs.close(); } catch (Exception e) {}
            try { if (mps != null) mps.close(); } catch (Exception e) {}
            try { if (aps != null) aps.close(); } catch (Exception e) {}

            try {
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (Exception e) {}
        }
    }
}

