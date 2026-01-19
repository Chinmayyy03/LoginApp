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

        try (Connection con = DBConnection.getConnection();
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery(
                 "SELECT * FROM " + schema + "." + table + " WHERE 1=0"
             )) {

            ResultSetMetaData md = rs.getMetaData();
            for (int i = 1; i <= md.getColumnCount(); i++) {
                String col = md.getColumnName(i);
                columns.add(col);
                row.put(col, ""); // default empty for ADD
            }

            if ("EDIT".equalsIgnoreCase(mode)) {
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT * FROM " + schema + "." + table +
                        " WHERE " + columns.get(0) + " = ?")) {

                    ps.setString(1, pk);
                    try (ResultSet rs2 = ps.executeQuery()) {
                        if (rs2.next()) {
                            for (String c : columns) {
                                row.put(c, rs2.getString(c));
                            }
                        }
                    }
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
        req.setAttribute("mode", mode);

        req.getRequestDispatcher("/Master/editRow.jsp").forward(req, resp);
    }
}
