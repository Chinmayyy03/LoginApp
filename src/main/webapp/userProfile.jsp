<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String loggedInUserId = (String) sess.getAttribute("userId");
    
    // User details variables
    String userId = "";
    String name = "";
    String emailAddress = "";
    String passwordChangedDate = "";
    String currentAddress1 = "";
    String currentAddress2 = "";
    String currentAddress3 = "";
    String phoneNumber = "";
    String mobileNumber = "";
    String customerId = "";
    String employeeCode = "";
    String createdDate = "";
    String modifiedDate = "";
    
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        conn = DBConnection.getConnection();
        
        String sql = "SELECT USER_ID, NAME, EMAILADDRESS, PASSWORD_CHANGED_DATE, " +
                     "CURRENTADDRESS1, CURRENTADDRESS2, CURRENTADDRESS3, " +
                     "PHONE_NUMBER, MOBILE_NUMBER, CUSTOMER_ID, EMPLOYEE_CODE, " +
                     "CREATED_DATE, MODIFIED_DATE " +
                     "FROM ACL.USERREGISTER " +
                     "WHERE USER_ID = ?";
        
        ps = conn.prepareStatement(sql);
        ps.setString(1, loggedInUserId);
        rs = ps.executeQuery();
        
        SimpleDateFormat inputFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        SimpleDateFormat outputFormat = new SimpleDateFormat("dd-MMM-yyyy");
        
        if (rs.next()) {
            userId = rs.getString("USER_ID") != null ? rs.getString("USER_ID") : "";
            name = rs.getString("NAME") != null ? rs.getString("NAME") : "";
            emailAddress = rs.getString("EMAILADDRESS") != null ? rs.getString("EMAILADDRESS") : "";
            
            // Format dates
            Timestamp pwdChanged = rs.getTimestamp("PASSWORD_CHANGED_DATE");
            if (pwdChanged != null) {
                passwordChangedDate = outputFormat.format(pwdChanged);
            }
            
            currentAddress1 = rs.getString("CURRENTADDRESS1") != null ? rs.getString("CURRENTADDRESS1") : "";
            currentAddress2 = rs.getString("CURRENTADDRESS2") != null ? rs.getString("CURRENTADDRESS2") : "";
            currentAddress3 = rs.getString("CURRENTADDRESS3") != null ? rs.getString("CURRENTADDRESS3") : "";
            phoneNumber = rs.getString("PHONE_NUMBER") != null ? rs.getString("PHONE_NUMBER") : "";
            mobileNumber = rs.getString("MOBILE_NUMBER") != null ? rs.getString("MOBILE_NUMBER") : "";
            customerId = rs.getString("CUSTOMER_ID") != null ? rs.getString("CUSTOMER_ID") : "";
            employeeCode = rs.getString("EMPLOYEE_CODE") != null ? rs.getString("EMPLOYEE_CODE") : "";
            
            Timestamp created = rs.getTimestamp("CREATED_DATE");
            if (created != null) {
                createdDate = outputFormat.format(created);
            }
            
            Timestamp modified = rs.getTimestamp("MODIFIED_DATE");
            if (modified != null) {
                modifiedDate = outputFormat.format(modified);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>User Profile</title>
<script src="<%= request.getContextPath() %>/js/breadcrumb-auto.js"></script>

<style>
body {
    font-family: Arial, sans-serif;
    background-color: #e8e4fc;
    margin: 0;
    padding: 0;
    overflow: hidden;
    height: 100vh;
}

.profile-container {
    background-color: #e8e4fc;
    height: 100vh;
    display: flex;
    flex-direction: column;
}

.profile-content {
    flex: 1;
    padding: 20px 30px;
    overflow-y: auto;
}

.profile-content::-webkit-scrollbar {
    width: 8px;
}

.profile-content::-webkit-scrollbar-track {
    background: #e8e4fc;
}

.profile-content::-webkit-scrollbar-thumb {
    background: #c8b7f6;
    border-radius: 4px;
}

.profile-content::-webkit-scrollbar-thumb:hover {
    background: #b89ff0;
}

.section-title {
    font-size: 16px;
    font-weight: 700;
    color: #2b0d73;
    margin: 0 0 15px 0;
    padding-bottom: 8px;
    border-bottom: 2px solid #2b0d73;
}

.info-grid {
    display: grid;
    grid-template-columns: repeat(3 , 1fr);
    gap: 15px;
    margin-bottom: 25px;
}

.info-item {
    background: white;
    padding: 12px 15px;
    border-radius: 4px;
    border-left: 3px solid #2b0d73;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.info-label {
    font-size: 11px;
    font-weight: 600;
    color: #666;
    text-transform: uppercase;
    letter-spacing: 0.3px;
    margin-bottom: 5px;
}

.info-value {
    font-size: 14px;
    font-weight: 600;
    color: #2b0d73;
    word-wrap: break-word;
}

.info-value.empty {
    color: #999;
    font-style: italic;
    font-weight: 400;
}

.address-section {
    background: white;
    padding: 12px 15px;
    border-radius: 4px;
    border-left: 3px solid #2b0d73;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    margin-bottom: 25px;
}

.address-line {
    font-size: 13px;
    color: #2b0d73;
    font-weight: 500;
    margin-bottom: 5px;
    line-height: 1.4;
}

.address-line:last-child {
    margin-bottom: 0;
}

/* Responsive Design */
@media (max-width: 1200px) {
    .info-grid {
        grid-template-columns: 1fr;
        gap: 12px;
    }
}

@media (max-width: 768px) {
    .profile-header {
        padding: 20px 15px;
    }
    
    .profile-header h1 {
        font-size: 22px;
    }
    
    .profile-pic-large {
        width: 80px;
        height: 80px;
    }
    
    .profile-content {
        padding: 15px 20px;
    }
}
</style>

<script>
window.onload = function() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('User Profile');
    }
};
</script>
</head>
<body>

<div class="profile-container">
    <!-- Profile Content -->
    <div class="profile-content">
        
        <!-- Basic Information Section -->
        <div class="section-title">Basic Information</div>
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">User ID</div>
                <div class="info-value"><%= userId.isEmpty() ? "<span class='empty'>Not Available</span>" : userId %></div>
            </div>
            
            <div class="info-item">
                <div class="info-label">Full Name</div>
                <div class="info-value"><%= name.isEmpty() ? "<span class='empty'>Not Available</span>" : name %></div>
            </div>
            
            <div class="info-item">
                <div class="info-label">Email Address</div>
                <div class="info-value"><%= emailAddress.isEmpty() ? "<span class='empty'>Not Available</span>" : emailAddress %></div>
            </div>
            
            <div class="info-item">
                <div class="info-label">Customer ID</div>
                <div class="info-value"><%= customerId.isEmpty() ? "<span class='empty'>Not Available</span>" : customerId %></div>
            </div>
            
            <div class="info-item">
                <div class="info-label">Employee Code</div>
                <div class="info-value"><%= employeeCode.isEmpty() ? "<span class='empty'>Not Available</span>" : employeeCode %></div>
            </div>
            
            <div class="info-item">
                <div class="info-label">Phone Number</div>
                <div class="info-value"><%= phoneNumber.isEmpty() ? "<span class='empty'>Not Available</span>" : phoneNumber %></div>
            </div>
            
            <div class="info-item">
                <div class="info-label">Mobile Number</div>
                <div class="info-value"><%= mobileNumber.isEmpty() ? "<span class='empty'>Not Available</span>" : mobileNumber %></div>
            </div>
        </div>
        
        <!-- Address Section -->
        <div class="section-title">Current Address</div>
        <div class="address-section">
            <% if (currentAddress1.isEmpty() && currentAddress2.isEmpty() && currentAddress3.isEmpty()) { %>
                <div class="address-line empty">Address not available</div>
            <% } else { %>
                <% if (!currentAddress1.isEmpty()) { %>
                    <div class="address-line"><%= currentAddress1 %></div>
                <% } %>
                <% if (!currentAddress2.isEmpty()) { %>
                    <div class="address-line"><%= currentAddress2 %></div>
                <% } %>
                <% if (!currentAddress3.isEmpty()) { %>
                    <div class="address-line"><%= currentAddress3 %></div>
                <% } %>
            <% } %>
        </div>
        
        <!-- Account Dates Section -->
        <div class="section-title">Account Information</div>
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">Password Last Changed</div>
                <div class="info-value"><%= passwordChangedDate.isEmpty() ? "<span class='empty'>Never Changed</span>" : passwordChangedDate %></div>
            </div>
            
            <div class="info-item">
                <div class="info-label">Account Created</div>
                <div class="info-value"><%= createdDate.isEmpty() ? "<span class='empty'>Not Available</span>" : createdDate %></div>
            </div>
            
            <div class="info-item">
                <div class="info-label">Last Modified</div>
                <div class="info-value"><%= modifiedDate.isEmpty() ? "<span class='empty'>Not Available</span>" : modifiedDate %></div>
            </div>
        </div>
        
    </div>
</div>

</body>
</html>
