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

    .card p.loading {
        font-size: 18px;
        opacity: 0.7;
        font-weight: 400;
        animation: pulse 1.5s ease-in-out infinite;
    }

    @keyframes pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.5; }
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
        <!-- Total Accounts Card -->
        <div class="card" onclick="openInParentFrame('View/totalAccounts.jsp', 'View > Total Accounts')">
            <h3>Total Accounts</h3>
            <p class="loading" id="total-accounts-value">Loading...</p>
        </div>
        
        <!-- Add more cards here as needed -->
    </div>
</div>

<script>
    window.onload = function () {
        if (window.parent && window.parent.updateParentBreadcrumb) {
            window.parent.updateParentBreadcrumb('View');
        }
        
        // Load card values asynchronously
        loadCardValues();
    };
    
    async function loadCardValues() {
        // Load Total Accounts card
        await loadCard('total_accounts', 'total-accounts-value', 'view');
        
        // Add more cards here as needed
    }
    
    async function loadCard(cardId, elementId, cardType) {
        try {
            const response = await fetch('../getCardValueUnified.jsp?type=' + cardType + '&id=' + cardId);
            const data = await response.json();
            
            const valueElement = document.getElementById(elementId);
            if (valueElement) {
                if (data.error) {
                    valueElement.textContent = 'Error';
                } else {
                    valueElement.textContent = data.value;
                }
                valueElement.classList.remove('loading');
            }
        } catch (error) {
            console.error('Error loading card:', error);
            const valueElement = document.getElementById(elementId);
            if (valueElement) {
                valueElement.textContent = 'Error';
                valueElement.classList.remove('loading');
            }
        }
    }

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