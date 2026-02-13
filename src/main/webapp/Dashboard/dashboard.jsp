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
<link rel="stylesheet" href="../css/cardView.css">
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
            var adjustedPage = page.includes('/') ? page : '../' + page;
            iframe.src = adjustedPage;
            
            if (window.parent.updateParentBreadcrumb) {
                window.parent.updateParentBreadcrumb(breadcrumbPath, adjustedPage);
            }
        }
    }
}
</script>
</body>
</html>