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
            return account.branchName.toLowerCase().indexOf(filter) > -1 ||
                   account.productDesc.toLowerCase().indexOf(filter) > -1 ||
                   account.accountCode.toLowerCase().indexOf(filter) > -1 ||
                   account.openDate.toLowerCase().indexOf(filter) > -1 ||
                   account.maturityDate.toLowerCase().indexOf(filter) > -1 ||
                   account.installmentAmount.toLowerCase().indexOf(filter) > -1;
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
        tbody.innerHTML = "<tr><td colspan='8' class='no-data'>No accounts found.</td></tr>";
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
            "<td>" + account.branchName + "</td>" +
            "<td>" + account.productDesc + "</td>" +
            "<td>" + account.accountCode + "</td>" +
            "<td>" + account.openDate + "</td>" +
            "<td>" + account.maturityDate + "</td>" +
            "<td>" + account.maturityAmount + "</td>" +
            "<td>" + account.installmentAmount + "</td>" +
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
            return account.branchName.toLowerCase().indexOf(filter) > -1 ||
                   account.productDesc.toLowerCase().indexOf(filter) > -1 ||
                   account.accountCode.toLowerCase().indexOf(filter) > -1 ||
                   account.openDate.toLowerCase().indexOf(filter) > -1 ||
                   account.maturityDate.toLowerCase().indexOf(filter) > -1 ||
                   account.installmentAmount.toLowerCase().indexOf(filter) > -1;
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
            return account.branchName.toLowerCase().indexOf(filter) > -1 ||
                   account.productDesc.toLowerCase().indexOf(filter) > -1 ||
                   account.accountCode.toLowerCase().indexOf(filter) > -1 ||
                   account.openDate.toLowerCase().indexOf(filter) > -1 ||
                   account.maturityDate.toLowerCase().indexOf(filter) > -1 ||
                   account.installmentAmount.toLowerCase().indexOf(filter) > -1;
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
     <input type="text" id="searchInput" onkeyup="searchTable()" placeholder="🔍 Search by Account Code, Branch, Product Code">
</div>

<div class="table-container">
<table id="accountsTable">
<thead>
    <tr>
        <th>SR NO</th>
        <th>BRANCH CODE</th>
        <th>PRODUCT CODE</th>
        <th>ACCOUNT CODE</th>
        <th>ACCOUNT OPEN DATE</th>
        <th>MATURITY DATE</th>
        <th>MATURITY AMOUNT</th>
        <th>INSTALLMENT AMOUNT</th>
        <th>ACTION</th>
    </tr>
</thead>
<tbody>
<%
        // Load all branch names and product descriptions ONCE (optimization)
        java.util.Map<String, String> branchNames = new java.util.HashMap<>();
        java.util.Map<String, String> productDescs = new java.util.HashMap<>();
        
        // Load all branch names
        PreparedStatement psBranches = conn.prepareStatement("SELECT BRANCH_CODE, NAME FROM HEADOFFICE.BRANCH");
        ResultSet rsBranches = psBranches.executeQuery();
        while (rsBranches.next()) {
            branchNames.put(rsBranches.getString("BRANCH_CODE"), rsBranches.getString("NAME"));
        }
        rsBranches.close();
        psBranches.close();
        
        // Load all product descriptions
        PreparedStatement psProducts = conn.prepareStatement("SELECT PRODUCT_CODE, DESCRIPTION FROM HEADOFFICE.PRODUCT");
        ResultSet rsProducts = psProducts.executeQuery();
        while (rsProducts.next()) {
            productDescs.put(rsProducts.getString("PRODUCT_CODE"), rsProducts.getString("DESCRIPTION"));
        }
        rsProducts.close();
        psProducts.close();
        
        // Get all accounts for this customer
        psAccounts = conn.prepareStatement(
            "SELECT ACCOUNT_CODE, DATEACCOUNTOPEN FROM ACCOUNT.ACCOUNT WHERE CUSTOMER_ID = ? ORDER BY ACCOUNT_CODE"
        );
        psAccounts.setString(1, customerId);
        rsAccounts = psAccounts.executeQuery();
        
        boolean hasAccounts = false;
        int displayCount = 0;
        int srNo = 1;
        
        while (rsAccounts.next()) {
            hasAccounts = true;
            String accountCode = rsAccounts.getString("ACCOUNT_CODE");
            java.sql.Timestamp openDateTs = rsAccounts.getTimestamp("DATEACCOUNTOPEN");
            
            // Format open date
            String openDate = "";
            if (openDateTs != null) {
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MMM-yyyy");
                openDate = sdf.format(new java.util.Date(openDateTs.getTime()));
            }
            
            // Extract product code and branch code
            String productCode = "";
            String accountBranchCode = "";
            if (accountCode != null && accountCode.length() >= 7) {
                accountBranchCode = accountCode.substring(0, 4);
                productCode = accountCode.substring(4, 7);
            }
            
            // Get branch name and product description from HashMaps
            String branchName = branchNames.getOrDefault(accountBranchCode, accountBranchCode);
            String productDesc = productDescs.getOrDefault(productCode, productCode);
            
            // Get maturity date using function
            String maturityDate = "";
            PreparedStatement psMatDate = null;
            ResultSet rsMatDate = null;
            try {
                psMatDate = conn.prepareStatement("SELECT FN_GET_MAT_DATE(?) FROM DUAL");
                psMatDate.setString(1, accountCode);
                rsMatDate = psMatDate.executeQuery();
                if (rsMatDate.next()) {
                    java.sql.Timestamp matDateTs = rsMatDate.getTimestamp(1);
                    if (matDateTs != null) {
                        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MMM-yyyy");
                        maturityDate = sdf.format(new java.util.Date(matDateTs.getTime()));
                    }
                }
            } catch (Exception e) {
                maturityDate = "";
            } finally {
                try { if (rsMatDate != null) rsMatDate.close(); } catch (Exception ex) {}
                try { if (psMatDate != null) psMatDate.close(); } catch (Exception ex) {}
            }
            
            // Get maturity amount using function
            String maturityAmount = "";
            PreparedStatement psMatAmount = null;
            ResultSet rsMatAmount = null;
            try {
                psMatAmount = conn.prepareStatement("SELECT FN_GET_MAT_AMOUNT(?) FROM DUAL");
                psMatAmount.setString(1, accountCode);
                rsMatAmount = psMatAmount.executeQuery();
                if (rsMatAmount.next()) {
                    maturityAmount = rsMatAmount.getString(1);
                    if (maturityAmount == null) maturityAmount = "";
                }
            } catch (Exception e) {
                maturityAmount = "";
            } finally {
                try { if (rsMatAmount != null) rsMatAmount.close(); } catch (Exception ex) {}
                try { if (psMatAmount != null) psMatAmount.close(); } catch (Exception ex) {}
            }
            
            // Get installment amount using function
            String installmentAmount = "";
            PreparedStatement psInstAmount = null;
            ResultSet rsInstAmount = null;
            try {
                psInstAmount = conn.prepareStatement("SELECT FN_GET_LOAN_INST(?) FROM DUAL");
                psInstAmount.setString(1, accountCode);
                rsInstAmount = psInstAmount.executeQuery();
                if (rsInstAmount.next()) {
                    installmentAmount = rsInstAmount.getString(1);
                    if (installmentAmount == null) installmentAmount = "";
                }
            } catch (Exception e) {
                installmentAmount = "";
            } finally {
                try { if (rsInstAmount != null) rsInstAmount.close(); } catch (Exception ex) {}
                try { if (psInstAmount != null) psInstAmount.close(); } catch (Exception ex) {}
            }
            
            // Add to JavaScript array for client-side operations
            out.println("<script>");
            out.println("allAccounts.push({");
            out.println("  branchName: '" + (branchName != null ? branchName.replace("'", "\\'") : accountBranchCode) + "',");
            out.println("  productDesc: '" + (productDesc != null ? productDesc.replace("'", "\\'") : productCode) + "',");
            out.println("  accountCode: '" + accountCode + "',");
            out.println("  openDate: '" + openDate.replace("'", "\\'") + "',");
            out.println("  maturityDate: '" + maturityDate.replace("'", "\\'") + "',");
            out.println("  maturityAmount: '" + maturityAmount.replace("'", "\\'") + "',");
            out.println("  installmentAmount: '" + installmentAmount.replace("'", "\\'") + "'");
            out.println("});");
            out.println("</script>");
            
            // Display only first 15 records on initial load
            if (displayCount < recordsPerPage) {
                out.println("<tr>");
                out.println("<td>" + srNo + "</td>");
                out.println("<td>" + (branchName != null ? branchName : accountBranchCode) + "</td>");
                out.println("<td>" + (productDesc != null ? productDesc : productCode) + "</td>");
                out.println("<td>" + accountCode + "</td>");
                out.println("<td>" + openDate + "</td>");
                out.println("<td>" + maturityDate + "</td>");
                out.println("<td>" + maturityAmount + "</td>");
                out.println("<td>" + installmentAmount + "</td>");
                
                out.println("<td><a href='#' onclick=\"viewAccount('" + accountCode + "'); return false;\" ");
                out.println("style='background:#2b0d73;color:white;padding:4px 10px;");
                out.println("border-radius:4px;text-decoration:none;'>View Details</a></td>");
                
                out.println("</tr>");
                displayCount++;
                srNo++;
            }
        }
        
        if (!hasAccounts) {
            out.println("<tr><td colspan='9' class='no-data'>No accounts found for this customer.</td></tr>");
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