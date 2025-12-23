<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Initialize all metrics
    int totalCustomers = 0;
    int members = 0;
    int nonMembers = 0;
    int others = 0;
    
    double totalLoan = 0;
    double securedLoan = 0;
    double unsecuredLoan = 0;
    double personalLoan = 0;
    
    double regularLoan = 0;
    double overdueLoan = 0;
    double npaLoan = 0;
    double lossAsset = 0;
    
    double casaDeposit = 0;
    double otherDeposit = 0;
    double bankBalance = 0;
    double cashBalance = 0;
    
    double cdResho = 0;
    double npaPercentage = 0;
    double investment = 0;
    double depositLoanResho = 0;
    
    double workingCapital = 0;
    double yearBeginProfitLoss = 0;
    double currentProfitLoss = 0;

    // Fetch Total Customers by type
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
             "SELECT COUNT(*) as total, " +
             "SUM(CASE WHEN CUSTOMER_TYPE='M' THEN 1 ELSE 0 END) as members, " +
             "SUM(CASE WHEN CUSTOMER_TYPE='NM' THEN 1 ELSE 0 END) as non_members, " +
             "SUM(CASE WHEN CUSTOMER_TYPE='O' THEN 1 ELSE 0 END) as others " +
             "FROM CUSTOMERS WHERE BRANCH_CODE=? AND STATUS='A'")) {
        ps.setString(1, branchCode);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            totalCustomers = rs.getInt("total");
            members = rs.getInt("members");
            nonMembers = rs.getInt("non_members");
            others = rs.getInt("others");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Fetch Loan Details
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
             "SELECT " +
             "SUM(LOAN_AMOUNT) as total, " +
             "SUM(CASE WHEN LOAN_TYPE='SECURED' THEN LOAN_AMOUNT ELSE 0 END) as secured, " +
             "SUM(CASE WHEN LOAN_TYPE='UNSECURED' THEN LOAN_AMOUNT ELSE 0 END) as unsecured, " +
             "SUM(CASE WHEN LOAN_TYPE='PERSONAL' THEN LOAN_AMOUNT ELSE 0 END) as personal " +
             "FROM LOANS WHERE BRANCH_CODE=? AND STATUS='A'")) {
        ps.setString(1, branchCode);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            totalLoan = rs.getDouble("total");
            securedLoan = rs.getDouble("secured");
            unsecuredLoan = rs.getDouble("unsecured");
            personalLoan = rs.getDouble("personal");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Fetch Regular Loan Details
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
             "SELECT " +
             "SUM(CASE WHEN LOAN_STATUS='REGULAR' THEN OUTSTANDING_AMOUNT ELSE 0 END) as regular, " +
             "SUM(CASE WHEN LOAN_STATUS='OVERDUE' THEN OUTSTANDING_AMOUNT ELSE 0 END) as overdue, " +
             "SUM(CASE WHEN LOAN_STATUS='NPA' THEN OUTSTANDING_AMOUNT ELSE 0 END) as npa, " +
             "SUM(CASE WHEN LOAN_STATUS='LOSS' THEN OUTSTANDING_AMOUNT ELSE 0 END) as loss " +
             "FROM LOANS WHERE BRANCH_CODE=?")) {
        ps.setString(1, branchCode);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            regularLoan = rs.getDouble("regular");
            overdueLoan = rs.getDouble("overdue");
            npaLoan = rs.getDouble("npa");
            lossAsset = rs.getDouble("loss");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Fetch Deposit Details
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
             "SELECT " +
             "SUM(CASE WHEN DEPOSIT_TYPE='CASA' THEN AMOUNT ELSE 0 END) as casa, " +
             "SUM(CASE WHEN DEPOSIT_TYPE='OTHER' THEN AMOUNT ELSE 0 END) as other_deposit " +
             "FROM DEPOSITS WHERE BRANCH_CODE=?")) {
        ps.setString(1, branchCode);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            casaDeposit = rs.getDouble("casa");
            otherDeposit = rs.getDouble("other_deposit");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Fetch Balance Details
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
             "SELECT BANK_BALANCE, CASH_BALANCE FROM BRANCH_BALANCE WHERE BRANCH_CODE=?")) {
        ps.setString(1, branchCode);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            bankBalance = rs.getDouble("BANK_BALANCE");
            cashBalance = rs.getDouble("CASH_BALANCE");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Calculate NPA Percentage
    if (totalLoan > 0) {
        npaPercentage = (npaLoan / totalLoan) * 100;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="css/dashboard.css">
    <style>
        body {
            margin: 0;
            font-family: 'Segoe UI', Roboto, Arial, sans-serif;
            background: #f5f7fa;
        }

        .dashboard-container {
            padding: 15px;
            background-color: #e8e4fc;
            height: 100vh;
            overflow: hidden;
        }

        .cards-wrapper {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 10px;
            height: calc(100vh - 30px);
            grid-auto-rows: minmax(0, 1fr);
        }

        .card {
            background: linear-gradient(135deg, #4a9eff 0%, #3d85d9 100%);
            color: white;
            padding: 12px 15px;
            border-radius: 12px;
            box-shadow: 0 8px 15px rgba(0, 0, 0, 0.15);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            position: relative;
            overflow: hidden;
            cursor: pointer;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .card::before, 
        .card::after {
            content: "";
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.1);
        }

        .card::before {
            width: 100px;
            height: 100px;
            top: -25px;
            right: -25px;
        }

        .card::after {
            width: 150px;
            height: 150px;
            bottom: -50px;
            left: -50px;
        }

        .card h3 {
            font-size: 11px;
            font-weight: 600;
            margin: 0 0 6px 0;
            position: relative;
            z-index: 1;
        }

        .card p {
            font-size: 20px;
            font-weight: 700;
            margin: 0;
            position: relative;
            z-index: 1;
        }

        .card:hover {
            transform: translateY(-5px) scale(1.02);
            box-shadow: 0 10px 25px rgba(74, 158, 255, 0.35);
        }



        @media (max-width: 1600px) {
            .cards-wrapper {
                grid-template-columns: repeat(4, 1fr);
            }
        }

        @media (max-width: 1200px) {
            .cards-wrapper {
                grid-template-columns: repeat(3, 1fr);
            }
        }

        @media (max-width: 900px) {
            .cards-wrapper {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 640px) {
            .dashboard-container {
                padding: 10px;
            }
            .cards-wrapper {
                grid-template-columns: 1fr;
                gap: 10px;
                height: auto;
                overflow-y: auto;
            }
            .card {
                padding: 12px 15px;
            }
            .card p {
                font-size: 20px;
            }
            .card h3 {
                font-size: 11px;
            }
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="cards-wrapper">
            <div class="cards-wrapper">
            <div class="card" onclick="openInParentFrame('totalCustomers.jsp', 'Dashboard > Total Customers')">
                <h3>Total Customers</h3>
                <p><%= totalCustomers %></p>
            </div>

            <div class="card" onclick="openInParentFrame('members.jsp', 'Dashboard > Members')">
                <h3>Members</h3>
                <p><%= members %></p>
            </div>
            <div class="card" onclick="openInParentFrame('nonMembers.jsp', 'Dashboard > Non-Members')">
                <h3>Non-Members</h3>
                <p><%= nonMembers %></p>
            </div>
            <div class="card" onclick="openInParentFrame('others.jsp', 'Dashboard > Others')">
                <h3>Others</h3>
                <p><%= others %></p>
            </div>
            <div class="card" onclick="openInParentFrame('totalLoans.jsp', 'Dashboard > Total Loans')">
                <h3>Total Loans</h3>
                <p>₹<%= String.format("%,.2f", totalLoan) %></p>
            </div>
            <div class="card" onclick="openInParentFrame('securedLoans.jsp', 'Dashboard > Secured Loans')">
                <h3>Secured</h3>
                <p>₹<%= String.format("%,.2f", securedLoan) %></p>
            </div>
            <div class="card" onclick="openInParentFrame('unsecuredLoans.jsp', 'Dashboard > Unsecured Loans')">
                <h3>Unsecured</h3>
                <p>₹<%= String.format("%,.2f", unsecuredLoan) %></p>
            </div>
            <div class="card" onclick="openInParentFrame('personalLoans.jsp', 'Dashboard > Personal Loans')">
                <h3>Personal</h3>
                <p>₹<%= String.format("%,.2f", personalLoan) %></p>
            </div>
            <div class="card" onclick="openInParentFrame('regularLoans.jsp', 'Dashboard > Regular Loans')">
                <h3>Regular Loan</h3>
                <p>₹<%= String.format("%,.2f", regularLoan) %></p>
            </div>
            <div class="card" onclick="openInParentFrame('overdueLoans.jsp', 'Dashboard > Overdue Loans')">
                <h3>Overdue</h3>
                <p>₹<%= String.format("%,.2f", overdueLoan) %></p>
            </div>
            <div class="card" onclick="openInParentFrame('npaLoans.jsp', 'Dashboard > NPA Loans')">
                <h3>NPA</h3>
                <p>₹<%= String.format("%,.2f", npaLoan) %></p>
            </div>
            <div class="card" onclick="openInParentFrame('lossAsset.jsp', 'Dashboard > Loss Asset')">
                <h3>Loss Asset</h3>
                <p>₹<%= String.format("%,.2f", lossAsset) %></p>
            </div>
            <div class="card" onclick="openInParentFrame('casaDeposit.jsp', 'Dashboard > CASA Deposit')">
                <h3>CASA Deposit</h3>
                <p>₹<%= String.format("%,.2f", casaDeposit) %></p>
            </div>
            <div class="card" onclick="openInParentFrame('otherDeposit.jsp', 'Dashboard > Other Deposit')">
                <h3>Other Deposit</h3>
                <p>₹<%= String.format("%,.2f", otherDeposit) %></p>
            </div>
            <div class="card" onclick="openInParentFrame('bankBalance.jsp', 'Dashboard > Bank Balance')">
                <h3>Bank Balance</h3>
                <p>₹<%= String.format("%,.2f", bankBalance) %></p>
            </div>
            <div class="card" onclick="openInParentFrame('cashBalance.jsp', 'Dashboard > Cash Balance')">
                <h3>Cash Balance</h3>
                <p>₹<%= String.format("%,.2f", cashBalance) %></p>
            </div>
            <div class="card" onclick="openInParentFrame('npaPercentage.jsp', 'Dashboard > NPA %')">
                <h3>NPA %</h3>
                <p><%= String.format("%.2f", npaPercentage) %>%</p>
            </div>
            <div class="card" onclick="openInParentFrame('investment.jsp', 'Dashboard > Investment')">
                <h3>Investment</h3>
                <p>₹<%= String.format("%,.2f", investment) %></p>
            </div>
            <div class="card" onclick="openInParentFrame('depositLoanResho.jsp', 'Dashboard > Deposit/Loan Resho')">
                <h3>Deposit/Loan Resho</h3>
                <p>₹<%= String.format("%,.2f", depositLoanResho) %></p>
            </div>
            <div class="card" onclick="openInParentFrame('workingCapital.jsp', 'Dashboard > Working Capital')">
                <h3>Working Capital</h3>
                <p>₹<%= String.format("%,.2f", workingCapital) %></p>
            </div>
            <div class="card" onclick="openInParentFrame('yearBeginPL.jsp', 'Dashboard > Year Begin P/L')">
                <h3>Year Begin Profit/Loss</h3>
                <p>₹<%= String.format("%,.2f", yearBeginProfitLoss) %></p>
            </div>
            <div class="card" onclick="openInParentFrame('currentPL.jsp', 'Dashboard > Current P/L')">
                <h3>Current Profit/Loss</h3>
                <p>₹<%= String.format("%,.2f", currentProfitLoss) %></p>
            </div>
        </div>
    </div>
    
    <script>
        window.onload = function() {
            if (window.parent && window.parent.updateParentBreadcrumb) {
                window.parent.updateParentBreadcrumb('Dashboard');
            }
        };

        function openInParentFrame(page, breadcrumbPath) {
            if (window.parent && window.parent.document) {
                const iframe = window.parent.document.getElementById("contentFrame");
                if (iframe) {
                    iframe.src = page;
                    
                    if (window.parent.updateParentBreadcrumb) {
                        window.parent.updateParentBreadcrumb(breadcrumbPath);
                    }
                }
            }
        }
    </script>
</body>
</html>