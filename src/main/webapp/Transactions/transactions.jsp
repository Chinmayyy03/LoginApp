<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // ✅ Get branch code from session
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
                            <button type="button" class="icon-btn" onclick="openLookup()">…</button>
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
                            <button type="button" class="icon-btn" onclick="openAccountTypeLookup()">…</button>
                        </div>
                    </div>

                    <div>
                        <div class="label">Account Type Name</div>
                        <input type="text" name="accountTypeName" id="accountTypeName" placeholder="Account Type Name" style="width: 230px;" readonly>
                    </div>

                </div>
            </fieldset>

            <button class="submit-btn">Submit</button>

        </div>
    </form>

    <!-- 🔽 IFRAME for loading dynamic pages -->
    <iframe id="resultFrame" name="resultFrame"
            style="width:100%; height:800px; border:1px solid #ccc; margin-top:20px;">
    </iframe>

</div>

<!-- LOOKUP MODAL FOR TRANSACTION TYPE -->
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

<!-- LOOKUP MODAL FOR ACCOUNT TYPE -->
<div id="accountTypeLookupModal" style="
    display:none; 
    position:fixed; 
    top:0; left:0; width:100%; height:100%;
    background:rgba(0,0,0,0.5); 
    justify-content:center; 
    align-items:center;
    z-index:9999;
">
    <div style="background:white; width:80%; max-height:80%; overflow:auto; padding:20px; border-radius:6px;">
        <button onclick="closeAccountTypeLookup()" style="float:right; cursor:pointer;">✖</button>
        <div id="accountTypeLookupContent"></div>
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

    // Validate fields are filled
    if (!transType) {
        showToast('Please select a Transaction Type', 'warning');
        return;
    }
    
    if (!accountType) {
        showToast('Please select an Account Type', 'warning');
        return;
    }

    // 🔥 UPDATED MAPPING: All transaction types now go to unified form
    const pageMap = {
        "CSD": "transactionForm.jsp",      // Deposit → unified form
        "CSW": "transactionForm.jsp",      // Withdrawal → unified form
        "TR": "transactionForm.jsp",       // Transfer → unified form (if you want)
        // Add more mappings as needed
    };

    console.log("Transaction Type =", transType);
    console.log("Account Type =", accountType);

    if (pageMap[transType]) {
        // Create a form to submit with all values
        let form = document.getElementById("transactionForm");
        form.action = pageMap[transType];
        
        // Make sure all values are included
        document.getElementById("transactionType").value = transType;
        document.getElementById("transDescription").value = transDesc;
        document.getElementById("accountType").value = accountType;
        document.getElementById("accountTypeName").value = accountTypeName;
        
        form.submit();  // submit to iframe
        showToast('Loading transaction form...', 'success');
    } else {
        showToast('No page found for Transaction Type: ' + transType, 'error');
    }
}

// ========== TRANSACTION TYPE LOOKUP FUNCTIONS ==========
function openLookup() {
    let url = "LookupForTransactions.jsp";

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

function sendBack(code, desc) {
    setValueFromLookup(code, desc);
}

// This is called by lookup.jsp when a row is clicked
function setValueFromLookup(code, desc) {
    document.getElementById("transactionType").value = code;
    document.getElementById("transDescription").value = desc;
    document.getElementById("resultFrame").src = "";
    
    showToast('Transaction Type selected successfully', 'success');
    closeLookup();
}

// ========== ACCOUNT TYPE LOOKUP FUNCTIONS ==========
function openAccountTypeLookup() {
    let url = "LookupForAccountType.jsp";

    // Load JSP content into modal using fetch()
    fetch(url)
        .then(response => response.text())
        .then(html => {
            document.getElementById("accountTypeLookupContent").innerHTML = html;
            document.getElementById("accountTypeLookupModal").style.display = "flex";
        })
        .catch(error => {
            showToast('Failed to load account type lookup. Please try again.', 'error');
            console.error('Account Type Lookup error:', error);
        });
}

function closeAccountTypeLookup() {
    document.getElementById("accountTypeLookupModal").style.display = "none";
}

// Make this function globally accessible for the loaded lookup content
window.sendBackAccountType = function(code, name) {
    document.getElementById("accountType").value = code;
    document.getElementById("accountTypeName").value = name;
    
    showToast('Account Type selected successfully', 'success');
    closeAccountTypeLookup();
}
</script>
</body>
</html>