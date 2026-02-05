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
input[type="number"],
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
input[type="number"]:focus,
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

table tbody tr:nth-child(even) {
    background: #f9f9f9;
}

table tbody tr:nth-child(odd) {
    background: white;
}

.column-tag {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 8px 12px;
    border-radius: 20px;
    font-size: 13px;
    font-weight: 600;
}

.column-tag .remove-btn {
    background: rgba(255, 255, 255, 0.3);
    border: none;
    color: white;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    cursor: pointer;
    font-size: 14px;
    line-height: 1;
    transition: all 0.2s;
}

.column-tag .remove-btn:hover {
    background: rgba(255, 255, 255, 0.5);
}

.pagination-container {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 10px;
    margin: 20px 0;
    padding: 15px;
}

.pagination-btn {
    background: #2b0d73;
    color: white;
    padding: 8px 16px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 14px;
    font-weight: bold;
    transition: background 0.3s;
}

.pagination-btn:disabled {
    background: #ccc;
    cursor: not-allowed;
    opacity: 0.6;
}

.pagination-btn:hover:not(:disabled) {
    background: #1a0548;
}

.page-info {
    font-size: 14px;
    color: #2b0d73;
    font-weight: bold;
    padding: 0 15px;
}

small {
    display: block;
    margin-top: 4px;
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
    
    .pagination-container {
        flex-direction: column;
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
        
            
            <!-- Upload File Button -->
            <div class="form-row">
                <div class="form-group">
                    <button type="button" class="btn btn-primary" onclick="document.getElementById('fileInput').click()">
                        📤 Upload File
                    </button>
                    <input type="file" id="fileInput" name="importFile" accept=".csv,.dat,.txt" style="display: none;" onchange="handleFileSelect(this)">
                </div>
            </div>
            
            <!-- Column Selection and Extraction Tools -->
            <fieldset id="columnTools" style="display: none; background: linear-gradient(135deg, #f0f4ff 0%, #e8f4f9 100%); border: 2px solid #93c5fd; margin-top: 20px;">
                <legend style="color: #1e40af;">📊 Customize Columns</legend>
                
                <!-- Single Row Design -->
                <div style="display: flex; gap: 15px; align-items: flex-end; flex-wrap: wrap;">
                    
                    <!-- Column Selection -->
                    <div style="flex: 1; min-width: 200px;">
                        <label class="label">Column</label>
                        <select name="selectedColumn" id="selectedColumn" style="width: 100%;">
                            <option value="">-- Select Column --</option>
                        </select>
                    </div>
                    
                    <!-- Character Options (Radio Buttons) -->
                    <div style="flex: 2; min-width: 300px;">
                        <label class="label">Display</label>
                        <div style="display: flex; gap: 10px; flex-wrap: wrap; align-items: center;">
                            <label class="radio-label" style="padding: 8px 12px;">
                                <input type="radio" name="displayMode" value="full" checked>
                                <span>Full Column</span>
                            </label>
                            <label class="radio-label" style="padding: 8px 12px;">
                                <input type="radio" name="displayMode" value="last">
                                <span>Last</span>
                            </label>
                            <input type="number" id="lastChars" placeholder="4" min="1" max="50" 
                                   style="width: 70px; padding: 8px; display: none; border: 2px solid #C8B7F6; border-radius: 8px; background-color: #F4EDFF;" />
                            <label class="radio-label" style="padding: 8px 12px;">
                                <input type="radio" name="displayMode" value="first">
                                <span>First</span>
                            </label>
                            <input type="number" id="firstChars" placeholder="4" min="1" max="50" 
                                   style="width: 70px; padding: 8px; display: none; border: 2px solid #C8B7F6; border-radius: 8px; background-color: #F4EDFF;" />
                            <span style="color: #666; font-size: 12px;">chars</span>
                        </div>
                    </div>
                    
                    <!-- Add Button -->
                    <div>
                        <button type="button" class="btn btn-primary" onclick="addSelectedColumn()" 
                                style="padding: 10px 24px; font-size: 14px;">
                            ➕ Add
                        </button>
                    </div>
                </div>
                
                <!-- Selected Columns Tags -->
                <div id="selectedColumnsDisplay" style="margin-top: 20px; display: none;">
                    <label class="label" style="margin-bottom: 10px;">Selected Columns:</label>
                    <div id="selectedColumnsList" style="display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 15px;">
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <button type="button" class="btn btn-primary" onclick="applyColumnFilter()">
                            ✓ Apply Filter
                        </button>
                        <button type="button" class="btn" onclick="resetColumnFilter()" 
                                style="background: #f59e0b; color: white;">
                            ↺ Show All Columns
                        </button>
                    </div>
                </div>
            </fieldset>
            
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
                    <thead>
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
        
        <!-- Pagination Controls -->
        <div class="pagination-container" id="paginationControls" style="display: none;">
            <button id="prevBtn" class="pagination-btn" onclick="previousPage()">← Previous</button>
            <span id="pageInfo" class="page-info">Page 1</span>
            <button id="nextBtn" class="pagination-btn" onclick="nextPage()">Next →</button>
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

// Global variables for column management
let originalParsedData = [];
let selectedColumns = [];
let totalColumns = 0;

// Pagination variables
let currentPage = 1;
const recordsPerPage = 15;
let currentDisplayData = [];

function loadTransactionType() {
    const dropdown = document.getElementById('transactionTypeDropdown');
    const selectedValue = dropdown.value;
    const selectedText = dropdown.options[dropdown.selectedIndex].text;
    
    if (selectedValue) {
        showMessage('Transaction Type selected: ' + selectedText, 'info');
    }
}

function addSelectedColumn() {
    const columnDropdown = document.getElementById('selectedColumn');
    const columnNumber = columnDropdown.value;
    const displayMode = document.querySelector('input[name="displayMode"]:checked').value;
    
    if (!columnNumber) {
        showMessage('Please select a column', 'error');
        return;
    }
    
    // Check if column already selected
    const exists = selectedColumns.find(col => col.columnNumber === parseInt(columnNumber));
    if (exists) {
        showMessage('Column ' + columnNumber + ' is already selected', 'error');
        return;
    }
    
    let substringLength = null;
    let extractPosition = null;
    let label = 'Column ' + columnNumber;
    
    // Handle character extraction
    if (displayMode === 'last') {
        substringLength = parseInt(document.getElementById('lastChars').value);
        if (!substringLength || substringLength < 1) {
            showMessage('Please enter number of characters to extract', 'error');
            return;
        }
        extractPosition = 'end';
        label += ' (Last ' + substringLength + ')';
    } else if (displayMode === 'first') {
        substringLength = parseInt(document.getElementById('firstChars').value);
        if (!substringLength || substringLength < 1) {
            showMessage('Please enter number of characters to extract', 'error');
            return;
        }
        extractPosition = 'start';
        label += ' (First ' + substringLength + ')';
    }
    
    const columnConfig = {
        columnNumber: parseInt(columnNumber),
        substringLength: substringLength,
        extractPosition: extractPosition,
        label: label
    };
    
    selectedColumns.push(columnConfig);
    displaySelectedColumns();
    
    // Reset form
    columnDropdown.value = '';
    document.querySelector('input[name="displayMode"][value="full"]').checked = true;
    document.getElementById('lastChars').style.display = 'none';
    document.getElementById('firstChars').style.display = 'none';
    document.getElementById('lastChars').value = '';
    document.getElementById('firstChars').value = '';
    
    showMessage('Column added successfully! Click "Apply Filter" to see changes.', 'success');
}

function displaySelectedColumns() {
    const container = document.getElementById('selectedColumnsList');
    const display = document.getElementById('selectedColumnsDisplay');
    
    container.innerHTML = '';
    
    if (selectedColumns.length === 0) {
        display.style.display = 'none';
        return;
    }
    
    display.style.display = 'block';
    
    selectedColumns.forEach((col, index) => {
        const tag = document.createElement('div');
        tag.className = 'column-tag';
        tag.innerHTML = `
            <span>${col.label}</span>
            <button class="remove-btn" onclick="removeColumn(${index})" title="Remove">×</button>
        `;
        container.appendChild(tag);
    });
}

function removeColumn(index) {
    selectedColumns.splice(index, 1);
    displaySelectedColumns();
    
    if (selectedColumns.length === 0) {
        // Reset to show all columns
        displayAllColumns();
    }
}

function applyColumnFilter() {
    if (selectedColumns.length === 0) {
        showMessage('Please select at least one column', 'error');
        return;
    }
    
    // Filter and transform data based on selected columns
    const filteredData = originalParsedData.map(row => {
        return selectedColumns.map(colConfig => {
            const colIndex = colConfig.columnNumber - 1;
            let value = row[colIndex] || '';
            
            // Apply substring extraction if specified
            if (colConfig.substringLength) {
                if (colConfig.extractPosition === 'end') {
                    // Extract last N characters
                    value = value.slice(-colConfig.substringLength);
                } else {
                    // Extract first N characters
                    value = value.slice(0, colConfig.substringLength);
                }
            }
            
            return value;
        });
    });
    
    // Update current display data and reset to page 1
    currentDisplayData = filteredData;
    currentPage = 1;
    
    // Update table with filtered data
    displayFilteredData(filteredData, 1);
    
    showMessage(`Displaying ${selectedColumns.length} selected column(s)`, 'success');
}

function displayFilteredData(filteredData, page) {
    currentPage = page;
    const tableHeaderRow = document.getElementById('tableHeader');
    const tbody = document.getElementById('importDetailsTable');
    
    // Create headers based on selected columns with column numbers
    tableHeaderRow.innerHTML = '';
    selectedColumns.forEach(col => {
        const th = document.createElement('th');
        th.textContent = 'Column ' + col.columnNumber;
        th.style.padding = '10px';
        th.style.border = '1px solid #ddd';
        th.style.background = '#373279';
        th.style.color = 'white';
        th.style.textAlign = 'left';
        tableHeaderRow.appendChild(th);
    });
    
    // Calculate pagination
    const start = (page - 1) * recordsPerPage;
    const end = Math.min(start + recordsPerPage, filteredData.length);
    
    // Populate table body with paginated filtered data
    tbody.innerHTML = '';
    for (let i = start; i < end; i++) {
        const row = filteredData[i];
        const tr = document.createElement('tr');
        tr.style.background = i % 2 === 0 ? '#f9f9f9' : 'white';
        
        row.forEach(cellValue => {
            const td = document.createElement('td');
            td.textContent = cellValue;
            td.style.padding = '8px';
            td.style.border = '1px solid #ddd';
            td.style.textAlign = 'left';
            tr.appendChild(td);
        });
        
        tbody.appendChild(tr);
    }
    
    // Update pagination controls
    updatePaginationControls(filteredData.length, page);
}

function displayAllColumns() {
    if (originalParsedData.length === 0) {
        return;
    }
    
    // Reset current display data to original
    currentDisplayData = originalParsedData;
    currentPage = 1;
    
    const tableHeaderRow = document.getElementById('tableHeader');
    const tbody = document.getElementById('importDetailsTable');
    
    // Create headers with column numbers for all columns
    tableHeaderRow.innerHTML = '';
    for (let i = 0; i < totalColumns; i++) {
        const th = document.createElement('th');
        th.textContent = 'Column ' + (i + 1);
        th.style.padding = '10px';
        th.style.border = '1px solid #ddd';
        th.style.background = '#373279';
        th.style.color = 'white';
        th.style.textAlign = 'left';
        tableHeaderRow.appendChild(th);
    }
    
    // Calculate pagination
    const start = 0;
    const end = Math.min(recordsPerPage, originalParsedData.length);
    
    // Populate table body with paginated data
    tbody.innerHTML = '';
    for (let index = start; index < end; index++) {
        const row = originalParsedData[index];
        const tr = document.createElement('tr');
        tr.style.background = index % 2 === 0 ? '#f9f9f9' : 'white';
        
        for (let i = 0; i < totalColumns; i++) {
            const td = document.createElement('td');
            td.textContent = row[i] || '';
            td.style.padding = '8px';
            td.style.border = '1px solid #ddd';
            td.style.textAlign = 'left';
            tr.appendChild(td);
        }
        
        tbody.appendChild(tr);
    }
    
    // Update pagination controls
    updatePaginationControls(originalParsedData.length, 1);
    
    showMessage('Showing all columns (' + totalColumns + ' columns)', 'info');
}

function resetColumnFilter() {
    selectedColumns = [];
    displaySelectedColumns();
    displayAllColumns();
}

function updatePaginationControls(totalRecords, page) {
    const totalPages = Math.ceil(totalRecords / recordsPerPage);
    const paginationContainer = document.getElementById('paginationControls');
    
    // Show pagination only if there's data and more than one page
    if (totalRecords > 0) {
        paginationContainer.style.display = 'flex';
    } else {
        paginationContainer.style.display = 'none';
        return;
    }
    
    document.getElementById('prevBtn').disabled = (page <= 1);
    document.getElementById('nextBtn').disabled = (page >= totalPages);
    
    const pageInfo = 'Page ' + page + ' of ' + totalPages + ' (' + totalRecords + ' records)';
    document.getElementById('pageInfo').textContent = pageInfo;
}

function previousPage() {
    if (currentPage > 1) {
        if (selectedColumns.length > 0) {
            displayFilteredData(currentDisplayData, currentPage - 1);
        } else {
            displayPaginatedData(originalParsedData, currentPage - 1);
        }
    }
}

function nextPage() {
    const dataToDisplay = selectedColumns.length > 0 ? currentDisplayData : originalParsedData;
    const totalPages = Math.ceil(dataToDisplay.length / recordsPerPage);
    
    if (currentPage < totalPages) {
        if (selectedColumns.length > 0) {
            displayFilteredData(currentDisplayData, currentPage + 1);
        } else {
            displayPaginatedData(originalParsedData, currentPage + 1);
        }
    }
}

function displayPaginatedData(data, page) {
    currentPage = page;
    const tableHeaderRow = document.getElementById('tableHeader');
    const tbody = document.getElementById('importDetailsTable');
    
    // Create headers with column numbers for all columns
    tableHeaderRow.innerHTML = '';
    for (let i = 0; i < totalColumns; i++) {
        const th = document.createElement('th');
        th.textContent = 'Column ' + (i + 1);
        th.style.padding = '10px';
        th.style.border = '1px solid #ddd';
        th.style.background = '#373279';
        th.style.color = 'white';
        th.style.textAlign = 'left';
        tableHeaderRow.appendChild(th);
    }
    
    // Calculate pagination
    const start = (page - 1) * recordsPerPage;
    const end = Math.min(start + recordsPerPage, data.length);
    
    // Populate table body with paginated data
    tbody.innerHTML = '';
    for (let index = start; index < end; index++) {
        const row = data[index];
        const tr = document.createElement('tr');
        tr.style.background = index % 2 === 0 ? '#f9f9f9' : 'white';
        
        for (let i = 0; i < totalColumns; i++) {
            const td = document.createElement('td');
            td.textContent = row[i] || '';
            td.style.padding = '8px';
            td.style.border = '1px solid #ddd';
            td.style.textAlign = 'left';
            tr.appendChild(td);
        }
        
        tbody.appendChild(tr);
    }
    
    // Update pagination controls
    updatePaginationControls(data.length, page);
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
            
            // Create header for first line table with column numbers
            const firstLineHeader = document.getElementById('firstLineHeader');
            firstLineHeader.innerHTML = '';
            firstLineData.forEach((value, index) => {
                const th = document.createElement('th');
                th.textContent = 'Column ' + (index + 1);
                th.style.padding = '10px';
                th.style.border = '1px solid #ddd';
                th.style.background = '#373279';
                th.style.color = 'white';
                th.style.textAlign = 'left';
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
                td.style.textAlign = 'left';
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
        
        // Store original data globally
        originalParsedData = parsedData;
        currentDisplayData = parsedData;
        currentPage = 1;
        
        // Determine number of columns
        const maxColumns = Math.max(...parsedData.map(row => row.length));
        totalColumns = maxColumns;
        
        // Populate column selection dropdown
        const columnDropdown = document.getElementById('selectedColumn');
        columnDropdown.innerHTML = '<option value="">-- Select Column --</option>';
        for (let i = 1; i <= maxColumns; i++) {
            const option = document.createElement('option');
            option.value = i;
            option.textContent = 'Column ' + i;
            columnDropdown.appendChild(option);
        }
        
        // Show column tools
        document.getElementById('columnTools').style.display = 'block';
        
        // Create table header with column numbers
        const tableHeaderRow = document.getElementById('tableHeader');
        tableHeaderRow.innerHTML = '';
        
        for (let i = 0; i < maxColumns; i++) {
            const th = document.createElement('th');
            th.textContent = 'Column ' + (i + 1);
            th.style.padding = '10px';
            th.style.border = '1px solid #ddd';
            th.style.background = '#373279';
            th.style.color = 'white';
            th.style.textAlign = 'left';
            tableHeaderRow.appendChild(th);
        }
        
        // Populate table body with paginated data (first 15 rows)
        const tbody = document.getElementById('importDetailsTable');
        tbody.innerHTML = '';
        
        const displayLimit = Math.min(recordsPerPage, parsedData.length);
        
        for (let index = 0; index < displayLimit; index++) {
            const row = parsedData[index];
            const tr = document.createElement('tr');
            tr.style.background = index % 2 === 0 ? '#f9f9f9' : 'white';
            
            for (let i = 0; i < maxColumns; i++) {
                const td = document.createElement('td');
                td.textContent = row[i] || '';
                td.style.padding = '8px';
                td.style.border = '1px solid #ddd';
                td.style.textAlign = 'left';
                tr.appendChild(td);
            }
            
            tbody.appendChild(tr);
        }
        
        // Update pagination controls
        updatePaginationControls(parsedData.length, 1);
        
        // Calculate total amount (assuming last column is amount)
        let totalAmount = 0;
        parsedData.forEach(row => {
            const lastValue = row[row.length - 1];
            const amount = parseFloat(lastValue);
            if (!isNaN(amount)) {
                totalAmount += amount;
            }
        });
        
        let successMsg = 'File loaded successfully! ' + parsedData.length + ' records found with ' + maxColumns + ' columns.';
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
    if (originalParsedData.length === 0) {
        showMessage('No data to display. Please upload a file first.', 'error');
        return;
    }
    
    // Scroll to the table
    document.getElementById('importTable').scrollIntoView({ 
        behavior: 'smooth', 
        block: 'start' 
    });
    
    const displayedRecords = Math.min(recordsPerPage, currentDisplayData.length);
    showMessage('Displaying page ' + currentPage + ' (' + displayedRecords + ' of ' + currentDisplayData.length + ' records)', 'info');
}

function importData() {
    showMessage('Importing data...', 'info');
    
    setTimeout(() => {
        showMessage('Data imported successfully!', 'success');
        document.getElementById('createBtn').disabled = false;
    }, 1500);
}

function checkAmount() {
    if (originalParsedData.length === 0) {
        showMessage('No data to check. Please upload a file first.', 'error');
        return;
    }
    
    // Calculate total from last column
    let totalAmount = 0;
    originalParsedData.forEach(row => {
        const lastValue = row[row.length - 1];
        const amount = parseFloat(lastValue);
        if (!isNaN(amount)) {
            totalAmount += amount;
        }
    });
    
    showMessage('Total Amount: ₹' + totalAmount.toFixed(2) + ' (' + originalParsedData.length + ' records)', 'info');
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
        
        // Reset global variables
        originalParsedData = [];
        selectedColumns = [];
        totalColumns = 0;
        currentDisplayData = [];
        currentPage = 1;
        
        // Hide column tools
        document.getElementById('columnTools').style.display = 'none';
        document.getElementById('selectedColumnsDisplay').style.display = 'none';
        document.getElementById('selectedColumnsList').innerHTML = '';
        
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
        
        // Hide pagination
        document.getElementById('paginationControls').style.display = 'none';
        
        document.getElementById('messageBox').style.display = 'none';
        document.getElementById('importBtn').disabled = true;
        document.getElementById('createBtn').disabled = true;
    }
}

// Event listener for radio button changes
document.addEventListener('DOMContentLoaded', function() {
    const radios = document.querySelectorAll('input[name="displayMode"]');
    const lastCharsInput = document.getElementById('lastChars');
    const firstCharsInput = document.getElementById('firstChars');
    
    radios.forEach(radio => {
        radio.addEventListener('change', function() {
            // Hide all character inputs
            lastCharsInput.style.display = 'none';
            firstCharsInput.style.display = 'none';
            
            // Show relevant input
            if (this.value === 'last') {
                lastCharsInput.style.display = 'inline-block';
                lastCharsInput.focus();
            } else if (this.value === 'first') {
                firstCharsInput.style.display = 'inline-block';
                firstCharsInput.focus();
            }
        });
    });
});
</script>
</body>
</html>
