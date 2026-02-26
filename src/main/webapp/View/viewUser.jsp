<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, db.DBConnection" %>

<%
String sessionBranchCode = (String) session.getAttribute("branchCode");
if (sessionBranchCode == null || sessionBranchCode.isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

String userId = request.getParameter("userId");
if (userId == null || userId.trim().isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/View/allUsers.jsp");
    return;
}

String saveMsg = "";
String saveErr = "";

// ── SAVE POST ─────────────────────────────────────────────────────────────────
if ("POST".equals(request.getMethod())) {
    String newName   = request.getParameter("name")   != null ? request.getParameter("name").trim()   : "";
    String newEmail  = request.getParameter("email")  != null ? request.getParameter("email").trim()  : "";
    String newMobile = request.getParameter("mobile") != null ? request.getParameter("mobile").trim() : "";
    String newPhone  = request.getParameter("phone")  != null ? request.getParameter("phone").trim()  : "";
    String newAddr1  = request.getParameter("addr1")  != null ? request.getParameter("addr1").trim()  : "";
    String newAddr2  = request.getParameter("addr2")  != null ? request.getParameter("addr2").trim()  : "";
    String newAddr3  = request.getParameter("addr3")  != null ? request.getParameter("addr3").trim()  : "";
    String[] selectedRoles = request.getParameterValues("selectedRoles");

    Connection ct = null;
    try {
        ct = DBConnection.getConnection();
        ct.setAutoCommit(false); // START TRANSACTION

        // 1. Update user fields
        PreparedStatement ps1 = ct.prepareStatement(
            "UPDATE ACL.USERREGISTER SET NAME=?, EMAILADDRESS=?, MOBILE_NUMBER=?, " +
            "PHONE_NUMBER=?, CURRENTADDRESS1=?, CURRENTADDRESS2=?, CURRENTADDRESS3=? " +
            "WHERE USER_ID=?"
        );
        ps1.setString(1, newName);
        ps1.setString(2, newEmail);
        ps1.setString(3, newMobile);
        ps1.setString(4, newPhone);
        ps1.setString(5, newAddr1);
        ps1.setString(6, newAddr2);
        ps1.setString(7, newAddr3);
        ps1.setString(8, userId.trim());
        ps1.executeUpdate();
        ps1.close();

        // 2. Delete all existing roles for this user
        PreparedStatement ps2 = ct.prepareStatement(
            "DELETE FROM ACL.USERMAINROLE WHERE USER_ID = ?"
        );
        ps2.setString(1, userId.trim());
        ps2.executeUpdate();
        ps2.close();

        // 3. Insert new roles
        if (selectedRoles != null && selectedRoles.length > 0) {
            for (String roleName : selectedRoles) {
                if (roleName == null || roleName.trim().isEmpty()) continue;
                // Get MAINROLE_ID from MAINROLEREGISTER
                PreparedStatement psRid = ct.prepareStatement(
                    "SELECT MAINROLE_ID FROM ACL.MAINROLEREGISTER WHERE MAINROLE = ?"
                );
                psRid.setString(1, roleName.trim());
                ResultSet rsRid = psRid.executeQuery();
                if (rsRid.next()) {
                    String mainRoleId = rsRid.getString("MAINROLE_ID");
                    PreparedStatement psIns = ct.prepareStatement(
                        "INSERT INTO ACL.USERMAINROLE (USER_ID, MAINROLE_ID) VALUES (?, ?)"
                    );
                    psIns.setString(1, userId.trim());
                    psIns.setString(2, mainRoleId);
                    psIns.executeUpdate();
                    psIns.close();
                }
                rsRid.close();
                psRid.close();
            }
        }

        ct.commit(); // COMMIT TRANSACTION
        saveMsg = "User updated successfully!";

    } catch (Exception e) {
        if (ct != null) { try { ct.rollback(); } catch (Exception ignored) {} }
        saveErr = "Update failed: " + e.getMessage();
    } finally {
        if (ct != null) { try { ct.setAutoCommit(true); ct.close(); } catch (Exception ignored) {} }
    }
}

// ── FETCH USER ────────────────────────────────────────────────────────────────
String dbUserId     = "";
String dbName       = "";
String dbBranchCode = "";
String dbEmail      = "";
String dbMobile     = "";
String dbPhone      = "";
String dbCustId     = "";
String dbEmpCode    = "";
String dbAddr1      = "";
String dbAddr2      = "";
String dbAddr3      = "";

Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
try {
    conn = DBConnection.getConnection();
    if (conn != null) {
        pstmt = conn.prepareStatement(
            "SELECT USER_ID, NAME, BRANCH_CODE, EMAILADDRESS, MOBILE_NUMBER, PHONE_NUMBER, " +
            "CUSTOMER_ID, EMPLOYEE_CODE, CURRENTADDRESS1, CURRENTADDRESS2, CURRENTADDRESS3 " +
            "FROM ACL.USERREGISTER WHERE USER_ID = ?"
        );
        pstmt.setString(1, userId.trim());
        rs = pstmt.executeQuery();
        if (rs.next()) {
            dbUserId     = rs.getString("USER_ID")         != null ? rs.getString("USER_ID")         : "";
            dbName       = rs.getString("NAME")            != null ? rs.getString("NAME")            : "";
            dbBranchCode = rs.getString("BRANCH_CODE")     != null ? rs.getString("BRANCH_CODE")     : "";
            dbEmail      = rs.getString("EMAILADDRESS")    != null ? rs.getString("EMAILADDRESS")    : "";
            dbMobile     = rs.getString("MOBILE_NUMBER")   != null ? rs.getString("MOBILE_NUMBER")   : "";
            dbPhone      = rs.getString("PHONE_NUMBER")    != null ? rs.getString("PHONE_NUMBER")    : "";
            dbCustId     = rs.getString("CUSTOMER_ID")     != null ? rs.getString("CUSTOMER_ID")     : "";
            dbEmpCode    = rs.getString("EMPLOYEE_CODE")   != null ? rs.getString("EMPLOYEE_CODE")   : "";
            dbAddr1      = rs.getString("CURRENTADDRESS1") != null ? rs.getString("CURRENTADDRESS1") : "";
            dbAddr2      = rs.getString("CURRENTADDRESS2") != null ? rs.getString("CURRENTADDRESS2") : "";
            dbAddr3      = rs.getString("CURRENTADDRESS3") != null ? rs.getString("CURRENTADDRESS3") : "";
        }
    }
} catch (Exception e) {
} finally {
    try { if (rs != null) rs.close(); } catch (Exception ignored) {}
    try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
    try { if (conn != null) conn.close(); } catch (Exception ignored) {}
}

// ── FETCH BRANCH NAME ─────────────────────────────────────────────────────────
String dbBranchName = "";
if (!dbBranchCode.isEmpty()) {
    Connection c = null; PreparedStatement p = null; ResultSet r = null;
    try {
        c = DBConnection.getConnection();
        p = c.prepareStatement("SELECT NAME FROM HEADOFFICE.BRANCH WHERE BRANCH_CODE = ?");
        p.setString(1, dbBranchCode);
        r = p.executeQuery();
        if (r.next()) dbBranchName = r.getString("NAME") != null ? r.getString("NAME") : "";
    } catch (Exception e) {
    } finally {
        try { if (r != null) r.close(); } catch (Exception ignored) {}
        try { if (p != null) p.close(); } catch (Exception ignored) {}
        try { if (c != null) c.close(); } catch (Exception ignored) {}
    }
}

// ── FETCH CUSTOMER NAME ───────────────────────────────────────────────────────
String dbCustName = "";
if (!dbCustId.isEmpty()) {
    Connection c = null; PreparedStatement p = null; ResultSet r = null;
    try {
        c = DBConnection.getConnection();
        p = c.prepareStatement("SELECT NAME FROM HEADOFFICE.CUSTOMER WHERE CUST_ID = ?");
        p.setString(1, dbCustId);
        r = p.executeQuery();
        if (r.next()) dbCustName = r.getString("NAME") != null ? r.getString("NAME") : "";
    } catch (Exception e) {
    } finally {
        try { if (r != null) r.close(); } catch (Exception ignored) {}
        try { if (p != null) p.close(); } catch (Exception ignored) {}
        try { if (c != null) c.close(); } catch (Exception ignored) {}
    }
}

// ── FETCH ASSIGNED ROLES ──────────────────────────────────────────────────────
java.util.List<String> userRoles = new java.util.ArrayList<>();
Connection cr = null; PreparedStatement pr = null; ResultSet rr = null;
try {
    cr = DBConnection.getConnection();
    if (cr != null) {
        pr = cr.prepareStatement(
            "SELECT M.MAINROLE FROM ACL.USERMAINROLE UR " +
            "JOIN ACL.MAINROLEREGISTER M ON UR.MAINROLE_ID = M.MAINROLE_ID " +
            "WHERE UR.USER_ID = ? ORDER BY M.MAINROLE"
        );
        pr.setString(1, userId.trim());
        rr = pr.executeQuery();
        while (rr.next()) { String role = rr.getString("MAINROLE"); if (role != null) userRoles.add(role); }
    }
} catch (Exception e) {
} finally {
    try { if (rr != null) rr.close(); } catch (Exception ignored) {}
    try { if (pr != null) pr.close(); } catch (Exception ignored) {}
    try { if (cr != null) cr.close(); } catch (Exception ignored) {}
}

// ── FETCH ALL AVAILABLE ROLES ─────────────────────────────────────────────────
java.util.List<String> allRoles = new java.util.ArrayList<>();
Connection car = null; PreparedStatement par = null; ResultSet rar = null;
try {
    car = DBConnection.getConnection();
    if (car != null) {
        par = car.prepareStatement("SELECT MAINROLE FROM ACL.MAINROLEREGISTER ORDER BY MAINROLE");
        rar = par.executeQuery();
        while (rar.next()) { String role = rar.getString("MAINROLE"); if (role != null) allRoles.add(role); }
    }
} catch (Exception e) {
} finally {
    try { if (rar != null) rar.close(); } catch (Exception ignored) {}
    try { if (par != null) par.close(); } catch (Exception ignored) {}
    try { if (car != null) car.close(); } catch (Exception ignored) {}
}

String mode = request.getParameter("mode") != null ? request.getParameter("mode") : "view";
if ("POST".equals(request.getMethod()) && saveErr.isEmpty()) mode = "view";
boolean isMaintenance = "maintenance".equals(mode);

java.util.function.Function<String, String> esc = s ->
    s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>User Details - <%=esc.apply(dbUserId)%></title>
    <style>
        :root { --bg: #E6E6FA; --navy: #2b0d73; --border: #B8B8E6; --ro-bg: #E0E0E0; --edit-bg: #fff; }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background: var(--bg); padding: 20px 20px 60px; }
        .container { max-width: 1400px; margin: auto; }
        h2 { text-align: center; color: var(--navy); font-size: 22px; font-weight: bold; margin-bottom: 6px; }

        fieldset { border: 1.5px solid var(--border); border-radius: 8px; margin-bottom: 22px; padding: 18px; }
        legend { color: var(--navy); font-weight: bold; font-size: 15px; padding: 0 10px; background: var(--bg); }

        .grid-4 { display: grid; grid-template-columns: repeat(4,1fr); gap: 15px; align-items: end; }
        .grid-5 { display: grid; grid-template-columns: repeat(5,1fr); gap: 15px; margin-bottom: 15px; align-items: end; }
        .form-group { width: 100%; }
        .form-group label { display: block; font-size: 13px; font-weight: bold; color: var(--navy); margin-bottom: 4px; }
        .form-group input {
            width: 100%; padding: 7px; border: 1px solid var(--border);
            border-radius: 4px; font-size: 13px; color: #444;
            background: var(--ro-bg); box-sizing: border-box;
        }
        .form-group input.editable { background: var(--edit-bg); border-color: var(--navy); }
        .form-group input.editable:focus { outline: none; box-shadow: 0 0 0 2px rgba(43,13,115,0.2); }

        /* Roles */
        .roles-label { font-size: 13px; font-weight: bold; color: var(--navy); margin-bottom: 10px; display: block; }
        .roles-wrap { display: flex; flex-wrap: wrap; gap: 8px; min-height: 36px; align-items: center; }

        .role-tag {
            display: inline-flex; align-items: center; gap: 7px;
            background: #eef0fb; color: var(--navy);
            font-size: 12px; font-weight: bold;
            padding: 6px 10px 6px 14px; border-radius: 20px; border: 1px solid #c5caee;
        }
        .role-tag.view-tag { padding: 6px 14px; }
        .x-btn {
            width: 18px; height: 18px; background: var(--navy); color: white;
            border: none; border-radius: 50%; font-size: 10px; font-weight: bold;
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            transition: background 0.2s; flex-shrink: 0;
        }
        .x-btn:hover { background: #c0392b; }
        .no-roles { font-size: 13px; color: #999; font-style: italic; }

        .roles-divider { border: none; border-top: 1px dashed var(--border); margin: 14px 0; }

        /* Checkbox dropdown */
        .custom-select-wrapper { position: relative; width: 260px; }
        .custom-select-trigger {
            height: 34px; padding: 0 12px;
            border: 1.5px solid var(--border); border-radius: 4px;
            font-size: 13px; color: #444; background: #fff;
            cursor: pointer; display: flex; align-items: center;
            justify-content: space-between; user-select: none;
        }
        .custom-select-trigger:hover { border-color: var(--navy); }
        .custom-select-trigger .arrow { font-size: 10px; color: #888; }
        .checkbox-dropdown {
            display: none; position: absolute; top: 38px; left: 0;
            background: #fff; border: 1.5px solid var(--border);
            border-radius: 6px; box-shadow: 0 6px 20px rgba(0,0,0,0.15);
            z-index: 999; width: 520px; padding: 14px 14px 0 14px;
        }
        .checkbox-dropdown.open { display: block; }
        .checkbox-grid {
            display: grid; grid-template-columns: repeat(3,1fr); gap: 8px;
            max-height: 300px; overflow-y: auto; padding-bottom: 4px;
        }
        .checkbox-item {
            display: flex; align-items: center; gap: 8px;
            padding: 8px 10px; border: 1px solid var(--border);
            border-radius: 5px; cursor: pointer; font-size: 12px;
            font-weight: bold; color: var(--navy);
            transition: background 0.15s;
        }
        .checkbox-item:hover { background: #f0f0ff; }
        .checkbox-item input[type=checkbox] { accent-color: var(--navy); width: 14px; height: 14px; cursor: pointer; flex-shrink:0; }
        .checkbox-item.checked { background: #eef0fb; border-color: var(--navy); }
        .dropdown-footer {
            display: flex; justify-content: space-between; align-items: center;
            padding: 10px 0; border-top: 1px solid var(--border); margin-top: 10px;
        }
        .btn-clear-all {
            background: none; border: none; color: #888; font-size: 13px;
            cursor: pointer; font-family: Arial, sans-serif;
        }
        .btn-clear-all:hover { color: #c0392b; }
        .btn-done {
            background: var(--navy); color: white; border: none;
            border-radius: 4px; padding: 6px 22px; font-size: 13px;
            font-weight: bold; cursor: pointer;
        }
        .btn-done:hover { background: #1E2870; }

        /* Buttons */
        .btn-row { display: flex; justify-content: center; gap: 14px; margin-top: 20px; }
        .btn-back { padding: 10px 34px; background: var(--navy); color: white; border: none; border-radius: 5px; font-size: 15px; font-weight: bold; cursor: pointer; }
        .btn-back:hover { background: #1E2870; }
        .btn-maintenance { padding: 10px 34px; background: #e65c00; color: white; border: none; border-radius: 5px; font-size: 15px; font-weight: bold; cursor: pointer; }
        .btn-maintenance:hover { background: #c74f00; }
        .btn-save { padding: 10px 34px; background: #1a6b30; color: white; border: none; border-radius: 5px; font-size: 15px; font-weight: bold; cursor: pointer; }
        .btn-save:hover { background: #145526; }
        .btn-cancel { padding: 10px 34px; background: #888; color: white; border: none; border-radius: 5px; font-size: 15px; font-weight: bold; cursor: pointer; }
        .btn-cancel:hover { background: #666; }


        .alert-success { background: #d4edda; color: #1a6b30; border: 1px solid #b0ddb8; border-radius: 5px; padding: 10px 18px; margin-bottom: 16px; text-align: center; font-weight: bold; font-size: 14px; }
        .alert-error   { background: #f8d7da; color: #842029; border: 1px solid #f1aeb5; border-radius: 5px; padding: 10px 18px; margin-bottom: 16px; text-align: center; font-weight: bold; font-size: 14px; }
    </style>
</head>
<body>
<div class="container">

    <h2><% if(isMaintenance){ %>Re-Enter User Details<% } else { %>User Details<% } %></h2>

    <% if (!saveMsg.isEmpty()) { %><div class="alert-success"><%=saveMsg%></div><% } %>
    <% if (!saveErr.isEmpty()) { %><div class="alert-error"><%=saveErr%></div><% } %>


    <form method="post" action="?userId=<%=esc.apply(dbUserId)%>&mode=<%=mode%>">

        <!-- Hidden selected roles (populated by JS before submit) -->
        <div id="hiddenRolesContainer"></div>

        <!-- User Details -->
        <fieldset>
            <legend>User Details</legend>
            <div class="grid-4">
                <div class="form-group">
                    <label>User Id</label>
                    <input type="text" value="<%=esc.apply(dbUserId)%>" readonly>
                </div>
                <div class="form-group">
                    <label>User Name</label>
                    <input type="text" name="name" value="<%=esc.apply(dbName)%>" <%=isMaintenance ? "class=\"editable\"" : "readonly"%>>
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

        <!-- Address Details -->
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
                    <input type="text" name="phone" value="<%=esc.apply(dbPhone)%>" <%=isMaintenance ? "class=\"editable\"" : "readonly"%>>
                </div>
                <div class="form-group">
                    <label>Mobile</label>
                    <input type="text" name="mobile" value="<%=esc.apply(dbMobile)%>" <%=isMaintenance ? "class=\"editable\"" : "readonly"%>>
                </div>
            </div>
            <div class="grid-4">
                <div class="form-group">
                    <label>Address 1</label>
                    <input type="text" name="addr1" value="<%=esc.apply(dbAddr1)%>" <%=isMaintenance ? "class=\"editable\"" : "readonly"%>>
                </div>
                <div class="form-group">
                    <label>Address 2</label>
                    <input type="text" name="addr2" value="<%=esc.apply(dbAddr2)%>" <%=isMaintenance ? "class=\"editable\"" : "readonly"%>>
                </div>
                <div class="form-group">
                    <label>Address 3</label>
                    <input type="text" name="addr3" value="<%=esc.apply(dbAddr3)%>" <%=isMaintenance ? "class=\"editable\"" : "readonly"%>>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="text" name="email" value="<%=esc.apply(dbEmail)%>" <%=isMaintenance ? "class=\"editable\"" : "readonly"%>>
                </div>
            </div>
        </fieldset>

        <!-- User Roles -->
        <fieldset>
            <legend>User Roles</legend>
            <span class="roles-label">Assigned Roles</span>

            <% if (!isMaintenance) { %>
            <!-- VIEW MODE: plain tags -->
            <div class="roles-wrap">
                <% if (userRoles.isEmpty()) { %>
                <span class="no-roles">No roles assigned</span>
                <% } else { for (String role : userRoles) { %>
                <span class="role-tag view-tag"><%=esc.apply(role)%></span>
                <% } } %>
            </div>

            <% } else { %>
            <!-- MAINTENANCE MODE: removable tags + add dropdown -->
            <div class="roles-wrap" id="rolesWrap">
                <% if (userRoles.isEmpty()) { %>
                <span class="no-roles" id="noRolesMsg">No roles assigned</span>
                <% } else { for (String role : userRoles) { %>
                <span class="role-tag" data-role="<%=esc.apply(role)%>">
                    <%=esc.apply(role)%>
                    <button type="button" class="x-btn" onclick="removeRole(this,'<%=esc.apply(role)%>')">✕</button>
                </span>
                <% } } %>
            </div>

            <hr class="roles-divider">

            <div style="display:flex; align-items:center; gap:10px;">
                <label style="font-size:13px;font-weight:bold;color:var(--navy);white-space:nowrap;">Select Roles <span style="color:#c0392b;">*</span></label>
                <div class="custom-select-wrapper">
                    <div class="custom-select-trigger" id="dropdownTrigger" onclick="toggleDropdown()">
                        <span>-- Click to view roles --</span>
                        <span class="arrow">&#9650;</span>
                    </div>
                    <div class="checkbox-dropdown" id="checkboxDropdown">
                        <div class="checkbox-grid" id="checkboxGrid">
                            <%
                            for (String ar : allRoles) {
                                boolean isAssigned = userRoles.contains(ar);
                            %>
                            <label class="checkbox-item <%=isAssigned ? "checked" : ""%>" id="item_<%=esc.apply(ar).replace(" ","_")%>">
                                <input type="checkbox" value="<%=esc.apply(ar)%>"
                                    <%=isAssigned ? "checked" : ""%>
                                    onchange="handleRoleCheck(this,'<%=esc.apply(ar)%>')">
                                <%=esc.apply(ar)%>
                            </label>
                            <% } %>
                        </div>
                        <div class="dropdown-footer">
                            <button type="button" class="btn-clear-all" onclick="clearAllRoles()">Clear all</button>
                            <button type="button" class="btn-done" onclick="toggleDropdown()">Done</button>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
        </fieldset>

        <!-- Buttons -->
        <div class="btn-row">
            <% if (!isMaintenance) { %>
            <button type="button" class="btn-back" onclick="goBack()">&#8592; Back to List</button>
            <button type="button" class="btn-maintenance" onclick="goMaintenance()">&#9998; Maintenance</button>
            <% } else { %>
            <button type="submit" class="btn-save" onclick="prepareRoles()">&#10003; Save</button>
            <button type="button" class="btn-cancel" onclick="cancelMaintenance()">&#10005; Cancel</button>
            <% } %>
        </div>

    </form>
</div>

<script>
    // ── Role editing ────────────────────────────────────────────────────────
    function removeRole(btn, roleName) {
        btn.closest('.role-tag').remove();
        // Add back to dropdown
        var sel = document.getElementById('roleSelect');
        if (sel) {
            var opt = document.createElement('option');
            opt.value = roleName;
            opt.textContent = roleName;
            sel.appendChild(opt);
        }
        checkEmpty();
    }

    function addRole() {
        var sel = document.getElementById('roleSelect');
        var val = sel.value;
        if (!val) return;
        var wrap = document.getElementById('rolesWrap');
        // Remove no-roles message if present
        var noMsg = document.getElementById('noRolesMsg');
        if (noMsg) noMsg.remove();
        // Add tag
        var span = document.createElement('span');
        span.className = 'role-tag';
        span.setAttribute('data-role', val);
        span.innerHTML = val + ' <button type="button" class="x-btn" onclick="removeRole(this,\'' + val.replace(/'/g,"\\'") + '\')">✕</button>';
        wrap.appendChild(span);
        // Remove from dropdown
        sel.options[sel.selectedIndex].remove();
        sel.value = '';
    }

    function checkEmpty() {
        var wrap = document.getElementById('rolesWrap');
        if (!wrap) return;
        var tags = wrap.querySelectorAll('.role-tag');
        var noMsg = document.getElementById('noRolesMsg');
        if (tags.length === 0 && !noMsg) {
            var span = document.createElement('span');
            span.className = 'no-roles';
            span.id = 'noRolesMsg';
            span.textContent = 'No roles assigned';
            wrap.appendChild(span);
        }
    }

    // Before form submit - collect all role tags into hidden inputs
    function prepareRoles() {
        var container = document.getElementById('hiddenRolesContainer');
        container.innerHTML = '';
        var tags = document.querySelectorAll('#rolesWrap .role-tag');
        tags.forEach(function(tag) {
            var role = tag.getAttribute('data-role');
            if (role) {
                var input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'selectedRoles';
                input.value = role;
                container.appendChild(input);
            }
        });
    }

    // ── Navigation ──────────────────────────────────────────────────────────
    function goBack() {
        try {
            if (window.parent && window.parent.updateParentBreadcrumb) {
                window.parent.updateParentBreadcrumb('View > Users');
            }
        } catch(e) {}
        window.location.href = '<%=request.getContextPath()%>/View/allUsers.jsp';
    }

    function goMaintenance() {
        try {
            if (window.parent && window.parent.updateParentBreadcrumb) {
                window.parent.updateParentBreadcrumb('View > Users > User Maintenance');
            }
        } catch(e) {}
        window.location.href = '?userId=<%=esc.apply(dbUserId)%>&mode=maintenance';
    }

    function cancelMaintenance() {
        try {
            if (window.parent && window.parent.updateParentBreadcrumb) {
                window.parent.updateParentBreadcrumb('View > Users');
            }
        } catch(e) {}
        window.location.href = '?userId=<%=esc.apply(dbUserId)%>&mode=view';
    }
</script>
</body>
</html>
