<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<%
String msg = request.getParameter("msg");
if ("success".equals(msg)) {
%>
<div id="msgBox" style="background:#e7f7e7;padding:8px;border:1px solid green;color:green">
    ✔ Action completed successfully
</div>
<%
} else if ("error".equals(msg)) {
%>
<div id="msgBox" style="background:#fdecea;padding:8px;border:1px solid red;color:red">
    ✖ Error while processing request
</div>
<%
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Authorization Pending Masters</title>

<style>
body { font-family: Arial; background:#f5f7fa; padding:20px; }

.table-wrapper {
    width: 100%;
    overflow-x: auto;
    background: #fff;
    border: 1px solid #ddd;
}

.auth-table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 13px;
}

.auth-table th {
    background: #373279;
    color: white;
    padding: 6px;
    border: 1px solid #ccc;
    text-align: center;
    white-space: nowrap;
}

.auth-table td {
    padding: 8px;
    border: 1px solid #ccc;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.auth-table th:nth-child(1),
.auth-table td:nth-child(1) {
    width: 60px !important;
    text-align: center;
}

.status-pending { color: orange; font-weight: bold; }
.status-rejected { color: red; font-weight: bold; }

.btn {
    display:inline-block;
    padding:4px 8px;
    font-size:12px;
    border-radius:4px;
    text-decoration:none;
}
.btn.auth { background:#28a745; color:#fff; }
.btn.rej  { background:#dc3545; color:#fff; }
</style>
</head>

<body>

<script>
setTimeout(() => {
    const msg = document.getElementById("msgBox");
    if (msg) msg.style.display = "none";
}, 2000);
</script>

<h2>Authorization Pending Masters</h2>

<div class="table-wrapper">
<table class="auth-table">

<tr>
    <th>Status</th>
    <th>Action</th>
    <th>Master Name</th>
    <th>Table</th>
    <th>Record Key</th>
    <th>Field</th>
    <th>Old Value</th>
    <th>New Value</th>
    <th>Created Date</th>
</tr>

<%
Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

boolean found = false;

try {
    con = DBConnection.getConnection();

    ps = con.prepareStatement(
        "SELECT MASTER_NAME, TABLE_NAME, RECORD_KEY, FIELD_NAME, " +
        "ORIGINAL_VALUE, MODIFIED_VALUE, CREATED_DATE, STATUS " +
        "FROM AUDITTRAIL.MASTER_AUDITTRAIL " +
        "WHERE STATUS = 'E' " +
        "ORDER BY CREATED_DATE DESC"
    );

    rs = ps.executeQuery();

    while (rs.next()) {
        found = true;
%>
<tr>
    <td>
        <% if ("E".equals(rs.getString("STATUS"))) { %>
            <span class="status-pending">Pending</span>
        <% } else { %>
            <span class="status-rejected">Rejected</span>
        <% } %>
    </td>

    <td>
        <a class="btn auth"
           href="AuthorizeMasterServlet?action=A&recordKey=<%=rs.getString("RECORD_KEY")%>&field=<%=rs.getString("FIELD_NAME")%>">
           Authorize
        </a>
        <a class="btn rej"
           href="AuthorizeMasterServlet?action=R&recordKey=<%=rs.getString("RECORD_KEY")%>&field=<%=rs.getString("FIELD_NAME")%>">
           Reject
        </a>
    </td>

    <td><%=rs.getString("MASTER_NAME")%></td>
    <td><%=rs.getString("TABLE_NAME")%></td>
    <td style="text-align:center;"><%=rs.getString("RECORD_KEY")%></td>
    <td><%=rs.getString("FIELD_NAME")%></td>
    <td><%=rs.getString("ORIGINAL_VALUE")%></td>
    <td><%=rs.getString("MODIFIED_VALUE")%></td>
    <td><%=rs.getTimestamp("CREATED_DATE")%></td>
</tr>
<%
    }

    if (!found) {
%>
<tr>
    <td colspan="9" style="text-align:center;">No records found</td>
</tr>
<%
    }

} catch (Exception e) {
    e.printStackTrace();
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}
%>

</table>
</div>

</body>
</html>
