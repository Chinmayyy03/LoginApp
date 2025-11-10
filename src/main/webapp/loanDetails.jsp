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

<style>
body {
    margin: 0;
    background: #f4f6fc;
    font-family: "Segoe UI", Roboto, Arial, sans-serif;
    display: flex;
    justify-content: center;
    align-items: flex-start;
    min-height: 100vh;
    padding: 20px;
}

/* Dashboard Container */
.dashboard-container {
    width: 95%;
    max-width: 1200px;
}

/* Stats Card Section */
.stats-container {
    display: flex;
    gap: 20px;
    justify-content: space-between;
    flex-wrap: wrap;
}

/* Blue Statistic Cards */
.stats-card {
    flex: 1;
    min-width: 240px;
    height: 110px;
    background: linear-gradient(135deg, #5b6ef5, #4d8cff);
    border-radius: 18px;
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    transition: transform 0.25s ease;
}

.stats-card:hover {
    transform: translateY(-5px);
}

.card-content {
    text-align: center;
}

.card-content h4 {
    font-size: 13px;
    margin-bottom: 6px;
    letter-spacing: 0.5px;
}

.card-content p {
    font-size: 20px;
    font-weight: 600;
}

/* Graph Card */
.graph-card {
    margin-top: 25px;
    background: linear-gradient(135deg, #5b6ef5, #4d8cff);
    border-radius: 18px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    color: #fff;
    padding: 15px 20px;
    width: 500px;
    height: 200px;
}

.graph-card h4 {
    font-size: 13px;
    letter-spacing: 0.5px;
    margin-bottom: 10px;
}

.graph-card canvas {
    width: 100%;
    height: 120px !important;
}

/* Recent Transactions */
.transactions-card {
    flex: 1;
    min-width: 260px;
    background: #0c2d57;
    color: #fff;
    border-radius: 18px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    padding: 15px;
}

.transactions-card h4 {
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 10px;
    color: #dfe7ff;
}

.transaction {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 10px;
    border-bottom: 1px solid rgba(255,255,255,0.1);
    padding-bottom: 5px;
}

.tx-id {
    font-weight: 600;
    font-size: 13px;
    margin: 0;
}

.tx-detail {
    font-size: 12px;
    color: #bfcdf7;
    margin: 2px 0;
}

.tx-date {
    font-size: 11px;
    color: #9db3f3;
    margin: 0;
}

.tx-amount {
    color: #ff5555;
    font-weight: 600;
    font-size: 13px;
}

/* Responsive Layout */
@media (max-width: 992px) {
    .stats-container {
        flex-direction: row;
        justify-content: center;
        gap: 15px;
    }
    .stats-card, .transactions-card {
        flex: 1 1 45%;
    }
}

@media (max-width: 768px) {
    .dashboard-container {
        width: 100%;
    }
    .stats-container {
        flex-direction: column;
        align-items: center;
    }
    .stats-card, .transactions-card {
        width: 90%;
        height: auto;
    }
    .graph-card {
        height: 180px;
        padding: 10px;
    }
}

@media (max-width: 480px) {
    .card-content h4 {
        font-size: 12px;
    }
    .card-content p {
        font-size: 16px;
    }
    .transactions-card, .graph-card {
        width: 100%;
    }
}
</style>
</head>
<body>

<div class="dashboard-container">
    <div class="stats-container">
        <div class="stats-card">
            <div class="card-content">
                <h4>CUSTOMERS</h4>
                <p>54,235</p>
            </div>
        </div>

        <div class="stats-card">
            <div class="card-content">
                <h4>INCOME</h4>
                <p>$980,632</p>
            </div>
        </div>

        <div class="stats-card">
            <div class="card-content">
                <h4>PRODUCTS SOLD</h4>
                <p>5,490</p>
            </div>
        </div>

        <!-- 💳 Recent Transactions Card -->
        <div class="transactions-card">
            <h4>Recent Transactions</h4>
            <div class="transaction">
                <div>
                    <p class="tx-id">DK0955</p>
                    <p class="tx-detail">Retail ZARA</p>
                    <p class="tx-date">June 1 at 3pm</p>
                </div>
                <p class="tx-amount">-$70</p>
            </div>

            <div class="transaction">
                <div>
                    <p class="tx-id">DK0956</p>
                    <p class="tx-detail">Retail Home</p>
                    <p class="tx-date">June 5 at 5pm</p>
                </div>
                <p class="tx-amount">-$45</p>
            </div>

            <div class="transaction">
                <div>
                    <p class="tx-id">DK0957</p>
                    <p class="tx-detail">Retail Online</p>
                    <p class="tx-date">June 7 at 8pm</p>
                </div>
                <p class="tx-amount">-$10</p>
            </div>
        </div>
    </div>

    <!-- 📊 Graph Card -->
    <div class="graph-card">
        <h4>MONTHLY INCOME</h4>
        <canvas id="incomeChart"></canvas>
    </div>
</div>

<!-- Chart Script -->
<script>
const ctx = document.getElementById('incomeChart').getContext('2d');
new Chart(ctx, {
    type: 'line',
    data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
        datasets: [{
            label: 'Income ($)',
            data: [80000, 95000, 91000, 105000, 99000, 120000],
            borderColor: '#fff',
            backgroundColor: 'rgba(255,255,255,0.2)',
            tension: 0.4,
            fill: true,
            pointBackgroundColor: '#fff'
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
            x: { ticks: { color: '#fff' }, grid: { display: false } },
            y: { ticks: { color: '#fff' }, grid: { display: false } }
        },
        plugins: { legend: { display: false } }
    }
});
</script>

</body>
</html>
