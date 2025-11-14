<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String cid = request.getParameter("cid");
    if (cid == null) {
        out.println("<h3 style='color:red;text-align:center;'>Invalid Customer ID</h3>");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
<title>Customer Details</title>
<style>
    body { background:#f2f2f2; font-family:Arial; }
    .box {
        width: 60%;
        margin: 40px auto;
        background:white;
        padding: 20px;
        border-radius: 10px;
        box-shadow: 0 0 10px #999;
    }
    h2 { text-align:center; color:#2b0d73; }
    table {
        width:100%;
        border-collapse: collapse;
        font-size: 14px;
    }
    td {
        padding: 8px;
        border: 1px solid #ccc;
    }
    .label {
        font-weight: bold;
        background:#eee;
        width:30%;
    }
    .back-btn {
        background:#2b0d73;
        color:white;
        padding:6px 15px;
        text-decoration:none;
        border-radius:5px;
        display:inline-block;
    }
    .back-btn:hover {
        background:#1a0849;
    }
</style>
<script>
    // Update breadcrumb on page load
    window.onload = function() {
        if (window.parent && window.parent.updateParentBreadcrumb) {
            window.parent.updateParentBreadcrumb('Dashboard > Total Customers > View Details');
        }
    };
    
    // Function to go back and update breadcrumb
    function goBackToList() {
        if (window.parent && window.parent.updateParentBreadcrumb) {
            window.parent.updateParentBreadcrumb('Dashboard > Total Customers');
        }
        window.location.href = 'customers.jsp';
    }
</script>
</head>
<body>

<div class="box">
<h2>Customer Details (ID: <%= cid %>)</h2>

<table>
<%
try (Connection conn = DBConnection.getConnection();
     PreparedStatement ps = conn.prepareStatement(
        "SELECT * FROM CUSTOMERS WHERE CUSTOMER_ID = ?")) {

    ps.setString(1, cid);
    ResultSet rs = ps.executeQuery();

    if (rs.next()) {

        ResultSetMetaData meta = rs.getMetaData();
        int columnCount = meta.getColumnCount();

        for (int i = 1; i <= columnCount; i++) {
            String colName = meta.getColumnName(i);
            String value = rs.getString(i);
%>
            <tr>
                <td class="label"><%= colName %></td>
                <td><%= value == null ? "" : value %></td>
            </tr>
<%
        }
    } else {
        out.println("<tr><td colspan='2' style='color:red;text-align:center;'>Customer not found.</td></tr>");
    }

} catch (Exception e) {
    out.println("<tr><td colspan='2' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
}
%>
</table>

<br>
<div style="text-align:center;">
    <a href="#" onclick="goBackToList(); return false;" class="back-btn">
        ← Back to List
    </a>
</div>

</div>

</body>
</html>