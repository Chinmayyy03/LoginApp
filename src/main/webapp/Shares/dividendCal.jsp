<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String branchCode  = (String) sess.getAttribute("branchCode");
    String user        = (String) sess.getAttribute("userId");
    String today       = new SimpleDateFormat("dd-MM-yyyy").format(new java.util.Date());
    String SERVLET_URL = request.getContextPath() + "/dividendCal";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dividend Calculation</title>
<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    font-family: Arial, sans-serif;
    background: #E6E6FA;
    min-height: 100vh;
    padding: 24px 28px;
    color: #1a1464;
  }

  .page-title {
    text-align: center;
    font-size: 1.35rem;
    font-weight: 700;
    color: #1a1464;
    margin-bottom: 20px;
    letter-spacing: 0.3px;
  }

  /* ── Toast ── */
  #toastContainer {
    position: fixed;
    top: 16px;
    right: 20px;
    z-index: 9999;
    display: flex;
    flex-direction: column;
    gap: 8px;
    pointer-events: none;
  }
  .toast {
    padding: 9px 18px;
    border-radius: 7px;
    font-size: 0.8rem;
    font-weight: 600;
    font-family: inherit;
    box-shadow: 0 3px 14px rgba(26,20,100,0.15);
    opacity: 0;
    transform: translateX(16px);
    transition: opacity 0.25s, transform 0.25s;
    white-space: nowrap;
    pointer-events: none;
    max-width: 300px;
  }
  .toast.show    { opacity: 1; transform: translateX(0); }
  .toast.success { background: #e8f8f0; color: #0a6644; border-left: 4px solid #2db87a; }
  .toast.error   { background: #fff2f2; color: #b52020; border-left: 4px solid #e05050; }
  .toast.info    { background: #eef0fc; color: #1a1464; border-left: 4px solid #6870cc; }

  /* ── Section card ── */
  .section-card {
    background: #ffffff;
    border: 1.5px solid #C8C8E8;
    border-radius: 10px;
    padding: 28px 24px 22px;
    margin-bottom: 16px;
    position: relative;
    max-width: 1000px;
    margin-left: auto;
    margin-right: auto;
  }
  .section-card .card-title {
    position: absolute;
    top: -11px;
    left: 18px;
    background: #ffffff;
    padding: 0 8px;
    font-size: 0.78rem;
    font-weight: 700;
    color: ##1a1a6e;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  /* ── Form fields — all equal width via CSS grid ── */
  .form-row {
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    gap: 14px;
    align-items: end;
  }

  .fg { display: flex; flex-direction: column; gap: 4px; }
  .fg label {
    font-size: 0.72rem;
    font-weight: 700;
    color: #4a4a8a;
    white-space: nowrap;
    text-transform: uppercase;
    letter-spacing: 0.3px;
  }

  input[type="text"],
  input[type="number"],
  input[type="date"] {
    height: 36px;
    padding: 0 10px;
    border: 1.5px solid #C8C8E8;
    border-radius: 6px;
    font-size: 0.83rem;
    font-family: inherit;
    color: #1a1464;
    background: #ffffff;
    outline: none;
    width: 100%;
    transition: border-color 0.15s, box-shadow 0.15s;
  }
  input[type="text"]:focus,
  input[type="number"]:focus,
  input[type="date"]:focus {
    border-color: #6870cc;
    box-shadow: 0 0 0 3px rgba(104,112,204,0.12);
  }
  input[readonly], input[disabled] {
    background: #f0f0f8;
    color: #6060a0;
    cursor: default;
  }
  input.autofilled {
    background: #f4f4ff;
    border-color: #a0a0d8;
  }

  .input-btn { display: flex; gap: 5px; align-items: center; }
  .input-btn input { flex: 1; min-width: 0; }

  .btn-lookup {
    height: 36px;
    min-width: 38px;
    padding: 0 10px;
    background: #1a1464;
    color: #fff;
    border: none;
    border-radius: 6px;
    font-size: 0.85rem;
    font-weight: 700;
    cursor: pointer;
    flex-shrink: 0;
    transition: background 0.12s;
  }
  .btn-lookup:hover { background: #2a2484; }

  /* ── Action buttons ── */
  .action-wrap {
    max-width: 1000px;
    margin: 0 auto 16px;
    background: #ffffff;
    border: 1.5px solid #C8C8E8;
    border-radius: 10px;
    padding: 14px 20px;
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    align-items: center;
    justify-content: center;
  }

  .btn-divider {
    width: 1px;
    height: 26px;
    background: #C8C8E8;
    margin: 0 2px;
    flex-shrink: 0;
  }

  .btn {
    height: 34px;
    padding: 0 16px;
    border-radius: 6px;
    font-size: 0.76rem;
    font-weight: 700;
    font-family: inherit;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    gap: 5px;
    transition: background 0.12s, color 0.12s;
    white-space: nowrap;
    border: 1.5px solid transparent;
  }

  .btn-primary { background: #1a1464; color: #fff; border-color: #1a1464; }
  .btn-primary:hover { background: #2a2484; border-color: #2a2484; }

  .btn-outline { background: #fff; color: #1a1464; border-color: #C8C8E8; }
  .btn-outline:hover { background: #f0f0f8; border-color: #a0a0d8; }

  .btn-excel { background: #fff; color: #1a6e2a; border-color: #5cb870; }
  .btn-excel:hover { background: #f0fff4; }

  .btn-danger { background: #fff; color: #b52020; border-color: #e08080; }
  .btn-danger:hover { background: #fff2f2; }

  .btn-post { background: #fff; color: #0a6644; border-color: #2db87a; }
  .btn-post:hover { background: #e8f8f0; }

  /* ── Lookup popup ── */
  .popup-overlay {
    display: none;
    position: fixed;
    top: 0; left: 0;
    width: 100%; height: 100%;
    background: rgba(0,0,0,0.35);
    z-index: 1000;
    justify-content: center;
    align-items: center;
  }
  .popup-overlay.show { display: flex; }
  .popup-box {
    background: #fff;
    border: 1.5px solid #C8C8E8;
    border-radius: 10px;
    min-width: 340px;
    overflow: hidden;
    box-shadow: 0 8px 32px rgba(26,20,100,0.18);
  }
  .popup-header {
    background: #1a1464;
    color: #fff;
    padding: 10px 16px;
    font-size: 0.83rem;
    font-weight: 700;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  .popup-close {
    cursor: pointer;
    font-size: 1rem;
    font-weight: 700;
    color: #fff;
    background: none;
    border: none;
    line-height: 1;
  }
  .popup-body { padding: 14px; }

  .lookup-tbl {
    width: 100%;
    border-collapse: collapse;
    font-size: 0.82rem;
    background: #fff;
    border-radius: 6px;
    overflow: hidden;
    border: 1.5px solid #C8C8E8;
  }
  .lookup-tbl thead tr { background: #1a1464; color: #fff; }
  .lookup-tbl thead th { padding: 8px 16px; text-align: left; font-weight: 700; }
  .lookup-tbl tbody tr { cursor: pointer; }
  .lookup-tbl tbody tr:hover { background: #eeeef8; }
  .lookup-tbl tbody td { padding: 10px 16px; border-bottom: 1px solid #E8E8F4; color: #1a1464; font-weight: 600; }

  /* ── Result grid ── */
  .result-card {
    background: #ffffff;
    border: 1.5px solid #C8C8E8;
    border-radius: 10px;
    padding: 28px 20px 18px;
    margin-bottom: 18px;
    position: relative;
    max-width: 1200px;
    margin-left: auto;
    margin-right: auto;
  }
  .result-card .card-title {
    position: absolute;
    top: -11px;
    left: 18px;
    background: #ffffff;
    padding: 0 8px;
    font-size: 0.78rem;
    font-weight: 700;
    color: #6870cc;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .summary-bar { display: flex; gap: 10px; margin-bottom: 14px; flex-wrap: wrap; }
  .summary-item {
    background: #f4f4ff;
    border: 1.5px solid #C8C8E8;
    border-radius: 6px;
    padding: 5px 14px;
    font-size: 0.75rem;
    font-weight: 700;
    color: #1a1464;
  }
  .summary-item span { font-weight: 400; color: #5050a0; margin-left: 5px; }

  .table-wrap { overflow-x: auto; border-radius: 8px; border: 1.5px solid #C8C8E8; }
  table.res-tbl { width: 100%; border-collapse: collapse; font-size: 0.78rem; background: #fff; min-width: 900px; }
  table.res-tbl thead tr { background: #1a1464; color: #fff; }
  table.res-tbl thead th { padding: 8px 10px; text-align: left; font-weight: 700; white-space: nowrap; border-right: 1px solid #2a2474; }
  table.res-tbl thead th:last-child { border-right: none; }
  table.res-tbl tbody tr:nth-child(even) { background: #f6f6fb; }
  table.res-tbl tbody tr:hover { background: #eeeef8; }
  table.res-tbl tbody td { padding: 6px 10px; border-bottom: 1px solid #E4E4F4; color: #1a1464; white-space: nowrap; }
  table.res-tbl tfoot tr { background: #1a1464; color: #fff; }
  table.res-tbl tfoot td { padding: 7px 10px; font-weight: 700; }
</style>
</head>
<body>

<div id="toastContainer"></div>

<div class="page-title">Dividend Calculation</div>

<!-- Lookup Popup -->
<div class="popup-overlay" id="lookupPopup">
  <div class="popup-box">
    <div class="popup-header">
      <span>Select Member Type</span>
      <button class="popup-close" type="button" onclick="closePopup()">&#x2715;</button>
    </div>
    <div class="popup-body">
      <table class="lookup-tbl">
        <thead><tr><th>Product Code</th><th>Member Type</th></tr></thead>
        <tbody id="lookupBody">
          <tr><td colspan="2" style="text-align:center;color:#888;padding:14px;">Loading&#8230;</td></tr>
        </tbody>
      </table>
    </div>
  </div>
</div>

<!-- Form — 6 equal columns -->
<div class="section-card">
  <span class="card-title">Report Details</span>
  <div class="form-row">

    <div class="fg">
      <label>Product Code</label>
      <div class="input-btn">
        <input type="text" id="productCode" readonly placeholder="&#8212;" />
        <button class="btn-lookup" type="button" onclick="lookupProduct()">&#8230;</button>
      </div>
    </div>

    <div class="fg">
      <label>Member Type</label>
      <input type="text" id="memberType" readonly placeholder="&#8212;" />
    </div>

    <div class="fg">
      <label>Year Begin</label>
      <input type="date" id="yearBegin" />
    </div>

    <div class="fg">
      <label>Year End</label>
      <input type="date" id="yearEnd" />
    </div>

    <div class="fg">
      <label>Div. Balance Date</label>
      <input type="date" id="divBalDate" />
    </div>

    <div class="fg">
      <label>Percentage (%)</label>
      <input type="number" id="percentage" step="0.01" placeholder="0.00" />
    </div>

  </div>
</div>

<!-- Action Buttons — single grouped bar -->
<div class="action-wrap">
  <button class="btn btn-primary" type="button" onclick="validateForm()">&#10004; Validate</button>
  <button class="btn btn-outline" type="button" onclick="calculate()">&#9881; Calculate</button>

  <div class="btn-divider"></div>

  <button class="btn btn-outline" type="button" onclick="showReport('normal')">Report</button>
  <button class="btn btn-outline" type="button" onclick="showReport('sb')">SB Report</button>
  <button class="btn btn-excel"   type="button" onclick="showReport('sbXls')">
    <svg width="12" height="12" viewBox="0 0 16 16" fill="none"><rect x="1" y="1" width="14" height="14" rx="2" stroke="#1a6e2a" stroke-width="1.4"/><path d="M4 5l2.5 3L4 11M8 11h4" stroke="#1a6e2a" stroke-width="1.2" stroke-linecap="round"/></svg>
    SB XLS
  </button>
  <button class="btn btn-outline" type="button" onclick="showReport('payable')">Payable Report</button>
  <button class="btn btn-excel"   type="button" onclick="showReport('payableXls')">
    <svg width="12" height="12" viewBox="0 0 16 16" fill="none"><rect x="1" y="1" width="14" height="14" rx="2" stroke="#1a6e2a" stroke-width="1.4"/><path d="M4 5l2.5 3L4 11M8 11h4" stroke="#1a6e2a" stroke-width="1.2" stroke-linecap="round"/></svg>
    Payable XLS
  </button>
  <button class="btn btn-danger"  type="button" onclick="openReportPDF()">
    <svg width="13" height="13" viewBox="0 0 16 16" fill="none">
      <rect x="2" y="1" width="9" height="12" rx="1" stroke="#b52020" stroke-width="1.3"/>
      <path d="M11 1l3 3v9a1 1 0 01-1 1H5" stroke="#b52020" stroke-width="1.3" stroke-linecap="round"/>
      <path d="M11 1v3h3" stroke="#b52020" stroke-width="1.1" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>
    PDF
  </button>

  <div class="btn-divider"></div>

  <button class="btn btn-post"   type="button" onclick="postingPayable()">&#8679; Post Payable</button>
  <button class="btn btn-post"   type="button" onclick="postingSB()">&#8679; Post SB</button>

  <div class="btn-divider"></div>

  <button class="btn btn-danger" type="button" onclick="cancelForm()">&#10005; Cancel</button>
</div>

<!-- Result Grid -->
<div class="result-card" id="resultCard" style="display:none">
  <span class="card-title" id="resultTitle">Dividend Report</span>
  <div class="summary-bar" id="summaryBar"></div>
  <div class="table-wrap">
    <table class="res-tbl">
      <thead id="resultHead"></thead>
      <tbody id="resultBody"></tbody>
      <tfoot id="resultFoot"></tfoot>
    </table>
  </div>
</div>

<script>
  var PAGE_URL = '<%= SERVLET_URL %>';

  // ── Toast ──
  function showToast(msg, type, duration) {
    var container = document.getElementById('toastContainer');
    var t = document.createElement('div');
    t.className = 'toast ' + (type || 'info');
    t.textContent = msg;
    container.appendChild(t);
    requestAnimationFrame(function() {
      requestAnimationFrame(function() { t.classList.add('show'); });
    });
    setTimeout(function() {
      t.classList.remove('show');
      setTimeout(function() { if (t.parentNode) t.parentNode.removeChild(t); }, 300);
    }, duration || 3500);
  }

  // ── AJAX POST helper ──
  function ajaxPost(url, body, onSuccess, onError) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onreadystatechange = function() {
      if (xhr.readyState !== 4) return;
      if (xhr.status !== 200) { if (onError) onError(); return; }
      try {
        var raw = xhr.responseText;
        var si  = raw.indexOf('[');
        var si2 = raw.indexOf('{');
        if (si !== -1 && (si2 === -1 || si < si2)) raw = raw.substring(si);
        else if (si2 !== -1) raw = raw.substring(si2);
        onSuccess(JSON.parse(raw.trim()));
      } catch(e) { if (onError) onError(); }
    };
    xhr.send(body);
  }

  function buildBody(params) {
    return Object.keys(params).map(function(k) {
      return encodeURIComponent(k) + '=' + encodeURIComponent(params[k]);
    }).join('&');
  }

  ['yearBegin','yearEnd','divBalDate','percentage'].forEach(function(id) {
    document.getElementById(id).addEventListener('change', function() {
      this.classList.remove('autofilled');
    });
  });

  // ── Lookup popup ──
  function lookupProduct() {
    document.getElementById('lookupPopup').classList.add('show');
    ajaxPost(PAGE_URL, buildBody({ action: 'getMemberTypes' }), function(data) {
      var html = '';
      if (!Array.isArray(data) || data.length === 0) {
        html = '<tr><td colspan="2" style="text-align:center;color:#888;padding:14px;">No member types found.</td></tr>';
      } else {
        data.forEach(function(row) {
          html += '<tr onclick="selectMemberType(\'' + row.productCode + '\',\'' + row.memberType + '\')">'
                + '<td>' + row.productCode + '</td><td>' + row.memberType + '</td></tr>';
        });
      }
      document.getElementById('lookupBody').innerHTML = html;
    }, function() {
      document.getElementById('lookupBody').innerHTML =
        '<tr><td colspan="2" style="text-align:center;color:#b52020;padding:14px;">Failed to load.</td></tr>';
    });
  }

  function closePopup() { document.getElementById('lookupPopup').classList.remove('show'); }

  function selectMemberType(productCode, memberType) {
    closePopup();
    document.getElementById('productCode').value = productCode;
    document.getElementById('memberType').value  = memberType;

    ajaxPost(PAGE_URL, buildBody({ action: 'getDefaults' }), function(data) {
      if (data.success) {
        var fields = { yearBegin: data.yearBegin, yearEnd: data.yearEnd,
                       divBalDate: data.divBalDate, percentage: data.percentage };
        Object.keys(fields).forEach(function(id) {
          if (fields[id]) {
            document.getElementById(id).value = fields[id];
            document.getElementById(id).classList.add('autofilled');
          }
        });
      }
      fetchAccountCount(productCode, memberType);
    }, function() {
      showToast('Network error loading defaults.', 'error');
    });
  }

  function fetchAccountCount(productCode, memberType) {
    ajaxPost(PAGE_URL, buildBody({ action: 'getAccounts', memberType: memberType, productCode: productCode }),
    function(data) {
      if (data.success) showToast(data.count + ' active accounts found.', 'success');
    }, function() { /* silent */ });
  }

  // ── Validate ──
  function validateForm() {
    var checks = [
      [!document.getElementById('productCode').value.trim(), 'Select a Product Code first.'],
      [!document.getElementById('memberType').value.trim(),  'Member Type is required.'],
      [!document.getElementById('yearBegin').value,          'Year Begin is required.'],
      [!document.getElementById('yearEnd').value,            'Year End is required.'],
      [!document.getElementById('divBalDate').value,         'Div. Balance Date is required.'],
      [!document.getElementById('percentage').value,         'Percentage is required.'],
      [document.getElementById('yearBegin').value >= document.getElementById('yearEnd').value, 'Year End must be after Year Begin.']
    ];
    for (var i = 0; i < checks.length; i++) {
      if (checks[i][0]) { showToast(checks[i][1], 'error'); return false; }
    }
    return true;
  }

  // ── Calculate ──
  function calculate() {
    if (!validateForm()) return;
    showToast('Calculating dividend\u2026', 'info');
    ajaxPost(PAGE_URL, buildBody({
      action: 'calculate',
      productCode: document.getElementById('productCode').value,
      memberType:  document.getElementById('memberType').value,
      yearBegin:   document.getElementById('yearBegin').value,
      yearEnd:     document.getElementById('yearEnd').value,
      divBalDate:  document.getElementById('divBalDate').value,
      percentage:  document.getElementById('percentage').value
    }), function(data) {
      showToast(data.message || (data.success ? 'Calculation complete.' : 'Calculation failed.'),
                data.success ? 'success' : 'error');
    }, function() { showToast('Network error during calculation.', 'error'); });
  }

  // ── showReport ──
  function showReport(type) {
    if (!validateForm()) return;
    if (type === 'sbXls')      { openExcelDownload('reportSBXls');  return; }
    if (type === 'payableXls') { openExcelDownload('reportCRXls');  return; }
    var actionMap = { normal: 'reportMain', sb: 'reportSB', payable: 'reportCR' };
    showToast('Fetching report\u2026', 'info');
    ajaxPost(PAGE_URL, buildBody({
      action:      actionMap[type] || 'reportMain',
      productCode: document.getElementById('productCode').value,
      memberType:  document.getElementById('memberType').value,
      yearBegin:   document.getElementById('yearBegin').value,
      yearEnd:     document.getElementById('yearEnd').value,
      divBalDate:  document.getElementById('divBalDate').value
    }), function(data) {
      if (!data.success) { showToast(data.message || 'Error loading report.', 'error'); return; }
      if (data.count === 0) { showToast('No records found.', 'error'); return; }
      renderReport(data, type);
      showToast(data.count + ' records loaded.', 'success');
    }, function() { showToast('Network error loading report.', 'error'); });
  }

  function openExcelDownload(action) {
    if (!validateForm()) return;
    showToast('Preparing Excel download\u2026', 'info');
    var params = ['action=' + encodeURIComponent(action),
      'productCode=' + encodeURIComponent(document.getElementById('productCode').value),
      'memberType='  + encodeURIComponent(document.getElementById('memberType').value),
      'yearBegin='   + encodeURIComponent(document.getElementById('yearBegin').value),
      'yearEnd='     + encodeURIComponent(document.getElementById('yearEnd').value),
      'divBalDate='  + encodeURIComponent(document.getElementById('divBalDate').value)
    ].join('&');
    window.location.href = PAGE_URL + '?' + params;
  }

  function renderReport(data, type) {
    document.getElementById('resultCard').style.display = 'block';
    var pc  = document.getElementById('productCode').value;
    var mt  = document.getElementById('memberType').value;
    var yb  = document.getElementById('yearBegin').value;
    var ye  = document.getElementById('yearEnd').value;
    var pct = document.getElementById('percentage').value;
    var isSB = (type === 'sb'), isPayable = (type === 'payable');

    document.getElementById('resultTitle').textContent =
      isSB ? 'SB Report' : isPayable ? 'Payable (CR) Report' : 'Dividend Report';

    document.getElementById('summaryBar').innerHTML =
      '<div class="summary-item">Members <span>' + data.count + '</span></div>' +
      '<div class="summary-item">Product <span>' + pc + '</span></div>' +
      '<div class="summary-item">Type <span>' + mt + '</span></div>' +
      '<div class="summary-item">Period <span>' + yb + ' \u2013 ' + ye + '</span></div>' +
      '<div class="summary-item">Rate <span>' + pct + '%</span></div>' +
      '<div class="summary-item">Total Dividend <span>&#8377; ' + parseFloat(data.total).toFixed(2) + '</span></div>';

    var hdr = '<tr><th>#</th><th>Member Code</th><th>Name</th>' +
      '<th>Bal. for Div (&#8377;)</th><th>Rate %</th>' +
      '<th>Div Amount (&#8377;)</th><th>Post Amount (&#8377;)</th>';
    if (!isPayable) hdr += '<th>CR / SB Account</th>';
    if (isSB)       hdr += '<th>Branch</th>';
    hdr += '</tr>';
    document.getElementById('resultHead').innerHTML = hdr;

    var colCount = isPayable ? 7 : (isSB ? 9 : 8);
    var html = '';
    data.rows.forEach(function(r, i) {
      html += '<tr>' +
        '<td>' + (i+1) + '</td>' +
        '<td>' + (r.memberCode || r.member_code || '-') + '</td>' +
        '<td>' + (r.name || '-') + '</td>' +
        '<td style="text-align:right">' + parseFloat(r.balForDiv || r.bal_shares_for_div || 0).toFixed(2) + '</td>' +
        '<td style="text-align:right">' + (r.divPercentage || r.div_percentage || 0) + '%</td>' +
        '<td style="text-align:right">' + parseFloat(r.divAmount || r.div_amount || 0).toFixed(2) + '</td>' +
        '<td style="text-align:right;font-weight:700">' + parseFloat(r.divAmountPost || r.div_amount_post || 0).toFixed(2) + '</td>';
      if (!isPayable) { var cr = r.crAccountCode || r.cr_account_code || ''; html += '<td>' + (cr && cr !== '0' ? cr : '-') + '</td>'; }
      if (isSB)       { html += '<td>' + (r.branchCode || r.branch_code || '-') + '</td>'; }
      html += '</tr>';
    });
    document.getElementById('resultBody').innerHTML = html;
    document.getElementById('resultFoot').innerHTML =
      '<tr><td colspan="' + (colCount-1) + '" style="text-align:right">Total Dividend to Post :</td>' +
      '<td style="text-align:right">&#8377; ' + parseFloat(data.total).toFixed(2) + '</td></tr>';

    document.getElementById('resultCard').scrollIntoView({ behavior: 'smooth' });
  }

  function openReportPDF() {
    if (!validateForm()) return;
    showToast('Opening PDF\u2026', 'info');
    var params = ['action=reportPDF',
      'productCode=' + encodeURIComponent(document.getElementById('productCode').value),
      'memberType='  + encodeURIComponent(document.getElementById('memberType').value),
      'yearBegin='   + encodeURIComponent(document.getElementById('yearBegin').value),
      'yearEnd='     + encodeURIComponent(document.getElementById('yearEnd').value),
      'divBalDate='  + encodeURIComponent(document.getElementById('divBalDate').value),
      'percentage='  + encodeURIComponent(document.getElementById('percentage').value)
    ].join('&');
    window.open(PAGE_URL + '?' + params, '_blank');
  }

  function postingPayable() {
    if (!validateForm()) return;
    if (!confirm('Post dividend to all payable accounts? This cannot be undone.')) return;
    showToast('Posting to payable accounts\u2026', 'info');
    ajaxPost(PAGE_URL, buildBody({
      action: 'postingPayable',
      productCode: document.getElementById('productCode').value,
      memberType:  document.getElementById('memberType').value,
      yearBegin:   document.getElementById('yearBegin').value,
      yearEnd:     document.getElementById('yearEnd').value,
      divBalDate:  document.getElementById('divBalDate').value
    }), function(data) {
      showToast(data.message || (data.success ? 'Payable posting complete.' : 'Posting failed.'),
                data.success ? 'success' : 'error');
      if (data.success) showReport('normal');
    }, function() { showToast('Network error during posting.', 'error'); });
  }

  function postingSB() {
    if (!validateForm()) return;
    if (!confirm('Post dividend to SB accounts? This cannot be undone.')) return;
    showToast('Posting to SB accounts\u2026', 'info');
    ajaxPost(PAGE_URL, buildBody({
      action: 'postingSB',
      productCode: document.getElementById('productCode').value,
      memberType:  document.getElementById('memberType').value,
      yearBegin:   document.getElementById('yearBegin').value,
      yearEnd:     document.getElementById('yearEnd').value,
      divBalDate:  document.getElementById('divBalDate').value
    }), function(data) {
      showToast(data.message || (data.success ? 'SB posting complete.' : 'SB posting failed.'),
                data.success ? 'success' : 'error');
      if (data.success) showReport('sb');
    }, function() { showToast('Network error during SB posting.', 'error'); });
  }

  function cancelForm() {
    if (confirm('Clear the form?')) {
      ['productCode','memberType','yearBegin','yearEnd','divBalDate','percentage']
        .forEach(function(id) { document.getElementById(id).value = ''; });
      ['yearBegin','yearEnd','divBalDate','percentage'].forEach(function(id) {
        document.getElementById(id).classList.remove('autofilled');
      });
      document.getElementById('resultCard').style.display = 'none';
      showToast('Form cleared.', 'info');
    }
  }
</script>
</body>
</html>
