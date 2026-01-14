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
        Map<String,String> row = new HashMap<>();

        try (Connection con = DBConnection.getConnection()) {

            // column list
            ResultSet rs = con.createStatement()
                .executeQuery("SELECT * FROM " + schema + "." + table + " WHERE 1=0");

            ResultSetMetaData md = rs.getMetaData();
            for (int i=1;i<=md.getColumnCount();i++) {
                columns.add(md.getColumnName(i));
            }

            // data row
            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM " + schema + "." + table +
                " WHERE " + columns.get(0) + " = ?"
            );
            ps.setString(1, pk);

            ResultSet rs2 = ps.executeQuery();
            if (rs2.next()) {
                for (String c:columns) {
                    row.put(c, rs2.getString(c));
                }
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }

        req.setAttribute("schema", schema);
        req.setAttribute("table", table);
        req.setAttribute("columns", columns);
        req.setAttribute("row", row);
        req.setAttribute("primaryKey", columns.get(0));
        req.setAttribute("mode", "EDIT");

        req.getRequestDispatcher("/Master/editRow.jsp").forward(req, resp);
    }
}
