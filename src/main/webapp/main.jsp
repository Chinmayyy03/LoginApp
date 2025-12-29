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
    <style>
        /* ============================================
           FULLY RESPONSIVE LAYOUT - OPTION 2
           ============================================ */

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 0;
            overflow: hidden;
        }

        /* Sidebar - Responsive */
        .sidebar {
            width: 250px;
            position: fixed;
            left: 0;
            top: 0;
            height: 100vh;
            z-index: 200;
            transition: transform 0.3s ease;
        }

        /* Main Content - Responsive */
        .main-content {
            margin-left: 250px;
            width: calc(100% - 250px);
            height: 100vh;
            display: flex;
            flex-direction: column;
            transition: margin-left 0.3s ease, width 0.3s ease;
        }

        /* Header Container - Responsive */
        header {
            background: linear-gradient(90deg, #2c4a6f, #5a9bd5);
            padding: 8px 30px 6px 30px;
            color: white;
            display: flex;
            flex-direction: column;
            gap: 4px;
            position: fixed;
            width: calc(100% - 250px);
            top: 0;
            left: 250px;
            box-sizing: border-box;
            z-index: 100;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
            transition: width 0.3s ease, left 0.3s ease;
        }

        /* Title Row - Bank Left, Branch Right */
        .title-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2px;
            gap: 15px;
        }

        /* Bank Section with Icon */
        .bank-section {
            display: flex;
            align-items: center;
            gap: 10px;
            flex: 1;
            min-width: 0;
        }

        .bank-icon {
            width: 24px;
            height: 24px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            flex-shrink: 0;
        }

        .bank-title {
            font-size: clamp(14px, 1.2vw, 18px);
            font-weight: 700;
            letter-spacing: clamp(0.4px, 0.08vw, 1px);
            text-transform: uppercase;
            text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.3);
            margin: 0;
            padding: 0;
            line-height: 1.2;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        /* Branch Section */
        .branch-section {
            display: flex;
            align-items: center;
            background: rgba(255, 255, 255, 0.15);
            padding: 5px 15px;
            border-radius: 6px;
            border-left: 3px solid #4fc3f7;
            flex-shrink: 0;
        }

        .branch-name {
            font-size: clamp(12px, 0.95vw, 14px);
            font-weight: 600;
            white-space: nowrap;
        }

        /* Navigation Row */
        .nav-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 0;
            min-height: 26px;
            flex-wrap: wrap;
            gap: 8px;
        }

        /* Breadcrumb Navigation - Responsive */
        .breadcrumb-container {
            display: flex;
            align-items: center;
            gap: clamp(6px, 0.5vw, 8px);
            font-size: clamp(12px, 0.9vw, 14px);
            color: #ffffff;
            flex: 1 1 auto;
            min-width: 200px;
            flex-wrap: wrap;
        }

        .breadcrumb-item {
            display: flex;
            align-items: center;
            gap: clamp(6px, 0.5vw, 8px);
        }

        .breadcrumb-link {
            color: #ffffff;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            padding: 3px 8px;
            font-size: clamp(12px, 0.9vw, 14px);
            border-radius: 4px;
            background: rgba(255, 255, 255, 0.1);
            line-height: 1.3;
            white-space: nowrap;
        }

        .breadcrumb-link:hover {
            background: rgba(255, 255, 255, 0.25);
            transform: scale(1.05);
        }

        .breadcrumb-separator {
            color: #ffffff;
            font-weight: 600;
            user-select: none;
            font-size: clamp(14px, 1vw, 16px);
        }

        .breadcrumb-current {
            color: #ffffff;
            font-weight: 600;
            background: rgba(255, 255, 255, 0.15);
            padding: 3px 10px;
            border-radius: 4px;
            line-height: 1.3;
            font-size: clamp(12px, 0.9vw, 14px);
            white-space: nowrap;
        }

        /* Working Date - Responsive */
        #workingDate {
            color: #ffffff;
            font-size: clamp(12px, 0.9vw, 14px);
            font-weight: 500;
            padding: 3px 10px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 4px;
            white-space: nowrap;
            line-height: 1.3;
            flex-shrink: 0;
        }

        /* iframe - Fully Responsive */
        iframe {
            flex: 1;
            width: 100%;
            height: 100%;
            margin-top: 75px;
            border: none;
            overflow: auto;
        }

        /* Desktop - Large screens (1920px+) */
        @media (min-width: 1920px) {
            .bank-title {
                font-size: 20px;
                letter-spacing: 1.2px;
            }
            
            .branch-name {
                font-size: 15px;
            }
            
            .breadcrumb-link,
            .breadcrumb-current,
            #workingDate {
                font-size: 15px;
            }
        }

        /* Desktop - Medium screens (1440px - 1919px) */
        @media (min-width: 1440px) and (max-width: 1919px) {
            header {
                padding: 8px 25px 6px 25px;
            }
        }

        /* Laptop - Standard (1024px - 1439px) */
        @media (min-width: 1024px) and (max-width: 1439px) {
            header {
                padding: 7px 20px 5px 20px;
            }
            
            .nav-row {
                min-height: 24px;
            }
        }

        /* Tablet - Landscape (768px - 1023px) */
        @media (min-width: 768px) and (max-width: 1023px) {
            header {
                padding: 6px 15px 5px 15px;
            }
            
            .bank-title {
                font-size: 15px;
            }
            
            .branch-name {
                font-size: 12px;
            }
            
            .breadcrumb-container {
                min-width: 150px;
            }
            
            iframe {
                margin-top: 78px;
            }
        }

        /* Tablet - Portrait & Mobile (max-width: 767px) */
        @media (max-width: 767px) {
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
                z-index: 300;
            }
            
            .main-content {
                margin-left: 0;
                width: 100%;
                height: auto;
                min-height: 100vh;
            }
            
            header {
                width: 100%;
                left: 0;
                padding: 6px 15px 5px 15px;
                position: relative;
            }
            
            .title-row {
                flex-direction: column;
                align-items: flex-start;
                gap: 8px;
            }
            
            .bank-section {
                width: 100%;
            }
            
            .bank-title {
                white-space: normal;
                word-wrap: break-word;
            }
            
            .branch-section {
                align-self: flex-start;
            }
            
            .nav-row {
                flex-direction: column;
                align-items: flex-start;
                gap: 6px;
            }
            
            .breadcrumb-container {
                width: 100%;
                min-width: auto;
            }
            
            #workingDate {
                align-self: flex-start;
            }
            
            iframe {
                position: relative;
                margin-top: 0;
                width: 100%;
                min-height: calc(100vh - 250px);
                height: auto;
            }
        }

        /* Mobile - Small (360px - 480px) */
        @media (max-width: 480px) {
            header {
                padding: 5px 10px 4px 10px;
                gap: 3px;
            }
            
            .bank-icon {
                width: 20px;
                height: 20px;
                font-size: 12px;
            }
            
            .bank-title {
                font-size: 11px;
                letter-spacing: 0.3px;
            }
            
            .branch-section {
                padding: 4px 10px;
            }
            
            .branch-name {
                font-size: 11px;
            }
            
            .breadcrumb-link,
            .breadcrumb-current,
            #workingDate {
                font-size: 11px;
                padding: 2px 6px;
            }
            
            .breadcrumb-separator {
                font-size: 13px;
            }
            
            iframe {
                min-height: calc(100vh - 280px);
            }
        }

        /* Mobile - Extra Small (max-width: 359px) */
        @media (max-width: 359px) {
            .bank-title {
                font-size: 10px;
            }
            
            .branch-name {
                font-size: 10px;
            }
            
            .breadcrumb-link,
            .breadcrumb-current,
            #workingDate {
                font-size: 10px;
                padding: 2px 5px;
            }
            
            iframe {
                min-height: calc(100vh - 300px);
            }
        }

        /* Landscape orientation adjustments */
        @media (max-height: 600px) and (orientation: landscape) {
            iframe {
                min-height: 400px;
            }
        }

        /* High DPI screens */
        @media (-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi) {
            .bank-title,
            .breadcrumb-link,
            #workingDate {
                -webkit-font-smoothing: antialiased;
                -moz-osx-font-smoothing: grayscale;
            }
        }
    </style>
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
    const savedPage = sessionStorage.getItem('currentPage');
    const savedBreadcrumb = sessionStorage.getItem('currentBreadcrumb');

    if (savedPage && savedBreadcrumb) {
        document.getElementById("contentFrame").src = savedPage;
        updateBreadcrumb(savedBreadcrumb);
        updateActiveMenuFromSession();
    } else {
        document.getElementById("contentFrame").src = "dashboard.jsp";
        updateBreadcrumb("Dashboard");
        sessionStorage.setItem("currentPage", "dashboard.jsp");
        sessionStorage.setItem("currentBreadcrumb", "Dashboard");
        sessionStorage.setItem("activeMenu", "Dashboard");
        
        const dashboardItem = document.querySelector('.menu li[data-page="dashboard.jsp"]');
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

</body>
</html>