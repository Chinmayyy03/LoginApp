package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Base64;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/UploadPhotoSignatureServlet")
public class UploadPhotoSignatureServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        String customerId = request.getParameter("customerId");
        String photoData = request.getParameter("photoData");
        String signatureData = request.getParameter("signatureData");

        Connection conn = null;
        PreparedStatement psPhoto = null;
        PreparedStatement psSignature = null;
        PreparedStatement psGetDate = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // Get registration date from CUSTOMERS table
            String registrationDate = null;
            psGetDate = conn.prepareStatement(
                "SELECT REGISTRATION_DATE FROM CUSTOMERS WHERE CUSTOMER_ID = ?"
            );
            psGetDate.setString(1, customerId);
            rs = psGetDate.executeQuery();
            if (rs.next()) {
                registrationDate = rs.getString("REGISTRATION_DATE");
            }
            rs.close();
            psGetDate.close();

            // Insert Photo
            if (photoData != null && !photoData.isEmpty()) {
                // Remove data:image/...;base64, prefix if present
                if (photoData.contains(",")) {
                    photoData = photoData.split(",")[1];
                }
                
                byte[] photoBytes = Base64.getDecoder().decode(photoData);
                
                String photoFilename = "PHOTO_" + customerId + ".jpg";
                
                String sqlPhoto = "INSERT INTO SIGNATURES.CUSTOMERPHOTO " +
                                "(CUSTOMER_ID, PHOTO, USER_ID, OFFICER_ID, DATEOFREGISTRATION, PHOTOFILENAME, UPLOAD_ID) " +
                                "VALUES (?, ?, ?, NULL, TO_DATE(?, 'YYYY-MM-DD'), ?, ?)";
                
                psPhoto = conn.prepareStatement(sqlPhoto);
                psPhoto.setString(1, customerId);
                psPhoto.setBytes(2, photoBytes);
                psPhoto.setString(3, userId);
                psPhoto.setString(4, registrationDate);
                psPhoto.setString(5, photoFilename);
                psPhoto.setString(6, userId);
                
                psPhoto.executeUpdate();
                System.out.println("✅ Photo inserted for customer: " + customerId);
            }

            // Insert Signature
            if (signatureData != null && !signatureData.isEmpty()) {
                // Remove data:image/...;base64, prefix if present
                if (signatureData.contains(",")) {
                    signatureData = signatureData.split(",")[1];
                }
                
                byte[] signatureBytes = Base64.getDecoder().decode(signatureData);
                
                String signatureFilename = "SIGN_" + customerId + ".jpg";
                
                String sqlSignature = "INSERT INTO SIGNATURES.CUSTOMERSIGNATURE " +
                                    "(CUSTOMER_ID, SIGNATURE, USER_ID, OFFICER_ID, DATEOFREGISTRATION, SIGNATUREFILENAME, UPLOAD_ID) " +
                                    "VALUES (?, ?, ?, NULL, TO_DATE(?, 'YYYY-MM-DD'), ?, ?)";
                
                psSignature = conn.prepareStatement(sqlSignature);
                psSignature.setString(1, customerId);
                psSignature.setBytes(2, signatureBytes);
                psSignature.setString(3, userId);
                psSignature.setString(4, registrationDate);
                psSignature.setString(5, signatureFilename);
                psSignature.setString(6, userId);
                
                psSignature.executeUpdate();
                System.out.println("✅ Signature inserted for customer: " + customerId);
            }

            response.getWriter().println("SUCCESS");

        } catch (Exception e) {
            System.out.println("❌ ERROR: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().println("ERROR: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (psPhoto != null) psPhoto.close(); } catch (Exception ignored) {}
            try { if (psSignature != null) psSignature.close(); } catch (Exception ignored) {}
            try { if (psGetDate != null) psGetDate.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
}