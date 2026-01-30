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
<title>Pigmy Import</title>
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

.upload-section {
    border: 2px dashed #4a9eff;
    border-radius: 8px;
    padding: 40px;
    text-align: center;
    margin-bottom: 30px;
    background: #f8fbff;
    transition: all 0.3s ease;
}

.upload-section:hover {
    border-color: #3d85d9;
    background: #f0f7ff;
}

.upload-section.drag-over {
    border-color: #2563eb;
    background: #dbeafe;
}

.upload-icon {
    font-size: 48px;
    margin-bottom: 15px;
}

.upload-section h3 {
    margin: 10px 0;
    color: #4a9eff;
}

.upload-section p {
    color: #666;
    margin: 5px 0;
}

.file-input {
    display: none;
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

.file-info {
    display: none;
    margin-top: 20px;
    padding: 15px;
    background: #f0fdf4;
    border: 1px solid #86efac;
    border-radius: 6px;
}

.file-info.show {
    display: block;
}

.file-name {
    font-weight: 600;
    color: #166534;
}

.progress-section {
    display: none;
    margin-top: 20px;
}

.progress-section.show {
    display: block;
}

.progress-bar {
    width: 100%;
    height: 8px;
    background: #e5e7eb;
    border-radius: 4px;
    overflow: hidden;
    margin-top: 10px;
}

.progress-fill {
    height: 100%;
    background: linear-gradient(90deg, #4a9eff 0%, #3d85d9 100%);
    width: 0%;
    transition: width 0.3s ease;
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
</style>
</head>

<body>
<div class="container">
    <h2>📥 Pigmy Import</h2>
    <p class="subtitle">Import pigmy collection data from Excel/CSV file</p>

    <div class="upload-section" id="uploadSection">
        <div class="upload-icon">📄</div>
        <h3>Drop file here or click to browse</h3>
        <p>Supported formats: .xlsx, .xls, .csv</p>
        <p style="font-size: 12px; color: #999;">Maximum file size: 10MB</p>
        
        <input type="file" id="fileInput" class="file-input" accept=".xlsx,.xls,.csv">
        <button class="btn btn-primary" onclick="document.getElementById('fileInput').click()">
            Choose File
        </button>
    </div>

    <div class="file-info" id="fileInfo">
        <div>Selected file: <span class="file-name" id="fileName"></span></div>
        <div style="margin-top: 10px;">
            <button class="btn btn-primary" onclick="uploadFile()">Upload & Process</button>
            <button class="btn btn-secondary" onclick="clearFile()">Clear</button>
        </div>
    </div>

    <div class="progress-section" id="progressSection">
        <p>Processing file...</p>
        <div class="progress-bar">
            <div class="progress-fill" id="progressFill"></div>
        </div>
    </div>

    <div class="message" id="message"></div>

    <div class="instructions">
        <h4>📋 Import Instructions</h4>
        <ul>
            <li>Ensure your Excel/CSV file contains the following columns: Account Number, Customer Name, Collection Date, Amount</li>
            <li>The first row should contain column headers</li>
            <li>Date format should be: DD/MM/YYYY or DD-MM-YYYY</li>
            <li>Amount should be numeric values only</li>
            <li>File size should not exceed 10MB</li>
            <li>All mandatory fields must be filled</li>
        </ul>
    </div>
</div>

<script>
window.onload = function () {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('Pigmy/pigmyImport.jsp')
        );
    }
};

const uploadSection = document.getElementById('uploadSection');
const fileInput = document.getElementById('fileInput');
const fileInfo = document.getElementById('fileInfo');
const fileName = document.getElementById('fileName');
const progressSection = document.getElementById('progressSection');
const progressFill = document.getElementById('progressFill');
const message = document.getElementById('message');

// Drag and drop events
uploadSection.addEventListener('dragover', (e) => {
    e.preventDefault();
    uploadSection.classList.add('drag-over');
});

uploadSection.addEventListener('dragleave', () => {
    uploadSection.classList.remove('drag-over');
});

uploadSection.addEventListener('drop', (e) => {
    e.preventDefault();
    uploadSection.classList.remove('drag-over');
    
    const files = e.dataTransfer.files;
    if (files.length > 0) {
        handleFile(files[0]);
    }
});

// File input change
fileInput.addEventListener('change', (e) => {
    if (e.target.files.length > 0) {
        handleFile(e.target.files[0]);
    }
});

function handleFile(file) {
    const validTypes = ['application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'text/csv'];
    const maxSize = 10 * 1024 * 1024; // 10MB

    if (!validTypes.includes(file.type) && !file.name.match(/\.(xlsx|xls|csv)$/i)) {
        showMessage('Please select a valid Excel or CSV file', 'error');
        return;
    }

    if (file.size > maxSize) {
        showMessage('File size exceeds 10MB limit', 'error');
        return;
    }

    fileName.textContent = file.name;
    fileInfo.classList.add('show');
    hideMessage();
}

function clearFile() {
    fileInput.value = '';
    fileInfo.classList.remove('show');
    hideMessage();
}

function uploadFile() {
    if (!fileInput.files || fileInput.files.length === 0) {
        showMessage('Please select a file first', 'error');
        return;
    }

    const formData = new FormData();
    formData.append('file', fileInput.files[0]);
    formData.append('branchCode', '<%= branchCode %>');
    formData.append('userId', '<%= userId %>');

    progressSection.classList.add('show');
    progressFill.style.width = '0%';
    hideMessage();

    // Simulate progress (replace with actual upload)
    let progress = 0;
    const interval = setInterval(() => {
        progress += 10;
        progressFill.style.width = progress + '%';
        
        if (progress >= 100) {
            clearInterval(interval);
            
            // Here you would actually call your upload servlet/JSP
            // For now, showing a success message
            setTimeout(() => {
                progressSection.classList.remove('show');
                showMessage('File imported successfully! Processed X records.', 'success');
                clearFile();
            }, 500);
        }
    }, 200);

    // Actual implementation would be:
    /*
    fetch('processPigmyImport.jsp', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        progressSection.classList.remove('show');
        if (data.success) {
            showMessage('File imported successfully! Processed ' + data.recordCount + ' records.', 'success');
            clearFile();
        } else {
            showMessage('Error: ' + data.error, 'error');
        }
    })
    .catch(error => {
        progressSection.classList.remove('show');
        showMessage('Upload failed: ' + error.message, 'error');
    });
    */
}

function showMessage(text, type) {
    message.textContent = text;
    message.className = 'message show ' + type;
}

function hideMessage() {
    message.className = 'message';
}
</script>
</body>
</html>
