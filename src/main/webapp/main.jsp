<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String userId = (String) session.getAttribute("userId");
    String branchCode = (String) session.getAttribute("branchCode");
    String branchName = "";

    if (userId == null || branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT NAME FROM BRANCHES WHERE BRANCH_CODE=?")) {
        ps.setString(1, branchCode);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            branchName = rs.getString("NAME");
        }
    } catch (Exception e) {
        branchName = "Unknown Branch";
    }
    
    
   
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Main Dashboard</title>
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/breadcrumb.css">
</head>
<body>

<div class="sidebar">
    <div class="profile-section">
        <img src="images/user.png" alt="Profile" class="profile-pic">
        <div class="branch-name"><%= branchName.toUpperCase() %></div>
    </div>

    <ul class="menu">
       <li class="active">
            <a href="#" onclick="loadPage('dashboard.jsp', 'Dashboard', 'Dashboard', this); return false;">
                <img src="images/dashboard.png" width="20" height="20">
                Dashboard
            </a>
       </li>

        <li>
            <a href="#" onclick="loadPage('addCustomer.jsp', 'Add Customer', 'Add Customer', this); return false;">
                <img src="images/addCustomer.png" width="20" height="20">
                Add Customer
            </a>
        </li>
        
        <li>
            <a href="#" onclick="loadPage('authorizationPending.jsp', 'Authorization Pending', 'Authorization Pending', this); return false;">
                <img src="images/authorizationPending.png" width="22" height="22">
                Authorization Pending
            </a>
        </li>
        
        <li>
            <a href="#" onclick="loadPage('newApplication.jsp', 'New Application', 'New Application', this); return false;">
                <img src="images/newApplication.png" width="22" height="22">
                New Application
            </a>
        </li>
        
        <!-- Add new menu items here following the same pattern -->
        <!-- Example: 
        <li>
            <a href="#" onclick="loadPage('loans.jsp', 'Loans', 'Loans', this); return false;">
                <img src="images/loan.png" width="20" height="20">
                Loans
            </a>
        </li>
        -->
    </ul>

    <div class="logout">
        <a href="#" onclick="showLogoutConfirmation(event)">𓉘➜ Log Out</a>
    </div>
</div>

<div class="main-content">
    <header>
        <div id="breadcrumbNav" class="breadcrumb-container"></div>
        <div id="liveDate"></div>
    </header>

    <iframe id="contentFrame" src="dashboard.jsp" frameborder="0"></iframe>
</div>

<!-- Logout Confirmation Modal -->
<div id="logoutModal" class="logout-modal">
    <div class="logout-modal-content">
        <h2>⚠️ Confirm Logout</h2>
        <p>Are you sure you want to log out?</p>
        <div class="logout-modal-buttons">
            <button class="logout-btn logout-btn-cancel" onclick="closeLogoutModal()">Cancel</button>
            <button class="logout-btn logout-btn-confirm" onclick="confirmLogout()">Yes, Logout</button>
        </div>
    </div>
</div>

<script>
// Complete page mapping - ADD ALL YOUR PAGES HERE
const pageMap = {
    'Dashboard': 'dashboard.jsp',
    'Add Customer': 'addCustomer.jsp',
    'Total Customers': 'totalCustomers.jsp',
    'Authorization Pending': 'authorizationPending.jsp',
    'Loan Details': 'loanDetails.jsp'
};

// Update breadcrumb display
function updateBreadcrumb(path) {
    const breadcrumbNav = document.getElementById("breadcrumbNav");
    if (!breadcrumbNav) return;
    
    const parts = path.split(' > ');
    let breadcrumbHTML = '';
    
    parts.forEach((part, index) => {
        if (index === parts.length - 1) {
            breadcrumbHTML += '<span class="breadcrumb-current">' + part + '</span>';
        } else {
            const pageName = pageMap[part] || 'dashboard.jsp';
            const previousPath = parts.slice(0, index + 1).join(' > ');
            
            breadcrumbHTML += '<div class="breadcrumb-item">' +
                '<a href="#" class="breadcrumb-link" onclick="navigateToBreadcrumb(\'' + 
                pageName + '\', \'' + part + '\', \'' + previousPath + '\'); return false;">' +
                part + '</a><span class="breadcrumb-separator">></span></div>';
        }
    });
    
    breadcrumbNav.innerHTML = breadcrumbHTML;
}

function navigateToBreadcrumb(page, title, path) {
    document.getElementById("contentFrame").src = page;
    updateBreadcrumb(path);
    updateActiveMenu(title);
}

function loadPage(page, title, breadcrumbPath, anchorEl) {
    document.getElementById("contentFrame").src = page;
    updateBreadcrumb(breadcrumbPath);
    
    document.querySelectorAll(".menu li").forEach(li => li.classList.remove("active"));
    if (anchorEl && anchorEl.closest) {
        anchorEl.closest('li').classList.add("active");
    }
}

function updateActiveMenu(title) {
    document.querySelectorAll(".menu li").forEach(li => li.classList.remove("active"));
    const menuLink = Array.from(document.querySelectorAll(".menu li a")).find(
        a => a.textContent.trim().includes(title)
    );
    if (menuLink) {
        menuLink.closest('li').classList.add("active");
    }
}

window.updateParentBreadcrumb = function(path) {
    updateBreadcrumb(path);
};

window.onload = function() {
    updateBreadcrumb('Dashboard');
};

function updateDate() {
    const now = new Date();
    const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
    const dateElement = document.getElementById("liveDate");
    if (dateElement) {
        dateElement.innerText = now.toLocaleDateString('en-US', options);
    }
}
setInterval(updateDate, 1000);
updateDate();

function showLogoutConfirmation(event) {
    event.preventDefault();
    document.getElementById("logoutModal").style.display = "block";
}

function closeLogoutModal() {
    document.getElementById("logoutModal").style.display = "none";
}

function confirmLogout() {
    window.location.href = "logout.jsp";
}

window.onclick = function(event) {
    const modal = document.getElementById("logoutModal");
    if (event.target === modal) {
        closeLogoutModal();
    }
}

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeLogoutModal();
    }
});

function updatePendingCount(count) {
    document.getElementById("pendingCount").innerText = "(" + count + ")";
}

</script>

</body>
</html>