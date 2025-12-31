<%@ page import="java.sql.*, db.DBConnection" %> 
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ✅ Get branch code from session
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String branchCode = (String) sess.getAttribute("branchCode");

    String query = "SELECT CODE_TYPE, DESCRIPTION FROM HEADOFFICE.TRANSACTIONS_TYPE ORDER BY CODE_TYPE";

    Connection con = DBConnection.getConnection();
    PreparedStatement ps = con.prepareStatement(query);
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
tbody tr {
    transition: background-color 0.2s;
}
tbody tr:nth-child(even) {
    background-color: #f9f9f9;
}
</style>

<div class="lookup-title">
    Select Transaction Type
</div>

<table>
    <thead>
        <tr>
            <th>Code Type</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
<%
    while (rs.next()) {
        String codeType = rs.getString(1);
        String description = rs.getString(2);
%>
        <tr onclick="sendBack('<%=codeType%>', '<%=description%>')">
            <td><%=codeType%></td>
            <td><%=description%></td>
        </tr>
<% 
    } 
    rs.close();
    ps.close();
    con.close(); 
%>
    </tbody>
</table>