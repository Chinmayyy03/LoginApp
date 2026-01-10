<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    // Get branch code from session
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String branchCode = (String) sess.getAttribute("branchCode");
    Date workingDate = (Date) sess.getAttribute("workingDate");
    
    if (workingDate == null) {
        out.println("<script>alert('Working date not found. Please refresh the page.'); window.location='main.jsp';</script>");
        return;
    }
    
    int recordsPerPage = 15;
    
    // SR_NUMBER for Secured Loan in DASHBOARD table
    String srNumber = "6";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Secured Loan - Branch <%= branchCode %></title>
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

/* Number columns right-aligned */
.amount-col {
    text-align: right;
}
</style>
<script>
// Store all loan data for client-side search
let allLoans = [];
let currentPage = 1;
const recordsPerPage = <%= recordsPerPage %>;

// Live search filter across ALL data
function searchTable() {
    var input = document.getElementById("searchInput");
    var filter = input.value.toLowerCase().trim();
    var table = document.getElementById("loanTable");
    var tbody = table.querySelector("tbody");
    
    // Clear current table body
    tbody.innerHTML = "";
    
    // Filter all loans
    let filteredLoans = allLoans;
    if (filter) {
        filteredLoans = allLoans.filter(function(loan) {
            return loan.accountCode.toLowerCase().indexOf(filter) > -1 ||
                   loan.name.toLowerCase().indexOf(filter) > -1;
        });
    }
    
    // Display filtered results (paginated)
    displayLoans(filteredLoans, 1);
}

// Display loans with pagination
function displayLoans(loans, page) {
    currentPage = page;
    var table = document.getElementById("loanTable");
    var tbody = table.querySelector("tbody");
    tbody.innerHTML = "";
    
    if (loans.length === 0) {
        tbody.innerHTML = "<tr><td colspan='7' class='no-data'>No secured loans found.</td></tr>";
        updatePaginationControls(0, page);
        return;
    }
    
    // Calculate start and end indices
    var start = (page - 1) * recordsPerPage;
    var end = Math.min(start + recordsPerPage, loans.length);
    
    // Display loans for current page
    for (var i = start; i < end; i++) {
        var loan = loans[i];
        var srNo = i + 1;
        var row = tbody.insertRow();
        row.innerHTML = 
            "<td>" + srNo + "</td>" +
            "<td>" + loan.accountCode + "</td>" +
            "<td>" + loan.name + "</td>" +
            "<td>" + loan.dateAccountOpen + "</td>" +
            "<td class='amount-col'>" + loan.balance + "</td>" +
            "<td>" + loan.reviewDate + "</td>" +
            "<td><a href='#' onclick=\"viewLoan('" + loan.accountCode + "'); return false;\" " +
            "style='background:#2b0d73;color:white;padding:4px 10px;" +
            "border-radius:4px;text-decoration:none;'>View Details</a></td>";
    }
    
    updatePaginationControls(loans.length, page);
}

// Update pagination controls
function updatePaginationControls(totalRecords, page) {
    var totalPages = Math.ceil(totalRecords / recordsPerPage);
    
    document.getElementById("prevBtn").disabled = (page <= 1);
    document.getElementById("nextBtn").disabled = (page >= totalPages);
    
    var pageInfo = "Page " + page + " of " + totalPages;
    document.getElementById("pageInfo").textContent = pageInfo;
    
    // Store current page in sessionStorage for back button
    sessionStorage.setItem('securedLoanPage', page);
}

// Navigate to previous page
function previousPage() {
    var filter = document.getElementById("searchInput").value.toLowerCase().trim();
    var loans = allLoans;
    
    if (filter) {
        loans = allLoans.filter(function(loan) {
            return loan.accountCode.toLowerCase().indexOf(filter) > -1 ||
                   loan.name.toLowerCase().indexOf(filter) > -1;
        });
    }
    
    if (currentPage > 1) {
        displayLoans(loans, currentPage - 1);
    }
}

// Navigate to next page
function nextPage() {
    var filter = document.getElementById("searchInput").value.toLowerCase().trim();
    var loans = allLoans;
    
    if (filter) {
        loans = allLoans.filter(function(loan) {
            return loan.accountCode.toLowerCase().indexOf(filter) > -1 ||
                   loan.name.toLowerCase().indexOf(filter) > -1;
        });
    }
    
    var totalPages = Math.ceil(loans.length / recordsPerPage);
    if (currentPage < totalPages) {
        displayLoans(loans, currentPage + 1);
    }
}

// Update breadcrumb on page load
window.onload = function() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Dashboard > Secured Loan');
    }
    
    // Check if returning from detail view and restore page
    var savedPage = sessionStorage.getItem('securedLoanPage');
    if (savedPage) {
        currentPage = parseInt(savedPage);
        displayLoans(allLoans, currentPage);
    }
};

// View loan details and update breadcrumb
function viewLoan(accountCode) {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Dashboard > Secured Loan > View Details');
    }
    // Reuse existing viewAccount.jsp with returnPage parameter
    window.location.href = '../View/viewAccount.jsp?accountCode=' + accountCode + '&returnPage=Dashboard/securedLoan.jsp';
}
</script>
</head>
<body>

<h2>Secured Loan for Branch: <%= branchCode %></h2>

<div class="search-container">
     <input type="text" id="searchInput" onkeyup="searchTable()" placeholder="🔍 Search by Account Code, Name, Balance">
</div>

<div class="table-container">
<table id="loanTable">
<thead>
    <tr>
        <th>SR NO</th>
        <th>ACCOUNT CODE</th>
        <th>NAME</th>
        <th>DATE ACCOUNT OPEN</th>
        <th>BALANCE</th>
        <th>ACCOUNT REVIEW DATE</th>
        <th>ACTION</th>
    </tr>
</thead>
<tbody>
<%
Connection conn = null;
PreparedStatement psDashboard = null;
PreparedStatement psData = null;
ResultSet rsDashboard = null;
ResultSet rsData = null;

try {
    conn = DBConnection.getConnection();
    
    // Step 1: Get the query from DASHBOARD table
    String dashboardQuery = "SELECT D_QUERY FROM GLOBALCONFIG.DASHBOARD WHERE SR_NUMBER = ?";
    psDashboard = conn.prepareStatement(dashboardQuery);
    psDashboard.setString(1, srNumber);
    rsDashboard = psDashboard.executeQuery();
    
    String dynamicQuery = null;
    if (rsDashboard.next()) {
        dynamicQuery = rsDashboard.getString("QUERY");
    }
    
    if (dynamicQuery == null || dynamicQuery.trim().isEmpty()) {
        out.println("<tr><td colspan='7' class='no-data'>Query not configured in DASHBOARD table for SR_NUMBER: " + srNumber + "</td></tr>");
    } else {
        // Step 2: Execute the dynamic query
        // Replace placeholders with actual values
        dynamicQuery = dynamicQuery.replace(":workingDate", "?");
        dynamicQuery = dynamicQuery.replace(":branchCode", "?");
        
        psData = conn.prepareStatement(dynamicQuery);
        
        // Set parameters based on placeholders in query
        int paramIndex = 1;
        if (dynamicQuery.contains("?")) {
            // Count occurrences of ? to determine parameter binding
            int workingDateCount = (dynamicQuery.split("\\?", -1).length - 1);
            
            // Bind parameters (adjust based on your query structure)
            for (int i = 0; i < workingDateCount; i++) {
                if (i == 0) {
                    psData.setDate(paramIndex++, workingDate);
                } else if (i == 1) {
                    psData.setDate(paramIndex++, workingDate);
                } else if (i == 2) {
                    psData.setString(paramIndex++, branchCode);
                }
            }
        }
        
        rsData = psData.executeQuery();

        boolean hasData = false;
        int displayCount = 0;
        int srNo = 1;
        
        SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy");

        // Data Rows - display first 15 records initially
        while (rsData.next()) {
            hasData = true;
            String accountCode = rsData.getString("ACCOUNT_CODE");
            String name = rsData.getString("NAME");
            Date dateOpen = rsData.getDate("DATEACCOUNTOPEN");
            String dateOpenStr = (dateOpen != null) ? sdf.format(dateOpen) : "-";
            
            double balance = rsData.getDouble("v_os_balance");
            String balanceStr = String.format("%.2f", balance);
            
            Date reviewDate = rsData.getDate("ACCOUNTREVIEWDATE");
            String reviewDateStr = (reviewDate != null) ? sdf.format(reviewDate) : "-";
            
            // Add to JavaScript array for client-side operations
            out.println("<script>");
            out.println("allLoans.push({");
            out.println("  accountCode: '" + accountCode + "',");
            out.println("  name: '" + name.replace("'", "\\'") + "',");
            out.println("  dateAccountOpen: '" + dateOpenStr + "',");
            out.println("  balance: '" + balanceStr + "',");
            out.println("  reviewDate: '" + reviewDateStr + "'");
            out.println("});");
            out.println("</script>");
            
            // Display only first 15 records on initial load
            if (displayCount < recordsPerPage) {
                out.println("<tr>");
                out.println("<td>" + srNo + "</td>");
                out.println("<td>" + accountCode + "</td>");
                out.println("<td>" + name + "</td>");
                out.println("<td>" + dateOpenStr + "</td>");
                out.println("<td class='amount-col'>" + balanceStr + "</td>");
                out.println("<td>" + reviewDateStr + "</td>");
                
                // View button with onclick
                out.println("<td><a href='#' onclick=\"viewLoan('" + accountCode + "'); return false;\" ");
                out.println("style='background:#2b0d73;color:white;padding:4px 10px;");
                out.println("border-radius:4px;text-decoration:none;'>View Details</a></td>");
                
                out.println("</tr>");
                displayCount++;
                srNo++;
            }
        }

        if (!hasData) {
            out.println("<tr><td colspan='7' class='no-data'>No secured loans found for this branch.</td></tr>");
        }
    }

} catch (Exception e) {
    out.println("<tr><td colspan='7' class='no-data'>Error: " + e.getMessage() + "</td></tr>");
    e.printStackTrace();
} finally {
    try { if (rsData != null) rsData.close(); } catch (Exception ex) {}
    try { if (rsDashboard != null) rsDashboard.close(); } catch (Exception ex) {}
    try { if (psData != null) psData.close(); } catch (Exception ex) {}
    try { if (psDashboard != null) psDashboard.close(); } catch (Exception ex) {}
    try { if (conn != null) conn.close(); } catch (Exception ex) {}
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
    var totalPages = Math.ceil(allLoans.length / recordsPerPage);
    document.getElementById("prevBtn").disabled = true;
    document.getElementById("nextBtn").disabled = (totalPages <= 1);
    document.getElementById("pageInfo").textContent = "Page 1 of " + totalPages;
    
    // Store initial page
    sessionStorage.setItem('securedLoanPage', '1');
})();
</script>

</body>
</html>