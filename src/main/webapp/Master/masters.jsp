<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*,java.util.*,db.DBConnection" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    /* ================= LOAD MASTER CARDS ================= */
    List<Map<String,String>> masters = new ArrayList<>();

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
            "SELECT DESCRIPTION, TABLE_NAME FROM GLOBALCONFIG.MASTERS ORDER BY SR_NUMBER"
         );
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            Map<String,String> m = new HashMap<>();
            m.put("title", rs.getString("DESCRIPTION"));
            m.put("prefix", rs.getString("TABLE_NAME"));
            masters.add(m);
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
<title>Global Config Master</title>

<!-- ===================== CSS (UNCHANGED UI) ===================== -->
<style>
/* --- SAME CSS YOU PROVIDED (UNCHANGED) --- */
body{font-family:'Segoe UI',Roboto,Arial;background:#f5f7fa;margin:0}
.dashboard-view{background:#e8e4fc;height:100vh;overflow:auto}
.dashboard-container{padding:40px}
.cards-wrapper{display:grid;grid-template-columns:repeat(4,1fr);gap:30px}
.card{background:linear-gradient(135deg,#4a9eff,#3d85d9);color:#fff;
padding:20px;border-radius:20px;cursor:pointer}
.search-view{display:none;background:#e8e4fc;height:100vh}
.search-container{width:95%;margin:auto;padding:20px}
.back-btn{background:none;border:none;color:#2b0d73;font-size:16px;cursor:pointer}
.page-title{color:#2b0d73;margin-bottom:20px}
.top-bar{display:flex;gap:8px;background:#fff;padding:10px;border-radius:8px}
.top-bar input{flex:1;padding:10px}
.dropdown{display:none;position:absolute;background:#fff;border:1px solid #ccc;
max-height:300px;overflow:auto;width:100%}
.dropdown-item{padding:10px;cursor:pointer}
.dropdown-item:hover{background:#2b0d73;color:#fff}
.data-container{margin-top:20px;background:#fff;padding:15px;border-radius:8px}
</style>

<!-- ===================== JS ===================== -->
<script>
const ctx = '${pageContext.request.contextPath}';
let currentPrefix = "";

function openSearch(title, prefix) {
    currentPrefix = prefix;

    document.getElementById("dashboardView").style.display = "none";
    document.getElementById("searchView").style.display = "block";

    document.getElementById("pageTitle").innerText =
        title + " Configuration";

    document.getElementById("tableSearch").value = "";
    document.getElementById("dataContainer").innerHTML =
        "<div style='text-align:center;color:#777'>Search or select a table</div>";

    loadTables();
}

function backToDashboard() {
    document.getElementById("searchView").style.display = "none";
    document.getElementById("dashboardView").style.display = "block";
}

function loadTables() {
    fetch(ctx + "/getTables?prefix=" + currentPrefix)
        .then(r => r.json())
        .then(list => {
            const menu = document.getElementById("tableMenu");
            menu.innerHTML = "";

            if (list.length === 0) {
                menu.innerHTML = "<div class='dropdown-item'>No tables</div>";
                return;
            }

            list.forEach(t => {
                const d = document.createElement("div");
                d.className = "dropdown-item";
                d.innerText = t;
                d.onclick = () => loadTable(t);
                menu.appendChild(d);
            });
        });
}

function filterTables() {
    const q = tableSearch.value.toUpperCase();
    document.querySelectorAll(".dropdown-item").forEach(i=>{
        i.style.display = i.innerText.includes(q) ? "block":"none";
    });
    tableMenu.style.display = "block";
}

function loadTable(table) {
    tableSearch.value = table;
    tableMenu.style.display = "none";

    dataContainer.innerHTML = "<p>Loading "+table+"...</p>";

    fetch(ctx + "/loadTableData?table=" + table)
        .then(r => r.text())
        .then(html => dataContainer.innerHTML = html);
}

document.addEventListener("click", e=>{
    if(!tableMenu.contains(e.target) && e.target!==tableSearch){
        tableMenu.style.display="none";
    }
});
</script>
</head>

<body>

<!-- ===================== DASHBOARD ===================== -->
<div id="dashboardView" class="dashboard-view">
    <div class="dashboard-container">
        <div class="cards-wrapper">
            <% for (Map<String,String> m : masters) { %>
            <div class="card"
                 onclick="openSearch('<%=m.get("title")%>','<%=m.get("prefix")%>')">
                <h3><%=m.get("title")%></h3>
                <p>Click to manage</p>
            </div>
            <% } %>
        </div>
    </div>
</div>

<!-- ===================== SEARCH VIEW ===================== -->
<div id="searchView" class="search-view">
    <div class="search-container">

        <button class="back-btn" onclick="backToDashboard()">← Back</button>
        <h1 class="page-title" id="pageTitle"></h1>

        <div class="top-bar" style="position:relative">
            <input id="tableSearch"
                   placeholder="Search table..."
                   onkeyup="filterTables()">
            <div id="tableMenu" class="dropdown"></div>
        </div>

        <div id="dataContainer" class="data-container"></div>
    </div>
</div>

</body>
</html>
