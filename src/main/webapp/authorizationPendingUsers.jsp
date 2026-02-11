<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, db.DBConnection" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Authorization Pending Users</title>

<link rel="stylesheet" href="css/addCustomers.css">
<link rel="stylesheet" href="css/totalCustomers.css">

<style>

/* PAGE BACKGROUND */
body{
    font-family: Arial, sans-serif;
    background: #E6E6FA;  /* Changed from #C9C3D9 to match lighter lavender */
    margin: 0;
    padding: 20px;
}

html, body{
    overflow-x: hidden;
}

/* CONTAINER */
.container{
    max-width: 1400px;
    margin: auto;
}

/* TITLE */
h2{
    text-align: center;
    color: #303F9F;  /* Changed to match navy blue from other page */
    font-weight: 700;
    margin-bottom: 18px;
    font-size: 24px;
}

/* SEARCH BOX */
.search-box{
    width: 650px;
    margin: 0 auto 18px auto;
}

.search-box input{
    width: 100%;
    padding: 8px 12px;
    border-radius: 4px;
    border: 1px solid #B8B8E6;  /* Lighter border */
    font-size: 13px;
    background: #FFFFFF;  /* Changed to white for cleaner look */
    box-sizing: border-box;
    color: #444;
}

/* TABLE WRAPPER */
.table-card{
    background: #fff;
    border-radius: 6px;
    box-shadow: 0 2px 6px rgba(0,0,0,0.10);
    overflow: auto;
    border: 1px solid #B8B8E6;
    overflow: auto;       
    max-height: 500px;  
}

/* TABLE */
table{
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
}

/* HEADER */
thead tr{
    background: #303F9F;  /* Changed to match navy blue */
}

th{
    color: #FFFFFF;
    padding: 6px 8px;
    text-align: center;
    font-weight: 600;
    font-size: 12.5px;
    border-right: 1px solid rgba(255,255,255,0.2);  /* Lighter separator */
}

th:last-child{
    border-right: none;
}

/* ROWS */
tbody tr:nth-child(odd){ background: #F7F7F7; }
tbody tr:nth-child(even){ background: #FFFFFF; }

td{
    padding: 5px 8px;
    text-align: left;
    border-right: 1px solid #e3e3e3;
}

td:last-child{
    border-right: none;
}

/* BUTTON */
.action-btn{
    background: #2b0d73;  /* Matches table header color */
    color: #FFFFFF;
    border: none;
    padding: 3px 10px;
    border-radius: 3px;
    font-size: 12px;
    cursor: pointer;
    font-weight: 400;
}

.action-btn:hover{
    background: #1E2870;  /* Darker on hover */
}

.no-data{
    text-align: center;
    padding: 30px;
    color: #666;
    font-size: 14px;
}

</style>
</head>

<body>

<div class="container">

	<h2>Authorization Pending list for Branch: <%=branchCode%></h2>

<div class="search-box">
    <input type="text"
           id="searchInput"
           onkeyup="searchTable()"
           placeholder="🔍 Search by Name, Customer ID, Branch">
</div>

<div class="table-card">

<table id="userTable">

<thead>
<tr>
    <th>Sr. No.</th>
    <th>User ID</th>
    <th>User Name</th>
    <th>Branch Code</th>
    <th>Customer ID</th>
    <th>Mobile</th>
    <th>Created Date</th>
    <th>Action</th>
</tr>
</thead>

<tbody>

<%
Connection conn=null;
PreparedStatement pstmt=null;
ResultSet rs=null;

try{
    conn = DBConnection.getConnection();

    String sql =
        "SELECT USER_ID, NAME, BRANCH_CODE, CUSTOMER_ID, " +
        "MOBILE_NUMBER, CREATED_DATE " +
        "FROM ACL.USERREGISTER " +
        "WHERE BRANCH_CODE=? AND STATUS='E' " +
        "ORDER BY CREATED_DATE DESC";

    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, branchCode);
    rs = pstmt.executeQuery();

    boolean hasData=false;
    int srNo=1;

    while(rs.next()){
        hasData=true;
%>

	<tr>
	<td><%=srNo++%></td>
	<td><%=rs.getString("USER_ID")%></td>
	<td><%=rs.getString("NAME")%></td>
	<td><%=rs.getString("BRANCH_CODE")%></td>
	<td><%=rs.getString("CUSTOMER_ID")%></td>
	<td><%=rs.getString("MOBILE_NUMBER")%></td>

<td>
<%
Timestamp createdDate = rs.getTimestamp("CREATED_DATE");
if(createdDate!=null){
out.print(new java.text.SimpleDateFormat(
"dd-MMM-yyyy HH:mm").format(createdDate));
}
%>
</td>

<td>
    <a href="viewUserAutho.jsp?userId=<%=rs.getString("USER_ID")%>">
        <button class="action-btn">View Details</button>
    </a>
</td>

</tr>

<%
}

if(!hasData){
%>
	<tr>
		<td colspan="8" class="no-data">No pending users found</td>
	</tr>
<%
}

}catch(Exception e){
%>
	<tr>
		<td colspan="8" class="no-data">Error: <%=e.getMessage()%></td>
	</tr>
<%
} finally {
    if(rs != null) try { rs.close(); } catch(Exception e){}
    if(pstmt != null) try { pstmt.close(); } catch(Exception e){}
    if(conn != null) try { conn.close(); } catch(Exception e){}
}
%>

</tbody>
</table>
</div>

</div>
<script>
function searchTable() {

    let input = document.getElementById("searchInput");
    let filter = input.value.toLowerCase();

    let table = document.getElementById("userTable");
    let tr = table.getElementsByTagName("tr");

    for (let i = 1; i < tr.length; i++) {   // Skip header

        let tds = tr[i].getElementsByTagName("td");
        let found = false;

        for (let j = 0; j < tds.length; j++) {

            if (tds[j]) {
                let text = tds[j].textContent || tds[j].innerText;

                if (text.toLowerCase().indexOf(filter) > -1) {
                    found = true;
                    break;
                }
            }
        }

        tr[i].style.display = found ? "" : "none";
    }
}
</script>

</body>
</html>
