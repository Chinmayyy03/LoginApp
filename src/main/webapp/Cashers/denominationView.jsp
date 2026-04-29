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
    <title>Denomination View</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body {
            font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background:linear-gradient(160deg,#dbeeff 0%,#c4dff7 100%);
            min-height:100vh; padding:20px; font-size:13px;
        }
        .page-wrapper {
            max-width:820px; margin:0 auto;
            background:rgba(255,255,255,0.65);
            border-radius:12px;
            box-shadow:0 4px 24px rgba(74,144,226,.18);
            overflow:hidden;
        }
        .bank-header {
            background:linear-gradient(135deg,#8b5cf6 0%,#6d28d9 100%);
            color:#fff; text-align:center; padding:14px 20px 10px;
        }
        .bank-header h2 { font-size:15px; font-weight:700; }
        .bank-header h3 { font-size:17px; font-weight:800; margin-top:4px; letter-spacing:1px; }
        .meta-row {
            background:#f5f0ff; display:flex; justify-content:center;
            gap:28px; padding:7px 16px; font-size:12px; color:#3a1a6a; font-weight:600; flex-wrap:wrap;
        }
        .meta-row span b { color:#6d28d9; margin-left:4px; }
        .section-label {
            padding:6px 16px; font-size:11px; font-weight:700;
            color:#6d28d9; border-bottom:1px solid #ddd6fe;
            background:#faf5ff; text-transform:uppercase; letter-spacing:.5px;
        }

        /* Filter Bar */
        .filter-bar {
            padding:14px 20px; background:#fff;
            display:flex; gap:14px; flex-wrap:wrap; align-items:flex-end;
            border-bottom:1px solid #ddd6fe;
        }
        .field-group { display:flex; flex-direction:column; gap:3px; }
        .field-group label { font-size:11px; font-weight:600; color:#5a3a9a; }
        .field-group input, .field-group select {
            padding:6px 10px; border:1px solid #c4b5fd;
            border-radius:5px; background:#faf5ff;
            font-size:12px; color:#3a1a6a; width:145px;
        }
        .field-group input:focus, .field-group select:focus {
            outline:none; border-color:#8b5cf6; background:#fff;
        }
        .btn-search {
            padding:7px 22px; background:#8b5cf6; color:#fff;
            border:none; border-radius:6px; font-size:13px;
            font-weight:700; cursor:pointer; transition:all .2s;
            align-self:flex-end;
        }
        .btn-search:hover { background:#6d28d9; transform:translateY(-1px); }

        /* View Table */
        .view-section { padding:0 20px 16px; background:#fff; }
        table.view-table { width:100%; border-collapse:collapse; margin-top:10px; font-size:12px; }
        .view-table thead tr { background:linear-gradient(90deg,#8b5cf6,#a78bfa); color:#fff; }
        .view-table thead th { padding:8px 10px; text-align:center; font-weight:700; }
        .view-table tbody tr:nth-child(even) { background:#faf5ff; }
        .view-table tbody tr:hover { background:#ede9fe; }
        .view-table td { padding:6px 10px; text-align:center; color:#3a1a6a; font-weight:600; border-bottom:1px solid #ede9fe; }
        .view-table tfoot tr { background:#ede9fe; font-weight:700; }
        .view-table tfoot td { padding:8px 10px; text-align:center; color:#4c1d95; border-top:2px solid #8b5cf6; }

        .no-data { text-align:center; padding:24px; color:#a0a0a0; font-size:13px; }

        .msg-row {
            padding:10px 20px; background:#fff;
            border-top:1px solid #ddd6fe;
            display:flex; align-items:center; gap:10px;
        }
        .msg-row label { font-size:12px; font-weight:600; color:#5a3a9a; white-space:nowrap; }
        .msg-row input { flex:1; padding:6px 10px; border:1px solid #c4b5fd; border-radius:5px; font-size:12px; }

        .btn-row {
            padding:14px 20px; background:#faf5ff;
            display:flex; justify-content:center; gap:12px;
            border-top:1px solid #ddd6fe;
        }
        .btn { padding:8px 26px; border:none; border-radius:6px; font-size:13px; font-weight:700; cursor:pointer; transition:all .2s; }
        .btn-print  { background:#8b5cf6; color:#fff; }
        .btn-print:hover  { background:#6d28d9; transform:translateY(-1px); }
        .btn-cancel { background:#ef4444; color:#fff; }
        .btn-cancel:hover { background:#dc2626; transform:translateY(-1px); }
    </style>
</head>
<body>
<div class="page-wrapper">

    <div class="bank-header">
        <h2><%= bankName.toUpperCase() %></h2>
        <h3>DENOMINATION VIEW</h3>
    </div>
    <div class="meta-row">
        <span>BANK CODE : <b><%= bankCode %></b></span>
        <span>BRANCH CODE : <b><%= branchCode %></b></span>
        <span>USER : <b><%= userId %></b></span>
        <span>DATE : <b><%= workingDate %></b></span>
    </div>

    <!-- Filter -->
    <div class="section-label">Search Criteria</div>
    <div class="filter-bar">
        <div class="field-group">
            <label>From Date</label>
            <input type="date" id="fromDate">
        </div>
        <div class="field-group">
            <label>To Date</label>
            <input type="date" id="toDate">
        </div>
        <div class="field-group">
            <label>User ID</label>
            <input type="text" id="searchUser" placeholder="All Users">
        </div>
        <div class="field-group">
            <label>Transaction Type</label>
            <select id="txnType">
                <option value="">All</option>
                <option value="IN">Cash In</option>
                <option value="OUT">Cash Out</option>
            </select>
        </div>
        <button class="btn-search" onclick="searchDenom()">&#128269; Search</button>
    </div>

    <!-- Results -->
    <div class="section-label">Denomination Details</div>
    <div class="view-section">
        <table class="view-table">
            <thead>
                <tr>
                    <th>Date</th>
                    <th>User</th>
                    <th>Type</th>
                    <th>₹2000</th>
                    <th>₹1000</th>
                    <th>₹500</th>
                    <th>₹100</th>
                    <th>₹50</th>
                    <th>₹20</th>
                    <th>₹10</th>
                    <th>₹5</th>
                    <th>₹2</th>
                    <th>₹1</th>
                    <th>Total (₹)</th>
                </tr>
            </thead>
            <tbody id="viewBody">
                <tr><td colspan="14" class="no-data">Click Search to load data.</td></tr>
            </tbody>
            <tfoot>
                <tr id="footRow" style="display:none">
                    <td colspan="3"><b>TOTAL</b></td>
                    <td id="ft2000">0</td>
                    <td id="ft1000">0</td>
                    <td id="ft500">0</td>
                    <td id="ft100">0</td>
                    <td id="ft50">0</td>
                    <td id="ft20">0</td>
                    <td id="ft10">0</td>
                    <td id="ft5">0</td>
                    <td id="ft2">0</td>
                    <td id="ft1">0</td>
                    <td id="ftTotal">0</td>
                </tr>
            </tfoot>
        </table>
    </div>

    <div class="msg-row">
        <label>Message :</label>
        <input type="text" id="message" placeholder="">
    </div>
    <div class="btn-row">
        <button class="btn btn-print"  onclick="printView()">&#128424; Print</button>
        <button class="btn btn-cancel" onclick="cancelView()">Cancel</button>
    </div>
</div>

<script>
    // Demo data – replace with real AJAX call to a servlet
    const DEMO_DATA = [
        { date:'29-04-2026', user:'<%= userId %>', type:'IN',  d:[5,3,2,10,4,2,5,0,2,8], total:0 },
        { date:'29-04-2026', user:'<%= userId %>', type:'OUT', d:[2,1,1, 5,2,1,2,0,1,3], total:0 },
    ];
    const DENOMS = [2000,1000,500,100,50,20,10,5,2,1];
    DEMO_DATA.forEach(function(r) {
        r.total = r.d.reduce((s,q,i) => s + q * DENOMS[i], 0);
    });

    function searchDenom() {
        const tbody = document.getElementById('viewBody');
        // In real use, fetch from servlet with date/user/type params
        if (DEMO_DATA.length === 0) {
            tbody.innerHTML = '<tr><td colspan="14" class="no-data">No records found.</td></tr>';
            document.getElementById('footRow').style.display = 'none';
            return;
        }

        const ft = new Array(10).fill(0);
        let ftTotal = 0;
        tbody.innerHTML = DEMO_DATA.map(function(r) {
            const cells = r.d.map((q,i) => { ft[i] += q * DENOMS[i]; return '<td>' + (q * DENOMS[i]).toLocaleString('en-IN') + '</td>'; }).join('');
            ftTotal += r.total;
            return '<tr><td>' + r.date + '</td><td>' + r.user + '</td><td>' + r.type + '</td>' + cells + '<td>' + r.total.toLocaleString('en-IN') + '</td></tr>';
        }).join('');

        const keys = [2000,1000,500,100,50,20,10,5,2,1];
        keys.forEach((k,i) => document.getElementById('ft'+k).textContent = ft[i].toLocaleString('en-IN'));
        document.getElementById('ftTotal').textContent = ftTotal.toLocaleString('en-IN');
        document.getElementById('footRow').style.display = '';
        document.getElementById('message').value = DEMO_DATA.length + ' record(s) found.';
    }

    function printView() { window.print(); }
    function cancelView() {
        document.getElementById('fromDate').value = '';
        document.getElementById('toDate').value   = '';
        document.getElementById('searchUser').value = '';
        document.getElementById('viewBody').innerHTML = '<tr><td colspan="14" class="no-data">Click Search to load data.</td></tr>';
        document.getElementById('footRow').style.display = 'none';
        document.getElementById('message').value = '';
    }
</script>
</body>
</html>
