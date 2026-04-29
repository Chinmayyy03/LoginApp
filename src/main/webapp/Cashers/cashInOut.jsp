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
        // fetch bank code + working date
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
    <title>Cash In / Out</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(160deg, #dbeeff 0%, #c4dff7 100%);
            min-height: 100vh;
            padding: 20px;
            font-size: 13px;
        }

        .page-wrapper {
            max-width: 700px;
            margin: 0 auto;
            background: rgba(255,255,255,0.65);
            border-radius: 12px;
            box-shadow: 0 4px 24px rgba(74,144,226,0.18);
            overflow: hidden;
        }

        /* ─── Bank Header ─── */
        .bank-header {
            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);
            color: #fff;
            text-align: center;
            padding: 14px 20px 10px;
        }
        .bank-header h2 { font-size: 15px; font-weight: 700; letter-spacing: .5px; }
        .bank-header h3 { font-size: 17px; font-weight: 800; margin-top: 4px; letter-spacing: 1px; }

        /* ─── Meta Row ─── */
        .meta-row {
            background: #e8f0fb;
            display: flex;
            justify-content: center;
            gap: 28px;
            padding: 7px 16px;
            font-size: 12px;
            color: #1a3a5c;
            font-weight: 600;
            flex-wrap: wrap;
        }
        .meta-row span b { color: #2563eb; margin-left: 4px; }

        /* ─── Section Labels ─── */
        .section-label {
            padding: 6px 16px;
            font-size: 11px;
            font-weight: 700;
            color: #2563eb;
            border-bottom: 1px solid #d0e4f7;
            background: #f0f6ff;
            text-transform: uppercase;
            letter-spacing: .5px;
        }

        /* ─── Account Details ─── */
        .account-details {
            padding: 12px 20px;
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            background: #fff;
            border-bottom: 1px solid #d8eaf8;
        }
        .field-group {
            display: flex;
            flex-direction: column;
            gap: 3px;
        }
        .field-group label {
            font-size: 11px;
            font-weight: 600;
            color: #4a6fa5;
        }
        .field-group input {
            padding: 5px 10px;
            border: 1px solid #b8d4ee;
            border-radius: 5px;
            background: #f4f8fd;
            font-size: 12px;
            width: 140px;
            color: #1a3a5c;
        }
        .field-group input:focus {
            outline: none;
            border-color: #4a90e2;
            background: #fff;
        }

        /* ─── Denomination Table ─── */
        .denom-section { padding: 0 20px 12px; background: #fff; }
        table.denom-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 8px;
        }
        .denom-table thead tr {
            background: linear-gradient(90deg, #2563eb, #4a90e2);
            color: #fff;
        }
        .denom-table thead th {
            padding: 7px 10px;
            text-align: center;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: .3px;
        }
        .denom-table tbody tr:nth-child(even) { background: #f0f6ff; }
        .denom-table tbody tr:hover { background: #dbeeff; }
        .denom-table td {
            padding: 5px 8px;
            text-align: center;
            font-size: 12px;
            color: #1a3a5c;
            font-weight: 600;
        }
        .denom-table input[type="number"] {
            width: 90px;
            padding: 4px 8px;
            border: 1px solid #b8d4ee;
            border-radius: 4px;
            text-align: right;
            font-size: 12px;
            background: #f9fcff;
            color: #1a3a5c;
        }
        .denom-table input[type="number"]:focus {
            outline: none;
            border-color: #2563eb;
            background: #fff;
        }

        /* ─── Summary Row ─── */
        .summary-block {
            padding: 10px 20px;
            background: #e8f0fb;
            display: flex;
            gap: 30px;
            flex-wrap: wrap;
            border-top: 1px solid #c7dff5;
        }
        .summary-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 12px;
            font-weight: 600;
            color: #1a3a5c;
        }
        .summary-item input {
            width: 120px;
            padding: 5px 10px;
            border: 1px solid #b8d4ee;
            border-radius: 5px;
            background: #fff;
            font-size: 12px;
            font-weight: 700;
            color: #2563eb;
            text-align: right;
        }

        /* ─── Message ─── */
        .msg-row {
            padding: 10px 20px;
            background: #fff;
            border-top: 1px solid #d8eaf8;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .msg-row label { font-size: 12px; font-weight: 600; color: #4a6fa5; white-space: nowrap; }
        .msg-row input {
            flex: 1;
            padding: 6px 10px;
            border: 1px solid #b8d4ee;
            border-radius: 5px;
            font-size: 12px;
            color: #1a3a5c;
        }

        /* ─── Buttons ─── */
        .btn-row {
            padding: 14px 20px;
            background: #f4f8fd;
            display: flex;
            justify-content: center;
            gap: 12px;
            border-top: 1px solid #d8eaf8;
        }
        .btn {
            padding: 8px 26px;
            border: none;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: all .2s;
            letter-spacing: .3px;
        }
        .btn-validate { background: #2563eb; color: #fff; }
        .btn-validate:hover { background: #1d4ed8; transform: translateY(-1px); }
        .btn-save { background: #22c55e; color: #fff; }
        .btn-save:hover { background: #16a34a; transform: translateY(-1px); }
        .btn-cancel { background: #ef4444; color: #fff; }
        .btn-cancel:hover { background: #dc2626; transform: translateY(-1px); }
    </style>
</head>
<body>

<div class="page-wrapper">

    <!-- Bank Header -->
    <div class="bank-header">
        <h2><%= bankName.toUpperCase() %></h2>
        <h3>CASH IN / OUT (CASH ENTRY)</h3>
    </div>

    <!-- Meta Row -->
    <div class="meta-row">
        <span>BANK CODE : <b><%= bankCode %></b></span>
        <span>BRANCH CODE : <b><%= branchCode %></b></span>
        <span>USER : <b><%= userId %></b></span>
        <span>DATE : <b><%= workingDate %></b></span>
    </div>

    <!-- Account Details -->
    <div class="section-label">Account Details</div>
    <div class="account-details">
        <div class="field-group">
            <label>Cash Handling Date</label>
            <input type="date" id="cashHandlingDate" name="cashHandlingDate">
        </div>
        <div class="field-group">
            <label>Opening Cash</label>
            <input type="text" id="openingCash" name="openingCash" readonly placeholder="0.00">
        </div>
        <div class="field-group">
            <label>Current Cash</label>
            <input type="text" id="currentCash" name="currentCash" readonly placeholder="0.00">
        </div>
    </div>

    <!-- Denomination Table -->
    <div class="section-label">Cash Details</div>
    <div class="denom-section">
        <table class="denom-table" id="denomTable">
            <thead>
                <tr>
                    <th>Denomination (₹)</th>
                    <th>No. of Notes</th>
                    <th>Amount (₹)</th>
                </tr>
            </thead>
            <tbody id="denomBody">
                <!-- rows filled by JS -->
            </tbody>
        </table>
    </div>

    <!-- Summary -->
    <div class="summary-block">
        <div class="summary-item">
            Change :
            <input type="text" id="changeAmt" readonly placeholder="0">
        </div>
        <div class="summary-item">
            Total Amount :
            <input type="text" id="totalAmt" readonly placeholder="0">
        </div>
        <div class="summary-item">
            Remaining Amount :
            <input type="text" id="remainingAmt" readonly placeholder="0">
        </div>
        <div class="summary-item">
            Denomination Amount :
            <input type="text" id="denomAmt" readonly placeholder="0">
        </div>
    </div>

    <!-- Message -->
    <div class="msg-row">
        <label>Message :</label>
        <input type="text" id="message" placeholder="">
    </div>

    <!-- Buttons -->
    <div class="btn-row">
        <button class="btn btn-validate" onclick="validateCash()">Validate</button>
        <button class="btn btn-save"     onclick="saveCash()">Save</button>
        <button class="btn btn-cancel"   onclick="cancelCash()">Cancel</button>
    </div>

</div>

<script>
    const DENOMS = [2000, 1000, 500, 100, 50, 20, 10, 5, 2, 1];

    // Build rows
    const tbody = document.getElementById('denomBody');
    DENOMS.forEach(function(d) {
        const tr = document.createElement('tr');
        tr.innerHTML =
            '<td>₹ ' + d + '</td>' +
            '<td><input type="number" min="0" value="0" class="qty-input" data-denom="' + d + '" oninput="recalc()"></td>' +
            '<td class="amt-cell" id="amt-' + d + '">0</td>';
        tbody.appendChild(tr);
    });

    function recalc() {
        let total = 0;
        document.querySelectorAll('.qty-input').forEach(function(inp) {
            const d = parseInt(inp.dataset.denom);
            const q = parseInt(inp.value) || 0;
            const amt = d * q;
            document.getElementById('amt-' + d).textContent = amt.toLocaleString('en-IN');
            total += amt;
        });
        document.getElementById('totalAmt').value   = total.toLocaleString('en-IN');
        document.getElementById('denomAmt').value   = total.toLocaleString('en-IN');
        document.getElementById('changeAmt').value  = 0;
        document.getElementById('remainingAmt').value = 0;
    }

    function validateCash() {
        const date = document.getElementById('cashHandlingDate').value;
        if (!date) { alert('Please select Cash Handling Date.'); return; }
        const total = document.getElementById('totalAmt').value;
        document.getElementById('message').value = 'Validated successfully. Total: ₹ ' + total;
    }

    function saveCash() {
        const date = document.getElementById('cashHandlingDate').value;
        if (!date) { alert('Please select Cash Handling Date.'); return; }
        alert('Cash entry saved successfully!');
    }

    function cancelCash() {
        document.querySelectorAll('.qty-input').forEach(i => i.value = 0);
        document.getElementById('cashHandlingDate').value = '';
        document.getElementById('message').value = '';
        recalc();
    }
</script>
</body>
</html>
