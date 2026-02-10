package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import db.DBConnection;

@WebServlet("/UserAuthorizationServlet")
public class UserAuthorizationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // ===== PARAMETERS =====
        String userId = request.getParameter("userId");
        String status = request.getParameter("status");
        String password = request.getParameter("password");

        if (userId == null || userId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/authorizationPendingUsers.jsp");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            // ================= AUTHORIZE =================
            if ("A".equals(status)) {

                String sql =
                    "UPDATE ACL.USERREGISTER " +
                    "SET STATUS = ?, " +
                    "PASSWD = acl.toolkit.encrypt(?), " +   // 🔐 DB Encryption
                    "AUTHORIZED_BY = CREATED_BY " +
                    "WHERE USER_ID = ?";

                try (PreparedStatement ps = conn.prepareStatement(sql)) {

                    ps.setString(1, "A");
                    ps.setString(2, password);   // Plain password → Oracle encrypts
                    ps.setString(3, userId);

                    int rows = ps.executeUpdate();
                    updateSessionStatus(rows, "A", session);
                }

            }

            // ================= REJECT =================
            else if ("R".equals(status)) {

                String sql =
                    "UPDATE ACL.USERREGISTER " +
                    "SET STATUS = ? " +
                    "WHERE USER_ID = ?";

                try (PreparedStatement ps = conn.prepareStatement(sql)) {

                    ps.setString(1, "R");
                    ps.setString(2, userId);

                    int rows = ps.executeUpdate();
                    updateSessionStatus(rows, "R", session);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/authorizationPendingUsers.jsp");
    }

    // ===== SESSION MESSAGE =====
    private void updateSessionStatus(int rowsAffected, String status, HttpSession session) {

        if (session == null) return;

        if (rowsAffected > 0) {
            session.setAttribute(
                "message",
                "A".equals(status)
                    ? "Authorized Successfully!"
                    : "Rejected Successfully!"
            );
            session.setAttribute("messageType", "success");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
