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
import javax.servlet.http.HttpSession;

@WebServlet("/Authorization/UpdateCustomerStatusServlet")
public class UpdateCustomerStatusServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // Generate Officer ID based on user ID
    private String generateOfficerId(String userId) {
        // Take first 2 characters of userId, or pad if shorter
        if (userId == null || userId.isEmpty()) {
            return "00";
        }
        if (userId.length() >= 2) {
            return userId.substring(0, 2).toUpperCase();
        } else {
            return (userId + "0").substring(0, 2).toUpperCase();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        String customerId = request.getParameter("cid");
        String status = request.getParameter("status");

        Connection conn = null;
        PreparedStatement psCustomer = null;
        PreparedStatement psPhoto = null;
        PreparedStatement psSignature = null;

        try {
            conn = DBConnection.getConnection();

            // Update customer status
            String sqlCustomer = "UPDATE CUSTOMERS SET STATUS = ? WHERE CUSTOMER_ID = ?";
            psCustomer = conn.prepareStatement(sqlCustomer);
            psCustomer.setString(1, status);
            psCustomer.setString(2, customerId);
            int rows = psCustomer.executeUpdate();

            if (rows > 0) {
                System.out.println("✔ Updated: " + customerId + " → " + status);
                
                // If authorized (status = 'A'), update OFFICER_ID in photo and signature tables
                if ("A".equals(status)) {
                    String officerId = generateOfficerId(userId);
                    
                    // Update OFFICER_ID in CUSTOMERPHOTO
                    String sqlPhoto = "UPDATE SIGNATURES.CUSTOMERPHOTO SET OFFICER_ID = ? WHERE CUSTOMER_ID = ?";
                    psPhoto = conn.prepareStatement(sqlPhoto);
                    psPhoto.setString(1, officerId);
                    psPhoto.setString(2, customerId);
                    psPhoto.executeUpdate();
                    System.out.println("✔ Updated OFFICER_ID in CUSTOMERPHOTO: " + officerId);
                    
                    // Update OFFICER_ID in CUSTOMERSIGNATURE
                    String sqlSignature = "UPDATE SIGNATURES.CUSTOMERSIGNATURE SET OFFICER_ID = ? WHERE CUSTOMER_ID = ?";
                    psSignature = conn.prepareStatement(sqlSignature);
                    psSignature.setString(1, officerId);
                    psSignature.setString(2, customerId);
                    psSignature.executeUpdate();
                    System.out.println("✔ Updated OFFICER_ID in CUSTOMERSIGNATURE: " + officerId);
                }
            } else {
                System.out.println("✘ Failed: No customer found for ID = " + customerId);
            }

            response.sendRedirect("authorizationPendingCustomers.jsp?updated=" + status);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());

        } finally {
            try { if (psCustomer != null) psCustomer.close(); } catch (Exception ex) {}
            try { if (psPhoto != null) psPhoto.close(); } catch (Exception ex) {}
            try { if (psSignature != null) psSignature.close(); } catch (Exception ex) {}
            try { if (conn != null) conn.close(); } catch (Exception ex) {}
        }
    }
}