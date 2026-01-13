import db.DBConnection;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/loadTableData")
public class LoadTableDataServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String table = req.getParameter("table");

        resp.setContentType("text/html");
        PrintWriter out = resp.getWriter();

        if (table == null || !table.matches("[A-Z0-9_]+")) {
            out.println("<p>Invalid table name</p>");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {

            Statement st = con.createStatement();
            ResultSet rs = st.executeQuery(
                "SELECT * FROM GLOBALCONFIG." + table
            );

            ResultSetMetaData md = rs.getMetaData();
            int cols = md.getColumnCount();

            out.println("<table border='1' cellpadding='5'>");
            out.println("<tr>");
            for (int i = 1; i <= cols; i++) {
                out.println("<th>" + md.getColumnName(i) + "</th>");
            }
            out.println("<th>Edit</th>");
            out.println("</tr>");

            while (rs.next()) {
                String pk = rs.getString(1);
                out.println("<tr>");
                for (int i = 1; i <= cols; i++) {
                    out.println("<td>" + rs.getString(i) + "</td>");
                }
                out.println(
                    "<td><a href='editRow?table=" +
                    table + "&pk=" + pk + "'>Edit</a></td>"
                );
                out.println("</tr>");
            }

            out.println("</table>");

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p>Error loading table</p>");
        }
    }
}
