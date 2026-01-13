import db.DBConnection;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/masters")
public class MastersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        System.out.println(">>> MastersServlet CALLED <<<");

        List<Map<String, String>> mastersList = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            System.out.println("DB USER = " + con.getMetaData().getUserName());

            PreparedStatement ps = con.prepareStatement(
                "SELECT DESCRIPTION, TABLE_NAME " +
                "FROM GLOBALCONFIG.MASTERS " +
                "ORDER BY SR_NUMBER"
            );

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                row.put("DESCRIPTION", rs.getString("DESCRIPTION"));
                row.put("TABLE_NAME", rs.getString("TABLE_NAME"));
                mastersList.add(row);

                System.out.println(
                    "CARD => " +
                    rs.getString("DESCRIPTION") + " | " +
                    rs.getString("TABLE_NAME")
                );
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }

        System.out.println("TOTAL CARDS = " + mastersList.size());

        req.setAttribute("mastersList", mastersList);
        req.getRequestDispatcher("/Master/masters.jsp")
           .forward(req, resp);
    }
}
