<%@ page import="java.sql.*, db.DBConnection, db.AESEncryption" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String userId     = request.getParameter("username");
    String password   = request.getParameter("password");
    String branchCode = request.getParameter("branch");
    String errorMessage = null;
    boolean showForm  = true;

    if (userId != null && password != null && branchCode != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT USER_ID, PASSWD, CURRENTLOGIN_STATUS FROM ACL.USERREGISTER WHERE USER_ID=? AND BRANCH_CODE=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setString(2, branchCode);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String encryptedPassword  = rs.getString("PASSWD");
                String currentLoginStatus = rs.getString("CURRENTLOGIN_STATUS");
                try {
                    String decryptedPassword = AESEncryption.decrypt(encryptedPassword);
                    if (decryptedPassword.equals(password)) {
                        if ("L".equals(currentLoginStatus)) {
                            errorMessage = "User is already logged in from another session. Please contact administrator.";
                        } else {
                            session.setAttribute("userId",     userId);
                            session.setAttribute("branchCode", branchCode);
                            PreparedStatement historyStmt = null;
                            try {
                                String historySql = "INSERT INTO ACL.USERREGISTERLOGINHISTORY (USER_ID, BRANCH_CODE, LOGIN_TIME) VALUES (?, ?, SYSDATE)";
                                historyStmt = conn.prepareStatement(historySql);
                                historyStmt.setString(1, userId);
                                historyStmt.setString(2, branchCode);
                                historyStmt.executeUpdate();
                            } catch (Exception ignored) {}
                            finally { try { if (historyStmt != null) historyStmt.close(); } catch (Exception e2) {} }
                            PreparedStatement statusStmt = null;
                            try {
                                String statusSql = "UPDATE ACL.USERREGISTER SET CURRENTLOGIN_STATUS = 'L' WHERE USER_ID = ? AND BRANCH_CODE = ?";
                                statusStmt = conn.prepareStatement(statusSql);
                                statusStmt.setString(1, userId);
                                statusStmt.setString(2, branchCode);
                                statusStmt.executeUpdate();
                            } catch (Exception ignored) {}
                            finally { try { if (statusStmt != null) statusStmt.close(); } catch (Exception e2) {} }
                            response.sendRedirect("main.jsp");
                            showForm = false;
                        }
                    } else {
                        errorMessage = "Invalid username or password.";
                    }
                } catch (Exception decryptEx) {
                    errorMessage = "Invalid username or password.";
                }
            } else {
                errorMessage = "Invalid username or password.";
            }
        } catch (Exception e) {
            errorMessage = "Database Error: " + e.getMessage();
        } finally {
            try { if (rs    != null) rs.close();    } catch (Exception ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
            try { if (conn  != null) conn.close();  } catch (Exception ignored) {}
        }
    }
%>

<% if (showForm) { %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>CBS Login</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<style>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

html, body {
    height: 100%;
    font-family: 'Inter', 'Segoe UI', sans-serif;
    background: #ffffff;
    overflow: hidden;
}

/* ── Arc background (Vector.png) — full page like reference ── */
.bg-arc {
    position: fixed;
    right: 0; top: 0;
    width: 100%;
    height: 100%;
    background-image: url('images/Vector.png');
    background-size: cover;
    background-position: center center;
    background-repeat: no-repeat;
    opacity: 0.45;
    pointer-events: none;
    z-index: 0;
}

/* ── IDSSPL logo — top right ── */
.idsspl-corner {
    position: fixed;
    top: 24px; right: 32px;
    display: flex;
    flex-direction: column;
    align-items: center;
    z-index: 10;
}
.idsspl-corner img {
    height: 54px;
    width: auto;
    object-fit: contain;
}
.idsspl-corner-text {
    font-size: 10px;
    color: #1a3a6b;
    font-weight: 600;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    text-align: center;
    margin-top: 4px;
    line-height: 1.5;
}

/* ── Page wrapper ── */
.page-wrapper {
    display: flex;
    height: 100vh;
    width: 100%;
    position: relative;
    z-index: 1;
}

/* ── LEFT side — matches reference: ~38% width, content in upper-center ── */
.left-side {
    flex: 0 0 400px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    padding: 0 48px 80px 64px;
    position: relative;
    z-index: 2;
}

.greeting {
    font-size: 14.5px;
    color: #9aa3b0;
    font-weight: 400;
    margin-bottom: 8px;
    letter-spacing: 0.1px;
}

.bank-name {
    font-size: 28px;
    font-weight: 700;
    color: #1a1a2e;
    margin-bottom: 28px;
    line-height: 1.25;
    letter-spacing: -0.3px;
}

/* underline input style — matches mockup exactly */
.field-row {
    margin-bottom: 28px;
    position: relative;
}

.field-row label {
    display: block;
    font-size: 13.5px;
    font-weight: 400;
    color: #6b7a90;
    margin-bottom: 2px;
    letter-spacing: 0.1px;
}

.field-row input,
.field-row select {
    width: 100%;
    border: none;
    border-bottom: 1.5px solid #c8d0dc;
    border-radius: 0;
    background: transparent;
    font-family: 'Inter', sans-serif;
    font-size: 14px;
    color: #1a1a2e;
    padding: 6px 36px 8px 0;
    outline: none;
    appearance: none; -webkit-appearance: none;
    transition: border-color 0.2s;
}
.field-row input:focus,
.field-row select:focus {
    border-bottom-color: #3563d4;
}
.field-row input::placeholder { color: transparent; }

/* right-side icon for inputs */
.f-icon {
    position: absolute;
    right: 2px; bottom: 8px;
    width: 19px; height: 19px;
    opacity: 0.38; pointer-events: none;
}

/* select arrow */
.field-row select {
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6'%3E%3Cpath d='M0 0l5 6 5-6z' fill='%23aab4c0'/%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 4px center;
}

/* eye icon (password) */
.eye-btn {
    position: absolute;
    right: 2px; bottom: 8px;
    width: 19px; height: 19px;
    cursor: pointer; opacity: 0.38;
    transition: opacity 0.2s;
}
.eye-btn:hover { opacity: 0.75; }

/* forgot row — right-aligned, sits right after password underline */
.forgot-row {
    text-align: right;
    margin-top: -18px;
    margin-bottom: 28px;
}
.forgot-row a {
    font-size: 12.5px; color: #6b7a90;
    text-decoration: none; font-weight: 400;
}
.forgot-row a:hover { color: #3563d4; text-decoration: underline; }

/* login button — matches reference: rounded, full-width, blue */
.btn-login {
    width: 100%; height: 50px;
    background: #4361d8;
    color: #fff;
    font-family: 'Inter', sans-serif;
    font-size: 16px; font-weight: 600;
    border: none; border-radius: 10px;
    cursor: pointer; letter-spacing: 0.5px;
    box-shadow: 0 4px 16px rgba(67,97,216,0.35);
    transition: background 0.2s, box-shadow 0.2s, transform 0.12s;
}
.btn-login:hover  { background: #3451c4; transform: translateY(-1px); box-shadow: 0 6px 20px rgba(67,97,216,0.45); }
.btn-login:active { transform: translateY(0); }

/* alert */
.alert {
    margin-top: 13px; padding: 10px 13px;
    border-radius: 7px; font-size: 13px;
    font-weight: 500; line-height: 1.5;
    display: flex; align-items: flex-start; gap: 8px;
}
.alert-error   { background: #FEF2F2; border: 1px solid #FECACA; color: #991B1B; }
.alert-warning { background: #FFF7ED; border: 1px solid #FED7AA; color: #C2410C; }
.alert svg { width: 15px; height: 15px; fill: currentColor; flex-shrink: 0; margin-top: 1px; }

/* sign up row — matches reference */
.signup-row {
    text-align: center;
    font-size: 13px; color: #9aa3b0;
    margin-top: 16px;
    font-weight: 400;
}
.signup-row a { color: #4361d8; font-weight: 700; text-decoration: none; }
.signup-row a:hover { text-decoration: underline; }

/* ── RIGHT side — illustration, matches reference positioning ── */
.right-side {
    flex: 1;
    position: relative; z-index: 2;
    display: flex; align-items: center; justify-content: center;
    padding: 60px 60px 100px 0;
}

.banking-img {
    max-width: 560px; width: 92%; height: auto;
    animation: floatImg 4s ease-in-out infinite;
    filter: drop-shadow(0 8px 24px rgba(53,99,212,0.10));
}

@keyframes floatImg {
    0%, 100% { transform: translateY(0); }
    50%       { transform: translateY(-10px); }
}

/* ── Footer — matches reference: single centered line with pipes ── */
.page-footer {
    position: fixed; bottom: 0; left: 0; right: 0;
    text-align: center;
    font-size: 12.5px; color: #8a96a8;
    padding: 13px 20px;
    display: flex; align-items: center; justify-content: center;
    gap: 0;
    z-index: 5;
    background: rgba(255,255,255,0.92);
    backdrop-filter: blur(4px);
    border-top: 1px solid rgba(0,0,0,0.06);
    letter-spacing: 0.1px;
}
.footer-sep {
    margin: 0 14px;
    color: #ccd0d8;
    font-weight: 300;
}
.footer-icon {
    display: inline-flex; align-items: center; gap: 5px;
}

/* ── Responsive ── */
/* Tablet */
@media (max-width: 1100px) and (min-width: 769px) {
    .left-side { flex: 0 0 360px; padding: 0 36px 80px 40px; }
    .banking-img { max-width: 420px; }
}

/* Mobile */
@media (max-width: 768px) {
    .page-wrapper { flex-direction: column; height: auto; min-height: 100vh; overflow: auto; }
    .bg-arc { opacity: 0.25; }
    .left-side { flex: none; width: 100%; padding: 100px 28px 40px; }
    .right-side { flex: none; width: 100%; padding: 20px 28px 100px; justify-content: center; }
    .banking-img { max-width: 320px; }
    .idsspl-corner { top: 16px; right: 16px; }
    .idsspl-corner img { height: 40px; }
    html, body { overflow: auto; }
}

input[type="password"]::-ms-reveal,
input[type="password"]::-ms-clear { display: none; }
input[type="password"]::-webkit-credentials-auto-fill-button,
input[type="password"]::-webkit-password-toggle-button { display: none !important; }
</style>
</head>
<body>

<!-- Arc pattern background -->
<div class="bg-arc"></div>

<!-- IDSSPL logo top-right -->
<div class="idsspl-corner">
    <img src="images/IDSSPL LOGO.jpeg" alt="IDSSPL Logo">
    <div class="idsspl-corner-text">IDSSPL<br>Info Dynamic<br>software system</div>
</div>

<div class="page-wrapper">

    <!-- LEFT — form -->
    <div class="left-side">

        <div class="greeting">Back Again !</div>

        <div class="bank-name">
            <%
                String loginBankName = "Demo Bank/Society Ltd.";
                try (Connection connBank = DBConnection.getConnection();
                     PreparedStatement psBank = connBank.prepareStatement(
                         "SELECT NAME FROM GLOBALCONFIG.BANK WHERE BANK_CODE = ?")) {
                    psBank.setString(1, "0100");
                    ResultSet rsBank = psBank.executeQuery();
                    if (rsBank.next()) loginBankName = rsBank.getString("NAME");
                } catch (Exception ignored) {}
            %>
            <%= loginBankName %>
        </div>

        <form action="login.jsp" method="post" autocomplete="off">

            <!-- Branch -->
            <div class="field-row">
                <label for="branch">Branch</label>
                <select id="branch" name="branch" required>
                    <option value="">— Select Branch —</option>
                    <%
                        try (Connection connBr = DBConnection.getConnection();
                             Statement stmtBr  = connBr.createStatement();
                             ResultSet rsBr    = stmtBr.executeQuery(
                                 "SELECT BRANCH_CODE, NAME FROM HEADOFFICE.BRANCH ORDER BY BRANCH_CODE")) {
                            while (rsBr.next()) {
                                String bc = rsBr.getString("BRANCH_CODE");
                                String bn = rsBr.getString("NAME");
                    %>
                        <option value="<%= bc %>"><%= bc %> — <%= bn %></option>
                    <%
                            }
                        } catch (Exception ex) {
                            out.println("<option>Error loading branches</option>");
                        }
                    %>
                </select>
            </div>

            <!-- User Name -->
            <div class="field-row">
                <label for="username">User Name</label>
                <input type="text" id="username" name="username" placeholder="" required>
                <img src="images/user.png" class="f-icon" alt="">
            </div>

            <!-- Password -->
            <div class="field-row">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="" required>
                <img src="images/password_lock.png" id="lockIcon" class="f-icon" alt="">
                <img src="images/eye.png" id="eyeIcon" class="eye-btn" alt="show/hide" style="display:none;">
            </div>

            <!-- Forgot -->
            <div class="forgot-row"><a href="#">Forgot Password?</a></div>

            <!-- Submit -->
            <button type="submit" class="btn-login">Login</button>

            <!-- Error messages -->
            <% if (errorMessage != null) { %>
                <% if (errorMessage.contains("already logged in")) { %>
                    <div class="alert alert-warning">
                        <svg viewBox="0 0 20 20"><path d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"/></svg>
                        <%= errorMessage %>
                    </div>
                <% } else { %>
                    <div class="alert alert-error">
                        <svg viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/></svg>
                        <%= errorMessage %>
                    </div>
                <% } %>
            <% } %>

            <div class="signup-row">Don't have account? <a href="#">Sign up</a></div>

        </form>
    </div>

    <!-- RIGHT — banking illustration -->
    <div class="right-side">
        <img src="images/online_banking.png"
             alt="Online Banking" class="banking-img">
    </div>

</div>

<!-- Footer — matches reference: address | phone | email in one line -->
<div class="page-footer">
    <span class="footer-icon">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#8a96a8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s-8-4.5-8-11.8A8 8 0 0 1 12 2a8 8 0 0 1 8 8.2c0 7.3-8 11.8-8 11.8z"/><circle cx="12" cy="10" r="3"/></svg>
        11, "Gurukrupa" Friends &nbsp;Coloney Kolhapur 416005
    </span>
    <span class="footer-sep">|</span>
    <span class="footer-icon">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#8a96a8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.62 12 19.79 19.79 0 0 1 1.55 3.41 2 2 0 0 1 3.53 1h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.56a16 16 0 0 0 6.06 6.06l.81-.81a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
        +91 2312530950
    </span>
    <span class="footer-sep">|</span>
    <span class="footer-icon">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#8a96a8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
        www.infolop@idsspl.com
    </span>
</div>

<script>
var passwordInput = document.getElementById("password");
var eyeIcon       = document.getElementById("eyeIcon");
var lockIcon      = document.getElementById("lockIcon");

passwordInput.addEventListener("input", function () {
    var hasValue = passwordInput.value.length > 0;
    lockIcon.style.display = hasValue ? "none"  : "block";
    eyeIcon.style.display  = hasValue ? "block" : "none";
});

eyeIcon.addEventListener("click", function () {
    if (passwordInput.type === "password") {
        passwordInput.type = "text";
        eyeIcon.src = "images/eye-hide.png";
    } else {
        passwordInput.type = "password";
        eyeIcon.src = "images/eye.png";
    }
});
</script>

</body>
</html>
<% } %>
