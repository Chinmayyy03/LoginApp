<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, db.DBConnection" %>

<%
// Handle AJAX request for checking user ID
if ("checkUserId".equals(request.getParameter("action"))) {
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    // Prevent caching
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    
    String userId = request.getParameter("userId");
    
    if (userId == null || userId.trim().isEmpty()) {
        out.print("{\"exists\":false,\"message\":\"\"}");
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = DBConnection.getConnection();
        
        if (conn == null) {
            out.print("{\"error\":true,\"message\":\"Database connection failed\"}");
            return;
        }
        
        String sql = "SELECT USER_ID FROM ACL.USERREGISTER WHERE USER_ID = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId.trim());
        
        System.out.println("=== Checking User ID ===");
        System.out.println("Input User ID: " + userId.trim());
        
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            String foundUserId = rs.getString("USER_ID");
            System.out.println("FOUND - User ID exists: " + foundUserId);
            
            String message = "User ID '" + userId + "' already exists";
            String jsonMessage = message.replace("\\", "\\\\").replace("\"", "\\\"");
            out.print("{\"exists\":true,\"message\":\"" + jsonMessage + "\"}");
        } else {
            System.out.println("NOT FOUND - User ID is available");
            out.print("{\"exists\":false,\"message\":\"User ID is available\"}");
        }
        
    } catch (Exception e) {
        System.err.println("Error in checkUserId: " + e.getMessage());
        e.printStackTrace();
        
        String errorMsg = "Error: " + e.getMessage();
        String jsonError = errorMsg.replace("\\", "\\\\").replace("\"", "\\\"");
        out.print("{\"error\":true,\"message\":\"" + jsonError + "\"}");
        
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
    }
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>New User Creation</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/OpenAccount/css/savingAcc.css">

<style>
:root {
    --bg-lavender: #E6E6FA;
    --navy-blue: #303F9F;
    --border-color: #B8B8E6;
    --readonly-bg: #E0E0E0;
    --success-green: #28a745;
    --error-red: #dc3545;
    --info-blue: #2196F3;
}

body {
    font-family: Arial, sans-serif;
    background-color: var(--bg-lavender);
    margin: 0;
    padding: 20px;
}

.container { max-width: 1400px; margin: auto; }

h2 { text-align: center; color: var(--navy-blue); margin-bottom: 25px; }

fieldset {
    border: 1.5px solid var(--border-color);
    border-radius: 8px;
    margin-bottom: 22px;
    padding: 18px;
}

legend { color: var(--navy-blue); font-weight: bold; font-size: 15px; padding: 0 10px; background-color: var(--bg-lavender); }

.grid-row-1 {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 15px;
    margin-bottom: 15px;
    align-items: end;
}

.grid-row-2 {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 15px;
    align-items: end;
}

.form-group { width: 100%; }
.form-group label { display: block; font-size: 13px; font-weight: bold; color: var(--navy-blue); margin-bottom: 4px; }
.form-group input { width: 100%; padding: 7px; border: 1px solid var(--border-color); border-radius: 4px; font-size: 13px; box-sizing: border-box; }
input[readonly] { background-color: var(--readonly-bg); }

input.error { border-color: var(--error-red); }
input.success { border-color: var(--success-green); }

.input-row {
    display: flex !important;
    flex-direction: row !important;
    flex-wrap: nowrap !important;
    align-items: center !important;
    gap: 6px;
    width: 100%;
}
.input-row input { flex: 1; min-width: 0; }

.search-btn {
    width: 38px;
    height: 31px;
    flex-shrink: 0;
    border: 1px solid var(--navy-blue);
    background: #fff;
    border-radius: 4px;
    font-weight: bold;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
}

/* EXACT BLUE INFO TOAST LIKE IMAGE */
.toast-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0);
    display: none;
    align-items: flex-start;
    justify-content: center;
    z-index: 9999;
    padding-top: 50px;
}

.toast-overlay.show {
    display: flex;
}

.toast {
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.15);
    min-width: 380px;
    max-width: 500px;
    animation: slideDown 0.3s ease-out;
    display: flex;
    align-items: center;
    padding: 14px 18px;
    gap: 12px;
    border-left: 4px solid #2196F3;
}

.toast-icon-wrapper {
    width: 24px;
    height: 24px;
    background: #2196F3;
    border-radius: 4px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}

.toast-icon {
    color: white;
    font-size: 16px;
    font-weight: bold;
    font-family: serif;
}

.toast-content {
    flex: 1;
}

.toast-message {
    font-size: 15px;
    color: #333;
    line-height: 1.4;
    margin: 0;
}

.toast-close {
    cursor: pointer;
    font-size: 20px;
    color: #999;
    background: none;
    border: none;
    padding: 0;
    width: 20px;
    height: 20px;
    line-height: 1;
    flex-shrink: 0;
}

.toast-close:hover {
    color: #666;
}

@keyframes slideDown {
    from {
        opacity: 0;
        transform: translateY(-30px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes slideUp {
    from {
        opacity: 1;
        transform: translateY(0);
    }
    to {
        opacity: 0;
        transform: translateY(-30px);
    }
}

.toast.hiding {
    animation: slideUp 0.2s ease-out;
}

/* SUCCESS MODAL */
.msg-overlay {
    display: none;
    position: fixed;
    z-index: 2000;
    left: 0; top: 0;
    width: 100%; height: 100%;
    background-color: rgba(0,0,0,0.5);
    align-items: center;
    justify-content: center;
}
.msg-card {
    background: white;
    padding: 40px;
    border-radius: 15px;
    text-align: center;
    box-shadow: 0 10px 30px rgba(0,0,0,0.3);
    width: 90%;
    max-width: 400px;
}
.msg-icon { font-size: 45px; color: var(--success-green); margin-bottom: 15px; display: block; }
.msg-title { font-size: 20px; font-weight: bold; color: #2c0b5d; margin-bottom: 20px; }
.msg-confirm-btn {
    background-color: #28a745; color: white; padding: 12px 40px; border: none; border-radius: 8px; font-size: 16px; font-weight: bold; cursor: pointer;
}

.customer-modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); align-items: center; justify-content: center; }
.customer-modal-content { background: #fff; padding: 20px; border-radius: 8px; width: 80%; max-width: 800px; max-height: 80vh; overflow-y: auto; position: relative; }
.customer-close { position: absolute; right: 15px; top: 10px; font-size: 24px; cursor: pointer; }
.loading { opacity: 0.5; pointer-events: none; }
</style>
</head>

<body>

<%
    String sessionBranchCode = (String) session.getAttribute("branchCode");
    String branchName = "";
    
    if (sessionBranchCode != null && !sessionBranchCode.isEmpty()) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT NAME FROM HEADOFFICE.BRANCH WHERE BRANCH_CODE = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, sessionBranchCode);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                branchName = rs.getString("NAME");
            }
        } catch (Exception e) {
            branchName = "Error loading branch";
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    } else {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!-- Toast Notification - Exact Blue Style -->
<div id="toastOverlay" class="toast-overlay">
    <div id="toast" class="toast">
        <div class="toast-icon-wrapper">
            <span class="toast-icon">i</span>
        </div>
        <div class="toast-content">
            <p class="toast-message" id="toastMessage">Loading transaction form...</p>
        </div>
        <button class="toast-close" onclick="hideToast()">&times;</button>
    </div>
</div>

<div id="statusPopup" class="msg-overlay">
    <div class="msg-card">
        <span class="msg-icon">✔</span>
        <div class="msg-title">User created successfully</div>
        <button class="msg-confirm-btn" onclick="closeStatusPopup()">OK</button>
    </div>
</div>

<div class="container">
<form action="<%=request.getContextPath()%>/Utility/CreateUserServlet" method="post" id="userForm">
    <h2>New User Registration</h2>

    <fieldset>
    <legend>User Details</legend>
    <div class="grid-row-1" style="grid-template-columns: repeat(4, 1fr);">
        <div class="form-group">
            <label>User Id</label>
            <input type="text" id="userId" name="userId" onblur="checkUserId()" oninput="resetUserIdValidation()" required>      
            <span id="userIdMsg" style="font-size:12px;"></span>
        </div>

        <div class="form-group"><label>User Name</label><input type="text" name="userName" required></div>
        <div class="form-group"><label>Branch Code</label><input type="text" name="branchCode" value="<%=sessionBranchCode%>" readonly></div>
        <div class="form-group"><label>Branch Name</label><input type="text" value="<%=branchName%>" readonly></div>
    </div>
    </fieldset>

    <fieldset id="addressFieldset">
    <legend>Address Details</legend>
    
    <div class="grid-row-1">
        <div class="form-group">
            <label>Customer ID</label>
            <div class="input-row">
                <input type="text" id="customerId" name="custId" readonly>
                <button type="button" class="search-btn" onclick="openCustomerLookup()">...</button>
            </div>
        </div>
        <div class="form-group"><label>Customer Name</label><input type="text" id="customerName" readonly></div>
        <div class="form-group"><label>Employee Code</label><input type="text" name="empCode"></div>
        <div class="form-group"><label>Phone</label><input type="text" id="phone" name="phone" readonly></div>
        <div class="form-group"><label>Mobile</label><input type="text" id="mobile" name="mobile" readonly></div>
    </div>

    <div class="grid-row-2">
        <div class="form-group"><label>Address 1</label><input type="text" id="addr1" name="addr1" readonly></div>
        <div class="form-group"><label>Address 2</label><input type="text" id="addr2" name="addr2" readonly></div>
        <div class="form-group"><label>Address 3</label><input type="text" id="addr3" name="addr3" readonly></div>
        <div class="form-group"><label>Email</label><input type="email" id="email" name="email" readonly></div>
    </div>
    </fieldset>

    <div style="text-align: center; margin-top: 20px;">
        <input type="submit" value="Save" id="submitBtn" style="padding: 10px 55px; background: #3F51B5; color: white; border: none; border-radius: 5px; font-size: 15px; cursor: pointer;">
    </div>
</form>
</div>

<div id="customerLookupModal" class="customer-modal">
  <div class="customer-modal-content">
    <span class="customer-close" onclick="closeCustomerLookup()">&times;</span>
    <div id="customerLookupContent"></div>
  </div>
</div>

<script>
let userIdExists = false;
let toastTimeout;

window.onload = function() {
    <% String statusType = (String)request.getAttribute("msgType");
       if("success".equals(statusType)) { %>
        document.getElementById("statusPopup").style.display = "flex";
    <% } %>
};

function closeStatusPopup() { document.getElementById("statusPopup").style.display = "none"; }

// Show blue info toast - exact style from image
function showToast(message) {
    const overlay = document.getElementById('toastOverlay');
    const toast = document.getElementById('toast');
    
    document.getElementById('toastMessage').textContent = message;
    
    // Remove hiding class
    toast.classList.remove('hiding');
    
    // Show toast
    overlay.classList.add('show');
    
    // Auto hide after 5 seconds
    clearTimeout(toastTimeout);
    toastTimeout = setTimeout(() => {
        hideToast();
    }, 5000);
}

function hideToast() {
    const overlay = document.getElementById('toastOverlay');
    const toast = document.getElementById('toast');
    
    toast.classList.add('hiding');
    
    setTimeout(() => {
        overlay.classList.remove('show');
        toast.classList.remove('hiding');
    }, 200);
}

// Check if User ID already exists
function checkUserId() {
    const userIdInput = document.getElementById('userId');
    const userId = userIdInput.value.trim();
    const userIdMsg = document.getElementById('userIdMsg');
    
    if (!userId) {
        userIdMsg.textContent = '';
        userIdInput.classList.remove('error', 'success');
        userIdExists = false;
        return;
    }
    
    // No "Checking..." message - silent check
    
    const checkUrl = '<%=request.getContextPath()%>/Utility/NewUser.jsp?action=checkUserId&userId=' + encodeURIComponent(userId);
    
    console.log('Checking User ID:', userId);
    
    fetch(checkUrl)
        .then(response => {
            if (!response.ok) {
                throw new Error('HTTP error! status: ' + response.status);
            }
            return response.text();
        })
        .then(text => {
            console.log('Response:', text);
            const data = JSON.parse(text);
            
            if (data.error) {
                showToast(data.message);
                userIdMsg.textContent = '';
                userIdInput.classList.remove('error', 'success');
                userIdExists = false;
            } else if (data.exists) {
                // Only show message for duplicate
                showToast(data.message);
                userIdMsg.textContent = 'User ID already exists';
                userIdMsg.style.color = '#dc3545';
                userIdInput.classList.add('error');
                userIdInput.classList.remove('success');
                userIdExists = true;
            } else {
                // Available - keep field normal, no message
                userIdMsg.textContent = '';
                userIdInput.classList.remove('error', 'success');
                userIdExists = false;
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showToast('Failed to check user ID availability');
            userIdMsg.textContent = '';
            userIdInput.classList.remove('error', 'success');
            userIdExists = false;
        });
}

function resetUserIdValidation() {
    const userIdInput = document.getElementById('userId');
    const userIdMsg = document.getElementById('userIdMsg');
    
    userIdMsg.textContent = '';
    userIdInput.classList.remove('error', 'success');
    userIdExists = false;
}

document.getElementById('userForm').addEventListener('submit', function(e) {
    if (userIdExists) {
        e.preventDefault();
        showToast('User ID already exists. Please choose a different User ID.');
        document.getElementById('userId').focus();
        return false;
    }
});

window.setCustomerData = function(customerId, customerName, categoryCode, riskCategory) {
    document.getElementById("customerId").value = customerId;
    document.getElementById("customerName").value = customerName || '';
    closeCustomerLookup();
    fetchCustomerDetails(customerId);
};

function fetchCustomerDetails(customerId) {
    const fieldset = document.getElementById('addressFieldset');
    if (fieldset) fieldset.classList.add('loading');
    fetch('<%=request.getContextPath()%>/OpenAccount/getCustomerDetails.jsp?customerId=' + encodeURIComponent(customerId))
        .then(res => res.json())
        .then(data => {
            if (data.success && data.customer) {
                const c = data.customer;
                document.getElementById('phone').value = c.residencePhone || '';
                document.getElementById('mobile').value = c.mobileNo || '';
                document.getElementById('addr1').value = c.address1 || '';
                document.getElementById('addr2').value = c.address2 || '';
                document.getElementById('addr3').value = c.address3 || '';
                document.getElementById('email').value = c.email || '';
            }
        }).finally(() => fieldset.classList.remove('loading'));
}

function openCustomerLookup() {
    const modal = document.getElementById('customerLookupModal');
    modal.style.display = 'flex';
    fetch('<%=request.getContextPath()%>/OpenAccount/lookupForCustomerId.jsp')
        .then(res => res.text()).then(html => {
            document.getElementById('customerLookupContent').innerHTML = html;
            const scripts = document.getElementById('customerLookupContent').querySelectorAll('script');
            scripts.forEach(s => {
                const ns = document.createElement('script');
                ns.textContent = s.textContent;
                document.body.appendChild(ns); document.body.removeChild(ns);
            });
        });
}

function closeCustomerLookup() { document.getElementById('customerLookupModal').style.display = 'none'; }
</script>
</body>
</html>
