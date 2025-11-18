<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dashboard | Banking Software</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>


</head>
<body>
</body>
</html>
