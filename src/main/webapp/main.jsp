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
    <style>
        /* ============================================
           HEADER WITH BANK NAME & BREADCRUMB
           ============================================ */

        /* Header Container */
        header {
            background: linear-gradient(90deg, #1d314f, #5aa7f0);
            padding: 12px 30px 8px 30px;
            color: white;
            display: flex;
            flex-direction: column;
            gap: 8px;
            position: fixed;
            width: calc(100% - 250px);
            top: 0;
            box-sizing: border-box;
            z-index: 100;
            
        }

        /* Bank Name Title */
        .bank-title {
            font-size: 22px;
            font-weight: 700;
            letter-spacing: 1.2px;
            color: #ffffff;
            text-transform: uppercase;
            text-align: center;
            text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.3);
            margin: 0;
            padding: 0;
            line-height: 1.2;
        }

        /* Navigation Row (Breadcrumb + Date) */
        .nav-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 0;
            min-height: 30px;
        }

        /* Breadcrumb Navigation Styling */
        .breadcrumb-container {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 16px;
            color: #ffffff;
            flex: 1;
        }

        .breadcrumb-item {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .breadcrumb-link {
            color: #ffffff;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            padding: 4px 10px;
            font-size: 16px;
            border-radius: 4px;
            background: rgba(255, 255, 255, 0.1);
            line-height: 1.5;
        }

        .breadcrumb-link:hover {
            background: rgba(255, 255, 255, 0.25);
            transform: scale(1.05);
        }

        .breadcrumb-separator {
            color: #ffffff;
            font-weight: 600;
            user-select: none;
            font-size: 18px;
        }

        .breadcrumb-current {
            color: #ffffff;
            font-weight: 600;
            background: rgba(255, 255, 255, 0.15);
            padding: 4px 12px;
            border-radius: 4px;
            line-height: 1.5;
            font-size: 16px;
        }

        /* Working Date Styling */
        #workingDate {
            color: #ffffff;
            font-size: 16px;
            font-weight: 500;
            padding: 4px 12px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 4px;
            white-space: nowrap;
            line-height: 1.5;
        }

        /* Adjust iframe for new header height */
        iframe {
            flex: 1;
            margin-top: 85px;
            width: 100%;
            height: calc(100vh - 85px);
            border: none;
        }

        /* Mobile Responsive */
        @media (max-width: 1200px) {
            .bank-title {
                font-size: 18px;
                letter-spacing: 0.8px;
            }
            
            .breadcrumb-container {
                font-size: 14px;
            }
            
            .breadcrumb-link {
                padding: 3px 8px;
                font-size: 14px;
            }
            
            .breadcrumb-current {
                font-size: 14px;
                padding: 3px 10px;
            }
            
            #workingDate {
                font-size: 14px;
                padding: 3px 10px;
            }
        }

        @media (max-width: 768px) {
            header {
                padding: 10px 15px 8px 15px;
            }
            
            .bank-title {
                font-size: 15px;
                letter-spacing: 0.6px;
            }
            
            .nav-row {
                flex-direction: column;
                gap: 8px;
                align-items: flex-start;
            }
            
            .breadcrumb-container {
                font-size: 13px;
                flex-wrap: wrap;
            }
            
            .breadcrumb-link {
                padding: 2px 6px;
                font-size: 13px;
            }
            
            .breadcrumb-current {
                padding: 2px 8px;
                font-size: 13px;
            }
            
            #workingDate {
                font-size: 13px;
                padding: 2px 8px;
            }
            
            iframe {
                margin-top: 100px;
                height: calc(100vh - 100px);
            }
        }

        @media (max-width: 480px) {
            .bank-title {
                font-size: 12px;
                letter-spacing: 0.4px;
            }
            
            .breadcrumb-separator {
                font-size: 14px;
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
        <!-- Bank Name Title (Dynamically Loaded) -->
        <h1 class="bank-title" id="bankNameTitle">
            Loading Bank Name...
        </h1>
        
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

// ========== WORKING DATE & BANK NAME FUNCTIONS ==========

function updateWorkingDateAndBankName() {
    fetch('getWorkingDate.jsp')
        .then(response => response.json())
        .then(data => {
            const dateElement = document.getElementById("workingDate");
            const bankNameElement = document.getElementById("bankNameTitle");
            
            if (data.error) {
                dateElement.innerText = "Error: " + data.error;
                dateElement.style.color = "#ffcccc";
                bankNameElement.innerText = "Error Loading Bank Name";
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
            }
        })
        .catch(error => {
            console.error('Error fetching working date and bank name:', error);
            document.getElementById("workingDate").innerText = "Connection Error";
            document.getElementById("bankNameTitle").innerText = "Connection Error";
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

    // Update working date AND bank name immediately
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