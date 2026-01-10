// Navigation function - Opens specific card page
function openCardPage(cardType) {
    // In a real application, this would navigate to different JSP pages
    // For demonstration, we'll simulate it by showing different sections
    
    switch(cardType) {
        case 'bank':
            window.location.href = contextPath + '/bank-page.jsp';
            break;
        case 'headOffice':
            window.location.href = contextPath + '/head-office-page.jsp';
            break;
        case 'branch':
            window.location.href = contextPath + '/branch-page.jsp';
            break;
        case 'account':
            window.location.href = contextPath + '/account-page.jsp';
            break;
        default:
            window.location.href = contextPath + '/bank-page.jsp';
    }
}

// Back to dashboard function
function goBackToDashboard() {
    window.location.href = contextPath + '/master.jsp';
}

// Only run this code if we're on a card page (has search functionality)
if (document.getElementById('tableSearch')) {
    document.addEventListener("DOMContentLoaded", function () {
        const btn = document.getElementById("menuBtn");
        const menu = document.getElementById("tableMenu");
        const search = document.getElementById("tableSearch");

        if (!btn || !menu || !search) {
            console.error("Required elements missing");
            return;
        }

        // Toggle dropdown on 3-dot click
        btn.addEventListener("click", function (e) {
            e.stopPropagation();
            menu.style.display =
                menu.style.display === "block" ? "none" : "block";
        });

        // Open dropdown when typing or focusing search
        search.addEventListener("focus", function () {
            menu.style.display = "block";
        });

        // Close dropdown when clicking outside
        document.addEventListener("click", function () {
            menu.style.display = "none";
        });
    });

    // Filter table list
    function filterTables() {
        const search = document.getElementById("tableSearch");
        const menu = document.getElementById("tableMenu");
        const items = document.querySelectorAll("#tableMenu .dropdown-item");

        const filter = search.value.toUpperCase();
        menu.style.display = "block";

        items.forEach(item => {
            const text = item.textContent.toUpperCase();
            item.style.display = text.includes(filter) ? "block" : "none";
        });
    }

    // Load selected table data
    function loadTable(tableName) {
        const search = document.getElementById("tableSearch");
        const menu = document.getElementById("tableMenu");
        const container = document.getElementById("dataContainer");

        search.value = tableName;
        menu.style.display = "none";
        container.innerHTML = "<p>Loading data...</p>";

        fetch(contextPath + "/loadTableData?table=" + encodeURIComponent(tableName))
            .then(res => {
                if (!res.ok) throw new Error(res.status);
                return res.text();
            })
            .then(html => {
                container.innerHTML = html;
            })
            .catch(err => {
                console.error(err);
                container.innerHTML =
                    "<p style='color:red'>Failed to load table data</p>";
            });
    }
}
