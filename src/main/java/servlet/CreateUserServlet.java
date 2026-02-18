package servlet;

import db.DBConnection;
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

@WebServlet("/Utility/CreateUserServlet")
public class CreateUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String createdBy = (session != null) ? (String) session.getAttribute("userId") : "";

        String userId     = request.getParameter("userId");
        String userName   = request.getParameter("userName");
        String branchCode = request.getParameter("branchCode");
        String custId     = request.getParameter("custId");
        String empCode    = request.getParameter("empCode");
        String addr1      = request.getParameter("addr1");
        String addr2      = request.getParameter("addr2");
        String addr3      = request.getParameter("addr3");
        String phone      = request.getParameter("phone");
        String mobile     = request.getParameter("mobile");
        String email      = request.getParameter("email");
        String[] roleIds  = request.getParameterValues("roles");

        boolean success = false;
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // STEP 1: Insert user with STATUS='E'
            String userSql =
                "INSERT INTO ACL.USERREGISTER " +
                "(USER_ID, NAME, BRANCH_CODE, CUSTOMER_ID, EMPLOYEE_CODE, " +
                "CURRENTADDRESS1, CURRENTADDRESS2, CURRENTADDRESS3, " +
                "PHONE_NUMBER, MOBILE_NUMBER, EMAILADDRESS, CREATED_BY, STATUS) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'E')";

            try (PreparedStatement pstmt = conn.prepareStatement(userSql)) {
                pstmt.setString(1,  userId);
                pstmt.setString(2,  userName);
                pstmt.setString(3,  branchCode);
                pstmt.setString(4,  custId);
                pstmt.setString(5,  empCode);
                pstmt.setString(6,  addr1);
                pstmt.setString(7,  addr2);
                pstmt.setString(8,  addr3);
                pstmt.setString(9,  phone);
                pstmt.setString(10, mobile);
                pstmt.setString(11, email);
                pstmt.setString(12, createdBy);
                pstmt.executeUpdate();
            }

            // STEP 2: Insert roles into ACL.USERPENDINGROLES with STATUS='P'
            if (roleIds != null && roleIds.length > 0) {
                String roleSql =
                    "INSERT INTO ACL.USERPENDINGROLES " +
                    "(USER_ID, MAINROLE_ID, BRANCH_CODE, STATUS, CREATED_BY, CREATED_DATE) " +
                    "VALUES (?, ?, ?, 'P', ?, SYSDATE)";

                try (PreparedStatement pstmt = conn.prepareStatement(roleSql)) {
                    for (String roleId : roleIds) {
                        pstmt.setString(1, userId);
                        pstmt.setInt(2,    Integer.parseInt(roleId.trim()));
                        pstmt.setString(3, branchCode);
                        pstmt.setString(4, createdBy);
                        pstmt.addBatch();
                    }
                    pstmt.executeBatch();
                }
            }

            conn.commit();
            success = true;

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
        }

        // Store result in SESSION — survives forward reliably
        if (session != null) {
            session.setAttribute("popupStatus", success ? "success" : "error");
            session.setAttribute("popupMsg", success
                ? "User created successfully. Roles are pending authorization."
                : "User creation failed. Please try again.");
        }

        request.getRequestDispatcher("/Utility/NewUser.jsp").forward(request, response);
    }
}
