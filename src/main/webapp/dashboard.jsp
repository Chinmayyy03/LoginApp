<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int totalCustomers = 0;
    double totalLoan = 0; // static for now

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM CUSTOMERS WHERE BRANCH_CODE=?")) {
        ps.setString(1, branchCode);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            totalCustomers = rs.getInt(1);
        }
    } catch (Exception e) {
        totalCustomers = 0;
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
            <div class="card" onclick="openInParentFrame('customers.jsp', 'Dashboard > Total Customers')">
                <h3>Total Customers</h3>
                <p><%= totalCustomers %></p>
            </div>
            <div class="card" onclick="openInParentFrame('loanDetails.jsp', 'Dashboard > Total Loan')">
                <h3>Total Loan</h3>
                <p><%= String.format("%,.2f", totalLoan) %></p>
            </div>
        </div>
    </div>
    
    <script>
        function openInParentFrame(page, breadcrumbPath) {
            // Access iframe in parent page and change its src
            if (window.parent && window.parent.document) {
                const iframe = window.parent.document.getElementById("contentFrame");
                if (iframe) {
                    iframe.src = page;
                    
                    // Update breadcrumb in parent
                    if (window.parent.updateParentBreadcrumb) {
                        window.parent.updateParentBreadcrumb(breadcrumbPath);
                    }
                } else {
                    alert("Iframe not found in parent page!");
                }
            }
        }
    </script>
</body>
</html>