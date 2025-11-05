<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int totalCustomers = 0;
    double totalLoan = 0.00;

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM CUSTOMERS WHERE BRANCH_CODE=?")) {
        ps.setString(1, branchCode);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            totalCustomers = rs.getInt(1);
        }
    } catch (Exception e) {
        totalCustomers = 0;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/dashboard.css">
</head>
<body>
    <!-- Header inside iframe -->
    <div class="dashboard-header">
        <h1>
            <span style="font-size: 20px;">☰</span> Dashboard
        </h1>
        <div class="date" id="currentDate"></div>
    </div>

    <div class="dashboard-container">
        <div class="cards-wrapper">
        
            <div onclick="loadPage('customer_List.jsp')" class="card">
                <h3>Total Customers</h3>
                <p><%= totalCustomers %></p>
            </div>
            
            <div class="card">
                <h3>Total Loan</h3>
                <p><%= String.format("%.2f", totalLoan) %></p>
            </div>
            
        </div>
    </div>

    <script>
    // Display current date
    function updateDate() {
        const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
        const now = new Date();
        document.getElementById('currentDate').innerText = now.toLocaleDateString('en-US', options);
    }
    updateDate();

    // Load page function for cards
    function loadPage(page) {
        window.parent.document.getElementById("contentFrame").src = page;
    }
    </script>
</body>
</html>