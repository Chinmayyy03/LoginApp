<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <title>Global Config Master</title>

    <!-- CSS -->
    <link rel="stylesheet" href="Master/css/master.css">

    <!-- Context path for JS -->
    <script>
        const contextPath = '${pageContext.request.contextPath}';
    </script>

    <!-- JS -->
    <script src="Master/js/master.js" defer></script>
</head>

<body>

<div class="container">

    <!-- TOP BAR -->
    <div class="top-bar">

        <!-- SEARCH BAR -->
        <input type="text"
               id="tableSearch"
               placeholder="Search or select table..."
               onkeyup="filterTables()">

        <!-- 3 DOT MENU -->
        <button type="button" id="menuBtn">⋮</button>

        <!-- DROPDOWN (OVERLAY) -->
        <div id="tableMenu" class="dropdown">
            <c:forEach var="t" items="${tableList}">
                <div class="dropdown-item"
                     onclick="loadTable('${t}')">
                    ${t}
                </div>
            </c:forEach>
        </div>

    </div>

    <!-- TABLE DATA -->
    <div id="dataContainer" class="data-container">
        <!-- Data loads here -->
    </div>

</div>

</body>
</html>
