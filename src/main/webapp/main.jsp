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
    
    // Handle AJAX password change request
    if ("changePassword".equals(request.getParameter("action"))) {
        String newPassword = request.getParameter("newPassword");
        
        if (newPassword != null && !newPassword.trim().isEmpty()) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            
            try {
                conn = DBConnection.getConnection();
                
                // Update password and set CREATED_BY to USER_ID (so they match and popup won't show again)
                String sql = "UPDATE ACL.USERREGISTER SET PASSWD = acl.toolkit.encrypt(?), CREATED_BY = USER_ID WHERE USER_ID = ? AND BRANCH_CODE = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, newPassword);
                pstmt.setString(2, userId);
                pstmt.setString(3, branchCode);
                
                int rowsUpdated = pstmt.executeUpdate();
                
                response.setContentType("application/json");
                if (rowsUpdated > 0) {
                    out.print("{\"success\":true, \"message\":\"Password changed successfully!\"}");
                } else {
                    out.print("{\"success\":false, \"message\":\"Failed to update password.\"}");
                }
                
            } catch (Exception e) {
                response.setContentType("application/json");
                out.print("{\"success\":false, \"message\":\"Error: " + e.getMessage() + "\"}");
            } finally {
                try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
                try { if (conn != null) conn.close(); } catch (Exception ignored) {}
            }
            return;
        }
    }
    
    // Check if password change is needed (USER_ID != CREATED_BY)
    boolean needsPasswordChange = false;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        String sql = "SELECT USER_ID, CREATED_BY FROM ACL.USERREGISTER WHERE USER_ID=? AND BRANCH_CODE=?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        pstmt.setString(2, branchCode);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            String createdBy = rs.getString("CREATED_BY");
            // Show popup only if CREATED_BY is different from USER_ID
            if (createdBy != null && !userId.equals(createdBy)) {
                needsPasswordChange = true;
            }
        }
    } catch (Exception e) {
        System.err.println("Error checking password change requirement: " + e.getMessage());
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
    }

    // Fetch branch name
    try (Connection connBranch = DBConnection.getConnection();
         PreparedStatement ps = connBranch.prepareStatement("SELECT NAME FROM HEADOFFICE.BRANCH WHERE BRANCH_CODE=?")) {
        ps.setString(1, branchCode);
        ResultSet rsBranch = ps.executeQuery();
        if (rsBranch.next()) {
            branchName = rsBranch.getString("NAME");
        }
    } catch (Exception e) {
        branchName = "Unknown Branch";
    }

    // Fetch user's full name from USERREGISTER
    try (Connection connUser = DBConnection.getConnection();
         PreparedStatement ps = connUser.prepareStatement("SELECT NAME FROM ACL.USERREGISTER WHERE USER_ID=?")) {
        ps.setString(1, userId);
        ResultSet rsUser = ps.executeQuery();
        if (rsUser.next() && rsUser.getString("NAME") != null) {
            userName = rsUser.getString("NAME");
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
    <style>
        /* Password Change Modal Styles */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.75);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            z-index: 10000;
        }
        
        .modal-overlay.active {
            display: flex;
            align-items: center;
            justify-content: center;
            animation: fadeIn 0.3s ease;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        .password-change-modal {
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
            width: 90%;
            max-width: 450px;
            overflow: hidden;
            animation: slideIn 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        
        @keyframes slideIn {
            from {
                transform: translateY(-50px) scale(0.9);
                opacity: 0;
            }
            to {
                transform: translateY(0) scale(1);
                opacity: 1;
            }
        }
        
        .modal-header-custom {
            background: linear-gradient(135deg, #5fa3d0 0%, #4a90e2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .modal-header-custom h3 {
            margin: 0;
            font-size: 24px;
            font-weight: 600;
        }
        
        .modal-header-custom p {
            margin: 10px 0 0 0;
            font-size: 14px;
            opacity: 0.95;
        }
        
        .modal-body-custom {
            padding: 35px 30px;
        }
        
        .form-group-custom {
            margin-bottom: 22px;
        }
        
        .form-group-custom label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #2c3e50;
            font-size: 14px;
        }
        
        .password-input-wrapper {
            position: relative;
        }
        
        .form-group-custom input {
            width: 100%;
            padding: 14px 50px 14px 16px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 15px;
            transition: all 0.3s ease;
            box-sizing: border-box;
            font-family: inherit;
        }
        
        .form-group-custom input:focus {
            outline: none;
            border-color: #4a90e2;
            box-shadow: 0 0 0 4px rgba(74, 144, 226, 0.15);
        }
        
        .eye-icon-modal {
            position: absolute;
            right: 16px;
            top: 50%;
            transform: translateY(-50%);
            width: 22px;
            height: 22px;
            cursor: pointer;
            opacity: 0.5;
            transition: opacity 0.2s;
        }
        
        .eye-icon-modal:hover {
            opacity: 0.8;
        }
        
        .btn-change-password {
            width: 100%;
            padding: 16px;
            background: linear-gradient(135deg, #5fa3d0 0%, #4a90e2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 10px;
        }
        
        .btn-change-password:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(74, 144, 226, 0.4);
        }
        
        .btn-change-password:disabled {
            background: linear-gradient(135deg, #ccc 0%, #bbb 100%);
            cursor: not-allowed;
            transform: none;
        }
        
        .alert-custom {
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            display: none;
            font-weight: 500;
        }
        
        .alert-error-custom {
            background-color: #fee;
            border: 2px solid #fcc;
            color: #d32f2f;
        }
        
        /* Success Message - Simple Style */
        .success-message-container {
            display: none;
            text-align: center;
            padding: 40px 30px;
        }
        
        .success-message-container.active {
            display: block;
        }
        
        /* Simple Green Circle with Checkmark */
        .success-checkmark {
            width: 80px;
            height: 80px;
            margin: 0 auto 25px;
            background: #22c55e;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .success-checkmark::before {
            content: "✓";
            font-size: 50px;
            font-weight: bold;
            color: white;
            line-height: 1;
        }
        
        .success-title {
            font-size: 22px;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 30px;
        }
        
        .btn-ok {
            padding: 12px 50px;
            background: #22c55e;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .btn-ok:hover {
            background: #16a34a;
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(34, 197, 94, 0.3);
        }
    </style>
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

<!-- Password Change Modal -->
<div class="modal-overlay" id="modalOverlay">
    <div class="password-change-modal" id="passwordChangeModal">
        <div class="modal-header-custom">
            <h3>Change Your Password!</h3>
            <p>For security reasons, please set a new password</p>
        </div>
        
        <div class="modal-body-custom">
            <div id="passwordForm">
                <div class="alert-custom alert-error-custom" id="errorAlert"></div>
                
                <form id="changePasswordForm">
                    <div class="form-group-custom">
                        <label for="newPassword">New Password</label>
                        <div class="password-input-wrapper">
                            <input type="password" id="newPassword" name="newPassword" 
                                   placeholder="Enter your new password" required autocomplete="new-password">
                            <img src="images/eye.png" class="eye-icon-modal" id="eyeIconNew" 
                                 alt="Show" onclick="togglePasswordVisibility('newPassword', 'eyeIconNew')" 
                                 style="display:none;">
                        </div>
                    </div>
                    
                    <div class="form-group-custom">
                        <label for="confirmPassword">Confirm New Password</label>
                        <div class="password-input-wrapper">
                            <input type="password" id="confirmPassword" name="confirmPassword" 
                                   placeholder="Re-enter your new password" required autocomplete="new-password">
                            <img src="images/eye.png" class="eye-icon-modal" id="eyeIconConfirm" 
                                 alt="Show" onclick="togglePasswordVisibility('confirmPassword', 'eyeIconConfirm')"
                                 style="display:none;">
                        </div>
                    </div>
                    
                    <button type="submit" class="btn-change-password" id="submitBtn">
                        Change Password
                    </button>
                </form>
            </div>
            
            <!-- Success Message - Simple Style with Clean Checkmark -->
            <div class="success-message-container" id="successMessage">
                <div class="success-checkmark"></div>
                <div class="success-title">Password changed successfully</div>
                <button class="btn-ok" onclick="closeSuccessModal()">OK</button>
            </div>
        </div>
    </div>
</div>

<script>
//========== PASSWORD CHANGE MODAL LOGIC ==========

<% if (needsPasswordChange) { %>
// Show password change modal on page load
window.addEventListener('DOMContentLoaded', function() {
    setTimeout(function() {
        document.getElementById('modalOverlay').classList.add('active');
    }, 500);
});
<% } %>

// Close success modal
function closeSuccessModal() {
    document.getElementById('modalOverlay').classList.remove('active');
}

// Show/hide eye icon based on input
document.addEventListener('DOMContentLoaded', function() {
    const newPasswordInput = document.getElementById('newPassword');
    const confirmPasswordInput = document.getElementById('confirmPassword');
    const eyeIconNew = document.getElementById('eyeIconNew');
    const eyeIconConfirm = document.getElementById('eyeIconConfirm');
    
    if (newPasswordInput) {
        newPasswordInput.addEventListener('input', function() {
            eyeIconNew.style.display = this.value.length > 0 ? 'block' : 'none';
        });
    }
    
    if (confirmPasswordInput) {
        confirmPasswordInput.addEventListener('input', function() {
            eyeIconConfirm.style.display = this.value.length > 0 ? 'block' : 'none';
        });
    }
});

// Toggle password visibility
function togglePasswordVisibility(inputId, iconId) {
    const input = document.getElementById(inputId);
    const icon = document.getElementById(iconId);
    
    if (input.type === "password") {
        input.type = "text";
        icon.src = "images/eye-hide.png";
    } else {
        input.type = "password";
        icon.src = "images/eye.png";
    }
}

// Handle password change form submission
document.getElementById('changePasswordForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const newPassword = document.getElementById('newPassword').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    const errorAlert = document.getElementById('errorAlert');
    const submitBtn = document.getElementById('submitBtn');
    
    // Clear previous errors
    errorAlert.style.display = 'none';
    errorAlert.textContent = '';
    
    // Validate passwords match
    if (newPassword !== confirmPassword) {
        errorAlert.textContent = '❌ Passwords do not match!';
        errorAlert.style.display = 'block';
        return;
    }
    
    // Validate password is not empty
    if (newPassword.trim() === '') {
        errorAlert.textContent = '❌ Password cannot be empty!';
        errorAlert.style.display = 'block';
        return;
    }
    
    // Disable submit button
    submitBtn.disabled = true;
    submitBtn.textContent = 'Changing Password...';
    
    // Send AJAX request
    const xhr = new XMLHttpRequest();
    xhr.open('POST', 'main.jsp?action=changePassword', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    
    xhr.onload = function() {
        if (xhr.status === 200) {
            try {
                const response = JSON.parse(xhr.responseText);
                
                if (response.success) {
                    // Show simple success message
                    document.getElementById('passwordForm').style.display = 'none';
                    document.getElementById('successMessage').classList.add('active');
                } else {
                    errorAlert.textContent = '❌ ' + response.message;
                    errorAlert.style.display = 'block';
                    submitBtn.disabled = false;
                    submitBtn.textContent = 'Change Password';
                }
            } catch (e) {
                errorAlert.textContent = '❌ An error occurred. Please try again.';
                errorAlert.style.display = 'block';
                submitBtn.disabled = false;
                submitBtn.textContent = 'Change Password';
            }
        } else {
            errorAlert.textContent = '❌ Server error. Please try again.';
            errorAlert.style.display = 'block';
            submitBtn.disabled = false;
            submitBtn.textContent = 'Change Password';
        }
    };
    
    xhr.onerror = function() {
        errorAlert.textContent = '❌ Network error. Please check your connection.';
        errorAlert.style.display = 'block';
        submitBtn.disabled = false;
        submitBtn.textContent = 'Change Password';
    };
    
    xhr.send('newPassword=' + encodeURIComponent(newPassword));
});

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
