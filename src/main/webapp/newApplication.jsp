<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>


<%
    // ✅ Get branch code from session
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String branchCode = (String) sess.getAttribute("branchCode");
%>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>List of Product</title>
    
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

        /* ---------------- Responsive CSS Added ---------------- */
        @media (max-width: 1000px) {
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
    <h1>LIST OF PRODUCT</h1>

    <form id="productForm" method="post" target="resultFrame">
        <div class="card">

            <fieldset>
                <legend>Product Details</legend>

                <div class="row">

                    <!-- Account Type -->
                    <div>
                        <div class="label">Account Type</div>
                        <div class="input-box">
                            <input type="text" name="accountType" id="accountType" placeholder="Enter code" readonly>
                            <button type="button" class="icon-btn" onclick="openLookup('account')">…</button>
                        </div>
                    </div>

                    <div>
                        <div class="label">Description</div>
                        <input type="text" name="accDescription" id="accDescription" placeholder="Description" style="width: 230px;" readonly>
                    </div>

                    <!-- Product Code -->
                    <div>
                        <div class="label">Product Code</div>
                        <div class="input-box">
                            <input type="text" name="productCode" id="productCode" placeholder="Enter code" readonly>
                            <button type="button" class="icon-btn" onclick="openLookup('product', document.getElementById('accountType').value)">…</button>
                        </div>
                    </div>

                    <div>
                        <div class="label">Description</div>
                        <input type="text" name="prodDescription" id="prodDescription" placeholder="Description" style="width: 230px;" readonly>
                    </div>

                </div>
            </fieldset>

        </div>
    </form>

    <!-- 🔽 IFRAME for loading dynamic pages -->
    <iframe id="resultFrame" name="resultFrame"
            style="width:100%; height:800px; border:1px solid #ccc; margin-top:20px;">
    </iframe>

</div>

<!-- LOOKUP MODAL -->
<div id="lookupModal" style="
    display:none; 
    position:fixed; 
    top:0; left:0; width:100%; height:100%;
    background:rgba(0,0,0,0.5); 
    justify-content:center; 
    align-items:center;
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

function openLookup(type, accType = "") {
    let url = "LookupForNewAppCode.jsp?type=" + type;

    if (accType !== "") {
        url += "&accType=" + accType;
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
        document.getElementById("accountType").value = code;
        document.getElementById("accDescription").value = desc;
        
        // 👉 Clear product fields and IFrame when new account type selected
        document.getElementById("productCode").value = "";
        document.getElementById("prodDescription").value = "";
        document.getElementById("resultFrame").src = "";
        
        showToast('Account Type selected successfully', 'success');
    }

    if (type === "product") {
        document.getElementById("productCode").value = code;
        document.getElementById("prodDescription").value = desc;
        
        showToast('Product Code selected successfully', 'success');
        
        // 🔥 AUTO SUBMIT FORM when product is selected
        autoSubmitForm();
    }

    closeLookup();
}

// 🔥 NEW FUNCTION: Auto submit form after product selection
function autoSubmitForm() {
    let accType = document.getElementById("accountType").value.trim();
    let prodCode = document.getElementById("productCode").value.trim();

    // Validate fields are filled
    if (!accType) {
        showToast('Please select an Account Type first', 'warning');
        return;
    }
    
    if (!prodCode) {
        showToast('Please select a Product Code', 'warning');
        return;
    }

    // Mapping based on Account Type
    const pageMap = {
        "SB": "OpenAccount/savingAcc.jsp",
        "CA": "OpenAccount/savingAcc.jsp",
        "TD": "OpenAccount/deposit.jsp",
        "CC": "OpenAccount/loan.jsp",
        "TL": "OpenAccount/loan.jsp",
        "PG": "OpenAccount/pigmy.jsp",
        "SH": "OpenAccount/shares.jsp",
        "FA": "OpenAccount/fAApplication.jsp"
    };

    console.log("Account Type =", accType);

    // Check if mapping exists for this account type
    if (pageMap[accType]) {
        // Set form action to correct JSP
        document.getElementById("productForm").action = pageMap[accType];
        document.getElementById("productForm").submit();
        showToast('Loading application form...', 'success');
    } else {
        showToast('No page found for Account Type: ' + accType, 'error');
    }
}
</script>
</body>
</html>