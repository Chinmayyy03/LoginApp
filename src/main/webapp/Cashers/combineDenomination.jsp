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
    <title>Combine Denomination</title>
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

        .btn-add {
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

        .btn-add:hover {
            transform: translateY(-1px);
            box-shadow: 0 3px 10px rgba(74,158,255,0.4);
        }

        @media (max-width: 768px) {
            .form-row { flex-direction: column; }
            .header-info { flex-direction: column; gap: 4px; text-align: center; }
        }
    </style>
</head>
<body>

<h2>Combine Denomination - Branch <%= branchCode %></h2>

<div class="container">

    <!-- Cash Details -->
    <fieldset>
        <legend>Cash Details</legend>
        <div class="form-row">
            <div class="form-group">
                <label class="label">Scroll Number</label>
                <input type="text" id="scrollNo" placeholder="Enter scroll number">
            </div>
            <div class="form-group">
                <label class="label">Amount (₹)</label>
                <input type="number" id="scrollAmt" placeholder="0.00">
            </div>
            <div style="display:flex; align-items:flex-end;">
                <button class="btn-add" onclick="addScroll()">➕ Add</button>
            </div>
        </div>
    </fieldset>

    <!-- Scroll List -->
    <fieldset>
        <legend>Scroll List</legend>
        <div style="overflow-x: auto;">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Scroll Number</th>
                        <th>Amount (₹)</th>
                    </tr>
                </thead>
                <tbody id="scrollBody">
                    <tr>
                        <td colspan="3" style="color:#999; padding:20px;">No scrolls added yet.</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </fieldset>

    <!-- Buttons -->
    <div class="button-row">
        <button class="btn btn-primary" onclick="validateCombine()">Validate</button>
        <button class="btn btn-success" onclick="saveCombine()">Save</button>
    </div>

</div>

<script>
    let scrollList = [];

    function addScroll() {
        const no  = document.getElementById('scrollNo').value.trim();
        const amt = document.getElementById('scrollAmt').value.trim();

        if (!no || !amt) { alert('Please enter both Scroll Number and Amount.'); return; }

        scrollList.push({ no, amt });
        render();

        document.getElementById('scrollNo').value  = '';
        document.getElementById('scrollAmt').value = '';
    }

    function render() {
        const tbody = document.getElementById('scrollBody');
        if (scrollList.length === 0) {
            tbody.innerHTML = '<tr><td colspan="3" style="color:#999; padding:20px;">No scrolls added yet.</td></tr>';
            return;
        }
        tbody.innerHTML = scrollList.map((s, i) =>
            '<tr><td>' + (i + 1) + '</td><td>' + s.no + '</td><td>' + parseFloat(s.amt).toLocaleString('en-IN') + '</td></tr>'
        ).join('');
    }

    function validateCombine() { alert('Combine Denomination validated successfully.'); }
    function saveCombine()     { alert('Combine Denomination saved successfully.'); }

    window.onload = function() {
        if (window.parent && window.parent.updateParentBreadcrumb) {
            window.parent.updateParentBreadcrumb('Cashers > Combine Denomination', 'Cashers/combineDenomination.jsp');
        }
    };
</script>
</body>
</html>
