<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String userId     = (String) session.getAttribute("userId");
    String branchCode = (String) session.getAttribute("branchCode");
    String bankCode   = "";
    String bankName   = "";
    String workingDate = "";

    if (userId == null || branchCode == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT B.BANK_CODE, H.NAME, B.WORKING_DATE " +
            "FROM HEADOFFICE.BRANCH B JOIN HEADOFFICE.HEADOFFICE H ON B.BANK_CODE = H.BANK_CODE " +
            "WHERE B.BRANCH_CODE = ?");
        ps.setString(1, branchCode);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            bankCode    = rs.getString("BANK_CODE");
            bankName    = rs.getString("NAME");
            workingDate = rs.getString("WORKING_DATE");
        }
    } catch (Exception e) { /* ignore */ }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>User Denomination Master</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(160deg,#dbeeff 0%,#c4dff7 100%);
            min-height:100vh; padding:20px; font-size:13px;
        }
        .page-wrapper {
            max-width:760px; margin:0 auto;
            background:rgba(255,255,255,0.65);
            border-radius:12px;
            box-shadow:0 4px 24px rgba(74,144,226,.18);
            overflow:hidden;
        }
        .bank-header {
            background:linear-gradient(135deg,#22c55e 0%,#15803d 100%);
            color:#fff; text-align:center; padding:14px 20px 10px;
        }
        .bank-header h2 { font-size:15px; font-weight:700; letter-spacing:.5px; }
        .bank-header h3 { font-size:17px; font-weight:800; margin-top:4px; letter-spacing:1px; }
        .meta-row {
            background:#e8f7ee; display:flex; justify-content:center;
            gap:28px; padding:7px 16px; font-size:12px; color:#1a4a2c;
            font-weight:600; flex-wrap:wrap;
        }
        .meta-row span b { color:#15803d; margin-left:4px; }
        .section-label {
            padding:6px 16px; font-size:11px; font-weight:700;
            color:#15803d; border-bottom:1px solid #bbf7d0;
            background:#f0fdf4; text-transform:uppercase; letter-spacing:.5px;
        }
        .form-block {
            padding:16px 20px; background:#fff;
            display:flex; gap:16px; flex-wrap:wrap; align-items:flex-end;
            border-bottom:1px solid #d1fae5;
        }
        .field-group { display:flex; flex-direction:column; gap:3px; }
        .field-group label { font-size:11px; font-weight:600; color:#4a7a5a; }
        .field-group input, .field-group select {
            padding:5px 10px; border:1px solid #86efac; border-radius:5px;
            background:#f0fdf4; font-size:12px; width:150px; color:#1a4a2c;
        }
        .field-group input:focus, .field-group select:focus {
            outline:none; border-color:#22c55e; background:#fff;
        }
        .denom-section { padding:0 20px 12px; background:#fff; }
        table.denom-table { width:100%; border-collapse:collapse; margin-top:8px; }
        .denom-table thead tr {
            background:linear-gradient(90deg,#22c55e,#4ade80); color:#fff;
        }
        .denom-table thead th {
            padding:7px 10px; text-align:center;
            font-size:12px; font-weight:700;
        }
        .denom-table tbody tr:nth-child(even) { background:#f0fdf4; }
        .denom-table tbody tr:hover { background:#dcfce7; }
        .denom-table td {
            padding:5px 8px; text-align:center;
            font-size:12px; color:#1a4a2c; font-weight:600;
        }
        .denom-table input[type="number"] {
            width:90px; padding:4px 8px;
            border:1px solid #86efac; border-radius:4px;
            text-align:right; font-size:12px;
            background:#f9fffe; color:#1a4a2c;
        }
        .denom-table input:focus { outline:none; border-color:#22c55e; background:#fff; }
        .denom-table input[type="checkbox"] { width:16px; height:16px; cursor:pointer; accent-color:#22c55e; }
        .summary-block {
            padding:10px 20px; background:#e8f7ee;
            display:flex; gap:30px; flex-wrap:wrap;
            border-top:1px solid #bbf7d0;
        }
        .summary-item { display:flex; align-items:center; gap:8px; font-size:12px; font-weight:600; color:#1a4a2c; }
        .summary-item input {
            width:120px; padding:5px 10px;
            border:1px solid #86efac; border-radius:5px;
            background:#fff; font-size:12px; font-weight:700;
            color:#15803d; text-align:right;
        }
        .msg-row {
            padding:10px 20px; background:#fff;
            border-top:1px solid #d1fae5;
            display:flex; align-items:center; gap:10px;
        }
        .msg-row label { font-size:12px; font-weight:600; color:#4a7a5a; white-space:nowrap; }
        .msg-row input { flex:1; padding:6px 10px; border:1px solid #86efac; border-radius:5px; font-size:12px; color:#1a4a2c; }
        .btn-row {
            padding:14px 20px; background:#f0fdf4;
            display:flex; justify-content:center; gap:12px;
            border-top:1px solid #d1fae5;
        }
        .btn { padding:8px 26px; border:none; border-radius:6px; font-size:13px; font-weight:700; cursor:pointer; transition:all .2s; }
        .btn-validate { background:#22c55e; color:#fff; }
        .btn-validate:hover { background:#16a34a; transform:translateY(-1px); }
        .btn-save { background:#2563eb; color:#fff; }
        .btn-save:hover { background:#1d4ed8; transform:translateY(-1px); }
        .btn-cancel { background:#ef4444; color:#fff; }
        .btn-cancel:hover { background:#dc2626; transform:translateY(-1px); }
    </style>
</head>
<body>
<div class="page-wrapper">
    <div class="bank-header">
        <h2><%= bankName.toUpperCase() %></h2>
        <h3>USER DENOMINATION MASTER</h3>
    </div>
    <div class="meta-row">
        <span>BANK CODE : <b><%= bankCode %></b></span>
        <span>BRANCH CODE : <b><%= branchCode %></b></span>
        <span>USER : <b><%= userId %></b></span>
        <span>DATE : <b><%= workingDate %></b></span>
    </div>

    <div class="section-label">Account Details</div>
    <div class="form-block">
        <div class="field-group">
            <label>Effective Date</label>
            <input type="date" id="effectiveDate">
        </div>
        <div class="field-group">
            <label>User ID</label>
            <input type="text" id="mastUserId" placeholder="Enter User ID">
        </div>
        <div class="field-group">
            <label>Denomination Type</label>
            <select id="denomType">
                <option value="">-- Select --</option>
                <option value="IN">Cash In</option>
                <option value="OUT">Cash Out</option>
                <option value="BOTH">Both</option>
            </select>
        </div>
        <div class="field-group">
            <label>Max Limit (₹)</label>
            <input type="number" id="maxLimit" min="0" placeholder="0">
        </div>
    </div>

    <div class="section-label">Denomination Configuration</div>
    <div class="denom-section">
        <table class="denom-table">
            <thead>
                <tr>
                    <th>Denomination (₹)</th>
                    <th>Allowed</th>
                    <th>Min Notes</th>
                    <th>Max Notes</th>
                </tr>
            </thead>
            <tbody id="masterBody"></tbody>
        </table>
    </div>

    <div class="msg-row">
        <label>Message :</label>
        <input type="text" id="message" placeholder="">
    </div>
    <div class="btn-row">
        <button class="btn btn-validate" onclick="validateMaster()">Validate</button>
        <button class="btn btn-save"     onclick="saveMaster()">Save</button>
        <button class="btn btn-cancel"   onclick="cancelMaster()">Cancel</button>
    </div>
</div>

<script>
    const DENOMS = [2000,1000,500,100,50,20,10,5,2,1];
    const tbody = document.getElementById('masterBody');
    DENOMS.forEach(function(d) {
        const tr = document.createElement('tr');
        tr.innerHTML =
            '<td>₹ ' + d + '</td>' +
            '<td><input type="checkbox" checked class="denom-allowed" data-denom="' + d + '"></td>' +
            '<td><input type="number" min="0" value="0" class="min-inp" style="width:80px"></td>' +
            '<td><input type="number" min="0" value="9999" class="max-inp" style="width:80px"></td>';
        tbody.appendChild(tr);
    });

    function validateMaster() {
        if (!document.getElementById('effectiveDate').value) { alert('Please select Effective Date.'); return; }
        if (!document.getElementById('mastUserId').value) { alert('Please enter User ID.'); return; }
        document.getElementById('message').value = 'Validated successfully.';
    }
    function saveMaster() {
        if (!document.getElementById('effectiveDate').value) { alert('Please select Effective Date.'); return; }
        alert('User Denomination Master saved successfully!');
    }
    function cancelMaster() {
        document.getElementById('effectiveDate').value = '';
        document.getElementById('mastUserId').value = '';
        document.getElementById('maxLimit').value = '';
        document.getElementById('message').value = '';
        document.querySelectorAll('.min-inp').forEach(i => i.value = 0);
        document.querySelectorAll('.max-inp').forEach(i => i.value = 9999);
        document.querySelectorAll('.denom-allowed').forEach(i => i.checked = true);
    }
</script>
</body>
</html>
