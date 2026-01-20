import db.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/editRow")
public class EditRowServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String schema = req.getParameter("schema");
        String table  = req.getParameter("table");
        String pk     = req.getParameter("pk");
        String mode   = req.getParameter("mode"); // ADD or EDIT

        if (schema == null || table == null) {
            throw new ServletException("Schema or table missing");
        }

        if (mode == null || mode.isEmpty()) {
            mode = "EDIT";
        }

        if ("EDIT".equalsIgnoreCase(mode) && (pk == null || pk.trim().isEmpty())) {
            throw new ServletException("Primary key missing for edit");
        }

        List<String> columns = new ArrayList<>();
        Map<String, String> row = new HashMap<>();

        Connection con = null;
        Statement stmt = null;
        Statement stCnt = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        ResultSet rsCnt = null;
        ResultSet rs2 = null;

        try {
            con = DBConnection.getConnection();

            /* =========================
               LOAD COLUMN METADATA
            ========================= */
            stmt = con.createStatement();
            rs = stmt.executeQuery(
                "SELECT * FROM " + schema + "." + table + " WHERE 1=0"
            );

            ResultSetMetaData md = rs.getMetaData();
            for (int i = 1; i <= md.getColumnCount(); i++) {
                String col = md.getColumnName(i);
                columns.add(col);
                row.put(col, "");
            }

            /* =========================
               TABLE RECORD COUNT
               (DISPLAY ONLY)
            ========================= */
            int recordCount = 0;
            stCnt = con.createStatement();
            rsCnt = stCnt.executeQuery(
                "SELECT COUNT(*) FROM " + schema + "." + table
            );

            if (rsCnt.next()) {
                recordCount = rsCnt.getInt(1);
            }
            req.setAttribute("recordCount", recordCount);

            /* =========================
               EDIT MODE → LOAD DATA
            ========================= */
            if ("EDIT".equalsIgnoreCase(mode)) {
                ps = con.prepareStatement(
                    "SELECT * FROM " + schema + "." + table +
                    " WHERE " + columns.get(0) + " = ?"
                );
                ps.setString(1, pk);
                rs2 = ps.executeQuery();

                if (rs2.next()) {
                    for (String c : columns) {
                        row.put(c, rs2.getString(c));
                    }
                }
            }

        } catch (Exception e) {
            throw new ServletException(e);

        } finally {
            try { if (rs2 != null) rs2.close(); } catch (Exception e) {}
            try { if (rsCnt != null) rsCnt.close(); } catch (Exception e) {}
            try { if (rs != null) rs.close(); } catch (Exception e) {}

            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (stCnt != null) stCnt.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}

            try {
                if (con != null) {
                    con.close();
                }
            } catch (Exception e) {}
        }

        req.setAttribute("schema", schema);
        req.setAttribute("table", table);
        req.setAttribute("columns", columns);
        req.setAttribute("row", row);
        req.setAttribute("primaryKey", columns.get(0));
        req.setAttribute("mode", mode);

        req.getRequestDispatcher("/Master/editRow.jsp").forward(req, resp);
    }
}
