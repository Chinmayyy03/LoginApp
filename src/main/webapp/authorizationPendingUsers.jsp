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
<link rel="stylesheet" href="css/totalCustomers.css">

<style>

/* PAGE BACKGROUND */
body{
    font-family: Arial, sans-serif;
    background: #C9C3D9;
    margin: 0;
    padding: 20px;
}

/* CONTAINER */
.container{
    max-width: 1400px;
    margin: auto;
}

/* TITLE */
h2{
    text-align: center;
    color: #2E1A87;
    font-weight: 700;
    margin-bottom: 20px;
    font-size: 26px;
}

/* SEARCH BOX */
.search-box{
    width: 650px;
    margin: 0 auto 20px auto;
}

.search-box input{
    width: 100%;
    padding: 11px 15px;
    border-radius: 5px;
    border: 1px solid #999;
    font-size: 14px;
    background: #E9E9E9;
    box-sizing: border-box;
    color: #666;
}

.search-box input::placeholder{
    color: #999;
}

/* TABLE WRAPPER */
.table-card{
    background: #fff;
    border-radius: 0;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    overflow: hidden;
}

/* TABLE */
table{
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
}

/* HEADER ROW */
thead tr{
    background: #34127A;
}

th{
    background: #34127A;
    color: #FFFFFF;
    padding: 12px 10px;
    text-align: center;
    font-weight: 700;
    letter-spacing: 0.5px;
    font-size: 13px;
    text-transform: uppercase;
    border: none;
}

/* DATA ROWS */
tbody tr{
    border-bottom: 1px solid #ddd;
}

tbody tr:nth-child(odd){
    background: #F5F5F5;
}

tbody tr:nth-child(even){
    background: #FFFFFF;
}

tbody tr:hover{
    background: #E8E4FC !important;
}

td{
    padding: 11px 10px;
    text-align: center;
    color: #000;
    border: none;
}

/* SR NO COLUMN */
td:first-child{
    font-weight: 500;
}

/* STATUS STYLING */
td.status-cell{
    color: #2E1A87;
    font-weight: 600;
}

/* BUTTON */
.action-btn{
    background: #34127A;
    color: #FFFFFF;
    border: none;
    padding: 6px 16px;
    border-radius: 4px;
    font-size: 13px;
    cursor: pointer;
    transition: background 0.3s ease;
    font-weight: 600;
}

.action-btn:hover{
    background: #22085A;
}

/* NO DATA MESSAGE */
.no-data{
    text-align: center;
    padding: 40px;
    color: #666;
    font-size: 15px;
}

</style>
</head>

<body>

<div class="container">

    <!-- TITLE -->
    <h2>Authorization Pending list for Branch: <%=branchCode%></h2>

    <!-- SEARCH -->
    <div class="search-box">
        <input type="text"
               placeholder="🔍 Search by Name, Customer ID, Branch">
    </div>

    <!-- TABLE -->
    <div class="table-card">
        <table>

            <!-- TABLE HEADER -->
            <thead>
                <tr>
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
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;

                try {
                    conn = DBConnection.getConnection();

                    /* 🔹 Updated SQL (removed unwanted columns) */
                    String sql =
                        "SELECT USER_ID, NAME, BRANCH_CODE, CUSTOMER_ID, " +
                        "MOBILE_NUMBER, CREATED_DATE " +
                        "FROM ACL.USERREGISTER " +
                        "WHERE BRANCH_CODE=? " +
                        "ORDER BY CREATED_DATE DESC";

                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, branchCode);
                    rs = pstmt.executeQuery();

                    boolean hasData = false;

                    while (rs.next()) {
                        hasData = true;
            %>

                <tr>
                    <td><%=rs.getString("USER_ID")%></td>

                    <td>
                        <%=rs.getString("NAME") != null
                            ? rs.getString("NAME") : ""%>
                    </td>

                    <td><%=rs.getString("BRANCH_CODE")%></td>

                    <td>
                        <%=rs.getString("CUSTOMER_ID") != null
                            ? rs.getString("CUSTOMER_ID") : ""%>
                    </td>

                    <td>
                        <%=rs.getString("MOBILE_NUMBER") != null
                            ? rs.getString("MOBILE_NUMBER") : ""%>
                    </td>

                    <td>
                        <%
                            Timestamp createdDate =
                                rs.getTimestamp("CREATED_DATE");

                            if(createdDate != null){
                                out.print(
                                    new java.text.SimpleDateFormat(
                                        "dd-MMM-yyyy HH:mm"
                                    ).format(createdDate)
                                );
                            }
                        %>
                    </td>

                    <td>
                        <button class="action-btn"
                            onclick="authorizeUser('<%=rs.getString("USER_ID")%>')">
                            View Details
                        </button>
                    </td>
                </tr>

            <%
                    }

                    if (!hasData) {
            %>
                <tr>
                    <td colspan="7" class="no-data">
                        No pending users found
                    </td>
                </tr>
            <%
                    }

                } catch(Exception e) {
            %>
                <tr>
                    <td colspan="7" class="no-data">
                        Error: <%=e.getMessage()%>
                    </td>
                </tr>
            <%
                } finally {
                    try{ if(rs!=null) rs.close(); }catch(Exception ignored){}
                    try{ if(pstmt!=null) pstmt.close(); }catch(Exception ignored){}
                    try{ if(conn!=null) conn.close(); }catch(Exception ignored){}
                }
            %>

            </tbody>
        </table>
    </div>

</div>

<script>
function authorizeUser(userId){
    alert("Open details for: " + userId);
}
</script>

</body>
</html>
