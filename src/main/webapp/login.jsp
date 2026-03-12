<%@ page import="java.sql.*, db.DBConnection, db.AESEncryption" %> 
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
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
            String sql = "SELECT USER_ID, PASSWD, CURRENTLOGIN_STATUS FROM ACL.USERREGISTER WHERE USER_ID=? AND BRANCH_CODE=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setString(2, branchCode);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String encryptedPassword = rs.getString("PASSWD");
                String currentLoginStatus = rs.getString("CURRENTLOGIN_STATUS");
                try {
                    String decryptedPassword = AESEncryption.decrypt(encryptedPassword);
                    if (decryptedPassword.equals(password)) {
                        if ("L".equals(currentLoginStatus)) {
                            errorMessage = "User is already logged in from another machine/session. Please logout from the other session first or contact administrator.";
                        } else {
                            session.setAttribute("userId", userId);
                            session.setAttribute("branchCode", branchCode);
                            PreparedStatement historyStmt = null;
                            try {
                                String historySql = "INSERT INTO ACL.USERREGISTERLOGINHISTORY (USER_ID, BRANCH_CODE, LOGIN_TIME) VALUES (?, ?, SYSDATE)";
                                historyStmt = conn.prepareStatement(historySql);
                                historyStmt.setString(1, userId);
                                historyStmt.setString(2, branchCode);
                                historyStmt.executeUpdate();
                            } catch (Exception historyEx) {
                                System.err.println("Error inserting login history: " + historyEx.getMessage());
                            } finally {
                                try { if (historyStmt != null) historyStmt.close(); } catch (Exception ignored) {}
                            }
                            PreparedStatement statusStmt = null;
                            try {
                                String statusSql = "UPDATE ACL.USERREGISTER SET CURRENTLOGIN_STATUS = 'L' WHERE USER_ID = ? AND BRANCH_CODE = ?";
                                statusStmt = conn.prepareStatement(statusSql);
                                statusStmt.setString(1, userId);
                                statusStmt.setString(2, branchCode);
                                statusStmt.executeUpdate();
                            } catch (Exception statusEx) {
                                System.err.println("Error updating login status: " + statusEx.getMessage());
                            } finally {
                                try { if (statusStmt != null) statusStmt.close(); } catch (Exception ignored) {}
                            }
                            response.sendRedirect("main.jsp");
                            showForm = false;
                        }
                    } else {
                        errorMessage = "Invalid username or password";
                    }
                } catch (Exception decryptEx) {
                    errorMessage = "Invalid username or password";
                }
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
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
<style>
/* ─── Reset & Base ─────────────────────────────────────── */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
    --navy:      #0B1437;
    --blue:      #1B4FE4;
    --blue-mid:  #2563EB;
    --blue-light:#3B76F7;
    --indigo:    #4458DC;
    --sky:       #EEF3FF;
    --gray-50:   #F8FAFF;
    --gray-100:  #F1F5FD;
    --gray-300:  #CBD5E1;
    --gray-500:  #64748B;
    --gray-700:  #334155;
    --white:     #FFFFFF;
    --danger:    #EF4444;
    --warn-bg:   #FFF7ED;
    --warn-border:#F97316;
    --warn-text: #C2410C;
    --radius:    12px;
    --shadow-card: 0 20px 60px rgba(11,20,55,0.15), 0 4px 16px rgba(11,20,55,0.08);
}

html, body {
    height: 100%;
    font-family: 'DM Sans', sans-serif;
    background: var(--navy);
    overflow: hidden;
}

body::before {
    content: '';
    position: fixed; inset: 0;
    background:
        radial-gradient(ellipse 80% 60% at 20% 10%, rgba(27,79,228,0.35) 0%, transparent 60%),
        radial-gradient(ellipse 60% 50% at 80% 90%, rgba(68,88,220,0.25) 0%, transparent 55%),
        radial-gradient(ellipse 40% 40% at 70% 20%, rgba(59,118,247,0.15) 0%, transparent 50%);
    pointer-events: none; z-index: 0;
}

body::after {
    content: '';
    position: fixed; inset: 0;
    background-image: radial-gradient(rgba(255,255,255,0.07) 1px, transparent 1px);
    background-size: 28px 28px;
    pointer-events: none; z-index: 0;
}

.page-wrapper {
    position: relative; z-index: 1;
    display: flex; height: 100vh; width: 100%; overflow: hidden;
}

/* ══════════════════════════════════════════════════════
   LEFT PANEL — redesigned, no gif
══════════════════════════════════════════════════════ */
.left-panel {
    flex: 1.1;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    padding: 40px 44px;
    position: relative;
    overflow: hidden;
    animation: slideInLeft 0.7s ease both;
}

/* ── Hero scene ── */
.hero-scene {
    width: 100%;
    max-width: 460px;
    position: relative;
    display: flex;
    flex-direction: column;
    align-items: center;
}

/* ── IDSSPL logo ── */
.idsspl-title-block {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-bottom: 26px;
    animation: fadeUp 0.9s 0.15s ease both;
}

.idsspl-logo-img {
    height: 54px;
    width: auto;
    opacity: 0.95;
    margin-bottom: 6px;
    filter: drop-shadow(0 2px 12px rgba(255,255,255,0.15));
}

.idsspl-tagline {
    font-size: 10.5px;
    letter-spacing: 3px;
    text-transform: uppercase;
    color: rgba(255,255,255,0.4);
    font-weight: 500;
}

/* ── 3-D bank card ── */
.card-scene {
    width: 100%;
    perspective: 900px;
    margin-bottom: 28px;
    animation: fadeUp 0.9s 0.3s ease both;
}

.card-3d {
    width: 320px;
    height: 195px;
    margin: 0 auto;
    border-radius: 20px;
    background: linear-gradient(135deg,
        rgba(255,255,255,0.18) 0%,
        rgba(255,255,255,0.06) 50%,
        rgba(59,118,247,0.28) 100%);
    border: 1px solid rgba(255,255,255,0.22);
    backdrop-filter: blur(20px);
    box-shadow:
        0 32px 64px rgba(0,0,0,0.5),
        0 8px 24px rgba(0,0,0,0.3),
        inset 0 1px 0 rgba(255,255,255,0.25);
    position: relative;
    overflow: hidden;
    transform: rotateX(8deg) rotateY(-8deg);
    transition: transform 0.6s ease;
    animation: cardFloat 6s ease-in-out infinite;
    cursor: default;
}

/* shine sweep */
.card-3d::before {
    content: '';
    position: absolute; inset: 0;
    background: linear-gradient(105deg,
        transparent 30%, rgba(255,255,255,0.12) 50%, transparent 70%);
    background-size: 200% 100%;
    animation: cardShine 4s ease-in-out infinite;
    border-radius: 20px;
}

/* subtle grid */
.card-3d::after {
    content: '';
    position: absolute; inset: 0;
    background-image:
        linear-gradient(rgba(255,255,255,0.05) 1px, transparent 1px),
        linear-gradient(90deg, rgba(255,255,255,0.05) 1px, transparent 1px);
    background-size: 28px 28px;
    border-radius: 20px;
}

.card-inner {
    position: relative; z-index: 2;
    padding: 22px 26px;
    height: 100%;
    display: flex; flex-direction: column; justify-content: space-between;
}

.card-row-top {
    display: flex; justify-content: space-between; align-items: flex-start;
}

.card-bank-name {
    font-size: 10px; font-weight: 700;
    letter-spacing: 2.5px; text-transform: uppercase;
    color: rgba(255,255,255,0.88);
}

.card-chip {
    width: 38px; height: 28px;
    background: linear-gradient(135deg, #f0c040, #c9910e);
    border-radius: 5px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.4);
    position: relative; overflow: hidden;
}
.card-chip::before {
    content: '';
    position: absolute; top: 50%; left: 50%;
    width: 68%; height: 68%;
    transform: translate(-50%,-50%);
    border: 1.5px solid rgba(0,0,0,0.18);
    border-radius: 3px;
}
.card-chip::after {
    content: '';
    position: absolute; top: 50%; left: 0; right: 0;
    height: 1.5px; background: rgba(0,0,0,0.15);
    transform: translateY(-50%);
}

.card-number {
    display: flex; gap: 12px; align-items: center;
}

.card-number-group {
    font-size: 14px; font-family: 'DM Sans', monospace;
    font-weight: 600; letter-spacing: 3px;
    color: rgba(255,255,255,0.88);
}

.card-number-group.hidden {
    letter-spacing: 5px; font-size: 12px;
    color: rgba(255,255,255,0.55);
}

.card-row-bottom {
    display: flex; justify-content: space-between; align-items: flex-end;
}

.card-label-small {
    font-size: 8.5px; letter-spacing: 1.5px;
    text-transform: uppercase; color: rgba(255,255,255,0.4);
    margin-bottom: 3px;
}

.card-value {
    font-size: 12px; font-weight: 600;
    letter-spacing: 1px; color: rgba(255,255,255,0.9);
}

.card-network { display: flex; align-items: center; }

.card-ring {
    width: 26px; height: 26px; border-radius: 50%; opacity: 0.8;
}
.card-ring:first-child { background: rgba(240,80,80,0.75); margin-right: -9px; position: relative; z-index: 1; }
.card-ring:last-child  { background: rgba(255,180,30,0.75); }

/* ── Stats row ── */
.stats-row {
    display: flex; gap: 12px; width: 100%;
    animation: fadeUp 0.9s 0.5s ease both;
}

.stat-pill {
    flex: 1;
    background: rgba(255,255,255,0.07);
    border: 1px solid rgba(255,255,255,0.11);
    border-radius: 14px;
    padding: 13px 14px;
    backdrop-filter: blur(10px);
    position: relative; overflow: hidden;
    transition: background 0.3s, transform 0.3s;
}

.stat-pill:hover {
    background: rgba(255,255,255,0.13);
    transform: translateY(-3px);
}

.stat-pill::before {
    content: '';
    position: absolute; top: 0; left: 0; right: 0;
    height: 2px; border-radius: 14px 14px 0 0;
}
.stat-pill.green::before  { background: linear-gradient(90deg,#4ADE80,#22D3EE); }
.stat-pill.blue::before   { background: linear-gradient(90deg,#60A5FA,#818CF8); }
.stat-pill.yellow::before { background: linear-gradient(90deg,#FBBF24,#F59E0B); }

.stat-icon  { font-size: 17px; margin-bottom: 5px; display: block; }
.stat-value { font-size: 15px; font-weight: 700; color: #fff; line-height: 1; margin-bottom: 3px; }
.stat-label { font-size: 9.5px; letter-spacing: 0.7px; text-transform: uppercase; color: rgba(255,255,255,0.43); }

/* ── Ticker ── */
.activity-ticker {
    width: 100%;
    background: rgba(255,255,255,0.05);
    border: 1px solid rgba(255,255,255,0.09);
    border-radius: 10px;
    padding: 9px 14px;
    margin-top: 12px;
    display: flex; align-items: center; gap: 10px;
    animation: fadeUp 0.9s 0.65s ease both;
    overflow: hidden;
}

.ticker-dot {
    width: 7px; height: 7px; border-radius: 50%;
    background: #4ADE80; box-shadow: 0 0 8px #4ADE80;
    flex-shrink: 0;
    animation: tickerPulse 2s ease-in-out infinite;
}

.ticker-text {
    font-size: 11.5px; color: rgba(255,255,255,0.55);
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    transition: opacity 0.4s, transform 0.4s;
}

.ticker-text span { color: rgba(255,255,255,0.88); font-weight: 600; }

/* ── Brand block ── */
.brand-block-left {
    text-align: center; margin-top: 26px;
    animation: fadeUp 0.9s 0.8s ease both;
}

.brand-title-left {
    font-family: 'Playfair Display', serif;
    font-size: 21px; color: #fff;
    letter-spacing: 0.5px;
    text-shadow: 0 2px 12px rgba(0,0,0,0.3);
    margin-bottom: 4px;
}

.brand-sub-left {
    font-size: 10.5px; letter-spacing: 1.8px;
    text-transform: uppercase; color: rgba(255,255,255,0.42);
}

/* ── Particles ── */
.particles-wrap { position: absolute; inset: 0; pointer-events: none; overflow: hidden; }

.particle {
    position: absolute; border-radius: 50%;
    opacity: 0; animation: particleFloat linear infinite;
}

/* ══════════════════════════════════════════════════════
   RIGHT PANEL — login card (unchanged from original)
══════════════════════════════════════════════════════ */
.right-panel {
    display: flex; align-items: center; justify-content: center;
    padding: 32px 40px;
    animation: slideInRight 0.7s ease both;
}

.login-card {
    background: var(--white); border-radius: 20px;
    box-shadow: var(--shadow-card);
    width: 420px; padding: 44px 40px 36px;
    position: relative; overflow: hidden;
}

.login-card::before {
    content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px;
    background: linear-gradient(90deg, var(--blue), var(--indigo), var(--blue-light));
}

.card-header { margin-bottom: 28px; }
.card-header h2 { font-size: 22px; font-weight: 700; color: var(--navy); margin-bottom: 4px; }
.card-header p  { font-size: 13.5px; color: var(--gray-500); }

.field-group { margin-bottom: 16px; }

.field-group label {
    display: block; font-size: 12.5px; font-weight: 600;
    color: var(--gray-700); margin-bottom: 6px; letter-spacing: 0.2px;
}

.field-wrap { position: relative; }

.field-wrap .field-icon {
    position: absolute; left: 13px; top: 50%; transform: translateY(-50%);
    width: 17px; height: 17px; opacity: 0.45; pointer-events: none;
}

.field-wrap select,
.field-wrap input[type="text"],
.field-wrap input[type="password"] {
    width: 100%; height: 44px; padding: 0 42px 0 40px;
    border: 1.5px solid var(--gray-300); border-radius: 9px;
    font-family: 'DM Sans', sans-serif; font-size: 14px; color: var(--navy);
    background: var(--gray-50); transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
    outline: none; appearance: none; -webkit-appearance: none;
}

.field-wrap select {
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%2364748B' stroke-width='1.5' fill='none' stroke-linecap='round'/%3E%3C/svg%3E");
    background-repeat: no-repeat; background-position: right 14px center;
}

.field-wrap select:focus,
.field-wrap input:focus {
    border-color: var(--blue); background: var(--white);
    box-shadow: 0 0 0 3px rgba(27,79,228,0.1);
}

.eye-toggle {
    position: absolute; right: 13px; top: 50%; transform: translateY(-50%);
    width: 20px; height: 20px; cursor: pointer; opacity: 0.45;
    transition: opacity 0.2s; display: none;
}
.eye-toggle:hover { opacity: 0.75; }

.captcha-row { display: flex; gap: 10px; align-items: stretch; margin-bottom: 16px; }

.captcha-image-box {
    flex: 1; min-height: 44px;
    background: linear-gradient(135deg, #e8edf8, #dce4f5);
    border: 1.5px solid var(--gray-300); border-radius: 9px;
    display: flex; align-items: center; justify-content: center;
    overflow: hidden; position: relative;
}

.captcha-placeholder {
    font-family: 'DM Sans', sans-serif; font-size: 22px; font-weight: 700;
    letter-spacing: 6px; color: var(--navy); opacity: 0.55;
    user-select: none; text-decoration: line-through; text-decoration-style: dotted;
}

.captcha-refresh-btn {
    width: 44px; height: 44px; background: var(--sky);
    border: 1.5px solid var(--gray-300); border-radius: 9px;
    display: flex; align-items: center; justify-content: center;
    cursor: pointer; transition: background 0.2s, border-color 0.2s, transform 0.3s; flex-shrink: 0;
}
.captcha-refresh-btn:hover { background: #dce8ff; border-color: var(--blue); transform: rotate(180deg); }
.captcha-refresh-btn svg { width: 18px; height: 18px; stroke: var(--blue); fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

.btn-login {
    width: 100%; height: 46px;
    background: linear-gradient(135deg, var(--blue) 0%, var(--indigo) 100%);
    color: #fff; font-family: 'DM Sans', sans-serif; font-size: 15px;
    font-weight: 600; border: none; border-radius: 9px; cursor: pointer;
    letter-spacing: 0.3px;
    transition: opacity 0.2s, transform 0.15s, box-shadow 0.2s;
    box-shadow: 0 4px 16px rgba(27,79,228,0.35); margin-top: 4px;
}
.btn-login:hover  { opacity: 0.92; transform: translateY(-1px); box-shadow: 0 6px 22px rgba(27,79,228,0.45); }
.btn-login:active { transform: translateY(0); box-shadow: 0 2px 8px rgba(27,79,228,0.3); }

.alert {
    display: flex; align-items: flex-start; gap: 10px;
    border-radius: 9px; padding: 11px 14px; font-size: 13px;
    font-weight: 500; margin-top: 14px; line-height: 1.45;
}
.alert-error   { background: #FEF2F2; border: 1px solid #FECACA; color: #991B1B; }
.alert-warning { background: var(--warn-bg); border: 1px solid #FED7AA; color: var(--warn-text); }
.alert svg { width: 16px; height: 16px; flex-shrink: 0; margin-top: 1px; fill: currentColor; }

.help-row { display: flex; justify-content: flex-end; margin-top: 14px; }
.help-row a { font-size: 12.5px; color: var(--blue); text-decoration: none; font-weight: 500; }
.help-row a:hover { text-decoration: underline; }

.card-footer-note {
    text-align: center; font-size: 11.5px; color: var(--gray-500);
    margin-top: 22px; padding-top: 18px; border-top: 1px solid var(--gray-100);
    display: flex; align-items: center; justify-content: center; gap: 6px;
}
.card-footer-note svg { width: 13px; height: 13px; stroke: var(--gray-500); fill: none; stroke-width: 2; flex-shrink: 0; }

.page-footer {
    position: fixed; bottom: 0; left: 0; right: 0;
    text-align: center; font-size: 12px; color: rgba(255,255,255,0.3);
    padding: 12px; z-index: 2;
}

/* ── Keyframes ── */
@keyframes slideInLeft  { from { opacity:0; transform:translateX(-30px); } to { opacity:1; transform:translateX(0); } }
@keyframes slideInRight { from { opacity:0; transform:translateX(30px);  } to { opacity:1; transform:translateX(0); } }

@keyframes fadeUp {
    from { opacity:0; transform:translateY(18px); }
    to   { opacity:1; transform:translateY(0); }
}

@keyframes cardFloat {
    0%,100% { transform: rotateX(8deg)  rotateY(-8deg)  translateY(0px);  }
    33%      { transform: rotateX(5deg)  rotateY(-4deg)  translateY(-8px); }
    66%      { transform: rotateX(10deg) rotateY(-12deg) translateY(-4px); }
}

@keyframes cardShine {
    0%  { background-position: -200% 0; }
    60% { background-position:  200% 0; }
    100%{ background-position:  200% 0; }
}

@keyframes tickerPulse {
    0%,100% { box-shadow:0 0 8px #4ADE80; transform:scale(1); }
    50%      { box-shadow:0 0 14px #4ADE80; transform:scale(1.15); }
}

@keyframes particleFloat {
    0%   { opacity:0; transform:translateY(0)   scale(0.5); }
    10%  { opacity:0.55; }
    90%  { opacity:0.25; }
    100% { opacity:0; transform:translateY(-110px) scale(1.2); }
}

/* ── Responsive ── */
@media (max-width: 900px) {
    .left-panel { display:none; }
    .right-panel { flex:1; padding:20px; }
    .login-card { width:100%; max-width:420px; }
    html,body { overflow:auto; }
    .page-wrapper { height:auto; min-height:100vh; }
}

input[type="password"]::-ms-reveal,
input[type="password"]::-ms-clear { display:none; }
input[type="password"]::-webkit-credentials-auto-fill-button,
input[type="password"]::-webkit-password-toggle-button { display:none !important; }
</style>
</head>
<body>

<div class="page-wrapper">

    <!-- ══════════════════════════════════════
         LEFT PANEL — modern coded design
    ══════════════════════════════════════ -->
    <div class="left-panel">

        <!-- floating particles -->
        <div class="particles-wrap" id="particlesWrap"></div>

        <div class="hero-scene">

            <!-- IDSSPL logo provided as image -->
            <div class="idsspl-title-block">
                <img src="images/idsspl_logo.gif" alt="IDSSPL" class="idsspl-logo-img">
                <span class="idsspl-tagline">Info Dynamic Software Systems Pvt Ltd</span>
            </div>

            <!-- Animated 3-D bank card -->
            <div class="card-scene">
                <div class="card-3d" id="bankCard">
                    <div class="card-inner">
                        <div class="card-row-top">
                            <div class="card-bank-name" id="cardBankLabel">CBS BANK</div>
                            <div class="card-chip"></div>
                        </div>
                        <div class="card-number">
                            <span class="card-number-group hidden">••••</span>
                            <span class="card-number-group hidden">••••</span>
                            <span class="card-number-group hidden">••••</span>
                            <span class="card-number-group">4823</span>
                        </div>
                        <div class="card-row-bottom">
                            <div>
                                <div class="card-label-small">Card Holder</div>
                                <div class="card-value">ACCOUNT HOLDER</div>
                            </div>
                            <div>
                                <div class="card-label-small">Expires</div>
                                <div class="card-value">12/29</div>
                            </div>
                            <div class="card-network">
                                <div class="card-ring"></div>
                                <div class="card-ring"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Stats pills -->
            <div class="stats-row">
                <div class="stat-pill green">
                    <span class="stat-icon">🔒</span>
                    <div class="stat-value">256-bit</div>
                    <div class="stat-label">SSL Encrypted</div>
                </div>
                <div class="stat-pill blue">
                    <span class="stat-icon">⚡</span>
                    <div class="stat-value">99.9%</div>
                    <div class="stat-label">Uptime SLA</div>
                </div>
                <div class="stat-pill yellow">
                    <span class="stat-icon">🏦</span>
                    <div class="stat-value">v3.1</div>
                    <div class="stat-label">CBS Platform</div>
                </div>
            </div>

            <!-- Live activity ticker -->
            <div class="activity-ticker">
                <div class="ticker-dot"></div>
                <div class="ticker-text" id="tickerText">
                    <span>System Online</span> — All banking services operational
                </div>
            </div>

            <!-- Bank name (from DB) -->
            <div class="brand-block-left">
                <%
                    String loginBankName = "CBS BANK";
                    try (Connection connBank = DBConnection.getConnection();
                         PreparedStatement psLoginBank = connBank.prepareStatement(
                             "SELECT NAME FROM GLOBALCONFIG.BANK WHERE BANK_CODE = ?")) {
                        psLoginBank.setString(1, "0100");
                        ResultSet rsLoginBank = psLoginBank.executeQuery();
                        if (rsLoginBank.next()) loginBankName = rsLoginBank.getString("NAME");
                    } catch (Exception ignored) {}
                %>
                <div class="brand-title-left"><%= loginBankName.toUpperCase() %></div>
                <div class="brand-sub-left">Core Banking System &nbsp;·&nbsp; Secure Access Portal</div>
            </div>

        </div>
    </div>
    <!-- end left panel -->

    <!-- ══════════════════════════════════════
         RIGHT PANEL — Login Card (unchanged)
    ══════════════════════════════════════ -->
    <div class="right-panel">
        <div class="login-card">

            <div class="card-header">
                <h2>Welcome Back</h2>
                <p>Sign in to your CBS account to continue</p>
            </div>

            <form action="login.jsp" method="post" autocomplete="off">

                <!-- Branch -->
                <div class="field-group">
                    <label for="branch">Branch</label>
                    <div class="field-wrap">
                        <svg class="field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M3 21h18M3 10h18M5 6l7-3 7 3M4 10v11M20 10v11M8 10v11M12 10v11M16 10v11"/>
                        </svg>
                        <select id="branch" name="branch" required>
                            <option value="">— Select Branch —</option>
                            <%
                                try (Connection conn = DBConnection.getConnection();
                                     Statement stmt = conn.createStatement();
                                     ResultSet branchRS = stmt.executeQuery("SELECT BRANCH_CODE, NAME FROM HEADOFFICE.BRANCH ORDER BY BRANCH_CODE")) {
                                    while(branchRS.next()) {
                                        String bCode = branchRS.getString("BRANCH_CODE");
                                        String bName = branchRS.getString("NAME");
                            %>
                                        <option value="<%=bCode%>"><%=bCode%> — <%=bName%></option>
                            <%
                                    }
                                } catch(Exception ex) {
                                    out.println("<option>Error loading branches</option>");
                                }
                            %>
                        </select>
                    </div>
                </div>

                <!-- User ID -->
                <div class="field-group">
                    <label for="username">User ID</label>
                    <div class="field-wrap">
                        <svg class="field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="12" cy="8" r="4"/>
                            <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/>
                        </svg>
                        <input type="text" placeholder="Enter your User ID" id="username" name="username" required>
                    </div>
                </div>

                <!-- Password -->
                <div class="field-group">
                    <label for="password">Password</label>
                    <div class="field-wrap">
                        <svg class="field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                            <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                        </svg>
                        <input type="password" placeholder="Enter your password" id="password" name="password" required>
                        <img src="images/eye.png" id="eyeIcon" class="eye-toggle" alt="Toggle password">
                    </div>
                </div>

                <!-- CAPTCHA -->
                <div class="field-group">
                    <label>Security Verification</label>
                    <div class="captcha-row">
                        <div class="captcha-image-box" id="captchaBox">
                            <span class="captcha-placeholder" id="captchaText">X4P9R</span>
                        </div>
                        <button type="button" class="captcha-refresh-btn" id="captchaRefreshBtn" title="Refresh CAPTCHA">
                            <svg viewBox="0 0 24 24">
                                <polyline points="23 4 23 10 17 10"/>
                                <polyline points="1 20 1 14 7 14"/>
                                <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/>
                            </svg>
                        </button>
                    </div>
                    <div class="field-wrap">
                        <svg class="field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                        </svg>
                        <input type="text" id="captchaInput" name="captchaInput" placeholder="Enter the characters above" maxlength="10">
                    </div>
                </div>

                <button type="submit" class="btn-login">Sign In to CBS</button>

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

                <div class="help-row"><a href="#">Forgot Password?</a></div>

            </form>

            <div class="card-footer-note">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                </svg>
                Your connection is secured and encrypted
            </div>

        </div>
    </div>

</div>

<div class="page-footer">© 2025 Merchants Liberal Co-op Bank Ltd. All rights reserved.</div>

<script>
// ── Password eye toggle ──────────────────────────────────────
var passwordInput = document.getElementById("password");
var eyeIcon       = document.getElementById("eyeIcon");
eyeIcon.style.display = "none";

function togglePassword() {
    if (passwordInput.type === "password") {
        passwordInput.type = "text";
        eyeIcon.src = "images/eye-hide.png";
    } else {
        passwordInput.type = "password";
        eyeIcon.src = "images/eye.png";
    }
}
eyeIcon.addEventListener("click", togglePassword);
passwordInput.addEventListener("input", function() {
    eyeIcon.style.display = passwordInput.value.length > 0 ? "block" : "none";
});

// ── CAPTCHA ──────────────────────────────────────────────────
var captchaChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
function generateCaptcha() {
    var code = '';
    for (var i = 0; i < 5; i++) code += captchaChars[Math.floor(Math.random() * captchaChars.length)];
    document.getElementById('captchaText').textContent = code;
    document.getElementById('captchaInput').value = '';
}
document.getElementById('captchaRefreshBtn').addEventListener('click', generateCaptcha);

// ── Left panel: floating particles ──────────────────────────
(function() {
    var wrap = document.getElementById('particlesWrap');
    if (!wrap) return;
    var colors = ['#60A5FA','#818CF8','#4ADE80','#FBBF24','#F472B6','#34D399'];
    for (var i = 0; i < 20; i++) {
        (function(idx) {
            var p = document.createElement('div');
            p.className = 'particle';
            var size = 2.5 + Math.random() * 5;
            p.style.cssText = [
                'width:'      + size                          + 'px',
                'height:'     + size                          + 'px',
                'background:' + colors[idx % colors.length],
                'left:'       + (4 + Math.random() * 92)     + '%',
                'bottom:'     + (Math.random() * 40)         + 'px',
                'animation-duration:'  + (4 + Math.random() * 7) + 's',
                'animation-delay:'     + (Math.random() * 10)    + 's'
            ].join(';');
            wrap.appendChild(p);
        })(i);
    }
})();

// ── Left panel: ticker messages ──────────────────────────────
(function() {
    var messages = [
        '<span>System Online</span> — All banking services operational',
        '<span>Secure Session</span> — 256-bit TLS encryption active',
        '<span>CBS v3.1</span> — Core Banking Solution by IDSSPL',
        '<span>ISO 9001:2000</span> — GLC Certified Software Platform',
        '<span>Dynamic Bank Soft</span> — Java / Oracle / Linux platform'
    ];
    var el  = document.getElementById('tickerText');
    var idx = 0;
    if (!el) return;
    setInterval(function() {
        el.style.opacity = '0';
        el.style.transform = 'translateY(6px)';
        setTimeout(function() {
            idx = (idx + 1) % messages.length;
            el.innerHTML = messages[idx];
            el.style.opacity = '1';
            el.style.transform = 'translateY(0)';
        }, 420);
    }, 3500);
})();

// ── Left panel: card tilt on mouse move ──────────────────────
(function() {
    var card  = document.getElementById('bankCard');
    var panel = document.querySelector('.left-panel');
    if (!card || !panel) return;

    panel.addEventListener('mousemove', function(e) {
        var rect = card.getBoundingClientRect();
        var dx = (e.clientX - (rect.left + rect.width  / 2)) / (rect.width  / 2);
        var dy = (e.clientY - (rect.top  + rect.height / 2)) / (rect.height / 2);
        card.style.animation  = 'none';
        card.style.transition = 'transform 0.12s ease';
        card.style.transform  = 'rotateX(' + (-dy*14) + 'deg) rotateY(' + (dx*14) + 'deg) translateY(-5px) scale(1.025)';
    });

    panel.addEventListener('mouseleave', function() {
        card.style.transition = 'transform 0.7s ease';
        card.style.animation  = 'cardFloat 6s ease-in-out infinite';
        card.style.transform  = '';
    });
})();
</script>

</body>
</html>
<% } %>
