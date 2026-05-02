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
    <title>Denomination View</title>
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
            max-width: 1400px;
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
        input[type="date"]:focus,
        select:focus {
            border-color: #8066E8;
            background-color: #fff;
        }

        /* Table */
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 12px;
        }

        table thead {
            background: #373279;
            color: white;
        }

        table th {
            padding: 10px 10px;
            text-align: center;
            font-weight: 700;
            border: 1px solid #4a4599;
            white-space: nowrap;
        }

        table tbody tr:nth-child(even) { background: #f0ecff; }
        table tbody tr:nth-child(odd)  { background: #fff; }
        table tbody tr:hover           { background: #e4deff; }

        table td {
            padding: 10px;
            text-align: center;
            border: 1px solid #ddd;
            color: #333;
            font-weight: 500;
        }

        table tfoot tr { background: #f0ecff; }
        table tfoot td {
            padding: 10px;
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

        .btn-search {
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

        .btn-search:hover {
            transform: translateY(-1px);
            box-shadow: 0 3px 10px rgba(74,158,255,0.4);
        }

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

<h2>Denomination View - Branch <%= branchCode %></h2>

<div class="container">

    <!-- Search Criteria -->
    <fieldset>
        <legend>Search Criteria</legend>
        <div class="form-row">
            <div class="form-group">
                <label class="label">From Date</label>
                <input type="date" id="fromDate">
            </div>
            <div class="form-group">
                <label class="label">To Date</label>
                <input type="date" id="toDate">
            </div>
            <div class="form-group">
                <label class="label">User ID</label>
                <input type="text" id="searchUser" placeholder="All Users">
            </div>
            <div class="form-group">
                <label class="label">Transaction Type</label>
                <select id="txnType">
                    <option value="">All</option>
                    <option value="IN">Cash In</option>
                    <option value="OUT">Cash Out</option>
                </select>
            </div>
            <div style="display:flex; align-items:flex-end;">
                <button class="btn-search" onclick="searchDenom()">🔍 Search</button>
            </div>
        </div>
    </fieldset>

    <!-- Denomination Details -->
    <fieldset>
        <legend>Denomination Details</legend>
        <div style="overflow-x: auto;">
            <table>
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>User</th>
                        <th>Type</th>
                        <th>₹500</th>
                        <th>₹200</th>
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
                    <tr><td colspan="13" class="no-data">Click Search to load data.</td></tr>
                </tbody>
                <tfoot>
                    <tr id="footRow" style="display:none">
                        <td colspan="3"><b>TOTAL</b></td>
                        <td id="ft500">0</td>
                        <td id="ft200">0</td>
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
    </fieldset>

    <!-- Buttons -->
    <div class="button-row">
        <button class="btn btn-primary" onclick="window.print()">🖨️ Print</button>
        <button class="btn btn-cancel"  onclick="cancelView()">Cancel</button>
    </div>

</div>

<script>
    const DEMO_DATA = [
        { date:'29-04-2026', user:'<%= userId %>', type:'IN',  d:[5,3,2,10,4,2,5,0,2], total:0 },
        { date:'29-04-2026', user:'<%= userId %>', type:'OUT', d:[2,1,1, 5,2,1,2,0,1], total:0 },
    ];
    const DENOMS = [500,200,100,50,20,10,5,2,1];
    DEMO_DATA.forEach(function(r) {
        r.total = r.d.reduce((s, q, i) => s + q * DENOMS[i], 0);
    });

    function searchDenom() {
        const tbody = document.getElementById('viewBody');
        if (DEMO_DATA.length === 0) {
            tbody.innerHTML = '<tr><td colspan="13" class="no-data">No records found.</td></tr>';
            document.getElementById('footRow').style.display = 'none';
            return;
        }

        const ft = new Array(9).fill(0);
        let ftTotal = 0;

        tbody.innerHTML = DEMO_DATA.map(function(r) {
            const cells = r.d.map((q, i) => {
                ft[i] += q * DENOMS[i];
                return '<td>' + (q * DENOMS[i]).toLocaleString('en-IN') + '</td>';
            }).join('');
            ftTotal += r.total;
            return '<tr><td>' + r.date + '</td><td>' + r.user + '</td><td>' + r.type + '</td>' + cells + '<td>' + r.total.toLocaleString('en-IN') + '</td></tr>';
        }).join('');

        const keys = [500,200,100,50,20,10,5,2,1];
        keys.forEach((k, i) => document.getElementById('ft' + k).textContent = ft[i].toLocaleString('en-IN'));
        document.getElementById('ftTotal').textContent = ftTotal.toLocaleString('en-IN');
        document.getElementById('footRow').style.display = '';
    }

    function cancelView() {
        document.getElementById('fromDate').value   = '';
        document.getElementById('toDate').value     = '';
        document.getElementById('searchUser').value = '';
        document.getElementById('viewBody').innerHTML = '<tr><td colspan="13" class="no-data">Click Search to load data.</td></tr>';
        document.getElementById('footRow').style.display = 'none';
    }

    window.onload = function() {
        if (window.parent && window.parent.updateParentBreadcrumb) {
            window.parent.updateParentBreadcrumb('Cashers > Denomination View', 'Cashers/denominationView.jsp');
        }
    };
</script>
</body>
</html>
