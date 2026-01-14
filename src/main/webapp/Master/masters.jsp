<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*,java.util.*,db.DBConnection" %>

<%
    List<Map<String,String>> cards = new ArrayList<>();

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
            "SELECT DESCRIPTION, TABLE_NAME FROM GLOBALCONFIG.MASTERS ORDER BY SR_NUMBER"
         );
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            Map<String,String> c = new HashMap<>();
            c.put("title", rs.getString("DESCRIPTION"));
            c.put("schema", rs.getString("TABLE_NAME"));
            cards.add(c);
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
<title>Masters</title>

<!-- ✅ LINK EXTERNAL CSS -->
<link rel="stylesheet"
          href="<%=request.getContextPath()%>/Master/css/master.css">
<script>
const ctx = '<%=request.getContextPath()%>';
let currentSchema = '';

function openCard(title, schema){
    currentSchema = schema;

    dashboard.style.display='none';
    search.style.display='block';
    pageTitle.innerText = title + ' Configuration';

    tableSearch.value='';
    tableMenu.style.display='none';
    data.innerHTML='<p style="text-align:center;color:#777">Select a table</p>';

    loadTables();
}

function back(){
    search.style.display='none';
    dashboard.style.display='block';
}

function loadTables(){
    fetch(ctx + '/getTables?schema=' + encodeURIComponent(currentSchema))
      .then(r=>r.json())
      .then(list=>{
        tableMenu.innerHTML='';
        list.forEach(t=>{
            const d=document.createElement('div');
            d.innerText=t;
            d.onclick=()=>{
                tableSearch.value=t;
                tableMenu.style.display='none';
                loadTable(t);
            };
            tableMenu.appendChild(d);
        });
        tableMenu.style.display='block';
      });
}

function filterTables(){
    const q = tableSearch.value.toUpperCase();
    tableMenu.style.display='block';
    [...tableMenu.children].forEach(d=>{
        d.style.display = d.innerText.toUpperCase().includes(q) ? 'block':'none';
    });
}

function moveEditColumnFront() {
    const table = document.querySelector(".data-table");
    if (!table) return;

    const thead = table.querySelector("thead tr");
    const rows  = table.querySelectorAll("tbody tr");

    /* ---- Move EDIT header to first ---- */
    if (thead && thead.children.length > 1) {
        const editTh = thead.lastElementChild;
        thead.insertBefore(editTh, thead.firstChild);
        editTh.textContent = "Edit";
        editTh.style.textAlign = "center";
    }

    /* ---- Move EDIT button column to first ---- */
    rows.forEach(row => {
        if (row.children.length > 1) {
            const editTd = row.lastElementChild;
            row.insertBefore(editTd, row.firstChild);
        }
    });
}

function loadTable(t){
    fetch(ctx + '/loadTableData?schema=' + encodeURIComponent(currentSchema) + '&table=' + t)
      .then(r=>r.text())
      .then(html=>{
          data.innerHTML = html;
          moveEditColumnFront(); // ✅ FIX
      });
}

function filterTableRows(value) {
    const table = document.querySelector(".data-table");
    if (!table) return;

    const filter = value.toUpperCase();
    const rows = table.querySelectorAll("tbody tr");

    rows.forEach(row => {
        const text = row.innerText.toUpperCase();
        row.style.display = text.includes(filter) ? "" : "none";
    });
}

function toggleTableMenu(e){
    e.stopPropagation();
    const menu = document.getElementById("tableMenu");
    menu.style.display = menu.style.display === "block" ? "none" : "block";
}

/* Close dropdown when clicking outside */
document.addEventListener("click", function(e){
    const menu = document.getElementById("tableMenu");
    const search = document.getElementById("tableSearch");
    if(menu && !menu.contains(e.target) && e.target !== search){
        menu.style.display = "none";
    }
});
</script>
</head>

<body>

<!-- DASHBOARD -->
<div id="dashboard" class="dashboard-view">
    <div class="dashboard-container">
        <div class="cards-wrapper">
            <% for(Map<String,String> c : cards){ %>
            <div class="card"
                 onclick="openCard('<%=c.get("title")%>',
                                   '<%=c.get("schema")%>')">
                <h3><%=c.get("title")%></h3>
                <p>Click to manage</p>
            </div>
            <% } %>
        </div>
    </div>
</div>

<!-- ================= SEARCH VIEW ================= -->
<div id="search" class="search-view">
    <div class="search-container">

        <!-- BACK -->
        <button class="back" onclick="back()">← Back</button>

        <!-- PAGE TITLE -->
        <h1 id="pageTitle" class="page-title"></h1>

        <!-- SEARCH BAR (CENTERED LIKE IMAGE) -->
        <div class="search-wrapper">

    <div class="search-bar">
        <span class="search-icon">🔍</span>

        <input id="tableSearch"
               placeholder="Search by Code, Name, Type..."
               onkeyup="filterTables()">

        <!-- THREE DOTS BUTTON -->
        <button class="menu-btn"
                onclick="toggleTableMenu(event)">⋮</button>
    </div>

    <!-- DROPDOWN -->
    <div id="tableMenu" class="dropdown"></div>

</div>


       <!-- TABLE TOOLBAR -->
<div class="table-toolbar">
    <div class="table-title">Records</div>

    <input type="text"
           class="table-search"
           placeholder="🔍 Search inside table..."
           onkeyup="filterTableRows(this.value)">
</div>

<!-- TABLE CONTAINER -->
<div id="data" class="data-container">
    <div class="initial-message">
        Select a table to view data
    </div>
</div>


    </div>
</div>


</body>
</html>

