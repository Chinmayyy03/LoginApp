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

    String type = request.getParameter("type");
    String query = "";

    if ("transaction".equals(type)) {
        query = "SELECT CODE_TYPE, DESCRIPTION FROM HEADOFFICE.TRANSACTIONS_TYPE ORDER BY CODE_TYPE";
    } 
    else if ("accountType".equals(type)) {
        query = "SELECT ACCOUNT_TYPE, NAME FROM HEADOFFICE.ACCOUNTTYPE ORDER BY ACCOUNT_TYPE";
    }

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
</style>

<div class="lookup-title">
    Select <%= ("transaction".equals(type) ? "Transaction Type" : "Account Type") %>
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

<% 
        }
    } catch (SQLException e) {
        out.println("<tr><td colspan='2' style='color: red; text-align: center;'>Error loading data: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (ps != null) try { ps.close(); } catch(SQLException e) {}
        if (con != null) try { con.close(); } catch(SQLException e) {}
    }
%>
</table>