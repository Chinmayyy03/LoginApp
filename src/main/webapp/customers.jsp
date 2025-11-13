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
<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #fafafa;
        margin: 0;
    }
    h2 {
        text-align: center;
        color: #2b0d73;
        margin-top: 20px;
    }
    .search-container {
        text-align: center;
        margin: 10px 0;
    }
    .search-container input {
        width: 40%;
        padding: 8px;
        font-size: 14px;
        border: 1px solid #ccc;
        border-radius: 4px;
    }
    .table-container {
        overflow-x: auto;
        margin: 20px;
        border: 1px solid #ccc;
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 0 8px rgba(0,0,0,0.1);
    }
    table {
        border-collapse: collapse;
        width: 100%;
        font-size: 12px;
        white-space: nowrap;
    }
    th, td {
        border: 1px solid #ccc;
        padding: 6px 8px;
        text-align: left;
    }
    th {
        background-color: #2b0d73;
        color: white;
        text-align: center;
        position: sticky;
        top: 0;
        z-index: 2;
    }
    tr:nth-child(even) {
        background-color: #f9f9f9;
    }
    .no-data {
        text-align: center;
        color: red;
        font-weight: bold;
        padding: 10px;
    }
</style>
<script>
    // ✅ Live search filter (client-side)
    function searchTable() {
        var input = document.getElementById("searchInput");
        var filter = input.value.toLowerCase();
        var table = document.getElementById("customerTable");
        var trs = table.getElementsByTagName("tr");

        // Skip header row
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
</script>
</head>
<body>

<h2>Customer Data for Branch: <%= branchCode %></h2>

<div class="search-container">
    🔍 <input type="text" id="searchInput" onkeyup="searchTable()" placeholder="Search by any detail... (e.g. Name, Customer ID, Aadhaar)">
</div>

<div class="table-container">
<table id="customerTable">
<%
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
             "SELECT * FROM CUSTOMERS WHERE BRANCH_CODE = ? ORDER BY CUSTOMER_ID")) {

        ps.setString(1, branchCode);
        ResultSet rs = ps.executeQuery();
        ResultSetMetaData meta = rs.getMetaData();
        int colCount = meta.getColumnCount();

        // ✅ Table Header
        out.println("<tr>");
        for (int i = 1; i <= colCount; i++) {
            out.println("<th>" + meta.getColumnName(i) + "</th>");
        }
        out.println("</tr>");

        boolean hasData = false;

        // ✅ Data Rows
        while (rs.next()) {
            hasData = true;
            out.println("<tr>");
            for (int i = 1; i <= colCount; i++) {
                Object val = rs.getObject(i);
                out.println("<td>" + (val == null ? "" : val.toString()) + "</td>");
            }
            out.println("</tr>");
        }

        if (!hasData) {
            out.println("<tr><td colspan='" + colCount + "' class='no-data'>No customers found for this branch.</td></tr>");
        }

    } catch (Exception e) {
        out.println("<tr><td colspan='95' class='no-data'>Error: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
    }
%>
</table>
</div>

</body>
</html>
