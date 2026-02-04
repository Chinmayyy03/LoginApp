<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>New User Creation</title>
<link rel="stylesheet" type="text/css" href="OpenAccount/css/savingAcc.css">

<style>
:root {
    --bg-lavender: #E6E6FA;
    --navy-blue: #303F9F;
    --border-color: #B8B8E6;   /* ✅ exact soft border */
    --readonly-bg: #E0E0E0;
}

body {
    font-family: Arial, sans-serif;
    background-color: var(--bg-lavender);
    margin: 0;
    padding: 20px;
}

.container {
    max-width: 1250px;
    margin: auto;
}

/* ===== MAIN HEADING ===== */
h2 {
    text-align: center;
    color: var(--navy-blue);
    margin-bottom: 25px;
}

/* ===== FIELDSET (SOFT BORDER) ===== */
fieldset {
    border: 1.5px solid var(--border-color);   /* ✅ FIX */
    border-radius: 8px;
    margin-bottom: 22px;
    padding: 18px;
}

/* ===== FIELDSET TITLE ===== */
legend {
    color: var(--navy-blue);                   /* heading color kept */
    font-weight: bold;
    font-size: 15px;
    padding: 0 10px;
    background-color: var(--bg-lavender);
}

/* ===== FORM GRID ===== */
.form-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 18px;
}

/* ===== FORM GROUP ===== */
.form-group {
    display: flex;
    flex-direction: column;
}

/* ===== LABELS ===== */
.form-group label {
    font-size: 13px;
    font-weight: bold;
    color: var(--navy-blue);
    margin-bottom: 4px;
}

/* ===== INPUTS (SOFT BORDER) ===== */
.form-group input {
    padding: 7px;
    border: 1px solid var(--border-color);     /* ✅ FIX */
    border-radius: 4px;
    font-size: 13px;
}

input[readonly] {
    background-color: var(--readonly-bg);
}

/* ===== CUSTOMER LOOKUP BUTTON ===== */
.input-row {
    display: flex;
    gap: 6px;
}

.search-btn {
    padding: 0 12px;
    font-weight: bold;
    cursor: pointer;
    border: 1px solid var(--border-color);     /* ✅ FIX */
    background: #fff;
    border-radius: 4px;
}

/* ===== SAVE BUTTON ===== */
.btn-container {
    text-align: center;
    margin-top: 20px;
}

.save-btn {
    padding: 10px 55px;
    background: #3F51B5;
    color: white;
    border: none;
    border-radius: 5px;
    font-size: 15px;
    cursor: pointer;
}

.save-btn:hover {
    background: #283593;
}


</style>

</head>

<body>


<div class="container">
<form action="<%=request.getContextPath()%>/Utility/CreateUserServlet" method="post">

<h2>New User Registration</h2>

<!-- ================= USER DETAILS ================= -->
<fieldset>
<legend>User Details</legend>

<div class="form-grid">

    <div class="form-group">
        <label>User Id</label>
        <input type="text" name="userId" required>
    </div>

    <div class="form-group">
        <label>User Name</label>
        <input type="text" name="userName" required>
    </div>

    <div class="form-group">
        <label>Branch Code</label>
        <input type="text" name="branchCode" value="0002" readonly>
    </div>

    <div class="form-group">
        <label>Branch Name</label>
        <input type="text" value="SHAHUPURI" readonly>
    </div>

</div>
</fieldset>

<!-- ================= ADDRESS DETAILS ================= -->
<fieldset>
<legend>Address Details</legend>

<div class="form-grid">

    <!-- CUSTOMER LOOKUP -->
    <div class="form-group">
        <label>Customer ID</label>
        <div class="input-row">
            <input type="text" id="customerId" name="custId" readonly>
            <button type="button" class="search-btn" onclick="openCustomerLookup()">...</button>
        </div>
    </div>

    <div class="form-group">
        <label>Customer Name</label>
        <input type="text" id="customerName" readonly>
    </div>

    <div class="form-group">
        <label>Employee Code</label>
        <input type="text" name="empCode">
    </div>

    <div class="form-group">
        <label>Phone</label>
        <input type="text" name="phone">
    </div>

    <div class="form-group">
        <label>Mobile</label>
        <input type="text" name="mobile">
    </div>

    <div class="form-group">
        <label>Address 1</label>
        <input type="text" name="addr1">
    </div>

    <div class="form-group">
        <label>Address 2</label>
        <input type="text" name="addr2">
    </div>

    <div class="form-group">
        <label>Address 3</label>
        <input type="text" name="addr3">
    </div>

    <div class="form-group">
        <label>Email</label>
        <input type="email" name="email">
    </div>

</div>
</fieldset>

<div class="btn-container">
    <input type="submit" value="Save" class="save-btn">
</div>

</form>
</div>

<!-- Customer Lookup Modal -->
<div id="customerLookupModal" class="customer-modal">
  <div class="customer-modal-content">
    <span class="customer-close" onclick="closeCustomerLookup()">&times;</span>
    <div id="customerLookupContent">
      <!-- Content will be loaded here -->
    </div>
  </div>
</div>

<!-- ================= MESSAGE POPUP ================= -->
<%
String msg = (String) request.getAttribute("msg");
String msgType = (String) request.getAttribute("msgType");
if (msg != null) {
%>
<div id="popupOverlay" style="
position:fixed;top:0;left:0;width:100%;height:100%;
background:rgba(0,0,0,0.5);
display:flex;align-items:center;justify-content:center;">
<div style="background:#fff;padding:20px;border-radius:6px;text-align:center;">
<h3 style="color:<%= "success".equals(msgType) ? "green" : "red" %>">
<%= msg %>
</h3>
<button onclick="document.getElementById('popupOverlay').style.display='none'">
OK
</button>
</div>
</div>
<% } %>

<!-- ================= JAVASCRIPT ================= -->
<script>


function setCustomerData(customerId, customerName, categoryCode, riskCategory) {
    document.getElementById("customerId").value = customerId;
    document.getElementById("customerName").value = customerName;
}
</script>
<script src="OpenAccount/js/savingAcc.js"></script>
</body>
</html>
