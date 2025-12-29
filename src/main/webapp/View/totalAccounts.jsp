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
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Total Accounts - Branch <%= branchCode %></title>
<link rel="stylesheet" href="../css/totalCustomers.css">
<script>
// Live search filter (client-side)
function searchTable() {
    var input = document.getElementById("searchInput");
    var filter = input.value.toLowerCase();
    var table = document.getElementById("accountTable");
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
        window.parent.updateParentBreadcrumb('View > Total Accounts');
    }
};

// View account details
function viewAccount(accountCode) {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('View > Total Accounts' > View Details');
    }
    window.location.href = 'viewAccount.jsp?accountCode=' + accountCode;
}
</script>
</head>
<body>

<h2>Total Accounts for Branch: <%= branchCode %></h2>

<div class="search-container">
     <input type="text" id="searchInput" onkeyup="searchTable()" placeholder="🔍 Search by Account Code, Name, Product Code">
</div>

<div class="table-container">
<table id="accountTable">
<%
try (Connection conn = DBConnection.getConnection()) {
    
    // Get working date from session
    Date workingDate = (Date) session.getAttribute("workingDate");
    
    if (workingDate == null) {
        out.println("<tr><td colspan='5' class='no-data'>Working date not available. Please refresh the page.</td></tr>");
        return;
    }
    
    // Query to get accounts opened on working date
    // Note: ACCOUNT table doesn't have BRANCH_CODE column
    // Branch code is the first 4 digits of ACCOUNT_CODE (e.g., 0002 from 00022110000007)
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

    // Table Header
    out.println("<tr>");
    out.println("<th>BRANCH CODE</th>");
    out.println("<th>PRODUCT CODE</th>");
    out.println("<th>ACCOUNT CODE</th>");
    out.println("<th>NAME</th>");
    out.println("<th>ACTION</th>");
    out.println("</tr>");

    while (rs.next()) {
        hasData = true;
        String accountCode = rs.getString("ACCOUNT_CODE");
        String name = rs.getString("NAME");
        
        // Extract product code (5th, 6th, 7th digits)
        String productCode = "";
        if (accountCode != null && accountCode.length() >= 7) {
            productCode = accountCode.substring(4, 7);
        }

        out.println("<tr>");
        out.println("<td>" + branchCode + "</td>");
        out.println("<td>" + productCode + "</td>");
        out.println("<td>" + accountCode + "</td>");
        out.println("<td>" + (name != null ? name : "") + "</td>");

        out.println("<td><a href='#' onclick=\"viewAccount('" + accountCode + "'); return false;\" ");
        out.println("style='background:#2b0d73;color:white;padding:4px 10px;");
        out.println("border-radius:4px;text-decoration:none;'>View Details</a></td>");
        out.println("</tr>");
    }

    if (!hasData) {
        out.println("<tr><td colspan='5' class='no-data'>No accounts found for today's working date.</td></tr>");
    }

} catch (Exception e) {
    out.println("<tr><td colspan='5' class='no-data'>Error: " + e.getMessage() + "</td></tr>");
    e.printStackTrace();
}
%>

</table>
</div>

</body>
</html>