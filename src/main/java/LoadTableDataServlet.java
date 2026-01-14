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
        String table = req.getParameter("table");

        resp.setContentType("text/html");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        /* =========================
           VALIDATION
        ========================= */
        if (schema == null || table == null ||
            !schema.matches("[A-Z0-9_]+") ||
            !table.matches("[A-Z0-9_]+")) {

            out.println("<p style='color:red'>Invalid schema or table</p>");
            return;
        }

        /* =========================
           LOAD TABLE DATA
        ========================= */
        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(
                 "SELECT * FROM " + schema + "." + table
             )) {

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
                String pk = rs.getString(1); // first column = PK

                out.println("<tr>");
                for (int i = 1; i <= cols; i++) {
                    String val = rs.getString(i);
                    out.println("<td>" + (val == null ? "" : val) + "</td>");
                }

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
                out.println("</tr>");
            }

            out.println("</tbody>");
            out.println("</table>");

        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<p style='color:red'>Error loading table data</p>");
        }
    }
}
