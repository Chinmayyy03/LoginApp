<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    
    if (branchCode == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
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
<script src="../js/breadcrumb-auto.js"></script>
</head>

<body>
<div class="dashboard-container">
    <div class="cards-wrapper">
        
        <div class="card" onclick="openPage('lockerIssues')">
            <h3>Locker Issues</h3>
            <p class="size-1">→</p>
        </div>
        
        <div class="card" onclick="openPage('lockerAttendance')">
            <h3>Locker Attendance</h3>
            <p class="size-1">→</p>
        </div>
        
        <div class="card" onclick="openPage('lockerSurrender')">
            <h3>Locker Surrender</h3>
            <p class="size-1">→</p>
        </div>
        
        <div class="card" onclick="openPage('lockerTransaction')">
            <h3>Locker Transaction</h3>
            <p class="size-1">→</p>
        </div>

        <div class="card" onclick="openPage('lockerNominee')">
            <h3>Locker Nominee</h3>
            <p class="size-1">→</p>
        </div>

        <div class="card" onclick="openPage('lockerJointHolder')">
            <h3>Locker JointHolder</h3>
            <p class="size-1">→</p>
        </div>

    </div>
</div>

<script>
// Page config: url → breadcrumb label
var PAGE_CONFIG = {
    lockerIssues:      { url: 'Lockers/lockerIssues.jsp',      label: 'Locker Issues'      },
    lockerAttendance:  { url: 'Lockers/lockerAttendance.jsp',  label: 'Locker Attendance'  },
    lockerSurrender:   { url: 'Lockers/lockerSurrender.jsp',   label: 'Locker Surrender'   },
    lockerTransaction: { url: 'Lockers/lockerTransaction.jsp', label: 'Locker Transaction' },
    lockerNominee:     { url: 'Lockers/lockerNominee.jsp',     label: 'Locker Nominee'     },
    lockerJointHolder: { url: 'Lockers/lockerJointHolder.jsp', label: 'Locker JointHolder' }
};

window.onload = function () {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Lockers');
    }
    
    if (window.parent && window.parent.pushNavigationHistory) {
        window.parent.pushNavigationHistory('Lockers', 'Lockers/locker.jsp');
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
                    url = 'Lockers/lockerNominee.jsp';  // ← Correct path
                    breadcrumbLabel = 'Locker Nominee';
                    break;
                case 'lockerJointHolder':
                    url = 'Lockers/lockerJointHolder.jsp';  // ← Correct path
                    breadcrumbLabel = 'Locker JointHolder';
                    break;
            }
            
            if (url) {
                // Direct iframe navigation (bypassing main.jsp breadcrumb issue)
                iframe.src = url;
                
                // Update breadcrumb separately
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
