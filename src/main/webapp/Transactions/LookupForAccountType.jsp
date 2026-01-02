<%@ page import="java.sql.*, db.DBConnection" %> 
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Get branch code from session
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String branchCode = (String) sess.getAttribute("branchCode");

    // Query to fetch Account Type and Name from ACCOUNTTYPE table
    String query = "SELECT ACCOUNT_TYPE, NAME FROM HEADOFFICE.ACCOUNTTYPE ORDER BY ACCOUNT_TYPE";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        con = DBConnection.getConnection();
        ps = con.prepareStatement(query);
        rs = ps.executeQuery();
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
    Select Account Type
</div>

<table>
    <thead>
        <tr>
            <th>Account Type</th>
            <th>Name</th>
        </tr>
    </thead>
    <tbody>
<%
        while (rs.next()) {
            String accountType = rs.getString("ACCOUNT_TYPE");
            String name = rs.getString("NAME");
%>
        <tr onclick="sendBackAccountType('<%=accountType%>', '<%=name%>')">
            <td><%=accountType%></td>
            <td><%=name%></td>
        </tr>
<% 
        } 
    } catch (SQLException e) {
        out.println("<tr><td colspan='2' style='color: red; text-align: center;'>Error loading account types: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (ps != null) try { ps.close(); } catch(SQLException e) {}
        if (con != null) try { con.close(); } catch(SQLException e) {}
    }
%>
    </tbody>
</table>