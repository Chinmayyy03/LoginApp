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
    <title>Denomination Report</title>
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
            background:linear-gradient(135deg,#ef4444 0%,#b91c1c 100%);
            color:#fff; text-align:center; padding:14px 20px 10px;
        }
        .bank-header h2 { font-size:15px; font-weight:700; }
        .bank-header h3 { font-size:17px; font-weight:800; margin-top:4px; letter-spacing:1px; }
        .meta-row {
            background:#fff5f5; display:flex; justify-content:center;
            gap:28px; padding:7px 16px; font-size:12px; color:#6a1a1a; font-weight:600; flex-wrap:wrap;
        }
        .meta-row span b { color:#b91c1c; margin-left:4px; }
        .section-label {
            padding:6px 16px; font-size:11px; font-weight:700;
            color:#b91c1c; border-bottom:1px solid #fecaca;
            background:#fff5f5; text-transform:uppercase; letter-spacing:.5px;
        }

        /* Filter */
        .filter-bar {
            padding:14px 20px; background:#fff;
            display:flex; gap:14px; flex-wrap:wrap; align-items:flex-end;
            border-bottom:1px solid #fecaca;
        }
        .field-group { display:flex; flex-direction:column; gap:3px; }
        .field-group label { font-size:11px; font-weight:600; color:#7a1a1a; }
        .field-group input, .field-group select {
            padding:6px 10px; border:1px solid #fca5a5;
            border-radius:5px; background:#fff5f5;
            font-size:12px; color:#6a1a1a; width:145px;
        }
        .field-group input:focus, .field-group select:focus {
            outline:none; border-color:#ef4444; background:#fff;
        }
        .btn-generate {
            padding:7px 22px; background:#ef4444; color:#fff;
            border:none; border-radius:6px; font-size:13px;
            font-weight:700; cursor:pointer; transition:all .2s; align-self:flex-end;
        }
        .btn-generate:hover { background:#b91c1c; transform:translateY(-1px); }

        /* Report Area */
        .report-section { padding:0 20px 16px; background:#fff; }

        /* Printable Report Card */
        .report-card {
            border:2px solid #fecaca; border-radius:8px;
            margin-top:12px; overflow:hidden; display:none;
        }
        .report-card.visible { display:block; }
        .report-card-header {
            background:linear-gradient(90deg,#ef4444,#fca5a5);
            color:#fff; padding:12px 16px; text-align:center;
        }
        .report-card-header h4 { font-size:14px; font-weight:800; }
        .report-card-header p  { font-size:11px; margin-top:2px; opacity:.9; }

        table.report-table { width:100%; border-collapse:collapse; }
        .report-table thead tr { background:#fef2f2; }
        .report-table thead th {
            padding:8px 10px; text-align:center;
            font-size:11px; font-weight:700; color:#b91c1c;
            border-bottom:2px solid #fecaca;
        }
        .report-table tbody tr:nth-child(even) { background:#fff5f5; }
        .report-table tbody tr:hover { background:#fee2e2; }
        .report-table td { padding:6px 10px; text-align:center; font-size:12px; color:#6a1a1a; font-weight:600; border-bottom:1px solid #fee2e2; }
        .report-table tfoot tr { background:#fee2e2; }
        .report-table tfoot td { padding:8px 10px; text-align:center; font-size:12px; color:#7f1d1d; font-weight:700; border-top:2px solid #ef4444; }

        .no-data { text-align:center; padding:20px; color:#a0a0a0; font-size:13px; }

        /* Summary Cards */
        .summary-cards {
            display:flex; gap:14px; flex-wrap:wrap;
            padding:14px 20px; background:#fff5f5;
            border-top:1px solid #fecaca;
        }
        .sum-card {
            flex:1; min-width:150px;
            background:#fff; border:1px solid #fecaca;
            border-radius:8px; padding:10px 14px; text-align:center;
        }
        .sum-card .sum-label { font-size:11px; color:#7a1a1a; font-weight:600; margin-bottom:4px; }
        .sum-card .sum-value { font-size:18px; font-weight:800; color:#b91c1c; }

        .msg-row {
            padding:10px 20px; background:#fff;
            border-top:1px solid #fecaca;
            display:flex; align-items:center; gap:10px;
        }
        .msg-row label { font-size:12px; font-weight:600; color:#7a1a1a; white-space:nowrap; }
        .msg-row input { flex:1; padding:6px 10px; border:1px solid #fca5a5; border-radius:5px; font-size:12px; }

        .btn-row {
            padding:14px 20px; background:#fff5f5;
            display:flex; justify-content:center; gap:12px;
            border-top:1px solid #fecaca;
        }
        .btn { padding:8px 26px; border:none; border-radius:6px; font-size:13px; font-weight:700; cursor:pointer; transition:all .2s; }
        .btn-print  { background:#ef4444; color:#fff; }
        .btn-print:hover  { background:#b91c1c; transform:translateY(-1px); }
        .btn-export { background:#2563eb; color:#fff; }
        .btn-export:hover { background:#1d4ed8; transform:translateY(-1px); }
        .btn-cancel { background:#6b7280; color:#fff; }
        .btn-cancel:hover { background:#4b5563; transform:translateY(-1px); }

        @media print {
            body { background:#fff !important; padding:0; }
            .filter-bar, .btn-row, .msg-row { display:none !important; }
            .page-wrapper { box-shadow:none; border-radius:0; }
            .report-card { display:block !important; }
        }
    </style>
</head>
<body>
<div class="page-wrapper">

    <div class="bank-header">
        <h2><%= bankName.toUpperCase() %></h2>
        <h3>DENOMINATION REPORT</h3>
    </div>
    <div class="meta-row">
        <span>BANK CODE : <b><%= bankCode %></b></span>
        <span>BRANCH CODE : <b><%= branchCode %></b></span>
        <span>USER : <b><%= userId %></b></span>
        <span>DATE : <b><%= workingDate %></b></span>
    </div>

    <!-- Filter -->
    <div class="section-label">Report Parameters</div>
    <div class="filter-bar">
        <div class="field-group">
            <label>Report Date</label>
            <input type="date" id="reportDate">
        </div>
        <div class="field-group">
            <label>Report Type</label>
            <select id="reportType">
                <option value="DAILY">Daily Summary</option>
                <option value="USER">User-wise</option>
                <option value="DENOM">Denomination-wise</option>
            </select>
        </div>
        <div class="field-group">
            <label>User ID (optional)</label>
            <input type="text" id="repUserId" placeholder="All Users">
        </div>
        <button class="btn-generate" onclick="generateReport()">&#9881; Generate</button>
    </div>

    <!-- Report Output -->
    <div class="section-label">Report Output</div>
    <div class="report-section">
        <div id="noDataMsg" class="no-data">Select parameters and click Generate to view the report.</div>

        <div class="report-card" id="reportCard">
            <div class="report-card-header">
                <h4 id="reportTitle">DENOMINATION DAILY REPORT</h4>
                <p id="reportSubtitle">Date: –  |  Branch: <%= branchCode %>  |  Generated by: <%= userId %></p>
            </div>
            <table class="report-table">
                <thead>
                    <tr>
                        <th>Denomination (₹)</th>
                        <th>Opening Nos.</th>
                        <th>Received Nos.</th>
                        <th>Paid Nos.</th>
                        <th>Closing Nos.</th>
                        <th>Closing Amt (₹)</th>
                    </tr>
                </thead>
                <tbody id="reportBody"></tbody>
                <tfoot>
                    <tr>
                        <td><b>GRAND TOTAL</b></td>
                        <td id="ftOpen">0</td>
                        <td id="ftRec">0</td>
                        <td id="ftPaid">0</td>
                        <td id="ftClose">0</td>
                        <td id="ftAmt">₹ 0</td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>

    <!-- Summary Cards -->
    <div class="summary-cards" id="summaryCards" style="display:none;">
        <div class="sum-card">
            <div class="sum-label">Opening Cash</div>
            <div class="sum-value" id="sumOpen">₹ 0</div>
        </div>
        <div class="sum-card">
            <div class="sum-label">Total Received</div>
            <div class="sum-value" id="sumRec">₹ 0</div>
        </div>
        <div class="sum-card">
            <div class="sum-label">Total Paid</div>
            <div class="sum-value" id="sumPaid">₹ 0</div>
        </div>
        <div class="sum-card">
            <div class="sum-label">Closing Balance</div>
            <div class="sum-value" id="sumClose">₹ 0</div>
        </div>
    </div>

    <div class="msg-row">
        <label>Message :</label>
        <input type="text" id="message" placeholder="">
    </div>
    <div class="btn-row">
        <button class="btn btn-print"  onclick="window.print()">&#128424; Print</button>
        <button class="btn btn-export" onclick="exportCSV()">&#8681; Export CSV</button>
        <button class="btn btn-cancel" onclick="cancelReport()">Cancel</button>
    </div>
</div>

<script>
    const DENOMS = [2000,1000,500,100,50,20,10,5,2,1];

    // Demo generator – replace with real servlet call
    function generateReport() {
        const dt   = document.getElementById('reportDate').value;
        const type = document.getElementById('reportType').value;
        if (!dt) { alert('Please select Report Date.'); return; }

        // Simulate demo data
        const rows = DENOMS.map(function(d) {
            const op  = Math.floor(Math.random()*10);
            const rec = Math.floor(Math.random()*8);
            const paid= Math.floor(Math.random()*5);
            const cl  = op + rec - paid;
            return { denom:d, op, rec, paid, cl, amt: cl * d };
        });

        const tbody = document.getElementById('reportBody');
        let ftOpen=0, ftRec=0, ftPaid=0, ftClose=0, ftAmt=0;
        tbody.innerHTML = rows.map(function(r) {
            ftOpen  += r.op;  ftRec  += r.rec;
            ftPaid  += r.paid; ftClose += r.cl; ftAmt += r.amt;
            return '<tr>' +
                '<td>₹ ' + r.denom + '</td>' +
                '<td>' + r.op   + '</td>' +
                '<td>' + r.rec  + '</td>' +
                '<td>' + r.paid + '</td>' +
                '<td>' + r.cl   + '</td>' +
                '<td>' + r.amt.toLocaleString('en-IN') + '</td>' +
                '</tr>';
        }).join('');

        document.getElementById('ftOpen').textContent  = ftOpen;
        document.getElementById('ftRec').textContent   = ftRec;
        document.getElementById('ftPaid').textContent  = ftPaid;
        document.getElementById('ftClose').textContent = ftClose;
        document.getElementById('ftAmt').textContent   = '₹ ' + ftAmt.toLocaleString('en-IN');

        const titles = { DAILY:'DENOMINATION DAILY REPORT', USER:'USER-WISE DENOMINATION REPORT', DENOM:'DENOMINATION-WISE REPORT' };
        document.getElementById('reportTitle').textContent    = titles[type] || 'DENOMINATION REPORT';
        document.getElementById('reportSubtitle').textContent = 'Date: ' + dt + '  |  Branch: <%= branchCode %>  |  Generated by: <%= userId %>';

        document.getElementById('noDataMsg').style.display = 'none';
        document.getElementById('reportCard').classList.add('visible');

        // Summary
        const openAmt  = rows.reduce((s,r) => s + r.op   * r.denom, 0);
        const recAmt   = rows.reduce((s,r) => s + r.rec  * r.denom, 0);
        const paidAmt  = rows.reduce((s,r) => s + r.paid * r.denom, 0);
        const closeAmt = rows.reduce((s,r) => s + r.cl   * r.denom, 0);
        document.getElementById('sumOpen').textContent  = '₹ ' + openAmt.toLocaleString('en-IN');
        document.getElementById('sumRec').textContent   = '₹ ' + recAmt.toLocaleString('en-IN');
        document.getElementById('sumPaid').textContent  = '₹ ' + paidAmt.toLocaleString('en-IN');
        document.getElementById('sumClose').textContent = '₹ ' + closeAmt.toLocaleString('en-IN');
        document.getElementById('summaryCards').style.display = 'flex';

        document.getElementById('message').value = 'Report generated for ' + dt + '.';
    }

    function exportCSV() {
        const card = document.getElementById('reportCard');
        if (!card.classList.contains('visible')) { alert('Please generate a report first.'); return; }
        const rows = [['Denomination','Opening','Received','Paid','Closing','Amount']];
        document.querySelectorAll('#reportBody tr').forEach(function(tr) {
            rows.push(Array.from(tr.querySelectorAll('td')).map(td => td.textContent.replace(/₹\s*/,'')));
        });
        const csv = rows.map(r => r.join(',')).join('\n');
        const a = document.createElement('a');
        a.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
        a.download = 'Denomination_Report_' + (document.getElementById('reportDate').value || 'NA') + '.csv';
        a.click();
    }

    function cancelReport() {
        document.getElementById('reportDate').value = '';
        document.getElementById('reportBody').innerHTML = '';
        document.getElementById('reportCard').classList.remove('visible');
        document.getElementById('noDataMsg').style.display = 'block';
        document.getElementById('summaryCards').style.display = 'none';
        document.getElementById('message').value = '';
    }
</script>
</body>
</html>
