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
  <title>Locker Transaction</title>
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

<form action="LockerTransactionServlet" method="post" onsubmit="return validateForm()">

  <!-- ══════════════════════════════════════════════════ -->
  <!-- FIELDSET 1: TRANSACTION BASIC INFORMATION         -->
  <!-- ══════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Transaction Basic Information</legend>
    <div class="form-grid">

      <div>
        <label>Locker Number</label>
        <input type="text" name="lockerNumber" id="lockerNumber" required
               oninput="this.value = this.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();">
      </div>

      <div>
        <label>Account Holder Name</label>
        <input type="text" name="accountHolderName" id="accountHolderName" readonly>
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
        <label>Transaction Type <span class="dd-spinner" id="sp-transactionType"></span></label>
        <select name="transactionType" id="transactionType" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Transaction Date</label>
        <input type="date" name="transactionDate" id="transactionDate" required>
      </div>

      <div>
        <label>Transaction Reference No.</label>
        <input type="text" name="transactionRefNo" id="transactionRefNo"
               oninput="this.value = this.value.toUpperCase();">
      </div>

      <div>
        <label>Financial Year</label>
        <input type="text" name="financialYear" id="financialYear" readonly>
      </div>

    </div>
  </fieldset>


  <!-- ══════════════════════════════════════════════════ -->
  <!-- FIELDSET 2: RENT / CHARGE DETAILS                 -->
  <!-- ══════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Rent &amp; Charge Details</legend>
    <div class="form-grid">

      <div>
        <label>Transaction Amount (₹)</label>
        <input type="number" name="transactionAmount" id="transactionAmount" min="0" step="0.01" required>
      </div>

      <div>
        <label>Charge Type <span class="dd-spinner" id="sp-chargeType"></span></label>
        <select name="chargeType" id="chargeType" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Rent Period From</label>
        <input type="date" name="rentPeriodFrom" id="rentPeriodFrom">
      </div>

      <div>
        <label>Rent Period To</label>
        <input type="date" name="rentPeriodTo" id="rentPeriodTo">
      </div>

      <div>
        <label>GST Amount (₹)</label>
        <input type="number" name="gstAmount" id="gstAmount" min="0" step="0.01" value="0">
      </div>

      <div>
        <label>Total Amount Payable (₹)</label>
        <input type="number" name="totalAmount" id="totalAmount" min="0" step="0.01" readonly>
      </div>

      <div>
        <label>Late Payment Penalty (₹)</label>
        <input type="number" name="latePaymentPenalty" id="latePaymentPenalty" min="0" step="0.01" value="0">
      </div>

      <div>
        <label>Waiver Amount (₹)</label>
        <input type="number" name="waiverAmount" id="waiverAmount" min="0" step="0.01" value="0">
      </div>

    </div>
  </fieldset>


  <!-- ══════════════════════════════════════════════════ -->
  <!-- FIELDSET 3: PAYMENT & ACCOUNT DETAILS             -->
  <!-- ══════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Payment &amp; Account Details</legend>
    <div class="form-grid">

      <div>
        <label>Payment Mode <span class="dd-spinner" id="sp-paymentMode"></span></label>
        <select name="paymentMode" id="paymentMode" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Debit Account Number</label>
        <input type="text" name="debitAccountNumber" id="debitAccountNumber" required
               oninput="this.value = this.value.replace(/[^0-9]/g, '');">
      </div>

      <div>
        <label>Instrument Number (Chq/DD)</label>
        <input type="text" name="instrumentNumber" id="instrumentNumber"
               oninput="this.value = this.value.replace(/[^0-9]/g, '');">
      </div>

      <div>
        <label>Instrument Date</label>
        <input type="date" name="instrumentDate" id="instrumentDate">
      </div>

      <div>
        <label>Drawee Bank Name</label>
        <input type="text" name="draweeBankName" id="draweeBankName"
               oninput="this.value = this.value.replace(/[^A-Za-z ]/g, '').replace(/\s{2,}/g,' ').replace(/^\s+/g,'').toUpperCase();">
      </div>

      <div>
        <label>IFSC Code</label>
        <input type="text" name="ifscCode" id="ifscCode" maxlength="11"
               oninput="this.value = this.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();">
      </div>

      <div>
        <label>Payment Status <span class="dd-spinner" id="sp-paymentStatus"></span></label>
        <select name="paymentStatus" id="paymentStatus" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Receipt Number</label>
        <input type="text" name="receiptNumber" id="receiptNumber"
               oninput="this.value = this.value.toUpperCase();">
      </div>

    </div>
  </fieldset>


  <!-- ══════════════════════════════════════════════════ -->
  <!-- FIELDSET 4: AUTHORIZATION & AUDIT DETAILS         -->
  <!-- ══════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Authorization &amp; Audit Details</legend>
    <div class="form-grid">

      <div>
        <label>Entered By (Employee ID)</label>
        <input type="text" name="enteredBy" id="enteredBy" required
               oninput="this.value = this.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();">
      </div>

      <div>
        <label>Authorized By (Officer ID)</label>
        <input type="text" name="authorizedBy" id="authorizedBy" required
               oninput="this.value = this.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();">
      </div>

      <div>
        <label>Narration / Description</label>
        <input type="text" name="narration" id="narration" maxlength="200">
      </div>

      <div>
        <label>Voucher Number</label>
        <input type="text" name="voucherNumber" id="voucherNumber"
               oninput="this.value = this.value.toUpperCase();">
      </div>

      <div>
        <label>Is Reversal Transaction</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="isReversal" value="yes" required> Yes</label>
          <label><input type="radio" name="isReversal" value="no" checked> No</label>
        </div>
      </div>

      <div>
        <label>Original Transaction Ref. (if Reversal)</label>
        <input type="text" name="originalTxnRef" id="originalTxnRef"
               oninput="this.value = this.value.toUpperCase();">
      </div>

      <div>
        <label>Receipt Issued</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="receiptIssued" value="yes" checked required> Yes</label>
          <label><input type="radio" name="receiptIssued" value="no"> No</label>
        </div>
      </div>

      <div>
        <label>Declaration Accepted</label>
        <div style="flex-direction: row;" class="radio-group">
          <label>
            <input type="checkbox" name="declarationAccepted" id="declarationAccepted" required>
            I confirm the transaction details are correct
          </label>
        </div>
      </div>

    </div>
  </fieldset>


  <!-- ══════════════════════════════════════════════════ -->
  <!-- BUTTON SECTION                                    -->
  <!-- ══════════════════════════════════════════════════ -->
  <div class="form-buttons">
    <button type="submit">Save Transaction</button>
    <button type="reset">Reset</button>
  </div>

</form>

<script>
window.APP_CONTEXT_PATH = '<%= contextPath %>';

const DD_MAP = {
    transactionType: { id: 'transactionType', sp: 'sp-transactionType', codeLabel: false },
    chargeType:      { id: 'chargeType',      sp: 'sp-chargeType',      codeLabel: false },
    paymentMode:     { id: 'paymentMode',     sp: 'sp-paymentMode',     codeLabel: false },
    paymentStatus:   { id: 'paymentStatus',   sp: 'sp-paymentStatus',   codeLabel: false }
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
    fetch(window.APP_CONTEXT_PATH + '/loaders/LockerTransactionDataLoader')
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

// Auto-calculate total amount
['transactionAmount', 'gstAmount', 'latePaymentPenalty', 'waiverAmount'].forEach(function(id) {
    var el = document.getElementById(id);
    if (el) el.addEventListener('input', calculateTotal);
});

function calculateTotal() {
    var amount  = parseFloat(document.getElementById('transactionAmount').value) || 0;
    var gst     = parseFloat(document.getElementById('gstAmount').value)         || 0;
    var penalty = parseFloat(document.getElementById('latePaymentPenalty').value)|| 0;
    var waiver  = parseFloat(document.getElementById('waiverAmount').value)      || 0;
    document.getElementById('totalAmount').value = (amount + gst + penalty - waiver).toFixed(2);
}

function validateForm() {
    var rentFrom = document.getElementById('rentPeriodFrom').value;
    var rentTo   = document.getElementById('rentPeriodTo').value;
    if (rentFrom && rentTo && rentTo < rentFrom) {
        alert('Rent Period To cannot be before Rent Period From');
        return false;
    }
    if (!document.getElementById('declarationAccepted').checked) {
        alert('Please accept the declaration');
        return false;
    }
    return true;
}

window.onload = function() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath ? window.buildBreadcrumbPath('Lockers/lockerTransaction.jsp') : 'Locker Transaction'
        );
    }
    // Set today's date
    var today = new Date();
    var dateStr = today.toISOString().split('T')[0];
    document.getElementById('transactionDate').value = dateStr;

    // Set financial year
    var month = today.getMonth(); // 0-indexed, April = 3
    var year  = today.getFullYear();
    var fyStart = month >= 3 ? year : year - 1;
    document.getElementById('financialYear').value = fyStart + '-' + (fyStart + 1);
};
</script>
</body>
</html>
