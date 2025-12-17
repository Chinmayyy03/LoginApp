<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }
	int totalPendingApplications = 0;
    int totalCustomers = 0;
    int totalPendingCustomers = 0;
    double totalLoan = 0; // static for now

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM CUSTOMERS WHERE BRANCH_CODE=? AND STATUS = 'A' ")) {
        ps.setString(1, branchCode);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            totalCustomers = rs.getInt(1);
        }
    } catch (Exception e) {
        totalCustomers = 0;
    }
    try (Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM CUSTOMERS WHERE BRANCH_CODE=? AND STATUS = 'P' ")) {
           ps.setString(1, branchCode);
           ResultSet rs = ps.executeQuery();
           if (rs.next()) {
               totalPendingCustomers = rs.getInt(1);
           }
       } catch (Exception e) {
           totalPendingCustomers = 0;
       }
    
 // Count total pending applications (STATUS = 'E')
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM APPLICATION.APPLICATION WHERE BRANCH_CODE=? AND STATUS = 'E'")) {
        ps.setString(1, branchCode);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            totalPendingApplications = rs.getInt(1);
        }
    } catch (Exception e) {
        totalPendingApplications = 0;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="css/dashboard.css">
</head>
<body>
    <div class="dashboard-container">
        <div class="cards-wrapper">
    <div class="card" onclick="openInParentFrame('authorizationPendingCustomers.jsp', 'Authorization Pending > Customer List')">
        <h3>Authorization Pending Customers</h3>
        <p><%= totalPendingCustomers %></p>
    </div>
    <div class="card" onclick="openInParentFrame('authorizationPendingApplications.jsp', 'Authorization Pending > Application List')">
        <h3>Authorization Pending Application</h3>
        <p><%= totalPendingApplications %></p>
    </div>
</div>
    </div>
    
    <script>
    // Update breadcrumb when dashboard loads
    window.onload = function() {
        if (window.parent && window.parent.updateParentBreadcrumb) {
            window.parent.updateParentBreadcrumb('Authorization Pending');
        }
    };

    function openInParentFrame(page, breadcrumbPath) {
        if (window.parent && window.parent.document) {
            const iframe = window.parent.document.getElementById("contentFrame");
            if (iframe) {
                iframe.src = page;
                
                if (window.parent.updateParentBreadcrumb) {
                    window.parent.updateParentBreadcrumb(breadcrumbPath);
                }
            }
        }
    }
</script>
</body>
</html>