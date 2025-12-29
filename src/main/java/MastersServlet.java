import db.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/masters")
public class MastersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        System.out.println(">>> MastersServlet CALLED");

        List<String> tableList = new ArrayList<>();

        // 🔴 CHANGE THIS to your actual schema name
        final String OWNER = "GLOBALCONFIG";

        try (Connection con = DBConnection.getConnection()) {

            System.out.println(">>> DB CONNECTED");

            PreparedStatement ps = con.prepareStatement(
                "SELECT table_name " +
                "FROM all_tables " +
                "WHERE owner = ? " +
                "ORDER BY table_name"
            );

            ps.setString(1, OWNER.toUpperCase());

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                String table = rs.getString("table_name");
                System.out.println(">>> FOUND TABLE: " + table);
                tableList.add(table);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        System.out.println(">>> TOTAL TABLES: " + tableList.size());

        req.setAttribute("tableList", tableList);
        req.getRequestDispatcher("/Master/masters.jsp")
           .forward(req, resp);
    }
}
