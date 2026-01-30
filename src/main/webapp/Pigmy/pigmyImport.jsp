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
<title>Transaction Import</title>
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
input[type="file"],
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

.radio-group {
    display: flex;
    gap: 20px;
    align-items: center;
}

.radio-label {
    display: flex;
    align-items: center;
    gap: 8px;
    cursor: pointer;
    font-size: 14px;
    padding: 8px 14px;
    border: 2px solid #C8B7F6;
    border-radius: 8px;
    transition: all 0.3s ease;
    background: #F4EDFF;
    color: #3D316F;
}

.radio-label:hover {
    border-color: #8066E8;
    background: #E8DCFF;
}

.radio-label input[type="radio"] {
    cursor: pointer;
    width: 18px;
    height: 18px;
    accent-color: #8066E8;
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

.btn-secondary {
    background: #e5e7eb;
    color: #333;
}

.btn-secondary:hover {
    background: #d1d5db;
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

.message-box.info {
    background: #eff6ff;
    border-color: #93c5fd;
    color: #1e40af;
}

/* File input custom styling */
input[type="file"] {
    padding: 8px;
    background: white;
    cursor: pointer;
}

input[type="file"]::file-selector-button {
    background: #2D2B80;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 6px;
    cursor: pointer;
    margin-right: 10px;
}

input[type="file"]::file-selector-button:hover {
    background: #1a0548;
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
    
    .radio-group {
        flex-direction: column;
        align-items: flex-start;
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
    <form id="importForm">
        
        <!-- Transaction Details -->
        <fieldset>
            <legend>Transaction Details</legend>
            
            <!-- Row 1: Import From & Machine Type -->
            <div class="form-row">
                <div class="form-group">
                    <div class="label">Import From:</div>
                    <div class="radio-group">
                        <label class="radio-label">
                            <input type="radio" name="importFrom" value="Client" checked>
                            <span>Client</span>
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="importFrom" value="Server">
                            <span>Server</span>
                        </label>
                    </div>
                </div>
                
                <div class="form-group">
                    <div class="label">Machine Type:</div>
                    <div class="radio-group">
                        <label class="radio-label">
                            <input type="radio" name="machineType" value="Balaji">
                            <span>Balaji</span>
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="machineType" value="Pratinidhi">
                            <span>Pratinidhi</span>
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="machineType" value="Sai Balaji">
                            <span>Sai Balaji</span>
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="machineType" value="Others" checked>
                            <span>Others</span>
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="machineType" value="Balaji New">
                            <span>Balaji New</span>
                        </label>
                    </div>
                </div>
            </div>
            
            <!-- Row 2: Branch Code and Product Code -->
            <div class="form-row">
                <div class="form-group">
                    <label class="label">Branch Code</label>
                    <div class="input-box">
                        <input type="text" name="importBranchCode" id="importBranchCode" value="<%= branchCode %>" readonly>
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
            
        </fieldset>
        
        <!-- Transaction Details Section -->
        <fieldset>
            <legend>Transaction Details</legend>
            
            <!-- Client Import Button -->
            <div class="form-row">
                <div class="form-group">
                    <button type="button" class="btn btn-primary" onclick="document.getElementById('fileInput').click()">
                        Client_Import
                    </button>
                    <input type="file" id="fileInput" name="importFile" accept=".csv,.xlsx,.xls,.txt" style="display: none;" onchange="handleFileSelect(this)">
                </div>
            </div>
            
            <!-- Row with all transaction details -->
            <div class="form-row">
                <div class="form-group">
                    <label class="label">Transaction Type</label>
                    <div class="radio-group">
                        <label class="radio-label">
                            <input type="radio" name="transactionType" value="Credit" checked>
                            <span>Credit</span>
                        </label>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="label">Contra Account Head</label>
                    <div class="input-box">
                        <input type="text" name="contraAccountHead" id="contraAccountHead">
                        <button type="button" class="icon-btn">…</button>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="label">Description</label>
                    <input type="text" name="description" id="description" value="Invalid data" readonly>
                </div>
            </div>
            
            <!-- Row 2 -->
            <div class="form-row">
                <div class="form-group">
                    <label class="label">Total Amount</label>
                    <input type="text" name="totalAmount" id="totalAmount" readonly>
                </div>
                
                <div class="form-group">
                    <label class="label">Particular</label>
                    <input type="text" name="particular" id="particular">
                </div>
                
                <div class="form-group">
                    <label class="label">Contra Head Particular</label>
                    <input type="text" name="contraHeadParticular" id="contraHeadParticular">
                </div>
            </div>
            
            <!-- Row 3 -->
            <div class="form-row">
                <div class="form-group">
                    <label class="label">Advice No.</label>
                    <input type="text" name="adviceNo" id="adviceNo" value="0" readonly>
                </div>
                
                <div class="form-group">
                    <label class="label">Original/Responding</label>
                    <input type="text" name="originalResponding" id="originalResponding" value="O" readonly>
                </div>
                
                <div class="form-group">
                    <label class="label">Advice Date</label>
                    <input type="text" name="adviceDate" id="adviceDate" readonly>
                </div>
            </div>
            
            <!-- Row 4 -->
            <div class="form-row">
                <div class="form-group">
                    <label class="label">Recon.Code</label>
                    <div class="input-box">
                        <input type="text" name="reconCode" id="reconCode" value="0" readonly>
                        <button type="button" class="icon-btn">…</button>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="label">Description</label>
                    <input type="text" name="reconDescription" id="reconDescription" readonly>
                </div>
            </div>
            
        </fieldset>
        
        <!-- Message Box -->
        <div id="messageBox" class="message-box info" style="display: none;">
            <strong>Message:</strong> <span id="messageText"></span>
        </div>
        
        <!-- Action Buttons -->
        <div class="button-row">
            <button type="button" class="btn btn-validate" onclick="validateImport()">Validate</button>
            <button type="button" class="btn btn-secondary" onclick="displayData()">Display</button>
            <button type="button" class="btn btn-primary" onclick="importData()" disabled id="importBtn">Import</button>
            <button type="button" class="btn btn-secondary" onclick="checkAmount()">Check Amount</button>
            <button type="button" class="btn btn-secondary" onclick="createTransaction()" disabled id="createBtn">Create Transaction</button>
            <button type="button" class="btn btn-cancel" onclick="cancelImport()">Cancel</button>
        </div>
        
    </form>
    
    <!-- Import Details Table -->
    <fieldset style="margin-top: 30px;">
        <legend>TRANSACTION IMPORT DETAILS</legend>
        <div style="overflow-x: auto;">
            <table style="width: 100%; border-collapse: collapse; font-size: 12px;">
                <thead style="background: #373279; color: white;">
                    <tr>
                        <th style="padding: 10px; border: 1px solid #ddd;">Account Code</th>
                        <th style="padding: 10px; border: 1px solid #ddd;">Name</th>
                        <th style="padding: 10px; border: 1px solid #ddd;">Amount1</th>
                        <th style="padding: 10px; border: 1px solid #ddd;">Amount2</th>
                        <th style="padding: 10px; border: 1px solid #ddd;">Amount3</th>
                        <th style="padding: 10px; border: 1px solid #ddd;">Amount4</th>
                        <th style="padding: 10px; border: 1px solid #ddd;">Amount5</th>
                        <th style="padding: 10px; border: 1px solid #ddd;">Amount6</th>
                        <th style="padding: 10px; border: 1px solid #ddd;">Amount7</th>
                        <th style="padding: 10px; border: 1px solid #ddd;">Total Amount</th>
                    </tr>
                </thead>
                <tbody id="importDetailsTable">
                    <tr>
                        <td colspan="10" style="padding: 20px; text-align: center; color: #999;">No data imported yet</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </fieldset>
    
</div>

<script>
window.onload = function () {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('Pigmy/pigmyImport.jsp')
        );
    }
    
    // Load branch name
    loadBranchName();
};

function loadBranchName() {
    // Fetch branch name based on branch code
    const branchCode = document.getElementById('importBranchCode').value;
    if (branchCode) {
        // You can implement AJAX call here to fetch branch name
        document.getElementById('branchName').value = '';
    }
}

function handleFileSelect(input) {
    if (input.files && input.files[0]) {
        const file = input.files[0];
        const fileName = file.name;
        
        showMessage('File selected: ' + fileName, 'info');
        
        // Enable validate button
        document.querySelector('.btn-validate').disabled = false;
    }
}

function showMessage(text, type) {
    const messageBox = document.getElementById('messageBox');
    const messageText = document.getElementById('messageText');
    
    messageBox.className = 'message-box ' + type;
    messageText.textContent = text;
    messageBox.style.display = 'block';
}

function validateImport() {
    const fileInput = document.getElementById('fileInput');
    
    if (!fileInput.files || fileInput.files.length === 0) {
        showMessage('Please select a file to import', 'error');
        return;
    }
    
    // Simulate validation
    showMessage('Validating import file...', 'info');
    
    setTimeout(() => {
        showMessage('File validated successfully! Ready to import.', 'success');
        document.getElementById('importBtn').disabled = false;
    }, 1000);
}

function displayData() {
    showMessage('Displaying import data...', 'info');
    // Implement display logic
}

function importData() {
    showMessage('Importing data...', 'info');
    
    setTimeout(() => {
        showMessage('Data imported successfully!', 'success');
        document.getElementById('createBtn').disabled = false;
        
        // Add sample data to table
        const tbody = document.getElementById('importDetailsTable');
        tbody.innerHTML = `
            <tr style="background: #f9f9f9;">
                <td style="padding: 8px; border: 1px solid #ddd;">Sample Account</td>
                <td style="padding: 8px; border: 1px solid #ddd;">Test Customer</td>
                <td style="padding: 8px; border: 1px solid #ddd; text-align: right;">100.00</td>
                <td style="padding: 8px; border: 1px solid #ddd; text-align: right;">0.00</td>
                <td style="padding: 8px; border: 1px solid #ddd; text-align: right;">0.00</td>
                <td style="padding: 8px; border: 1px solid #ddd; text-align: right;">0.00</td>
                <td style="padding: 8px; border: 1px solid #ddd; text-align: right;">0.00</td>
                <td style="padding: 8px; border: 1px solid #ddd; text-align: right;">0.00</td>
                <td style="padding: 8px; border: 1px solid #ddd; text-align: right;">0.00</td>
                <td style="padding: 8px; border: 1px solid #ddd; text-align: right; font-weight: bold;">100.00</td>
            </tr>
        `;
    }, 1500);
}

function checkAmount() {
    showMessage('Checking amounts...', 'info');
}

function createTransaction() {
    if (confirm('Are you sure you want to create transactions from this import?')) {
        showMessage('Creating transactions...', 'info');
        
        setTimeout(() => {
            showMessage('Transactions created successfully!', 'success');
        }, 2000);
    }
}

function cancelImport() {
    if (confirm('Are you sure you want to cancel this import?')) {
        document.getElementById('importForm').reset();
        document.getElementById('importDetailsTable').innerHTML = `
            <tr>
                <td colspan="10" style="padding: 20px; text-align: center; color: #999;">No data imported yet</td>
            </tr>
        `;
        document.getElementById('messageBox').style.display = 'none';
        document.getElementById('importBtn').disabled = true;
        document.getElementById('createBtn').disabled = true;
    }
}
</script>
</body>
</html>