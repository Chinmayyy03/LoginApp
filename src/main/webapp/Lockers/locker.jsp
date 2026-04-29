<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    
    if (branchCode == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Load card structure from database (optional - you can hardcode if not in DB)
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    java.util.List<java.util.Map<String, String>> cards = new java.util.ArrayList<>();
    
    try {
        // If you have locker cards in GLOBALCONFIG.DASHBOARD, fetch them
        // Otherwise, we'll hardcode them below
        conn = DBConnection.getConnection();
        // You can add your query here if cards are in database
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (ps != null) ps.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Locker Management</title>
<link rel="stylesheet" href="../css/cardView.css">
</head>

<body>
<div class="dashboard-container">
    <div class="cards-wrapper">
        
        <!-- Card 1: Locker Issues -->
        <div class="card" onclick="openPage('lockerIssues')">
            <h3>Locker Issues</h3>
            <p class="size-1">→</p>
        </div>
        
        <!-- Card 2: Locker Attendance -->
        <div class="card" onclick="openPage('lockerAttendance')">
            <h3>Locker Attendance</h3>
            <p class="size-1">→</p>
        </div>
        
        <!-- Card 3: Locker Surrender -->
        <div class="card" onclick="openPage('lockerSurrender')">
            <h3>Locker Surrender</h3>
            <p class="size-1">→</p>
        </div>
        
        <!-- Card 4: Locker Transaction -->
        <div class="card" onclick="openPage('lockerTransaction')">
            <h3>Locker Transaction</h3>
            <p class="size-1">→</p>
        </div>

        <!-- Card 5: Locker Nominee -->
        <div class="card" onclick="openPage('lockerNominee')">
            <h3>Locker Nominee</h3>
            <p class="size-1">→</p>
        </div>

        <!-- Card 6: Locker JointHolder -->
        <div class="card" onclick="openPage('lockerJointHolder')">
            <h3>Locker JointHolder</h3>
            <p class="size-1">→</p>
        </div>

    </div>
</div>

<script>
window.onload = function () {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Lockers');
    }
};

function openPage(page) {
    if (window.parent && window.parent.document) {
        const iframe = window.parent.document.getElementById("contentFrame");
        if (iframe) {
            let url = '';
            let breadcrumbLabel = '';
            
            switch(page) {
                case 'lockerIssues':
                    url = 'Lockers/lockerIssues.jsp';
                    breadcrumbLabel = 'Locker Issues';
                    break;
                case 'lockerAttendance':
                    url = 'Lockers/lockerAttendance.jsp';
                    breadcrumbLabel = 'Locker Attendance';
                    break;
                case 'lockerSurrender':
                    url = 'Lockers/lockerSurrender.jsp';
                    breadcrumbLabel = 'Locker Surrender';
                    break;
                case 'lockerTransaction':
                    url = 'Lockers/lockerTransaction.jsp';
                    breadcrumbLabel = 'Locker Transaction';
                    break;
                case 'lockerNominee':
                    url = 'Lockers/lockerNominee.jsp';
                    breadcrumbLabel = 'Locker Nominee';
                    break;
                case 'lockerJointHolder':
                    url = 'Lockers/lockerJointHolder.jsp';
                    breadcrumbLabel = 'Locker JointHolder';
                    break;
            }
            
            if (url) {
                iframe.src = url;
                if (window.parent.updateParentBreadcrumb) {
                    window.parent.updateParentBreadcrumb('Lockers > ' + breadcrumbLabel);
                }
            }
        }
    }
}
</script>
</body>
</html>
