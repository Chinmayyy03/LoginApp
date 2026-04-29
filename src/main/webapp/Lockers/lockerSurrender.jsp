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
  <title>Locker Surrender</title>
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

<form action="LockerSurrenderServlet" method="post" onsubmit="return validateForm()">

  <!-- ══════════════════════════════════════════════════ -->
  <!-- FIELDSET 1: LOCKER & CUSTOMER DETAILS             -->
  <!-- ══════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Locker &amp; Customer Details</legend>
    <div class="form-grid">

      <div>
        <label>Locker Number</label>
        <input type="text" name="lockerNumber" id="lockerNumber" required
               oninput="this.value = this.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();">
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
        <label>Branch Code</label>
        <input type="text" name="branchCode" id="branchCode"
               value="<%= branchCode %>" readonly>
      </div>

      <div>
        <label>Locker Size</label>
        <input type="text" name="lockerSize" id="lockerSize" readonly>
      </div>

      <div>
        <label>Locker Type</label>
        <input type="text" name="lockerType" id="lockerType" readonly>
      </div>

      <div>
        <label>Original Issue Date</label>
        <input type="date" name="originalIssueDate" id="originalIssueDate" readonly>
      </div>

      <div>
        <label>Surrender Date</label>
        <input type="date" name="surrenderDate" id="surrenderDate" required>
      </div>

    </div>
  </fieldset>


  <!-- ══════════════════════════════════════════════════ -->
  <!-- FIELDSET 2: REASON & KEY RETURN                   -->
  <!-- ══════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Reason &amp; Key Return Details</legend>
    <div class="form-grid">

      <div>
        <label>Reason for Surrender <span class="dd-spinner" id="sp-surrenderReason"></span></label>
        <select name="surrenderReason" id="surrenderReason" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Other Reason (if applicable)</label>
        <input type="text" name="otherReason" id="otherReason" maxlength="200">
      </div>

      <div>
        <label>Key Returned</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="keyReturned" value="yes" checked required> Yes</label>
          <label><input type="radio" name="keyReturned" value="no"> No</label>
        </div>
      </div>

      <div>
        <label>Duplicate Key Returned</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="duplicateKeyReturned" value="yes" checked required> Yes</label>
          <label><input type="radio" name="duplicateKeyReturned" value="no"> No</label>
        </div>
      </div>

      <div>
        <label>Key Number</label>
        <input type="text" name="keyNumber" id="keyNumber" readonly>
      </div>

      <div>
        <label>Locker Contents Removed</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="contentsRemoved" value="yes" checked required> Yes</label>
          <label><input type="radio" name="contentsRemoved" value="no"> No</label>
        </div>
      </div>

      <div>
        <label>Locker Inspected by Officer</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="lockerInspected" value="yes" checked required> Yes</label>
          <label><input type="radio" name="lockerInspected" value="no"> No</label>
        </div>
      </div>

      <div>
        <label>Remarks</label>
        <input type="text" name="remarks" id="remarks" maxlength="200">
      </div>

    </div>
  </fieldset>


  <!-- ══════════════════════════════════════════════════ -->
  <!-- FIELDSET 3: RENT & FINANCIAL SETTLEMENT           -->
  <!-- ══════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Rent &amp; Financial Settlement</legend>
    <div class="form-grid">

      <div>
        <label>Security Deposit Paid (₹)</label>
        <input type="number" name="securityDepositPaid" id="securityDepositPaid" readonly min="0" step="0.01">
      </div>

      <div>
        <label>Outstanding Rent (₹)</label>
        <input type="number" name="outstandingRent" id="outstandingRent" readonly min="0" step="0.01">
      </div>

      <div>
        <label>Penalty Amount (₹)</label>
        <input type="number" name="penaltyAmount" id="penaltyAmount" min="0" step="0.01" value="0">
      </div>

      <div>
        <label>Refund Amount (₹)</label>
        <input type="number" name="refundAmount" id="refundAmount" readonly min="0" step="0.01">
      </div>

      <div>
        <label>Rent Paid Upto Date</label>
        <input type="date" name="rentPaidUptoDate" id="rentPaidUptoDate" readonly>
      </div>

      <div>
        <label>Settlement Mode <span class="dd-spinner" id="sp-settlementMode"></span></label>
        <select name="settlementMode" id="settlementMode" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Refund Credit Account</label>
        <input type="text" name="refundCreditAccount" id="refundCreditAccount"
               oninput="this.value = this.value.replace(/[^0-9]/g, '');">
      </div>

      <div>
        <label>Final Settlement Date</label>
        <input type="date" name="finalSettlementDate" id="finalSettlementDate" required>
      </div>

    </div>
  </fieldset>


  <!-- ══════════════════════════════════════════════════ -->
  <!-- FIELDSET 4: AUTHORIZATION & CONFIRMATION          -->
  <!-- ══════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Authorization &amp; Confirmation</legend>
    <div class="form-grid">

      <div>
        <label>Authorized By (Officer ID)</label>
        <input type="text" name="authorizedBy" id="authorizedBy" required
               oninput="this.value = this.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();">
      </div>

      <div>
        <label>Officer Name</label>
        <input type="text" name="officerName" id="officerName" readonly>
      </div>

      <div>
        <label>Surrender Reference No.</label>
        <input type="text" name="surrenderRefNo" id="surrenderRefNo"
               oninput="this.value = this.value.toUpperCase();">
      </div>

      <div>
        <label>Witness Name</label>
        <input type="text" name="witnessName" id="witnessName"
               oninput="this.value = this.value.replace(/[^A-Za-z ]/g, '').replace(/\s{2,}/g,' ').replace(/^\s+/g,'').toLowerCase().replace(/\b\w/g, c => c.toUpperCase());">
      </div>

      <div>
        <label>Customer Signature Obtained</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="signatureObtained" value="yes" checked required> Yes</label>
          <label><input type="radio" name="signatureObtained" value="no"> No</label>
        </div>
      </div>

      <div>
        <label>NOC Issued</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="nocIssued" value="yes" required> Yes</label>
          <label><input type="radio" name="nocIssued" value="no" checked> No</label>
        </div>
      </div>

      <div>
        <label>NOC Reference Number</label>
        <input type="text" name="nocRefNo" id="nocRefNo"
               oninput="this.value = this.value.toUpperCase();">
      </div>

      <div>
        <label>Declaration Accepted</label>
        <div style="flex-direction: row;" class="radio-group">
          <label>
            <input type="checkbox" name="declarationAccepted" id="declarationAccepted" required>
            I confirm the locker surrender details are correct
          </label>
        </div>
      </div>

    </div>
  </fieldset>


  <!-- ══════════════════════════════════════════════════ -->
  <!-- BUTTON SECTION                                    -->
  <!-- ══════════════════════════════════════════════════ -->
  <div class="form-buttons">
    <button type="submit">Surrender Locker</button>
    <button type="reset">Reset</button>
  </div>

</form>

<script>
window.APP_CONTEXT_PATH = '<%= contextPath %>';

const DD_MAP = {
    surrenderReason: { id: 'surrenderReason', sp: 'sp-surrenderReason', codeLabel: false },
    settlementMode:  { id: 'settlementMode',  sp: 'sp-settlementMode',  codeLabel: false }
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
    fetch(window.APP_CONTEXT_PATH + '/loaders/LockerSurrenderDataLoader')
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
    if (!document.getElementById('declarationAccepted').checked) {
        alert('Please accept the declaration');
        return false;
    }
    return true;
}

window.onload = function() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath ? window.buildBreadcrumbPath('Lockers/lockerSurrender.jsp') : 'Locker Surrender'
        );
    }
    // Default surrender date to today
    var today = new Date().toISOString().split('T')[0];
    document.getElementById('surrenderDate').value = today;
    document.getElementById('finalSettlementDate').value = today;
};
</script>
</body>
</html>
