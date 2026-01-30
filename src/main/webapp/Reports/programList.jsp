<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String schemaParam = request.getParameter("schema");

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html>
<head>
    <title>Report Record</title>

    <!-- Bootstrap (required for .table, .btn, etc.) -->
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">

    <!-- YOUR CSS -->
    <link rel="stylesheet"
          href="<%=request.getContextPath()%>/Reports/common-table.css">
</head>

<body>

<div class="container">

    <!-- TITLE -->
    <div class="card-header">
        <h5>Report Records</h5>
    </div>

    <!-- SEARCH BAR -->
    <div class="search-box">
        <input type="text"
               id="tableSearch"
               placeholder="🔍 Search by Program Name, Caption, Page Link"
               onkeyup="filterTable()">
    </div>

    <!-- TABLE WRAPPER (VERY IMPORTANT) -->
    <div class="card-body">
        <table class="table table-bordered table-hover">
            <thead>
                <tr>
                    <th>Program Name</th>
                    <th>Caption</th>
                    <th>Page Link</th>
                    <th>View Report</th>
                </tr>
            </thead>

            <tbody>
<%
try {
    conn = DBConnection.getConnection();

    String sql =
        "SELECT PROGRAM_NAME, CAPTION, PAGE_LINK " +
        "FROM ACL.PROGRAM " +
        "WHERE UPPER(\"SCHEMA\") LIKE ? " +
        "ORDER BY PROGRAM_NAME";

    ps = conn.prepareStatement(sql);

    if (schemaParam == null || schemaParam.trim().isEmpty()) {
        throw new RuntimeException("Schema parameter missing");
    }

    String filter = "%" + schemaParam.toUpperCase() + "%";
    ps.setString(1, filter);


    rs = ps.executeQuery();

    boolean hasData = false;

    while (rs.next()) {
        hasData = true;
%>
                <tr>
                    <td><%= rs.getString("PROGRAM_NAME") %></td>
                    <td><%= rs.getString("CAPTION") %></td>
                    <td><%= rs.getString("PAGE_LINK") %></td>
                    <td>
                        <a href="<%= rs.getString("PAGE_LINK") %>"
   class="btn btn-sm btn-success">
    View Report
</a>
                    </td>
                </tr>
<%
    }

    if (!hasData) {
%>
                <tr>
                    <td colspan="4" class="text-center text-danger">
                        No records found
                    </td>
                </tr>
<%
    }

} catch (Exception e) {
%>
                <tr>
                    <td colspan="4" class="text-center text-danger">
                        Error loading data
                    </td>
                </tr>
<%
    e.printStackTrace();
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
}
%>
            </tbody>
        </table>
    </div>
</div>

<script>
function filterTable() {
    let input = document.getElementById("tableSearch");
    let filter = input.value.toUpperCase();
    let table = document.querySelector(".table");
    let tr = table.getElementsByTagName("tr");

    for (let i = 1; i < tr.length; i++) {
        let tds = tr[i].getElementsByTagName("td");
        let found = false;

        for (let j = 0; j < tds.length; j++) {
            if (tds[j].innerText.toUpperCase().includes(filter)) {
                found = true;
                break;
            }
        }
        tr[i].style.display = found ? "" : "none";
    }
}
</script>

</body>
</html>
