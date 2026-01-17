import db.DBConnection;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/insertRow")
public class InsertRowServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String table = req.getParameter("table");

        if (table == null || table.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/masters");
            return;
        }

        Map<String, String[]> params = req.getParameterMap();

        StringBuilder cols = new StringBuilder();
        StringBuilder vals = new StringBuilder();
        List<String> values = new ArrayList<>();

        for (String key : params.keySet()) {
            if (!"table".equals(key) && !"schema".equals(key)) {
                cols.append(key).append(",");
                vals.append("?,");

                values.add(req.getParameter(key));
            }
        }

        if (values.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/masters");
            return;
        }

        String sql =
            "INSERT INTO " + table +
            " (" + cols.substring(0, cols.length() - 1) + ")" +
            " VALUES (" + vals.substring(0, vals.length() - 1) + ")";

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);

            for (int i = 0; i < values.size(); i++) {
                ps.setString(i + 1, values.get(i));
            }

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }

        resp.sendRedirect(req.getContextPath() + "/masters");
    }
}
