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
    <link rel="stylesheet" href="css/transactions.css">

   
</head>
<body>
<div class="container">
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
			        
			        <!-- Tallied Message -->
			        <div id="talliedMessage" style="display: none; color: green; font-weight: bold; font-size: 16px; margin-left: 20px;">
			            ✓ Transaction tallied
			        </div>
			    </div>
			</div>

                </div>

                <!-- Account Code and Name Row -->
				<div class="row">	
				<!-- Account Category Dropdown -->
				<div class="dropdown-inline">
				<div>
				    <div class="label">Account Type</div>
				    <select name="accountCategory" id="accountCategory" style="min-width: 100px;">
				        <option value="saving" selected>Saving</option>
				        <option value="loan">Loan</option>
				        <option value="deposit">Deposit</option>
				        <option value="pigmy">Pigmy</option>
				        <option value="current">Current</option>
				        <option value="cc">CC</option>
				        <option value="other">Other</option>
				    </select>
				</div>	</div>	
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
				
				
				
				
				<!-- LOAN SPECIFIC FIELDS (Hidden by default) -->
				<div id="loanFieldsSection" class="loan-fields-section">    
				    <div id="loanFieldsLoader" style="text-align: center; padding: 20px;">
				        <div class="loading-spinner"></div>
				        <div style="margin-top: 10px; color: #8066E8;">Loading loan fields...</div>
				    </div>
				    <div id="loanFieldsTableContainer" style="display: none;">
				        <table class="compact-loan-table" id="loanFieldsTable">
				            <thead id="loanTableHeader">
				                <!-- Headers will be dynamically generated -->
				            </thead>
				            <tbody id="loanTableBody">
				                <!-- Rows will be dynamically generated -->
				            </tbody>
				        </table>
				    </div>
				</div>
				
				<div id="creditAccountsContainer"></div>
				<!-- CLOSING TRANSACTION FIELDS (Hidden by default) -->
<div id="closingFieldsSection" class="closing-fields-section" style="display: none;">
    <fieldset>
        
        <div class="form-grid" style="grid-template-columns: repeat(5, 1fr);">
            
            <div>
                <label>Ledger Balance</label>
                <input type="text" id="closingLedgerBalance" name="closingLedgerBalance" readonly>
            </div>
            
            <div>
                <label>Available Balance</label>
                <input type="text" id="closingAvailableBalance" name="closingAvailableBalance" readonly>
            </div>
            
            <div>
                <label>Closing Interest</label>
                <input type="text" id="closingInterest" name="closingInterest" placeholder="0.00">
            </div>
            
            <div>
                <label>Closing Balance</label>
                <input type="text" id="closingBalance" name="closingBalance" placeholder="0.00">
            </div>
            
            <div>
                <label>Against Effect Int.</label>
                <input type="text" id="againstEffectInt" name="againstEffectInt" placeholder="0.00">
            </div>
            
            <div>
                <label>TOD Interest</label>
                <input type="text" id="todInterest" name="todInterest" placeholder="0.00">
            </div>
            
            <div>
                <label>Service Charges</label>
                <input type="text" id="serviceCharges" name="serviceCharges" placeholder="0.00">
            </div>
            
            <div>
                <label>Other Charges</label>
                <input type="text" id="otherCharges" name="otherCharges" placeholder="0.00">
            </div>
            
            <div>
                <label>Service Tax</label>
                <input type="text" id="serviceTax" name="serviceTax" placeholder="0.00">
            </div>
            
        </div>
    </fieldset>
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

    <script src="js/transactions.js"></script>
</body>
</html>