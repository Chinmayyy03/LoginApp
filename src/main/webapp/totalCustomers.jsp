<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    // ✅ Get branch code from session
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String branchCode = (String) sess.getAttribute("branchCode");
    
    // Get current page from parameter (default to 1)
    int currentPage = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.trim().isEmpty()) {
        try {
            currentPage = Integer.parseInt(pageParam);
            if (currentPage < 1) currentPage = 1;
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }
    
    int recordsPerPage = 15;
    int offset = (currentPage - 1) * recordsPerPage;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Customer Data - Branch <%= branchCode %></title>
<link rel="stylesheet" href="css/totalCustomers.css">
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
// Store all customer data for client-side search
let allCustomers = [];
let currentPage = <%= currentPage %>;
const recordsPerPage = <%= recordsPerPage %>;

// Live search filter across ALL data
function searchTable() {
    var input = document.getElementById("searchInput");
    var filter = input.value.toLowerCase().trim();
    var table = document.getElementById("customerTable");
    var tbody = table.querySelector("tbody");
    
    // Clear current table body
    tbody.innerHTML = "";
    
    // Filter all customers
    let filteredCustomers = allCustomers;
    if (filter) {
        filteredCustomers = allCustomers.filter(function(customer) {
            return customer.branchCode.toLowerCase().indexOf(filter) > -1 ||
                   customer.customerId.toLowerCase().indexOf(filter) > -1 ||
                   customer.customerName.toLowerCase().indexOf(filter) > -1 ||
                   customer.mobileNo.toLowerCase().indexOf(filter) > -1;
        });
    }
    
    // Display filtered results (paginated)
    displayCustomers(filteredCustomers, 1);
}

// Display customers with pagination
function displayCustomers(customers, page) {
    currentPage = page;
    var table = document.getElementById("customerTable");
    var tbody = table.querySelector("tbody");
    tbody.innerHTML = "";
    
    if (customers.length === 0) {
        tbody.innerHTML = "<tr><td colspan='6' class='no-data'>No customers found.</td></tr>";
        updatePaginationControls(0, page);
        return;
    }
    
    // Calculate start and end indices
    var start = (page - 1) * recordsPerPage;
    var end = Math.min(start + recordsPerPage, customers.length);
    
    // Display customers for current page
    for (var i = start; i < end; i++) {
        var customer = customers[i];
        var srNo = i + 1; // Serial number based on overall position
        var row = tbody.insertRow();
        row.innerHTML = 
            "<td>" + srNo + "</td>" +
            "<td>" + customer.branchCode + "</td>" +
            "<td>" + customer.customerId + "</td>" +
            "<td>" + customer.customerName + "</td>" +
            "<td>" + customer.mobileNo + "</td>" +
            "<td><a href='#' onclick=\"viewCustomer('" + customer.customerId + "'); return false;\" " +
            "style='background:#2b0d73;color:white;padding:4px 10px;" +
            "border-radius:4px;text-decoration:none;'>View Details</a></td>";
    }
    
    updatePaginationControls(customers.length, page);
}

// Update pagination controls
function updatePaginationControls(totalRecords, page) {
    var totalPages = Math.ceil(totalRecords / recordsPerPage);
    
    document.getElementById("prevBtn").disabled = (page <= 1);
    document.getElementById("nextBtn").disabled = (page >= totalPages);
    
    var pageInfo = "Page " + page + " of " + totalPages;
    document.getElementById("pageInfo").textContent = pageInfo;
    
    // Store current page in sessionStorage for back button
    sessionStorage.setItem('customerListPage', page);
}

// Navigate to previous page
function previousPage() {
    var filter = document.getElementById("searchInput").value.toLowerCase().trim();
    var customers = allCustomers;
    
    if (filter) {
        customers = allCustomers.filter(function(customer) {
            return customer.branchCode.toLowerCase().indexOf(filter) > -1 ||
                   customer.customerId.toLowerCase().indexOf(filter) > -1 ||
                   customer.customerName.toLowerCase().indexOf(filter) > -1 ||
                   customer.mobileNo.toLowerCase().indexOf(filter) > -1;
        });
    }
    
    if (currentPage > 1) {
        displayCustomers(customers, currentPage - 1);
    }
}

// Navigate to next page
function nextPage() {
    var filter = document.getElementById("searchInput").value.toLowerCase().trim();
    var customers = allCustomers;
    
    if (filter) {
        customers = allCustomers.filter(function(customer) {
            return customer.branchCode.toLowerCase().indexOf(filter) > -1 ||
                   customer.customerId.toLowerCase().indexOf(filter) > -1 ||
                   customer.customerName.toLowerCase().indexOf(filter) > -1 ||
                   customer.mobileNo.toLowerCase().indexOf(filter) > -1;
        });
    }
    
    var totalPages = Math.ceil(customers.length / recordsPerPage);
    if (currentPage < totalPages) {
        displayCustomers(customers, currentPage + 1);
    }
}

// Update breadcrumb on page load
window.onload = function() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Dashboard > Total Customer');
    }
    
    // Check if returning from detail view and restore page
    var savedPage = sessionStorage.getItem('customerListPage');
    if (savedPage) {
        currentPage = parseInt(savedPage);
        displayCustomers(allCustomers, currentPage);
    }
};

// View customer and update breadcrumb
function viewCustomer(customerId) {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Dashboard > Total Customer > View Details');
    }
    window.location.href = 'viewCustomer.jsp?cid=' + customerId + '&returnPage=totalCustomers.jsp';
}
</script>
</head>
<body>

<h2>Customer Data for Branch: <%= branchCode %></h2>

<div class="search-container">
     <input type="text" id="searchInput" onkeyup="searchTable()" placeholder="🔍 Search by Name, Customer ID, Branch, Mobile">
</div>

<div class="table-container">
<table id="customerTable">
<thead>
    <tr>
        <th>SR NO</th>
        <th>BRANCH CODE</th>
        <th>CUSTOMER ID</th>
        <th>CUSTOMER NAME</th>
        <th>MOBILE NO</th>
        <th>ACTION</th>
    </tr>
</thead>
<tbody>
<%
try (Connection conn = DBConnection.getConnection();
     PreparedStatement ps = conn.prepareStatement(
        "SELECT BRANCH_CODE, CUSTOMER_ID, CUSTOMER_NAME, MOBILE_NO FROM CUSTOMERS WHERE BRANCH_CODE = ? AND STATUS='A' AND IS_ACTIVE='Y' ORDER BY CUSTOMER_ID")) {

    ps.setString(1, branchCode);
    ResultSet rs = ps.executeQuery();

    boolean hasData = false;
    int displayCount = 0;
    int srNo = 1;

    // Data Rows - display first 15 records initially
    while (rs.next()) {
        hasData = true;
        String cid = rs.getString("CUSTOMER_ID");
        String bc = rs.getString("BRANCH_CODE");
        String name = rs.getString("CUSTOMER_NAME");
        String mobile = rs.getString("MOBILE_NO");
        
        // Add to JavaScript array for client-side operations
        out.println("<script>");
        out.println("allCustomers.push({");
        out.println("  branchCode: '" + bc + "',");
        out.println("  customerId: '" + cid + "',");
        out.println("  customerName: '" + name.replace("'", "\\'") + "',");
        out.println("  mobileNo: '" + mobile + "'");
        out.println("});");
        out.println("</script>");
        
        // Display only first 15 records on initial load
        if (displayCount < recordsPerPage) {
            out.println("<tr>");
            out.println("<td>" + srNo + "</td>");
            out.println("<td>" + bc + "</td>");
            out.println("<td>" + cid + "</td>");
            out.println("<td>" + name + "</td>");
            out.println("<td>" + mobile + "</td>");
            
            // View button with onclick
            out.println("<td><a href='#' onclick=\"viewCustomer('" + cid + "'); return false;\" ");
            out.println("style='background:#2b0d73;color:white;padding:4px 10px;");
            out.println("border-radius:4px;text-decoration:none;'>View Details</a></td>");
            
            out.println("</tr>");
            displayCount++;
            srNo++;
        }
    }

    if (!hasData) {
        out.println("<tr><td colspan='6' class='no-data'>No customers found for this branch.</td></tr>");
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
    var totalPages = Math.ceil(allCustomers.length / recordsPerPage);
    document.getElementById("prevBtn").disabled = true;
    document.getElementById("nextBtn").disabled = (totalPages <= 1);
    document.getElementById("pageInfo").textContent = "Page 1 of " + totalPages;
    
    // Store initial page
    sessionStorage.setItem('customerListPage', '1');
})();
</script>

</body>
</html>