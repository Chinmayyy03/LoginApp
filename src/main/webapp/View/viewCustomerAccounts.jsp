<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    String branchCode = (String) sess.getAttribute("branchCode");
%>

<%
    String customerId = request.getParameter("customerId");
    if (customerId == null || customerId.trim().isEmpty()) {
        out.println("<h3 style='color:red;'>Customer ID not provided.</h3>");
        return;
    }
    
    int recordsPerPage = 15;
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

.pagination-container {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 10px;
    margin: 20px 0;
    padding: 15px;
}

.pagination-btn {
    background: #2b0d73;
    color: white;
    padding: 8px 16px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 14px;
    font-weight: bold;
    transition: background 0.3s;
}

.pagination-btn:disabled {
    background: #ccc;
    cursor: not-allowed;
    opacity: 0.6;
}

.page-info {
    font-size: 14px;
    color: #2b0d73;
    font-weight: bold;
    padding: 0 15px;
}
</style>

<script>
// Store all account data for client-side search
let allAccounts = [];
let currentPage = 1;
const recordsPerPage = <%= recordsPerPage %>;

// Live search filter across ALL data
function searchTable() {
    var input = document.getElementById("searchInput");
    var filter = input.value.toLowerCase().trim();
    var table = document.getElementById("accountsTable");
    var tbody = table.querySelector("tbody");
    
    // Clear current table body
    tbody.innerHTML = "";
    
    // Filter all accounts
    let filteredAccounts = allAccounts;
    if (filter) {
        filteredAccounts = allAccounts.filter(function(account) {
            return account.branchCode.toLowerCase().indexOf(filter) > -1 ||
                   account.productCode.toLowerCase().indexOf(filter) > -1 ||
                   account.accountCode.toLowerCase().indexOf(filter) > -1 ||
                   account.name.toLowerCase().indexOf(filter) > -1;
        });
    }
    
    // Display filtered results (paginated)
    displayAccounts(filteredAccounts, 1);
}

// Display accounts with pagination
function displayAccounts(accounts, page) {
    currentPage = page;
    var table = document.getElementById("accountsTable");
    var tbody = table.querySelector("tbody");
    tbody.innerHTML = "";
    
    if (accounts.length === 0) {
        tbody.innerHTML = "<tr><td colspan='6' class='no-data'>No accounts found.</td></tr>";
        updatePaginationControls(0, page);
        return;
    }
    
    // Calculate start and end indices
    var start = (page - 1) * recordsPerPage;
    var end = Math.min(start + recordsPerPage, accounts.length);
    
    // Display accounts for current page
    for (var i = start; i < end; i++) {
        var account = accounts[i];
        var srNo = i + 1;
        var row = tbody.insertRow();
        row.innerHTML = 
            "<td>" + srNo + "</td>" +
            "<td>" + account.branchCode + "</td>" +
            "<td>" + account.productCode + "</td>" +
            "<td>" + account.accountCode + "</td>" +
            "<td>" + account.name + "</td>" +
            "<td><a href='#' onclick=\"viewAccount('" + account.accountCode + "'); return false;\" " +
            "style='background:#2b0d73;color:white;padding:4px 10px;" +
            "border-radius:4px;text-decoration:none;'>View Details</a></td>";
    }
    
    updatePaginationControls(accounts.length, page);
}

// Update pagination controls
function updatePaginationControls(totalRecords, page) {
    var totalPages = Math.ceil(totalRecords / recordsPerPage);
    
    document.getElementById("prevBtn").disabled = (page <= 1);
    document.getElementById("nextBtn").disabled = (page >= totalPages);
    
    var pageInfo = "Page " + page + " of " + totalPages;
    document.getElementById("pageInfo").textContent = pageInfo;
    
    // Store current page in sessionStorage for back button
    sessionStorage.setItem('customerAccountsPage', page);
}

// Navigate to previous page
function previousPage() {
    var filter = document.getElementById("searchInput").value.toLowerCase().trim();
    var accounts = allAccounts;
    
    if (filter) {
        accounts = allAccounts.filter(function(account) {
            return account.branchCode.toLowerCase().indexOf(filter) > -1 ||
                   account.productCode.toLowerCase().indexOf(filter) > -1 ||
                   account.accountCode.toLowerCase().indexOf(filter) > -1 ||
                   account.name.toLowerCase().indexOf(filter) > -1;
        });
    }
    
    if (currentPage > 1) {
        displayAccounts(accounts, currentPage - 1);
    }
}

// Navigate to next page
function nextPage() {
    var filter = document.getElementById("searchInput").value.toLowerCase().trim();
    var accounts = allAccounts;
    
    if (filter) {
        accounts = allAccounts.filter(function(account) {
            return account.branchCode.toLowerCase().indexOf(filter) > -1 ||
                   account.productCode.toLowerCase().indexOf(filter) > -1 ||
                   account.accountCode.toLowerCase().indexOf(filter) > -1 ||
                   account.name.toLowerCase().indexOf(filter) > -1;
        });
    }
    
    var totalPages = Math.ceil(accounts.length / recordsPerPage);
    if (currentPage < totalPages) {
        displayAccounts(accounts, currentPage + 1);
    }
}

// Update breadcrumb on page load
window.onload = function() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('View/viewCustomerAccounts.jsp', 'View/viewCustomer.jsp')
        );
    }
    
    // Check if returning from detail view and restore page
    var savedPage = sessionStorage.getItem('customerAccountsPage');
    if (savedPage) {
        currentPage = parseInt(savedPage);
        displayAccounts(allAccounts, currentPage);
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

function viewAccount(accountCode) {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('View/viewAccount.jsp', 'View/viewCustomerAccounts.jsp')
        );
    }
    window.location.href = '<%= request.getContextPath() %>/View/viewAccount.jsp?accountCode=' + accountCode + '&returnPage=View/viewCustomerAccounts.jsp?customerId=<%= customerId %>';
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

<div class="search-container">
     <input type="text" id="searchInput" onkeyup="searchTable()" placeholder="🔍 Search by Account Code, Name, Product Code, Branch">
</div>

<div class="table-container">
<table id="accountsTable">
<thead>
    <tr>
        <th>SR NO</th>
        <th>BRANCH CODE</th>
        <th>PRODUCT CODE</th>
        <th>ACCOUNT CODE</th>
        <th>NAME</th>
        <th>ACTION</th>
    </tr>
</thead>
<tbody>
<%
        // Get all accounts for this customer
        psAccounts = conn.prepareStatement(
            "SELECT ACCOUNT_CODE, NAME FROM ACCOUNT.ACCOUNT WHERE CUSTOMER_ID = ? ORDER BY ACCOUNT_CODE"
        );
        psAccounts.setString(1, customerId);
        rsAccounts = psAccounts.executeQuery();
        
        boolean hasAccounts = false;
        int displayCount = 0;
        int srNo = 1;
        
        while (rsAccounts.next()) {
            hasAccounts = true;
            String accountCode = rsAccounts.getString("ACCOUNT_CODE");
            String name = rsAccounts.getString("NAME");
            
            // Extract product code (5th, 6th, 7th digits)
            String productCode = "";
            String accountBranchCode = "";
            if (accountCode != null && accountCode.length() >= 7) {
                accountBranchCode = accountCode.substring(0, 4);
                productCode = accountCode.substring(4, 7);
            }
            
            // Add to JavaScript array for client-side operations
            out.println("<script>");
            out.println("allAccounts.push({");
            out.println("  branchCode: '" + accountBranchCode + "',");
            out.println("  productCode: '" + productCode + "',");
            out.println("  accountCode: '" + accountCode + "',");
            out.println("  name: '" + (name != null ? name.replace("'", "\\'") : "") + "'");
            out.println("});");
            out.println("</script>");
            
            // Display only first 15 records on initial load
            if (displayCount < recordsPerPage) {
                out.println("<tr>");
                out.println("<td>" + srNo + "</td>");
                out.println("<td>" + accountBranchCode + "</td>");
                out.println("<td>" + productCode + "</td>");
                out.println("<td>" + accountCode + "</td>");
                out.println("<td>" + (name != null ? name : "") + "</td>");
                
                out.println("<td><a href='#' onclick=\"viewAccount('" + accountCode + "'); return false;\" ");
                out.println("style='background:#2b0d73;color:white;padding:4px 10px;");
                out.println("border-radius:4px;text-decoration:none;'>View Details</a></td>");
                
                out.println("</tr>");
                displayCount++;
                srNo++;
            }
        }
        
        if (!hasAccounts) {
            out.println("<tr><td colspan='6' class='no-data'>No accounts found for this customer.</td></tr>");
        }
%>
</tbody>
</table>
</div>

<!-- Pagination Controls -->
<div class="pagination-container">
    <button id="prevBtn" class="pagination-btn" onclick="previousPage()">← Previous</button>
    <span id="pageInfo" class="page-info">Page 1</span>
    <button id="nextBtn" class="pagination-btn" onclick="nextPage()">Next →</button>
</div>

<div style="text-align:center; margin-top:20px;">
    <button type="button" onclick="goBackToCustomer();" class="back-btn">
        ← Back to Customer Details
    </button>
</div>

<script>
// Initialize pagination on page load
(function() {
    var totalPages = Math.ceil(allAccounts.length / recordsPerPage);
    document.getElementById("prevBtn").disabled = true;
    document.getElementById("nextBtn").disabled = (totalPages <= 1);
    document.getElementById("pageInfo").textContent = "Page 1 of " + totalPages;
    
    // Store initial page
    sessionStorage.setItem('customerAccountsPage', '1');
})();
</script>

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