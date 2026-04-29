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
  <title>Locker Attendance</title>
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

<form action="LockerAttendanceServlet" method="post" onsubmit="return validateForm()">

  <!-- ══════════════════════════════════════════════════ -->
  <!-- FIELDSET 1: LOCKER & VISITOR INFORMATION          -->
  <!-- ══════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Locker &amp; Visitor Information</legend>
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
        <label>Visitor Name</label>
        <input type="text" name="visitorName" id="visitorName" required
               oninput="this.value = this.value.replace(/[^A-Za-z ]/g, '').replace(/\s{2,}/g,' ').replace(/^\s+/g,'').toLowerCase().replace(/\b\w/g, c => c.toUpperCase());">
      </div>

      <div>
        <label>Visitor Type <span class="dd-spinner" id="sp-visitorType"></span></label>
        <select name="visitorType" id="visitorType" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Relationship to Holder <span class="dd-spinner" id="sp-relationship"></span></label>
        <select name="relationship" id="relationship" class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Visitor ID Proof Type <span class="dd-spinner" id="sp-idProofType"></span></label>
        <select name="idProofType" id="idProofType" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

    </div>
  </fieldset>


  <!-- ══════════════════════════════════════════════════ -->
  <!-- FIELDSET 2: VISIT DATE, TIME & PURPOSE            -->
  <!-- ══════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Visit Details</legend>
    <div class="form-grid">

      <div>
        <label>Visit Date</label>
        <input type="date" name="visitDate" id="visitDate" required>
      </div>

      <div>
        <label>Entry Time</label>
        <input type="time" name="entryTime" id="entryTime" required>
      </div>

      <div>
        <label>Exit Time</label>
        <input type="time" name="exitTime" id="exitTime">
      </div>

      <div>
        <label>Purpose of Visit <span class="dd-spinner" id="sp-visitPurpose"></span></label>
        <select name="visitPurpose" id="visitPurpose" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Items Carried In</label>
        <input type="text" name="itemsCarriedIn" id="itemsCarriedIn" maxlength="200">
      </div>

      <div>
        <label>Items Carried Out</label>
        <input type="text" name="itemsCarriedOut" id="itemsCarriedOut" maxlength="200">
      </div>

      <div>
        <label>Token / Slip Number</label>
        <input type="text" name="tokenNumber" id="tokenNumber"
               oninput="this.value = this.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();">
      </div>

      <div>
        <label>Visitor Mobile Number</label>
        <input type="text" name="visitorMobile" id="visitorMobile"
               oninput="this.value = this.value.replace(/[^0-9]/g, '').slice(0, 10);">
      </div>

    </div>
  </fieldset>


  <!-- ══════════════════════════════════════════════════ -->
  <!-- FIELDSET 3: STAFF & SECURITY DETAILS              -->
  <!-- ══════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Staff &amp; Security Details</legend>
    <div class="form-grid">

      <div>
        <label>Attended By (Staff ID)</label>
        <input type="text" name="attendedBy" id="attendedBy" required
               oninput="this.value = this.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();">
      </div>

      <div>
        <label>Staff Name</label>
        <input type="text" name="staffName" id="staffName" readonly>
      </div>

      <div>
        <label>Security Guard Name</label>
        <input type="text" name="securityGuardName" id="securityGuardName"
               oninput="this.value = this.value.replace(/[^A-Za-z ]/g, '').replace(/\s{2,}/g,' ').replace(/^\s+/g,'').toLowerCase().replace(/\b\w/g, c => c.toUpperCase());">
      </div>

      <div>
        <label>Signature Verified</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="signatureVerified" value="yes" checked required> Yes</label>
          <label><input type="radio" name="signatureVerified" value="no"> No</label>
        </div>
      </div>

      <div>
        <label>ID Proof Verified</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="idProofVerified" value="yes" checked required> Yes</label>
          <label><input type="radio" name="idProofVerified" value="no"> No</label>
        </div>
      </div>

      <div>
        <label>CCTV Available</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="cctvAvailable" value="yes" checked required> Yes</label>
          <label><input type="radio" name="cctvAvailable" value="no"> No</label>
        </div>
      </div>

      <div>
        <label>Locker Key Handover Verified</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="keyHandoverVerified" value="yes" checked required> Yes</label>
          <label><input type="radio" name="keyHandoverVerified" value="no"> No</label>
        </div>
      </div>

      <div>
        <label>Remarks</label>
        <input type="text" name="remarks" id="remarks" maxlength="200">
      </div>

    </div>
  </fieldset>


  <!-- ══════════════════════════════════════════════════ -->
  <!-- FIELDSET 4: CONFIRMATION                          -->
  <!-- ══════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Confirmation &amp; Authorization</legend>
    <div class="form-grid">

      <div>
        <label>Attendance Reference No.</label>
        <input type="text" name="attendanceRefNo" id="attendanceRefNo"
               oninput="this.value = this.value.toUpperCase();">
      </div>

      <div>
        <label>Previous Visit Date</label>
        <input type="date" name="previousVisitDate" id="previousVisitDate" readonly>
      </div>

      <div>
        <label>Total Visits (This Month)</label>
        <input type="number" name="totalVisitsMonth" id="totalVisitsMonth" readonly min="0">
      </div>

      <div>
        <label>Locker Status <span class="dd-spinner" id="sp-lockerStatus"></span></label>
        <select name="lockerStatus" id="lockerStatus" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Authorized by Manager</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="managerAuthorized" value="yes" required> Yes</label>
          <label><input type="radio" name="managerAuthorized" value="no" checked> No</label>
        </div>
      </div>

      <div>
        <label>Manager Employee ID</label>
        <input type="text" name="managerEmpId" id="managerEmpId"
               oninput="this.value = this.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();">
      </div>

      <div>
        <label>Visitor Biometric Captured</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="biometricCaptured" value="yes" required> Yes</label>
          <label><input type="radio" name="biometricCaptured" value="no" checked> No</label>
        </div>
      </div>

      <div>
        <label>Declaration Accepted</label>
        <div style="flex-direction: row;" class="radio-group">
          <label>
            <input type="checkbox" name="declarationAccepted" id="declarationAccepted" required>
            I confirm the attendance entry is accurate
          </label>
        </div>
      </div>

    </div>
  </fieldset>


  <!-- ══════════════════════════════════════════════════ -->
  <!-- BUTTON SECTION                                    -->
  <!-- ══════════════════════════════════════════════════ -->
  <div class="form-buttons">
    <button type="submit">Save Attendance</button>
    <button type="reset">Reset</button>
  </div>

</form>

<script>
window.APP_CONTEXT_PATH = '<%= contextPath %>';

const DD_MAP = {
    visitorType:   { id: 'visitorType',   sp: 'sp-visitorType',   codeLabel: false },
    relationship:  { id: 'relationship',  sp: 'sp-relationship',  codeLabel: false },
    idProofType:   { id: 'idProofType',   sp: 'sp-idProofType',   codeLabel: false },
    visitPurpose:  { id: 'visitPurpose',  sp: 'sp-visitPurpose',  codeLabel: false },
    lockerStatus:  { id: 'lockerStatus',  sp: 'sp-lockerStatus',  codeLabel: false }
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
    fetch(window.APP_CONTEXT_PATH + '/loaders/LockerAttendanceDataLoader')
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
    var entry = document.getElementById('entryTime').value;
    var exit  = document.getElementById('exitTime').value;
    if (exit && exit < entry) { alert('Exit Time cannot be before Entry Time'); return false; }
    if (!document.getElementById('declarationAccepted').checked) { alert('Please accept the declaration'); return false; }
    return true;
}

window.onload = function() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath ? window.buildBreadcrumbPath('Lockers/lockerAttendance.jsp') : 'Locker Attendance'
        );
    }
    // Set today's date and current time as defaults
    var today = new Date();
    var dateStr = today.toISOString().split('T')[0];
    var timeStr = today.toTimeString().slice(0, 5);
    document.getElementById('visitDate').value = dateStr;
    document.getElementById('entryTime').value = timeStr;
};
</script>
</body>
</html>
