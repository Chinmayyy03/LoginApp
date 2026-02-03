<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>New User Creation</title>

<style>
    :root {
        --bg-lavender: #E6E6FA;      
        --navy-blue: #303F9F;        
        --border-color: #A2A2D0;    
        --input-bg: #FFFFFF;
        --readonly-bg: #E0E0E0;     
    }

    body {
        font-family: Arial, sans-serif;
        background-color: var(--bg-lavender);
        margin: 0;
        padding: 20px;
    }

    .container {
        max-width: 1250px;
        margin: 0 auto;
        background-color: var(--bg-lavender);
        padding: 10px;
    }

    h2 {
        text-align: center;
        color: var(--navy-blue);
        text-transform: uppercase;
        margin-bottom: 30px;
        font-size: 24px;
        letter-spacing: 1px;
    }

    fieldset {
        border: 1px solid var(--border-color);
        border-radius: 8px;
        margin-bottom: 25px;
        padding: 20px 15px 15px;
    }

    legend {
        color: var(--navy-blue);
        font-weight: bold;
        font-size: 18px;
        padding: 0 10px;
    }

    .form-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 15px 20px;
    }

    .form-group {
        display: flex;
        flex-direction: column;
    }

    .form-group label {
        font-size: 13px;
        font-weight: bold;
        color: var(--navy-blue);
        margin-bottom: 4px;
    }

    .form-group input {
        padding: 6px 8px;
        border: 1px solid var(--border-color);
        border-radius: 3px;
        font-size: 13px;
    }

    input[readonly] {
        background-color: var(--readonly-bg);
    }

    .input-row {
        display: flex;
        gap: 4px;
    }

    .search-btn {
        background: #F0F0F0;
        border: 1px solid var(--border-color);
        padding: 0 8px;
        border-radius: 3px;
        cursor: pointer;
        font-weight: bold;
    }

    .btn-container {
        text-align: center;
        margin-top: 20px;
    }

    .save-btn {
        padding: 10px 50px;
        background-color: #3F51B5;
        color: white;
        border: none;
        border-radius: 4px;
        font-weight: bold;
        cursor: pointer;
    }
</style>
</head>

<body>

<div class="container">
    <form action="<%=request.getContextPath()%>/Utility/CreateUserServlet" method="post">

        <h2>New User Registration</h2>

        <fieldset>
            <legend>User Details</legend>
            <div class="form-grid">
                <div class="form-group">
                    <label>User Id</label>
                    <input type="text" name="userId" required>
                </div>
                <div class="form-group">
                    <label>User Name</label>
                    <input type="text" name="userName" required>
                </div>
                <div class="form-group">
                    <label>Branch Code</label>
                    <div class="input-row">
                        <input type="text" name="branchCode" value="0002">
                        <button type="button" class="search-btn">...</button>
                    </div>
                </div>
                <div class="form-group">
                    <label>Branch Name</label>
                    <input type="text" value="SHAHUPURI" readonly>
                </div>
            </div>
        </fieldset>

        <fieldset>
            <legend>Address Details</legend>
            <div class="form-grid">
                <div class="form-group">
                    <label>Customer ID</label>
                    <div class="input-row">
                        <input type="text" name="custId">
                        <button type="button" class="search-btn">...</button>
                    </div>
                </div>
                <div class="form-group">
                    <label>Employee Code</label>
                    <input type="text" name="empCode">
                </div>
                <div class="form-group">
                    <label>Phone Number</label>
                    <input type="text" name="phone">
                </div>
                <div class="form-group">
                    <label>Mobile Number</label>
                    <input type="text" name="mobile">
                </div>

                <div class="form-group">
                    <label>Current Address 1</label>
                    <input type="text" name="addr1">
                </div>
                <div class="form-group">
                    <label>Current Address 2</label>
                    <input type="text" name="addr2">
                </div>
                <div class="form-group">
                    <label>Current Address 3</label>
                    <input type="text" name="addr3">
                </div>
                <div class="form-group">
                    <label>Email Id</label>
                    <input type="email" name="email">
                </div>
            </div>
        </fieldset>

        <div class="btn-container">
            <input type="submit" value="Save" class="save-btn">
        </div>
    </form>
</div>

<!-- ===== POPUP MESSAGE ===== -->
<%
    String msg = (String) request.getAttribute("msg");
    String msgType = (String) request.getAttribute("msgType");
    if (msg != null) {
%>

<div id="popupOverlay" style="
    position: fixed;
    top:0; left:0;
    width:100%; height:100%;
    background:rgba(0,0,0,0.5);
    display:flex;
    align-items:center;
    justify-content:center;
    z-index:9999;
">

    <div style="
        background:#fff;
        padding:25px 35px;
        border-radius:8px;
        text-align:center;
        min-width:320px;
    ">
        <h3 style="color:<%= "success".equals(msgType) ? "#2E7D32" : "#C62828" %>">
            <%= msg %>
        </h3>

        <button onclick="closePopup()" style="
            margin-top:15px;
            padding:8px 30px;
            background:#3F51B5;
            color:#fff;
            border:none;
            border-radius:4px;
            font-weight:bold;
            cursor:pointer;
        ">
            OK
        </button>
    </div>
</div>

<script>
    function closePopup() {
        document.getElementById("popupOverlay").style.display = "none";
    }
</script>

<%
    }
%>

</body>
</html>
