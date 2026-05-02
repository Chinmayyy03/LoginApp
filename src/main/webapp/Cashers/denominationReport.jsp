<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String userId     = (String) session.getAttribute("userId");
    String branchCode = (String) session.getAttribute("branchCode");

    if (userId == null || branchCode == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Denomination Report</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Roboto, Arial, sans-serif;
            background: #e8e4fc;
            min-height: 100vh;
            color: #1a1a1a;
            font-size: 13px;
        }
        h2 {
		    color: #2b0d73;
		    margin: 20px 0;
		    font-size: 22px;
		    font-weight: 700;
		    text-align: center;
		}

        .page-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 10px 30px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .page-header h1 {
            margin: 0;
            font-size: 20px;
            font-weight: bold;
            letter-spacing: 0.5px;
        }

        .header-info {
            display: flex;
            justify-content: space-between;
            background: white;
            padding: 6px 30px;
            font-size: 12px;
            color: #3D316F;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .header-info span { font-weight: bold; }

        .container {
            max-width: 1200px;
            margin: 15px auto;
            padding: 0 15px;
        }

        fieldset {
            background-color: white;
            border: 2px solid #BBADED;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
        }

        legend {
            font-size: 16px;
            font-weight: bold;
            padding: 0 8px;
            color: #3D316F;
        }

        .form-row {
            display: flex;
            gap: 15px;
            margin-bottom: 12px;
            align-items: flex-end;
            flex-wrap: wrap;
        }

        .form-group {
            flex: 1;
            min-width: 160px;
        }

        .label {
            font-weight: bold;
            font-size: 13px;
            color: #3D316F;
            margin-bottom: 5px;
            display: block;
        }

        input[type="text"],
        input[type="number"],
        input[type="date"],
        select {
            padding: 8px 10px;
            border: 2px solid #C8B7F6;
            border-radius: 6px;
            background-color: #F4EDFF;
            outline: none;
            font-size: 13px;
            width: 100%;
            color: #1a1a1a;
        }

        input[type="text"]:focus,
        input[type="number"]:focus,
        input[type="date"]:focus,
        select:focus {
            border-color: #8066E8;
            background-color: #fff;
        }

        /* Table */
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        table thead {
            background: #373279;
            color: white;
        }

        table th {
            padding: 10px 12px;
            text-align: center;
            font-weight: 700;
            border: 1px solid #4a4599;
        }

        table tbody tr:nth-child(even) { background: #f0ecff; }
        table tbody tr:nth-child(odd)  { background: #fff; }
        table tbody tr:hover           { background: #e4deff; }

        table td {
            padding: 10px 12px;
            text-align: center;
            border: 1px solid #ddd;
            color: #333;
            font-weight: 500;
        }

        table tfoot tr { background: #f0ecff; }
        table tfoot td {
            padding: 10px 12px;
            border: 1px solid #ddd;
            font-weight: 700;
            color: #3D316F;
            border-top: 2px solid #BBADED;
        }

        .no-data {
            text-align: center;
            padding: 20px;
            color: #999;
            font-size: 13px;
        }

        /* Buttons */
        .button-row {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 10px;
        }

        .btn {
            padding: 8px 28px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background: linear-gradient(135deg, #4a9eff 0%, #3d85d9 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 3px 10px rgba(74,158,255,0.4);
        }

        .btn-generate {
            background: linear-gradient(135deg, #4a9eff 0%, #3d85d9 100%);
            color: white;
            padding: 8px 20px;
            border: none;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            white-space: nowrap;
        }

        .btn-generate:hover {
            transform: translateY(-1px);
            box-shadow: 0 3px 10px rgba(74,158,255,0.4);
        }

        .btn-secondary {
            background: #e5e7eb;
            color: #333;
        }

        .btn-secondary:hover { background: #d1d5db; }

        .btn-cancel {
            background: #dc2626;
            color: white;
        }

        .btn-cancel:hover { background: #b91c1c; }

        @media print {
            body { background: #fff !important; }
            .form-row, .button-row, .page-header, .header-info { display: none !important; }
        }

        @media (max-width: 768px) {
            .form-row { flex-direction: column; }
            .header-info { flex-direction: column; gap: 4px; text-align: center; }
        }
    </style>
</head>
<body>

<h2>Denomination Report - Branch <%= branchCode %></h2>

<div class="container">

    <!-- Report Parameters -->
    <fieldset>
        <legend>Report Parameters</legend>
        <div class="form-row">
            <div class="form-group">
                <label class="label">Report Date</label>
                <input type="date" id="reportDate">
            </div>
            <div class="form-group">
                <label class="label">Report Type</label>
                <select id="reportType">
                    <option value="DAILY">Daily Summary</option>
                    <option value="USER">User-wise</option>
                    <option value="DENOM">Denomination-wise</option>
                </select>
            </div>
            <div class="form-group">
                <label class="label">User ID (optional)</label>
                <input type="text" id="repUserId" placeholder="All Users">
            </div>
            <div style="display:flex; align-items:flex-end;">
                <button class="btn-generate" onclick="generateReport()">📊 Generate</button>
            </div>
        </div>
    </fieldset>

    <!-- Report Output -->
    <fieldset>
        <legend>Report Output</legend>
        <div id="noDataMsg" class="no-data">Select parameters and click Generate to view the report.</div>
        <div id="reportCard" style="display:none; overflow-x:auto;">
            <table>
                <thead>
                    <tr>
                        <th>Denomination (₹)</th>
                        <th>Opening</th>
                        <th>Received</th>
                        <th>Paid</th>
                        <th>Closing</th>
                        <th>Amount (₹)</th>
                    </tr>
                </thead>
                <tbody id="reportBody"></tbody>
                <tfoot>
                    <tr>
                        <td><b>TOTAL</b></td>
                        <td id="ftOpen">0</td>
                        <td id="ftRec">0</td>
                        <td id="ftPaid">0</td>
                        <td id="ftClose">0</td>
                        <td id="ftAmt">₹ 0</td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </fieldset>

    <!-- Buttons -->
    <div class="button-row">
        <button class="btn btn-primary"   onclick="window.print()">🖨️ Print</button>
        <button class="btn btn-secondary" onclick="exportCSV()">📥 Export CSV</button>
        <button class="btn btn-cancel"    onclick="cancelReport()">Cancel</button>
    </div>

</div>

<script>
    const DENOMS = [500,200,100,50,20,10,5,2,1];

    function generateReport() {
        const dt = document.getElementById('reportDate').value;
        if (!dt) { alert('Please select Report Date.'); return; }

        const rows = DENOMS.map(function(d) {
            const op   = Math.floor(Math.random() * 10);
            const rec  = Math.floor(Math.random() * 8);
            const paid = Math.floor(Math.random() * 5);
            const cl   = op + rec - paid;
            return { denom: d, op, rec, paid, cl, amt: cl * d };
        });

        const tbody = document.getElementById('reportBody');
        let ftOpen = 0, ftRec = 0, ftPaid = 0, ftClose = 0, ftAmt = 0;

        tbody.innerHTML = rows.map(function(r) {
            ftOpen += r.op; ftRec += r.rec; ftPaid += r.paid; ftClose += r.cl; ftAmt += r.amt;
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

        document.getElementById('noDataMsg').style.display  = 'none';
        document.getElementById('reportCard').style.display = 'block';
    }

    function exportCSV() {
        if (document.getElementById('reportCard').style.display === 'none') {
            alert('Please generate a report first.');
            return;
        }
        const rows = [['Denomination','Opening','Received','Paid','Closing','Amount']];
        document.querySelectorAll('#reportBody tr').forEach(function(tr) {
            rows.push(Array.from(tr.querySelectorAll('td')).map(td => td.textContent.replace(/₹\s*/, '')));
        });
        const csv = rows.map(r => r.join(',')).join('\n');
        const a = document.createElement('a');
        a.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
        a.download = 'Denomination_Report_' + (document.getElementById('reportDate').value || 'NA') + '.csv';
        a.click();
    }

    function cancelReport() {
        document.getElementById('reportDate').value    = '';
        document.getElementById('reportBody').innerHTML = '';
        document.getElementById('reportCard').style.display  = 'none';
        document.getElementById('noDataMsg').style.display   = 'block';
    }

    window.onload = function() {
        if (window.parent && window.parent.updateParentBreadcrumb) {
            window.parent.updateParentBreadcrumb('Cashers > Denomination Report', 'Cashers/denominationReport.jsp');
        }
    };
</script>
</body>
</html>
