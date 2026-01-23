<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%!
    // Helper method to safely escape strings for JavaScript
    private String escapeJavaScript(String str) {
        if (str == null || str.isEmpty()) {
            return "";
        }
        
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < str.length(); i++) {
            char c = str.charAt(i);
            switch (c) {
                case '\'':
                    sb.append("\\'");
                    break;
                case '\"':
                    sb.append("\\\"");
                    break;
                case '\\':
                    sb.append("\\\\");
                    break;
                case '\n':
                    sb.append("\\n");
                    break;
                case '\r':
                    sb.append("\\r");
                    break;
                case '\t':
                    sb.append("\\t");
                    break;
                case '\b':
                    sb.append("\\b");
                    break;
                case '\f':
                    sb.append("\\f");
                    break;
                default:
                    if (c < 32 || c > 126) {
                        sb.append(String.format("\\u%04x", (int) c));
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.toString();
    }
%>

<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String sessionBranchCode = (String) sess.getAttribute("branchCode");
    String filterBranchCode = request.getParameter("branchCode");
    String filterStatus = request.getParameter("status");
    
    // Use filter if provided, otherwise use session branch
    String branchCode = (filterBranchCode != null && !filterBranchCode.trim().isEmpty()) 
                        ? filterBranchCode.trim() 
                        : sessionBranchCode;
    
    // Default status to "All" if not specified
    if (filterStatus == null || filterStatus.trim().isEmpty()) {
        filterStatus = "All";
    }
    
    int recordsPerPage = 15;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>All Customers - Branch <%= branchCode %></title>
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

.icon-btn {
    background-color: #2D2B80;
    color: white;
    border: none;
    width: 35px;
    height: 35px;
    border-radius: 8px;
    font-size: 18px;
    cursor: pointer;
    flex-shrink: 0;
}

.icon-btn:hover {
    background-color: #1a0548;
}

.status-group {
    flex: 1;
}

.radio-container {
    display: flex;
    gap: 20px;
    align-items: center;
    margin-top: 16px;
}

.radio-option {
    display: flex;
    align-items: center;
    gap: 8px;
}

.radio-option input[type="radio"] {
    width: 18px;
    height: 18px;
    cursor: pointer;
    accent-color: #2D2B80;
}

.radio-option label {
    font-size: 14px;
    color: #3D316F;
    cursor: pointer;
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

/* Responsive Design */
@media (max-width: 1000px) {
    .filter-row {
        gap: 15px;
    }
    
    .radio-container {
        flex-wrap: wrap;
    }
}

@media (max-width: 768px) {
    .input-box {
        width: 100%;
    }
    
    .radio-container {
        flex-direction: column;
        align-items: flex-start;
    }
}
</style>

<script>
let allCustomers = [];
let currentPage = 1;
const recordsPerPage = <%= recordsPerPage %>;

function searchTable() {
    var input = document.getElementById("searchInput");
    var filter = input.value.toLowerCase().trim();
    var table = document.getElementById("customerTable");
    var tbody = table.querySelector("tbody");
    
    tbody.innerHTML = "";
    
    let filteredCustomers = allCustomers;
    if (filter) {
        filteredCustomers = allCustomers.filter(function(customer) {
            return customer.customerId.toLowerCase().indexOf(filter) > -1 ||
                   customer.name.toLowerCase().indexOf(filter) > -1 ||
                   customer.address.toLowerCase().indexOf(filter) > -1 ||
                   customer.memberNumber.toLowerCase().indexOf(filter) > -1 ||
                   customer.panNo.toLowerCase().indexOf(filter) > -1 ||
                   customer.aadharNo.toLowerCase().indexOf(filter) > -1;
        });
    }
    
    displayCustomers(filteredCustomers, 1);
}

function displayCustomers(customers, page) {
    currentPage = page;
    var table = document.getElementById("customerTable");
    var tbody = table.querySelector("tbody");
    tbody.innerHTML = "";
    
    if (customers.length === 0) {
        tbody.innerHTML = "<tr><td colspan='8' class='no-data'>No customers found.</td></tr>";
        updatePaginationControls(0, page);
        return;
    }
    
    var start = (page - 1) * recordsPerPage;
    var end = Math.min(start + recordsPerPage, customers.length);
    
    for (var i = start; i < end; i++) {
        var customer = customers[i];
        var srNo = i + 1;
        var row = tbody.insertRow();
        
        var cell1 = row.insertCell(0);
        cell1.textContent = srNo;
        
        var cell2 = row.insertCell(1);
        cell2.textContent = customer.customerId;
        
        var cell3 = row.insertCell(2);
        cell3.textContent = customer.name;
        
        var cell4 = row.insertCell(3);
        cell4.textContent = customer.address;
        
        var cell5 = row.insertCell(4);
        cell5.textContent = customer.memberNumber;
        
        var cell6 = row.insertCell(5);
        cell6.textContent = customer.panNo;
        
        var cell7 = row.insertCell(6);
        cell7.textContent = customer.aadharNo;
        
        var cell8 = row.insertCell(7);
        var btn = document.createElement('button');
        btn.className = 'action-btn';
        btn.textContent = 'View Customer';
        btn.onclick = (function(id) {
            return function() {
                viewCustomer(id);
                return false;
            };
        })(customer.customerId);
        cell8.appendChild(btn);
    }
    
    updatePaginationControls(customers.length, page);
}

function updatePaginationControls(totalRecords, page) {
    var totalPages = Math.ceil(totalRecords / recordsPerPage);
    
    document.getElementById("prevBtn").disabled = (page <= 1);
    document.getElementById("nextBtn").disabled = (page >= totalPages);
    
    var pageInfo = "Page " + page + " of " + totalPages;
    document.getElementById("pageInfo").textContent = pageInfo;
    
    sessionStorage.setItem('allCustomersPage', page);
}

function previousPage() {
    var filter = document.getElementById("searchInput").value.toLowerCase().trim();
    var customers = allCustomers;
    
    if (filter) {
        customers = allCustomers.filter(function(customer) {
            return customer.customerId.toLowerCase().indexOf(filter) > -1 ||
                   customer.name.toLowerCase().indexOf(filter) > -1 ||
                   customer.address.toLowerCase().indexOf(filter) > -1 ||
                   customer.memberNumber.toLowerCase().indexOf(filter) > -1 ||
                   customer.panNo.toLowerCase().indexOf(filter) > -1 ||
                   customer.aadharNo.toLowerCase().indexOf(filter) > -1;
        });
    }
    
    if (currentPage > 1) {
        displayCustomers(customers, currentPage - 1);
    }
}

function nextPage() {
    var filter = document.getElementById("searchInput").value.toLowerCase().trim();
    var customers = allCustomers;
    
    if (filter) {
        customers = allCustomers.filter(function(customer) {
            return customer.customerId.toLowerCase().indexOf(filter) > -1 ||
                   customer.name.toLowerCase().indexOf(filter) > -1 ||
                   customer.address.toLowerCase().indexOf(filter) > -1 ||
                   customer.memberNumber.toLowerCase().indexOf(filter) > -1 ||
                   customer.panNo.toLowerCase().indexOf(filter) > -1 ||
                   customer.aadharNo.toLowerCase().indexOf(filter) > -1;
        });
    }
    
    var totalPages = Math.ceil(customers.length / recordsPerPage);
    if (currentPage < totalPages) {
        displayCustomers(customers, currentPage + 1);
    }
}

window.onload = function() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('View/allCustomers.jsp')
        );
    }
    
    var savedPage = sessionStorage.getItem('allCustomersPage');
    if (savedPage) {
        currentPage = parseInt(savedPage);
        displayCustomers(allCustomers, currentPage);
    }
    
    // Set initial branch description
    updateBranchDescription();
};

function viewCustomer(customerId) {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('View/viewCustomer.jsp', 'View/allCustomers.jsp')
        );
    }
    window.location.href = '<%= request.getContextPath() %>/View/viewCustomer.jsp?customerId=' + customerId + '&returnPage=View/allCustomers.jsp';
    return false;
}

function filterByBranch() {
    var branchSelect = document.getElementById("branchInput");
    var branchCode = branchSelect.value.trim();
    var statusRadios = document.getElementsByName("status");
    var selectedStatus = "All";
    
    for (var i = 0; i < statusRadios.length; i++) {
        if (statusRadios[i].checked) {
            selectedStatus = statusRadios[i].value;
            break;
        }
    }
    
    if (branchCode.length === 0) {
        alert("Please select a branch");
        return;
    }
    
    window.location.href = 'allCustomers.jsp?branchCode=' + encodeURIComponent(branchCode) + 
                          '&status=' + encodeURIComponent(selectedStatus);
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

<h2>All Customers for Branch: <%= branchCode %></h2>

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
        
        <!-- Status Radio Buttons -->
        <div class="status-group">
            <label class="label">Status</label>
            <div class="radio-container">
                <div class="radio-option">
                    <input type="radio" id="statusAll" name="status" value="All" <%= "All".equals(filterStatus) ? "checked" : "" %>>
                    <label for="statusAll">All</label>
                </div>
                <div class="radio-option">
                    <input type="radio" id="statusLive" name="status" value="Live" <%= "Live".equals(filterStatus) ? "checked" : "" %>>
                    <label for="statusLive">Live</label>
                </div>
                <div class="radio-option">
                    <input type="radio" id="statusClosed" name="status" value="Closed" <%= "Closed".equals(filterStatus) ? "checked" : "" %>>
                    <label for="statusClosed">Closed</label>
                </div>
            </div>
        </div>
        
        <!-- Filter Button -->
        <div class="filter-btn-container">
            <button type="button" class="filter-btn" onclick="filterByBranch()">Filter</button>
        </div>
    </div>
</div>

<div class="search-container">
     <input type="text" id="searchInput" onkeyup="searchTable()" placeholder="🔍 Search by Customer ID, Name, Address, Member Number, PAN, Aadhar">
</div>

<div class="table-container">
<table id="customerTable">
<thead>
    <tr>
        <th>SR NO</th>
        <th>CUSTOMER ID</th>
        <th>NAME</th>
        <th>ADDRESS</th>
        <th>MEMBER NUMBER</th>
        <th>PAN NO</th>
        <th>AADHAR CARD NO</th>
        <th>ACTION</th>
    </tr>
</thead>
<tbody>
<%
try {
    conn = DBConnection.getConnection();
    
    ps = conn.prepareStatement(
        "SELECT CUSTOMER_ID, NAME, ADDRESS1, MEMBER_NUMBER, PANNO, AADHAR_CARD_NO " +
        "FROM CUSTOMER.CUSTOMER " +
        "WHERE SUBSTR(CUSTOMER_ID, 1, 4) = ? " +
        "ORDER BY CUSTOMER_ID");

    ps.setString(1, branchCode);
    rs = ps.executeQuery();

    boolean hasData = false;
    int displayCount = 0;
    int srNo = 1;

    while (rs.next()) {
        hasData = true;
        String customerId = rs.getString("CUSTOMER_ID");
        String name = rs.getString("NAME");
        String address = rs.getString("ADDRESS1");
        String memberNumber = rs.getString("MEMBER_NUMBER");
        String panNo = rs.getString("PANNO");
        String aadharNo = rs.getString("AADHAR_CARD_NO");
        
        out.println("<script>");
        out.println("allCustomers.push({");
        out.println("  customerId: '" + escapeJavaScript(customerId) + "',");
        out.println("  name: '" + escapeJavaScript(name) + "',");
        out.println("  address: '" + escapeJavaScript(address) + "',");
        out.println("  memberNumber: '" + escapeJavaScript(memberNumber) + "',");
        out.println("  panNo: '" + escapeJavaScript(panNo) + "',");
        out.println("  aadharNo: '" + escapeJavaScript(aadharNo) + "'");
        out.println("});");
        out.println("</script>");
        
        if (displayCount < recordsPerPage) {
            out.println("<tr>");
            out.println("<td>" + srNo + "</td>");
            out.println("<td>" + (customerId != null ? customerId : "") + "</td>");
            out.println("<td>" + (name != null ? name : "") + "</td>");
            out.println("<td>" + (address != null ? address : "") + "</td>");
            out.println("<td>" + (memberNumber != null ? memberNumber : "") + "</td>");
            out.println("<td>" + (panNo != null ? panNo : "") + "</td>");
            out.println("<td>" + (aadharNo != null ? aadharNo : "") + "</td>");
            out.println("<td><button class='action-btn' onclick=\"viewCustomer('" + escapeJavaScript(customerId) + "'); return false;\">View Customer</button></td>");
            out.println("</tr>");
            displayCount++;
            srNo++;
        }
    }

    if (!hasData) {
        out.println("<tr><td colspan='8' class='no-data'>No customers found for branch code: " + branchCode + "</td></tr>");
    }

} catch (Exception e) {
    out.println("<tr><td colspan='8' class='no-data'>Error: " + e.getMessage() + "</td></tr>");
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

<div class="pagination-container">
    <button id="prevBtn" class="pagination-btn" onclick="previousPage()">← Previous</button>
    <span id="pageInfo" class="page-info">Page 1</span>
    <button id="nextBtn" class="pagination-btn" onclick="nextPage()">Next →</button>
</div>

<script>
(function() {
    var totalPages = Math.ceil(allCustomers.length / recordsPerPage);
    document.getElementById("prevBtn").disabled = true;
    document.getElementById("nextBtn").disabled = (totalPages <= 1);
    document.getElementById("pageInfo").textContent = "Page 1 of " + totalPages;
    
    sessionStorage.setItem('allCustomersPage', '1');
})();
</script>

</body>
</html>