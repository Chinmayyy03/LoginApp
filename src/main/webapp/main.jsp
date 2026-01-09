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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Main Dashboard</title>
    <link rel="stylesheet" href="css/main.css">
</head>
<body>

<div class="sidebar">
    <div class="profile-section">
        <img src="images/user.png" alt="Profile" class="profile-pic">
        <div class="user-name"><%= userId.toUpperCase() %></div>
    </div>

    <ul class="menu">
    <li class="active" data-page="Dashboard/dashboard.jsp">
        <a href="#" onclick="loadPage('Dashboard/dashboard.jsp', 'Dashboard', 'Dashboard', this); return false;">
            <img src="images/right-arrow.png" width="18" height="18" alt="">
            <span>Dashboard</span>
        </a>
    </li>

    <li data-page="addCustomer.jsp">
        <a href="#" onclick="loadPage('addCustomer.jsp', 'Add Customer', 'Add Customer', this); return false;">
            <img src="images/right-arrow.png" width="18" height="18" alt="">
            <span>Add Customer</span>
        </a>
    </li>
    
    <li data-page="authorizationPending.jsp">
        <a href="#" onclick="loadPage('authorizationPending.jsp', 'Authorization', 'Authorization', this); return false;">
            <img src="images/right-arrow.png" width="18" height="18" alt="">
            <span>Authorization</span>
        </a>
    </li>
    
    <li data-page="newApplication.jsp">
        <a href="#" onclick="loadPage('newApplication.jsp', 'Open Account', 'Open Account', this); return false;">
            <img src="images/right-arrow.png" width="18" height="18" alt="">
            <span>Open Account</span>
        </a>
    </li>
    
    <li data-page="Master/masters.jsp">
        <a href="#" onclick="loadPage('masters', 'Masters', 'Masters', this); return false;">
            <img src="images/right-arrow.png" width="18" height="18" alt="">
            <span>Master</span>
        </a>
    </li>
    
    <li data-page="View/view.jsp">
        <a href="#" onclick="loadPage('View/view.jsp', 'View', 'View', this); return false;">
            <img src="images/right-arrow.png" width="18" height="18" alt="">
            <span>View</span>
        </a>
    </li>
    
    <li data-page="Transactions/transactions.jsp">
        <a href="#" onclick="loadPage('Transactions/transactions.jsp', 'Transactions', 'Transactions', this); return false;">
            <img src="images/right-arrow.png" width="18" height="18" alt="">
            <span>Transactions</span>
        </a>
    </li>
</ul>

    <div class="logout">
        <a href="#" onclick="showLogoutConfirmation(event)">𓉘➜ Log Out</a>
    </div>
</div>

<div class="main-content">
    <header>
        <!-- Title Row: Bank Name (Left) + Branch Name (Right) -->
        <div class="title-row">
            <!-- Bank Section with Icon -->
            <div class="bank-section">
                <div class="bank-icon">🏦</div>
                <h1 class="bank-title" id="bankNameTitle">
                    Loading Bank Name...
                </h1>
            </div>
            
            <!-- Branch Section (Without "BRANCH" text) -->
            <div class="branch-section">
                <div class="branch-name" id="branchName">
                    Loading...
                </div>
            </div>
        </div>
        
        <!-- Navigation Row: Breadcrumb + Working Date -->
        <div class="nav-row">
            <!-- Breadcrumb Navigation -->
            <div id="breadcrumbNav" class="breadcrumb-container"></div>
            
            <!-- Working Date -->
            <div id="workingDate">Loading...</div>
        </div>
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
//========== SESSION MONITORING ==========

function checkSession() {
    fetch('sessionCheck.jsp')
        .then(response => response.json())
        .then(data => {
            if (!data.sessionValid) {
                // Session expired - redirect entire page to login
                sessionStorage.clear();
                window.top.location.href = 'login.jsp';
            }
        })
        .catch(error => {
            console.error('Session check error:', error);
        });
}

// Check session every 30 seconds
setInterval(checkSession, 30000);

// Check session on page visibility change (when user returns to tab)
document.addEventListener('visibilitychange', function() {
    if (!document.hidden) {
        checkSession();
    }
});

// Check session on any user interaction
['click', 'keydown', 'mousemove'].forEach(event => {
    document.addEventListener(event, function() {
        if (!window.lastSessionCheck || Date.now() - window.lastSessionCheck > 10000) {
            window.lastSessionCheck = Date.now();
            checkSession();
        }
    }, { passive: true, once: false });
});

//========== PAGE MAPPING ==========
const pageMap = {
		'Dashboard': 'Dashboard/dashboard.jsp',
	    'Add Customer': 'addCustomer.jsp',
	    'Total Customers': 'Dashboard/totalCustomers.jsp',
	    'Authorization': 'authorizationPending.jsp',
	    'Customer List': 'authorizationPendingCustomers.jsp',
	    'Application List': 'authorizationPendingApplications.jsp',
	    'Loan Details': 'loanDetails.jsp',
	    'Open Account': 'newApplication.jsp',
	    'Masters': 'Master/masters.jsp',
	    'View': 'View/view.jsp',
	    'Total Accounts': 'View/totalAccounts.jsp',
	    'Transactions': 'Transactions/transactions.jsp',
	    'A Type member': 'Dashboard/aTypeMember.jsp',
	    'B Type member': 'Dashboard/bTypeMember.jsp',
	    'OTHER': 'Dashboard/otherMember.jsp',
	    'View Details': 'Dashboard/viewCustomer.jsp'
};

// Track the currently active menu item
let currentActiveMenu = null;

// ========== PAGE STATE PERSISTENCE ==========

function loadPage(page, title, breadcrumbPath, anchorEl) {
    sessionStorage.setItem('currentPage', page);
    sessionStorage.setItem('currentBreadcrumb', breadcrumbPath);
    sessionStorage.setItem('activeMenu', title);
    
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
    sessionStorage.setItem('currentPage', page);
    sessionStorage.setItem('currentBreadcrumb', path);
    
    document.getElementById("contentFrame").src = page;
    updateBreadcrumb(path);
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
            const pageName = pageMap[part] || 'Dashboard/dashboard.jsp';
            const previousPath = parts.slice(0, index + 1).join(' > ');
            
            breadcrumbHTML += '<div class="breadcrumb-item">' +
                '<a href="#" class="breadcrumb-link" onclick="navigateToBreadcrumb(\'' + 
                pageName + '\', \'' + part + '\', \'' + previousPath + '\'); return false;">' +
                part + '</a><span class="breadcrumb-separator">></span></div>';
        }
    });
    
    breadcrumbNav.innerHTML = breadcrumbHTML;
}

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

window.updateParentBreadcrumb = function(path) {
    sessionStorage.setItem('currentBreadcrumb', path);
    updateBreadcrumb(path);
};

// ========== WORKING DATE, BANK NAME & BRANCH NAME FUNCTIONS ==========

function updateWorkingDateAndBankName() {
    fetch('getWorkingDate.jsp')
        .then(response => response.json())
        .then(data => {
            const dateElement = document.getElementById("workingDate");
            const bankNameElement = document.getElementById("bankNameTitle");
            const branchNameElement = document.getElementById("branchName");
            
            if (data.error) {
                dateElement.innerText = "Error: " + data.error;
                dateElement.style.color = "#ffcccc";
                bankNameElement.innerText = "Error Loading Bank Name";
                branchNameElement.innerText = "Error";
            } else {
                // Update Working Date
                dateElement.innerText = "Working Date: " + data.workingDate;
                sessionStorage.setItem('workingDate', data.workingDate);
                
                // Update Bank Name
                if (data.bankName) {
                    bankNameElement.innerText = data.bankName.toUpperCase();
                    sessionStorage.setItem('bankName', data.bankName);
                    sessionStorage.setItem('bankCode', data.bankCode);
                }
                
                // Update Branch Name (without "BRANCH:" prefix)
                if (data.branchName) {
                    branchNameElement.innerText = data.branchName.toUpperCase();
                    sessionStorage.setItem('branchName', data.branchName);
                    sessionStorage.setItem('branchCode', data.branchCode);
                }
            }
        })
        .catch(error => {
            console.error('Error fetching working date and bank name:', error);
            document.getElementById("workingDate").innerText = "Connection Error";
            document.getElementById("bankNameTitle").innerText = "Connection Error";
            document.getElementById("branchName").innerText = "Error";
        });
}

// ========== RESTORE STATE ON LOAD ==========

window.onload = function () {
    // Initial session check
    checkSession();
    
    const savedPage = sessionStorage.getItem('currentPage');
    const savedBreadcrumb = sessionStorage.getItem('currentBreadcrumb');

    if (savedPage && savedBreadcrumb) {
        document.getElementById("contentFrame").src = savedPage;
        updateBreadcrumb(savedBreadcrumb);
        updateActiveMenuFromSession();
    } else {
        document.getElementById("contentFrame").src = "Dashboard/dashboard.jsp";
        updateBreadcrumb("Dashboard");
        sessionStorage.setItem("currentPage", "Dashboard/dashboard.jsp");
        sessionStorage.setItem("currentBreadcrumb", "Dashboard");
        sessionStorage.setItem("activeMenu", "Dashboard");
        
        const dashboardItem = document.querySelector('.menu li[data-page="Dashboard/dashboard.jsp"]');
        if (dashboardItem) {
            dashboardItem.classList.add('active');
            currentActiveMenu = dashboardItem;
        }
    }

    // Update working date, bank name AND branch name immediately
    updateWorkingDateAndBankName();
    
    // Refresh every 30 seconds
    setInterval(updateWorkingDateAndBankName, 30000);
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