<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    // Get branch code from session
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String branchCode = (String) sess.getAttribute("branchCode");
    
    int recordsPerPage = 15;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Total Accounts - Branch <%= branchCode %></title>
<link rel="stylesheet" href="../css/totalCustomers.css">
<style>
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
    var table = document.getElementById("accountTable");
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
    var table = document.getElementById("accountTable");
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
    sessionStorage.setItem('totalAccountsPage', page);
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
        window.parent.updateParentBreadcrumb('View > Total Accounts');
    }
    
    // Check if returning from detail view and restore page
    var savedPage = sessionStorage.getItem('totalAccountsPage');
    if (savedPage) {
        currentPage = parseInt(savedPage);
        displayAccounts(allAccounts, currentPage);
    }
};

// View account details
function viewAccount(accountCode) {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('View > Total Accounts > View Details');
    }
    window.location.href = 'viewAccount.jsp?accountCode=' + accountCode;
}
</script>
</head>
<body>

<h2>Total Accounts for Branch: <%= branchCode %></h2>

<div class="search-container">
     <input type="text" id="searchInput" onkeyup="searchTable()" placeholder="🔍 Search by Account Code, Name, Product Code, Branch">
</div>

<div class="table-container">
<table id="accountTable">
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
try (Connection conn = DBConnection.getConnection()) {
    
    // Get working date from session
    Date workingDate = (Date) session.getAttribute("workingDate");
    
    if (workingDate == null) {
        out.println("<tr><td colspan='6' class='no-data'>Working date not available. Please refresh the page.</td></tr>");
        return;
    }
    
    // Query to get accounts opened on working date
    PreparedStatement ps = conn.prepareStatement(
        "SELECT ACCOUNT_CODE, NAME " +
        "FROM ACCOUNT.ACCOUNT " +
        "WHERE SUBSTR(ACCOUNT_CODE, 1, 4) = ? " +
        "AND TRUNC(DATEACCOUNTOPEN) = TRUNC(?) " +
        "ORDER BY ACCOUNT_CODE");

    ps.setString(1, branchCode);
    ps.setDate(2, workingDate);
    ResultSet rs = ps.executeQuery();

    boolean hasData = false;
    int displayCount = 0;
    int srNo = 1;

    while (rs.next()) {
        hasData = true;
        String accountCode = rs.getString("ACCOUNT_CODE");
        String name = rs.getString("NAME");
        
        // Extract product code (5th, 6th, 7th digits)
        String productCode = "";
        if (accountCode != null && accountCode.length() >= 7) {
            productCode = accountCode.substring(4, 7);
        }
        
        // Add to JavaScript array for client-side operations
        out.println("<script>");
        out.println("allAccounts.push({");
        out.println("  branchCode: '" + branchCode + "',");
        out.println("  productCode: '" + productCode + "',");
        out.println("  accountCode: '" + accountCode + "',");
        out.println("  name: '" + (name != null ? name.replace("'", "\\'") : "") + "'");
        out.println("});");
        out.println("</script>");
        
        // Display only first 15 records on initial load
        if (displayCount < recordsPerPage) {
            out.println("<tr>");
            out.println("<td>" + srNo + "</td>");
            out.println("<td>" + branchCode + "</td>");
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

    if (!hasData) {
        out.println("<tr><td colspan='6' class='no-data'>No accounts found for today's working date.</td></tr>");
    }

} catch (Exception e) {
    out.println("<tr><td colspan='6' class='no-data'>Error: " + e.getMessage() + "</td></tr>");
    e.printStackTrace();
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

<script>
// Initialize pagination on page load
(function() {
    var totalPages = Math.ceil(allAccounts.length / recordsPerPage);
    document.getElementById("prevBtn").disabled = true;
    document.getElementById("nextBtn").disabled = (totalPages <= 1);
    document.getElementById("pageInfo").textContent = "Page 1 of " + totalPages;
    
    // Store initial page
    sessionStorage.setItem('totalAccountsPage', '1');
})();
</script>

</body>
</html>