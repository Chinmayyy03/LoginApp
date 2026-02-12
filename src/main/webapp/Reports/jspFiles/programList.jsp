<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String schemaParam = request.getParameter("schema");
    if (schemaParam == null) schemaParam = "";

    String pageParam = request.getParameter("page");

    int currentPage = 1;
    int recordsPerPage = 16;

    if (pageParam != null) {
        currentPage = Integer.parseInt(pageParam);
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    int totalRecords = 0;
    int totalPages = 0;
%>

<!DOCTYPE html>
<html>
<head>
<title>Report List</title>

<link rel="stylesheet"
      href="<%=request.getContextPath()%>/Reports/common-table.css">

</head>

<body>

<div class="container">

     <!-- SEARCH BAR -->
    <div class="search-box">
        <input type="text"
               id="tableSearch"
               placeholder="🔍 Search by Program Name...."
               onkeyup="filterTable()">
    </div>


    <div class="card-wrapper">

<%
    try {

        conn = DBConnection.getConnection();

        String countSql =
            "SELECT COUNT(*) FROM ACL.PROGRAM WHERE UPPER(\"SCHEMA\") LIKE ?";

        ps = conn.prepareStatement(countSql);
        ps.setString(1, "%" + schemaParam.toUpperCase() + "%");
        rs = ps.executeQuery();

        if (rs.next()) {
            totalRecords = rs.getInt(1);
        }

        rs.close();
        ps.close();

        totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
        int start = (currentPage - 1) * recordsPerPage;

        String dataSql =
            "SELECT PROGRAM_NAME, PAGE_LINK FROM (" +
            " SELECT PROGRAM_NAME, PAGE_LINK, ROW_NUMBER() OVER (ORDER BY PROGRAM_NAME) rn " +
            " FROM ACL.PROGRAM WHERE UPPER(\"SCHEMA\") LIKE ?" +
            ") WHERE rn BETWEEN ? AND ?";

        ps = conn.prepareStatement(dataSql);
        ps.setString(1, "%" + schemaParam.toUpperCase() + "%");
        ps.setInt(2, start + 1);
        ps.setInt(3, start + recordsPerPage);

        rs = ps.executeQuery();
%>

        <table class="program-table">
            <thead>
                <tr>
                    <th>PROGRAM NAME</th>
                    <th>PROGRAM NAME</th>
                    <th>PROGRAM NAME</th>
                    <th>PROGRAM NAME</th>
                </tr>
            </thead>
            <tbody>
                <tr>

<%
        int columnCount = 0;

        while (rs.next()) {

            if (columnCount == 4) {
%>
                </tr>
                <tr>
<%
                columnCount = 0;
            }
%>

            <td class="program-cell"
                onclick="openForm('<%= rs.getString("PAGE_LINK") %>')">
                <%= rs.getString("PROGRAM_NAME") %>
            </td>

<%
            columnCount++;
        }

        while (columnCount < 4 && columnCount != 0) {
%>
            <td></td>
<%
            columnCount++;
        }
%>

                </tr>
            </tbody>
        </table>

<%
    } catch (Exception e) {
%>
        <div style="color:red; text-align:center;">Error loading data</div>
<%
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>

    </div>

    <!-- PAGINATION -->
    <div class="pagination-container">

        <% if (currentPage > 1) { %>
            <a href="?schema=<%=schemaParam%>&page=<%=currentPage-1%>"
               class="nav-btn">← Previous</a>
        <% } else { %>
            <button class="disabled-btn">← Previous</button>
        <% } %>

        <span class="page-info">
            Page <%=currentPage%> of <%= totalPages == 0 ? 1 : totalPages %>
        </span>

        <% if (currentPage < totalPages) { %>
            <a href="?schema=<%=schemaParam%>&page=<%=currentPage+1%>"
               class="nav-btn">Next →</a>
        <% } else { %>
            <button class="disabled-btn">Next →</button>
        <% } %>

    </div>

    <!-- ================= FORM CONTAINER BELOW TABLE ================= -->
    <div id="formContainer" style="display:none; margin-top:30px;">
        
        <div style="text-align:right; margin-bottom:10px;">
            <button onclick="closeForm()" class="nav-btn">Close</button>
        </div>

        <iframe id="formFrame"
                style="width:100%; height:650px; border:1px solid #ccc; border-radius:8px;">
        </iframe>
    </div>

</div>

<!-- ================= SCRIPT ================= -->
<script>
function openForm(url) {
    document.getElementById("formContainer").style.display = "block";
    document.getElementById("formFrame").src = url;

    document.getElementById("formContainer").scrollIntoView({
        behavior: "smooth"
    });
}

function closeForm() {
    document.getElementById("formContainer").style.display = "none";
    document.getElementById("formFrame").src = "";
}
</script>

<script>
function filterTable() {
    let input = document.getElementById("tableSearch");
    let filter = input.value.toUpperCase();
    let table = document.querySelector(".program-table");
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
