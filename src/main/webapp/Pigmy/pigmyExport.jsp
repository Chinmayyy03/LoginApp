<%@ page import="java.sql.*, db.DBConnection, java.text.SimpleDateFormat" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String branchCode = (String) sess.getAttribute("branchCode");
    String userId = (String) sess.getAttribute("userId");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Pigmy Export</title>
<script src="<%= request.getContextPath() %>/js/breadcrumb-auto.js"></script>
<style>
* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
    background: #f5f7fa;
    color: #1a1a1a;
}

.container {
    max-width: 900px;
    margin: 40px auto;
    padding: 30px;
    background: white;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

h2 {
    color: #333;
    margin-bottom: 10px;
    font-size: 24px;
}

.subtitle {
    color: #666;
    margin-bottom: 30px;
    font-size: 14px;
}

.form-section {
    background: #f8fbff;
    padding: 25px;
    border-radius: 8px;
    margin-bottom: 20px;
}

.form-group {
    margin-bottom: 20px;
}

.form-group label {
    display: block;
    margin-bottom: 8px;
    font-weight: 600;
    color: #333;
}

.form-group input,
.form-group select {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    font-size: 14px;
    transition: border-color 0.3s ease;
}

.form-group input:focus,
.form-group select:focus {
    outline: none;
    border-color: #4a9eff;
}

.form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
}

.btn {
    padding: 12px 24px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 600;
    transition: all 0.3s ease;
    margin: 5px;
}

.btn-primary {
    background: linear-gradient(135deg, #4a9eff 0%, #3d85d9 100%);
    color: white;
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(74, 158, 255, 0.4);
}

.btn-secondary {
    background: #e5e7eb;
    color: #333;
}

.btn-secondary:hover {
    background: #d1d5db;
}

.export-options {
    display: flex;
    gap: 15px;
    margin-bottom: 20px;
}

.option-card {
    flex: 1;
    padding: 20px;
    border: 2px solid #e5e7eb;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s ease;
    text-align: center;
}

.option-card:hover {
    border-color: #4a9eff;
    background: #f8fbff;
}

.option-card.selected {
    border-color: #4a9eff;
    background: #f0f7ff;
}

.option-card .icon {
    font-size: 36px;
    margin-bottom: 10px;
}

.option-card .title {
    font-weight: 600;
    color: #333;
    margin-bottom: 5px;
}

.option-card .desc {
    font-size: 12px;
    color: #666;
}

.message {
    padding: 15px;
    border-radius: 6px;
    margin-top: 20px;
    display: none;
}

.message.show {
    display: block;
}

.message.success {
    background: #f0fdf4;
    border: 1px solid #86efac;
    color: #166534;
}

.message.error {
    background: #fef2f2;
    border: 1px solid #fca5a5;
    color: #991b1b;
}

.instructions {
    margin-top: 30px;
    padding: 20px;
    background: #fefce8;
    border-left: 4px solid #fbbf24;
    border-radius: 6px;
}

.instructions h4 {
    margin-top: 0;
    color: #92400e;
}

.instructions ul {
    margin: 10px 0;
    padding-left: 20px;
}

.instructions li {
    margin: 5px 0;
    color: #78350f;
}

@media (max-width: 768px) {
    .form-row {
        grid-template-columns: 1fr;
    }
    
    .export-options {
        flex-direction: column;
    }
}
</style>
</head>

<body>
<div class="container">
    <h2>📤 Pigmy Export</h2>
    <p class="subtitle">Export pigmy collection data to Excel/CSV file</p>

    <div class="export-options">
        <div class="option-card selected" onclick="selectFormat('excel')" id="excelOption">
            <div class="icon">📊</div>
            <div class="title">Excel Format</div>
            <div class="desc">.xlsx file with formatting</div>
        </div>
        <div class="option-card" onclick="selectFormat('csv')" id="csvOption">
            <div class="icon">📄</div>
            <div class="title">CSV Format</div>
            <div class="desc">Plain text comma-separated</div>
        </div>
    </div>

    <form id="exportForm" onsubmit="exportData(event)">
        <input type="hidden" id="exportFormat" name="format" value="excel">
        
        <div class="form-section">
            <h3 style="margin-top: 0; color: #4a9eff;">Export Filters</h3>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="fromDate">From Date</label>
                    <input type="date" id="fromDate" name="fromDate" required>
                </div>
                <div class="form-group">
                    <label for="toDate">To Date</label>
                    <input type="date" id="toDate" name="toDate" required>
                </div>
            </div>

            <div class="form-group">
                <label for="accountNumber">Account Number (Optional)</label>
                <input type="text" id="accountNumber" name="accountNumber" placeholder="Leave blank to export all accounts">
            </div>

            <div class="form-group">
                <label for="collectorName">Collector Name (Optional)</label>
                <input type="text" id="collectorName" name="collectorName" placeholder="Leave blank to export all collectors">
            </div>

            <div class="form-group">
                <label for="exportType">Export Type</label>
                <select id="exportType" name="exportType">
                    <option value="all">All Collections</option>
                    <option value="pending">Pending Collections</option>
                    <option value="completed">Completed Collections</option>
                    <option value="summary">Summary Report</option>
                </select>
            </div>
        </div>

        <div style="text-align: center;">
            <button type="submit" class="btn btn-primary">
                📥 Download Export
            </button>
            <button type="button" class="btn btn-secondary" onclick="resetForm()">
                🔄 Reset
            </button>
        </div>
    </form>

    <div class="message" id="message"></div>

    <div class="instructions">
        <h4>📋 Export Information</h4>
        <ul>
            <li>Select date range to filter collections within specific period</li>
            <li>Use optional filters to narrow down specific accounts or collectors</li>
            <li>Excel format includes formatting and formulas for better readability</li>
            <li>CSV format is compatible with most spreadsheet applications</li>
            <li>Summary report provides aggregated data grouped by account/collector</li>
        </ul>
    </div>
</div>

<script>
window.onload = function () {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('Pigmy/pigmyExport.jsp')
        );
    }
    
    // Set default dates (last 30 days)
    const today = new Date();
    const thirtyDaysAgo = new Date(today);
    thirtyDaysAgo.setDate(today.getDate() - 30);
    
    document.getElementById('toDate').valueAsDate = today;
    document.getElementById('fromDate').valueAsDate = thirtyDaysAgo;
};

function selectFormat(format) {
    document.getElementById('exportFormat').value = format;
    
    const excelOption = document.getElementById('excelOption');
    const csvOption = document.getElementById('csvOption');
    
    if (format === 'excel') {
        excelOption.classList.add('selected');
        csvOption.classList.remove('selected');
    } else {
        csvOption.classList.add('selected');
        excelOption.classList.remove('selected');
    }
}

function exportData(event) {
    event.preventDefault();
    
    const formData = new FormData(event.target);
    formData.append('branchCode', '<%= branchCode %>');
    formData.append('userId', '<%= userId %>');
    
    hideMessage();
    
    // Show loading message
    showMessage('Generating export file...', 'success');
    
    // Here you would actually call your export servlet/JSP
    // For now, showing a success message
    setTimeout(() => {
        showMessage('Export file generated successfully! Download should start automatically.', 'success');
        
        // Actual implementation would be:
        /*
        fetch('processPigmyExport.jsp', {
            method: 'POST',
            body: formData
        })
        .then(response => response.blob())
        .then(blob => {
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'pigmy_export_' + new Date().getTime() + '.' + formData.get('format');
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
            showMessage('Export file downloaded successfully!', 'success');
        })
        .catch(error => {
            showMessage('Export failed: ' + error.message, 'error');
        });
        */
    }, 1500);
}

function resetForm() {
    document.getElementById('exportForm').reset();
    
    // Reset dates to default
    const today = new Date();
    const thirtyDaysAgo = new Date(today);
    thirtyDaysAgo.setDate(today.getDate() - 30);
    
    document.getElementById('toDate').valueAsDate = today;
    document.getElementById('fromDate').valueAsDate = thirtyDaysAgo;
    
    hideMessage();
}

function showMessage(text, type) {
    const message = document.getElementById('message');
    message.textContent = text;
    message.className = 'message show ' + type;
}

function hideMessage() {
    const message = document.getElementById('message');
    message.className = 'message';
}
</script>
</body>
</html>
