<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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

/* ROW 1: PERFECT 5-COLUMN FIT */
.grid-row-1 {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 15px;
    margin-bottom: 15px;
    align-items: end;
}

/* ROW 2: NEAT 4-COLUMN ALIGNMENT */
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

/* BUTTON LOCK */
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

/* Original Lookup Modal */
.customer-modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); align-items: center; justify-content: center; }
.customer-modal-content { background: #fff; padding: 20px; border-radius: 8px; width: 80%; max-width: 800px; max-height: 80vh; overflow-y: auto; position: relative; }
.customer-close { position: absolute; right: 15px; top: 10px; font-size: 24px; cursor: pointer; }
.loading { opacity: 0.5; pointer-events: none; }
</style>
</head>

<body>

<div id="statusPopup" class="msg-overlay">
    <div class="msg-card">
        <span class="msg-icon">✔</span>
        <div class="msg-title">User created successfully</div>
        <button class="msg-confirm-btn" onclick="closeStatusPopup()">OK</button>
    </div>
</div>

<div class="container">
<form action="<%=request.getContextPath()%>/Utility/CreateUserServlet" method="post">
    <h2>New User Registration</h2>

    <fieldset>
    <legend>User Details</legend>
    <div class="grid-row-1" style="grid-template-columns: repeat(4, 1fr);">
        <div class="form-group"><label>User Id</label><input type="text" name="userId" required></div>
        <div class="form-group"><label>User Name</label><input type="text" name="userName" required></div>
        <div class="form-group"><label>Branch Code</label><input type="text" name="branchCode" value="0002" readonly></div>
        <div class="form-group"><label>Branch Name</label><input type="text" value="SHAHUPURI" readonly></div>
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
        <div class="form-group"><label>Email</label><input type="email" name="email" readonly></div>
    </div>
    </fieldset>

    <div style="text-align: center; margin-top: 20px;">
        <input type="submit" value="Save" style="padding: 10px 55px; background: #3F51B5; color: white; border: none; border-radius: 5px; font-size: 15px; cursor: pointer;">
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
window.onload = function() {
    <% String statusType = (String)request.getAttribute("msgType");
       if("success".equals(statusType)) { %>
        document.getElementById("statusPopup").style.display = "flex";
    <% } %>
};

function closeStatusPopup() { document.getElementById("statusPopup").style.display = "none"; }

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