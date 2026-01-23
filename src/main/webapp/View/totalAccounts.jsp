<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    // Get branch code from session or filter
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String sessionBranchCode = (String) sess.getAttribute("branchCode");
    String filterBranchCode = request.getParameter("branchCode");
    
    // Use filter if provided, otherwise use session branch
    String branchCode = (filterBranchCode != null && !filterBranchCode.trim().isEmpty()) 
                        ? filterBranchCode.trim() 
                        : sessionBranchCode;
    
    int recordsPerPage = 15;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Total Accounts - Branch <%= branchCode %></title>
<script src="<%= request.getContextPath() %>/js/breadcrumb-auto.js"></script>

<link rel="stylesheet" href="../css/totalCustomers.css">
<style>
.branch-filter-container {
    background: #ffffff;
    padding: 10px 30px 10px 30px;
    margin: 20px 20px 0px 20px;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.filter-row {
    display: flex;
    gap: 25px;
    margin-bottom: 20px;
    align-items: flex-start;
}

.filter-group {
    flex: 1;
}

.label {
    font-weight: bold;
    font-size: 14px;
    color: #3D316F;
    margin-bottom: 8px;
    display: block;
}

.input-box {
    display: flex;
    align-items: center;
    gap: 10px;
}

.input-box select,
.input-box input {
    padding: 10px;
    border: 2px solid #C8B7F6;
    border-radius: 8px;
    background-color: #F4EDFF;
    outline: none;
    font-size: 14px;
    width: 100%;
}

.input-box select:focus,
.input-box input:focus {
    border-color: #8066E8;
}

.input-box input[readonly] {
    background-color: #f5f5f5;
    cursor: not-allowed;
}

.filter-btn-container {
    display: flex;
    align-items: flex-end;
}

.filter-btn {
    background: #2D2B80;
    color: white;
    padding: 10px 24px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-size: 14px;
    font-weight: bold;
    transition: background 0.3s;
    margin-top: 14px;
}

.filter-btn:hover {
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

@media (max-width: 1000px) {
    .filter-row {
        gap: 15px;
    }
}

@media (max-width: 768px) {
    .input-box {
        width: 100%;
    }
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
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('View/totalAccounts.jsp')
        );
    }
    
    // Check if returning from detail view and restore page
    var savedPage = sessionStorage.getItem('totalAccountsPage');
    if (savedPage) {
        currentPage = parseInt(savedPage);
        displayAccounts(allAccounts, currentPage);
    }
    
    // Set initial branch description
    updateBranchDescription();
};

function viewAccount(accountCode) {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('View/viewAccount.jsp', 'View/totalAccounts.jsp')
        );
    }
    window.location.href = '<%= request.getContextPath() %>/View/viewAccount.jsp?accountCode=' + accountCode + '&returnPage=View/totalAccounts.jsp';
}

function filterByBranch() {
    var branchSelect = document.getElementById("branchInput");
    var branchCode = branchSelect.value.trim();
    
    if (branchCode.length === 0) {
        alert("Please select a branch");
        return;
    }
    
    window.location.href = 'totalAccounts.jsp?branchCode=' + encodeURIComponent(branchCode);
}

function updateBranchDescription() {
    var branchSelect = document.getElementById("branchInput");
    var descField = document.getElementById("branchDescription");
    var selectedOption = branchSelect.options[branchSelect.selectedIndex];
    
    if (selectedOption.value) {
        descField.value = selectedOption.getAttribute("data-name");
    } else {
        descField.value = "";
    }
}

</script>
</head>
<body>

<h2>Total Accounts for Branch: <%= branchCode %></h2>

<div class="branch-filter-container">
    <div class="filter-row">
        <!-- Branch Dropdown -->
        <div class="filter-group">
            <label class="label" for="branchInput">Branch</label>
            <div class="input-box">
                <select id="branchInput" onchange="updateBranchDescription()">
                    <option value="">Select Branch</option>
                    <%
                    Connection conn = null;
                    PreparedStatement ps = null;
                    ResultSet rs = null;
                    try {
                        conn = DBConnection.getConnection();
                        ps = conn.prepareStatement("SELECT BRANCH_CODE, NAME FROM HEADOFFICE.BRANCH ORDER BY BRANCH_CODE");
                        rs = ps.executeQuery();
                        
                        while (rs.next()) {
                            String code = rs.getString("BRANCH_CODE");
                            String name = rs.getString("NAME");
                            String selected = code.equals(branchCode) ? "selected" : "";
                    %>
                            <option value="<%= code %>" data-name="<%= name %>" <%= selected %>><%= code %></option>
                    <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        try { if (rs != null) rs.close(); } catch (Exception e) {}
                        try { if (ps != null) ps.close(); } catch (Exception e) {}
                        try { if (conn != null) conn.close(); } catch (Exception e) {}
                    }
                    %>
                </select>
            </div>
        </div>
        
        <!-- Branch Description -->
        <div class="filter-group">
            <label class="label" for="branchDescription">Description</label>
            <div class="input-box">
                <input type="text" id="branchDescription" placeholder="Branch Name" readonly>
            </div>
        </div>
        
        <!-- Filter Button -->
        <div class="filter-btn-container">
            <button type="button" class="filter-btn" onclick="filterByBranch()">Filter</button>
        </div>
    </div>
</div>

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
try {
    conn = DBConnection.getConnection();
    
    // Query to get all accounts for the branch
    ps = conn.prepareStatement(
        "SELECT ACCOUNT_CODE, NAME " +
        "FROM ACCOUNT.ACCOUNT " +
        "WHERE SUBSTR(ACCOUNT_CODE, 1, 4) = ? " +
        "ORDER BY ACCOUNT_CODE");

    ps.setString(1, branchCode);
    rs = ps.executeQuery();

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
        out.println("<tr><td colspan='6' class='no-data'>No accounts found for branch code: " + branchCode + "</td></tr>");
    }

} catch (Exception e) {
    out.println("<tr><td colspan='6' class='no-data'>Error: " + e.getMessage() + "</td></tr>");
    e.printStackTrace();
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
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