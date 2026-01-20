<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>

<%
    String customerId = request.getParameter("customerId");
    if (customerId == null || customerId.trim().isEmpty()) {
        out.println("<h3 style='color:red;'>Customer ID not provided.</h3>");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Customer Accounts - <%= customerId %></title>
<script src="<%= request.getContextPath() %>/js/breadcrumb-auto.js"></script>

<link rel="stylesheet" href="../css/totalCustomers.css">
<style>
.customer-info {
    background: #ffffff;
    padding: 20px;
    margin: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
    border-left: 4px solid #2D2B80;
}

.customer-info h3 {
    color: #2D2B80;
    margin: 0 0 10px 0;
}

.customer-info p {
    margin: 5px 0;
    color: #555;
}

.back-btn {
    background: #373279;
    color: white;
    padding: 10px 20px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 14px;
    font-weight: bold;
    transition: background 0.3s;
    text-decoration: none;
    display: inline-block;
    margin: 20px;
}

.back-btn:hover {
    background: #2b0d73;
}

.action-btn {
    background: #2b0d73;
    color: white;
    padding: 4px 10px;
    border-radius: 4px;
    text-decoration: none;
    font-size: 12px;
    white-space: nowrap;
    cursor: pointer;
    border: none;
}

.action-btn:hover {
    background: #1a0548;
}
</style>

<script>
window.onload = function() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('View/viewCustomerAccounts.jsp', 'View/viewCustomer.jsp')
        );
    }
};

function goBackToCustomer() {
    var customerId = '<%= customerId %>';
    
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('View/viewCustomer.jsp')
        );
    }
    
    window.location.href = '<%= request.getContextPath() %>/View/viewCustomer.jsp?customerId=' + customerId;
}

function viewAccountDetails(accountCode) {
    alert('View details for account: ' + accountCode);
    // You can implement navigation to account details page here
    // window.location.href = '<%= request.getContextPath() %>/View/viewAccount.jsp?accountCode=' + accountCode;
}
</script>
</head>
<body>

<h2>Accounts for Customer: <%= customerId %></h2>

<%
    Connection conn = null;
    PreparedStatement psCustomer = null;
    PreparedStatement psAccounts = null;
    ResultSet rsCustomer = null;
    ResultSet rsAccounts = null;
    
    try {
        conn = DBConnection.getConnection();
        
        // Get customer name
        psCustomer = conn.prepareStatement("SELECT NAME FROM CUSTOMER.CUSTOMER WHERE CUSTOMER_ID = ?");
        psCustomer.setString(1, customerId);
        rsCustomer = psCustomer.executeQuery();
        
        String customerName = "";
        if (rsCustomer.next()) {
            customerName = rsCustomer.getString("NAME");
        }
%>

<div class="customer-info">
    <h3>Customer Information</h3>
    <p><strong>Customer ID:</strong> <%= customerId %></p>
    <p><strong>Name:</strong> <%= customerName %></p>
</div>

<div class="table-container">
<table id="accountsTable">
<thead>
    <tr>
        <th>SR NO</th>
        <th>ACCOUNT CODE</th>
        <th>ACTION</th>
    </tr>
</thead>
<tbody>
<%
        // Get all accounts for this customer
        psAccounts = conn.prepareStatement(
            "SELECT ACCOUNT_CODE FROM ACCOUNT.ACCOUNT WHERE CUSTOMER_ID = ? ORDER BY ACCOUNT_CODE"
        );
        psAccounts.setString(1, customerId);
        rsAccounts = psAccounts.executeQuery();
        
        boolean hasAccounts = false;
        int srNo = 1;
        
        while (rsAccounts.next()) {
            hasAccounts = true;
            String accountCode = rsAccounts.getString("ACCOUNT_CODE");
%>
    <tr>
        <td><%= srNo++ %></td>
        <td><%= accountCode %></td>
        <td>
            <button class="action-btn" onclick="viewAccountDetails('<%= accountCode %>')">
                View Details
            </button>
        </td>
    </tr>
<%
        }
        
        if (!hasAccounts) {
%>
    <tr>
        <td colspan="3" class="no-data">No accounts found for this customer.</td>
    </tr>
<%
        }
%>
</tbody>
</table>
</div>

<div style="text-align:center; margin-top:20px;">
    <button type="button" onclick="goBackToCustomer();" class="back-btn">
        ← Back to Customer Details
    </button>
</div>

<%
    } catch (Exception e) {
        out.println("<div class='customer-info' style='color:red;'>");
        out.println("<p>Error: " + e.getMessage() + "</p>");
        out.println("</div>");
        e.printStackTrace();
    } finally {
        try { if (rsAccounts != null) rsAccounts.close(); } catch (Exception e) {}
        try { if (rsCustomer != null) rsCustomer.close(); } catch (Exception e) {}
        try { if (psAccounts != null) psAccounts.close(); } catch (Exception e) {}
        try { if (psCustomer != null) psCustomer.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>

</body>
</html>