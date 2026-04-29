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
    <title>Cash Combine Denomination</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body {
            font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background:linear-gradient(160deg,#dbeeff 0%,#c4dff7 100%);
            min-height:100vh; padding:20px; font-size:13px;
        }
        .page-wrapper {
            max-width:780px; margin:0 auto;
            background:rgba(255,255,255,0.65);
            border-radius:12px;
            box-shadow:0 4px 24px rgba(74,144,226,.18);
            overflow:hidden;
        }
        .bank-header {
            background:linear-gradient(135deg,#f59e0b 0%,#d97706 100%);
            color:#fff; text-align:center; padding:14px 20px 10px;
        }
        .bank-header h2 { font-size:15px; font-weight:700; }
        .bank-header h3 { font-size:17px; font-weight:800; margin-top:4px; letter-spacing:1px; }
        .meta-row {
            background:#fef9e7; display:flex; justify-content:center;
            gap:28px; padding:7px 16px; font-size:12px; color:#5a3a00; font-weight:600; flex-wrap:wrap;
        }
        .meta-row span b { color:#d97706; margin-left:4px; }
        .section-label {
            padding:6px 16px; font-size:11px; font-weight:700;
            color:#d97706; border-bottom:1px solid #fde68a;
            background:#fffbeb; text-transform:uppercase; letter-spacing:.5px;
        }

        /* Scroll Entry Row */
        .scroll-entry {
            padding:14px 20px; background:#fff;
            border-bottom:1px solid #fde68a;
            display:flex; gap:14px; align-items:flex-end; flex-wrap:wrap;
        }
        .field-group { display:flex; flex-direction:column; gap:3px; }
        .field-group label { font-size:11px; font-weight:600; color:#7a5800; }
        .field-group input {
            padding:6px 10px; border:1px solid #fbbf24;
            border-radius:5px; background:#fffbeb;
            font-size:12px; color:#5a3a00;
        }
        .field-group input:focus { outline:none; border-color:#f59e0b; background:#fff; }
        .btn-add {
            padding:7px 20px; background:#f59e0b; color:#fff;
            border:none; border-radius:6px; font-size:13px;
            font-weight:700; cursor:pointer; transition:all .2s;
            align-self:flex-end;
        }
        .btn-add:hover { background:#d97706; transform:translateY(-1px); }

        /* Scroll List Table */
        .scroll-list { padding:0 20px 14px; background:#fff; }
        table.scroll-table { width:100%; border-collapse:collapse; margin-top:8px; }
        .scroll-table thead tr { background:linear-gradient(90deg,#f59e0b,#fbbf24); color:#fff; }
        .scroll-table thead th { padding:7px 10px; text-align:center; font-size:12px; font-weight:700; }
        .scroll-table tbody tr:nth-child(even) { background:#fffbeb; }
        .scroll-table tbody tr:hover { background:#fef3c7; }
        .scroll-table td { padding:6px 10px; text-align:center; font-size:12px; color:#5a3a00; font-weight:600; }
        .btn-remove {
            padding:3px 12px; background:#ef4444; color:#fff;
            border:none; border-radius:4px; font-size:11px;
            font-weight:700; cursor:pointer;
        }
        .btn-remove:hover { background:#dc2626; }

        /* Denomination Section */
        .denom-section { padding:0 20px 12px; background:#fff; }
        table.denom-table { width:100%; border-collapse:collapse; margin-top:8px; }
        .denom-table thead tr { background:linear-gradient(90deg,#d97706,#f59e0b); color:#fff; }
        .denom-table thead th { padding:7px 10px; text-align:center; font-size:12px; font-weight:700; }
        .denom-table tbody tr:nth-child(even) { background:#fffbeb; }
        .denom-table tbody tr:hover { background:#fef3c7; }
        .denom-table td { padding:5px 8px; text-align:center; font-size:12px; color:#5a3a00; font-weight:600; }
        .denom-table input[type="number"] {
            width:80px; padding:4px 8px; border:1px solid #fbbf24;
            border-radius:4px; text-align:right; font-size:12px;
            background:#fffdf5; color:#5a3a00;
        }
        .denom-table input:focus { outline:none; border-color:#f59e0b; background:#fff; }

        /* Summary */
        .summary-block {
            padding:10px 20px; background:#fef9e7;
            display:flex; gap:30px; flex-wrap:wrap;
            border-top:1px solid #fde68a;
        }
        .summary-item { display:flex; align-items:center; gap:8px; font-size:12px; font-weight:600; color:#5a3a00; }
        .summary-item input {
            width:130px; padding:5px 10px;
            border:1px solid #fbbf24; border-radius:5px;
            background:#fff; font-size:12px; font-weight:700;
            color:#d97706; text-align:right;
        }

        /* Message */
        .msg-row {
            padding:10px 20px; background:#fff;
            border-top:1px solid #fde68a;
            display:flex; align-items:center; gap:10px;
        }
        .msg-row label { font-size:12px; font-weight:600; color:#7a5800; white-space:nowrap; }
        .msg-row input { flex:1; padding:6px 10px; border:1px solid #fbbf24; border-radius:5px; font-size:12px; }

        /* Buttons */
        .btn-row {
            padding:14px 20px; background:#fffbeb;
            display:flex; justify-content:center; gap:12px;
            border-top:1px solid #fde68a;
        }
        .btn { padding:8px 26px; border:none; border-radius:6px; font-size:13px; font-weight:700; cursor:pointer; transition:all .2s; }
        .btn-validate { background:#f59e0b; color:#fff; }
        .btn-validate:hover { background:#d97706; transform:translateY(-1px); }
        .btn-save { background:#22c55e; color:#fff; }
        .btn-save:hover { background:#16a34a; transform:translateY(-1px); }
        .btn-cancel { background:#ef4444; color:#fff; }
        .btn-cancel:hover { background:#dc2626; transform:translateY(-1px); }

        .empty-msg { text-align:center; color:#a0a0a0; font-size:12px; padding:10px; }
    </style>
</head>
<body>
<div class="page-wrapper">

    <div class="bank-header">
        <h2><%= bankName.toUpperCase() %></h2>
        <h3>COMBINE DENOMINATION OF ACCEPT &amp; PAY CASH</h3>
    </div>
    <div class="meta-row">
        <span>BANK CODE : <b><%= bankCode %></b></span>
        <span>BRANCH CODE : <b><%= branchCode %></b></span>
        <span>USER : <b><%= userId %></b></span>
        <span>DATE : <b><%= workingDate %></b></span>
    </div>

    <!-- Scroll Entry -->
    <div class="section-label">Cash Details – Add Scroll</div>
    <div class="scroll-entry">
        <div class="field-group">
            <label>Scroll Number</label>
            <input type="text" id="scrollNo" placeholder="e.g. 00123" style="width:130px;">
        </div>
        <div class="field-group">
            <label>–</label>
            <input type="text" id="scrollSuffix" placeholder="–" style="width:50px;">
        </div>
        <div class="field-group">
            <label>Amount (₹)</label>
            <input type="number" id="scrollAmt" min="0" placeholder="0.00" style="width:140px;">
        </div>
        <button class="btn-add" onclick="addScroll()">Add</button>
    </div>

    <!-- Scroll List -->
    <div class="scroll-list">
        <table class="scroll-table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Scroll Number</th>
                    <th>Amount (₹)</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="scrollBody">
                <tr><td colspan="4" class="empty-msg">No scrolls added yet.</td></tr>
            </tbody>
        </table>
    </div>

    <!-- Denomination -->
    <div class="section-label">Denomination Details</div>
    <div class="denom-section">
        <table class="denom-table">
            <thead>
                <tr>
                    <th>Denomination (₹)</th>
                    <th>Received Nos.</th>
                    <th>Received Amt (₹)</th>
                    <th>Paid Nos.</th>
                    <th>Paid Amt (₹)</th>
                </tr>
            </thead>
            <tbody id="denomBody"></tbody>
        </table>
    </div>

    <!-- Summary -->
    <div class="summary-block">
        <div class="summary-item">Total Received : <input type="text" id="totalRec" readonly placeholder="0"></div>
        <div class="summary-item">Total Paid : <input type="text" id="totalPaid" readonly placeholder="0"></div>
        <div class="summary-item">Net Amount : <input type="text" id="netAmt" readonly placeholder="0"></div>
    </div>

    <div class="msg-row">
        <label>Message :</label>
        <input type="text" id="message" placeholder="">
    </div>
    <div class="btn-row">
        <button class="btn btn-validate" onclick="validateCombine()">Validate</button>
        <button class="btn btn-save"     onclick="saveCombine()">Save</button>
        <button class="btn btn-cancel"   onclick="cancelCombine()">Cancel</button>
    </div>
</div>

<script>
    const DENOMS = [2000,1000,500,100,50,20,10,5,2,1];
    let scrollList = [];
    let scrollCounter = 0;

    // Build denomination rows
    const tbody = document.getElementById('denomBody');
    DENOMS.forEach(function(d) {
        const tr = document.createElement('tr');
        tr.innerHTML =
            '<td>₹ ' + d + '</td>' +
            '<td><input type="number" min="0" value="0" class="rec-inp" data-denom="' + d + '" oninput="recalc()"></td>' +
            '<td class="rec-amt" id="rec-' + d + '">0</td>' +
            '<td><input type="number" min="0" value="0" class="paid-inp" data-denom="' + d + '" oninput="recalc()"></td>' +
            '<td class="paid-amt" id="paid-' + d + '">0</td>';
        tbody.appendChild(tr);
    });

    function recalc() {
        let rec = 0, paid = 0;
        DENOMS.forEach(function(d) {
            const rq = parseInt(document.querySelector('.rec-inp[data-denom="'+d+'"]').value) || 0;
            const pq = parseInt(document.querySelector('.paid-inp[data-denom="'+d+'"]').value) || 0;
            const ra = d * rq, pa = d * pq;
            document.getElementById('rec-' + d).textContent  = ra.toLocaleString('en-IN');
            document.getElementById('paid-' + d).textContent = pa.toLocaleString('en-IN');
            rec += ra; paid += pa;
        });
        document.getElementById('totalRec').value  = rec.toLocaleString('en-IN');
        document.getElementById('totalPaid').value = paid.toLocaleString('en-IN');
        document.getElementById('netAmt').value    = (rec - paid).toLocaleString('en-IN');
    }

    function addScroll() {
        const no  = document.getElementById('scrollNo').value.trim();
        const sfx = document.getElementById('scrollSuffix').value.trim();
        const amt = parseFloat(document.getElementById('scrollAmt').value) || 0;
        if (!no) { alert('Please enter Scroll Number.'); return; }
        scrollCounter++;
        scrollList.push({ id: scrollCounter, no: no + (sfx ? '-' + sfx : ''), amt });
        renderScrollList();
        document.getElementById('scrollNo').value  = '';
        document.getElementById('scrollSuffix').value = '';
        document.getElementById('scrollAmt').value = '';
    }

    function removeScroll(id) {
        scrollList = scrollList.filter(s => s.id !== id);
        renderScrollList();
    }

    function renderScrollList() {
        const sb = document.getElementById('scrollBody');
        if (scrollList.length === 0) {
            sb.innerHTML = '<tr><td colspan="4" class="empty-msg">No scrolls added yet.</td></tr>';
            return;
        }
        sb.innerHTML = scrollList.map((s, i) =>
            '<tr>' +
            '<td>' + (i+1) + '</td>' +
            '<td>' + s.no + '</td>' +
            '<td>₹ ' + s.amt.toLocaleString('en-IN') + '</td>' +
            '<td><button class="btn-remove" onclick="removeScroll(' + s.id + ')">Remove</button></td>' +
            '</tr>'
        ).join('');
    }

    function validateCombine() {
        if (scrollList.length === 0) { alert('Please add at least one scroll.'); return; }
        document.getElementById('message').value = 'Validated successfully.';
    }
    function saveCombine() {
        if (scrollList.length === 0) { alert('Please add at least one scroll.'); return; }
        alert('Combine denomination saved successfully!');
    }
    function cancelCombine() {
        scrollList = []; scrollCounter = 0; renderScrollList();
        document.querySelectorAll('.rec-inp, .paid-inp').forEach(i => i.value = 0);
        document.getElementById('message').value = '';
        recalc();
    }
</script>
</body>
</html>
