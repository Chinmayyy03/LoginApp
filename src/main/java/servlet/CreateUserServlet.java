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
        
        // ===== Get logged-in user ID from session (who is creating the new user) =====
        HttpSession session = request.getSession(false);
        String createdBy = (session != null) ? (String) session.getAttribute("userId") : "";
        
        // ===== Read form values =====
        String userId = request.getParameter("userId");
        String userName = request.getParameter("userName");
        String branchCode = request.getParameter("branchCode");
        String custId = request.getParameter("custId");
        String empCode = request.getParameter("empCode");
        String addr1 = request.getParameter("addr1");
        String addr2 = request.getParameter("addr2");
        String addr3 = request.getParameter("addr3");
        String phone = request.getParameter("phone");
        String mobile = request.getParameter("mobile");
        String email = request.getParameter("email");
        boolean success = false;
        // ===== DB insert =====
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(
                "INSERT INTO ACL.USERREGISTER " +
                "(USER_ID, NAME, BRANCH_CODE, CUSTOMER_ID, EMPLOYEE_CODE, " +
                "CURRENTADDRESS1, CURRENTADDRESS2, CURRENTADDRESS3, PHONE_NUMBER, MOBILE_NUMBER, EMAILADDRESS, CREATED_BY) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")) {
            pstmt.setString(1, userId);
            pstmt.setString(2, userName);
            pstmt.setString(3, branchCode);
            pstmt.setString(4, custId);
            pstmt.setString(5, empCode);
            pstmt.setString(6, addr1);
            pstmt.setString(7, addr2);
            pstmt.setString(8, addr3);
            pstmt.setString(9, phone);
            pstmt.setString(10, mobile);
            pstmt.setString(11, email);
            pstmt.setString(12, createdBy);  // Store who created this user
            success = pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        // ===== Send message back to SAME JSP =====
        if (success) {
            request.setAttribute("msg", "✔ User created successfully");
            request.setAttribute("msgType", "success");
        } else {
            request.setAttribute("msg", "✖ User creation failed");
            request.setAttribute("msgType", "error");
        }
       
        request.getRequestDispatcher("/Utility/NewUser.jsp").forward(request, response);
    }
}
