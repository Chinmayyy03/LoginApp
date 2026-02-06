<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, db.DBConnection" %>

<%
String userId = request.getParameter("userId");

if(userId == null || userId.trim().equals("")){
%>
    <h3> User Id not received</h3>
<%
    return;
}

/* ================= FETCH USER DATA ================= */
String userName="";
String branchCode="";
String custId="";
String mobile="";
String empCode="";

Connection conn=null;
PreparedStatement ps=null;
ResultSet rs=null;

try{
    conn = DBConnection.getConnection();

    String sql =
        "SELECT USER_ID, NAME, BRANCH_CODE, CUSTOMER_ID, MOBILE_NUMBER " +
        "FROM ACL.USERREGISTER WHERE USER_ID=?";

    ps = conn.prepareStatement(sql);
    ps.setString(1,userId);
    rs = ps.executeQuery();

    if(rs.next()){
        userName   = rs.getString("NAME");
        branchCode = rs.getString("BRANCH_CODE");
        custId     = rs.getString("CUSTOMER_ID");
        mobile     = rs.getString("MOBILE_NUMBER");
    }else{
%>
        <h3>User Not Found</h3>
<%
        return;
    }

}catch(Exception e){
    out.print(e);
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>View User Authorization</title>

<link rel="stylesheet" type="text/css"
href="<%=request.getContextPath()%>/OpenAccount/css/savingAcc.css">

<style>
:root{
 --bg-lavender:#E6E6FA;
 --navy-blue:#303F9F;
 --border-color:#B8B8E6;
 --readonly-bg:#E0E0E0;
}

body{
 font-family:Arial,sans-serif;
 background-color:var(--bg-lavender);
 margin:0;
 padding:20px;
}

.container{max-width:1400px;margin:auto;}

h2{
 text-align:center;
 color:var(--navy-blue);
 margin-bottom:25px;
}

fieldset{
 border:1.5px solid var(--border-color);
 border-radius:8px;
 margin-bottom:22px;
 padding:18px;
}

legend{
 color:var(--navy-blue);
 font-weight:bold;
 font-size:15px;
 padding:0 10px;
 background-color:var(--bg-lavender);
}

.grid-row-1{
 display:grid;
 grid-template-columns:repeat(5,1fr);
 gap:15px;
 margin-bottom:15px;
 align-items:end;
}

.grid-row-2{
 display:grid;
 grid-template-columns:repeat(4,1fr);
 gap:15px;
 align-items:end;
}

.form-group{width:100%;}

.form-group label{
 display:block;
 font-size:13px;
 font-weight:bold;
 color:var(--navy-blue);
 margin-bottom:4px;
}

.form-group input{
 width:100%;
 padding:7px;
 border:1px solid var(--border-color);
 border-radius:4px;
 font-size:13px;
 box-sizing:border-box;
}

input[readonly]{
 background-color:var(--readonly-bg);
}

/* ===== BUTTON STYLES ===== */

.btn-back{
 background:#6c757d;
 color:white;
 padding:9px 22px;
 border:none;
 border-radius:5px;
 font-size:13px;
 cursor:pointer;
}

.btn-auth{
 background:#28a745;
 color:white;
 padding:10px 26px;
 border:none;
 border-radius:5px;
 font-size:14px;
 cursor:pointer;
 margin-right:15px;
}

.btn-reject{
 background:#dc3545;
 color:white;
 padding:10px 26px;
 border:none;
 border-radius:5px;
 font-size:14px;
 cursor:pointer;
}
</style>
</head>

<body>

<div class="container">

<h2>View User Authorization</h2>

<!-- ================= USER DETAILS ================= -->
<fieldset>
<legend>User Details</legend>

<div class="grid-row-1" style="grid-template-columns:repeat(4,1fr);">

<div class="form-group">
<label>User Id</label>
<input type="text" value="<%=userId%>" readonly>
</div>

<div class="form-group">
<label>User Name</label>
<input type="text" value="<%=userName%>" readonly>
</div>

<div class="form-group">
<label>Branch Code</label>
<input type="text" value="<%=branchCode%>" readonly>
</div>

<div class="form-group">
<label>Employee Code</label>
<input type="text" value="<%=empCode%>" readonly>
</div>

</div>
</fieldset>

<!-- ================= ADDRESS DETAILS ================= -->
<fieldset id="addressFieldset">
<legend>Address Details</legend>

<div class="grid-row-1">

<div class="form-group">
<label>Customer ID</label>
<input type="text" id="customerId" value="<%=custId%>" readonly>
</div>

<div class="form-group">
<label>Customer Name</label>
<input type="text" id="customerName" readonly>
</div>

<div class="form-group">
<label>Phone</label>
<input type="text" id="phone" readonly>
</div>

<div class="form-group">
<label>Mobile</label>
<input type="text" id="mobile" value="<%=mobile%>" readonly>
</div>

<div class="form-group">
<label>Email</label>
<input type="text" id="email" readonly>
</div>

</div>

<div class="grid-row-2">

<div class="form-group">
<label>Address 1</label>
<input type="text" id="addr1" readonly>
</div>

<div class="form-group">
<label>Address 2</label>
<input type="text" id="addr2" readonly>
</div>

<div class="form-group">
<label>Address 3</label>
<input type="text" id="addr3" readonly>
</div>

</div>
</fieldset>

<!-- ================= BUTTON SECTION ================= -->

<br>

<div style="text-align:center;">
    <button type="button" onclick="goBackToList();" class="back-btn"
        style="padding:10px 22px; background:#373279; color:white;
               border:none; border-radius:6px; cursor:pointer;
               font-size:16px; font-weight:bold;">
    ← Back to List
    </button>
</div>

<div style="text-align:center; margin-top:30px;">
    <form id="authorizeForm" action="UpdateApplicationStatusServlet" method="post" style="display:inline;">
        <input type="hidden" name="appNo" value="<%= userId %>">
        <input type="hidden" name="status" value="A">
        <button type="button" onclick="showAuthorizeConfirmation(event)"
            style="padding:10px 22px; background:linear-gradient(45deg, #28a745, #34ce57); color:white;
                   border:none; border-radius:6px; cursor:pointer;
                   font-size:16px; font-weight:bold;">
            ✔ Authorize
        </button>
    </form>

    &nbsp;&nbsp;&nbsp;

    <form id="rejectForm" action="UpdateApplicationStatusServlet" method="post" style="display:inline;">
        <input type="hidden" name="appNo" value="<%= userId %>">
        <input type="hidden" name="status" value="R">
        <button type="button" onclick="showRejectConfirmation(event)"
            style="padding:10px 22px; background:linear-gradient(45deg, #dc3545, #e74c3c); color:white;
                   border:none; border-radius:6px; cursor:pointer;
                   font-size:16px; font-weight:bold;">
            ✘ Reject
        </button>
    </form>
</div>
<!-- ================= FETCH CUSTOMER DETAILS ================= -->
<script>
window.onload=function(){

 let custId=document.getElementById("customerId").value;

 if(custId){

  fetch(
   "<%=request.getContextPath()%>/OpenAccount/getCustomerDetails.jsp?customerId="
   +encodeURIComponent(custId)
  )
  .then(res=>res.json())
  .then(data=>{

   if(data.success && data.customer){

    let c=data.customer;

    document.getElementById("customerName").value=c.customerName||"";
    document.getElementById("phone").value=c.residencePhone||"";
    document.getElementById("email").value=c.email||"";
    document.getElementById("addr1").value=c.address1||"";
    document.getElementById("addr2").value=c.address2||"";
    document.getElementById("addr3").value=c.address3||"";
   }

  });

 }

};
</script>

</body>
</html>
