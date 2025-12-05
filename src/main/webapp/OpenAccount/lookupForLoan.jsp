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

    String query = "SELECT INSTALLMENTTYPE_ID, DISCRIPTION FROM HEADOFFICE.INSTALLMENTTYPE ORDER BY INSTALLMENTTYPE_ID";

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
</style>

<div class="lookup-title">
    Select Installment Type
</div>

<table>
    <tr>
        <th>Installment Type ID</th>
        <th>Description</th>
    </tr>

<%
    while (rs.next()) {
        String id = rs.getString(1);
        String desc = rs.getString(2);
%>

    <tr onclick="sendBackInstallment('<%=id%>', '<%=desc%>')">
        <td><%=id%></td>
        <td><%=desc%></td>
    </tr>

<% } 
   rs.close();
   ps.close();
   con.close(); 
%>
</table>

<script>
function sendBackInstallment(id, desc) {
    // This is loaded inside the modal, so parent.window is the main page
    if (window.parent && window.parent.setInstallmentData) {
        window.parent.setInstallmentData(id, desc);
    } else if (window.setInstallmentData) {
        window.setInstallmentData(id, desc);
    } else {
        // Fallback: try to access directly
        parent.document.getElementById('installmentTypeId').value = id;
        parent.document.getElementById('installmentType').value = desc;
        parent.closeInstallmentLookup();
    }
}
</script>