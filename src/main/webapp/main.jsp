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
       <li class="active" data-page="dashboard.jsp">
            <a href="#" onclick="loadPage('dashboard.jsp', 'Dashboard', 'Dashboard', this); return false;">
                <img src="images/dashboard.png" width="20" height="20">
                Dashboard
            </a>
       </li>

        <li data-page="addCustomer.jsp">
            <a href="#" onclick="loadPage('addCustomer.jsp', 'Add Customer', 'Add Customer', this); return false;">
                <img src="images/addCustomer.png" width="20" height="20">
                Add Customer
            </a>
        </li>
        
        <li data-page="authorizationPending.jsp">
            <a href="#" onclick="loadPage('authorizationPending.jsp', 'Authorization Pending', 'Authorization Pending', this); return false;">
                <img src="images/authorizationPending.png" width="22" height="22">
                Authorization Pending
            </a>
        </li>
        
        <li data-page="newApplication.jsp">
            <a href="#" onclick="loadPage('newApplication.jsp', 'Open Account', 'Open Account', this); return false;">
                <img src="images/newApplication.png" width="22" height="22">
                Open Account
            </a>
        </li>
        
        <li data-page="masters.jsp">
            <a href="#" onclick="loadPage('masters.jsp', 'Masters', 'Masters', this); return false;">
                <img src="images/newApplication.png" width="22" height="22">
               Master
            </a>
        </li>
        
    </ul>

    <div class="logout">
        <a href="#" onclick="showLogoutConfirmation(event)">𓉘➜ Log Out</a>
    </div>
</div>

<div class="main-content">
    <header>
        <div id="breadcrumbNav" class="breadcrumb-container"></div>
        <div id="workingDate" style=" color: #fff; font-size: 14px; opacity: 0.9;">Loading working date...</div>
    </header>

    <iframe id="contentFrame" frameborder="0"></iframe>
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
//========== PAGE MAPPING ==========
const pageMap = {
    'Dashboard': 'dashboard.jsp',
    'Add Customer': 'addCustomer.jsp',
    'Total Customers': 'totalCustomers.jsp',
    'Authorization Pending': 'authorizationPending.jsp',
    'Customer List': 'authorizationPendingCustomers.jsp',
    'Application List': 'authorizationPendingApplications.jsp',
    'Loan Details': 'loanDetails.jsp',
    'Open Account': 'newApplication.jsp'
};

// Track the currently active menu item
let currentActiveMenu = null;

// ========== PAGE STATE PERSISTENCE ==========

// Save current page state whenever iframe changes
function loadPage(page, title, breadcrumbPath, anchorEl) {
    // Save to sessionStorage before loading
    sessionStorage.setItem('currentPage', page);
    sessionStorage.setItem('currentBreadcrumb', breadcrumbPath);
    sessionStorage.setItem('activeMenu', title); // Save active menu
    
    document.getElementById("contentFrame").src = page;
    updateBreadcrumb(breadcrumbPath);
    
    // Update active menu
    document.querySelectorAll(".menu li").forEach(li => li.classList.remove("active"));
    if (anchorEl && anchorEl.closest) {
        const menuItem = anchorEl.closest('li');
        menuItem.classList.add("active");
        currentActiveMenu = menuItem;
    }
}

function navigateToBreadcrumb(page, title, path) {
    // Save state
    sessionStorage.setItem('currentPage', page);
    sessionStorage.setItem('currentBreadcrumb', path);
    
    document.getElementById("contentFrame").src = page;
    updateBreadcrumb(path);
    // DON'T update active menu here - keep current selection
}

// ========== BREADCRUMB FUNCTIONS ==========

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

// Helper function to update active menu based on saved menu name
function updateActiveMenuFromSession() {
    const savedMenu = sessionStorage.getItem('activeMenu');
    if (savedMenu) {
        document.querySelectorAll(".menu li").forEach(li => {
            const link = li.querySelector('a');
            if (link && link.textContent.trim().includes(savedMenu)) {
                li.classList.add('active');
                currentActiveMenu = li;
            } else {
                li.classList.remove('active');
            }
        });
    }
}

// Allow child pages to update breadcrumb WITHOUT changing menu selection
window.updateParentBreadcrumb = function(path) {
    sessionStorage.setItem('currentBreadcrumb', path);
    updateBreadcrumb(path);
    // DON'T change active menu here
};

// ========== WORKING DATE FUNCTIONS ==========

function updateWorkingDate() {
    fetch('getWorkingDate.jsp')
        .then(response => response.json())
        .then(data => {
            const dateElement = document.getElementById("workingDate");
            if (data.error) {
                dateElement.innerText = "Working Date: Error - " + data.error;
                dateElement.style.color = "#e74c3c";
            } else {
                dateElement.innerText = "Working Date: " + data.workingDate;
                dateElement.style.color = "#fff";
                
                sessionStorage.setItem('workingDate', data.workingDate);
            }
        })
        .catch(error => {
            console.error('Error fetching working date:', error);
            document.getElementById("workingDate").innerText = "Working Date: Connection Error";
        });
}

// ========== RESTORE STATE ON LOAD ==========

window.onload = function () {
    const savedPage = sessionStorage.getItem('currentPage');
    const savedBreadcrumb = sessionStorage.getItem('currentBreadcrumb');

    if (savedPage && savedBreadcrumb) {
        // Reloading → load last opened page
        document.getElementById("contentFrame").src = savedPage;
        updateBreadcrumb(savedBreadcrumb);
        updateActiveMenuFromSession(); // Restore menu selection
    } else {
        // First-time opening website → load Dashboard
        document.getElementById("contentFrame").src = "dashboard.jsp";
        updateBreadcrumb("Dashboard");
        sessionStorage.setItem("currentPage", "dashboard.jsp");
        sessionStorage.setItem("currentBreadcrumb", "Dashboard");
        sessionStorage.setItem("activeMenu", "Dashboard");
        
        // Set Dashboard as active
        const dashboardItem = document.querySelector('.menu li[data-page="dashboard.jsp"]');
        if (dashboardItem) {
            dashboardItem.classList.add('active');
            currentActiveMenu = dashboardItem;
        }
    }

    // Update working date immediately and then every 30 seconds
    updateWorkingDate();
    setInterval(updateWorkingDate, 30000); // Refresh every 30 seconds
};

// ========== LOGOUT FUNCTIONS ==========

function showLogoutConfirmation(event) {
    event.preventDefault();
    document.getElementById("logoutModal").style.display = "block";
}

function closeLogoutModal() {
    document.getElementById("logoutModal").style.display = "none";
}

function confirmLogout() {
    // Clear session storage on logout
    sessionStorage.clear();
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

</script>

</body>
</html>