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

        if (schema == null || table == null || pk == null) {
            throw new ServletException("Missing parameters");
        }

        List<String> columns = new ArrayList<>();
        Map<String, String> row = new HashMap<>();

        Connection con = null;
        Statement stmt = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        ResultSet rs2 = null;

        try {
            con = DBConnection.getConnection();

            /* ===============================
               LOAD COLUMN LIST
            =============================== */
            stmt = con.createStatement();
            rs = stmt.executeQuery(
                "SELECT * FROM " + schema + "." + table + " WHERE 1=0"
            );

            ResultSetMetaData md = rs.getMetaData();
            for (int i = 1; i <= md.getColumnCount(); i++) {
                columns.add(md.getColumnName(i));
            }

            if (columns.isEmpty()) {
                throw new ServletException("No columns found");
            }

            /* ===============================
               LOAD ROW DATA
            =============================== */
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

        } catch (Exception e) {
            throw new ServletException(e);

        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (rs2 != null) rs2.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }

        /* ===============================
           FORWARD TO JSP
        =============================== */
        req.setAttribute("schema", schema);
        req.setAttribute("table", table);
        req.setAttribute("columns", columns);
        req.setAttribute("row", row);
        req.setAttribute("primaryKey", columns.get(0));
        req.setAttribute("mode", "EDIT");

        req.getRequestDispatcher("/Master/editRow.jsp")
           .forward(req, resp);
    }
}
