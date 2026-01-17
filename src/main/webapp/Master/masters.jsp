<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*,java.util.*,db.DBConnection" %>

<%
    String updated = request.getParameter("updated");
    String pendingAuth = request.getParameter("pendingAuth");

%>

<%
    List<Map<String,String>> cards = new ArrayList<>();

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
            "SELECT DESCRIPTION, TABLE_NAME FROM GLOBALCONFIG.MASTERS ORDER BY SR_NUMBER"
         );
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {

            Map<String,String> c = new HashMap<>();

            String title  = rs.getString("DESCRIPTION");
            String schema = rs.getString("TABLE_NAME"); // schema name

            c.put("title", title);
            c.put("schema", schema);

            /* ===============================
               COUNT TABLES IN THIS SCHEMA
            =============================== */
            String tableCount = "0";

            try (PreparedStatement cntPs = con.prepareStatement(
                    "SELECT COUNT(*) FROM ALL_TABLES " +
                    "WHERE OWNER = ? AND TABLE_NAME NOT LIKE 'SYS_%'")) {


                cntPs.setString(1, schema.toUpperCase());
                ResultSet cntRs = cntPs.executeQuery();

                if (cntRs.next()) {
                    tableCount = cntRs.getString(1);
                }
            } catch (Exception ex) {
                tableCount = "0"; // safe fallback
            }

            c.put("count", tableCount);
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

    const dashboard  = document.getElementById("dashboard");
    const search     = document.getElementById("search");
    const pageTitle  = document.getElementById("pageTitle");
    const tableSearch = document.getElementById("tableSearch");
    const tableMenu   = document.getElementById("tableMenu");
    const data        = document.getElementById("data");

    if (!dashboard || !search || !pageTitle) return;

    dashboard.style.display = 'none';
    search.style.display    = 'block';
    pageTitle.innerText     = title + ' Configuration';

    tableSearch.value = '';
    tableMenu.style.display = 'none';
    data.innerHTML = '<p style="text-align:center;color:#777">Select a Table</p>';

    loadTables();
}

function back(){
    const dashboard = document.getElementById("dashboard");
    const search    = document.getElementById("search");

    if (!dashboard || !search) return;

    search.style.display = 'none';
    dashboard.style.display = 'block';
}

function loadTables(){
    const tableMenu = document.getElementById("tableMenu");
    const tableSearch = document.getElementById("tableSearch");

    fetch(ctx + '/getTables?schema=' + encodeURIComponent(currentSchema))
        .then(r => r.json())
        .then(list => {
            tableMenu.innerHTML = '';
            list.forEach(t => {
                const d = document.createElement('div');
                d.innerText = t;
                d.onclick = () => {
                    tableSearch.value = t;
                    tableMenu.style.display = 'none';
                    loadTable(t);
                };
                tableMenu.appendChild(d);
            });
            
        });
}

function filterTables(){
    const tableSearch = document.getElementById("tableSearch");
    const tableMenu   = document.getElementById("tableMenu");

    const q = tableSearch.value.toUpperCase();
    tableMenu.style.display = 'block';

    [...tableMenu.children].forEach(d => {
        d.style.display = d.innerText.toUpperCase().includes(q) ? 'block' : 'none';
    });
}

function moveEditColumnFront() {
    const table = document.querySelector(".data-table");
    if (!table) return;

    const thead = table.querySelector("thead tr");
    const rows  = table.querySelectorAll("tbody tr");

    if (thead && thead.children.length > 1) {
        const editTh = thead.lastElementChild;
        thead.insertBefore(editTh, thead.firstChild);
        editTh.textContent = "Edit";
        editTh.style.textAlign = "center";
    }

    rows.forEach(row => {
        if (row.children.length > 1) {
            const editTd = row.lastElementChild;
            row.insertBefore(editTd, row.firstChild);
        }
    });
}

function loadTable(t){
    const data = document.getElementById("data");

    fetch(ctx + '/loadTableData?schema=' + encodeURIComponent(currentSchema) + '&table=' + t)
        .then(r => r.text())
        .then(html => {
            data.innerHTML = html;
            moveEditColumnFront();
        });
}

function filterTableRows(value) {
    const table = document.querySelector(".data-table");
    if (!table) return;

    const filter = value.toUpperCase();
    const rows = table.querySelectorAll("tbody tr");

    rows.forEach(row => {
        row.style.display = row.innerText.toUpperCase().includes(filter) ? "" : "none";
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

/* restore state after redirect */
document.addEventListener("DOMContentLoaded", function () {

    const params = new URLSearchParams(window.location.search);
    const schemaFromUrl = params.get("schema");
    const tableFromUrl  = params.get("table");

    if (schemaFromUrl) {
        openCard("", schemaFromUrl);

        if (tableFromUrl) {
            setTimeout(() => {
                // ✅ set table name in search bar
                const tableSearch = document.getElementById("tableSearch");
                if (tableSearch) {
                    tableSearch.value = tableFromUrl;
                }

                // ✅ load table directly
                loadTable(tableFromUrl);

                // ❌ do NOT open dropdown
                const tableMenu = document.getElementById("tableMenu");
                if (tableMenu) {
                    tableMenu.style.display = "none";
                }
            }, 300);
        }
    }

    // ✅ auto-hide message
    const msg = document.getElementById("updateMsg");
    if (msg) {
        setTimeout(() => msg.style.display = "none", 4000);
    }
});

</script>

</head>

<body>

<% if ("true".equals(updated)) { %>
<div id="updateMsg" style="
    background:#e7f7e7;
    border:1px solid #4CAF50;
    color:#2e7d32;
    padding:6px 12px;
    margin:10px auto;
    border-radius:4px;
    font-size:13px;
    font-weight:500;
    width:fit-content;">
    ✅ Updated successfully
</div>
<% } %>

<% if ("true".equals(pendingAuth)) { %>
<div id="updateMsg" style="
    background:#fff3cd;
    border:1px solid #ffca2c;
    color:#856404;
    padding:8px 18px;
    margin:10px auto;
    border-radius:4px;
    font-size:13px;
    font-weight:500;
    min-width: 380px;   /* ✅ same width */
    text-align: center;
">
    ⏳ Changes submitted successfully.<br>
    Pending authorization approval.
</div>

<% } %>


<!-- DASHBOARD -->
<div id="dashboard" class="dashboard-view">
    <div class="dashboard-container">
        <div class="cards-wrapper">

            <% for(Map<String,String> c : cards){ %>
            <div class="card"
                 onclick="openCard('<%=c.get("title")%>',
                                   '<%=c.get("schema")%>')">

                <h3><%=c.get("title")%></h3>

                <!-- ✅ DYNAMIC TABLE COUNT -->
                <p style="font-size:13px;color:#fff;margin:6px 0;">
                    Total Tables: <strong><%=c.get("count")%></strong>
                </p>

                <p>Click to manage</p>
            </div>
            <% } %>

        </div>
    </div>
</div>

<!-- SEARCH VIEW -->
<div id="search" class="search-view">
    <div class="search-container">

        <button class="back" onclick="back()">← Back</button>
        <h1 id="pageTitle" class="page-title"></h1>

        <div class="search-wrapper">
            <div class="search-bar" onclick="toggleTableMenu(event)">
                <span class="search-icon">🔍</span>
                <input id="tableSearch"
                       placeholder="Search by Table Name..."
                       onkeyup="filterTables()">
                <button class="menu-btn">⋮</button>
            </div>
            <div id="tableMenu" class="dropdown"></div>
        </div>

        <div class="table-toolbar">
            <div class="table-title">Records</div>
            <input class="table-search"
                   placeholder="🔍 Search inside table..."
                   onkeyup="filterTableRows(this.value)">
        </div>

        <div id="data" class="data-container">
            <div class="initial-message">
                Select a table to view data
            </div>
        </div>

    </div>
</div>

</body>
</html>
