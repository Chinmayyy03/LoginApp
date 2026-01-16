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

/* Wrapper */
.table-wrapper {
    width: 100%;
    overflow-x: auto;
    background: #fff;
    border: 1px solid #ddd;
}

/* Table */
.auth-table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 13px;
}

/* Header */
.auth-table th {
    background: #373279;
    color: white;
    padding: 6px;
    border: 1px solid #ccc;
    text-align: center;
    white-space: nowrap;
}

/* Cells */
.auth-table td {
    padding: 8px;
    border: 1px solid #ccc;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

/* Column widths */
.auth-table th:nth-child(1), .auth-table td:nth-child(1) { width: 90px; }
.auth-table th:nth-child(2), .auth-table td:nth-child(2) { width: 140px; }
.auth-table th:nth-child(3), .auth-table td:nth-child(3) { width: 220px; }
.auth-table th:nth-child(4), .auth-table td:nth-child(4) { width: 160px; }
.auth-table th:nth-child(5), .auth-table td:nth-child(5) { width: 90px; text-align:center; }
.auth-table th:nth-child(6), .auth-table td:nth-child(6) { width: 140px; }
.auth-table th:nth-child(7), .auth-table td:nth-child(7) { width: 180px; }
.auth-table th:nth-child(8), .auth-table td:nth-child(8) { width: 180px; }
.auth-table th:nth-child(9), .auth-table td:nth-child(9) { width: 170px; }

/* Status */
.status-pending { color: orange; font-weight: bold; }
.status-rejected { color: red; font-weight: bold; }

/* Buttons */
.btn {
    display:inline-block;
    padding:4px 8px;
    font-size:12px;
    border-radius:4px;
    text-decoration:none;
    margin:2px 0;
}
.btn.auth { background:#28a745; color:#fff; }
.btn.rej  { background:#dc3545; color:#fff; }

/* FIX STATUS COLUMN SIZE */
.auth-table th:nth-child(1),
.auth-table td:nth-child(1) {
    width: 60px !important;
    min-width: 60px;
    max-width: 60px;
    text-align: center;
    padding-left: 4px;
    padding-right: 4px;
}

/* Keep status text compact */
.status-pending,
.status-rejected {
    display: inline-block;
    font-size: 12px;
    font-weight: bold;
    white-space: nowrap;
}

</style>
</head>

<body>

<script>
/* Hide message after 2 seconds */
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
try (Connection con = DBConnection.getConnection()) {

    PreparedStatement ps = con.prepareStatement(
        "SELECT MASTER_NAME, TABLE_NAME, RECORD_KEY, FIELD_NAME, " +
        "ORIGINAL_VALUE, MODIFIED_VALUE, CREATED_DATE, STATUS " +
        "FROM AUDITTRAIL.MASTER_AUDITTRAIL " +
        "WHERE STATUS = 'E' " +
        "ORDER BY CREATED_DATE DESC"
    );

    ResultSet rs = ps.executeQuery();
    boolean found = false;

    while (rs.next()) {
        found = true;
%>
<tr>
    <!-- STATUS -->
    <td>
        <% if ("E".equals(rs.getString("STATUS"))) { %>
            <span class="status-pending">Pending</span>
        <% } else { %>
            <span class="status-rejected">Rejected</span>
        <% } %>
    </td>

    <!-- ACTION -->
    <td>
        <% if ("E".equals(rs.getString("STATUS"))) { %>
            <a class="btn auth"
               href="AuthorizeMasterServlet?action=A&recordKey=<%=rs.getString("RECORD_KEY")%>&field=<%=rs.getString("FIELD_NAME")%>">
               Authorize
            </a>
            <a class="btn rej"
               href="AuthorizeMasterServlet?action=R&recordKey=<%=rs.getString("RECORD_KEY")%>&field=<%=rs.getString("FIELD_NAME")%>">
               Reject
            </a>
        <% } else { %>
            No Action
        <% } %>
    </td>

    <!-- DATA -->
    <td title="<%=rs.getString("MASTER_NAME")%>"><%=rs.getString("MASTER_NAME")%></td>
    <td title="<%=rs.getString("TABLE_NAME")%>"><%=rs.getString("TABLE_NAME")%></td>
    <td style="text-align:center;"><%=rs.getString("RECORD_KEY")%></td>
    <td title="<%=rs.getString("FIELD_NAME")%>"><%=rs.getString("FIELD_NAME")%></td>
    <td title="<%=rs.getString("ORIGINAL_VALUE")%>"><%=rs.getString("ORIGINAL_VALUE")%></td>
    <td title="<%=rs.getString("MODIFIED_VALUE")%>"><%=rs.getString("MODIFIED_VALUE")%></td>
    <td><%=rs.getTimestamp("CREATED_DATE")%></td>
</tr>
<%
    }

    if (!found) {
%>
<tr><td colspan="9" style="text-align:center;">No records found</td></tr>
<%
    }
}
%>

</table>
</div>

</body>
</html>
