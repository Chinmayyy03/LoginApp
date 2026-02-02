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

table {
    width: 100%;
    border-collapse: collapse;
    font-size: 12px;
}

table thead {
    background: #373279;
    color: white;
}

table th,
table td {
    padding: 10px;
    border: 1px solid #ddd;
    text-align: left;
}

table td {
    text-align: right;
}

table td:first-child,
table td:nth-child(2) {
    text-align: left;
}

table tbody tr:nth-child(even) {
    background: #f9f9f9;
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
            
            <!-- Row 1: Import From & Transaction Type -->
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
                    <label class="label">Transaction Type:</label>
                    <select name="transactionType" id="transactionTypeDropdown" onchange="loadTransactionType()">
                        <option value="">-- Select Transaction Type --</option>
                        <%
                        Connection conn2 = null;
                        PreparedStatement pstmt2 = null;
                        ResultSet rs2 = null;
                        
                        try {
                            conn2 = DBConnection.getConnection();
                            String sql = "SELECT TRANSACTIONIDENTIFICATION_ID, DESCRIPTION FROM HEADOFFICE.TRANSACTIONIDENTIFICATION ORDER BY DESCRIPTION";
                            pstmt2 = conn2.prepareStatement(sql);
                            rs2 = pstmt2.executeQuery();
                            
                            while (rs2.next()) {
                                int txnId = rs2.getInt("TRANSACTIONIDENTIFICATION_ID");
                                String desc = rs2.getString("DESCRIPTION");
                        %>
                                <option value="<%= txnId %>"><%= desc %></option>
                        <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        } finally {
                            try {
                                if (rs2 != null) rs2.close();
                                if (pstmt2 != null) pstmt2.close();
                                if (conn2 != null) conn2.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                        }
                        %>
                    </select>
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
            
            <!-- Upload File Button -->
            <div class="form-row">
                <div class="form-group">
                    <button type="button" class="btn btn-primary" onclick="document.getElementById('fileInput').click()">
                        Upload File
                    </button>
                    <input type="file" id="fileInput" name="importFile" accept=".csv,.dat,.txt" style="display: none;" onchange="handleFileSelect(this)">
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
        
        <!-- First Line Data Table (for .dat files) -->
        <fieldset id="firstLineSection" style="display: none; margin-top: 20px;">
            <legend>FIRST LINE DATA (Metadata)</legend>
            <div style="overflow-x: auto;">
                <table>
                    <thead style="background: #373279; color: white;">
                        <tr id="firstLineHeader">
                        </tr>
                    </thead>
                    <tbody id="firstLineBody">
                    </tbody>
                </table>
            </div>
        </fieldset>
        
        <!-- Action Buttons -->
        <div class="button-row">
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
            <table id="importTable">
                <thead>
                    <tr id="tableHeader">
                        <th>Loading...</th>
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
            window.buildBreadcrumbPath('Pigmy/import.jsp')
        );
    }
};

function loadTransactionType() {
    const dropdown = document.getElementById('transactionTypeDropdown');
    const selectedValue = dropdown.value;
    const selectedText = dropdown.options[dropdown.selectedIndex].text;
    
    if (selectedValue) {
        showMessage('Transaction Type selected: ' + selectedText, 'info');
    }
}

function handleFileSelect(input) {
    if (input.files && input.files[0]) {
        const file = input.files[0];
        const fileName = file.name;
        
        showMessage('File selected: ' + fileName + '. Reading file...', 'info');
        
        // Read and parse the file
        const reader = new FileReader();
        reader.onload = function(e) {
            const content = e.target.result;
            parseAndDisplayFile(content, fileName);
        };
        reader.readAsText(file);
    }
}

function parseAndDisplayFile(content, fileName) {
    try {
        const lines = content.split('\n').filter(line => line.trim() !== '');
        
        if (lines.length === 0) {
            showMessage('File is empty', 'error');
            return;
        }
        
        // Check if it's a .dat file
        const isDatFile = fileName.toLowerCase().endsWith('.dat');
        
        let dataLines = lines;
        let firstLineData = null;
        
        // For .dat files, separate and display the first line in a separate table
        if (isDatFile && lines.length > 0) {
            firstLineData = lines[0].split(',').map(cell => cell.trim());
            dataLines = lines.slice(1);
            
            // Show first line section
            document.getElementById('firstLineSection').style.display = 'block';
            
            // Create header for first line table (blank headers)
            const firstLineHeader = document.getElementById('firstLineHeader');
            firstLineHeader.innerHTML = '';
            firstLineData.forEach(() => {
                const th = document.createElement('th');
                th.textContent = ''; // Blank header
                th.style.padding = '10px';
                th.style.border = '1px solid #ddd';
                firstLineHeader.appendChild(th);
            });
            
            // Create body for first line table
            const firstLineBody = document.getElementById('firstLineBody');
            firstLineBody.innerHTML = '';
            const tr = document.createElement('tr');
            tr.style.background = '#f9f9f9';
            firstLineData.forEach(value => {
                const td = document.createElement('td');
                td.textContent = value;
                td.style.padding = '8px';
                td.style.border = '1px solid #ddd';
                tr.appendChild(td);
            });
            firstLineBody.appendChild(tr);
            
            showMessage('DAT file detected. First line separated and displayed above.', 'info');
        } else {
            // Hide first line section for non-.dat files
            document.getElementById('firstLineSection').style.display = 'none';
        }
        
        if (dataLines.length === 0) {
            showMessage('No data found in file', 'error');
            return;
        }
        
        // Parse the data (comma-separated)
        const parsedData = dataLines.map(line => {
            return line.split(',').map(cell => cell.trim());
        });
        
        if (parsedData.length === 0) {
            showMessage('No data rows found in file', 'error');
            return;
        }
        
        // Determine number of columns
        const maxColumns = Math.max(...parsedData.map(row => row.length));
        
        // Create table header (blank column names)
        const tableHeaderRow = document.getElementById('tableHeader');
        tableHeaderRow.innerHTML = '';
        
        for (let i = 0; i < maxColumns; i++) {
            const th = document.createElement('th');
            th.textContent = ''; // Blank column names
            th.style.padding = '10px';
            th.style.border = '1px solid #ddd';
            tableHeaderRow.appendChild(th);
        }
        
        // Populate table body
        const tbody = document.getElementById('importDetailsTable');
        tbody.innerHTML = '';
        
        parsedData.forEach((row, index) => {
            const tr = document.createElement('tr');
            tr.style.background = index % 2 === 0 ? '#f9f9f9' : 'white';
            
            for (let i = 0; i < maxColumns; i++) {
                const td = document.createElement('td');
                td.textContent = row[i] || '';
                td.style.padding = '8px';
                td.style.border = '1px solid #ddd';
                tr.appendChild(td);
            }
            
            tbody.appendChild(tr);
        });
        
        // Calculate total amount (assuming last column is amount)
        let totalAmount = 0;
        parsedData.forEach(row => {
            const lastValue = row[row.length - 1];
            const amount = parseFloat(lastValue);
            if (!isNaN(amount)) {
                totalAmount += amount;
            }
        });
        
        document.getElementById('totalAmount').value = totalAmount.toFixed(2);
        
        let successMsg = 'File loaded successfully! ' + parsedData.length + ' records found.';
        if (isDatFile) {
            successMsg += ' (First line displayed separately)';
        }
        showMessage(successMsg, 'success');
        document.getElementById('importBtn').disabled = false;
        
    } catch (error) {
        showMessage('Error parsing file: ' + error.message, 'error');
        console.error(error);
    }
}

function showMessage(text, type) {
    const messageBox = document.getElementById('messageBox');
    const messageText = document.getElementById('messageText');
    
    messageBox.className = 'message-box ' + type;
    messageText.textContent = text;
    messageBox.style.display = 'block';
}

function displayData() {
    const tbody = document.getElementById('importDetailsTable');
    if (tbody.children.length === 0 || tbody.children[0].cells.length === 1) {
        showMessage('No data to display. Please upload a file first.', 'error');
    } else {
        showMessage('Displaying ' + tbody.children.length + ' records', 'info');
    }
}

function importData() {
    showMessage('Importing data...', 'info');
    
    setTimeout(() => {
        showMessage('Data imported successfully!', 'success');
        document.getElementById('createBtn').disabled = false;
    }, 1500);
}

function checkAmount() {
    const totalAmount = document.getElementById('totalAmount').value;
    if (totalAmount) {
        showMessage('Total Amount: ₹' + totalAmount, 'info');
    } else {
        showMessage('No amount to check. Please upload a file first.', 'error');
    }
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
        
        const headerRow = document.getElementById('tableHeader');
        headerRow.innerHTML = '<th>Loading...</th>';
        
        document.getElementById('importDetailsTable').innerHTML = `
            <tr>
                <td colspan="10" style="padding: 20px; text-align: center; color: #999;">No data imported yet</td>
            </tr>
        `;
        
        // Hide and reset first line section
        document.getElementById('firstLineSection').style.display = 'none';
        document.getElementById('firstLineHeader').innerHTML = '';
        document.getElementById('firstLineBody').innerHTML = '';
        
        document.getElementById('messageBox').style.display = 'none';
        document.getElementById('importBtn').disabled = true;
        document.getElementById('createBtn').disabled = true;
        document.getElementById('totalAmount').value = '';
    }
}
</script>
</body>
</html>
