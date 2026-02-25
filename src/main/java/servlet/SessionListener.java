package servlet;

import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;
import db.DBConnection;

public class SessionListener implements HttpSessionListener {

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        System.out.println("Session CREATED: " + se.getSession().getId());
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        System.out.println("Session DESTROYED: " + se.getSession().getId());
        
        HttpSession session = se.getSession();
        String userId = (String) session.getAttribute("userId");
        String branchCode = (String) session.getAttribute("branchCode");

        if (userId != null && branchCode != null) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            try {
                conn = DBConnection.getConnection();
                String sql = "UPDATE ACL.USERREGISTER SET CURRENTLOGIN_STATUS = 'U' WHERE USER_ID = ? AND BRANCH_CODE = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, userId);
                pstmt.setString(2, branchCode);
                pstmt.executeUpdate();
                System.out.println("Session expired - Status reset to U for: " + userId);
            } catch (Exception e) {
                System.err.println("Error resetting status: " + e.getMessage());
            } finally {
                try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
                try { if (conn != null) conn.close(); } catch (Exception ignored) {}
            }
        }
    }
}