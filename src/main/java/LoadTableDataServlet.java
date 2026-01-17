import db.DBConnection;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/loadTableData")
public class LoadTableDataServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String schema = req.getParameter("schema");
        String table  = req.getParameter("table");

        resp.setContentType("text/html");
        resp.setCharacterEncoding("UTF-8");

        PrintWriter out = resp.getWriter();

        /* =========================
           VALIDATION
        ========================= */
        if (schema == null || table == null ||
            !schema.matches("[A-Za-z0-9_]+") ||
            !table.matches("[A-Za-z0-9_]+")) {

            out.println("<p style='color:red'>Invalid schema or table</p>");
            return;
        }

        Connection con = null;
        Statement st = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();
            st = con.createStatement();
            rs = st.executeQuery(
                "SELECT * FROM " + schema + "." + table
            );

            ResultSetMetaData md = rs.getMetaData();
            int cols = md.getColumnCount();

            /* =========================
               TABLE HEADER
            ========================= */
            out.println("<table class='data-table'>");
            out.println("<thead><tr>");

            for (int i = 1; i <= cols; i++) {
                out.println("<th>" + md.getColumnName(i) + "</th>");
            }
            out.println("<th>Edit</th>");
            out.println("</tr></thead>");

            /* =========================
               TABLE BODY
            ========================= */
            out.println("<tbody>");

            while (rs.next()) {

                String pk;
                try {
                    pk = rs.getString(1); // first column assumed PK
                } catch (Exception ex) {
                    pk = "";
                }

                out.println("<tr>");

                for (int i = 1; i <= cols; i++) {
                    Object val = rs.getObject(i);

                    if (val == null) {
                        out.println("<td></td>");
                    } else if (val instanceof Clob) {
                        out.println("<td>[CLOB]</td>");
                    } else if (val instanceof Blob) {
                        out.println("<td>[BLOB]</td>");
                    } else {
                        out.println("<td>" + val + "</td>");
                    }
                }

                /* =========================
                   EDIT BUTTON
                ========================= */
                if (pk != null && !pk.trim().isEmpty()) {
                    out.println(
                        "<td style='text-align:center'>" +
                        "<a class='edit-btn' href='" +
                        req.getContextPath() +
                        "/editRow?schema=" + schema +
                        "&table=" + table +
                        "&pk=" + pk +
                        "'>Edit</a>" +
                        "</td>"
                    );
                } else {
                    out.println("<td style='color:#999;text-align:center'>N/A</td>");
                }

                out.println("</tr>");
            }

            out.println("</tbody>");
            out.println("</table>");

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:red'>Error loading table data</p>");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (st != null) st.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
            try { if (out != null) out.flush(); } catch (Exception e) {}
        }
    }
}
