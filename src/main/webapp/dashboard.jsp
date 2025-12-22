<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }

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
            <div class="card" onclick="openInParentFrame('totalCustomers.jsp', 'Dashboard > Total Customers')">
    			<h3>Total Customers</h3>
    			<p><%= totalCustomers %></p>
			</div>

			<div class="card" onclick="openInParentFrame('loanDetails.jsp', 'Dashboard > Loan Details')">
    			<h3>Total Loan</h3>
    			<p><%= String.format("%,.2f", totalLoan) %></p>
			</div>
			
			<div class="card" onclick="openInParentFrame('totalApplications.jsp', 'Dashboard > Total Applications')">
    			<h3>Total Applications</h3>
    			
			</div>


        </div>
    </div>
    
    <script>
 // Update breadcrumb when dashboard loads
    window.onload = function() {
        if (window.parent && window.parent.updateParentBreadcrumb) {
            window.parent.updateParentBreadcrumb('Dashboard');
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