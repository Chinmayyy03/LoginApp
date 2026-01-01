<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="css/dashboard.css">
</head>
<body>
    <div class="dashboard-container">
        <div class="cards-wrapper">
            <div class="card" onclick="openInParentFrame('authorizationPendingCustomers.jsp', 'Authorization Pending > Customer List')">
                <h3>Authorization Pending Customers</h3>
                <p class="loading" id="pending-customers-value">Loading...</p>
            </div>
            
            <div class="card" onclick="openInParentFrame('authorizationPendingApplications.jsp', 'Authorization Pending > Application List')">
                <h3>Authorization Pending Application</h3>
                <p class="loading" id="pending-applications-value">Loading...</p>
            </div>
        </div>
    </div>
    
    <script>
    // Update breadcrumb when dashboard loads
    window.onload = function() {
        if (window.parent && window.parent.updateParentBreadcrumb) {
            window.parent.updateParentBreadcrumb('Authorization Pending');
        }
        
        // Load card values asynchronously
        loadCardValues();
    };
    
    async function loadCardValues() {
        // Load both cards in parallel
        await Promise.all([
            loadCard('pending_customers', 'pending-customers-value', 'auth'),
            loadCard('pending_applications', 'pending-applications-value', 'auth')
        ]);
    }
    
    async function loadCard(cardId, elementId, cardType) {
        try {
            const response = await fetch('getCardValueUnified.jsp?type=' + cardType + '&id=' + cardId);
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