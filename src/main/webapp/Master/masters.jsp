<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
<title>Global Config Master</title>

<style>
body {
    font-family: Arial;
    background: #e8e4fc;
}
.cards-wrapper {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 20px;
}
.card {
    background: #4a9eff;
    color: white;
    padding: 20px;
    border-radius: 15px;
    cursor: pointer;
}
.card:hover {
    background: #3b86d4;
}
</style>

<script>
const contextPath = '${pageContext.request.contextPath}';

function openCard(tableName, title) {
    document.getElementById("dashboardView").style.display = "none";
    document.getElementById("tableView").style.display = "block";
    document.getElementById("pageTitle").innerText =
        title + " Configuration";

    loadTable(tableName);
}

function loadTable(table) {
    fetch(contextPath + "/loadTableData?table=" + table)
        .then(res => res.text())
        .then(html => {
            document.getElementById("dataContainer").innerHTML = html;
        });
}

function backToDashboard() {
    document.getElementById("tableView").style.display = "none";
    document.getElementById("dashboardView").style.display = "block";
}
</script>
</head>

<body>

<!-- DASHBOARD -->
<div id="dashboardView">
    <h2>Dashboard</h2>

    <c:if test="${empty mastersList}">
        <p style="color:red;font-weight:bold;">No cards found</p>
    </c:if>

    <div class="cards-wrapper">
        <c:forEach var="m" items="${mastersList}">
            <div class="card"
                 onclick="openCard('${m.TABLE_NAME}','${m.DESCRIPTION}')">
                <h3>${m.DESCRIPTION}</h3>
                <p>Click to manage</p>
            </div>
        </c:forEach>
    </div>
</div>

<!-- TABLE VIEW -->
<div id="tableView" style="display:none">
    <button onclick="backToDashboard()">← Back</button>
    <h2 id="pageTitle"></h2>
    <div id="dataContainer"></div>
</div>

</body>
</html>
