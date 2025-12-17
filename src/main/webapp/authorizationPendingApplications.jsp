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
<title>Application Data - Branch <%= branchCode %></title>
<link rel="stylesheet" href="css/totalCustomers.css">
<script>
//✅ Live search filter (client-side)
function searchTable() {
    var input = document.getElementById("searchInput");
    var filter = input.value.toLowerCase();
    var table = document.getElementById("applicationTable");
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
        window.parent.updateParentBreadcrumb('Authorization Pending > Application List');
    }
};

// View application
function viewApplication(applicationNumber) {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Authorization Pending > Application List > View Details');
    }
    window.location.href = 'authViewApplication.jsp?appNo=' + applicationNumber;
}
</script>
</head>
<body>

<h2>Authorization Pending Applications for Branch: <%= branchCode %></h2>

<div class="search-container">
     <input type="text" id="searchInput" onkeyup="searchTable()" placeholder="🔍 Search by Name, Application Number">
</div>

<div class="table-container">
<table id="applicationTable">
<%
try (Connection conn = DBConnection.getConnection();
     PreparedStatement ps = conn.prepareStatement(
        "SELECT BRANCH_CODE, APPLICATION_NUMBER, NAME, STATUS " +
        "FROM APPLICATION.APPLICATION " +
        "WHERE BRANCH_CODE = ? AND STATUS = 'E' " +
        "ORDER BY APPLICATION_NUMBER")) {

    ps.setString(1, branchCode);

    ResultSet rs = ps.executeQuery();

    boolean hasData = false;

    // Table Header
    out.println("<tr>");
    out.println("<th>BRANCH CODE</th>");
    out.println("<th>APPLICATION NUMBER</th>");
    out.println("<th>NAME</th>");
    out.println("<th>STATUS</th>");
    out.println("<th>ACTION</th>");
    out.println("</tr>");

    while (rs.next()) {
        hasData = true;
        String appNo = rs.getString("APPLICATION_NUMBER");

        out.println("<tr>");
        out.println("<td>" + rs.getString("BRANCH_CODE") + "</td>");
        out.println("<td>" + rs.getString("APPLICATION_NUMBER") + "</td>");
        out.println("<td>" + rs.getString("NAME") + "</td>");
        out.println("<td>" + rs.getString("STATUS") + "</td>");

        out.println("<td><a href='#' onclick=\"viewApplication('" + appNo + "'); return false;\" ");
        out.println("style='background:#2b0d73;color:white;padding:4px 10px;");
        out.println("border-radius:4px;text-decoration:none;'>View Details</a></td>");
        out.println("</tr>");
    }

    if (!hasData) {
        out.println("<tr><td colspan='5' class='no-data'>No applications found.</td></tr>");
    }

} catch (Exception e) {
    out.println("<tr><td colspan='5' class='no-data'>Error: " + e.getMessage() + "</td></tr>");
}
%>

</table>
</div>

</body>
</html>