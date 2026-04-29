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
  <title>Locker Nominee Management</title>
  <link rel="stylesheet" href="../css/addCustomer.css">
  <link rel="stylesheet" href="../css/tabs-navigation.css">
  <script src="<%= request.getContextPath() %>/js/breadcrumb-auto.js"></script>
  <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
  <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>

  <style>
    select.dd-loading {
      color: #999;
      background-color: #f9f9f9;
      font-style: italic;
    }
    .dd-spinner {
      display: inline-block;
      width: 8px; height: 8px;
      border-radius: 50%;
      background: #373279;
      margin-left: 4px;
      animation: ddPulse 0.8s ease-in-out infinite alternate;
      vertical-align: middle;
    }
    @keyframes ddPulse {
      from { opacity: 0.2; transform: scale(0.8); }
      to   { opacity: 1;   transform: scale(1.1); }
    }
    .dd-spinner.done { display: none; }
  </style>
</head>
<body>

<form action="LockerNomineeServlet" method="post" onsubmit="return validateForm()">

  <!-- ════════════════════════════════════════════════════════════════ -->
  <!-- FIELDSET 1: LOCKER & NOMINEE INFORMATION -->
  <!-- ════════════════════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Locker & Nominee Information</legend>
    <div class="form-grid">

      <!-- Row 1 -->
      <div>
        <label>Locker Number</label>
        <input type="text" name="lockerNumber" id="lockerNumber" required>
      </div>

      <div>
        <label>Nominee Name</label>
        <input type="text" name="nomineeName" id="nomineeName" 
               oninput="this.value = this.value.replace(/[^A-Za-z ]/g, '').replace(/\s{2,}/g, ' ').replace(/^\s+/g, '').toLowerCase().replace(/\b\w/g, c => c.toUpperCase());" 
               required>
      </div>

      <div>
        <label>Gender</label>
        <select name="gender" id="gender" required>
          <option value="">-- Select Gender --</option>
          <option>Male</option>
          <option>Female</option>
          <option>Other</option>
        </select>
      </div>

      <div>
        <label>Date of Birth</label>
        <input type="date" name="dateOfBirth" id="dateOfBirth" required>
      </div>

      <!-- Row 2 -->
      <div>
        <label>Relationship <span class="dd-spinner" id="sp-relation"></span></label>
        <select name="relationship" id="relationship" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Email ID</label>
        <input type="email" name="email" id="email">
      </div>

      <div>
        <label>Mobile Number</label>
        <input type="text" name="mobileNumber" id="mobileNumber" 
               oninput="this.value = this.value.replace(/[^0-9]/g, '').slice(0, 10);">
      </div>

      <div>
        <label>Percentage Share</label>
        <input type="number" name="percentageShare" id="percentageShare" min="0" max="100" step="0.01" required>
        <small style="color: #666; font-size: 11px;">Enter value between 0 and 100</small>
      </div>

      <!-- Row 3 -->
      <div>
        <label>Is Nominee Active</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="isActive" value="yes" checked required> Yes</label>
          <label><input type="radio" name="isActive" value="no"> No</label>
        </div>
      </div>

      <div>
        <label>Nomination Date</label>
        <input type="date" name="nominationDate" id="nominationDate" required>
      </div>

      <div>
        <label>Remarks</label>
        <input type="text" name="remarks" id="remarks" maxlength="200">
      </div>

    </div>
  </fieldset>


  <!-- ════════════════════════════════════════════════════════════════ -->
  <!-- FIELDSET 2: ADDRESS INFORMATION -->
  <!-- ════════════════════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Address Information</legend>
    <div class="address-grid">

      <div>
        <label>Address Line 1</label>
        <input type="text" name="address1" id="address1" required>
      </div>

      <div>
        <label>Address Line 2</label>
        <input type="text" name="address2" id="address2">
      </div>

      <div>
        <label>Address Line 3</label>
        <input type="text" name="address3" id="address3">
      </div>

      <div>
        <label>Country <span class="dd-spinner" id="sp-country"></span></label>
        <select name="country" id="country" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>State <span class="dd-spinner" id="sp-state"></span></label>
        <select name="state" id="state" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>City <span class="dd-spinner" id="sp-city"></span></label>
        <select name="city" id="city" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>PIN Code</label>
        <input type="text" name="pinCode" id="pinCode" maxlength="6"
               oninput="this.value = this.value.replace(/[^0-9]/g, '').slice(0, 6);" required>
      </div>

      <div>
        <label>Residence Type <span class="dd-spinner" id="sp-residenceType"></span></label>
        <select name="residenceType" id="residenceType" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

    </div>
  </fieldset>


  <!-- ════════════════════════════════════════════════════════════════ -->
  <!-- FIELDSET 3: DOCUMENT DETAILS -->
  <!-- ════════════════════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Identification Document Details</legend>
    <div class="form-grid">

      <div>
        <label>Document Type <span class="dd-spinner" id="sp-docType"></span></label>
        <select name="documentType" id="documentType" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Document Number</label>
        <input type="text" name="documentNumber" id="documentNumber" required>
      </div>

      <div>
        <label>Document Expiry Date</label>
        <input type="date" name="documentExpiryDate" id="documentExpiryDate">
      </div>

      <div>
        <label>Document Issue Date</label>
        <input type="date" name="documentIssueDate" id="documentIssueDate">
      </div>

    </div>
  </fieldset>


  <!-- ════════════════════════════════════════════════════════════════ -->
  <!-- FIELDSET 4: NOMINEE CONTACT AUTHORIZATION -->
  <!-- ════════════════════════════════════════════════════════════════ -->
  <fieldset>
    <legend>Contact Authorization & Terms</legend>
    <div class="form-grid">

      <div>
        <label>Phone Number (Residence)</label>
        <input type="text" name="residencePhone" id="residencePhone">
      </div>

      <div>
        <label>Phone Number (Office)</label>
        <input type="text" name="officePhone" id="officePhone">
      </div>

      <div>
        <label>Can Bank Contact for Nominee Verification</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="canContactForVerification" value="yes" checked required> Yes</label>
          <label><input type="radio" name="canContactForVerification" value="no"> No</label>
        </div>
      </div>

      <div>
        <label>Preferred Contact Method <span class="dd-spinner" id="sp-contactMethod"></span></label>
        <select name="preferredContactMethod" id="preferredContactMethod" required class="dd-loading">
          <option value="">Loading...</option>
        </select>
      </div>

      <div>
        <label>Declaration Accepted</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="checkbox" name="declarationAccepted" id="declarationAccepted" required> I confirm the nominee details are correct</label>
        </div>
      </div>

    </div>
  </fieldset>


  <!-- ════════════════════════════════════════════════════════════════ -->
  <!-- BUTTON SECTION -->
  <!-- ════════════════════════════════════════════════════════════════ -->
  <div class="form-buttons">
    <button type="submit">Save Nominee</button>
    <button type="reset">Reset</button>
  </div>

</form>

<script src="js/addCustomer.js"></script>
<script>
window.APP_CONTEXT_PATH = '<%= contextPath %>';

// Dropdown configuration
const DD_MAP = {
    relationship:     { id: 'relationship',         sp: 'sp-relation',        codeLabel: false },
    country:          { id: 'country',              sp: 'sp-country',         codeLabel: true },
    state:            { id: 'state',                sp: 'sp-state',           codeLabel: true },
    city:             { id: 'city',                 sp: 'sp-city',            codeLabel: false },
    residenceType:    { id: 'residenceType',        sp: 'sp-residenceType',   codeLabel: false },
    documentType:     { id: 'documentType',         sp: 'sp-docType',         codeLabel: false },
    contactMethod:    { id: 'preferredContactMethod', sp: 'sp-contactMethod',   codeLabel: false }
};

function fillSelect(selectEl, items, codeLabel) {
    selectEl.innerHTML = '';
    const blank = document.createElement('option');
    blank.value = '';
    blank.textContent = '-- Select --';
    selectEl.appendChild(blank);

    items.forEach(function(item) {
        const opt = document.createElement('option');
        opt.value = item.v;
        opt.textContent = codeLabel ? item.v + ' — ' + item.l : item.l;
        selectEl.appendChild(opt);
    });

    selectEl.classList.remove('dd-loading');
    selectEl.style.color = '';
    selectEl.style.fontStyle = '';
}

// Load dropdowns
(function loadAllDropdowns() {
    fetch(window.APP_CONTEXT_PATH + '/loaders/LockerNomineeDataLoader')
        .then(function(res) {
            if (!res.ok) throw new Error('HTTP ' + res.status);
            return res.json();
        })
        .then(function(data) {
            Object.keys(DD_MAP).forEach(function(key) {
                var cfg = DD_MAP[key];
                var selectEl = document.getElementById(cfg.id);
                if (!selectEl) return;

                var items = data[key];
                if (Array.isArray(items)) {
                    fillSelect(selectEl, items, cfg.codeLabel);
                } else {
                    selectEl.innerHTML = '<option value="">-- Error loading --</option>';
                    selectEl.classList.remove('dd-loading');
                }

                if (document.getElementById(cfg.sp)) {
                    document.getElementById(cfg.sp).classList.add('done');
                }
            });
            console.log('✅ All dropdowns loaded via AJAX');
        })
        .catch(function(err) {
            console.error('❌ Dropdown AJAX error:', err);
            Object.keys(DD_MAP).forEach(function(key) {
                var cfg = DD_MAP[key];
                var selectEl = document.getElementById(cfg.id);
                if (selectEl) {
                    selectEl.innerHTML = '<option value="">-- Error: reload page --</option>';
                    selectEl.classList.remove('dd-loading');
                    selectEl.style.borderColor = '#f44336';
                }
            });
        });
})();

function validateForm() {
    var percentageShare = parseFloat(document.getElementById('percentageShare').value);
    if (isNaN(percentageShare) || percentageShare < 0 || percentageShare > 100) {
        alert('Percentage Share must be between 0 and 100');
        return false;
    }
    
    var pinCode = document.getElementById('pinCode').value;
    if (pinCode.length !== 6 || !/^\d{6}$/.test(pinCode)) {
        alert('PIN Code must be exactly 6 digits');
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
            window.buildBreadcrumbPath ? window.buildBreadcrumbPath('Lockers/lockerNominee.jsp') : 'Locker Nominee'
        );
    }
};
</script>

</body>
</html>
