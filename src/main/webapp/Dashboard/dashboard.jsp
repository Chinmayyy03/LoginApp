<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    
    if (branchCode == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Load card structure from database
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    java.util.List<java.util.Map<String, String>> cards = new java.util.ArrayList<>();
    
    try {
        conn = DBConnection.getConnection();
        ps = conn.prepareStatement(
            "SELECT SR_NUMBER, DESCRIPTION, PAGE_LINK " +
            "FROM GLOBALCONFIG.DASHBOARD " +
            "WHERE DESCRIPTION IS NOT NULL " +
            "ORDER BY SR_NUMBER"
        );
        rs = ps.executeQuery();
        
        while (rs.next()) {
            java.util.Map<String, String> card = new java.util.HashMap<>();
            card.put("srNumber", String.valueOf(rs.getInt("SR_NUMBER")));
            card.put("description", rs.getString("DESCRIPTION"));
            
            String pageLink = rs.getString("PAGE_LINK");
            if (pageLink == null || pageLink.trim().isEmpty()) {
                pageLink = "dashboard.jsp";
            }
            card.put("pageLink", pageLink);
            
            cards.add(card);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (ps != null) ps.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
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
        padding: 18px 20px;
        border-radius: 20px;
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.15);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        position: relative;
        overflow: hidden;
        cursor: pointer;
        min-height: 100px;
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
        font-size: 16px;
        font-weight: 600;
        margin: 0 0 10px 0;
        position: relative;
        z-index: 1;
        line-height: 1.25;
        min-height: 40px;
        word-wrap: break-word;
    }

    .card p {
        font-size: 28px;
        font-weight: 700;
        margin: 0;
        position: relative;
        z-index: 1;
        word-wrap: break-word;
        overflow-wrap: break-word;
        line-height: 1.2;
        display: block;
        width: 100%;
        hyphens: none;
    }

    .card p.loading {
        font-size: 18px;
        opacity: 0.7;
        font-weight: 400;
        word-break: normal;
    }

    /* Adaptive font sizes based on content length */
    .card p.size-1 { font-size: 28px; line-height: 1.2; }  /* 0-12 chars */
    .card p.size-2 { font-size: 24px; line-height: 1.2; }  /* 13-16 chars */
    .card p.size-3 { font-size: 21px; line-height: 1.2; }   /* 17-20 chars */
    .card p.size-4 { font-size: 18px; line-height: 1.25; }   /* 21-25 chars */
    .card p.size-5 { font-size: 15px; line-height: 1.25; }  /* 26-32 chars */
    .card p.size-6 { font-size: 13px; line-height: 1.3; }   /* 33-40 chars */
    .card p.size-7 { font-size: 11px; line-height: 1.35; }  /* 41+ chars */

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

        .card p.size-1 { font-size: 26px; }
        .card p.size-2 { font-size: 22px; }
        .card p.size-3 { font-size: 19px; }
        .card p.size-4 { font-size: 16px; }
        .card p.size-5 { font-size: 14px; }
        .card p.size-6 { font-size: 12px; }
        .card p.size-7 { font-size: 10px; }
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
            font-size: 15px;
            min-height: 38px;
        }

        .card p.size-1 { font-size: 24px; }
        .card p.size-2 { font-size: 20px; }
        .card p.size-3 { font-size: 18px; }
        .card p.size-4 { font-size: 15px; }
        .card p.size-5 { font-size: 13px; }
        .card p.size-6 { font-size: 11px; }
        .card p.size-7 { font-size: 10px; }
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
            padding: 16px 18px;
            min-height: 140px;
        }

        .card h3 {
            font-size: 14px;
            min-height: 36px;
            margin-bottom: 8px;
        }

        .card p.size-1 { font-size: 22px; }
        .card p.size-2 { font-size: 19px; }
        .card p.size-3 { font-size: 17px; }
        .card p.size-4 { font-size: 14px; }
        .card p.size-5 { font-size: 12px; }
        .card p.size-6 { font-size: 10px; }
        .card p.size-7 { font-size: 9px; }
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
            padding: 14px 16px;
        }

        .card h3 {
            font-size: 13px;
        }

        .card p.size-1 { font-size: 20px; }
        .card p.size-2 { font-size: 17px; }
        .card p.size-3 { font-size: 15px; }
        .card p.size-4 { font-size: 13px; }
        .card p.size-5 { font-size: 10px; }
        .card p.size-6 { font-size: 8px; }
        .card p.size-7 { font-size: 7px; }
    }
</style>
</head>

<body>
<div class="dashboard-container">
    <div class="cards-wrapper">
        <%
            if (cards != null && !cards.isEmpty()) {
                for (java.util.Map<String, String> card : cards) {
                    String srNumber = card.get("srNumber");
                    String description = card.get("description");
                    String pageLink = card.get("pageLink");
        %>

        <div class="card" id="card-<%= srNumber %>"
             onclick="openInParentFrame('<%= pageLink %>', 'Dashboard > <%= description %>')">
            <h3><%= description %></h3>
            <p class="loading" id="value-<%= srNumber %>">Loading...</p>
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
    if (cards != null && !cards.isEmpty()) {
        for (int i = 0; i < cards.size(); i++) {
            java.util.Map<String, String> card = cards.get(i);
            if (i > 0) out.print(",");
    %>
    {
        srNumber: '<%= card.get("srNumber") %>'
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
    // Load each card value
    for (let card of cardsData) {
        loadSingleCard(card);
    }
}

async function loadSingleCard(card) {
    try {
        const response = await fetch('../getCardValueUnified.jsp?type=dashboard&id=' + card.srNumber);
        const data = await response.json();
        
        const valueElement = document.getElementById('value-' + card.srNumber);
        if (valueElement) {
            if (data.error) {
                valueElement.textContent = 'Error';
            } else {
                valueElement.textContent = data.value;
            }
            valueElement.classList.remove('loading');
            
            // Remove all size classes first
            valueElement.className = valueElement.className.replace(/size-\d+/g, '').trim();
            
            // Calculate appropriate size class based on text length
            const length = data.value.length;
            let sizeClass = 'size-1';
            
            if (length <= 12) {
                sizeClass = 'size-1';
            } else if (length <= 16) {
                sizeClass = 'size-2';
            } else if (length <= 20) {
                sizeClass = 'size-3';
            } else if (length <= 25) {
                sizeClass = 'size-4';
            } else if (length <= 32) {
                sizeClass = 'size-5';
            } else if (length <= 40) {
                sizeClass = 'size-6';
            } else {
                sizeClass = 'size-7';
            }
            
            valueElement.classList.add(sizeClass);
        }
    } catch (error) {
        console.error('Error loading card:', error);
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
            // If page ALREADY contains '/', use as-is (already has folder path)
            // If page doesn't contain '/', add '../' to go up from Dashboard folder
            var adjustedPage = page.includes('/') ? page : '../' + page;
            iframe.src = adjustedPage;
            
            if (window.parent.updateParentBreadcrumb) {
                window.parent.updateParentBreadcrumb(breadcrumbPath);
            }
        }
    }
}
</script>
</body>
</html>