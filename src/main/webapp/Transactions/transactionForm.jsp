<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String branchCode = (String) sess.getAttribute("branchCode");
    String operationType = request.getParameter("operationType");
    String accountCategory = request.getParameter("accountCategory");
    String accountCode = request.getParameter("accountCode");
    String accountName = request.getParameter("accountName");
    
    if (operationType == null) operationType = "";
    if (accountCategory == null) accountCategory = "";
    if (accountCode == null) accountCode = "";
    if (accountName == null) accountName = "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Transaction Form</title>
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
    <link rel="stylesheet" href="css/transactionsForm.css">
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
</head>
<body>

<form action="ProcessTransactionServlet" method="post" onsubmit="return validateForm()">
    <input type="hidden" name="operationType" value="<%= operationType %>">
    <input type="hidden" name="accountCategory" value="<%= accountCategory %>">
    <input type="hidden" name="accountCode" value="<%= accountCode %>">
    
    <!-- ========================================== -->
    <!-- ACCOUNT INFORMATION FIELDSET -->
    <!-- ========================================== -->
    <fieldset class="account-info-section" id="accountInfoSection">
        <legend>Account Information</legend>
        <div class="form-grid">
            
            <div>
                <label>GL Account Code</label>
                <input type="text" id="glAccountCode" name="glAccountCode" >
            </div>
            
            <div>
                <label>GL Account Name</label>
                <input type="text" id="glAccountName" name="glAccountName" >
            </div>
            
            <div>
                <label>Ledger Balance</label>
                <input type="text" id="ledgerBalance" name="ledgerBalance" >
            </div>
            
            <div>
                <label>Available Balance</label>
                <input type="text" id="availableBalance" name="availableBalance" >
            </div>
            
            <div>
                <label>New Ledger Balance</label>
                <input type="text" id="newLedgerBalance" name="newLedgerBalance" >
            </div>
            
            <div>
                <label>Limit Amount</label>
                <input type="text" id="limitAmount" name="limitAmount" >
            </div>
            
            <div>
                <label>Drawing Power</label>
                <input type="text" id="drawingPower" name="drawingPower" >
            </div>
            
            <div>
                <label>Unclear Balance</label>
                <input type="text" id="unclearBalance" name="unclearBalance" >
            </div>
            
            <div>
                <label>Last Transaction Date</label>
                <input type="date" id="lastTransactionDate" name="lastTransactionDate" >
            </div>
            
            <div>
                <label>Account Review Date</label>
                <input type="date" id="accountReviewDate" name="accountReviewDate" >
            </div>
            
            <div>
                <label>Last OD Date</label>
                <input type="date" id="lastOdDate" name="lastOdDate" >
            </div>
            
            <div>
                <label>Pincode</label>
                <input type="text" id="pincode" name="pincode" >
            </div>            
            
            <div>
                <label>OD Interest</label>
                <input type="text" id="odInterest" name="odInterest" >
            </div>
            
        </div>
        
        <div class="form-buttons">
            <button type="button" onclick="checkAccountDetails()">Check</button>
        </div>
    </fieldset>

</form>

<script>
function showToast(message, type = 'info') {
    const styles = {
        success: { borderColor: '#4caf50', icon: '✅' },
        error: { borderColor: '#f44336', icon: '❌' },
        warning: { borderColor: '#ff9800', icon: '⚠️' },
        info: { borderColor: '#2196F3', icon: 'ℹ️' }
    };
    const style = styles[type] || styles.info;
    
    Toastify({
        text: style.icon + ' ' + message,
        duration: 5000,
        close: true,
        gravity: "top",
        position: "center",
        style: {
            background: "#fff",
            color: "#333",
            borderRadius: "8px",
            fontSize: "14px",
            padding: "16px 24px",
            boxShadow: "0 3px 10px rgba(0,0,0,0.2)",
            borderLeft: "5px solid " + style.borderColor,
            marginTop: "20px"
        }
    }).showToast();
}

function validateForm() {
    // Add validation logic here
    return true;
}

function checkAccountDetails() {
    const accountCode = '<%= accountCode %>';
    
    if (!accountCode) {
        showToast('No account selected', 'error');
        return;
    }
    
    showToast('Fetching account details...', 'info');
    
    // Make AJAX call to fetch account details
    fetch('GetAccountDetails.jsp?accountCode=' + encodeURIComponent(accountCode))
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                showToast('Error: ' + data.error, 'error');
            } else {
                // Populate form fields
                document.getElementById('glAccountCode').value = data.glAccountCode || '';
                document.getElementById('glAccountName').value = data.glAccountName || '';
                document.getElementById('ledgerBalance').value = data.ledgerBalance || '0.00';
                document.getElementById('availableBalance').value = data.availableBalance || '0.00';
                document.getElementById('newLedgerBalance').value = data.newLedgerBalance || '0.00';
                document.getElementById('limitAmount').value = data.limitAmount || '0.00';
                document.getElementById('drawingPower').value = data.drawingPower || '';
                document.getElementById('unclearBalance').value = data.unclearBalance || '0.00';
                document.getElementById('lastTransactionDate').value = data.lastTransactionDate || '';
                document.getElementById('accountReviewDate').value = data.accountReviewDate || '';
                document.getElementById('pincode').value = data.pincode || '';
                document.getElementById('lastOdDate').value = data.lastOdDate || '';
                document.getElementById('odInterest').value = data.odInterest || '0';
                
                showToast('Account details loaded successfully', 'success');
            }
        })
        .catch(error => {
            console.error('Error fetching account details:', error);
            showToast('Failed to fetch account details', 'error');
        });
}

// Show account info section when page loads if account is selected
window.addEventListener('DOMContentLoaded', function() {
    const accountCode = '<%= accountCode %>';
    const operationType = '<%= operationType %>';
    
    if (accountCode && accountCode.trim() !== '' && operationType === 'deposit') {
        document.getElementById('accountInfoSection').classList.add('active');
        }
});
</script>

</body>
</html>