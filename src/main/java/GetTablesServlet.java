import db.DBConnection;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/getTables")
public class GetTablesServlet extends HttpServlet {

    private static final String SCHEMA = "GLOBALCONFIG";

    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String prefix = req.getParameter("prefix");
        List<String> tables = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT table_name FROM all_tables " +
                 "WHERE owner=? AND table_name LIKE ? ORDER BY table_name"
             )) {

            ps.setString(1, SCHEMA);
            ps.setString(2, prefix.toUpperCase() + "%");

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                tables.add(rs.getString("table_name"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < tables.size(); i++) {
            json.append("\"").append(tables.get(i)).append("\"");
            if (i < tables.size() - 1) json.append(",");
        }
        json.append("]");

        resp.getWriter().write(json.toString());
    }
}
