<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    // ========================================
    // STEP 1: Session Validation
    // ========================================
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
    
    // Get return page parameter (for back button functionality)
    String returnPage = request.getParameter("returnPage");
    if (returnPage == null || returnPage.trim().isEmpty()) {
        returnPage = "Dashboard/dashboard.jsp";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Unsecured Loan - Branch <%= branchCode %></title>
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

.amount-col {
    text-align: right;
}

.error-box {
    background: #ffebee;
    color: #c62828;
    padding: 20px;
    margin: 20px;
    border-radius: 8px;
    border-left: 4px solid #c62828;
}
</style>

<script>
// Store all unsecured loan data for client-side search
let allUnsecuredLoans = [];
let currentPage = 1;
const recordsPerPage = <%= recordsPerPage %>;

// Live search filter across ALL data
function searchTable() {
    var input = document.getElementById("searchInput");
    var filter = input.value.toLowerCase().trim();
    var table = document.getElementById("unsecuredLoanTable");
    var tbody = table.querySelector("tbody");
    
    tbody.innerHTML = "";
    
    let filteredLoans = allUnsecuredLoans;
    if (filter) {
        filteredLoans = allUnsecuredLoans.filter(function(loan) {
            return loan.accountCode.toLowerCase().indexOf(filter) > -1 ||
                   loan.name.toLowerCase().indexOf(filter) > -1;
        });
    }
    
    displayLoans(filteredLoans, 1);
}

// Display loans with pagination
function displayLoans(loans, page) {
    currentPage = page;
    var table = document.getElementById("unsecuredLoanTable");
    var tbody = table.querySelector("tbody");
    tbody.innerHTML = "";
    
    if (loans.length === 0) {
        tbody.innerHTML = "<tr><td colspan='7' class='no-data'>No unsecured loans found.</td></tr>";
        updatePaginationControls(0, page);
        return;
    }
    
    var start = (page - 1) * recordsPerPage;
    var end = Math.min(start + recordsPerPage, loans.length);
    
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
    
    document.getElementById("pageInfo").textContent = "Page " + page + " of " + totalPages;
    sessionStorage.setItem('unsecuredLoanPage', page);
}

// Navigate to previous page
function previousPage() {
    var filter = document.getElementById("searchInput").value.toLowerCase().trim();
    var loans = allUnsecuredLoans;
    
    if (filter) {
        loans = allUnsecuredLoans.filter(function(loan) {
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
    var loans = allUnsecuredLoans;
    
    if (filter) {
        loans = allUnsecuredLoans.filter(function(loan) {
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
        window.parent.updateParentBreadcrumb('Dashboard > Unsecured Loan');
    }
    
    var savedPage = sessionStorage.getItem('unsecuredLoanPage');
    if (savedPage) {
        currentPage = parseInt(savedPage);
        displayLoans(allUnsecuredLoans, currentPage);
    }
};

// View loan details and update breadcrumb
function viewLoan(accountCode) {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Dashboard > Unsecured Loan > View Details');
    }
    window.location.href = '../View/viewAccount.jsp?accountCode=' + accountCode + '&returnPage=Dashboard/unsecuredLoan.jsp';
}
</script>
</head>
<body>

<h2>Unsecured Loan for Branch: <%= branchCode %></h2>

<div class="search-container">
     <input type="text" id="searchInput" onkeyup="searchTable()" placeholder="🔍 Search by Account Code, Name, Balance">
</div>

<div class="table-container">
<table id="unsecuredLoanTable">
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
    // ========================================
    // STEP 2: Fetch Query Configuration from DASHBOARD
    // ========================================
    Connection conn = null;
    PreparedStatement psConfig = null;
    PreparedStatement psDynamic = null;
    ResultSet rsConfig = null;
    ResultSet rsDynamic = null;
    
    String dynamicQuery = null;
    
    try {
        conn = DBConnection.getConnection();
        
        // Fetch D_QUERY from DASHBOARD table for Unsecured Loan (SR_NUMBER = 7)
        String configQuery = "SELECT D_QUERY FROM GLOBALCONFIG.DASHBOARD WHERE SR_NUMBER = 7";
        
        psConfig = conn.prepareStatement(configQuery);
        rsConfig = psConfig.executeQuery();
        
        if (rsConfig.next()) {
            dynamicQuery = rsConfig.getString("D_QUERY");
            
            // ========================================
            // STEP 3: Validate D_QUERY
            // ========================================
            if (dynamicQuery == null || dynamicQuery.trim().isEmpty()) {
                out.println("<tr><td colspan='7' class='no-data'>");
                out.println("<div class='error-box'>");
                out.println("<h3>⚠ Configuration Error</h3>");
                out.println("<p>No query defined in GLOBALCONFIG.DASHBOARD table (SR_NUMBER = 7).</p>");
                out.println("<p>Please configure the D_QUERY column.</p>");
                out.println("</div>");
                out.println("</td></tr>");
                return;
            }
            
        } else {
            out.println("<tr><td colspan='7' class='no-data'>");
            out.println("<div class='error-box'>");
            out.println("<h3>⚠ Configuration Not Found</h3>");
            out.println("<p>Dashboard entry not found for SR_NUMBER = 7</p>");
            out.println("</div>");
            out.println("</td></tr>");
            return;
        }
        
        rsConfig.close();
        psConfig.close();
        
        // ========================================
        // STEP 4: Parse Query and Replace Parameters
        // ========================================
        // Count occurrences of '!' and '#' to know how many parameters to bind
        int workingDateCount = 0;
        int branchCodeCount = 0;
        
        for (char c : dynamicQuery.toCharArray()) {
            if (c == '!') workingDateCount++;
            if (c == '#') branchCodeCount++;
        }
        
        // Replace '!' with '?' for DATE parameters
        // Replace '#' with '?' for BRANCH parameters
        String preparedQuery = dynamicQuery.replace('!', '?').replace('#', '?');
        
        // ========================================
        // STEP 5: Execute Dynamic Query with Parameters
        // ========================================
        psDynamic = conn.prepareStatement(preparedQuery);
        
        // Bind parameters in the order they appear
        int paramIndex = 1;
        for (char c : dynamicQuery.toCharArray()) {
            if (c == '!') {
                // Bind working date
                psDynamic.setDate(paramIndex++, workingDate);
            } else if (c == '#') {
                // Bind branch code
                psDynamic.setString(paramIndex++, branchCode);
            }
        }
        
        rsDynamic = psDynamic.executeQuery();
        
        // ========================================
        // STEP 6: Process and Display Results
        // ========================================
        boolean hasData = false;
        int displayCount = 0;
        int srNo = 1;
        
        SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy");
        
        while (rsDynamic.next()) {
            hasData = true;
            String accountCode = rsDynamic.getString("ACCOUNT_CODE");
            String name = rsDynamic.getString("NAME");
            Date dateOpen = rsDynamic.getDate("DATEACCOUNTOPEN");
            String dateOpenStr = (dateOpen != null) ? sdf.format(dateOpen) : "-";
            
            double balance = rsDynamic.getDouble("v_os_balance");
            String balanceStr = String.format("%.2f", balance);
            
            Date reviewDate = rsDynamic.getDate("ACCOUNTREVIEWDATE");
            String reviewDateStr = (reviewDate != null) ? sdf.format(reviewDate) : "-";
            
            // Add to JavaScript array for client-side operations
            out.println("<script>");
            out.println("allUnsecuredLoans.push({");
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
            out.println("<tr><td colspan='7' class='no-data'>No unsecured loans found for this branch.</td></tr>");
        }
        
    } catch (SQLException e) {
        // ========================================
        // STEP 7: SQL Error Handling
        // ========================================
        out.println("<tr><td colspan='7'>");
        out.println("<div class='error-box'>");
        out.println("<h3>⚠ Database Error</h3>");
        out.println("<p><strong>Error Message:</strong> " + e.getMessage() + "</p>");
        out.println("<p><strong>SQL State:</strong> " + e.getSQLState() + "</p>");
        
        if (dynamicQuery != null) {
            out.println("<p><strong>Query:</strong></p>");
            out.println("<pre style='background: #f5f5f5; padding: 10px; overflow-x: auto;'>");
            out.println(dynamicQuery);
            out.println("</pre>");
        }
        
        out.println("</div>");
        out.println("</td></tr>");
        e.printStackTrace();
        
    } catch (Exception e) {
        out.println("<tr><td colspan='7' class='no-data'>Error: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
        
    } finally {
        // ========================================
        // STEP 8: Resource Cleanup
        // ========================================
        try { if (rsDynamic != null) rsDynamic.close(); } catch (Exception ex) {}
        try { if (rsConfig != null) rsConfig.close(); } catch (Exception ex) {}
        try { if (psDynamic != null) psDynamic.close(); } catch (Exception ex) {}
        try { if (psConfig != null) psConfig.close(); } catch (Exception ex) {}
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
    var totalPages = Math.ceil(allUnsecuredLoans.length / recordsPerPage);
    document.getElementById("prevBtn").disabled = true;
    document.getElementById("nextBtn").disabled = (totalPages <= 1);
    document.getElementById("pageInfo").textContent = "Page 1 of " + totalPages;
    sessionStorage.setItem('unsecuredLoanPage', '1');
})();
</script>

</body>
</html>