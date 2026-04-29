<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String userId    = (String) session.getAttribute("userId");
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
    <title>Casher</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #dbeeff 0%, #c7e3f8 40%, #b8d8f5 100%);
            min-height: 100vh;
            padding: 30px 24px;
        }

        /* ── Page Header ── */
        .page-header {
            text-align: center;
            margin-bottom: 36px;
        }
        .page-header h1 {
            font-size: 26px;
            font-weight: 700;
            color: #1a3a5c;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            border-bottom: 3px solid #4a90e2;
            display: inline-block;
            padding-bottom: 8px;
        }
        .page-header p {
            margin-top: 8px;
            font-size: 13px;
            color: #4a6fa5;
        }

        /* ── Grid ── */
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: 24px;
            max-width: 1100px;
            margin: 0 auto;
        }

        /* ── Card ── */
        .card {
            background: #fff;
            border-radius: 14px;
            box-shadow: 0 4px 18px rgba(74, 144, 226, 0.15);
            overflow: hidden;
            cursor: pointer;
            transition: transform 0.22s ease, box-shadow 0.22s ease;
            text-decoration: none;
            display: flex;
            flex-direction: column;
        }
        .card:hover {
            transform: translateY(-6px);
            box-shadow: 0 12px 32px rgba(74, 144, 226, 0.28);
        }
        .card:active {
            transform: translateY(-2px);
        }

        .card-icon-wrap {
            padding: 28px 0 20px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .card-icon {
            width: 68px;
            height: 68px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 30px;
            box-shadow: 0 4px 14px rgba(0,0,0,0.12);
        }

        /* individual card colours */
        .card:nth-child(1) .card-icon { background: linear-gradient(135deg, #4a90e2, #2563eb); }
        .card:nth-child(2) .card-icon { background: linear-gradient(135deg, #22c55e, #15803d); }
        .card:nth-child(3) .card-icon { background: linear-gradient(135deg, #f59e0b, #d97706); }
        .card:nth-child(4) .card-icon { background: linear-gradient(135deg, #8b5cf6, #6d28d9); }
        .card:nth-child(5) .card-icon { background: linear-gradient(135deg, #ef4444, #b91c1c); }

        .card:nth-child(1) { border-top: 4px solid #4a90e2; }
        .card:nth-child(2) { border-top: 4px solid #22c55e; }
        .card:nth-child(3) { border-top: 4px solid #f59e0b; }
        .card:nth-child(4) { border-top: 4px solid #8b5cf6; }
        .card:nth-child(5) { border-top: 4px solid #ef4444; }

        .card-body {
            padding: 0 22px 26px;
            text-align: center;
            flex: 1;
        }
        .card-title {
            font-size: 15px;
            font-weight: 700;
            color: #1a3a5c;
            margin-bottom: 8px;
            line-height: 1.35;
        }
        .card-desc {
            font-size: 12px;
            color: #6b8aaa;
            line-height: 1.5;
        }

        .card-footer {
            padding: 12px 22px;
            background: #f4f8fd;
            border-top: 1px solid #e2ecf7;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            font-size: 12px;
            font-weight: 600;
            color: #4a90e2;
        }
        .card-footer span.arrow {
            font-size: 14px;
            transition: transform 0.2s;
        }
        .card:hover .card-footer span.arrow {
            transform: translateX(4px);
        }
    </style>
</head>
<body>

<div class="page-header">
    <h1>&#128181; Casher Module</h1>
    <p>Manage cash transactions, denominations and reports</p>
</div>

<div class="cards-grid">

    <!-- 1. Cash In / Out -->
    <a class="card" href="#" onclick="goTo('cashInOut.jsp', 'Casher > Cash In / Out'); return false;">
        <div class="card-icon-wrap">
            <div class="card-icon">&#128176;</div>
        </div>
        <div class="card-body">
            <div class="card-title">Cash In / Out</div>
            <div class="card-desc">Record denomination-wise cash receipts and payments with opening &amp; current cash balance.</div>
        </div>
        <div class="card-footer">
            <span>Open</span><span class="arrow">&#8594;</span>
        </div>
    </a>

    <!-- 2. User Denomination Master -->
    <a class="card" href="#" onclick="goTo('userDenominationMaster.jsp', 'Casher > User Denomination Master'); return false;">
        <div class="card-icon-wrap">
            <div class="card-icon">&#128203;</div>
        </div>
        <div class="card-body">
            <div class="card-title">User Denomination Master</div>
            <div class="card-desc">Define and manage user-wise denomination limits and denomination mapping configuration.</div>
        </div>
        <div class="card-footer">
            <span>Open</span><span class="arrow">&#8594;</span>
        </div>
    </a>

    <!-- 3. Cash Combine Denomination -->
    <a class="card" href="#" onclick="goTo('combineDenomination.jsp', 'Casher > Cash Combine Denomination'); return false;">
        <div class="card-icon-wrap">
            <div class="card-icon">&#128197;</div>
        </div>
        <div class="card-body">
            <div class="card-title">Cash Combine Denomination</div>
            <div class="card-desc">Combine accept &amp; pay cash denominations for multiple scrolls in one transaction.</div>
        </div>
        <div class="card-footer">
            <span>Open</span><span class="arrow">&#8594;</span>
        </div>
    </a>

    <!-- 4. Denomination View -->
    <a class="card" href="#" onclick="goTo('denominationView.jsp', 'Casher > Denomination View'); return false;">
        <div class="card-icon-wrap">
            <div class="card-icon">&#128269;</div>
        </div>
        <div class="card-body">
            <div class="card-title">Denomination View</div>
            <div class="card-desc">View denomination-wise cash position for any date range and user or branch.</div>
        </div>
        <div class="card-footer">
            <span>Open</span><span class="arrow">&#8594;</span>
        </div>
    </a>

    <!-- 5. Denomination Report -->
    <a class="card" href="#" onclick="goTo('denominationReport.jsp', 'Casher > Denomination Report'); return false;">
        <div class="card-icon-wrap">
            <div class="card-icon">&#128196;</div>
        </div>
        <div class="card-body">
            <div class="card-title">Denomination Report</div>
            <div class="card-desc">Generate and print denomination-wise cash reports for audit and reconciliation.</div>
        </div>
        <div class="card-footer">
            <span>Open</span><span class="arrow">&#8594;</span>
        </div>
    </a>

</div>

<script>
    function goTo(page, breadcrumb) {
        if (window.parent && window.parent.updateParentBreadcrumb) {
            window.parent.updateParentBreadcrumb(breadcrumb, 'Cashers/' + page);
        }
        window.location.href = page;
    }
</script>
</body>
</html>
