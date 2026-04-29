<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Locker Issue</title>
  <link rel="stylesheet" href="../css/addCustomer.css">
  <link rel="stylesheet" href="../css/tabs-navigation.css">
  <script src="<%= request.getContextPath() %>/js/breadcrumb-auto.js"></script>
  <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
  <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>

  <style>
    select.dd-loading { color: #999; background-color: #f9f9f9; font-style: italic; }
    .dd-spinner {
      display: inline-block; width: 8px; height: 8px; border-radius: 50%;
      background: #373279; margin-left: 4px;
      animation: ddPulse 0.8s ease-in-out infinite alternate; vertical-align: middle;
    }
    @keyframes ddPulse {
      from { opacity: 0.2; transform: scale(0.8); }
      to   { opacity: 1;   transform: scale(1.1); }
    }
    .dd-spinner.done { display: none; }
  </style>
</head>
<body>

<form action="LockerIssueServlet" method="post" onsubmit="return validateForm()">

  <!-- ══════════════════════════════════════════════════ -->
  <!-- FIELDSET 1: LOCKER DETAILS                        -->
  <!-- ══════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Locker Details</legend>
    <div class="form-grid">

      <div>
        <label>Locker Number</label>
        <input type="text" name="lockerNumber" id="lockerNumber" required
               oninput="this.value = this.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();">
      </div>

      <div>
        <label>Locker Size <span class="dd-spinner" id="sp-lockerSize"></span></label>
        <select name="lockerSize" id="lockerSize" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Locker Type <span class="dd-spinner" id="sp-lockerType"></span></label>
        <select name="lockerType" id="lockerType" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Branch Code</label>
        <input type="text" name="issueBranchCode" id="issueBranchCode"
               value="<%= branchCode %>" readonly>
      </div>

      <div>
        <label>Key Number</label>
        <input type="text" name="keyNumber" id="keyNumber" required
               oninput="this.value = this.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();">
      </div>

      <div>
        <label>Duplicate Key Number</label>
        <input type="text" name="duplicateKeyNumber" id="duplicateKeyNumber"
               oninput="this.value = this.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();">
      </div>

      <div>
        <label>Issue Date</label>
        <input type="date" name="issueDate" id="issueDate" required>
      </div>

      <div>
        <label>Locker Location / Vault No.</label>
        <input type="text" name="lockerLocation" id="lockerLocation"
               oninput="this.value = this.value.toUpperCase();">
      </div>

    </div>
  </fieldset>


  <!-- ══════════════════════════════════════════════════ -->
  <!-- FIELDSET 2: CUSTOMER & ACCOUNT INFORMATION        -->
  <!-- ══════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Customer &amp; Account Information</legend>
    <div class="form-grid">

      <div>
        <label>Customer ID</label>
        <input type="text" name="customerId" id="customerId" required
               oninput="this.value = this.value.replace(/[^0-9]/g, '');">
      </div>

      <div>
        <label>Customer Name</label>
        <input type="text" name="customerName" id="customerName" readonly>
      </div>

      <div>
        <label>Account Number</label>
        <input type="text" name="accountNumber" id="accountNumber" required
               oninput="this.value = this.value.replace(/[^0-9]/g, '');">
      </div>

      <div>
        <label>Account Type <span class="dd-spinner" id="sp-accountType"></span></label>
        <select name="accountType" id="accountType" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Mobile Number</label>
        <input type="text" name="mobileNumber" id="mobileNumber"
               oninput="this.value = this.value.replace(/[^0-9]/g, '').slice(0, 10);">
      </div>

      <div>
        <label>Email ID</label>
        <input type="email" name="email" id="email">
      </div>

      <div>
        <label>Aadhar Number</label>
        <input type="text" name="aadharNumber" id="aadharNumber" maxlength="12"
               oninput="this.value = this.value.replace(/[^0-9]/g, '').slice(0, 12);" required>
      </div>

      <div>
        <label>PAN Number</label>
        <input type="text" name="panNumber" id="panNumber" maxlength="10"
               oninput="this.value = this.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase().slice(0, 10);">
      </div>

    </div>
  </fieldset>


  <!-- ══════════════════════════════════════════════════ -->
  <!-- FIELDSET 3: RENT & DEPOSIT DETAILS                -->
  <!-- ══════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Rent &amp; Deposit Details</legend>
    <div class="form-grid">

      <div>
        <label>Annual Rent Amount (₹)</label>
        <input type="number" name="annualRent" id="annualRent" min="0" step="0.01" required>
      </div>

      <div>
        <label>Rent Frequency <span class="dd-spinner" id="sp-rentFrequency"></span></label>
        <select name="rentFrequency" id="rentFrequency" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Security Deposit (₹)</label>
        <input type="number" name="securityDeposit" id="securityDeposit" min="0" step="0.01" required>
      </div>

      <div>
        <label>First Rent Due Date</label>
        <input type="date" name="firstRentDueDate" id="firstRentDueDate" required>
      </div>

      <div>
        <label>Rent Paid Upto Date</label>
        <input type="date" name="rentPaidUptoDate" id="rentPaidUptoDate">
      </div>

      <div>
        <label>Mode of Rent Payment <span class="dd-spinner" id="sp-paymentMode"></span></label>
        <select name="paymentMode" id="paymentMode" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Debit Account for Rent</label>
        <input type="text" name="debitAccount" id="debitAccount"
               oninput="this.value = this.value.replace(/[^0-9]/g, '');">
      </div>

      <div>
        <label>Remarks</label>
        <input type="text" name="remarks" id="remarks" maxlength="200">
      </div>

    </div>
  </fieldset>


  <!-- ══════════════════════════════════════════════════ -->
  <!-- FIELDSET 4: AUTHORIZATION & TERMS                 -->
  <!-- ══════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Authorization &amp; Terms</legend>
    <div class="form-grid">

      <div>
        <label>Authorized By (Officer ID)</label>
        <input type="text" name="authorizedBy" id="authorizedBy" required
               oninput="this.value = this.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();">
      </div>

      <div>
        <label>Witness Name</label>
        <input type="text" name="witnessName" id="witnessName"
               oninput="this.value = this.value.replace(/[^A-Za-z ]/g, '').replace(/\s{2,}/g,' ').replace(/^\s+/g,'').toLowerCase().replace(/\b\w/g, c => c.toUpperCase());">
      </div>

      <div>
        <label>Agreement Reference No.</label>
        <input type="text" name="agreementRefNo" id="agreementRefNo"
               oninput="this.value = this.value.toUpperCase();">
      </div>

      <div>
        <label>Agreement Date</label>
        <input type="date" name="agreementDate" id="agreementDate">
      </div>

      <div>
        <label>Is Locker Active</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="isActive" value="yes" checked required> Yes</label>
          <label><input type="radio" name="isActive" value="no"> No</label>
        </div>
      </div>

      <div>
        <label>Is Insurance Required</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="insuranceRequired" value="yes" required> Yes</label>
          <label><input type="radio" name="insuranceRequired" value="no" checked> No</label>
        </div>
      </div>

      <div>
        <label>Can Joint Access</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="jointAccess" value="yes" required> Yes</label>
          <label><input type="radio" name="jointAccess" value="no" checked> No</label>
        </div>
      </div>

      <div>
        <label>Declaration Accepted</label>
        <div style="flex-direction: row;" class="radio-group">
          <label>
            <input type="checkbox" name="declarationAccepted" id="declarationAccepted" required>
            I confirm all locker issue details are correct
          </label>
        </div>
      </div>

    </div>
  </fieldset>


  <!-- ══════════════════════════════════════════════════ -->
  <!-- BUTTON SECTION                                    -->
  <!-- ══════════════════════════════════════════════════ -->
  <div class="form-buttons">
    <button type="submit">Issue Locker</button>
    <button type="reset">Reset</button>
  </div>

</form>

<script>
window.APP_CONTEXT_PATH = '<%= contextPath %>';

const DD_MAP = {
    lockerSize:    { id: 'lockerSize',    sp: 'sp-lockerSize',    codeLabel: false },
    lockerType:    { id: 'lockerType',    sp: 'sp-lockerType',    codeLabel: false },
    accountType:   { id: 'accountType',   sp: 'sp-accountType',   codeLabel: false },
    rentFrequency: { id: 'rentFrequency', sp: 'sp-rentFrequency', codeLabel: false },
    paymentMode:   { id: 'paymentMode',   sp: 'sp-paymentMode',   codeLabel: false }
};

function fillSelect(selectEl, items, codeLabel) {
    selectEl.innerHTML = '';
    const blank = document.createElement('option');
    blank.value = ''; blank.textContent = '-- Select --';
    selectEl.appendChild(blank);
    items.forEach(function(item) {
        const opt = document.createElement('option');
        opt.value = item.v;
        opt.textContent = codeLabel ? item.v + ' — ' + item.l : item.l;
        selectEl.appendChild(opt);
    });
    selectEl.classList.remove('dd-loading');
    selectEl.style.color = ''; selectEl.style.fontStyle = '';
}

(function loadAllDropdowns() {
    fetch(window.APP_CONTEXT_PATH + '/loaders/LockerIssueDataLoader')
        .then(function(res) { if (!res.ok) throw new Error('HTTP ' + res.status); return res.json(); })
        .then(function(data) {
            Object.keys(DD_MAP).forEach(function(key) {
                var cfg = DD_MAP[key];
                var selectEl = document.getElementById(cfg.id);
                if (!selectEl) return;
                var items = data[key];
                if (Array.isArray(items)) { fillSelect(selectEl, items, cfg.codeLabel); }
                else { selectEl.innerHTML = '<option value="">-- Error loading --</option>'; selectEl.classList.remove('dd-loading'); }
                if (document.getElementById(cfg.sp)) document.getElementById(cfg.sp).classList.add('done');
            });
        })
        .catch(function(err) {
            console.error('Dropdown error:', err);
            Object.keys(DD_MAP).forEach(function(key) {
                var cfg = DD_MAP[key];
                var selectEl = document.getElementById(cfg.id);
                if (selectEl) { selectEl.innerHTML = '<option value="">-- Error: reload page --</option>'; selectEl.classList.remove('dd-loading'); selectEl.style.borderColor = '#f44336'; }
            });
        });
})();

function validateForm() {
    var aadhar = document.getElementById('aadharNumber').value;
    if (aadhar.length !== 12) { alert('Aadhar Number must be exactly 12 digits'); return false; }
    if (!document.getElementById('declarationAccepted').checked) { alert('Please accept the declaration'); return false; }
    return true;
}

window.onload = function() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath ? window.buildBreadcrumbPath('Lockers/lockerIssues.jsp') : 'Locker Issues'
        );
    }
};
</script>
</body>
</html>
