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
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Customer Data - Branch <%= branchCode %></title>
<link rel="stylesheet" href="css/totalCustomers.css">
<script>
// ✅ Live search filter (client-side)
function searchTable() {
    var input = document.getElementById("searchInput");
    var filter = input.value.toLowerCase();
    var table = document.getElementById("customerTable");
    var trs = table.getElementsByTagName("tr");

    for (var i = 1; i < trs.length; i++) {
        var tds = trs[i].getElementsByTagName("td");
        var found = false;
        for (var j = 0; j < tds.length; j++) {
            if (tds[j].textContent.toLowerCase().indexOf(filter) > -1) {
                found = true;
                break;
            }
        }
        trs[i].style.display = found ? "" : "none";
    }
}

// Update breadcrumb on page load
window.onload = function() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Authorization Pending > Customer List');
    }
};

// View customer
function viewCustomer(customerId) {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Authorization Pending > Customer List > View Details');
    }
    window.location.href = 'authViewCustomers.jsp?cid=' + customerId;
}
</script>
</head>
<body>

<h2>Authorization Pending list for Branch: <%= branchCode %></h2>

<div class="search-container">
     <input type="text" id="searchInput" onkeyup="searchTable()" placeholder="🔍 Search by Name, Customer ID">
</div>

<div class="table-container">
<table id="customerTable">
<%
try (Connection conn = DBConnection.getConnection();
     PreparedStatement ps = conn.prepareStatement(
        "SELECT BRANCH_CODE, CUSTOMER_ID, CUSTOMER_NAME, STATUS FROM CUSTOMERS WHERE BRANCH_CODE = ? AND STATUS = 'P' ORDER BY CUSTOMER_ID")) {

    ps.setString(1, branchCode);

    ResultSet rs = ps.executeQuery();

    boolean hasData = false;

    // Table Header
    out.println("<tr>");
    out.println("<th>BRANCH CODE</th>");
    out.println("<th>CUSTOMER ID</th>");
    out.println("<th>CUSTOMER NAME</th>");
    out.println("<th>STATUS</th>");   // added
    out.println("<th>ACTION</th>");
    out.println("</tr>");

    while (rs.next()) {
        hasData = true;
        String cid = rs.getString("CUSTOMER_ID");

        out.println("<tr>");
        out.println("<td>" + rs.getString("BRANCH_CODE") + "</td>");
        out.println("<td>" + rs.getString("CUSTOMER_ID") + "</td>");
        out.println("<td>" + rs.getString("CUSTOMER_NAME") + "</td>");
        out.println("<td>" + rs.getString("STATUS") + "</td>");  // added

        out.println("<td><a href='#' onclick=\"viewCustomer('" + cid + "'); return false;\" ");
        out.println("style='background:#2b0d73;color:white;padding:4px 10px;");
        out.println("border-radius:4px;text-decoration:none;'>View Details</a></td>");
        out.println("</tr>");
    }

    if (!hasData) {
        out.println("<tr><td colspan='5' class='no-data'>No customers found.</td></tr>");
    }

} catch (Exception e) {
    out.println("<tr><td colspan='5' class='no-data'>Error: " + e.getMessage() + "</td></tr>");
}
%>

</table>
</div>

</body>
</html>