<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // Get branch code from session
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String branchCode = (String) sess.getAttribute("branchCode");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Transaction Type Selection</title>
    
    <!-- Add Toastify CSS -->
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
    
    <!-- Add Toastify JS -->
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
    
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background-color: #e8e4fc;
        }

        .container {
            width: 90%;
            margin: 30px auto;
        }

        h1 {
            text-align: center;
            font-size: 30px;
            color: #3D316F;
            letter-spacing: 2px;
            margin-bottom: 30px;
        }

        .header-box {
            display: flex;
            justify-content: space-between;
            background: white;
            padding: 15px 20px;
            border-radius: 10px;
            font-size: 16px;
            color: #3D316F;
            box-shadow: 0px 2px 10px rgba(0,0,0,0.05);
        }

        .header-box span {
            font-weight: bold;
        }

        .card {
            margin-top: 30px;
            border-radius: 12px;
        }

        .card-title {
            font-size: 20px;
            color: #3D316F;
            font-weight: bold;
            margin-bottom: 20px;
        }

        fieldset {
            background-color: white;
            border: 2px solid #BBADED;
            border-radius: 12px;
            padding: 20px;
        }

        legend {
            font-size: 18px;
            padding: 0 10px;
            color: #3D316F;
        }

        .row {
            display: flex;
            gap: 25px;
            margin-bottom: 20px;
        }

        .label {
            font-weight: bold;
            font-size: 14px;
            color: #3D316F;
        }

        .input-box {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        input {
            padding: 10px;
            width: 180px;
            border: 2px solid #C8B7F6;
            border-radius: 8px;
            background-color: #F4EDFF;
            outline: none;
            font-size: 14px;
        }

        input:focus {
            border-color: #8066E8;
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
        }

        .icon-btn:hover {
            background-color: #3D316F;
        }

        .icon-btn:disabled {
            background-color: #ccc;
            cursor: not-allowed;
        }

        /* ---------------- Responsive CSS Added ---------------- */

        @media (max-width: 768px) {
            .row {
                flex-direction: column;
                gap: 15px;
            }

            input {
                width: 100%;
            }

            .input-box {
                width: 100%;
                justify-content: space-between;
            }
        }

        @media (max-width: 480px) {
            fieldset {
                padding: 15px;
            }

            legend {
                font-size: 16px;
            }

            input {
                font-size: 13px;
                padding: 8px;
            }

            .icon-btn {
                width: 30px;
                height: 30px;
                font-size: 16px;
            }
        }

        .submit-btn {
            display: block;
            margin: 35px auto 0;
            background: #2b0d73;
            border: none;
            padding: 12px 35px;
            border-radius: 30px;
            font-size: 18px;
            color: white;
            cursor: pointer;
            transition: 0.3s;
            box-shadow: 0px 6px 15px rgba(46,204,113,0.4);
        }
        
        .submit-btn:hover {
            background-color: #3D316F;
            transform: scale(1.05);
        }

        .submit-btn:active {
            transform: scale(0.97);
        }

        .modal {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0,0,0,0.4);
            z-index: 9999;
        }
        
        .modal-content {
            background: #fff;
            width: 60%;
            margin: 5% auto;
            padding: 20px;
            border-radius: 12px;
        }
        
        .close {
            float: right;
            font-size: 22px;
            cursor: pointer;
        }
    </style>
</head>
<body>

<div class="container">
    <h1>TRANSACTION</h1>

    <form id="transactionForm" method="post" target="resultFrame" onsubmit="checkForm(event)">
        <div class="card">

            <fieldset>
                <legend>Transaction Details</legend>

                <div class="row">

                    <!-- Transaction Type -->
                    <div>
                        <div class="label">Transaction Type</div>
                        <div class="input-box">
                            <input type="text" name="transactionType" id="transactionType" placeholder="Enter code" readonly>
                            <button type="button" class="icon-btn" onclick="openLookup('transaction')">…</button>
                        </div>
                    </div>

                    <div>
                        <div class="label">Description</div>
                        <input type="text" name="transDescription" id="transDescription" placeholder="Description" style="width: 230px;" readonly>
                    </div>

                    <!-- Account Type -->
                    <div>
                        <div class="label">Account Type</div>
                        <div class="input-box">
                            <input type="text" name="accountType" id="accountType" placeholder="Enter code" readonly>
                            <button type="button" class="icon-btn" onclick="openLookup('accountType')">…</button>
                        </div>
                    </div>

                    <div>
                        <div class="label">Account Type Name</div>
                        <input type="text" name="accountTypeName" id="accountTypeName" placeholder="Account Type Name" style="width: 230px;" readonly>
                    </div>

                </div>

                <div class="row">

                    <!-- Product Code -->
                    <div>
                        <div class="label">Product Code</div>
                        <div class="input-box">
                            <input type="text" name="productCode" id="productCode" placeholder="Enter code" readonly>
                            <button type="button" class="icon-btn" id="productLookupBtn" onclick="openLookup('product', document.getElementById('accountType').value)" disabled>…</button>
                        </div>
                    </div>

                    <div>
                        <div class="label">Product Description</div>
                        <input type="text" name="productDescription" id="productDescription" placeholder="Product Description" style="width: 230px;" readonly>
                    </div>

                    <!-- Account Code -->
                    <div>
                        <div class="label">Account Code</div>
                        <div class="input-box">
                            <input type="text" name="accountCode" id="accountCode" placeholder="Enter account code" readonly>
                            <button type="button" class="icon-btn" id="accountLookupBtn" onclick="openLookup('account', document.getElementById('productCode').value)" disabled>…</button>
                        </div>
                    </div>

                    <div>
                        <div class="label">Account Name</div>
                        <input type="text" name="accountName" id="accountName" placeholder="Account Name" style="width: 230px;" readonly>
                    </div>

                </div>
            </fieldset>

            <button class="submit-btn">Submit</button>

        </div>
    </form>

    <!-- IFRAME for loading dynamic pages -->
    <iframe id="resultFrame" name="resultFrame"
            style="width:100%; height:800px; border:1px solid #ccc; margin-top:20px;">
    </iframe>

</div>

<!-- SINGLE LOOKUP MODAL -->
<div id="lookupModal" style="
    display:none; 
    position:fixed; 
    top:0; left:0; width:100%; height:100%;
    background:rgba(0,0,0,0.5); 
    justify-content:center; 
    align-items:center;
    z-index:9999;
">
    <div style="background:white; width:80%; max-height:80%; overflow:auto; padding:20px; border-radius:6px;">
        <button onclick="closeLookup()" style="float:right; cursor:pointer;">✖</button>
        <div id="lookupContent"></div>
    </div>
</div>

<script>
// ========== TOAST UTILITY FUNCTION ==========
function showToast(message, type = 'error') {
    const styles = {
        success: {
            borderColor: '#4caf50',
            icon: '✅'
        },
        error: {
            borderColor: '#f44336',
            icon: '❌'
        },
        warning: {
            borderColor: '#ff9800',
            icon: '⚠️'
        },
        info: {
            borderColor: '#2196F3',
            icon: 'ℹ️'
        }
    };
    
    const style = styles[type] || styles.error;
    
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
            borderLeft: `5px solid ${style.borderColor}`,
            marginTop: "20px",
            whiteSpace: "pre-line"
        },
        stopOnFocus: true
    }).showToast();
}

function checkForm(event) {
    event.preventDefault(); // stop default submit

    let transType = document.querySelector("input[name='transactionType']").value.trim();
    let transDesc = document.querySelector("input[name='transDescription']").value.trim();
    let accountType = document.querySelector("input[name='accountType']").value.trim();
    let accountTypeName = document.querySelector("input[name='accountTypeName']").value.trim();
    let productCode = document.querySelector("input[name='productCode']").value.trim();
    let productDesc = document.querySelector("input[name='productDescription']").value.trim();
    let accountCode = document.querySelector("input[name='accountCode']").value.trim();
    let accountName = document.querySelector("input[name='accountName']").value.trim();

    // Validate fields are filled
    if (!transType) {
        showToast('Please select a Transaction Type', 'warning');
        return;
    }
    
    if (!accountType) {
        showToast('Please select an Account Type', 'warning');
        return;
    }

    if (!productCode) {
        showToast('Please select a Product Code', 'warning');
        return;
    }

    if (!accountCode) {
        showToast('Please select an Account Code', 'warning');
        return;
    }

    // UPDATED MAPPING: All transaction types now go to unified form
    const pageMap = {
        "CSD": "transactionForm.jsp",      // Deposit → unified form
        "CSW": "transactionForm.jsp",      // Withdrawal → unified form
        "TR": "transactionForm.jsp",       // Transfer → unified form
        // Add more mappings as needed
    };

    console.log("Transaction Type =", transType);
    console.log("Account Type =", accountType);
    console.log("Product Code =", productCode);
    console.log("Account Code =", accountCode);

    if (pageMap[transType]) {
        // Create a form to submit with all values
        let form = document.getElementById("transactionForm");
        form.action = pageMap[transType];
        
        // Make sure all values are included
        document.getElementById("transactionType").value = transType;
        document.getElementById("transDescription").value = transDesc;
        document.getElementById("accountType").value = accountType;
        document.getElementById("accountTypeName").value = accountTypeName;
        document.getElementById("productCode").value = productCode;
        document.getElementById("productDescription").value = productDesc;
        document.getElementById("accountCode").value = accountCode;
        document.getElementById("accountName").value = accountName;
        
        form.submit();  // submit to iframe
        showToast('Loading transaction form...', 'success');
    } else {
        showToast('No page found for Transaction Type: ' + transType, 'error');
    }
}

// ========== UNIFIED LOOKUP FUNCTION ==========
function openLookup(type, param = "") {
    // Validate if product lookup requires account type
    if (type === 'product' && !param) {
        showToast('Please select an Account Type first', 'warning');
        return;
    }

    // Validate if account lookup requires product code
    if (type === 'account' && !param) {
        showToast('Please select a Product Code first', 'warning');
        return;
    }

    let url = "LookupForTransactions.jsp?type=" + type;
    
    if (type === 'product' && param) {
        url += "&accType=" + param;
    }
    
    if (type === 'account' && param) {
        url += "&productCode=" + param;
    }

    // Load JSP content into modal using fetch()
    fetch(url)
        .then(response => response.text())
        .then(html => {
            document.getElementById("lookupContent").innerHTML = html;
            document.getElementById("lookupModal").style.display = "flex";
        })
        .catch(error => {
            showToast('Failed to load lookup data. Please try again.', 'error');
            console.error('Lookup error:', error);
        });
}

function closeLookup() {
    document.getElementById("lookupModal").style.display = "none";
}

function sendBack(code, desc, type) {
    setValueFromLookup(code, desc, type);
}

// This is called by lookup.jsp when a row is clicked
function setValueFromLookup(code, desc, type) {
    if (type === "transaction") {
        document.getElementById("transactionType").value = code;
        document.getElementById("transDescription").value = desc;
        
        // Clear all dependent fields when transaction type changes
        document.getElementById("accountType").value = "";
        document.getElementById("accountTypeName").value = "";
        document.getElementById("productCode").value = "";
        document.getElementById("productDescription").value = "";
        document.getElementById("accountCode").value = "";
        document.getElementById("accountName").value = "";
        document.getElementById("resultFrame").src = "";
        
        // Disable dependent lookup buttons
        document.getElementById("productLookupBtn").disabled = true;
        document.getElementById("accountLookupBtn").disabled = true;
        
        showToast('Transaction Type selected successfully', 'success');
    }

    if (type === "accountType") {
        document.getElementById("accountType").value = code;
        document.getElementById("accountTypeName").value = desc;
        
        // Clear product and account fields when account type changes
        document.getElementById("productCode").value = "";
        document.getElementById("productDescription").value = "";
        document.getElementById("accountCode").value = "";
        document.getElementById("accountName").value = "";
        document.getElementById("resultFrame").src = "";
        
        // Enable product lookup button, disable account lookup button
        document.getElementById("productLookupBtn").disabled = false;
        document.getElementById("accountLookupBtn").disabled = true;
        
        showToast('Account Type selected successfully', 'success');
    }

    if (type === "product") {
        document.getElementById("productCode").value = code;
        document.getElementById("productDescription").value = desc;
        
        // Clear account fields when product code changes
        document.getElementById("accountCode").value = "";
        document.getElementById("accountName").value = "";
        document.getElementById("resultFrame").src = "";
        
        // Enable account lookup button
        document.getElementById("accountLookupBtn").disabled = false;
        
        showToast('Product Code selected successfully', 'success');
    }

    if (type === "account") {
        document.getElementById("accountCode").value = code;
        document.getElementById("accountName").value = desc;
        document.getElementById("resultFrame").src = "";
        
        showToast('Account selected successfully', 'success');
    }

    closeLookup();
}
</script>
</body>
</html>