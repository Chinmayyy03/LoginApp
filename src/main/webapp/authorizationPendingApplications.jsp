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
    
    int recordsPerPage = 15;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Authorization Pending Applications - Branch <%= branchCode %></title>
<link rel="stylesheet" href="css/totalCustomers.css">
<script src="<%= request.getContextPath() %>/js/breadcrumb-auto.js"></script>

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
// Store all application data for client-side search
let allApplications = [];
let currentPage = 1;
const recordsPerPage = <%= recordsPerPage %>;

// Live search filter across ALL data
function searchTable() {
    var input = document.getElementById("searchInput");
    var filter = input.value.toLowerCase().trim();
    var table = document.getElementById("applicationTable");
    var tbody = table.querySelector("tbody");
    
    // Clear current table body
    tbody.innerHTML = "";
    
    // Filter all applications
    let filteredApplications = allApplications;
    if (filter) {
        filteredApplications = allApplications.filter(function(app) {
            return app.branchCode.toLowerCase().indexOf(filter) > -1 ||
                   app.applicationNumber.toLowerCase().indexOf(filter) > -1 ||
                   app.name.toLowerCase().indexOf(filter) > -1 ||
                   app.status.toLowerCase().indexOf(filter) > -1;
        });
    }
    
    // Display filtered results (paginated)
    displayApplications(filteredApplications, 1);
}

// Display applications with pagination
function displayApplications(applications, page) {
    currentPage = page;
    var table = document.getElementById("applicationTable");
    var tbody = table.querySelector("tbody");
    tbody.innerHTML = "";
    
    if (applications.length === 0) {
        tbody.innerHTML = "<tr><td colspan='6' class='no-data'>No applications found.</td></tr>";
        updatePaginationControls(0, page);
        return;
    }
    
    // Calculate start and end indices
    var start = (page - 1) * recordsPerPage;
    var end = Math.min(start + recordsPerPage, applications.length);
    
    // Display applications for current page
    for (var i = start; i < end; i++) {
        var app = applications[i];
        var srNo = i + 1;
        var row = tbody.insertRow();
        row.innerHTML = 
            "<td>" + srNo + "</td>" +
            "<td>" + app.branchCode + "</td>" +
            "<td>" + app.applicationNumber + "</td>" +
            "<td>" + app.name + "</td>" +
            "<td>" + app.status + "</td>" +
            "<td><a href='#' onclick=\"viewApplication('" + app.applicationNumber + "'); return false;\" " +
            "style='background:#2b0d73;color:white;padding:4px 10px;" +
            "border-radius:4px;text-decoration:none;'>View Details</a></td>";
    }
    
    updatePaginationControls(applications.length, page);
}

// Update pagination controls
function updatePaginationControls(totalRecords, page) {
    var totalPages = Math.ceil(totalRecords / recordsPerPage);
    
    document.getElementById("prevBtn").disabled = (page <= 1);
    document.getElementById("nextBtn").disabled = (page >= totalPages);
    
    var pageInfo = "Page " + page + " of " + totalPages;
    document.getElementById("pageInfo").textContent = pageInfo;
    
    // Store current page in sessionStorage for back button
    sessionStorage.setItem('authPendingAppsPage', page);
}

// Navigate to previous page
function previousPage() {
    var filter = document.getElementById("searchInput").value.toLowerCase().trim();
    var applications = allApplications;
    
    if (filter) {
        applications = allApplications.filter(function(app) {
            return app.branchCode.toLowerCase().indexOf(filter) > -1 ||
                   app.applicationNumber.toLowerCase().indexOf(filter) > -1 ||
                   app.name.toLowerCase().indexOf(filter) > -1 ||
                   app.status.toLowerCase().indexOf(filter) > -1;
        });
    }
    
    if (currentPage > 1) {
        displayApplications(applications, currentPage - 1);
    }
}

// Navigate to next page
function nextPage() {
    var filter = document.getElementById("searchInput").value.toLowerCase().trim();
    var applications = allApplications;
    
    if (filter) {
        applications = allApplications.filter(function(app) {
            return app.branchCode.toLowerCase().indexOf(filter) > -1 ||
                   app.applicationNumber.toLowerCase().indexOf(filter) > -1 ||
                   app.name.toLowerCase().indexOf(filter) > -1 ||
                   app.status.toLowerCase().indexOf(filter) > -1;
        });
    }
    
    var totalPages = Math.ceil(applications.length / recordsPerPage);
    if (currentPage < totalPages) {
        displayApplications(applications, currentPage + 1);
    }
}

// Update breadcrumb on page load
window.onload = function() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('authorizationPendingApplications.jsp')
        );
    }
    
    // Check if returning from detail view and restore page
    var savedPage = sessionStorage.getItem('authPendingAppsPage');
    if (savedPage) {
        currentPage = parseInt(savedPage);
        displayApplications(allApplications, currentPage);
    }
};

// View application
function viewApplication(applicationNumber) {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('authViewApplication.jsp', 'authorizationPendingApplications.jsp')
        );
    }

    window.location.href = 'authViewApplication.jsp?appNo=' + applicationNumber;
}
</script>
</head>
<body>

<h2>Authorization Pending Applications for Branch: <%= branchCode %></h2>

<div class="search-container">
     <input type="text" id="searchInput" onkeyup="searchTable()" placeholder="🔍 Search by Name, Application Number, Branch, Status">
</div>

<div class="table-container">
<table id="applicationTable">
<thead>
    <tr>
        <th>SR NO</th>
        <th>BRANCH CODE</th>
        <th>APPLICATION NUMBER</th>
        <th>NAME</th>
        <th>STATUS</th>
        <th>ACTION</th>
    </tr>
</thead>
<tbody>
<%
try (Connection conn = DBConnection.getConnection()) {
    
    // ✅ Get working date from session
    Date workingDate = (Date) session.getAttribute("workingDate");
    
    if (workingDate == null) {
        out.println("<tr><td colspan='6' class='no-data'>Working date not available. Please refresh the page.</td></tr>");
        return;
    }
    
    PreparedStatement ps = conn.prepareStatement(
        "SELECT BRANCH_CODE, APPLICATION_NUMBER, NAME, STATUS " +
        "FROM APPLICATION.APPLICATION " +
        "WHERE BRANCH_CODE = ? AND STATUS = 'E' " +
        "AND TRUNC(APPLICATIONDATE) = TRUNC(?) " +
        "ORDER BY APPLICATION_NUMBER");

    ps.setString(1, branchCode);
    ps.setDate(2, workingDate);
    ResultSet rs = ps.executeQuery();

    boolean hasData = false;
    int displayCount = 0;
    int srNo = 1;

    // Data Rows - display first 15 records initially
    while (rs.next()) {
        hasData = true;
        String appNo = rs.getString("APPLICATION_NUMBER");
        String bc = rs.getString("BRANCH_CODE");
        String name = rs.getString("NAME");
        String status = rs.getString("STATUS");
        
        // Add to JavaScript array for client-side operations
        out.println("<script>");
        out.println("allApplications.push({");
        out.println("  branchCode: '" + bc + "',");
        out.println("  applicationNumber: '" + appNo + "',");
        out.println("  name: '" + name.replace("'", "\\'") + "',");
        out.println("  status: '" + status + "'");
        out.println("});");
        out.println("</script>");
        
        // Display only first 15 records on initial load
        if (displayCount < recordsPerPage) {
            out.println("<tr>");
            out.println("<td>" + srNo + "</td>");
            out.println("<td>" + bc + "</td>");
            out.println("<td>" + appNo + "</td>");
            out.println("<td>" + name + "</td>");
            out.println("<td>" + status + "</td>");
            
            // View button with onclick
            out.println("<td><a href='#' onclick=\"viewApplication('" + appNo + "'); return false;\" ");
            out.println("style='background:#2b0d73;color:white;padding:4px 10px;");
            out.println("border-radius:4px;text-decoration:none;'>View Details</a></td>");
            
            out.println("</tr>");
            displayCount++;
            srNo++;
        }
    }

    if (!hasData) {
        out.println("<tr><td colspan='6' class='no-data'>No applications found.</td></tr>");
    }

} catch (Exception e) {
    out.println("<tr><td colspan='6' class='no-data'>Error: " + e.getMessage() + "</td></tr>");
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
    var totalPages = Math.ceil(allApplications.length / recordsPerPage);
    document.getElementById("prevBtn").disabled = true;
    document.getElementById("nextBtn").disabled = (totalPages <= 1);
    document.getElementById("pageInfo").textContent = "Page 1 of " + totalPages;
    
    // Store initial page
    sessionStorage.setItem('authPendingAppsPage', '1');
})();
</script>

</body>
</html>