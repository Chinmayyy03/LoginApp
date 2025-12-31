<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
 // Fetch working date for this branch
    String workingDateStr = "";
    try (Connection connWorkDate = DBConnection.getConnection()) {
        String bankCode = "0100"; // Default bank code
        CallableStatement cstmtWorkDate = connWorkDate.prepareCall("{? = call SYSTEM.FN_GET_WORKINGDATE(?, ?)}");
        cstmtWorkDate.registerOutParameter(1, Types.DATE);
        cstmtWorkDate.setString(2, bankCode);
        cstmtWorkDate.setString(3, branchCode);
        cstmtWorkDate.execute();
        
        Date workingDate = cstmtWorkDate.getDate(1);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        workingDateStr = sdf.format(workingDate);
        
        cstmtWorkDate.close();
    } catch (Exception e) {
        e.printStackTrace();
        // Fallback to current date if error
        workingDateStr = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    }
    
    String productCode = request.getParameter("productCode");
    if (productCode == null) {
        productCode = "";
    }
    System.out.println("📌 fAApplication.jsp - Product Code received: " + productCode);
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Fixed Asset Depreciation Application</title>
  <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
  <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
<style>
body {
    background-color: #e8e4fc;
    font-family: Arial, sans-serif;
    margin: 20px;
    padding: 0;
}

fieldset {
    background: #e8e4fc;
    border: 2px solid #aaa;
    margin: 32px 0;
    padding: 15px 20px;
    min-width: 320px;
    border-radius: 9px;
}

legend {
    font-weight: bold;
    letter-spacing: 1px;
    font-size: 1.18em;
    padding: 0 10px;
    color: #373279;
}

.form-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 10px 20px;
}

.form-grid div {
    display: flex;
    flex-direction: column;
}

label {
    min-width: 10px;
    font-size: 13px;
    margin-bottom: 3px;
    font-weight: bold;
    color: #373279;
}

input[type="text"],
input[type="date"],
input[type="number"],
select {
    padding: 4px 6px;
    font-size: 13px;
    width: 90%;
    box-sizing: border-box;
}

input[readonly] {
    background-color: #f0f0f0;
    cursor: not-allowed;
}

.input-icon-box {
    position: relative;
    width: 90%;
}

.input-icon-box input {
    width: 100%;
    padding-right: 40px;
    height: 30px;
    cursor: pointer;
    box-sizing: border-box;
}

.input-icon-box .inside-icon-btn {
    position: absolute;
    right: 5px;
    top: 50%;
    transform: translateY(-50%);
    background: none;
    border: none;
    font-size: 20px;
    cursor: pointer;
    color: #373279;
}

.customer-modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.6);
    z-index: 9999;
    justify-content: center;
    align-items: center;
}

.customer-modal-content {
    background: white;
    width: 85%;
    max-width: 1000px;
    max-height: 85vh;
    overflow: auto;
    padding: 25px;
    border-radius: 12px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
    position: relative;
}

.customer-close {
    position: absolute;
    right: 20px;
    top: 15px;
    font-size: 32px;
    font-weight: bold;
    cursor: pointer;
    color: #666;
    transition: color 0.3s;
}

.customer-close:hover {
    color: #373279;
}

.lookup-title {
    font-size: 24px;
    margin-bottom: 20px;
    font-weight: bold;
    color: #373279;
    text-align: center;
}

.search-box {
    margin-bottom: 20px;
}

.search-box input {
    width: 100%;
    padding: 12px 15px;
    font-size: 15px;
    border: 2px solid #9c8ed8;
    border-radius: 8px;
    background-color: #f5f3ff;
    box-sizing: border-box;
}

.search-box input:focus {
    outline: none;
    border-color: #373279;
    background-color: #fff;
}

.table-container {
    max-height: 400px;
    overflow-y: auto;
    border: 1px solid #ddd;
    border-radius: 8px;
    background: white;
}

.customer-modal-content table {
    width: 100%;
    border-collapse: collapse;
}

.customer-modal-content th,
.customer-modal-content td {
    border: 1px solid #ddd;
    padding: 12px 15px;
    text-align: left;
}

.customer-modal-content th {
    background-color: #373279;
    color: white;
    font-weight: bold;
    position: sticky;
    top: 0;
    z-index: 10;
}

.customer-modal-content tbody tr {
    transition: all 0.2s;
}

.customer-modal-content tbody tr:hover {
    background-color: #e8e4fc;
    cursor: pointer;
    transform: scale(1.01);
}

.customer-modal-content tbody tr:nth-child(even) {
    background-color: #f9f9f9;
}

.customer-count {
    text-align: right;
    margin-bottom: 10px;
    color: #666;
    font-size: 14px;
}

.radio-group {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 13px;
}

.radio-group label {
    display: flex;
    align-items: center;
    gap: 5px;
    margin: 0;
}

input[type="radio"] {
    transform: scale(0.9);
}

.form-buttons {
    display: flex;
    justify-content: center;
    align-items: center;
    margin: 25px 0;
    gap: 20px;
}

.form-buttons button {
    background-color: #373279;
    color: white;
    border: none;
    padding: 10px 25px;
    border-radius: 6px;
    font-size: 14px;
    font-weight: bold;
    cursor: pointer;
    transition: background-color 0.3s ease, transform 0.2s ease;
}

.form-buttons button:hover {
    background-color: #2b0d73;
    transform: scale(1.05);
}

/* Hide number input arrows */
input[type=number]::-webkit-inner-spin-button, 
input[type=number]::-webkit-outer-spin-button {
    -webkit-appearance: none !important;
    appearance: none !important;
    margin: 0 !important;
}

input[type=number] {
    -moz-appearance: textfield !important;
    appearance: textfield !important;
}

@media (max-width: 1024px) {
    .form-grid {
        grid-template-columns: repeat(2, 1fr);
    }
}

@media (max-width: 600px) {
    .form-grid {
        grid-template-columns: 1fr;
    }
}
</style>
</head>
<body>

<form action="SaveFAApplicationServlet" method="post" onsubmit="return validateForm()">
  <input type="hidden" id="hiddenProductCode" name="productCode" value="<%= productCode %>">

  <fieldset>
    <legend>Application</legend>
    <div class="form-grid">
      
      <div>
        <label>Product Code</label>
        <input type="text" value="<%= productCode %>" readonly style="background-color: #f0f0f0;">
      </div>
      
      <div>
        <label>Customer ID</label>
        <div class="input-icon-box">
          <input type="text" id="customerId" name="customerId" onclick="openCustomerLookup()" readonly required>
          <button type="button" class="inside-icon-btn" onclick="openCustomerLookup()" title="Search Customer">🔍</button>
        </div>
      </div>

      <div>
        <label>Customer Name</label>
        <input type="text" id="customerName" name="customerName" readonly>
      </div>
     
      <div>
    	<label>Date Of Application</label>
    	<input type="date" name="dateOfApplication" value="<%= workingDateStr %>" readonly 
           style="background-color: #f0f0f0; cursor: not-allowed;" required>
	</div>

      <div>
        <label>Item Name</label>
        <input type="text" name="itemName" required oninput="this.value = this.value.replace(/[^A-Za-z0-9 ]/g, '')">
      </div>

      <div>
        <label>Purchase Date</label>
        <input type="date" name="purchaseDate" required>
      </div>

      <div>
        <label>Purchase Amount</label>
        <input type="number" step="0.01" name="purchaseAmount" value="0" required>
      </div>

      <div>
        <label>No. Of Item</label>
        <input type="number" name="noOfItem" value="0" required>
      </div>

      <div>
        <label>Depreciation Rate</label>
        <input type="number" step="0.01" name="depreciationRate" value="0" required>
      </div>

      <div>
        <label>Description</label>
        <input type="text" name="description" required oninput="this.value = this.value.replace(/[^A-Za-z0-9 ]/g, '')">
      </div>

      <div>
        <label>Bill Number</label>
        <input type="text" name="billNumber" required oninput="this.value = this.value.replace(/[^A-Za-z0-9 ]/g, '')">
      </div>

      <div>
        <label>Method Of Depreciation Calculation</label>
        <div class="radio-group" style="flex-direction: row;">
          <label><input type="radio" name="methodOfDepreciation" value="Day"> Day</label>
          <label><input type="radio" name="methodOfDepreciation" value="Month" checked> Month</label>
        </div>
      </div>

      <div>
        <label>Depreciation Calculate On</label>
        <div class="radio-group" style="flex-direction: row;">
          <label><input type="radio" name="depreciationCalculateOn" value="Opening Balance"> Opening Balance</label>
          <label><input type="radio" name="depreciationCalculateOn" value="Current Balance" checked> Current Balance</label>
        </div>
      </div>

    </div>
  </fieldset>

  <div class="form-buttons">
    <button type="submit">Submit</button>
    <button type="reset">Reset</button>
  </div>
</form>

<!-- Customer Lookup Modal -->
<div id="customerLookupModal" class="customer-modal">
  <div class="customer-modal-content">
    <span class="customer-close" onclick="closeCustomerLookup()">&times;</span>
    <div id="customerLookupContent">
      <!-- Content will be loaded here -->
    </div>
  </div>
</div>

<script>
// Validation function
function validateForm() {
    const customerId = document.getElementById('customerId').value.trim();
    
    if (!customerId) {
        showToast('❌ Please select a customer before submitting');
        return false;
    }
    
    const purchaseAmount = parseFloat(document.querySelector('input[name="purchaseAmount"]').value);
    if (purchaseAmount <= 0) {
        showToast('❌ Purchase Amount must be greater than 0');
        return false;
    }
    
    const noOfItem = parseInt(document.querySelector('input[name="noOfItem"]').value);
    if (noOfItem <= 0) {
        showToast('❌ Number of Items must be greater than 0');
        return false;
    }
    
    const depreciationRate = parseFloat(document.querySelector('input[name="depreciationRate"]').value);
    if (depreciationRate < 0 || depreciationRate > 100) {
        showToast('❌ Depreciation Rate must be between 0 and 100');
        return false;
    }
    
    return true;
}

// Check URL parameters for success/error messages
window.addEventListener('DOMContentLoaded', function() {
    const urlParams = new URLSearchParams(window.location.search);
    const status = urlParams.get('status');
    const applicationNumber = urlParams.get('applicationNumber');
    const message = urlParams.get('message');
    
    if (status === 'success' && applicationNumber) {
        Toastify({
            text: "✅ Fixed Asset Application saved successfully!\nApplication Number: " + applicationNumber,
            duration: 6000,
            close: true,
            gravity: "top",
            position: "center",
            style: {
                background: "#fff",
                color: "#333",
                borderRadius: "8px",
                fontSize: "14px",
                padding: "16px 24px",
                boxShadow: "0 3px 10px rgba(0,0,0,0.2)",
                borderLeft: "5px solid #4caf50",
                marginTop: "20px",
                whiteSpace: "pre-line"
            },
            stopOnFocus: true
        }).showToast();
        
        setTimeout(function() {
            const cleanUrl = window.location.pathname + window.location.search.replace(/[?&](status|applicationNumber|message)=[^&]*/g, '').replace(/^&/, '?').replace(/\?$/, '');
            window.history.replaceState({}, document.title, cleanUrl || window.location.pathname);
        }, 100);
        
    } else if (status === 'error') {
        Toastify({
            text: "❌ Error: " + (message || "Failed to save application"),
            duration: 6000,
            close: true,
            gravity: "top",
            position: "center",
            style: {
                background: "#fff",
                color: "#333",
                borderRadius: "8px",
                fontSize: "14px",
                padding: "16px 24px",
                boxShadow: "0 3px 10px rgba(0,0,0,0.2)",
                borderLeft: "5px solid #f44336",
                marginTop: "20px"
            },
            stopOnFocus: true
        }).showToast();
        
        setTimeout(function() {
            const cleanUrl = window.location.pathname + window.location.search.replace(/[?&](status|applicationNumber|message)=[^&]*/g, '').replace(/^&/, '?').replace(/\?$/, '');
            window.history.replaceState({}, document.title, cleanUrl || window.location.pathname);
        }, 100);
    }
});

//==================== CUSTOMER LOOKUP FUNCTIONS ====================

window.setCustomerData = function(customerId, customerName, categoryCode, riskCategory) {
    document.getElementById('customerId').value = customerId;
    document.getElementById('customerName').value = customerName;

    closeCustomerLookup();

    if (typeof Toastify !== 'undefined') {
        Toastify({
            text: "✅ Customer data loaded successfully!",
            duration: 5000,
            close: true,
            gravity: "top",
            position: "center",
            style: {
                background: "#fff",
                color: "#333",
                borderRadius: "8px",
                fontSize: "14px",
                padding: "16px 24px",
                boxShadow: "0 3px 10px rgba(0,0,0,0.2)",
                borderLeft: "5px solid #4caf50",
                marginTop: "20px"
            }
        }).showToast();
    }
};

function openCustomerLookup() {
    const modal = document.getElementById('customerLookupModal');
    const content = document.getElementById('customerLookupContent');

    modal.style.display = 'flex';
    content.innerHTML = '<div style="text-align:center;padding:40px;">Loading customers...</div>';

    fetch('lookupForCustomerId.jsp')
        .then(response => response.text())
        .then(html => {
            content.innerHTML = html;
            const scripts = content.querySelectorAll('script');
            scripts.forEach(script => {
                const newScript = document.createElement('script');
                newScript.textContent = script.textContent;
                document.body.appendChild(newScript);
                document.body.removeChild(newScript);
            });
        })
        .catch(error => {
            console.error('Error loading customer lookup:', error);
            content.innerHTML = '<div style="text-align:center;padding:40px;color:red;">Failed to load customer list. Please try again.</div>';
        });
}

function closeCustomerLookup() {
    document.getElementById('customerLookupModal').style.display = 'none';
}

window.onclick = function(event) {
    const modal = document.getElementById('customerLookupModal');
    if (event.target === modal) {
        closeCustomerLookup();
    }
}

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeCustomerLookup();
    }
});

function showToast(message) {
    if (typeof Toastify !== 'undefined') {
        Toastify({
            text: message,
            duration: 5000,
            close: true,
            gravity: "top",
            position: "center",
            style: {
                background: "#fff",
                color: "#333",
                borderRadius: "8px",
                fontSize: "14px",
                padding: "16px 24px",
                boxShadow: "0 3px 10px rgba(0,0,0,0.2)",
                borderLeft: "5px solid #4caf50",
                marginTop: "20px"
            }
        }).showToast();
    }
}

// Update breadcrumb on page load
window.onload = function() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Fixed Asset Application');
    }
};

</script>
</body>
</html>