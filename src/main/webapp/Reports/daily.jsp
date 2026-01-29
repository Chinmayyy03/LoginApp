<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>Daily Report</title>

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">

    <link rel="stylesheet"
      href="<%=request.getContextPath()%>/Reports/common-table.css">

</head>

<body>

<div class="container">
     
      <div class="card-header bg-primary text-white">
            <h5 class="mb-0">Daily Report</h5>
        </div>
        
         <!-- SEARCH BAR -->
<div class="search-box">
    <input type="text"
           id="tableSearch"
           placeholder="🔍 Search by Program Name, Caption, Page Link"
           onkeyup="filterTable()">
</div>

        <div class="card-body">
            <table class="table table-bordered table-hover">
                <thead class="thead-dark">
                    <tr>
                        <th>Program Name</th>
                        <th>Caption</th>
                        <th>Page Link</th>
                        <th>View Report</th>
                    </tr>
                </thead>
                <tbody>

<%
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("oracle.jdbc.OracleDriver");

    conn = DriverManager.getConnection(
        "jdbc:oracle:thin:@192.168.1.117:1521:xe",
        "system",
        "info123"
    );

    String sql =
        "SELECT PROGRAM_NAME, CAPTION, PAGE_LINK " +
        "FROM ACL.PROGRAM " +
        "WHERE PROGRAM_ID = 999999";

    ps = conn.prepareStatement(sql);
    rs = ps.executeQuery();

    boolean hasData = false;

    while (rs.next()) {
        hasData = true;
%>
                    <tr>
                        <td><%= rs.getString("PROGRAM_NAME") %></td>
                        <td><%= rs.getString("CAPTION") %></td>
                        <td><%= rs.getString("PAGE_LINK") %></td>
                        <td class="text-center">
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
                            No records found for PROGRAM_ID = 999999
                        </td>
                    </tr>
<%
    }

} catch (Exception e) {
%>
                    <tr>
                        <td colspan="4" class="text-center text-danger">
                            <%= e.getMessage() %>
                        </td>
                    </tr>
<%
} finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
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
