<%@ page import="java.sql.*, db.DBConnection, servlet.DashboardService, servlet.DashboardCard, java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    
    if (branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Only load card structure (fast - no function calls)
    DashboardService dashboardService = new DashboardService();
    List<DashboardCard> cards = null;

    try {
        cards = dashboardService.getDashboardCards();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dynamic Dashboard</title>

<style>
    * {
        box-sizing: border-box;
    }

    body {
        margin: 0;
        font-family: 'Segoe UI', Roboto, Arial, sans-serif;
        background: #f5f7fa;
        color: #1a1a1a;
    }

    .dashboard-container {
        display: flex;
        justify-content: center;
        align-items: flex-start;
        padding: 40px;
        background-color: #e8e4fc;
        min-height: 100vh;
        width: 100%;
    }

    .cards-wrapper {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 30px;
        padding: 0;
        width: 100%;
        max-width: 1400px;
    }

    .card {
        background: linear-gradient(135deg, #4a9eff 0%, #3d85d9 100%);
        color: white;
        padding: 25px 28px;
        border-radius: 20px;
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.15);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        position: relative;
        overflow: hidden;
        cursor: pointer;
        min-height: 160px;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
    }

    .card::before,
    .card::after {
        content: "";
        position: absolute;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.1);
        pointer-events: none;
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
        font-size: 18px;
        font-weight: 600;
        margin: 0 0 15px 0;
        position: relative;
        z-index: 1;
        line-height: 1.3;
        min-height: 48px;
    }

    .card p {
        font-size: 32px;
        font-weight: 700;
        margin: 0;
        position: relative;
        z-index: 1;
        word-wrap: break-word;
        overflow-wrap: break-word;
        line-height: 1.2;
        display: block;
        max-width: 100%;
    }

    .card p.loading {
        font-size: 18px;
        opacity: 0.7;
        font-weight: 400;
    }

    .card p.long-text {
        font-size: 24px;
    }

    .card p.very-long-text {
        font-size: 18px;
    }

    .card:hover {
        transform: translateY(-6px) scale(1.02);
        box-shadow: 0 12px 30px rgba(74, 158, 255, 0.35);
    }

    .card:active {
        transform: scale(0.97);
    }

    .error-message {
        grid-column: 1 / -1;
        color: #dc2626;
        background: #fee2e2;
        padding: 20px;
        border-radius: 8px;
        text-align: center;
    }

    /* Loading animation */
    @keyframes pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.5; }
    }

    .loading {
        animation: pulse 1.5s ease-in-out infinite;
    }

    /* Tablet Landscape */
    @media (max-width: 1200px) {
        .dashboard-container {
            padding: 30px;
        }

        .cards-wrapper {
            gap: 25px;
            grid-template-columns: repeat(3, 1fr);
        }
    }

    /* Tablet Portrait */
    @media (max-width: 900px) {
        .dashboard-container {
            padding: 25px;
        }

        .cards-wrapper {
            gap: 20px;
            grid-template-columns: repeat(2, 1fr);
        }

        .card h3 {
            font-size: 16px;
            min-height: 42px;
        }

        .card p {
            font-size: 28px;
        }
    }

    /* Mobile */
    @media (max-width: 600px) {
        .dashboard-container {
            padding: 20px 15px;
        }

        .cards-wrapper {
            gap: 18px;
            grid-template-columns: 1fr;
        }

        .card {
            padding: 20px 24px;
            min-height: 140px;
        }

        .card h3 {
            font-size: 15px;
            min-height: 38px;
            margin-bottom: 12px;
        }

        .card p {
            font-size: 26px;
        }

        .card p.long-text {
            font-size: 20px;
        }

        .card p.very-long-text {
            font-size: 16px;
        }
    }

    /* Extra Small Mobile */
    @media (max-width: 400px) {
        .dashboard-container {
            padding: 15px 10px;
        }

        .cards-wrapper {
            gap: 15px;
        }

        .card {
            padding: 18px 20px;
        }

        .card h3 {
            font-size: 14px;
        }

        .card p {
            font-size: 24px;
        }
    }
</style>
</head>

<body>
<div class="dashboard-container">
    <div class="cards-wrapper">
        <%
            if (cards != null && !cards.isEmpty()) {
                for (DashboardCard card : cards) {
                    if (card.getDescription() == null) continue;

                    String pageLink = card.getPageLink();
                    if (pageLink == null || pageLink.trim().isEmpty()) {
                        pageLink = "dashboard.jsp";
                    }
        %>

        <div class="card" id="card-<%= card.getSrNumber() %>"
             onclick="openInParentFrame('<%= pageLink %>', 'Dashboard > <%= card.getDescription() %>')">
            <h3><%= card.getDescription() %></h3>
            <p class="loading" id="value-<%= card.getSrNumber() %>">Loading...</p>
        </div>

        <%
                }
            } else {
        %>

        <div class="error-message">
            <h3>No dashboard cards configured</h3>
            <p>Please configure cards in GLOBALCONFIG.DASHBOARD table</p>
        </div>

        <%
            }
        %>
    </div>
</div>

<script>
// Card data loaded from server
const cardsData = [
    <%
    if (cards != null) {
        boolean first = true;
        for (DashboardCard card : cards) {
            if (card.getDescription() == null) continue;
            if (!first) out.print(",");
            first = false;
    %>
    {
        srNumber: <%= card.getSrNumber() %>,
        functionName: '<%= card.getFuncationName() != null ? card.getFuncationName() : "" %>',
        paramitar: '<%= card.getParamitar() != null ? card.getParamitar() : "" %>',
        tableName: '<%= card.getTableName() != null ? card.getTableName() : "" %>'
    }
    <%
        }
    }
    %>
];

window.onload = function () {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Dashboard');
    }
    
    // Load card values asynchronously
    loadCardValues();
};

async function loadCardValues() {
    // Load each card value one by one (or batch them)
    for (let card of cardsData) {
        loadSingleCard(card);
    }
}

async function loadSingleCard(card) {
    try {
        const response = await fetch('getCardValue.jsp?sr=' + card.srNumber);
        const data = await response.json();
        
        const valueElement = document.getElementById('value-' + card.srNumber);
        if (valueElement) {
            valueElement.textContent = data.value;
            valueElement.classList.remove('loading');
            
            // Adjust font size based on length
            if (data.value.length > 20) {
                valueElement.classList.add('very-long-text');
            } else if (data.value.length > 12) {
                valueElement.classList.add('long-text');
            }
        }
    } catch (error) {
        const valueElement = document.getElementById('value-' + card.srNumber);
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