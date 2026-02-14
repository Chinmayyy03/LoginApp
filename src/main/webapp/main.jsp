<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String userId = (String) session.getAttribute("userId");
    String branchCode = (String) session.getAttribute("branchCode");
    String branchName = "";
    String userName = userId; // fallback to USER_ID if NAME is not found

    if (userId == null || branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Fetch branch name
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT NAME FROM HEADOFFICE.BRANCH WHERE BRANCH_CODE=?")) {
        ps.setString(1, branchCode);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            branchName = rs.getString("NAME");
        }
    } catch (Exception e) {
        branchName = "Unknown Branch";
    }

    // Fetch user's full name from USERREGISTER
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT NAME FROM ACL.USERREGISTER WHERE USER_ID=?")) {
        ps.setString(1, userId);
        ResultSet rs = ps.executeQuery();
        if (rs.next() && rs.getString("NAME") != null) {
            userName = rs.getString("NAME");
        }
    } catch (Exception e) {
        // userName already defaults to userId as fallback
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Main Dashboard</title>
    <link rel="stylesheet" href="css/main.css">
    <script src="js/breadcrumb-auto.js"></script>
</head>
<body>

<div class="sidebar">
    <div class="profile-section" style="cursor: pointer;" onclick="openUserProfile()">
        <img src="images/user.png" alt="Profile" class="profile-pic">
        <div class="user-name"><%= userName.toUpperCase() %></div>
    </div>

    <ul class="menu">
    <!-- Dashboard -->
	<li class="active" data-page="Dashboard/dashboard.jsp">
	    <a href="#" onclick="loadPage('Dashboard/dashboard.jsp', 'Dashboard', this); return false;">
	        <img src="images/right-arrow.png" width="18" height="18" alt="">
	        <span>Dashboard</span>
	    </a>
	</li>

	<!-- Add Customer -->
	<li data-page="addCustomer.jsp">
	    <a href="#" onclick="loadPage('addCustomer.jsp', 'Add Customer', this); return false;">
	        <img src="images/right-arrow.png" width="18" height="18" alt="">
	        <span>Add Customer</span>
	    </a>
	</li>

	<!-- Authorization -->
	<li data-page="Authorization/authorizationPending.jsp">
	    <a href="#" onclick="loadPage('Authorization/authorizationPending.jsp', 'Authorization', this); return false;">
	        <img src="images/right-arrow.png" width="18" height="18" alt="">
	        <span>Authorization</span>
	    </a>
	</li>

	<!-- Open Account -->
	<li data-page="newApplication.jsp">
	    <a href="#" onclick="loadPage('newApplication.jsp', 'Open Account', this); return false;">
	        <img src="images/right-arrow.png" width="18" height="18" alt="">
	        <span>Open Account</span>
	    </a>
	</li>

	<!-- Master -->
	<li data-page="Master/masters.jsp">
	    <a href="#" onclick="loadPage('Master/masters.jsp', 'Master', this); return false;">
	        <img src="images/right-arrow.png" width="18" height="18" alt="">
	        <span>Master</span>
	    </a>
	</li>

	<!-- View -->
	<li data-page="View/view.jsp">
	    <a href="#" onclick="loadPage('View/view.jsp', 'View', this); return false;">
	        <img src="images/right-arrow.png" width="18" height="18" alt="">
	        <span>View</span>
	    </a>
	</li>

	<!-- Transactions -->
	<li data-page="Transactions/transactions.jsp">
	    <a href="#" onclick="loadPage('Transactions/transactions.jsp', 'Transactions', this); return false;">
	        <img src="images/right-arrow.png" width="18" height="18" alt="">
	        <span>Transactions</span>
	    </a>
	</li>
	
	<!-- Reports -->
	<li data-page="Reports/reports.jsp">
	    <a href="#" onclick="loadPage('Reports/reports.jsp', 'Reports', this); return false;">
	        <img src="images/right-arrow.png" width="18" height="18" alt="">
	        <span>Reports</span>
	    </a>
	</li>

	<!-- Pigmy -->
	<li data-page="Pigmy/pigmy.jsp">
	    <a href="#" onclick="loadPage('Pigmy/pigmy.jsp', 'Pigmy', this); return false;">
	        <img src="images/right-arrow.png" width="18" height="18" alt="">
	        <span>Pigmy</span>
	    </a>
	</li>
	
	<!-- Utility -->
	<li data-page="Utility/utility.jsp">
	    <a href="#" onclick="loadPage('Utility/utility.jsp', 'Utility', this); return false;">
	        <img src="images/right-arrow.png" width="18" height="18" alt="">
	        <span>Utility</span>
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

// Track the currently active menu item
let currentActiveMenu = null;

// ========== USER PROFILE FUNCTION ==========

function openUserProfile() {
    loadPage('userProfile.jsp', 'User Profile', null);
}

// ========== PAGE STATE PERSISTENCE ==========
// This stack tracks the navigation history automatically
const navigationStack = [];

function loadPage(page, title, anchorEl) {
    let breadcrumbPath = buildBreadcrumbPath(page);
    
    // Add to navigation stack
    addToNavigationStack(page, breadcrumbPath);
    
    sessionStorage.setItem('currentPage', page);
    sessionStorage.setItem('currentBreadcrumb', breadcrumbPath);
    sessionStorage.setItem('activeMenu', title);
    
    document.getElementById("contentFrame").src = page;
    updateBreadcrumb(breadcrumbPath);
    
    document.querySelectorAll(".menu li").forEach(li => li.classList.remove("active"));
    if (anchorEl && anchorEl.closest) {
        const menuItem = anchorEl.closest('li');
        menuItem.classList.add("active");
        currentActiveMenu = menuItem;
    }
}

//Load navigation stack from session
function loadNavigationStack() {
    const stored = sessionStorage.getItem('navigationStack');
    if (stored) {
        const parsed = JSON.parse(stored);
        navigationStack.push(...parsed);
    }
}

function addToNavigationStack(page, breadcrumbPath) {
    const entry = { page, breadcrumbPath };
    
    // Remove any entries after current position (when navigating back then forward)
    const currentIndex = navigationStack.findIndex(e => e.breadcrumbPath === breadcrumbPath);
    if (currentIndex !== -1) {
        navigationStack.splice(currentIndex + 1);
    } else {
        navigationStack.push(entry);
    }
    
    // Persist to sessionStorage
    sessionStorage.setItem('navigationStack', JSON.stringify(navigationStack));
}

function navigateToBreadcrumb(page, title) {
    // ✅ Auto-build breadcrumb
    let path = buildBreadcrumbPath(page);
    
    sessionStorage.setItem('currentPage', page);
    sessionStorage.setItem('currentBreadcrumb', path);
    
    document.getElementById("contentFrame").src = page;
    updateBreadcrumb(path);
}

// ========== BREADCRUMB FUNCTIONS ==========

// --- Optimized breadcrumb updater (replace the existing updateBreadcrumb) ---

// Simple debounce to coalesce rapid calls (100ms)
let _breadcrumbTimeout = null;
let _currentBreadcrumbPath = null;

function updateBreadcrumb(path) {
    // If path is same as current, skip (fast path)
    if (path === _currentBreadcrumbPath) return;

    // Debounce multiple rapid calls
    if (_breadcrumbTimeout) {
        clearTimeout(_breadcrumbTimeout);
    }
    _breadcrumbTimeout = setTimeout(() => {
        _breadcrumbTimeout = null;
        _doUpdateBreadcrumb(path);
    }, 100);
}

function _doUpdateBreadcrumb(path) {
    _currentBreadcrumbPath = path;

    const breadcrumbNav = document.getElementById("breadcrumbNav");
    if (!breadcrumbNav) return;

    const parts = path.split(' > ');
    const breadcrumbParts = [];

    for (let index = 0; index < parts.length; index++) {
        const part = parts[index];
        if (index === parts.length - 1) {
            breadcrumbParts.push('<span class="breadcrumb-current">' + escapeHtml(part) + '</span>');
        } else {
            breadcrumbParts.push(
                '<div class="breadcrumb-item">' +
                '<a href="#" class="breadcrumb-link" onclick="navigateToBreadcrumbByIndex(' + index + '); return false;">' +
                escapeHtml(part) + '</a><span class="breadcrumb-separator">></span></div>'
            );
        }
    }

    breadcrumbNav.innerHTML = breadcrumbParts.join('');
    sessionStorage.setItem('currentBreadcrumb', path);
}

// small helper to avoid XSS when injecting text
function escapeHtml(text) {
    return String(text)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
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
    checkSession();
    loadNavigationStack(); // Load navigation history
    
    const savedPage = sessionStorage.getItem('currentPage');
    const savedBreadcrumb = sessionStorage.getItem('currentBreadcrumb');

    if (savedPage && savedBreadcrumb) {
        document.getElementById("contentFrame").src = savedPage;
        updateBreadcrumb(savedBreadcrumb);
        updateActiveMenuFromSession();
    } else {
        const defaultPage = "Dashboard/dashboard.jsp";
        const defaultBreadcrumb = "Dashboard";
        
        document.getElementById("contentFrame").src = defaultPage;
        updateBreadcrumb(defaultBreadcrumb);
        sessionStorage.setItem("currentPage", defaultPage);
        sessionStorage.setItem("currentBreadcrumb", defaultBreadcrumb);
        sessionStorage.setItem("activeMenu", "Dashboard");
        
        addToNavigationStack(defaultPage, defaultBreadcrumb);
        
        const dashboardItem = document.querySelector('.menu li[data-page="Dashboard/dashboard.jsp"]');
        if (dashboardItem) {
            dashboardItem.classList.add('active');
            currentActiveMenu = dashboardItem;
        }
    }

    updateWorkingDateAndBankName();
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

function navigateToBreadcrumbByIndex(index) {
    const currentPath = sessionStorage.getItem('currentBreadcrumb');
    if (!currentPath) return;
    
    const currentParts = currentPath.split(' > ');
    const targetPath = currentParts.slice(0, index + 1).join(' > ');
    
    // Search navigation stack for matching breadcrumb
    const navStack = JSON.parse(sessionStorage.getItem('navigationStack') || '[]');
    
    // Find the most recent entry with this breadcrumb path
    for (let i = navStack.length - 1; i >= 0; i--) {
        if (navStack[i].breadcrumbPath === targetPath) {
            const targetPage = navStack[i].page;
            document.getElementById("contentFrame").src = targetPage;
            updateBreadcrumb(targetPath);
            sessionStorage.setItem('currentPage', targetPage);
            return;
        }
    }
    
    console.warn('No navigation history found for:', targetPath);
}

window.updateParentBreadcrumb = function(path, currentPage) {
    // If currentPage is provided, add it to navigation stack
    if (currentPage) {
        addToNavigationStack(currentPage, path);
    }
    sessionStorage.setItem('currentBreadcrumb', path);
    updateBreadcrumb(path);
};

</script>
</body>
</html>
