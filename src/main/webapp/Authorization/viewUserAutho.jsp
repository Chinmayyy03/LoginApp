<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, db.DBConnection" %>

<%
String userId = request.getParameter("userId");

if(userId == null || userId.trim().equals("")){
%>
    <h3> User Id not received</h3>
<%
    return;
}

/* ================= FETCH USER DATA ================= */
String userName="";
String branchCode="";
String custId="";
String mobile="";
String empCode="";

Connection conn=null;
PreparedStatement ps=null;
ResultSet rs=null;

try{
    conn = DBConnection.getConnection();

    String sql =
        "SELECT USER_ID, NAME, BRANCH_CODE, CUSTOMER_ID, MOBILE_NUMBER " +
        "FROM ACL.USERREGISTER WHERE USER_ID=?";

    ps = conn.prepareStatement(sql);
    ps.setString(1,userId);
    rs = ps.executeQuery();

    if(rs.next()){
        userName   = rs.getString("NAME");
        branchCode = rs.getString("BRANCH_CODE");
        custId     = rs.getString("CUSTOMER_ID");
        mobile     = rs.getString("MOBILE_NUMBER");
    }else{
%>
        <h3>User Not Found</h3>
<%
        return;
    }

}catch(Exception e){
    out.print(e);
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>View User Authorization</title>

<link rel="stylesheet" type="text/css"
href="<%=request.getContextPath()%>/OpenAccount/css/savingAcc.css">

<style>
:root{
 --bg-lavender:#E6E6FA;
 --navy-blue:#303F9F;
 --border-color:#B8B8E6;
 --readonly-bg:#E0E0E0;
}

body{
 font-family:Arial,sans-serif;
 background-color:var(--bg-lavender);
 margin:0;
 padding:20px;
}

.container{max-width:1400px;margin:auto;}

h2{
 text-align:center;
 color:var(--navy-blue);
 margin-bottom:25px;
}

fieldset{
 border:1.5px solid var(--border-color);
 border-radius:8px;
 margin-bottom:22px;
 padding:18px;
}

legend{
 color:var(--navy-blue);
 font-weight:bold;
 font-size:15px;
 padding:0 10px;
 background-color:var(--bg-lavender);
}

.grid-row-1{
 display:grid;
 grid-template-columns:repeat(5,1fr);
 gap:15px;
 margin-bottom:15px;
 align-items:end;
}

.grid-row-2{
 display:grid;
 grid-template-columns:repeat(4,1fr);
 gap:15px;
 align-items:end;
}

.form-group{width:100%;}

.form-group label{
 display:block;
 font-size:13px;
 font-weight:bold;
 color:var(--navy-blue);
 margin-bottom:4px;
}

.form-group input{
 width:100%;
 padding:7px;
 border:1px solid var(--border-color);
 border-radius:4px;
 font-size:13px;
 box-sizing:border-box;
}

input[readonly]{
 background-color:var(--readonly-bg);
}

/* ===== PASSWORD FIELD STYLES ===== */
.password-field {
    position: relative;
    width: 100%;
}

.password-field input {
    padding-right: 40px;
    background-color: white;
}

.toggle-password {
    position: absolute;
    right: 15px;
    top: 50%;
    transform: translateY(-50%);
    cursor: pointer;
    color: #6c757d;
    font-size: 16px;
    user-select: none;
    display: flex;
    align-items: center;
    justify-content: center;
}

.toggle-password:hover {
    color: var(--navy-blue);
}

/* Hide default browser password reveal eye */


input[type="password"]::-ms-reveal,
input[type="password"]::-ms-clear {
    display: none;
}

input[type="password"]::-webkit-credentials-auto-fill-button,
input[type="password"]::-webkit-textfield-decoration-container,
input[type="password"]::-webkit-clear-button,
input[type="password"]::-webkit-inner-spin-button,
input[type="password"]::-webkit-outer-spin-button {
    display: none !important;
}

/* General fallback */
input[type="password"] {
    appearance: none;
    -webkit-appearance: none;
}


.error-message {
    color: #dc3545;
    font-size: 12px;
    margin-top: 4px;
    display: none;
}

/* ===== BUTTON STYLES ===== */

.btn-back{
 background:#6c757d;
 color:white;
 padding:9px 22px;
 border:none;
 border-radius:5px;
 font-size:13px;
 cursor:pointer;
}

.btn-auth{
 background:#28a745;
 color:white;
 padding:10px 26px;
 border:none;
 border-radius:5px;
 font-size:14px;
 cursor:pointer;
 margin-right:15px;
}

.btn-reject{
 background:#dc3545;
 color:white;
 padding:10px 26px;
 border:none;
 border-radius:5px;
 font-size:14px;
 cursor:pointer;
}

/* ===== MODAL STYLES ===== */
.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0,0,0,0.6);
}

.modal-content {
    background-color: white;
    margin: 12% auto;
    padding: 35px 40px;
    border-radius: 12px;
    width: 550px;
    box-shadow: 0 8px 20px rgba(0,0,0,0.3);
    text-align: center;
}

.modal-header {
    font-size: 24px;
    font-weight: bold;
    color: #3f3a7f;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
}

.modal-header .icon {
    font-size: 28px;
}

.modal-body {
    margin-bottom: 25px;
    color: #555;
    font-size: 15px;
    line-height: 1.6;
}

.modal-body .app-number {
    font-weight: bold;
    color: #3f3a7f;
}

.modal-footer {
    display: flex;
    justify-content: center;
    gap: 15px;
}

.modal-btn {
    padding: 12px 30px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 15px;
    font-weight: 600;
    min-width: 140px;
    transition: all 0.3s ease;
}

.btn-confirm-authorize {
    background-color: #28a745;
    color: white;
}

.btn-confirm-authorize:hover {
    background-color: #218838;
    transform: translateY(-1px);
    box-shadow: 0 4px 8px rgba(40,167,69,0.3);
}

.btn-confirm-reject {
    background-color: #dc3545;
    color: white;
}

.btn-confirm-reject:hover {
    background-color: #c82333;
    transform: translateY(-1px);
    box-shadow: 0 4px 8px rgba(220,53,69,0.3);
}

.btn-cancel {
    background-color: #e0e0e0;
    color: #555;
}

.btn-cancel:hover {
    background-color: #d0d0d0;
    transform: translateY(-1px);
}
</style>
</head>

<body>

<div class="container">

<h2>View User Authorization</h2>

<!-- ================= USER DETAILS ================= -->
<fieldset>
<legend>User Details</legend>

<div class="grid-row-1" style="grid-template-columns:repeat(4,1fr);">

<div class="form-group">
<label>User Id</label>
<input type="text" value="<%=userId%>" readonly>
</div>

<div class="form-group">
<label>User Name</label>
<input type="text" value="<%=userName%>" readonly>
</div>

<div class="form-group">
<label>Branch Code</label>
<input type="text" value="<%=branchCode%>" readonly>
</div>

<div class="form-group">
<label>Employee Code</label>
<input type="text" value="<%=empCode%>" readonly>
</div>

</div>
</fieldset>

<!-- ================= ADDRESS DETAILS ================= -->
<fieldset id="addressFieldset">
<legend>Address Details</legend>

<div class="grid-row-1">

<div class="form-group">
<label>Customer ID</label>
<input type="text" id="customerId" value="<%=custId%>" readonly>
</div>

<div class="form-group">
<label>Customer Name</label>
<input type="text" id="customerName" readonly>
</div>

<div class="form-group">
<label>Phone</label>
<input type="text" id="phone" readonly>
</div>

<div class="form-group">
<label>Mobile</label>
<input type="text" id="mobile" value="<%=mobile%>" readonly>
</div>

<div class="form-group">
<label>Email</label>
<input type="text" id="email" readonly>
</div>

</div>

<div class="grid-row-2">

<div class="form-group">
<label>Address 1</label>
<input type="text" id="addr1" readonly>
</div>

<div class="form-group">
<label>Address 2</label>
<input type="text" id="addr2" readonly>
</div>

<div class="form-group">
<label>Address 3</label>
<input type="text" id="addr3" readonly>
</div>

</div>
</fieldset>

<!-- ================= PASSWORD DETAILS ================= -->
<fieldset>
<legend>Password Details</legend>

<div style="display:grid; grid-template-columns:repeat(2,1fr); gap:80px; align-items:end; max-width:900px; margin:0 auto;">

<div class="form-group">
<label>Password <span style="color:red;">*</span></label>
<div class="password-field">
    <input type="password" id="password" name="password" required style="height:38px; padding:8px 40px 8px 12px;">
    <span class="toggle-password" onclick="togglePassword('password')">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
            <circle cx="12" cy="12" r="3"></circle>
        </svg>
    </span>
</div>
<div class="error-message" id="passwordError">Password is required</div>
</div>

<div class="form-group">
<label>Confirm Password <span style="color:red;">*</span></label>
<div class="password-field">
    <input type="password" id="confirmPassword" name="confirmPassword" required style="height:38px; padding:8px 40px 8px 12px;">
    <span class="toggle-password" onclick="togglePassword('confirmPassword')">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
            <circle cx="12" cy="12" r="3"></circle>
        </svg>
    </span>
</div>
<div class="error-message" id="confirmPasswordError">Passwords does not match</div>
</div>

</div>
</fieldset>

<!-- ================= BUTTON SECTION ================= -->

<br>

<div style="text-align:center;">
    <button type="button" onclick="goBackToList();" class="back-btn"
        style="padding:10px 22px; background:#373279; color:white;
               border:none; border-radius:6px; cursor:pointer;
               font-size:16px; font-weight:bold;">
    ← Back to List
    </button>
</div>

<div style="text-align:center; margin-top:30px;">
    <form id="authorizeForm" action="UserAuthorizationServlet" method="post" style="display:inline;">
        <input type="hidden" name="userId" value="<%= userId %>">
        <input type="hidden" name="status" value="A">
        <input type="hidden" name="password" id="hiddenPassword">
        <button type="button" onclick="showAuthorizeConfirmation(event)"
            style="padding:10px 22px; background:linear-gradient(45deg, #28a745, #34ce57); color:white;
                   border:none; border-radius:6px; cursor:pointer;
                   font-size:16px; font-weight:bold;">
            ✔ Authorize
        </button>
    </form>

    &nbsp;&nbsp;&nbsp;

    <form id="rejectForm" action="UserAuthorizationServlet" method="post" style="display:inline;">
        <input type="hidden" name="userId" value="<%= userId %>">
        <input type="hidden" name="status" value="R">
        <button type="button" onclick="showRejectConfirmation(event)"
            style="padding:10px 22px; background:linear-gradient(45deg, #dc3545, #e74c3c); color:white;
                   border:none; border-radius:6px; cursor:pointer;
                   font-size:16px; font-weight:bold;">
            ✘ Reject
        </button>
    </form>
</div>

<!-- ================= CONFIRMATION MODALS ================= -->

<!-- Authorize Confirmation Modal -->
<div id="authorizeModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <span class="icon" style="color: #28a745;">✓</span>
            Confirm Authorization
        </div>
        <div class="modal-body">
            Are you sure you want to <strong>authorize</strong> this application?<br>
            User ID: <span class="app-number"><%= userId %></span>
        </div>
        <div class="modal-footer">
            <button class="modal-btn btn-cancel" onclick="closeModal('authorizeModal')">Cancel</button>
            <button class="modal-btn btn-confirm-authorize" onclick="submitAuthorize()">Yes, Authorize</button>
        </div>
    </div>
</div>

<!-- Reject Confirmation Modal -->
<div id="rejectModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <span class="icon" style="color: #dc3545;">✗</span>
            Confirm Rejection
        </div>
        <div class="modal-body">
            Are you sure you want to <strong>reject</strong> this application?<br>
            User ID: <span class="app-number"><%= userId %></span>
        </div>
        <div class="modal-footer">
            <button class="modal-btn btn-cancel" onclick="closeModal('rejectModal')">Cancel</button>
            <button class="modal-btn btn-confirm-reject" onclick="submitReject()">Yes, Reject</button>
        </div>
    </div>
</div>

<!-- ================= FETCH CUSTOMER DETAILS ================= -->
<script>
window.onload=function(){

 let custId=document.getElementById("customerId").value;

 if(custId){

  fetch(
		  "<%=request.getContextPath()%>/OpenAccount/getCustomerDetails.jsp?customerId="
		   + encodeURIComponent(custId)
  )
  .then(res=>res.json())
  .then(data=>{

   if(data.success && data.customer){

    let c=data.customer;

    document.getElementById("customerName").value=c.customerName||"";
    document.getElementById("phone").value=c.residencePhone||"";
    document.getElementById("email").value=c.email||"";
    document.getElementById("addr1").value=c.address1||"";
    document.getElementById("addr2").value=c.address2||"";
    document.getElementById("addr3").value=c.address3||"";
   }

  });

 }

};

// ================= UTILITY FUNCTIONS =================

// Toggle password visibility
function togglePassword(fieldId) {
    const field = document.getElementById(fieldId);
    const toggleIcon = field.parentElement.querySelector('.toggle-password svg');
    
    if (field.type === "password") {
        field.type = "text";
        // Change to eye-off icon
        toggleIcon.innerHTML = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line>';
    } else {
        field.type = "password";
        // Change to eye icon
        toggleIcon.innerHTML = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle>';
    }
}

// Validate password fields
function validatePasswords() {
    const password = document.getElementById("password").value;
    const confirmPassword = document.getElementById("confirmPassword").value;
    const passwordError = document.getElementById("passwordError");
    const confirmPasswordError = document.getElementById("confirmPasswordError");
    
    // Reset error messages
    passwordError.style.display = "none";
    confirmPasswordError.style.display = "none";
    
    // Check if password is empty
    if (!password || password.trim() === "") {
        passwordError.textContent = "Password is required";
        passwordError.style.display = "block";
        return false;
    }
    
    // Check password length (minimum 6 characters)
    if (password.length < 6) {
        passwordError.textContent = "Password must be at least 6 characters";
        passwordError.style.display = "block";
        return false;
    }
    
    // Check if confirm password is empty
    if (!confirmPassword || confirmPassword.trim() === "") {
        confirmPasswordError.textContent = "Please confirm your password";
        confirmPasswordError.style.display = "block";
        return false;
    }
    
    // Check if passwords match
    if (password !== confirmPassword) {
        confirmPasswordError.textContent = "Passwords do not match";
        confirmPasswordError.style.display = "block";
        return false;
    }
    
    return true;
}

// ================= BUTTON FUNCTIONS =================

// Back to List function
function goBackToList() {
    // Redirect to pending list page
    window.location.href = "<%=request.getContextPath()%>/authorizationPendingUsers.jsp";
}

// Show authorize confirmation modal
function showAuthorizeConfirmation(event) {
    event.preventDefault();
    
    // Validate passwords before showing modal
    if (!validatePasswords()) {
        return;
    }
    
    // Show modal
    document.getElementById("authorizeModal").style.display = "block";
}

// Show reject confirmation modal
function showRejectConfirmation(event) {
    event.preventDefault();
    
    // Show modal (no password validation needed for rejection)
    document.getElementById("rejectModal").style.display = "block";
}

// Close modal
function closeModal(modalId) {
    document.getElementById(modalId).style.display = "none";
}

// Submit authorize form
function submitAuthorize() {
    // Set password in hidden field
    const password = document.getElementById("password").value;
    document.getElementById("hiddenPassword").value = password;
    
    // Submit the form
    document.getElementById("authorizeForm").submit();
}

// Submit reject form
function submitReject() {
    // Submit the form
    document.getElementById("rejectForm").submit();
}

// Close modal when clicking outside
window.onclick = function(event) {
    const authorizeModal = document.getElementById("authorizeModal");
    const rejectModal = document.getElementById("rejectModal");
    
    if (event.target == authorizeModal) {
        authorizeModal.style.display = "none";
    }
    if (event.target == rejectModal) {
        rejectModal.style.display = "none";
    }
}

// Real-time password validation
document.getElementById("confirmPassword").addEventListener("input", function() {
    const password = document.getElementById("password").value;
    const confirmPassword = this.value;
    const confirmPasswordError = document.getElementById("confirmPasswordError");
    
    if (confirmPassword && password !== confirmPassword) {
        confirmPasswordError.style.display = "block";
    } else {
        confirmPasswordError.style.display = "none";
    }
});

</script>

</body>
</html>
