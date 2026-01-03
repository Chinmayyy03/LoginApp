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
	            margin-bottom: 8px;
	        }
	
	        .input-box {
	            display: flex;
	            align-items: center;
	            gap: 10px;
	        }
	
	        input[type="text"] {
	            padding: 10px;
	            width: 180px;
	            border: 2px solid #C8B7F6;
	            border-radius: 8px;
	            background-color: #F4EDFF;
	            outline: none;
	            font-size: 14px;
	        }
	
	        input[type="text"]:focus {
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
	
	        /* Radio Button Styles */
	        .radio-row {
	            display: flex;
	            align-items: center;
	            gap: 30px;
	            margin-bottom: 20px;
	            flex-wrap: wrap;
	        }
	
	        .radio-group-inline {
	            display: flex;
	            align-items: center;
	            gap: 10px;
	        }
	
	        .radio-group-inline .label {
	            margin-bottom: 0;
	            margin-right: 10px;
	        }
	
	        .radio-buttons {
	            display: flex;
	            gap: 10px;
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
	
	        .radio-label input[type="radio"]:checked + span {
	            font-weight: bold;
	            color: #2D2B80;
	        }
	
	        .radio-label span {
	            user-select: none;
	        }
	
	        .form-group {
	            flex: 1;
	            min-width: 200px;
	        }
	
	        /* ---------------- Responsive CSS Added ---------------- */
	
	        @media (max-width: 1024px) {
	            .radio-row {
	                flex-direction: column;
	                align-items: flex-start;
	                gap: 15px;
	            }
	
	            .radio-group-inline {
	                width: 100%;
	                flex-direction: column;
	                align-items: flex-start;
	            }
	
	            .radio-buttons {
	                flex-wrap: wrap;
	                margin-top: 8px;
	            }
	        }
	
	        @media (max-width: 768px) {
	            .container {
	                width: 95%;
	            }
	
	            h1 {
	                font-size: 24px;
	            }
	
	            .header-box {
	                flex-direction: column;
	                gap: 10px;
	            }
	
	            .row {
	                flex-direction: column;
	                gap: 15px;
	            }
	
	            input[type="text"] {
	                width: 100%;
	            }
	
	            .input-box {
	                width: 100%;
	                justify-content: space-between;
	            }
	
	            .radio-row {
	                flex-direction: column;
	                align-items: flex-start;
	            }
	
	            .radio-group-inline {
	                width: 100%;
	            }
	
	            .radio-buttons {
	                flex-wrap: wrap;
	            }
	
	            .radio-label {
	                font-size: 13px;
	                padding: 6px 10px;
	            }
	
	            fieldset {
	                padding: 15px;
	            }
	
	            legend {
	                font-size: 16px;
	            }
	        }
	
	        @media (max-width: 480px) {
	            h1 {
	                font-size: 20px;
	                letter-spacing: 1px;
	            }
	
	            fieldset {
	                padding: 12px;
	            }
	
	            legend {
	                font-size: 14px;
	            }
	
	            input[type="text"] {
	                font-size: 13px;
	                padding: 8px;
	            }
	
	            .icon-btn {
	                width: 30px;
	                height: 30px;
	                font-size: 16px;
	            }
	
	            .label {
	                font-size: 13px;
	            }
	
	            .radio-label {
	                font-size: 12px;
	                padding: 6px 8px;
	            }
	
	            .radio-label input[type="radio"] {
	                width: 16px;
	                height: 16px;
	            }
	
	            .submit-btn {
	                padding: 10px 25px;
	                font-size: 16px;
	                width: 100%;
	            }
	
	            .radio-buttons {
	                gap: 8px;
	            }
	
	            .radio-row {
	                gap: 12px;
	            }
	        }
	
	        @media (max-width: 360px) {
	            .container {
	                width: 98%;
	                margin: 15px auto;
	            }
	
	            h1 {
	                font-size: 18px;
	            }
	
	            .radio-label span {
	                font-size: 11px;
	            }
	
	            input[type="text"] {
	                font-size: 12px;
	                padding: 6px;
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
	
	    <form id="transactionForm" method="post" target="resultFrame">
	        <div class="card">
	
	            <fieldset>
	                <legend>Transaction Details</legend>
	
	                <!-- All Radio Button Groups in One Line -->
	                <div class="radio-row">
	                    <!-- Transaction Type -->
	                    <div class="radio-group-inline">
	                        <div class="label">Transaction Type:</div>
	                        <div class="radio-buttons">
	                            <label class="radio-label">
	                                <input type="radio" name="transactionTypeRadio" value="regular" checked>
	                                <span>Regular</span>
	                            </label>
	                            <label class="radio-label">
	                                <input type="radio" name="transactionTypeRadio" value="closing">
	                                <span>Closing</span>
	                            </label>
	                        </div>
	                    </div>
	
	                    <!-- Operation Type -->
	                    <div class="radio-group-inline">
	                        <div class="label">Operation Type:</div>
	                        <div class="radio-buttons">
	                            <label class="radio-label">
	                                <input type="radio" name="operationType" value="deposit" checked>
	                                <span>Deposit</span>
	                            </label>
	                            <label class="radio-label">
	                                <input type="radio" name="operationType" value="withdrawal">
	                                <span>Withdrawal</span>
	                            </label>
	                            <label class="radio-label">
	                                <input type="radio" name="operationType" value="transfer">
	                                <span>Transfer</span>
	                            </label>
	                        </div>
	                    </div>
	
	                    <!-- Account Category -->
	                    <div class="radio-group-inline">
	                        <div class="label">Account Category:</div>
	                        <div class="radio-buttons">
	                            <label class="radio-label">
	                                <input type="radio" name="accountCategory" value="saving" checked>
	                                <span>Saving</span>
	                            </label>
	                            <label class="radio-label">
	                                <input type="radio" name="accountCategory" value="loan">
	                                <span>Loan</span>
	                            </label>
	                            <label class="radio-label">
	                                <input type="radio" name="accountCategory" value="deposit">
	                                <span>Deposit</span>
	                            </label>
	                            <label class="radio-label">
	                                <input type="radio" name="accountCategory" value="pigmy">
	                                <span>Pigmy</span>
	                            </label>
	                            <label class="radio-label">
	                                <input type="radio" name="accountCategory" value="investment">
	                                <span>Investment</span>
	                            </label>
	                        </div>
	                    </div>
	                </div>
	
	                <!-- Account Code and Name Row -->
	                <div class="row">
	                    <!-- Account Code -->
	                    <div>
	                        <div class="label" id="accountCodeLabel">Account Code</div>
	                        <div class="input-box">
	                            <input type="text" name="accountCode" id="accountCode" placeholder="Enter account code" readonly>
	                            <button type="button" class="icon-btn" id="accountLookupBtn" onclick="openLookup('account')">…</button>
	                        </div>
	                    </div>
	
	                    <div>
	                        <div class="label" id="accountNameLabel">Account Name</div>
	                        <input type="text" name="accountName" id="accountName" placeholder="Account Name" style="width: 230px;" readonly>
	                    </div>
	                </div>
	            </fieldset>
	
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
	
	// ========== UPDATE LABELS BASED ON OPERATION TYPE ==========
	function updateLabelsBasedOnOperation() {
	    const operationType = document.querySelector("input[name='operationType']:checked").value;
	    const accountCodeLabel = document.getElementById("accountCodeLabel");
	    const accountNameLabel = document.getElementById("accountNameLabel");
	    const accountCodeInput = document.getElementById("accountCode");
	    const accountNameInput = document.getElementById("accountName");
	    
	    if (operationType === "transfer") {
	        accountCodeLabel.textContent = "Debit Account Code";
	        accountNameLabel.textContent = "Debit Account Name";
	        accountCodeInput.placeholder = "Enter debit account code";
	        accountNameInput.placeholder = "Debit Account Name";
	    } else {
	        accountCodeLabel.textContent = "Account Code";
	        accountNameLabel.textContent = "Account Name";
	        accountCodeInput.placeholder = "Enter account code";
	        accountNameInput.placeholder = "Account Name";
	    }
	}
	
	// Add event listeners to operation type radio buttons
	document.addEventListener('DOMContentLoaded', function() {
	    const operationRadios = document.querySelectorAll("input[name='operationType']");
	    operationRadios.forEach(radio => {
	        radio.addEventListener('change', updateLabelsBasedOnOperation);
	    });
	    
	    // Initialize on page load
	    updateLabelsBasedOnOperation();
	});
	
	// Function to submit transaction form
	function openLookup(type, param = "") {
	    let url = "LookupForTransactions.jsp?type=" + type;
	    
	    // Get account category from radio button
	    let accountCategory = document.querySelector("input[name='accountCategory']:checked").value;
	    
	    if (type === 'account') {
	        url += "&accountCategory=" + accountCategory;
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
	    if (type === "account") {
	        document.getElementById("accountCode").value = code;
	        document.getElementById("accountName").value = desc;
	        
	        showToast('Account selected successfully', 'success');
	        
	        closeLookup();
	        
	        // Automatically submit the form after account selection
	        setTimeout(() => {
	            submitTransactionForm();
	        }, 500);
	    }
	}
	
	// Function to submit transaction form
	function submitTransactionForm() {
	    // Get radio button values
	    let transTypeRadio = document.querySelector("input[name='transactionTypeRadio']:checked").value;
	    let operationType = document.querySelector("input[name='operationType']:checked").value;
	    let accountCategory = document.querySelector("input[name='accountCategory']:checked").value;
	
	    let accountCode = document.querySelector("input[name='accountCode']").value.trim();
	    let accountName = document.querySelector("input[name='accountName']").value.trim();
	
	    console.log("Auto-submitting form with values:");
	    console.log("Transaction Type Radio:", transTypeRadio);
	    console.log("Operation Type:", operationType);
	    console.log("Account Category:", accountCategory);
	    console.log("Account Code:", accountCode);
	    console.log("Account Name:", accountName);
	
	    // UPDATED MAPPING: Based on operation type, route to appropriate form
	    const pageMap = {
	        "deposit": "transactionForm.jsp",
	        "withdrawal": "transactionForm.jsp",
	        "transfer": "transactionForm.jsp",
	    };
	
	    if (pageMap[operationType]) {
	        // Create a form to submit with all values
	        let form = document.getElementById("transactionForm");
	        form.action = pageMap[operationType];
	        
	        form.submit();  // submit to iframe
	        showToast('Loading transaction form...', 'info');
	    } else {
	        showToast('No page found for Operation Type: ' + operationType, 'error');
	    }
	}
	</script>
	</body>
	</html>