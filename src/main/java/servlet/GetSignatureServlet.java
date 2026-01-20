package servlet;

import java.io.IOException;
import java.io.OutputStream;
import java.sql.Blob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import db.DBConnection;

@WebServlet("/GetSignatureServlet")
public class GetSignatureServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String customerId = request.getParameter("customerId");
        
        if (customerId == null || customerId.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Customer ID is required");
            return;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            
            // Query to get signature from SIGNATURES.CUSTOMERSIGNATURE table
            ps = conn.prepareStatement(
                "SELECT SIGNATURE FROM SIGNATURES.CUSTOMERSIGNATURE WHERE CUSTOMER_ID = ?"
            );
            ps.setString(1, customerId);
            rs = ps.executeQuery();

            if (rs.next()) {
                Blob signatureBlob = rs.getBlob("SIGNATURE");
                
                if (signatureBlob != null) {
                    // Set content type for image
                    response.setContentType("image/jpeg"); // Change to image/png if needed
                    
                    // Get blob bytes
                    byte[] imageBytes = signatureBlob.getBytes(1, (int) signatureBlob.length());
                    
                    // Set content length
                    response.setContentLength(imageBytes.length);
                    
                    // Write image to output stream
                    OutputStream out = response.getOutputStream();
                    out.write(imageBytes);
                    out.flush();
                    out.close();
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Signature not found");
                }
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "No signature found for customer");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Error retrieving signature: " + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}