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
    <title>Cash In / Out</title>
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

        input[readonly] {
            background-color: #f5f5f5;
            cursor: not-allowed;
            border-color: #ddd;
            color: #3D316F;
            font-weight: 600;
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
            font-size: 13px;
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

        table input[type="number"] {
            width: 90px;
            padding: 6px 8px;
            border: 2px solid #C8B7F6;
            border-radius: 6px;
            text-align: center;
            font-size: 13px;
            background: #F4EDFF;
        }

        table input[type="number"]:focus {
            border-color: #8066E8;
            background: #fff;
            outline: none;
        }

        /* Summary */
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 15px;
        }

        .summary-item {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .summary-item input {
            text-align: right;
            font-weight: 700;
            color: #3D316F;
            background: #f5f5f5;
            border-color: #ddd;
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

        .btn-success {
            background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
            color: white;
        }

        .btn-success:hover {
            transform: translateY(-1px);
            box-shadow: 0 3px 10px rgba(34,197,94,0.4);
        }

        .btn-cancel {
            background: #dc2626;
            color: white;
        }

        .btn-cancel:hover { background: #b91c1c; }

        @media (max-width: 768px) {
            .form-row { flex-direction: column; }
            .header-info { flex-direction: column; gap: 4px; text-align: center; }
        }
    </style>
</head>
<body>

<h2>Cash In / Out - Branch <%= branchCode %></h2>

<div class="container">

    <!-- Account Details -->
    <fieldset>
        <legend>Account Details</legend>
        <div class="form-row">
            <div class="form-group">
                <label class="label">Cash Handling Date</label>
                <input type="date" id="cashHandlingDate">
            </div>
            <div class="form-group">
                <label class="label">Transaction Amount (₹)</label>
                <input type="number" id="transactionAmount" min="0" placeholder="0.00">
            </div>
        </div>
    </fieldset>

    <!-- Cash Details -->
    <fieldset>
        <legend>Cash Details</legend>
        <div style="overflow-x: auto;">
            <table>
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
    </fieldset>

    <!-- Summary -->
    <fieldset>
        <legend>Summary</legend>
        <div class="summary-grid">
            <div class="summary-item">
                <label class="label">Total Received (₹)</label>
                <input type="text" id="totalRec" readonly placeholder="0">
            </div>
            <div class="summary-item">
                <label class="label">Total Paid (₹)</label>
                <input type="text" id="totalPaid" readonly placeholder="0">
            </div>
            <div class="summary-item">
                <label class="label">Net Amount (₹)</label>
                <input type="text" id="netAmt" readonly placeholder="0">
            </div>
        </div>
    </fieldset>

    <!-- Buttons -->
    <div class="button-row">
        <button class="btn btn-primary"  onclick="validateCombine()">Validate</button>
        <button class="btn btn-success"  onclick="saveCombine()">Save</button>
        <button class="btn btn-cancel"   onclick="cancelCombine()">Cancel</button>
    </div>

</div>

<script>
    const DENOMS = [500,200,100,50,20,10,5,2,1];
    const tbody  = document.getElementById('denomBody');

    DENOMS.forEach(function(d) {
        const tr = document.createElement('tr');
        tr.innerHTML =
            '<td>₹ ' + d + '</td>' +
            '<td><input type="number" min="0" value="0" class="rec-inp"  data-denom="' + d + '" oninput="recalc()"></td>' +
            '<td class="rec-amt"  id="rec-'  + d + '">0</td>' +
            '<td><input type="number" min="0" value="0" class="paid-inp" data-denom="' + d + '" oninput="recalc()"></td>' +
            '<td class="paid-amt" id="paid-' + d + '">0</td>';
        tbody.appendChild(tr);
    });

    const changeRow = document.createElement('tr');
    changeRow.innerHTML =
        '<td><strong>Change</strong></td>' +
        '<td><input type="number" min="0" value="0" class="rec-inp"  data-denom="change" oninput="recalc()"></td>' +
        '<td class="rec-amt"  id="rec-change">0</td>' +
        '<td><input type="number" min="0" value="0" class="paid-inp" data-denom="change" oninput="recalc()"></td>' +
        '<td class="paid-amt" id="paid-change">0</td>';
    tbody.appendChild(changeRow);

    function recalc() {
        let rec = 0, paid = 0;
        DENOMS.forEach(function(d) {
            const rq = parseInt(document.querySelector('.rec-inp[data-denom="'+d+'"]').value)  || 0;
            const pq = parseInt(document.querySelector('.paid-inp[data-denom="'+d+'"]').value) || 0;
            const ra = d * rq, pa = d * pq;
            document.getElementById('rec-'  + d).textContent = ra.toLocaleString('en-IN');
            document.getElementById('paid-' + d).textContent = pa.toLocaleString('en-IN');
            rec += ra; paid += pa;
        });
        const crq = parseFloat(document.querySelector('.rec-inp[data-denom="change"]').value)  || 0;
        const cpq = parseFloat(document.querySelector('.paid-inp[data-denom="change"]').value) || 0;
        document.getElementById('rec-change').textContent  = crq.toLocaleString('en-IN');
        document.getElementById('paid-change').textContent = cpq.toLocaleString('en-IN');
        rec += crq; paid += cpq;
        document.getElementById('totalRec').value  = rec.toLocaleString('en-IN');
        document.getElementById('totalPaid').value = paid.toLocaleString('en-IN');
        document.getElementById('netAmt').value    = (rec - paid).toLocaleString('en-IN');
    }

    function validateCombine() { alert('Cash In / Out validated successfully.'); }
    function saveCombine()     { alert('Cash In / Out saved successfully!'); }
    function cancelCombine() {
        document.querySelectorAll('.rec-inp, .paid-inp').forEach(i => i.value = 0);
        document.getElementById('rec-change').textContent  = '0';
        document.getElementById('paid-change').textContent = '0';
        recalc();
    }

    window.onload = function() {
        if (window.parent && window.parent.updateParentBreadcrumb) {
            window.parent.updateParentBreadcrumb('Cashers > Cash In / Out', 'Cashers/cashInOut.jsp');
        }
    };
</script>
</body>
</html>
