<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    
    if (branchCode == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Utility - New User</title>
<link rel="stylesheet" href="../css/cardView.css">
</head>

<body>
<div class="dashboard-container">
    <div class="cards-wrapper">
        <div class="card" id="card-new-user"
             onclick="openInParentFrame('Utility/NewUser.jsp', 'Utility > New User')">
            <h3>New User</h3>
            <p class="size-1" id="value-new-user">+</p>
        </div>
    </div>
</div>

<script>
window.onload = function () {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Utility');
    }
};

function openInParentFrame(page, breadcrumbPath) {
    if (window.parent && window.parent.document) {
        const iframe = window.parent.document.getElementById("contentFrame");
        if (iframe) {
            // If page ALREADY contains '/', use as-is (already has folder path)
            // If page doesn't contain '/', add '../' to go up from Utility folder
            var adjustedPage = page.includes('/') ? page : '../' + page;
            iframe.src = adjustedPage;
            
            if (window.parent.updateParentBreadcrumb) {
                window.parent.updateParentBreadcrumb(breadcrumbPath);
            }
        }
    }
}
</script>
</body>
</html>
