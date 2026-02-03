<%@ page import="java.sql.*, db.DBConnection" %> 
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Disable caching
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String userId = request.getParameter("username");
    String password = request.getParameter("password");
    String branchCode = request.getParameter("branch");
    String errorMessage = null;
    boolean showForm = true;

    if (userId != null && password != null && branchCode != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT USER_ID FROM ACL.USERREGISTER WHERE USER_ID=? AND acl.toolkit.decrypt(PASSWD)=? AND BRANCH_CODE=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setString(2, password);
            pstmt.setString(3, branchCode);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                session.setAttribute("userId", userId);
                session.setAttribute("branchCode", branchCode);
                response.sendRedirect("main.jsp");
                showForm = false;
            } else {
                errorMessage = "Invalid username or password";
            }
        } catch (Exception e) {
            errorMessage = "Database Error: " + e.getMessage();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
%>

<% if (showForm) { %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Bank CBS - Secure Login</title>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
<link rel="stylesheet" href="css/login.css">
<style>
.error-message {
    color: red;
    font-weight: bold;
    margin-top: 10px;
    text-align: center;
}
</style>
</head>
<body>

<div class="login-container">

    <!-- 🔹 Logo and Titles -->
    <div class="bank-brand">
        <img src="images/idsspl_logo.gif" alt="Bank Logo" class="bank-logo">
        <div class="brand-title">MERCHANTS LIBERAL CO-OP BANK LTD, GADAG</div>
        <div class="brand-sub">Core Banking System - Secure Access</div>
    </div>

    <!-- 🔹 Main form layout (Image + Form) -->
    <form action="login.jsp" method="post" autocomplete="off">

        <!-- Left Side: Image -->
        <div style="flex:1.4; display:flex; justify-content:center; align-items:center;">

            <img src="images/image.gif" alt="Bank System Illustration">
        </div>

        <!-- Right Side: Form Fields -->
        <div style="flex:1; min-width:280px; text-align:left;">

            <select id="branch" name="branch" class="form-control" required>
                <option value="">-- Select Branch --</option>
                <%
                    try (Connection conn = DBConnection.getConnection();
                         Statement stmt = conn.createStatement();
                         ResultSet branchRS = stmt.executeQuery("SELECT BRANCH_CODE, NAME FROM HEADOFFICE.BRANCH ORDER BY BRANCH_CODE")) {

                        while(branchRS.next()) {
                            String bCode = branchRS.getString("BRANCH_CODE");
                            String bName = branchRS.getString("NAME");
                %>
                            <option value="<%=bCode%>"><%=bCode%> - <%=bName%></option>
                <%
                        }
                    } catch(Exception ex) {
                        out.println("<option>Error loading branches</option>");
                    }
                %>
            </select>

            <input type="text" placeholder="Enter User ID" id="username" name="username" class="form-control" required>
            
            <div class="password-container">
    			<input type="password" placeholder="Enter Password" id="password" name="password" class="form-control" required>
    				<img src="images/eye.png" id="eyeIcon" class="eye-icon" alt="Show" onclick="togglePassword()">
			</div>


            <button type="submit" class="btn-login">Login</button>

            <% if (errorMessage != null) { %>
                <div class="error-message"><%= errorMessage %></div>
            <% } %>

            <div class="help-row">
                <a href="#">Forgot Password?</a>
            </div>

        </div>
    </form>

    <!-- Footer -->
    <div class="login-footer">
        © 2025 Merchants Liberal Co-op Bank Ltd. All rights reserved.
    </div>

</div>


<!-- script code for eye icon in password field -->
<script>
const password = document.getElementById("password");
const eyeIcon = document.getElementById("eyeIcon");

// Hide icon initially
eyeIcon.style.display = "none";

// Show/Hide password on click
function togglePassword() {
    if (password.type === "password") {
        password.type = "text";
        eyeIcon.src = "images/eye-hide.png"; // 👁 closed-eye image
    } else {
        password.type = "password";
        eyeIcon.src = "images/eye.png"; // 👁 open-eye image
    }
}

// Detect typing and show/hide icon
password.addEventListener("input", function () {
    if (password.value.length > 0) {
        eyeIcon.style.display = "block";
    } else {
        eyeIcon.style.display = "none";
    }
});
</script>

</body>
</html>
<% } %> 




