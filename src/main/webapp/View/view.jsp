<%@ page import="java.sql.*, db.DBConnection, java.text.SimpleDateFormat" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("../login.jsp");
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
<script src="<%= request.getContextPath() %>/js/breadcrumb-auto.js"></script>
<link rel="stylesheet" href="../css/cardView.css">
</head>

<body>
<div class="dashboard-container">
    <div class="cards-wrapper">

        <!-- Total Accounts Card -->
        <div class="card" onclick="openInParentFrame('View/totalAccounts.jsp', 'View > Total Accounts')">
            <h3>Total Accounts</h3>
            <p class="loading" id="total-accounts-value">Loading...</p>
        </div>

        <!-- All Customers Card -->
        <div class="card" onclick="openInParentFrame('View/allCustomers.jsp', 'View > Customers')">
            <h3>Customers</h3>
            <p class="loading" id="all-customers-value">Loading...</p>
        </div>

        <!-- ✅ All Users Card (NEW) -->
        <div class="card" onclick="openInParentFrame('View/allUsers.jsp', 'View > Users')">
            <h3>Users</h3>
            <p class="loading" id="all-users-value">Loading...</p>
        </div>

    </div>
</div>

<script>
window.onload = function () {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('View/view.jsp')
        );
    }
    loadCardValues();
};

async function loadCardValues() {
    await loadCard('total_accounts', 'total-accounts-value',  'view');
    await loadCard('all_customers',  'all-customers-value',   'view');
    await loadCard('all_users',      'all-users-value',       'view');   // NEW
}

async function loadCard(cardId, elementId, cardType) {
    try {
        const response = await fetch('../getCardValueUnified.jsp?type=' + cardType + '&id=' + cardId);
        const data     = await response.json();
        const el       = document.getElementById(elementId);
        if (el) {
            el.textContent = data.error ? 'Error' : data.value;
            el.classList.remove('loading');
        }
    } catch (error) {
        console.error('Error loading card:', error);
        const el = document.getElementById(elementId);
        if (el) { el.textContent = 'Error'; el.classList.remove('loading'); }
    }
}

function openInParentFrame(page, breadcrumbPath) {
    if (window.parent && window.parent.document) {
        const iframe = window.parent.document.getElementById("contentFrame");
        if (iframe) {
            iframe.src = page;
            if (window.parent.updateParentBreadcrumb) {
                window.parent.updateParentBreadcrumb(
                    window.buildBreadcrumbPath(page)
                );
            }
        }
    }
}
</script>
</body>
</html>
