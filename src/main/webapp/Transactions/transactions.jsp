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
            width: 112px;
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
		    margin: 15px 0px 15px 0px;
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
		
		
		.add-btn {
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
		
		.add-btn:hover {
		    background-color: #2b0d73;
		    transform: scale(1.05);
		}
		
		.add-btn:active {
		    transform: scale(0.97);
		}
		
		/* Container for dynamically added credit account rows */
		.credit-accounts-container {
		    margin-top: 15px;
		}
		
		.credit-account-row {
		    display: flex;
		    gap: 20px;
		    margin-bottom: 15px;
		    padding: 15px;
		    background-color: #f9f9f9;
		    border-radius: 8px;
		    border: 1px solid #ddd;
		    align-items: flex-end;
		}
		
		.remove-btn {
		    background-color: #c62828;
		    color: white;
		    border: none;
		    padding: 8px 15px;
		    border-radius: 6px;
		    font-size: 12px;
		    font-weight: bold;
		    cursor: pointer;
		    transition: background-color 0.3s ease;
		    height: fit-content;
		}
		
		.remove-btn:hover {
		    background-color: #b71c1c;
		}
		/* Responsive adjustments */
		@media (max-width: 600px) {
		    .save-btn {
		        width: 80%;
		        padding: 10px;
		    }
		}
		
		select {
		    padding: 10px;
		    border: 2px solid #C8B7F6;
		    border-radius: 8px;
		    background-color: #F4EDFF;
		    color: #3D316F;
		    font-size: 14px;
		    font-weight: 600;
		    cursor: pointer;
		    outline: none;
		    transition: all 0.3s ease;
		}
		
		select:hover {
		    border-color: #8066E8;
		    background: #E8DCFF;
		}
		
		select:focus {
		    border-color: #8066E8;
		    background: #E8DCFF;
		    box-shadow: 0 0 0 3px rgba(128, 102, 232, 0.1);
		}

	select option {
	    background-color: white;
	    color: #3D316F;
	    padding: 10px;
	}
	/* Dropdown inline styles */
	.dropdown-inline {
	    display: flex;
	    flex-direction: row;
	    align-items: center;
	    gap: 10px;
	}
	
	.dropdown-inline .label {
	    margin-bottom: 0;
	    white-space: nowrap;
	}
	
	.dropdown-inline select {
	    padding: 10px;
	    border: 2px solid #C8B7F6;
	    border-radius: 8px;
	    background-color: #F4EDFF;
	    color: #3D316F;
	    font-size: 14px;
	    font-weight: 600;
	    cursor: pointer;
	}
	.op-type-inline {
    display: inline-flex;        /* 👈 forces single row */
    align-items: center;         /* vertical center */
    gap: 12px;                   /* space between label & dropdown */
    white-space: nowrap;         /* 👈 NO wrapping */
    font-size: 14px;
	}
	
	.op-type-inline label {
	    font-weight:bold;
	}
	
	.op-type-inline select {
	    min-width: 100px;
	}
	
	.totals-row {
    display: flex;
    align-items: center;
    gap: 12px;
    white-space: nowrap;
	}
	
	.total-label {
	    font-weight: bold;
	    font-size: 14px;
	    color: #3D316F;
	}
	
	.totals-row input[type="text"] {
	    width: 95px;
	    text-align: right;
	    font-weight: bold;
	    background-color: #eef2ff;
	    border: 2px solid #C8B7F6;
	    border-radius: 6px;
	}
	
	/* Loan-specific fields section */
	.loan-fields-section {
	    display: none;
	    margin-top: 20px;
	    padding: 20px;
	    background-color: #fff9e6;
	    border: 2px solid #ffc107;
	    border-radius: 8px;
	}
	
	.loan-fields-section.active {
	    display: block;
	}
	
	.loan-fields-section .section-title {
	    font-size: 16px;
	    font-weight: bold;
	    color: #3D316F;
	    margin-bottom: 15px;
	    padding-bottom: 10px;
	    border-bottom: 2px solid #ffc107;
	}
	
	.loan-field-group {
	    display: grid;
	    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
	    gap: 15px;
	    margin-top: 10px;
	}
	
	.loan-field-item {
	    display: flex;
	    flex-direction: column;
	}
	
	.loan-field-item .label {
	    margin-bottom: 5px;
	}
	
	.loan-field-item input[type="text"] {
	    width: 65%;
	}
	/* Dual input under one label */
	.dual-input {
	    display: flex;
	    gap: 10px;
	}
	
	.dual-input-item {
	    display: flex;
	    flex-direction: column;
	}
	
	.dual-label {
	    font-size: 12px;
	    font-weight: bold;
	    color: #3D316F;
	    margin-bottom: 4px;
	}
	
	.dual-input-item input[type="text"] {
	    width: 90px;
	    text-align: right;
	}
	
	/* Transfer-specific fields section */
	.transfer-fields-section {
	    display: none;
	    padding: 15px;
	    background-color: #f0e6ff;
	    border: 2px solid #C8B7F6;
	    border-radius: 8px;
	}
	
	.transfer-fields-section.active {
	    display: block;
	}
	
	.transfer-fields-section .section-title {
	    font-size: 16px;
	    font-weight: bold;
	    color: #3D316F;
	    margin-bottom: 15px;
	    padding-bottom: 10px;
	    border-bottom: 2px solid #8066E8;
	}
	
	.transfer-field-group {
	    display: flex;
	    align-items: center;
	    gap: 20px;
	    flex-wrap: wrap;
	}
	
	/* Base select */
	#opType {
	    font-weight: bold;
	    color: #fff;
	    border-radius: 8px;
	    padding: 8px 12px;
	    border: 2px solid #C8B7F6;
	}
	
	/* Selected background */
	#opType.debit-bg {
	    background-color: #ff0000;
	}
	
	#opType.credit-bg {
	    background-color: #16b21d;
	}
	
	/* ===== DROPDOWN LIST COLORS ===== */
	
	/* Debit option */
	#opType option[value="Debit"] {
	    background-color: #ff0000;
	    color: #fff;
	    font-weight: bold;
	}
	
	/* Credit option */
	#opType option[value="Credit"] {
	    background-color: #16b21d;
	    color: #fff;
	    font-weight: bold;
	}
	
	/* Hover effect (Chrome / Edge) */
	#opType option:hover {
	    filter: brightness(0.9);
	}
		
    </style>
</head>
<body>

<div class="container">
	<h1> TRANSACTION </h1>
	
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

                <!-- Account Category Dropdown -->
				<div class="dropdown-inline">
				    <div class="label">Account Type:</div>
				    <select name="accountCategory" id="accountCategory" style="min-width: 100px;">
				        <option value="saving" selected>Saving</option>
				        <option value="loan">Loan</option>
				        <option value="deposit">Deposit</option>
				        <option value="pigmy">Pigmy</option>
				        <option value="current">Current</option>
				        <option value="cc">CC</option>
				        <option value="other">Other</option>
				    </select>
				</div>
				
				<!-- TRANSFER SPECIFIC FIELDS (Hidden by default) -->
		<div id="transferFieldsSection" class="transfer-fields-section">
		    <div class="transfer-field-group">
		        <!-- OP Type Dropdown -->
		        <div class="op-type-inline">
		            <label for="opType">OP Type:</label>
		            <select id="opType" name="opType">
		                <option value="Debit" selected>DEBIT</option>
		                <option value="Credit">CREDIT</option>
		            </select>
		        </div>
		        
		        <!-- Totals -->
		        <div class="totals-row">
		            <span class="total-label">Total Debit:</span>
		            <input type="text" id="totalDebit" readonly>
		        </div>
		        
		        <div class="totals-row">
		            <span class="total-label">Total Credit:</span>
		            <input type="text" id="totalCredit" readonly>
		        </div>
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
					    <input type="text" name="transactionamount" id="transactionamount" placeholder="Enter Transaction Amount" oninput="calculateNewBalanceInIframe()">
					</div>
					<div>
					    <div class="label">Particular</div>
					    <textarea name="particular" id="particular" placeholder="Enter particular details" style="width: 250px; height: 40px; padding: 10px; border: 2px solid #C8B7F6; border-radius: 8px; background-color: #F4EDFF; resize: vertical;"></textarea>
					</div>
					
					<div class="save-button-container">
					    <button type="button" class="add-btn" onclick="addTransactionRow()">+</button>
					</div>
				    <div class="save-button-container">
					    <button type="button" class="save-btn" onclick="handleSaveTransaction()">Save</button>
				</div>

				</div>
				
				
				<div id="creditAccountsContainer"></div>
				
				<!-- LOAN SPECIFIC FIELDS (Hidden by default) -->
				<div id="loanFieldsSection" class="loan-fields-section">
				    <div class="loan-field-group">
				        <div class="loan-field-item">
						    <div class="label">Insurance</div>
						
						    <div class="dual-input">
						        <div class="dual-input-item">
						            <span class="dual-label">Receivable</span>
						            <input type="text" name="insuranceReceivable" id="insuranceReceivable" placeholder="0.00" readonly>
						        </div>
						
						        <div class="dual-input-item">
						            <span class="dual-label">Received</span>
						            <input type="text" name="insuranceReceived" id="insuranceReceived" placeholder="0.00">
						        </div>
						    </div>
						</div>
				        <div class="loan-field-item">
				            <div class="label">Other Charges</div>
				            <div class="dual-input">
						        <div class="dual-input-item">
						            <span class="dual-label">Receivable</span>
						            <input type="text" name="OtherChargesReceivable" id="OtherChargesReceivable" placeholder="0.00" readonly>
						        </div>
						
						        <div class="dual-input-item">
						            <span class="dual-label">Received</span>
						            <input type="text" name="OtherChargesReceived" id="OtherChargesReceived" placeholder="0.00">
						        </div>
						    </div>
				        </div>
				        <div class="loan-field-item">
				            <div class="label">Interest Receivable</div>
				            <div class="dual-input">
						        <div class="dual-input-item">
						            <span class="dual-label">Receivable</span>
						            <input type="text" name="InterestReceivable" id="InterestReceivable" placeholder="0.00" readonly>
						        </div>
						
						        <div class="dual-input-item">
						            <span class="dual-label">Received</span>
						            <input type="text" name="InterestReceived" id="InterestReceived" placeholder="0.00">
						        </div>
						    </div>
				        </div>
				        <div class="loan-field-item">
				            <div class="label">Penal Receivable</div>
				            <div class="dual-input">
						        <div class="dual-input-item">
						            <span class="dual-label">Receivable</span>
						            <input type="text" name="PenalReceivable" id="PenalReceivable" placeholder="0.00" readonly>
						        </div>
						
						        <div class="dual-input-item">
						            <span class="dual-label">Received</span>
						            <input type="text" name="PenalReceived" id="PenalReceived" placeholder="0.00">
						        </div>
						    </div>
				        </div>
				        <div class="loan-field-item">
				            <div class="label">Penal Interest</div>
				            <div class="dual-input">
						        <div class="dual-input-item">
						            <span class="dual-label">Receivable</span>
						            <input type="text" name="PenalInterestReceivable" id="PenalInterestReceivable" placeholder="0.00" readonly>
						        </div>
						
						        <div class="dual-input-item">
						            <span class="dual-label">Received</span>
						            <input type="text" name="PenalInterestReceived" id="PenalInterestReceived" placeholder="0.00">
						        </div>
						    </div>
				        </div>
				        <div class="loan-field-item">
				            <div class="label">Postage</div>
				            <div class="dual-input">
						        <div class="dual-input-item">
						            <span class="dual-label">Receivable</span>
						            <input type="text" name="PostageReceivable" id="PostageReceivable" placeholder="0.00" readonly>
						        </div>
						
						        <div class="dual-input-item">
						            <span class="dual-label">Received</span>
						            <input type="text" name="PostageReceived" id="PostageReceived" placeholder="0.00">
						        </div>
						    </div>
				        </div>
				        <div class="loan-field-item">
				            <div class="label">Current Interest</div>
				            <div class="dual-input">
						        <div class="dual-input-item">
						            <span class="dual-label">Receivable</span>
						            <input type="text" name="CurrentInterestReceivable" id="CurrentInterestReceivable" placeholder="0.00" readonly>
						        </div>
						
						        <div class="dual-input-item">
						            <span class="dual-label">Received</span>
						            <input type="text" name="CurrentInterestReceived" id="CurrentInterestReceived" placeholder="0.00">
						        </div>
						    </div>
				        </div>
				        <div class="loan-field-item">
				            <div class="label">Overdue Amount</div>
				            <div class="dual-input">
						        <div class="dual-input-item">
						            <span class="dual-label">Receivable</span>
						            <input type="text" name="OverdueAmountReceivable" id="OverdueAmountReceivable" placeholder="0.00" readonly>
						        </div>
						
						        <div class="dual-input-item">
						            <span class="dual-label">Received</span>
						            <input type="text" name="OverdueAmountReceived" id="OverdueAmountReceived" placeholder="0.00">
						        </div>
						    </div>
				        </div>
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
    currentCategory = document.getElementById('accountCategory').value;
    
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
    const last7Digits = text.slice(-7);
    const matchIndex = last7Digits.indexOf(search);
    
    if (matchIndex === -1) return text;
    
    const actualIndex = text.length - 7 + matchIndex;
    
    return text.substring(0, actualIndex) + 
           '<span class="highlight">' + 
           search + 
           '</span>' + 
           text.substring(actualIndex + search.length);
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

//========== UPDATE LABELS AND SHOW/HIDE TRANSFER CONTROLS ==========
function updateLabelsBasedOnOperation() {
    const operationType = document.querySelector("input[name='operationType']:checked").value;

    const accountCodeInput = document.getElementById("accountCode");
    const accountNameInput = document.getElementById("accountName");
    const accountCodeLabel = document.getElementById("accountCodeLabel");
    const accountNameLabel = document.getElementById("accountNameLabel");
    const transactionAmountLabel = document.getElementById("transactionamountLabel");

    const addButtonDiv = document.querySelector('.add-btn').parentElement;
    const creditAccountsContainer = document.getElementById('creditAccountsContainer');

    // Clear inputs
    accountCodeInput.value = '';
    accountNameInput.value = '';
    document.getElementById('transactionamount').value = '';
    document.getElementById('particular').value = '';
    previousAccountCode = '';
    clearIframe();

    // Clear transaction data
    creditAccountsData = [];
    refreshCreditAccountsTable();
    updateTotals();

    // ✅ Toggle transfer fields visibility
    toggleTransferFields();

    if (operationType === 'transfer') {
        // Update labels for transfer mode
        const opType = document.getElementById('opType').value;
        if (opType === 'Debit') {
            accountCodeLabel.textContent = 'Debit Account Code';
            accountNameLabel.textContent = 'Debit Account Name';
            transactionAmountLabel.textContent = 'Debit Amount';
        } else {
            accountCodeLabel.textContent = 'Credit Account Code';
            accountNameLabel.textContent = 'Credit Account Name';
            transactionAmountLabel.textContent = 'Credit Amount';
        }
        
        addButtonDiv.style.display = 'flex';
        creditAccountsContainer.style.display = 'block';
    } else {
        // Reset labels for deposit/withdrawal
        accountCodeLabel.textContent = 'Account Code';
        accountNameLabel.textContent = 'Account Name';
        transactionAmountLabel.textContent = 'Transaction Amount';
        
        addButtonDiv.style.display = 'none';
        creditAccountsContainer.style.display = 'none';
    }
}

//========== TOGGLE LOAN FIELDS VISIBILITY ==========
function toggleLoanFields() {
    const accountCategory = document.getElementById('accountCategory').value;
    const loanFieldsSection = document.getElementById('loanFieldsSection');
    
    if (accountCategory === 'loan') {
        loanFieldsSection.classList.add('active');
    } else {
        loanFieldsSection.classList.remove('active');
        // Clear loan fields when switching away from loan
        clearLoanFields();
    }
}

function clearLoanFields() {
    const fields = [
        'insuranceReceivable',
        'insuranceReceived',
        'OtherChargesReceivable',
        'OtherChargesReceived',
        'InterestReceivable',
        'InterestReceived',
        'PenalReceivable',
        'PenalReceived',
        'PostageReceivable',
        'PostageReceived',
        'CurrentInterestReceivable',
        'CurrentInterestReceived',
        'OverdueAmountReceivable',
        'OverdueAmountReceived',
        'PenalInterestReceivable',
        'PenalInterestReceived'
    ];

    fields.forEach(function(id) {
        const el = document.getElementById(id);
        if (el) {
            el.value = '';
        }
    });
}

//========== TOGGLE TRANSFER FIELDS VISIBILITY ==========
function toggleTransferFields() {
    const operationType = document.querySelector("input[name='operationType']:checked").value;
    const transferFieldsSection = document.getElementById('transferFieldsSection');
    
    if (operationType === 'transfer') {
        transferFieldsSection.classList.add('active');
    } else {
        transferFieldsSection.classList.remove('active');
    }
}
// ========== INITIALIZE ON PAGE LOAD ==========
document.addEventListener('DOMContentLoaded', function() {
    // Initialize transaction table
    refreshCreditAccountsTable();
    
    
    // Operation type change handler
    const operationRadios = document.querySelectorAll("input[name='operationType']");
    operationRadios.forEach(function(radio) {
        radio.addEventListener('change', function() {
            updateLabelsBasedOnOperation();
            calculateNewBalanceInIframe();
        });
    });
    
    // Handle OP Type dropdown change
    const opTypeSelect = document.getElementById('opType');
    if (opTypeSelect) {
        opTypeSelect.addEventListener('change', function() {
            const opType = this.value;
            const accountCodeLabel = document.getElementById("accountCodeLabel");
            const accountNameLabel = document.getElementById("accountNameLabel");
            const transactionAmountLabel = document.getElementById("transactionamountLabel");
            
            if (opType === 'Debit') {
                accountCodeLabel.textContent = 'Debit Account Code';
                accountNameLabel.textContent = 'Debit Account Name';
                transactionAmountLabel.textContent = 'Debit Amount';
            } else if (opType === 'Credit') {
                accountCodeLabel.textContent = 'Credit Account Code';
                accountNameLabel.textContent = 'Credit Account Name';
                transactionAmountLabel.textContent = 'Credit Amount';
            }
            
            // Clear inputs when OP Type changes
            document.getElementById('accountCode').value = '';
            document.getElementById('accountName').value = '';
            document.getElementById('transactionamount').value = '';
            document.getElementById('particular').value = '';
            previousAccountCode = '';
            clearIframe();
        });
    }
    
 // Category change handler
    const categoryDropdown = document.getElementById('accountCategory');
    if (categoryDropdown) {
        categoryDropdown.addEventListener('change', function() {
            document.getElementById("accountCode").value = '';
            document.getElementById("accountName").value = '';
            document.getElementById("transactionamount").value = '';
            previousAccountCode = '';
            document.getElementById('searchResults').classList.remove('active');
            currentCategory = this.value;
            
            // ✅ Toggle loan fields visibility
            toggleLoanFields();
        });
    }
    // Initialize previous values
    previousAccountCode = document.getElementById('accountCode').value;
    
    // Transaction amount input handler for totals
    const transactionAmountInput = document.getElementById('transactionamount');
    if (transactionAmountInput) {
        transactionAmountInput.addEventListener('input', updateTotals);
    }
    
    // Initial call to set visibility
    updateLabelsBasedOnOperation();
    toggleLoanFields();
    toggleTransferFields();
});

// ========== LOOKUP MODAL FUNCTIONS ==========
function openLookup(type) {
	let accountCategory = document.getElementById('accountCategory').value;
    let url = "LookupForTransactions.jsp?type=account";
    url += "&accountCategory=" + accountCategory;
    
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
    window.currentLookupType = null;
}

function sendBack(code, desc, type) {
    setValueFromLookup(code, desc, type);
}

function setValueFromLookup(code, desc, type) {
    document.getElementById("accountCode").value = code;
    document.getElementById("accountName").value = desc;
    previousAccountCode = code;
    window.currentLookupType = null;
    closeLookup();
    setTimeout(function() { submitTransactionForm(); }, 500);
}

// ========== SUBMIT TRANSACTION FORM ==========
function submitTransactionForm() {
    let transTypeRadio = document.querySelector("input[name='transactionTypeRadio']:checked").value;
    let operationType = document.querySelector("input[name='operationType']:checked").value;
    let accountCategory = document.getElementById('accountCategory').value;
    let accountCode = document.querySelector("input[name='accountCode']").value.trim();
    let accountName = document.querySelector("input[name='accountName']").value.trim();
    
    console.log("Submitting:", transTypeRadio, operationType, accountCategory, accountCode, accountName);
    
    const pageMap = {
        "deposit": "transactionForm.jsp",
        "withdrawal": "transactionForm.jsp",
        "transfer": "transferForm.jsp"
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
    }
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeLookup();
        document.getElementById('searchResults').classList.remove('active');
    }
});

function handleSaveTransaction() {
    showToast('Save transaction functionality not yet implemented', 'warning');
}

function calculateNewBalanceInIframe() {
    const transactionAmount = parseFloat(document.getElementById('transactionamount').value) || 0;
    const operationType = document.querySelector("input[name='operationType']:checked").value;
    
    const iframe = document.getElementById('resultFrame');
    
    try {
        const iframeWindow = iframe.contentWindow;
        const iframeDoc = iframeWindow.document;
        
        const ledgerBalanceField = iframeDoc.getElementById('ledgerBalance');
        const newLedgerBalanceField = iframeDoc.getElementById('newLedgerBalance');
        
        if (ledgerBalanceField && newLedgerBalanceField) {
            const ledgerBalance = parseFloat(ledgerBalanceField.value) || 0;
            let newLedgerBalance = ledgerBalance;
            
            if (transactionAmount > 0) {
                if (operationType === 'deposit') {
                    newLedgerBalance = ledgerBalance + transactionAmount;
                } else if (operationType === 'withdrawal') {
                    newLedgerBalance = ledgerBalance - transactionAmount;
                }
            }
            
            newLedgerBalanceField.value = newLedgerBalance.toFixed(2);
        }
    } catch (e) {
        console.error('Error calculating balance:', e);
    }
}

	// ========== DYNAMIC TRANSACTION TABLE ==========
	let creditAccountsData = [];
	
	function addTransactionRow() {
	    const accountCode = document.getElementById('accountCode').value.trim();
	    const accountName = document.getElementById('accountName').value.trim();
	    const transactionAmount = document.getElementById('transactionamount').value.trim();
	    const particular = document.getElementById('particular').value.trim();
	    const opType = document.getElementById('opType').value;
	
	    // Validate inputs
	    if (!accountCode) {
	        showToast('Please enter or select an account code', 'error');
	        return;
	    }
	
	    if (!accountName) {
	        showToast('Please select an account', 'error');
	        return;
	    }
	
	    if (!transactionAmount || parseFloat(transactionAmount) <= 0) {
	        showToast('Please enter a valid transaction amount', 'error');
	        return;
	    }
	
	    const finalAmount = parseFloat(transactionAmount).toFixed(2);
	
	    // ✅ Add to data array (NO duplicate check now)
	    creditAccountsData.push({
	        id: Date.now(),
	        code: accountCode,
	        name: accountName,
	        amount: finalAmount,
	        particular: particular,
	        opType: opType
	    });
	
	    // Clear input fields
	    document.getElementById('accountCode').value = '';
	    document.getElementById('accountName').value = '';
	    document.getElementById('transactionamount').value = '';
	    document.getElementById('particular').value = '';
	    previousAccountCode = '';
	    clearIframe();
	
	    // Refresh table + totals
	    refreshCreditAccountsTable();
	    updateTotals();
	
	    
	}


function refreshCreditAccountsTable() {
    const container = document.getElementById('creditAccountsContainer');
    
    if (creditAccountsData.length === 0) {
        container.innerHTML = '<p style="text-align: center; color: #999; padding: 20px;">No transactions added yet</p>';
        return;
    }
    
	    let tableHTML = '<table style="width: 100%; border-collapse: collapse; margin-top: 8px; font-size: 13px;">' +
		    '<thead>' +
		    '<tr style="background-color: #373279; color: white;">' +
		    '<th style="padding: 6px 8px; text-align: left; border: 1px solid #ddd;">OP Type</th>' +
		    '<th style="padding: 6px 8px; text-align: left; border: 1px solid #ddd;">Account Code</th>' +
		    '<th style="padding: 6px 8px; text-align: left; border: 1px solid #ddd;">Account Name</th>' +
		    '<th style="padding: 6px 8px; text-align: right; border: 1px solid #ddd;">Amount</th>' +
		    '<th style="padding: 6px 8px; text-align: left; border: 1px solid #ddd;">Particular</th>' +
		    '<th style="padding: 6px 8px; text-align: center; border: 1px solid #ddd; width: 60px;">Action</th>' +
		    '</tr>' +
		    '</thead>' +
		    '<tbody>';
		
		creditAccountsData.forEach(function(account) {
		const rowBgColor = account.opType === 'Debit' ? '#FF4D0F' : '#3AD330';
		
		tableHTML += '<tr style="background-color:' + rowBgColor + '; color:white; line-height:1.2;">' +
		     '<td style="padding:4px 6px; border:1px solid #ddd; font-weight:bold;">' + account.opType + '</td>' +
		     '<td style="padding:4px 6px; border:1px solid #ddd; cursor:pointer; text-decoration:underline;" ' +
		     'onclick="loadAccountInTransferForm(\'' + account.code + '\', \'' + account.name.replace(/'/g, "\\'") + '\', \'' + account.opType + '\')">' +
		     account.code + '</td>' +
		     '<td style="padding:4px 6px; border:1px solid #ddd;">' + account.name + '</td>' +
		     '<td style="padding:4px 6px; border:1px solid #ddd; text-align:right; font-weight:bold;">₹ ' + account.amount + '</td>' +
		     '<td style="padding:4px 6px; border:1px solid #ddd;">' + (account.particular || '-') + '</td>' +
		     '<td style="padding:4px 6px; border:1px solid #ddd; text-align:center;">' +
		     '<button type="button" onclick="removeCreditAccount(' + account.id + ')" ' +
		     ' class="remove-btn" style="padding:2px 6px; font-size:14px;">×</button>' +
		     '</td>' +
		     '</tr>';
		});
	
	tableHTML += '</tbody></table>';

    
    container.innerHTML = tableHTML;
	}
	
	function removeCreditAccount(accountId) {
	    creditAccountsData = creditAccountsData.filter(acc => acc.id !== accountId);
	
	    refreshCreditAccountsTable();
	
	    // ✅ UPDATE TOTALS
	    updateTotals();
	
	    
	}


	function updateTotals() {
    let totalDebit = 0;
    let totalCredit = 0;

    creditAccountsData.forEach(function (row) {
        const amount = parseFloat(row.amount) || 0;

        if (row.opType === 'Debit') {
            totalDebit += amount;
        } else if (row.opType === 'Credit') {
            totalCredit += amount;
        }
    });

    document.getElementById('totalDebit').value = totalDebit.toFixed(2);
    document.getElementById('totalCredit').value = totalCredit.toFixed(2);

    // Optional: highlight when balanced
    if (totalDebit === totalCredit && totalDebit > 0) {
        document.getElementById('totalDebit').style.borderColor = 'green';
        document.getElementById('totalCredit').style.borderColor = 'green';
        showToast('transaction match', 'success');
    } else {
        document.getElementById('totalDebit').style.borderColor = '#C8B7F6';
        document.getElementById('totalCredit').style.borderColor = '#C8B7F6';
    	}
	}

	function loadAccountInTransferForm(accountCode, accountName, opType) {
	    const operationType = document.querySelector("input[name='operationType']:checked").value;
	    const accountCategory = document.getElementById('accountCategory').value;
	    
	    if (operationType !== 'transfer') {
	        showToast('This feature only works in transfer mode', 'warning');
	        return;
	    }
	    
	    // Build URL with parameters
	    let url = 'transferForm.jsp?';
	    url += 'operationType=' + encodeURIComponent(operationType);
	    url += '&accountCategory=' + encodeURIComponent(accountCategory);
	    
	    if (opType === 'Debit') {
	        url += '&accountCode=' + encodeURIComponent(accountCode);
	        url += '&accountName=' + encodeURIComponent(accountName);
	        url += '&creditAccountCode=';
	        url += '&creditAccountName=';
	    } else {
	        url += '&accountCode=';
	        url += '&accountName=';
	        url += '&creditAccountCode=' + encodeURIComponent(accountCode);
	        url += '&creditAccountName=' + encodeURIComponent(accountName);
	    }
	    
	    // Load in iframe
	    document.getElementById('resultFrame').src = url;

	}
	const opTypeSelect = document.getElementById('opType');

	function updateOpTypeBackground() {
	    opTypeSelect.classList.remove('debit-bg', 'credit-bg');

	    if (opTypeSelect.value === 'Debit') {
	        opTypeSelect.classList.add('debit-bg');
	    } else {
	        opTypeSelect.classList.add('credit-bg');
	    }
	}

	opTypeSelect.addEventListener('change', updateOpTypeBackground);
	updateOpTypeBackground();

</script>
</body>
</html>