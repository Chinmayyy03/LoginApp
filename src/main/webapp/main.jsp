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
                <img src="images/dashboard.png" width="20" height="20" style="vertical-align: middle; margin-right: 8px;">
                Dashboard
            </a>
       </li>

        <li>
            <a href="#" onclick="loadPage('addCustomer.jsp', 'Add Customer', 'Add Customer', this); return false;">
                <img src="images/customer.png" width="20" height="20" style="vertical-align: middle; margin-right: 8px;">
                Add Customer
            </a>
        </li>
        
        <!-- Add new menu items here -->
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
        <a href="#" onclick="showLogoutConfirmation(event)">⏻ Log Out</a>
    </div>
</div>

<div class="main-content">
    <header>
        <div id="breadcrumbNav" class="breadcrumb-container">
            <!-- Breadcrumb will be dynamically inserted here -->
        </div>
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
// Breadcrumb navigation function
function updateBreadcrumb(path) {
    const breadcrumbNav = document.getElementById("breadcrumbNav");
    const parts = path.split(' > ');
    
    let breadcrumbHTML = '';
    
    parts.forEach((part, index) => {
        if (index === parts.length - 1) {
            // Last item (current page) - not clickable
            breadcrumbHTML += '<span class="breadcrumb-current">' + part + '</span>';
        } else {
            // Previous items - clickable
            const isHome = (part === 'Dashboard');
            const pageName = isHome ? 'dashboard.jsp' : getPageForBreadcrumb(part);
            const previousPath = getPreviousPath(parts, index);
            
            breadcrumbHTML += '<div class="breadcrumb-item">' +
                '<a href="#" class="breadcrumb-link" onclick="loadPageFromBreadcrumb(\'' + pageName + '\', \'' + part + '\', \'' + previousPath + '\'); return false;">' +
                part +
                '</a>' +
                '<span class="breadcrumb-separator">></span>' +
                '</div>';
        }
    });
    
    breadcrumbNav.innerHTML = breadcrumbHTML;
}

// Helper function to get page URL from breadcrumb text
function getPageForBreadcrumb(pageName) {
    const pageMap = {
        'Dashboard': 'dashboard.jsp',
        'Add Customer': 'addCustomer.jsp',
        'Total Customers': 'customers.jsp',
        'Loan Details': 'loanDetails.jsp'
    };
    return pageMap[pageName] || 'dashboard.jsp';
}

// Helper function to reconstruct path up to a certain index
function getPreviousPath(parts, endIndex) {
    return parts.slice(0, endIndex + 1).join(' > ');
}

// Load page from breadcrumb click
function loadPageFromBreadcrumb(page, title, path) {
    document.getElementById("contentFrame").src = page;
    updateBreadcrumb(path);
    
    // Update active menu item
    document.querySelectorAll(".menu li").forEach(li => li.classList.remove("active"));
    const menuLink = Array.from(document.querySelectorAll(".menu li a")).find(
        a => a.textContent.trim().includes(title)
    );
    if (menuLink) {
        menuLink.closest('li').classList.add("active");
    }
}

// Main page load function
function loadPage(page, title, breadcrumbPath, anchorEl) {
    // Load page
    document.getElementById("contentFrame").src = page;
    
    // Update breadcrumb
    updateBreadcrumb(breadcrumbPath);
    
    // Reset active classes and add to the clicked li
    document.querySelectorAll(".menu li").forEach(li => li.classList.remove("active"));
    if (anchorEl && anchorEl.closest) {
        anchorEl.closest('li').classList.add("active");
    }
}

// Function to be called from iframe (for card clicks)
window.updateParentBreadcrumb = function(path) {
    updateBreadcrumb(path);
};

// Initialize breadcrumb on page load
window.onload = function() {
    updateBreadcrumb('Dashboard');
};

// Live date updater
function updateDate() {
    const now = new Date();
    const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
    document.getElementById("liveDate").innerText = now.toLocaleDateString('en-US', options);
}
setInterval(updateDate, 1000);
updateDate();

// Logout confirmation functions
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

// Close modal when clicking outside of it
window.onclick = function(event) {
    const modal = document.getElementById("logoutModal");
    if (event.target === modal) {
        closeLogoutModal();
    }
}

// Close modal with Escape key
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeLogoutModal();
    }
});
</script>

</body>
</html>