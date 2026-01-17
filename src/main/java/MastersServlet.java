import db.DBConnection;

import javax.servlet.ServletException;
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

        List<Map<String, String>> cards = new ArrayList<>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();

            ps = con.prepareStatement(
                "SELECT DESCRIPTION, TABLE_NAME " +
                "FROM GLOBALCONFIG.MASTERS " +
                "ORDER BY SR_NUMBER"
            );

            rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> card = new HashMap<>();
                card.put("title", rs.getString("DESCRIPTION"));
                card.put("schema", rs.getString("TABLE_NAME"));
                cards.add(card);

                System.out.println("CARD: " + card);
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);

        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }

        req.setAttribute("cards", cards);
        req.getRequestDispatcher("/Master/masters.jsp")
           .forward(req, resp);
    }
}
