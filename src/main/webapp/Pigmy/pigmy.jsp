<%@ page import="java.sql.*, db.DBConnection, java.text.SimpleDateFormat" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String branchCode = (String) sess.getAttribute("branchCode");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Pigmy Management</title>
<script src="<%= request.getContextPath() %>/js/breadcrumb-auto.js"></script>
<link rel="stylesheet" href="../css/cardView.css">
</head>

<body>
<div class="dashboard-container">
    <div class="cards-wrapper">
        <!-- New Import Card -->
        <div class="card" onclick="openInParentFrame('Pigmy/import.jsp', 'Pigmy > New Import')">
            <h3>New Import</h3>
            <p>📁</p>
        </div>
        
        <!-- Export Card -->
        <div class="card" onclick="openInParentFrame('Pigmy/pigmyExport.jsp', 'Pigmy > Export')">
            <h3>Export</h3>
            <p>📤</p>
        </div>
    </div>
</div>

<script>
window.onload = function () {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('Pigmy/pigmy.jsp')
        );
    }
};

function openInParentFrame(page, breadcrumbPath) {
    if (window.parent && window.parent.document) {
        const iframe = window.parent.document.getElementById("contentFrame");
        if (iframe) {
            iframe.src = page;
            if (window.parent.updateParentBreadcrumb) {
                window.parent.updateParentBreadcrumb(
                    window.buildBreadcrumbPath(page)
                );
            }
        }
    }
}
</script>
</body>
</html>
