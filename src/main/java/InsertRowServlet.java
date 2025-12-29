import db.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;


@WebServlet("/insertRow")
public class InsertRowServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String table = req.getParameter("table");

        Map<String, String[]> params = req.getParameterMap();

        StringBuilder cols = new StringBuilder();
        StringBuilder vals = new StringBuilder();
        List<String> values = new ArrayList<>();

        for (String key : params.keySet()) {
            if (!"table".equals(key)) {
                cols.append(key).append(",");
                vals.append("?,");
                values.add(req.getParameter(key));
            }
        }

        String sql =
            "INSERT INTO " + table +
            " (" + cols.substring(0, cols.length()-1) + ")" +
            " VALUES (" + vals.substring(0, vals.length()-1) + ")";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            for (int i = 0; i < values.size(); i++) {
                ps.setString(i + 1, values.get(i));
            }

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

        resp.sendRedirect("masters");
    }
}
