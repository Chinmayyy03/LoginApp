<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, db.DBConnection" %>

<%
// ─────────────────────────────────────────────
// Session validation
// ─────────────────────────────────────────────
String sessionBranchCode = (String) session.getAttribute("branchCode");
if (sessionBranchCode == null || sessionBranchCode.isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

String userId = request.getParameter("userId");
if (userId == null || userId.trim().isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/Utility/TotalUsers.jsp");
    return;
}

// ─────────────────────────────────────────────
// Fetch user from ACL.USERREGISTER
// ─────────────────────────────────────────────
String dbUserId   = "";
String dbName     = "";
String dbBranchCode = "";
String dbEmail    = "";
String dbMobile   = "";
String dbPhone    = "";
String dbCustId   = "";
String dbEmpCode  = "";
String dbAddr1    = "";
String dbAddr2    = "";
String dbAddr3    = "";

Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
try {
    conn = DBConnection.getConnection();
    if (conn != null) {
        String sql =
            "SELECT USER_ID, NAME, BRANCH_CODE, EMAILADDRESS, " +
            "MOBILE_NUMBER, PHONE_NUMBER, CUSTOMER_ID, EMPLOYEE_CODE, " +
            "CURRENTADDRESS1, CURRENTADDRESS2, CURRENTADDRESS3 " +
            "FROM ACL.USERREGISTER WHERE USER_ID = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId.trim());
        rs = pstmt.executeQuery();
        if (rs.next()) {
            dbUserId    = rs.getString("USER_ID")         != null ? rs.getString("USER_ID")         : "";
            dbName      = rs.getString("NAME")            != null ? rs.getString("NAME")            : "";
            dbBranchCode= rs.getString("BRANCH_CODE")     != null ? rs.getString("BRANCH_CODE")     : "";
            dbEmail     = rs.getString("EMAILADDRESS")    != null ? rs.getString("EMAILADDRESS")    : "";
            dbMobile    = rs.getString("MOBILE_NUMBER")   != null ? rs.getString("MOBILE_NUMBER")   : "";
            dbPhone     = rs.getString("PHONE_NUMBER")    != null ? rs.getString("PHONE_NUMBER")    : "";
            dbCustId    = rs.getString("CUSTOMER_ID")     != null ? rs.getString("CUSTOMER_ID")     : "";
            dbEmpCode   = rs.getString("EMPLOYEE_CODE")   != null ? rs.getString("EMPLOYEE_CODE")   : "";
            dbAddr1     = rs.getString("CURRENTADDRESS1") != null ? rs.getString("CURRENTADDRESS1") : "";
            dbAddr2     = rs.getString("CURRENTADDRESS2") != null ? rs.getString("CURRENTADDRESS2") : "";
            dbAddr3     = rs.getString("CURRENTADDRESS3") != null ? rs.getString("CURRENTADDRESS3") : "";
        }
    }
} catch (Exception e) {
} finally {
    try { if (rs    != null) rs.close();    } catch (Exception ignored) {}
    try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
    try { if (conn  != null) conn.close();  } catch (Exception ignored) {}
}

// ─────────────────────────────────────────────
// Fetch branch name
// ─────────────────────────────────────────────
String dbBranchName = "";
if (!dbBranchCode.isEmpty()) {
    Connection c = null; PreparedStatement p = null; ResultSet r = null;
    try {
        c = DBConnection.getConnection();
        if (c != null) {
            p = c.prepareStatement("SELECT NAME FROM HEADOFFICE.BRANCH WHERE BRANCH_CODE = ?");
            p.setString(1, dbBranchCode);
            r = p.executeQuery();
            if (r.next()) dbBranchName = r.getString("NAME") != null ? r.getString("NAME") : "";
        }
    } catch (Exception e) {
    } finally {
        try { if (r != null) r.close(); } catch (Exception ignored) {}
        try { if (p != null) p.close(); } catch (Exception ignored) {}
        try { if (c != null) c.close(); } catch (Exception ignored) {}
    }
}

// ─────────────────────────────────────────────
// Fetch customer name
// ─────────────────────────────────────────────
String dbCustName = "";
if (!dbCustId.isEmpty()) {
    Connection c = null; PreparedStatement p = null; ResultSet r = null;
    try {
        c = DBConnection.getConnection();
        if (c != null) {
            p = c.prepareStatement("SELECT NAME FROM HEADOFFICE.CUSTOMER WHERE CUST_ID = ?");
            p.setString(1, dbCustId);
            r = p.executeQuery();
            if (r.next()) dbCustName = r.getString("NAME") != null ? r.getString("NAME") : "";
        }
    } catch (Exception e) {
    } finally {
        try { if (r != null) r.close(); } catch (Exception ignored) {}
        try { if (p != null) p.close(); } catch (Exception ignored) {}
        try { if (c != null) c.close(); } catch (Exception ignored) {}
    }
}

// ─────────────────────────────────────────────
// Fetch assigned roles
// ─────────────────────────────────────────────
java.util.List<String> userRoles = new java.util.ArrayList<>();
Connection cr = null; PreparedStatement pr = null; ResultSet rr = null;
try {
    cr = DBConnection.getConnection();
    if (cr != null) {
        String sqlR =
            "SELECT M.MAINROLE FROM ACL.USERMAINROLE UR " +
            "JOIN ACL.MAINROLEREGISTER M ON UR.MAINROLE_ID = M.MAINROLE_ID " +
            "WHERE UR.USER_ID = ? ORDER BY M.MAINROLE";
        pr = cr.prepareStatement(sqlR);
        pr.setString(1, userId.trim());
        rr = pr.executeQuery();
        while (rr.next()) {
            String role = rr.getString("MAINROLE");
            if (role != null) userRoles.add(role);
        }
    }
} catch (Exception e) {
} finally {
    try { if (rr != null) rr.close(); } catch (Exception ignored) {}
    try { if (pr != null) pr.close(); } catch (Exception ignored) {}
    try { if (cr != null) cr.close(); } catch (Exception ignored) {}
}

// HTML escape helper
java.util.function.Function<String, String> esc = s ->
    s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>User Details - <%=esc.apply(dbUserId)%></title>
    <style>
        :root {
            --bg-lavender:  #E6E6FA;
            --navy-blue:    #2b0d73;
            --navy-dark:    #1a237e;
            --border-color: #B8B8E6;
            --readonly-bg:  #E0E0E0;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: Arial, sans-serif;
            background-color: var(--bg-lavender);
            padding: 20px 20px 60px 20px;
        }

        .container { max-width: 1400px; margin: auto; }

        h2 {
            text-align: center;
            color: #2b0d73;
            font-size: 22px;
            font-weight: bold;
            margin-bottom: 25px;
        }

        fieldset {
            border: 1.5px solid var(--border-color);
            border-radius: 8px;
            margin-bottom: 22px;
            padding: 18px;
        }

        legend {
            color: #2b0d73;
            font-weight: bold;
            font-size: 15px;
            padding: 0 10px;
            background-color: var(--bg-lavender);
        }

        .grid-4 {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            align-items: end;
        }

        .grid-5 {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 15px;
            margin-bottom: 15px;
            align-items: end;
        }

        .form-group { width: 100%; }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: bold;
            color: var(--navy-blue);
            margin-bottom: 4px;
        }

        .form-group input {
            width: 100%;
            padding: 7px;
            border: 1px solid var(--border-color);
            border-radius: 4px;
            font-size: 13px;
            background-color: var(--readonly-bg);
            color: #444;
            box-sizing: border-box;
        }

        /* ── Roles ── */
        .roles-display {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            padding: 10px 0 4px 0;
            min-height: 38px;
        }

        .role-tag {
            display: inline-flex;
            align-items: center;
            background-color: #eef0fb;
            color: var(--navy-blue);
            font-size: 12px;
            font-weight: bold;
            padding: 5px 14px;
            border-radius: 12px;
            border: 1px solid #c5caee;
        }

        .no-roles {
            font-size: 13px;
            color: #999;
            font-style: italic;
            padding: 6px 0;
        }

        /* ── Back button ── */
        .btn-back {
            padding: 10px 40px;
            background-color: #2b0d73;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 15px;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.2s;
            text-decoration: none;
            display: inline-block;
        }
        .btn-back:hover { background-color: #2b0d73; }
        .btn-row { text-align: center; margin-top: 20px; }
    </style>
</head>
<body>
<div class="container">

    <h2>User Details</h2>

    <!-- ── User Details ── -->
    <fieldset>
        <legend>User Details</legend>
        <div class="grid-4">
            <div class="form-group">
                <label>User Id</label>
                <input type="text" value="<%=esc.apply(dbUserId)%>" readonly>
            </div>
            <div class="form-group">
                <label>User Name</label>
                <input type="text" value="<%=esc.apply(dbName)%>" readonly>
            </div>
            <div class="form-group">
                <label>Branch Code</label>
                <input type="text" value="<%=esc.apply(dbBranchCode)%>" readonly>
            </div>
            <div class="form-group">
                <label>Branch Name</label>
                <input type="text" value="<%=esc.apply(dbBranchName)%>" readonly>
            </div>
        </div>
    </fieldset>

    <!-- ── Address Details ── -->
    <fieldset>
        <legend>Address Details</legend>
        <div class="grid-5">
            <div class="form-group">
                <label>Customer ID</label>
                <input type="text" value="<%=esc.apply(dbCustId)%>" readonly>
            </div>
            <div class="form-group">
                <label>Customer Name</label>
                <input type="text" value="<%=esc.apply(dbCustName)%>" readonly>
            </div>
            <div class="form-group">
                <label>Employee Code</label>
                <input type="text" value="<%=esc.apply(dbEmpCode)%>" readonly>
            </div>
            <div class="form-group">
                <label>Phone</label>
                <input type="text" value="<%=esc.apply(dbPhone)%>" readonly>
            </div>
            <div class="form-group">
                <label>Mobile</label>
                <input type="text" value="<%=esc.apply(dbMobile)%>" readonly>
            </div>
        </div>
        <div class="grid-4">
            <div class="form-group">
                <label>Address 1</label>
                <input type="text" value="<%=esc.apply(dbAddr1)%>" readonly>
            </div>
            <div class="form-group">
                <label>Address 2</label>
                <input type="text" value="<%=esc.apply(dbAddr2)%>" readonly>
            </div>
            <div class="form-group">
                <label>Address 3</label>
                <input type="text" value="<%=esc.apply(dbAddr3)%>" readonly>
            </div>
            <div class="form-group">
                <label>Email</label>
                <input type="text" value="<%=esc.apply(dbEmail)%>" readonly>
            </div>
        </div>
    </fieldset>

    <!-- ── User Roles ── -->
    <fieldset>
        <legend>User Roles</legend>
        <div class="form-group">
            <label>Assigned Roles</label>
            <div class="roles-display">
                <%
                if (userRoles.isEmpty()) {
                %>
                <span class="no-roles">No roles assigned</span>
                <%
                } else {
                    for (String role : userRoles) {
                %>
                <span class="role-tag"><%=esc.apply(role)%></span>
                <%
                    }
                }
                %>
            </div>
        </div>
    </fieldset>

    <!-- ── Back to List ── -->
    <div class="btn-row">
        <a href="<%=request.getContextPath()%>/Utility/TotalUsers.jsp" class="btn-back">
            &#8592; Back to List
        </a>
    </div>

</div>
</body>
</html>
