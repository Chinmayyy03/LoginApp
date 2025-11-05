<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard</title>

  <!-- Chart.js CDN -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

  <style>
    body {
      background: #f5f7fa;
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 20px;
    }

    /* Dashboard Layout */
    .dashboard {
      display: flex;
      flex-direction: column;
      gap: 20px;
    }

    /* Top Section */
    .top-section {
      display: flex;
      justify-content: space-between;
      gap: 20px;
    }

    .card {
      flex: 1;
      background: linear-gradient(135deg, #007bff, #00bfff);
      color: white;
      text-align: center;
      border-radius: 15px;
      padding: 20px;
      font-weight: bold;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    }

    .card span {
      display: block;
      font-size: 1.8rem;
      margin-top: 10px;
    }

    /* Content (Middle + Right Sections) */
    .content {
      display: flex;
      gap: 20px;
    }

    .left-section {
      flex: 2;
    }

    .right-section {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 20px;
    }

    /* Monthly Income Chart */
    .income-chart {
      background: linear-gradient(135deg, #3a7bd5, #3a6073);
      color: white;
      border-radius: 20px;
      padding: 20px;
      text-align: left;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    }

    .income-chart h3 {
      margin-bottom: 10px;
      font-size: 1.4rem;
    }

    canvas {
      width: 100% !important;
      height: 300px !important;
      border-radius: 15px;
      background: rgba(255, 255, 255, 0.1);
      padding: 10px;
    }

    /* Subscription Card */
    .subscription-card {
      background: #4caf50;
      color: white;
      border-radius: 15px;
      padding: 20px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    }

    .subscription-card h4 {
      margin: 0 0 10px;
      font-size: 1.2rem;
    }

    .progress {
      width: 80%;
      height: 10px;
      background: rgba(255, 255, 255, 0.3);
      border-radius: 5px;
      margin-top: 10px;
      position: relative;
    }

    .progress::after {
      content: '';
      position: absolute;
      height: 10px;
      width: 25%;
      background: white;
      border-radius: 5px;
    }

    /* Recent Transactions */
    .transactions {
      background: #001f3f;
      color: white;
      border-radius: 15px;
      padding: 20px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    }

    .transactions h4 {
      margin-bottom: 10px;
      font-size: 1.2rem;
    }

    .transactions ul {
      list-style: none;
      padding: 0;
      margin: 0;
    }

    .transactions li {
      margin-bottom: 10px;
      border-bottom: 1px solid rgba(255, 255, 255, 0.2);
      padding-bottom: 5px;
    }

    .transactions b {
      display: block;
    }

    .transactions .red {
      color: #ff4d4d;
      float: right;
    }

    /* Responsive */
    @media (max-width: 900px) {
      .content {
        flex-direction: column;
      }

      .top-section {
        flex-direction: column;
      }
    }
  </style>
</head>
<body>

  <div class="dashboard">

    <!-- Top Cards -->
    <div class="top-section">
      <div class="card">
        Total Customers
        <span>0</span>
      </div>
      <div class="card">
        Total Loan
        <span>0.00</span>
      </div>
      <div class="card">
        Total Customers
        <span>0</span>
      </div>
    </div>

    <!-- Middle and Right Sections -->
    <div class="content">
      <!-- Left Section -->
      <div class="left-section">
        <div class="income-chart">
          <h3>MONTHLY INCOME</h3>
          <canvas id="incomeChart"></canvas>
        </div>
      </div>

      <!-- Right Section -->
      <div class="right-section">
        <div class="subscription-card">
          <h4>Subscription</h4>
          <p>$500 / $2000</p>
          <div class="progress"></div>
        </div>

        <div class="transactions">
          <h4>Recent Transactions</h4>
          <ul>
            <li><b>DK0955</b> Retail ZARA <span class="red">-$70</span></li>
            <li><b>DK0955</b> Retail Home <span class="red">-$45</span></li>
            <li><b>DK0955</b> Retail Online <span class="red">-$10</span></li>
          </ul>
        </div>
      </div>
    </div>
  </div>

  <!-- Chart.js Script -->
  <script>
    const ctx = document.getElementById('incomeChart').getContext('2d');
    new Chart(ctx, {
      type: 'line',
      data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
        datasets: [{
          label: 'Income',
          data: [80000, 95000, 90000, 105000, 98000, 120000],
          borderColor: '#ffffff',
          backgroundColor: 'rgba(255, 255, 255, 0.2)',
          fill: true,
          tension: 0.4,
          pointBackgroundColor: '#fff',
          pointRadius: 6,
          pointHoverRadius: 8,
          borderWidth: 2
        }]
      },
      options: {
        plugins: {
          legend: { display: false }
        },
        scales: {
          x: {
            ticks: { color: '#fff' },
            grid: { display: false }
          },
          y: {
            ticks: { color: '#fff' },
            grid: { color: 'rgba(255,255,255,0.2)' }
          }
        }
      }
    });
  </script>

</body>
</html>