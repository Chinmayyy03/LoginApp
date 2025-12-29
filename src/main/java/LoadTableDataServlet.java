import db.DBConnection;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/loadTableData")
public class LoadTableDataServlet extends HttpServlet {

    // 🔴 CHANGE this if schema name is different
    private static final String SCHEMA = "GLOBALCONFIG";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
    	
        String tableName = req.getParameter("table");

        // Basic validation
        if (tableName == null || tableName.trim().isEmpty()) {
            resp.getWriter().println("Invalid table name");
            return;
        }

        resp.setContentType("text/html");

        String sql = "SELECT * FROM " + SCHEMA + "." + tableName;

        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            ResultSetMetaData md = rs.getMetaData();
            int columnCount = md.getColumnCount();

            PrintWriter out = resp.getWriter();

            out.println("<table class='data-table'>");
            out.println("<tr>");

            for (int i = 1; i <= columnCount; i++) {
                out.println("<th>" + md.getColumnName(i) + "</th>");
            }
            out.println("<th>Edit</th>");
            out.println("</tr>");

            boolean hasData = false;

            while (rs.next()) {
                hasData = true;
                out.println("<tr>");

                String pkValue = rs.getString(1); // assume 1st column is PK

                for (int i = 1; i <= columnCount; i++) {
                    out.println("<td>" + rs.getString(i) + "</td>");
                }

                out.println(
                	    "<td>" +
                	    "<a class='edit-btn' href='" +
                	    req.getContextPath() +
                	    "/editRow?table=" + tableName +
                	    "&pk=" + pkValue +
                	    "'>Edit</a>" +
                	    "</td>"
                	);

                out.println("</tr>");
            }

            if (!hasData) {
                out.println("<tr><td colspan='" + (columnCount + 1) +
                        "' style='text-align:center'>No data found</td></tr>");
            }

            out.println("</table>");

        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().println("Error loading data");
        }
    }
}
