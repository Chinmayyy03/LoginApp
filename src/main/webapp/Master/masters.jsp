<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Global Config Master</title>

    <!-- ===================== CSS (UNCHANGED UI) ===================== -->
    <style>
        /* Reset and Base */
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Segoe UI', Roboto, Arial, sans-serif;
            background: #f5f7fa;
            color: #1a1a1a;
            height: 100vh;
            overflow: hidden;
        }

        /* Dashboard View */
        .dashboard-view {
            display: block;
            height: 100vh;
            overflow: auto;
            background-color: #e8e4fc;
        }

        .dashboard-container {
            display: flex;
            justify-content: center;
            align-items: flex-start;
            padding: 40px;
            min-height: 100vh;
            width: 100%;
        }

        .cards-wrapper {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 30px;
            padding: 0;
            width: 100%;
            max-width: 1400px;
        }

        .card {
            background: linear-gradient(135deg, #4a9eff 0%, #3d85d9 100%);
            color: white;
            padding: 18px 20px;
            border-radius: 20px;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.15);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            position: relative;
            overflow: hidden;
            cursor: pointer;
            min-height: 100px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .card::before,
        .card::after {
            content: "";
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.1);
            pointer-events: none;
        }

        .card::before {
            width: 140px;
            height: 140px;
            top: -40px;
            right: -40px;
        }

        .card::after {
            width: 200px;
            height: 200px;
            bottom: -70px;
            left: -70px;
        }

        .card h3 {
            font-size: 16px;
            font-weight: 600;
            margin: 0 0 10px 0;
            position: relative;
            z-index: 1;
            line-height: 1.25;
            min-height: 40px;
            word-wrap: break-word;
        }

        .card p {
            font-size: 28px;
            font-weight: 700;
            margin: 0;
            position: relative;
            z-index: 1;
            word-wrap: break-word;
            overflow-wrap: break-word;
            line-height: 1.2;
        }

        .card:hover {
            transform: translateY(-6px) scale(1.02);
            box-shadow: 0 12px 30px rgba(74, 158, 255, 0.35);
        }

        .card:active {
            transform: scale(0.97);
        }

        /* Search View */
        .search-view {
            display: none;
            height: 100vh;
            overflow: auto;
            background: #e8e4fc;
        }

        .search-container {
            width: 95%;
            margin: 20px auto;
            position: relative;
            padding: 0 20px;
        }

        /* Back Button */
        .back-btn {
            background: none;
            border: none;
            color: #2b0d73;
            font-size: 16px;
            cursor: pointer;
            padding: 12px 0;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 500;
        }

        .back-btn:hover {
            text-decoration: underline;
            color: #1a0855;
        }

        .page-title {
            color: #2b0d73;
            margin: 0 0 25px 0;
            font-size: 24px;
            font-weight: 600;
            padding-bottom: 10px;
            border-bottom: 2px solid rgba(43, 13, 115, 0.1);
        }

        /* TOP BAR */
        .top-bar {
            display: flex;
            align-items: center;
            gap: 10px;
            position: relative;
            background: #fff;
            padding: 10px 12px;
            border-radius: 8px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.08);
            margin-bottom: 20px;
            border: 1px solid #cbc3ff;
        }

        .top-bar input {
            flex: 1;
            padding: 10px 12px;
            font-size: 15px;
            border: 1px solid #ccc;
            border-radius: 6px;
            border-color: #cbc3ff;
        }

        .top-bar input:focus {
            outline: none;
            border-color: #2b0d73;
            box-shadow: 0 0 0 2px rgba(43, 13, 115, 0.1);
        }

        .top-bar button {
            width: 42px;
            height: 42px;
            font-size: 20px;
            border: none;
            border-radius: 6px;
            background: #2b0d73;
            color: #fff;
            cursor: pointer;
            transition: background 0.2s;
        }

        .top-bar button:hover {
            background: #1a0855;
        }

        /* DROPDOWN */
        .dropdown {
            display: none;
            position: absolute;
            top: calc(100% + 8px);
            left: 0;
            right: 0;
            background: #fff;
            border-radius: 8px;
            border: 1px solid #cbc3ff;
            max-height: 300px;
            overflow-y: auto;
            z-index: 10000;
            box-shadow: 0 10px 25px rgba(0,0,0,0.25);
        }

        .dropdown-item {
            padding: 10px 14px;
            cursor: pointer;
            border-bottom: 1px solid #f0f0f0;
            transition: all 0.2s ease;
        }

        .dropdown-item:last-child {
            border-bottom: none;
        }

        .dropdown-item:hover {
            background: #2b0d73;
            color: #fff;
        }

        /* TABLE DATA CONTAINER */
        .data-container {
            margin-top: 25px;
            background: #fff;
            border-radius: 8px;
            border: 1px solid #cbc3ff;
            max-height: 520px;
            overflow: auto;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            padding: 15px;
            min-height: 200px;
        }

        .initial-message {
            padding: 60px 20px;
            text-align: center;
            color: #666;
            font-size: 16px;
            font-style: italic;
        }

        /* TABLE STYLING - Compact and small */
        .data-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 12px;
            background: #fff;
            border-radius: 6px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        .data-table th {
            background: #2b0d73;
            color: white;
            padding: 8px 10px;
            text-align: left;
            font-weight: 600;
            position: sticky;
            top: 0;
            border-bottom: 1px solid #1a0855;
            font-size: 12px;
            white-space: nowrap;
        }

        .data-table td {
            padding: 6px 8px;
            border-bottom: 1px solid #e8e4fc;
            color: #333;
            font-size: 11.5px;
            vertical-align: middle;
            height: 28px;
            max-height: 28px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .data-table tr {
            transition: background-color 0.2s ease;
            height: 28px;
        }

        .data-table tr:hover {
            background-color: #f5f3ff;
        }

        .data-table tr:nth-child(even) {
            background-color: #faf9ff;
        }

        /* EDIT BUTTON - Small and compact */
        .edit-btn {
            background: #2b0d73;
            color: #fff;
            padding: 3px 8px;
            border-radius: 4px;
            text-decoration: none;
            font-size: 10px;
            border: none;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 3px;
            min-width: 50px;
            height: 22px;
            white-space: nowrap;
        }

        .edit-btn:hover {
            background: #1a0855;
            transform: translateY(-1px);
        }

        /* ACTION BUTTONS */
        .action-buttons {
            display: flex;
            gap: 4px;
            justify-content: center;
        }

        /* TABLE ACTIONS BAR */
        .table-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
            padding: 8px 5px;
            background: #f8f7ff;
            border-radius: 6px;
            border: 1px solid #e0dcff;
        }

        .table-actions-left {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        .add-new-btn {
            background: #28a745;
            color: white;
            padding: 6px 12px;
            border-radius: 4px;
            text-decoration: none;
            font-size: 12px;
            border: none;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            height: 28px;
        }

        .add-new-btn:hover {
            background: #218838;
        }

        .record-count {
            color: #666;
            font-size: 12px;
            font-weight: 500;
            padding: 3px 8px;
            background: white;
            border-radius: 4px;
            border: 1px solid #e0dcff;
        }

        /* SEARCH BOX IN TABLE */
        .table-search {
            padding: 5px 8px;
            border: 1px solid #cbc3ff;
            border-radius: 4px;
            font-size: 12px;
            width: 180px;
            height: 28px;
            transition: all 0.2s ease;
        }

        .table-search:focus {
            outline: none;
            border-color: #2b0d73;
            box-shadow: 0 0 0 2px rgba(43, 13, 115, 0.1);
        }

        /* LOADING SPINNER */
        .loading-spinner {
            display: inline-block;
            width: 16px;
            height: 16px;
            border: 2px solid #f3f3f3;
            border-top: 2px solid #2b0d73;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* RESPONSIVE DESIGN */
        @media (max-width: 1200px) {
            .dashboard-container { padding: 30px; }
            .cards-wrapper {
                gap: 25px;
                grid-template-columns: repeat(3, 1fr);
            }
            .search-container {
                width: 97%;
            }
        }

        @media (max-width: 900px) {
            .dashboard-container { padding: 25px; }
            .cards-wrapper {
                gap: 20px;
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            .data-table {
                display: block;
                overflow-x: auto;
            }
            .table-actions {
                flex-direction: column;
                gap: 8px;
                align-items: flex-start;
            }
            .table-search {
                width: 100%;
            }
        }

        @media (max-width: 600px) {
            .dashboard-container { padding: 20px 15px; }
            .cards-wrapper {
                gap: 18px;
                grid-template-columns: 1fr;
            }
            .search-container {
                padding: 0 10px;
            }
        }
    </style>

    <!-- ===================== JAVASCRIPT (FIXED) ===================== -->
    <script>
        const contextPath = '${pageContext.request.contextPath}';
        let isSearchInitialized = false;

        function showDashboard() {
            document.getElementById('dashboardView').style.display = 'block';
            document.getElementById('searchView').style.display = 'none';
        }

        function showBankSearch() {
            document.getElementById('dashboardView').style.display = 'none';
            document.getElementById('searchView').style.display = 'block';

            if (!isSearchInitialized) {
                initializeSearch();
                isSearchInitialized = true;
            }
        }

        function initializeSearch() {
            const btn = document.getElementById("menuBtn");
            const menu = document.getElementById("tableMenu");
            const search = document.getElementById("tableSearch");

            btn.addEventListener("click", e => {
                e.stopPropagation();
                menu.style.display = menu.style.display === "block" ? "none" : "block";
            });

            search.addEventListener("focus", () => menu.style.display = "block");

            document.addEventListener("click", e => {
                if (!menu.contains(e.target) && e.target !== btn && e.target !== search) {
                    menu.style.display = "none";
                }
            });
        }

        function filterTables() {
            const filter = document.getElementById("tableSearch").value.toUpperCase();
            document.querySelectorAll(".dropdown-item").forEach(item => {
                item.style.display = item.textContent.toUpperCase().includes(filter)
                    ? "block" : "none";
            });
            document.getElementById("tableMenu").style.display = "block";
        }

        function loadTable(tableName) {
            const container = document.getElementById("dataContainer");
            document.getElementById("tableSearch").value = tableName;
            document.getElementById("tableMenu").style.display = "none";

            container.innerHTML = `<p style="text-align:center">Loading ${tableName}...</p>`;

            fetch(contextPath + "/loadTableData?table=" + encodeURIComponent(tableName))
                .then(res => res.text())
                .then(html => {
                    container.innerHTML = html;
                    attachEditButtonEvents();   // 🔥 FIX
                })
                .catch(() => {
                    container.innerHTML = "<p>Error loading table</p>";
                });
        }

        /* ================= EDIT BUTTON FIX ================= */
function attachEditButtonEvents() {

    const table = document.querySelector(".data-table");
    if (!table) return;

    const theadRow = table.querySelector("thead tr");
    const tbodyRows = table.querySelectorAll("tbody tr");

    /* MOVE EDIT HEADER TO FIRST */
    if (theadRow && theadRow.children.length > 1) {
        const lastTh = theadRow.lastElementChild;
        theadRow.insertBefore(lastTh, theadRow.firstElementChild);
        lastTh.textContent = "Edit";
        lastTh.style.textAlign = "center";
    }

    /* MOVE EDIT BUTTON TO FIRST COLUMN */
    tbodyRows.forEach(tr => {
        if (tr.children.length > 1) {
            const lastTd = tr.lastElementChild;
            tr.insertBefore(lastTd, tr.firstElementChild);

            const btn = lastTd.querySelector(".edit-btn");
            if (btn) {
                btn.onclick = function () {
                    const tableName = document.getElementById("tableSearch").value;

                    let recordId = this.dataset.id;

                    // 🔥 FALLBACK: take first data column as PK
                    if (!recordId) {
                        const firstCell = this.closest("tr").querySelector("td:nth-child(2)");
                        recordId = firstCell ? firstCell.textContent.trim() : null;
                    }

                    if (!recordId) {
                        alert("Primary key not found for this row!");
                        return;
                    }

                    window.location.href =
                        contextPath +
                        "/editRow?table=" +
                        encodeURIComponent(tableName) +
                        "&id=" +
                        encodeURIComponent(recordId);
                };
            }
        }
    });
}

        document.addEventListener("DOMContentLoaded", function () {
            showDashboard();
            document.getElementById("bankCard").addEventListener("click", showBankSearch);
            document.querySelector(".back-btn").addEventListener("click", showDashboard);
        });
    </script>
</head>

<body>

<!-- ===================== DASHBOARD ===================== -->
<div id="dashboardView" class="dashboard-view">
    <div class="dashboard-container">
        <div class="cards-wrapper">
            <div class="card" id="bankCard">
                <h3>Bank</h3>
                <p>Click to search bank tables</p>
            </div>
            <div class="card"><h3>Head Office</h3><p>Coming soon</p></div>
            <div class="card"><h3>Branch</h3><p>Coming soon</p></div>
            <div class="card"><h3>Account</h3><p>Coming soon</p></div>
        </div>
    </div>
</div>

<!-- ===================== SEARCH VIEW ===================== -->
<div id="searchView" class="search-view">
    <div class="search-container">

        <button class="back-btn">← Back to Dashboard</button>
        <h1 class="page-title">Bank Configuration</h1>

        <div class="top-bar">
            <input type="text"
                   id="tableSearch"
                   placeholder="Search or select bank table..."
                   onkeyup="filterTables()">

            <button type="button" id="menuBtn">⋮</button>

            <div id="tableMenu" class="dropdown">
                <c:forEach var="tableName" items="${tableList}">
                    <div class="dropdown-item"
                         onclick="loadTable('${tableName}')">
                        ${tableName}
                    </div>
                </c:forEach>
            </div>
        </div>

        <div id="dataContainer" class="data-container">
            <div class="initial-message">
                Search for a table or select from dropdown
            </div>
        </div>

    </div>
</div>

</body>
</html>
