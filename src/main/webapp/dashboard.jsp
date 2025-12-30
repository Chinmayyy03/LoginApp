<%@ page import="java.sql.*, db.DBConnection, servlet.DashboardService, servlet.DashboardCard, java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    
    if (branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }

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
        /* Key fix: Scale down text if it gets too long */
        display: block;
        max-width: 100%;
    }

    /* Dynamically scale font size for long text */
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

                    String formattedValue = dashboardService.getFormattedCardValue(card, branchCode);

                    String pageLink = card.getPageLink();

                    if (pageLink == null || pageLink.trim().isEmpty()) {
                        pageLink = "dashboard.jsp";
                    }

                    // Determine text length class for responsive sizing
                    String textLengthClass = "";
                    if (formattedValue.length() > 20) {
                        textLengthClass = "very-long-text";
                    } else if (formattedValue.length() > 12) {
                        textLengthClass = "long-text";
                    }
        %>

        <div class="card"
             onclick="openInParentFrame('<%= pageLink %>', 'Dashboard > <%= card.getDescription() %>')">
            <h3><%= card.getDescription() %></h3>
            <p class="<%= textLengthClass %>"><%= formattedValue %></p>
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
    window.onload = function () {
        if (window.parent && window.parent.updateParentBreadcrumb) {
            window.parent.updateParentBreadcrumb('Dashboard');
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