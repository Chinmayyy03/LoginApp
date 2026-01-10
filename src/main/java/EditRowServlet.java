import db.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/editRow")
public class EditRowServlet extends HttpServlet {

    private static final String SCHEMA = "GLOBALCONFIG"; // adjust if needed

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        System.out.println(">>> EditRowServlet CALLED <<<");

        String table = req.getParameter("table");
        String pk = req.getParameter("pk");

        if (table == null || table.trim().isEmpty()) {
            // ❌ DO NOT WRITE TO RESPONSE
            throw new ServletException("Table name missing");
        }

        List<String> columns = new ArrayList<>();
        Map<String, String> row = new HashMap<>();
        String primaryKey;

        try (Connection con = DBConnection.getConnection()) {

            /* =========================
               GET COLUMNS
            ========================= */
            Statement st = con.createStatement();
            ResultSet rs =
                st.executeQuery(
                    "SELECT * FROM " + SCHEMA + "." + table + " WHERE 1=0"
                );

            ResultSetMetaData md = rs.getMetaData();
            int colCount = md.getColumnCount();

            for (int i = 1; i <= colCount; i++) {
                columns.add(md.getColumnName(i));
            }

            primaryKey = columns.get(0); // assume first column is PK

            /* =========================
               EDIT MODE
            ========================= */
            if (pk != null && !pk.isEmpty()) {

                PreparedStatement ps =
                    con.prepareStatement(
                        "SELECT * FROM " + SCHEMA + "." + table +
                        " WHERE " + primaryKey + " = ?"
                    );
                ps.setString(1, pk);

                ResultSet rs2 = ps.executeQuery();
                if (rs2.next()) {
                    for (String col : columns) {
                        row.put(col, rs2.getString(col));
                    }
                }

                req.setAttribute("mode", "EDIT");
            }
            /* =========================
               ADD MODE
            ========================= */
            else {
                for (String col : columns) {
                    row.put(col, "");
                }
                req.setAttribute("mode", "ADD");
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }

        /* =========================
           SET ATTRIBUTES
        ========================= */
        req.setAttribute("table", table);
        req.setAttribute("columns", columns);
        req.setAttribute("row", row);
        req.setAttribute("primaryKey", primaryKey);

        /* =========================
           FORWARD TO JSP
        ========================= */
        req.getRequestDispatcher("/Master/editRow.jsp")
           .forward(req, resp);
    }
}
