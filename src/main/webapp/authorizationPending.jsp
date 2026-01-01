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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Authorization Pending</title>
    
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
    }

    .card p.loading {
        font-size: 18px;
        opacity: 0.7;
        font-weight: 400;
    }

    @keyframes pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.5; }
    }

    .loading {
        animation: pulse 1.5s ease-in-out infinite;
    }

    .card:hover {
        transform: translateY(-6px) scale(1.02);
        box-shadow: 0 12px 30px rgba(74, 158, 255, 0.35);
    }

    .card:active {
        transform: scale(0.97);
    }

    @media (max-width: 1200px) {
        .dashboard-container { padding: 30px; }
        .cards-wrapper {
            gap: 25px;
            grid-template-columns: repeat(3, 1fr);
        }
    }

    @media (max-width: 900px) {
        .dashboard-container { padding: 25px; }
        .cards-wrapper {
            gap: 20px;
            grid-template-columns: repeat(2, 1fr);
        }
        .card h3 {
            font-size: 15px;
            min-height: 38px;
        }
        .card p {
            font-size: 24px;
        }
    }

    @media (max-width: 600px) {
        .dashboard-container { padding: 20px 15px; }
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
        .card p {
            font-size: 22px;
        }
    }

    @media (max-width: 400px) {
        .dashboard-container { padding: 15px 10px; }
        .cards-wrapper { gap: 15px; }
        .card { padding: 14px 16px; }
        .card h3 { font-size: 13px; }
        .card p { font-size: 20px; }
    }
</style>
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
    window.onload = function() {
        if (window.parent && window.parent.updateParentBreadcrumb) {
            window.parent.updateParentBreadcrumb('Authorization Pending');
        }
        
        loadCardValues();
    };
    
    async function loadCardValues() {
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