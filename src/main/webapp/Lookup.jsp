<%@ page import="java.sql.*, db.DBConnection" %> 
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String type = request.getParameter("type");
    String accType = request.getParameter("accType");

    String query = "";

    if ("account".equals(type)) {
        query = "SELECT ACCOUNT_TYPE, NAME FROM HEADOFFICE.ACCOUNTTYPE ORDER BY ACCOUNT_TYPE";
    } 
    else if ("product".equals(type)) {
        query = "SELECT PRODUCT_CODE, DESCRIPTION FROM HEADOFFICE.PRODUCT WHERE ACCOUNT_TYPE = ?";
    }

    Connection con = DBConnection.getConnection();
    PreparedStatement ps = con.prepareStatement(query);

    if ("product".equals(type)) {
        ps.setString(1, accType);
    }

    ResultSet rs = ps.executeQuery();
%>

<style>
table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 10px;
}
th, td {
    border: 1px solid #999;
    padding: 10px;
    cursor: pointer;
}
th {
    background-color: #373279;
    color: white;
    font-weight: bold;
}
tr:hover { 
    background-color: #e8e4fc;
}
.lookup-title {
    font-size: 20px;
    margin-bottom: 10px;
    font-weight: bold;
    color: #373279;
}
</style>

<div class="lookup-title">
    Select <%= ("account".equals(type) ? "Account Type" : "Product Code") %>
</div>

<table>
    <tr>
        <th>Code</th>
        <th>Description</th>
    </tr>

<%
    while (rs.next()) {
        String code = rs.getString(1);
        String desc = rs.getString(2);
%>

    <tr onclick="sendBack('<%=code%>', '<%=desc%>', '<%=type%>')">
        <td><%=code%></td>
        <td><%=desc%></td>
    </tr>

<% } 
   rs.close();
   ps.close();
   con.close(); 
%>
</table>

<script>
function sendBack(code, desc, type) {
    // Call the parent window's function to set values
    if (window.parent && window.parent.setValueFromLookup) {
        window.parent.setValueFromLookup(code, desc, type);
    } else {
        console.error("Parent function setValueFromLookup not found!");
    }
}
</script>