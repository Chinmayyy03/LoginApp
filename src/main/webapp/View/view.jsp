<%@ page import="java.sql.*, db.DBConnection, java.text.SimpleDateFormat" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    // Get branch code from session
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String branchCode = (String) sess.getAttribute("branchCode");
    
    // Get working date from session
    Date workingDate = (Date) session.getAttribute("workingDate");
    
    // Count total accounts for current working date
    int totalAccounts = 0;
    
    if (workingDate != null) {
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) as TOTAL " +
                "FROM ACCOUNT.ACCOUNT " +
                "WHERE SUBSTR(ACCOUNT_CODE, 1, 4) = ? " +
                "AND TRUNC(DATEACCOUNTOPEN) = TRUNC(?)");
            
            ps.setString(1, branchCode);
            ps.setDate(2, workingDate);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                totalAccounts = rs.getInt("TOTAL");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>View Account Card</title>

<style>
    * {
        box-sizing: border-box;
    }

    body {
        margin: 0;
        font-family: 'Segoe UI', Roboto, Arial, sans-serif;
        background: #e8e4fc;
        color: #1a1a1a;
    }

    /* ================= CONTAINER ================= */
    .dashboard-container {
        display: flex;
        justify-content: center;
        align-items: flex-start;
        padding: 20px;
        background-color: #e8e4fc;
        min-height: 100vh;
        width: 100%;
    }

    /* ================= GRID ================= */
    .cards-wrapper {
        display: grid;
        grid-template-columns: repeat(4, 260px);
        gap: 20px;
        padding: 20px;
        justify-content: center;
        width: 100%;
    }

    /* ================= CARD ================= */
    .card {
        width: 260px;
        background: linear-gradient(135deg, #4a9eff 0%, #3d85d9 100%);
        color: white;
        padding: 22px 26px;
        border-radius: 20px;
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.15);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        position: relative;
        overflow: hidden;
        cursor: pointer;
        min-height: 150px;
    }

    .card::before,
    .card::after {
        content: "";
        position: absolute;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.1);
    }

    .card::before {
        width: 140px;
        height: 140px;
        top: -40px;
        right: -40px;
    }

    .card::after {
        width: 200px;
        height: 200px;
        bottom: -70px;
        left: -70px;
    }

    .card h3 {
        font-size: 20px;
        font-weight: 600;
        margin-bottom: 12px;
        position: relative;
        z-index: 1;
    }

    .card p {
        font-size: 30px;
        font-weight: 700;
        margin: 0;
        position: relative;
        z-index: 1;
        word-break: break-word;
    }

    .card:hover {
        transform: translateY(-6px) scale(1.02);
        box-shadow: 0 12px 30px rgba(74, 158, 255, 0.35);
    }

    .card:active {
        transform: scale(0.97);
    }

    /* ================= ERROR MESSAGE ================= */
    .error-message {
        grid-column: 1 / -1;
        color: #dc2626;
        background: #fee2e2;
        padding: 20px;
        border-radius: 8px;
        text-align: center;
    }

    /* ================= RESPONSIVE BREAKPOINTS ================= */

    /* Laptop → 3 cards */
    @media (max-width: 1250px) {
        .cards-wrapper {
            grid-template-columns: repeat(3, 260px);
        }
    }

    /* Tablet → 2 cards */
    @media (max-width: 900px) {
        .cards-wrapper {
            grid-template-columns: repeat(2, 260px);
        }
    }

    /* Mobile → 1 card */
    @media (max-width: 580px) {
        .cards-wrapper {
            grid-template-columns: repeat(1, 260px);
        }

        .card h3 {
            font-size: 14px;
        }

        .card p {
            font-size: 28px;
        }
    }
</style>
</head>

<body>
<div class="dashboard-container">
    <div class="cards-wrapper">
        <% if (workingDate != null) { %>
        
        <!-- Total Accounts Card -->
        <div class="card" onclick="openInParentFrame('View/totalAccounts.jsp', 'View > Total Accounts')">
            <h3>Total Accounts</h3>
            <p><%= totalAccounts %></p>
        </div>
        
        <% } else { %>
        
        <div class="error-message">
            <h3>Working Date Not Available</h3>
            <p>Please refresh the page to load the working date.</p>
        </div>
        
        <% } %>
    </div>
</div>

<script>
    window.onload = function () {
        if (window.parent && window.parent.updateParentBreadcrumb) {
            window.parent.updateParentBreadcrumb('View');
        }
    };

    function openInParentFrame(page, breadcrumbPath) {
        if (window.parent && window.parent.document) {
            const iframe = window.parent.document.getElementById("contentFrame");
            if (iframe) {
                iframe.src = page;
                if (window.parent.updateParentBreadcrumb) {
                    window.parent.updateParentBreadcrumb(breadcrumbPath);
                }
            }
        }
    }
</script>
</body>
</html>