<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Transaction Type Selection</title>
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
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
            font-weight: bold;
            padding: 0 10px;
            color: #3D316F;
        }

        .row {
            display: flex;
            gap: 20px;
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
            gap: 20px;
        }

        input[type="text"] {
            padding: 10px;
            width: 150px;
            border: 2px solid #C8B7F6;
            border-radius: 8px;
            background-color: #F4EDFF;
            outline: none;
            color: blue;
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
        }

        .radio-group-inline .label {
            margin-bottom: 0;
            margin-right: 10px;
        }

        .radio-buttons {
            display: flex;
            gap: 15px;
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
        
        .result-product-desc {
		    color: #a52323;
		    font-size: 13px;
		    font-weight: bold;
		    padding: 4px 12px;
		    border-radius: 4px;
		    white-space: nowrap;
		    flex-shrink: 0;
		}
		
		.result-name-row {
		    color: #0306fffc;
		    font-size: 13px;
		    font-weight: bold;
		    flex: 1;
		    text-align: left;
		}
		
		/* Remove this - no longer needed */
		.result-info-wrapper {
		    display: none;
		}
        
        /* ========== LIVE SEARCH DROPDOWN STYLES ========== */
input[type="text"]:read-only {
    background-color: #f5f5f5;
    cursor: not-allowed;
}

.search-dropdown {
    position: relative;
    width: 100%;
    margin-top: 10px;
}

.search-results {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    max-height: 300px;
    width: max-content;
    overflow-y: auto;
    background: white;
    border: 2px solid #8066E8;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    z-index: 1000;
    display: none;
}

.search-results.active {
    display: block;
}

.search-result-item {
    padding: 12px 15px;
    cursor: pointer;
    border-bottom: 1px solid #f0f0f0;
    transition: all 0.2s ease;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
}

.search-result-item:last-child {
    border-bottom: none;
}

.search-result-item:hover {
    background-color: #e8e4fc;
    transform: translateX(5px);
}

.result-code {
    font-weight: bold;
    color: #3D316F;
    font-size: 14px;
    min-width: 140px;
}

.result-name {
    color: #0306fffc;
    font-size: 13px;
    font-weight: bold;
    flex: 1;
    text-align: left;
    padding-left: 15px;
}

.search-info {
    padding: 12px 15px;
    text-align: center;
    color: #999;
    font-size: 13px;
    font-style: italic;
}

.search-loading {
    padding: 15px;
    text-align: center;
    color: #8066E8;
}

.loading-spinner {
    display: inline-block;
    width: 20px;
    height: 20px;
    border: 3px solid #f3f3f3;
    border-top: 3px solid #8066E8;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

.no-results {
    padding: 15px;
    text-align: center;
    color: #f44336;
    font-size: 13px;
}

.search-hint {
    font-size: 12px;
    color: #666;
    margin-top: 5px;
    font-style: italic;
}

.highlight {
    background-color: #ffeb3b;
    font-weight: bold;
    padding: 1px 2px;
}

.search-results::-webkit-scrollbar {
    width: 8px;
}

.search-results::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 4px;
}

.search-results::-webkit-scrollbar-thumb {
    background: #8066E8;
    border-radius: 4px;
}

.search-results::-webkit-scrollbar-thumb:hover {
    background: #6B52CC;
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
                gap: 15px;
            }

            .input-box {
                width: 100%;
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
        .operation-display-box {
		    padding: 15px 15px;
		    border-radius: 12px;
		    display: flex;
		    align-items: center;
		    justify-content: center;
		    flex-direction: column;
		    gap: 5px;
		    min-width: 250px;
		    transition: all 0.3s ease;
		}
		
		/* Green for Deposit */
		.operation-display-box.deposit {
		    background: linear-gradient(135deg, #11998e 0%, #06c64f 100%);
		}
		
		/* Red for Withdrawal */
		.operation-display-box.withdrawal {
		    background: linear-gradient(135deg, #eb3349 0%, #f45c43 100%);
		}
		
		/* Purple for Transfer */
		.operation-display-box.transfer {
		    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		}
		
		.operation-display-box .display-label {
		    color: #fff;
		    font-size: 14px;
		    font-weight: 500;
		    letter-spacing: 0.5px;
		    opacity: 0.9;
		}
		
		.operation-display-box .display-value {
		    color: #fff;
		    font-size: 35px;
		    font-weight: bold;
		    text-transform: uppercase;
		    letter-spacing: 2px;
		}
		
		.save-button-container {
		    display: flex;
		    justify-content: center;
		    align-items: center;
		    margin: 15px 0;
		}
		
		.save-btn {
		    background-color: #373279;
		    color: white;
		    border: none;
		    padding: 10px 25px;
		    border-radius: 6px;
		    font-size: 14px;
		    font-weight: bold;
		    cursor: pointer;
		    transition: background-color 0.3s ease, transform 0.2s ease;
		}
		
		.save-btn:hover {
		    background-color: #2b0d73;
		    transform: scale(1.05);
		}
		
		.save-btn:active {
		    transform: scale(0.97);
		}
		
		/* Responsive adjustments */
		@media (max-width: 600px) {
		    .save-btn {
		        width: 80%;
		        padding: 10px;
		    }
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
                        <div class="label">Account Type:</div>
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
                                <input type="radio" name="accountCategory" value="current">
                                <span>Current</span>
                            </label>
                            <label class="radio-label">
                                <input type="radio" name="accountCategory" value="cc">
                                <span>CC</span>
                            </label>
                            <label class="radio-label">
                                <input type="radio" name="accountCategory" value="other">
                                <span>Other</span>
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
				            <input type="text" name="accountCode" id="accountCode" placeholder="Enter account code" maxlength="14" autocomplete="off">
				            <button type="button" class="icon-btn" id="accountLookupBtn" onclick="openLookup('account')">…</button>
				        </div>
				        <div class="search-hint">Type last 7 digits to search</div>
				        
				        <!-- LIVE SEARCH DROPDOWN -->
				        <div class="search-dropdown">
				            <div class="search-results" id="searchResults"></div>
				        </div>
				    </div>
				
				    <div>
				        <div class="label" id="accountNameLabel">Account Name</div>
				        <input type="text" name="accountName" id="accountName" placeholder="Account Name" style="width: 220px;" readonly>
				    </div>
				    <div>
				        <div class="label" id="transactionamountLabel">Transaction Amount</div>
				        <input type="text" name="transactionamount" id="transactionamount" placeholder="Enter Transaction Amount">
				    </div>
				    <div class="save-button-container">
					    <button type="button" class="save-btn" onclick="handleSaveTransaction()">Save</button>
					</div>

				
				    <!-- OPERATION DISPLAY BOX -->
					<div class="operation-display-box deposit" id="operationBox">
					    <span class="display-value" id="operationDisplay">DEPOSIT</span>
					</div>
				</div>
				
				<!-- Credit Account Code and Name Row -->
				<div class="row" id="creditAccountRow" style="display: none;">
				    <!-- Credit Account Code -->
				    <div>
				        <div class="label" id="creditAccountCodeLabel">Credit Account Code</div>
				        <div class="input-box">
				            <input type="text" name="creditAccountCode" id="creditAccountCode" placeholder="Enter credit account code" maxlength="14" autocomplete="off">
				            <button type="button" class="icon-btn" id="creditAccountLookupBtn" onclick="openLookup('creditAccount')">…</button>
				        </div>
				        <div class="search-hint">Type last 7 digits to search</div>
				        
				        <!-- LIVE SEARCH DROPDOWN FOR CREDIT ACCOUNT -->
				        <div class="search-dropdown">
				            <div class="search-results" id="creditSearchResults"></div>
				        </div>
				    </div>
				
				    <div>
				        <div class="label" id="creditAccountNameLabel">Credit Account Name</div>
				        <input type="text" name="creditAccountName" id="creditAccountName" placeholder="Account Name" style="width: 220px;" readonly>
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
        <button onclick="closeLookup()" style="float:right; cursor:pointer; background:#f44336; color:white; border:none; padding:8px 12px; border-radius:4px; font-size:16px;">✖</button>
        <div id="lookupContent"></div>
    </div>
</div>

<script>
//========== CONFIGURATION ==========
const MIN_SEARCH_LENGTH = 3;
const SEARCH_DELAY = 300;
let searchTimeout;
let currentCategory = 'saving';
let previousAccountCode = '';
let previousCreditAccountCode = '';

// ========== TOAST UTILITY ==========
function showToast(message, type = 'error') {
    const styles = {
        success: { borderColor: '#4caf50', icon: '✅' },
        error: { borderColor: '#f44336', icon: '❌' },
        warning: { borderColor: '#ff9800', icon: '⚠️' },
        info: { borderColor: '#2196F3', icon: 'ℹ️' }
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
            borderLeft: "5px solid " + style.borderColor,
            marginTop: "20px"
        }
    }).showToast();
}

// ========== CLEAR IFRAME CONTENT ==========
function clearIframe() {
    const iframe = document.getElementById('resultFrame');
    if (iframe) {
        iframe.src = 'about:blank';
    }
}

// ========== ACCOUNT CODE INPUT - DIGITS ONLY ==========
const accountCodeInput = document.getElementById('accountCode');

accountCodeInput.addEventListener('input', function(e) {
    const currentValue = this.value.replace(/\D/g, '');
    this.value = currentValue;
    
    // Clear Account Name if Account Code changes
    if (currentValue !== previousAccountCode) {
        document.getElementById('accountName').value = '';
        previousAccountCode = currentValue;
    }
    
    handleLiveSearch(currentValue);
});

accountCodeInput.addEventListener('keydown', function(e) {
    if ([8, 9, 27, 13, 46].indexOf(e.keyCode) !== -1 ||
        (e.keyCode === 65 && e.ctrlKey === true) ||
        (e.keyCode === 67 && e.ctrlKey === true) ||
        (e.keyCode === 86 && e.ctrlKey === true) ||
        (e.keyCode === 88 && e.ctrlKey === true) ||
        (e.keyCode >= 35 && e.keyCode <= 39)) {
        return;
    }
    if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
        e.preventDefault();
    }
});

// ========== HANDLE LIVE SEARCH ==========
function handleLiveSearch(value) {
    clearTimeout(searchTimeout);
    const searchResults = document.getElementById('searchResults');
    
    if (value.length === 0) {
        searchResults.classList.remove('active');
        return;
    }
    
    let searchNumber = value;
    if (value.length > 7) {
        searchNumber = value.slice(-7);
    }
    
    if (searchNumber.length < MIN_SEARCH_LENGTH) {
        searchResults.innerHTML = '<div class="search-info">Type at least ' + MIN_SEARCH_LENGTH + ' digits to search...</div>';
        searchResults.classList.add('active');
        return;
    }
    
    searchResults.innerHTML = '<div class="search-loading"><div class="loading-spinner"></div><div style="margin-top: 8px;">Searching...</div></div>';
    searchResults.classList.add('active');
    
    searchTimeout = setTimeout(function() {
        performSearch(searchNumber);
    }, SEARCH_DELAY);
}

// ========== PERFORM SEARCH ==========
function performSearch(searchNumber) {
    const searchResults = document.getElementById('searchResults');
    currentCategory = document.querySelector('input[name="accountCategory"]:checked').value;
    
    fetch('SearchAccounts.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'searchNumber=' + encodeURIComponent(searchNumber) + '&category=' + encodeURIComponent(currentCategory)
    })
    .then(function(response) {
        if (!response.ok) throw new Error('Network error');
        return response.json();
    })
    .then(function(data) {
        if (data.error) {
            searchResults.innerHTML = '<div class="no-results">' + data.error + '</div>';
            return;
        }
        if (data.accounts && data.accounts.length > 0) {
            displaySearchResults(data.accounts, searchNumber);
        } else {
            searchResults.innerHTML = '<div class="no-results">No accounts found matching "' + searchNumber + '"</div>';
        }
    })
    .catch(function(error) {
        console.error('Search error:', error);
        searchResults.innerHTML = '<div class="no-results">Error loading accounts. Please try again.</div>';
        showToast('Search failed. Please try again.', 'error');
    });
}

// ========== DISPLAY SEARCH RESULTS ==========
function displaySearchResults(accounts, searchNumber) {
    const searchResults = document.getElementById('searchResults');
    if (accounts.length === 0) {
        searchResults.innerHTML = '<div class="no-results">No accounts found</div>';
        return;
    }
    let html = '';
    accounts.forEach(function(account) {
        const highlightedCode = highlightMatch(account.code, searchNumber);
        const escapedName = account.name.replace(/'/g, "\\'");
        const productDesc = account.productDesc || '';
        
        html += '<div class="search-result-item" onclick="selectAccountFromSearch(\'' + 
                account.code + '\', \'' + escapedName + '\')">' +
                '<div class="result-code">' + highlightedCode + '</div>' +
                '<div class="result-name-row">' + account.name + '</div>';
        
        if (productDesc && productDesc.trim() !== '') {
            html += '<div class="result-product-desc">' + productDesc + '</div>';
        }
        
        html += '</div>';
    });
    searchResults.innerHTML = html;
}

// ========== HIGHLIGHT MATCHING TEXT ==========
function highlightMatch(text, search) {
    const index = text.indexOf(search);
    if (index === -1) return text;
    return text.substring(0, index) + '<span class="highlight">' + search + '</span>' + text.substring(index + search.length);
}

// ========== SELECT ACCOUNT FROM DROPDOWN ==========
function selectAccountFromSearch(code, name) {
    document.getElementById('accountCode').value = code;
    document.getElementById('accountName').value = name;
    previousAccountCode = code;
    document.getElementById('searchResults').classList.remove('active');
    setTimeout(function() { submitTransactionForm(); }, 500);
}

// ========== FILTER TABLE FUNCTION FOR LOOKUP ==========
function filterTable() {
    const searchBox = document.getElementById('searchBox');
    if (!searchBox) return;
    const searchValue = searchBox.value.toLowerCase().trim();
    const table = document.getElementById('lookupTable');
    if (!table) return;
    const rows = table.getElementsByClassName('data-row');
    let noResultsRow = document.getElementById('noResultsRow');
    if (searchValue.length < 2) {
        for (let i = 0; i < rows.length; i++) {
            rows[i].style.display = '';
        }
        if (noResultsRow) noResultsRow.style.display = 'none';
        return;
    }
    let visibleCount = 0;
    for (let i = 0; i < rows.length; i++) {
        const cells = rows[i].getElementsByTagName('td');
        if (cells.length < 2) continue;
        const code = cells[0].textContent.toLowerCase();
        const name = cells[1].textContent.toLowerCase();
        if (code.includes(searchValue) || name.includes(searchValue)) {
            rows[i].style.display = '';
            visibleCount++;
        } else {
            rows[i].style.display = 'none';
        }
    }
    if (visibleCount === 0) {
        if (!noResultsRow) {
            noResultsRow = table.insertRow(-1);
            noResultsRow.id = 'noResultsRow';
            noResultsRow.innerHTML = '<td colspan="2" class="no-results">No accounts found</td>';
        }
        noResultsRow.style.display = '';
    } else {
        if (noResultsRow) noResultsRow.style.display = 'none';
    }
}

function updateLabelsBasedOnOperation() {
    const operationType = document.querySelector("input[name='operationType']:checked").value;
    const accountCodeLabel = document.getElementById("accountCodeLabel");
    const accountNameLabel = document.getElementById("accountNameLabel");
    const accountCodeInput = document.getElementById("accountCode");
    const accountNameInput = document.getElementById("accountName");
    const operationDisplay = document.getElementById("operationDisplay");
    const operationBox = document.getElementById("operationBox");
    const creditAccountRow = document.getElementById("creditAccountRow");
    
    // Clear Account Code, Account Name and iframe when operation type changes
    accountCodeInput.value = '';
    accountNameInput.value = '';
    document.getElementById('creditAccountCode').value = '';
    document.getElementById('creditAccountName').value = '';
    previousAccountCode = '';
    previousCreditAccountCode = '';
    clearIframe();
    
    // Update the display box text
    operationDisplay.textContent = operationType.toUpperCase();
    
    // Update the display box color by changing classes
    operationBox.className = 'operation-display-box ' + operationType;
    
    if (operationType === "transfer") {
        accountCodeLabel.textContent = "Debit Account Code";
        accountNameLabel.textContent = "Debit Account Name";
        accountCodeInput.placeholder = "Enter debit account code";
        accountNameInput.placeholder = "Debit Account Name";
        creditAccountRow.style.display = "flex";
    } else {
        accountCodeLabel.textContent = "Account Code";
        accountNameLabel.textContent = "Account Name";
        accountCodeInput.placeholder = "Enter account code";
        accountNameInput.placeholder = "Account Name";
        creditAccountRow.style.display = "none";
    }
}

// ========== INITIALIZE ON PAGE LOAD ==========
document.addEventListener('DOMContentLoaded', function() {
    const operationRadios = document.querySelectorAll("input[name='operationType']");
    operationRadios.forEach(function(radio) {
        radio.addEventListener('change', updateLabelsBasedOnOperation);
    });
    
    // Credit Account Code - digits only
    const creditAccountCodeInput = document.getElementById('creditAccountCode');
    if (creditAccountCodeInput) {
        creditAccountCodeInput.addEventListener('input', function(e) {
            const currentValue = this.value.replace(/\D/g, '');
            this.value = currentValue;
            
            // Clear Credit Account Name if Credit Account Code changes
            if (currentValue !== previousCreditAccountCode) {
                document.getElementById('creditAccountName').value = '';
                previousCreditAccountCode = currentValue;
            }
            
            handleLiveSearchCredit(currentValue);
        });

        creditAccountCodeInput.addEventListener('keydown', function(e) {
            if ([8, 9, 27, 13, 46].indexOf(e.keyCode) !== -1 ||
                (e.keyCode === 65 && e.ctrlKey === true) ||
                (e.keyCode === 67 && e.ctrlKey === true) ||
                (e.keyCode === 86 && e.ctrlKey === true) ||
                (e.keyCode === 88 && e.ctrlKey === true) ||
                (e.keyCode >= 35 && e.keyCode <= 39)) {
                return;
            }
            if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
                e.preventDefault();
            }
        });
    }
    
    const categoryRadios = document.querySelectorAll("input[name='accountCategory']");
    categoryRadios.forEach(function(radio) {
        radio.addEventListener('change', function() {
            document.getElementById("accountCode").value = '';
            document.getElementById("accountName").value = '';
            previousAccountCode = '';
            document.getElementById('searchResults').classList.remove('active');
            currentCategory = this.value;
        });
    });
    
    // Initialize previous values
    previousAccountCode = document.getElementById('accountCode').value;
    previousCreditAccountCode = document.getElementById('creditAccountCode').value;
    
    updateLabelsBasedOnOperation();
});

// ========== LOOKUP MODAL FUNCTIONS ==========
function openLookup(type) {
    let accountCategory = document.querySelector("input[name='accountCategory']:checked").value;
    let url = "LookupForTransactions.jsp?type=" + (type === 'creditAccount' ? 'account' : type);
    if (type === 'account' || type === 'creditAccount') {
        url += "&accountCategory=" + accountCategory;
    }
    fetch(url)
        .then(function(response) { return response.text(); })
        .then(function(html) {
            document.getElementById("lookupContent").innerHTML = html;
            document.getElementById("lookupModal").style.display = "flex";
            window.currentLookupType = type;
            setTimeout(function() {
                const searchBox = document.getElementById('searchBox');
                if (searchBox) searchBox.focus();
            }, 100);
        })
        .catch(function(error) {
            showToast('Failed to load lookup data.', 'error');
            console.error('Lookup error:', error);
        });
}

function closeLookup() {
    document.getElementById("lookupModal").style.display = "none";
}

function sendBack(code, desc, type) {
    setValueFromLookup(code, desc, type);
}

function setValueFromLookup(code, desc, type) {
    if (window.currentLookupType === "creditAccount") {
        document.getElementById("creditAccountCode").value = code;
        document.getElementById("creditAccountName").value = desc;
        previousCreditAccountCode = code;
        closeLookup();
    } else if (type === "account") {
        document.getElementById("accountCode").value = code;
        document.getElementById("accountName").value = desc;
        previousAccountCode = code;
        closeLookup();
        setTimeout(function() { submitTransactionForm(); }, 500);
    }
}

// ========== SUBMIT TRANSACTION FORM ==========
function submitTransactionForm() {
    let transTypeRadio = document.querySelector("input[name='transactionTypeRadio']:checked").value;
    let operationType = document.querySelector("input[name='operationType']:checked").value;
    let accountCategory = document.querySelector("input[name='accountCategory']:checked").value;
    let accountCode = document.querySelector("input[name='accountCode']").value.trim();
    let accountName = document.querySelector("input[name='accountName']").value.trim();
    console.log("Submitting:", transTypeRadio, operationType, accountCategory, accountCode, accountName);
    const pageMap = {
        "deposit": "transactionForm.jsp",
        "withdrawal": "transactionForm.jsp",
        "transfer": "transactionForm.jsp"
    };
    if (pageMap[operationType]) {
        let form = document.getElementById("transactionForm");
        form.action = pageMap[operationType];
        form.submit();
        showToast('Loading transaction form...', 'info');
    } else {
        showToast('No page found for Operation Type: ' + operationType, 'error');
    }
}

// ========== CLOSE DROPDOWN AND MODAL ==========
document.addEventListener('click', function(e) {
    if (!e.target.closest('.input-box') && !e.target.closest('.search-dropdown')) {
        document.getElementById('searchResults').classList.remove('active');
        const creditResults = document.getElementById('creditSearchResults');
        if (creditResults) creditResults.classList.remove('active');
    }
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeLookup();
        document.getElementById('searchResults').classList.remove('active');
    }
});

// ========== CREDIT ACCOUNT LIVE SEARCH ==========
function handleLiveSearchCredit(value) {
    clearTimeout(searchTimeout);
    const searchResults = document.getElementById('creditSearchResults');
    
    if (value.length === 0) {
        searchResults.classList.remove('active');
        return;
    }
    
    let searchNumber = value;
    if (value.length > 7) {
        searchNumber = value.slice(-7);
    }
    
    if (searchNumber.length < MIN_SEARCH_LENGTH) {
        searchResults.innerHTML = '<div class="search-info">Type at least ' + MIN_SEARCH_LENGTH + ' digits to search...</div>';
        searchResults.classList.add('active');
        return;
    }
    
    searchResults.innerHTML = '<div class="search-loading"><div class="loading-spinner"></div><div style="margin-top: 8px;">Searching...</div></div>';
    searchResults.classList.add('active');
    
    searchTimeout = setTimeout(function() {
        performSearchCredit(searchNumber);
    }, SEARCH_DELAY);
}

function performSearchCredit(searchNumber) {
    const searchResults = document.getElementById('creditSearchResults');
    currentCategory = document.querySelector('input[name="accountCategory"]:checked').value;
    
    fetch('SearchAccounts.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'searchNumber=' + encodeURIComponent(searchNumber) + '&category=' + encodeURIComponent(currentCategory)
    })
    .then(function(response) {
        if (!response.ok) throw new Error('Network error');
        return response.json();
    })
    .then(function(data) {
        if (data.error) {
            searchResults.innerHTML = '<div class="no-results">' + data.error + '</div>';
            return;
        }
        if (data.accounts && data.accounts.length > 0) {
            displaySearchResultsCredit(data.accounts, searchNumber);
        } else {
            searchResults.innerHTML = '<div class="no-results">No accounts found matching "' + searchNumber + '"</div>';
        }
    })
    .catch(function(error) {
        console.error('Search error:', error);
        searchResults.innerHTML = '<div class="no-results">Error loading accounts. Please try again.</div>';
        showToast('Search failed. Please try again.', 'error');
    });
}

function displaySearchResultsCredit(accounts, searchNumber) {
    const searchResults = document.getElementById('creditSearchResults');
    if (accounts.length === 0) {
        searchResults.innerHTML = '<div class="no-results">No accounts found</div>';
        return;
    }
    let html = '';
    accounts.forEach(function(account) {
        const highlightedCode = highlightMatch(account.code, searchNumber);
        const escapedName = account.name.replace(/'/g, "\\'");
        const productDesc = account.productDesc || '';
        
        html += '<div class="search-result-item" onclick="selectCreditAccountFromSearch(\'' + 
                account.code + '\', \'' + escapedName + '\')">' +
                '<div class="result-code">' + highlightedCode + '</div>' +
                '<div class="result-name-row">' + account.name + '</div>';
        
        if (productDesc && productDesc.trim() !== '') {
            html += '<div class="result-product-desc">' + productDesc + '</div>';
        }
        
        html += '</div>';
    });
    searchResults.innerHTML = html;
}

function selectCreditAccountFromSearch(code, name) {
    document.getElementById('creditAccountCode').value = code;
    document.getElementById('creditAccountName').value = name;
    previousCreditAccountCode = code;
    document.getElementById('creditSearchResults').classList.remove('active');
    showToast('Credit account selected: ' + code, 'success');
}

function handleSaveTransaction() {
    showToast('Save transaction functionality not yet implemented', 'warning');
}

//========== HIGHLIGHT MATCHING TEXT (LAST 7 DIGITS ONLY) ==========
function highlightMatch(text, search) {
    // Get the last 7 digits of the account code
    const last7Digits = text.slice(-7);
    
    // Find the match position within the last 7 digits
    const matchIndex = last7Digits.indexOf(search);
    
    // If no match found in last 7 digits, return original text
    if (matchIndex === -1) return text;
    
    // Calculate the actual position in the full text
    const actualIndex = text.length - 7 + matchIndex;
    
    // Build the highlighted string
    return text.substring(0, actualIndex) + 
           '<span class="highlight">' + 
           search + 
           '</span>' + 
           text.substring(actualIndex + search.length);
}
</script>
</body>
</html>