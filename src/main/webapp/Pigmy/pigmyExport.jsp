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
    
    // Get bank name and working date from session
    String bankName = (String) session.getAttribute("bankName");
    String workingDate = "";
    if (session.getAttribute("workingDate") != null) {
        workingDate = new SimpleDateFormat("dd-MMM-yyyy").format((java.util.Date)session.getAttribute("workingDate"));
    }
    
    if (bankName == null) bankName = "Bank Name";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Transaction Export</title>
<script src="<%= request.getContextPath() %>/js/breadcrumb-auto.js"></script>
<style>
* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
    background: #e8e4fc;
    color: #1a1a1a;
}

.page-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 20px 40px;
    text-align: center;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.page-header h1 {
    margin: 0;
    font-size: 28px;
    font-weight: bold;
    letter-spacing: 1px;
}

.header-info {
    display: flex;
    justify-content: space-between;
    background: white;
    padding: 12px 40px;
    font-size: 14px;
    color: #3D316F;
    box-shadow: 0 2px 5px rgba(0,0,0,0.05);
}

.header-info span {
    font-weight: bold;
}

.container {
    max-width: 1400px;
    margin: 20px auto;
    padding: 0 20px;
}

fieldset {
    background-color: white;
    border: 2px solid #BBADED;
    border-radius: 12px;
    padding: 25px;
    margin-bottom: 20px;
}

legend {
    font-size: 18px;
    font-weight: bold;
    padding: 0 10px;
    color: #3D316F;
}

.form-row {
    display: flex;
    gap: 25px;
    margin-bottom: 20px;
    align-items: flex-end;
}

.form-group {
    flex: 1;
}

.label {
    font-weight: bold;
    font-size: 14px;
    color: #3D316F;
    margin-bottom: 8px;
    display: block;
}

.input-box {
    display: flex;
    align-items: center;
    gap: 10px;
}

input[type="text"],
select {
    padding: 10px 12px;
    border: 2px solid #C8B7F6;
    border-radius: 8px;
    background-color: #F4EDFF;
    outline: none;
    font-size: 14px;
    width: 100%;
}

input[type="text"]:focus,
select:focus {
    border-color: #8066E8;
}

input[type="text"]:read-only {
    background-color: #f5f5f5;
    cursor: not-allowed;
}

select {
    cursor: pointer;
    color: #3D316F;
    font-weight: 600;
}

.icon-btn {
    background-color: #2D2B80;
    color: white;
    border: none;
    width: 35px;
    height: 35px;
    border-radius: 8px;
    font-size: 18px;
    cursor: pointer;
    flex-shrink: 0;
}

.icon-btn:hover {
    background-color: #3D316F;
}

.btn {
    padding: 12px 24px;
    border: none;
    border-radius: 8px;
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

.btn-validate {
    background: #2b0d73;
    color: white;
}

.btn-validate:hover {
    background: #1a0548;
    transform: translateY(-2px);
}

.btn-cancel {
    background: #dc2626;
    color: white;
}

.btn-cancel:hover {
    background: #b91c1c;
}

.button-row {
    display: flex;
    justify-content: center;
    gap: 15px;
    margin-top: 30px;
}

.message-box {
    margin-top: 20px;
    padding: 15px;
    border-radius: 8px;
    border: 2px solid;
    min-height: 60px;
}

.message-box.info {
    background: #eff6ff;
    border-color: #93c5fd;
    color: #1e40af;
}

.message-box.success {
    background: #f0fdf4;
    border-color: #86efac;
    color: #166534;
}

.message-box.error {
    background: #fef2f2;
    border-color: #fca5a5;
    color: #991b1b;
}

@media (max-width: 768px) {
    .form-row {
        flex-direction: column;
        gap: 15px;
    }
    
    .header-info {
        flex-direction: column;
        gap: 8px;
        text-align: center;
    }
    
    .button-row {
        flex-direction: column;
    }
    
    .btn {
        width: 100%;
    }
}
</style>
</head>

<body>
<div class="container">
    <form id="exportForm">
        
        <!-- Transaction Details -->
        <fieldset>
            <legend>Transaction Details</legend>
            
            <!-- Row 1: Branch Code, Product Code, Agent ID -->
            <div class="form-row">
                <div class="form-group">
                    <label class="label">Branch Code</label>
                    <div class="input-box">
                        <input type="text" name="exportBranchCode" id="exportBranchCode" value="<%= branchCode %>">
                        <button type="button" class="icon-btn">…</button>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="label">Name</label>
                    <input type="text" name="branchName" id="branchName" readonly>
                </div>
                
                <div class="form-group">
                    <label class="label">Product Code</label>
                    <div class="input-box">
                        <input type="text" name="productCode" id="productCode" maxlength="3">
                        <button type="button" class="icon-btn">…</button>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="label">Description</label>
                    <input type="text" name="productDescription" id="productDescription" readonly>
                </div>
            </div>
            
            <!-- Row 2: Agent ID -->
            <div class="form-row">
                <div class="form-group">
                    <label class="label">Agent ID</label>
                    <div class="input-box">
                        <input type="text" name="agentId" id="agentId">
                        <button type="button" class="icon-btn">…</button>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="label">Name</label>
                    <input type="text" name="agentName" id="agentName" readonly>
                </div>
            </div>
            
        </fieldset>
        
        <!-- Message Box -->
        <div id="messageBox" class="message-box info">
            <strong>Message:</strong> <span id="messageText"></span>
        </div>
        
        <!-- Action Buttons -->
        <div class="button-row">
            <button type="button" class="btn btn-validate" onclick="validateExport()">Validate</button>
            <button type="button" class="btn btn-primary" onclick="exportToClient()">Client_Export</button>
            <button type="button" class="btn btn-cancel" onclick="cancelExport()">Cancel</button>
        </div>
        
    </form>
    
</div>

<script>
window.onload = function () {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('Pigmy/pigmyExport.jsp')
        );
    }
    
    // Load branch name
    loadBranchName();
    
    // Set initial message
    showMessage('Please fill in the required details and click Validate');
};

function loadBranchName() {
    // Fetch branch name based on branch code
    const branchCode = document.getElementById('exportBranchCode').value;
    if (branchCode) {
        // You can implement AJAX call here to fetch branch name
        document.getElementById('branchName').value = '';
    }
}

function showMessage(text, type) {
    const messageBox = document.getElementById('messageBox');
    const messageText = document.getElementById('messageText');
    
    if (type) {
        messageBox.className = 'message-box ' + type;
    }
    messageText.textContent = text;
    messageBox.style.display = 'block';
}

function validateExport() {
    const branchCode = document.getElementById('exportBranchCode').value.trim();
    const productCode = document.getElementById('productCode').value.trim();
    
    if (!branchCode) {
        showMessage('Please enter Branch Code', 'error');
        return;
    }
    
    if (!productCode) {
        showMessage('Please enter Product Code', 'error');
        return;
    }
    
    // Simulate validation
    showMessage('Validating export parameters...', 'info');
    
    setTimeout(() => {
        showMessage('Validation successful! Ready to export.', 'success');
    }, 1000);
}

function exportToClient() {
    const branchCode = document.getElementById('exportBranchCode').value.trim();
    const productCode = document.getElementById('productCode').value.trim();
    
    if (!branchCode || !productCode) {
        showMessage('Please validate the form before exporting', 'error');
        return;
    }
    
    showMessage('Generating export file...', 'info');
    
    setTimeout(() => {
        // Create a sample CSV content
        const csvContent = "Account Code,Customer Name,Agent ID,Collection Date,Amount\n" +
                          "000200010001,Test Customer 1,AG001,30/01/2026,500.00\n" +
                          "000200010002,Test Customer 2,AG001,30/01/2026,750.00\n" +
                          "000200010003,Test Customer 3,AG001,30/01/2026,1000.00";
        
        // Create blob and download
        const blob = new Blob([csvContent], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'pigmy_export_' + new Date().getTime() + '.csv';
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
        
        showMessage('Export file downloaded successfully!', 'success');
    }, 1500);
}

function cancelExport() {
    if (confirm('Are you sure you want to cancel?')) {
        document.getElementById('exportForm').reset();
        document.getElementById('exportBranchCode').value = '<%= branchCode %>';
        showMessage('Please fill in the required details and click Validate', 'info');
    }
}
</script>
</body>
</html>
