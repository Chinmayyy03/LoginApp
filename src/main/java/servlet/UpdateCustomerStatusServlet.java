package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/UpdateCustomerStatusServlet")
public class UpdateCustomerStatusServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerId = request.getParameter("cid");   // customer ID
        String status = request.getParameter("status");    // A or R

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();

            String sql = "UPDATE CUSTOMERS SET STATUS = ? WHERE CUSTOMER_ID = ?";
            ps = conn.prepareStatement(sql);

            ps.setString(1, status);
            ps.setString(2, customerId);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                System.out.println("✔ Updated: " + customerId + " → " + status);
            } else {
                System.out.println("✘ Failed: No customer found for ID = " + customerId);
            }

            // redirect to customer list page
            response.sendRedirect("authorizationPending.jsp?updated=" + status);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());

        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ex) {}
            try { if (conn != null) conn.close(); } catch (Exception ex) {}
        }
    }
}
