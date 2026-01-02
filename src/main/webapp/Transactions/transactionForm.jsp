<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Get session and validate
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String branchCode = (String) sess.getAttribute("branchCode");
    
    // Get transaction type from form submission
    String transactionType = request.getParameter("transactionType");
    String transDescription = request.getParameter("transDescription");
    
    // Determine if deposit or withdrawal
    boolean isDeposit = "CSD".equalsIgnoreCase(transactionType);
    boolean isWithdrawal = "CSW".equalsIgnoreCase(transactionType);
    
    // Default to deposit if not specified
    if (!isDeposit && !isWithdrawal) {
        isDeposit = true;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= isDeposit ? "Cash Deposit" : "Cash Withdrawal" %></title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: Arial, sans-serif;
            background-color: #e8e4fc;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: #e8e4fc;
            border-radius: 8px;
        }
        
        .header {
            background: linear-gradient(135deg, #373279 0%, #2b0d73 100%);
            color: white;
            padding: 20px;
            text-align: center;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        
        .header h1 {
            font-size: 28px;
            margin-bottom: 10px;
            letter-spacing: 1px;
        }
        
        fieldset {
            background: #e8e4fc;
            border: 2px solid #aaa;
            margin: 20px 0;
            padding: 20px;
            border-radius: 9px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }
        
        legend {
            font-weight: bold;
            letter-spacing: 1px;
            font-size: 1.18em;
            padding: 0 10px;
            color: #373279;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
            margin-bottom: 15px;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        .form-group.full-width {
            grid-column: 1 / -1;
        }
        
        .form-group label {
            min-width: 10px;
            font-size: 13px;
            margin-bottom: 5px;
            font-weight: bold;
            color: #373279;
        }
        
        .form-group input[type="text"],
        .form-group input[type="date"] {
            padding: 6px 8px;
            font-size: 13px;
            width: 90%;
            border: 1px solid #9ca3af;
            border-radius: 4px;
            background-color: white;
            box-sizing: border-box;
        }
        
        .form-group input[type="text"]:focus,
        .form-group input[type="date"]:focus {
            outline: none;
            border-color: #373279;
            box-shadow: 0 0 0 2px rgba(55, 50, 121, 0.1);
        }
        
        .form-group input[readonly] {
            background-color: #f0f0f0;
            cursor: not-allowed;
        }
        
        .radio-group {
            display: flex;
            gap: 20px;
            margin-top: 5px;
        }
        
        .radio-group label {
            display: flex;
            align-items: center;
            gap: 5px;
            font-weight: normal;
            cursor: pointer;
        }
        
        .radio-group input[type="radio"] {
            cursor: pointer;
        }
        
        .input-with-button {
            display: flex;
            gap: 5px;
            width: 90%;
        }
        
        .input-with-button button {
            padding: 6px 12px;
            background-color: #d1d5db;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        
        .input-with-button button:hover {
            background-color: #9ca3af;
        }
        
        .input-with-button input {
            flex: 1;
        }
        
        .check-button {
            margin-top: 15px;
        }
        
        .check-button.center {
            text-align: center;
        }
        
        .btn {
            padding: 10px 25px;
            background-color: #373279;
            color: white;
            border: none;
            border-radius: 6px;
            font-weight: bold;
            font-size: 14px;
            cursor: pointer;
            transition: background-color 0.3s ease, transform 0.2s ease;
        }
        
        .btn:hover {
            background-color: #2b0d73;
            transform: scale(1.05);
        }
        
        .cheque-section {
            background-color: #f5f3ff;
            padding: 15px;
            border-radius: 8px;
            margin-top: 15px;
            border: 1px solid #d0d0d0;
        }
        
        .message-box {
            margin: 20px 0;
            padding: 15px;
        }
        
        .message-box label {
            font-weight: bold;
            color: #373279;
            font-size: 14px;
        }
        
        .message-content {
            margin-top: 10px;
            padding: 12px;
            background-color: white;
            border: 2px solid #f87171;
            border-radius: 6px;
            color: #dc2626;
            font-weight: bold;
        }
        
        .action-buttons {
            display: flex;
            justify-content: center;
            gap: 15px;
            padding: 25px 20px;
            background-color: #e8e4fc;
            border-radius: 8px;
            flex-wrap: wrap;
            margin-top: 20px;
        }
        
        .action-buttons button {
            padding: 10px 25px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
            font-size: 14px;
            transition: all 0.3s ease;
        }
        
        .action-buttons button.disabled {
            background-color: #d1d5db;
            color: #6b7280;
        }
        
        .action-buttons button.disabled:hover {
            background-color: #9ca3af;
            transform: scale(1.05);
        }
        
        .action-buttons button.primary {
            background-color: #373279;
            color: white;
        }
        
        .action-buttons button.primary:hover {
            background-color: #2b0d73;
            transform: scale(1.05);
        }
        
        .amount-display {
            background-color: #f0f0f0;
            padding: 8px;
            border-radius: 4px;
            min-height: 38px;
            border: 1px solid #9ca3af;
        }

        @media (max-width: 1024px) {
            .form-row {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 600px) {
            .form-row {
                grid-template-columns: 1fr;
            }
            
            .input-with-button,
            .form-group input[type="text"],
            .form-group input[type="date"] {
                width: 100%;
            }
        }
    </style>
    <script>
        function toggleChequeFields() {
            var withdrawalBy = document.querySelector('input[name="withdrawalBy"]:checked').value;
            var chequeSection = document.getElementById('chequeSection');
            if (withdrawalBy === 'cheque') {
                chequeSection.style.display = 'block';
            } else {
                chequeSection.style.display = 'none';
            }
        }
    </script>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <h1><%= isDeposit ? "CASH DEPOSIT" : "CASH WITHDRAWAL" %></h1>
        </div>

        <!-- Account Info Section -->
        <fieldset>
            <legend>Account Info</legend>
            
            <form action="processTransaction.jsp" method="post">
                <input type="hidden" name="transactionType" value="<%= transactionType %>">
                <input type="hidden" name="branchCode" value="<%= branchCode %>">
                
                <!-- Is Ho Transaction -->
                <div class="form-group full-width">
                    <label>Is Ho Transaction</label>
                    <div class="radio-group">
                        <label>
                            <input type="radio" name="isHoTransaction" value="yes"> Yes
                        </label>
                        <label>
                            <input type="radio" name="isHoTransaction" value="no" checked> No
                        </label>
                    </div>
                </div>

                <div class="form-row">
                    <!-- Account Type -->
                    <div class="form-group">
                        <label>Account Type</label>
                        <div class="input-with-button">
                            <button type="button">...</button>
                            <input type="text" name="accountType">
                        </div>
                    </div>

                    <!-- Description (Withdrawal only) -->
                    <% if (isWithdrawal) { %>
                    <div class="form-group" style="grid-column: span 3;">
                        <label>Description</label>
                        <input type="text" name="description" value="<%= transDescription != null ? transDescription : "" %>">
                    </div>
                    <% } %>
                </div>

                <div class="form-row">
                    <!-- Account Code -->
                    <div class="form-group">
                        <label>Account Code</label>
                        <div class="input-with-button">
                            <button type="button">...</button>
                            <input type="text" name="accountCode">
                        </div>
                    </div>

                    <!-- Account Name -->
                    <div class="form-group" style="grid-column: span 3;">
                        <label>Account Name</label>
                        <input type="text" name="accountName" readonly>
                    </div>
                </div>

                <!-- GL Account (Deposit only) -->
                <% if (isDeposit) { %>
                <div class="form-row">
                    <div class="form-group">
                        <label>GLAccount Code</label>
                        <input type="text" name="glAccountCode">
                    </div>
                    <div class="form-group" style="grid-column: span 3;">
                        <label>GLAccount Name</label>
                        <input type="text" name="glAccountName">
                    </div>
                </div>
                <% } %>

                <!-- Account Review Date (Withdrawal only) -->
                <% if (isWithdrawal) { %>
                <div class="form-row">
                    <div class="form-group">
                        <label>Account Review Date</label>
                        <input type="text" name="accountReviewDate">
                    </div>
                <% } %>

                    <!-- Last Transaction Date -->
                    <div class="form-group">
                        <label>Last Transaction Date</label>
                        <input type="text" name="lastTransactionDate">
                    </div>

                    <!-- Unclear Balance -->
                    <div class="form-group">
                        <label>Unclear Balance</label>
                        <input type="text" name="unclearBalance">
                    </div>

                <% if (isWithdrawal) { %>
                </div>
                <% } %>

                <div class="form-row">
                    <!-- Ledger Balance -->
                    <div class="form-group">
                        <label>Ledger Balance</label>
                        <input type="text" name="ledgerBalance">
                    </div>

                    <!-- Available Balance -->
                    <div class="form-group">
                        <label>Available Balance</label>
                        <input type="text" name="availableBalance">
                    </div>

                    <!-- New Leadger Bal. -->
                    <div class="form-group">
                        <label>New Leadger Bal.</label>
                        <input type="text" name="newLedgerBalance">
                    </div>
                </div>

                <div class="form-row">
                    <!-- Limit Amount -->
                    <div class="form-group">
                        <label>Limit Amount</label>
                        <input type="text" name="limitAmount" value="0.0">
                    </div>

                    <!-- Drawing Power -->
                    <div class="form-group">
                        <label>Drawing Power</label>
                        <input type="text" name="drawingPower">
                    </div>

                    <% if (isWithdrawal) { %>
                    <!-- Cheque Book Status (Withdrawal only) -->
                    <div class="form-group">
                        <label>Cheque Book Status</label>
                        <input type="text" name="chequeBookStatus">
                    </div>
                    <% } %>

                    <% if (isDeposit) { %>
                    <!-- Account Review Date (Deposit) -->
                    <div class="form-group">
                        <label>Account Review Date</label>
                        <input type="text" name="accountReviewDate">
                    </div>
                </div>

                <div class="form-row">
                    <!-- Last OD Date -->
                    <div class="form-group">
                        <label>Last OD Date</label>
                        <input type="text" name="lastOdDate">
                    </div>

                    <!-- OD Interest -->
                    <div class="form-group">
                        <label>OD Interest</label>
                        <input type="text" name="odInterest" value="0">
                    </div>
                    <% } %>

                    <% if (isWithdrawal) { %>
                    <!-- TOD Applicable Date (Withdrawal only) -->
                    <div class="form-group">
                        <label>TOD Applicable Date</label>
                        <input type="text" name="todApplicableDate">
                    </div>
                    <% } %>
                </div>

                <!-- Check Button -->
                <div class="check-button <%= isWithdrawal ? "center" : "" %>">
                    <button type="button" class="btn">
                        Check <%= isWithdrawal ? "Account" : "" %>
                    </button>
                </div>
        </fieldset>

        <!-- Transaction Details/Info Section -->
        <fieldset>
            <legend>Transaction <%= isDeposit ? "Details" : "Info" %></legend>

            <!-- Original/Responding -->
            <div class="form-group full-width">
                <label>Original/Responding</label>
                <div class="radio-group">
                    <label>
                        <input type="radio" name="originalResponding" value="original" checked> Original
                    </label>
                    <label>
                        <input type="radio" name="originalResponding" value="responding"> Responding
                    </label>
                </div>
            </div>

            <div class="form-row">
                <!-- Outlist Serial -->
                <div class="form-group">
                    <label>Outlist Serial</label>
                    <div class="input-with-button">
                        <button type="button">...</button>
                        <input type="text" name="outlistSerial">
                    </div>
                </div>

                <!-- GL Outlist Description -->
                <div class="form-group">
                    <label>GL Outlist Description</label>
                    <input type="text" name="glOutlistDescription">
                </div>
            </div>

            <div class="form-row">
                <!-- GL OutList Doc. No. -->
                <div class="form-group">
                    <label><%= isDeposit ? "GL OutList Doc. No." : "GL OutList Document Number" %></label>
                    <input type="text" name="glOutlistDocNo">
                </div>

                <% if (isWithdrawal) { %>
                <!-- Withdrawal By (Withdrawal only) -->
                <div class="form-group" style="grid-column: span 2;">
                    <label>Withdrawal By</label>
                    <div class="radio-group">
                        <label>
                            <input type="radio" name="withdrawalBy" value="cash" checked onchange="toggleChequeFields()"> Cash
                        </label>
                        <label>
                            <input type="radio" name="withdrawalBy" value="cheque" onchange="toggleChequeFields()"> Cheque
                        </label>
                    </div>
                </div>
                <% } %>
            </div>

            <div class="form-row">
                <!-- Advice Number -->
                <div class="form-group">
                    <label>Advice Number</label>
                    <div class="input-with-button">
                        <button type="button">...</button>
                        <input type="text" name="adviceNumber">
                    </div>
                </div>

                <!-- Advice Date -->
                <div class="form-group">
                    <label>Advice Date</label>
                    <input type="text" name="adviceDate">
                </div>
            </div>

            <!-- Amount -->
            <div class="form-row">
                <div class="form-group">
                    <label>Amount</label>
                    <input type="text" name="amount">
                </div>
                <div class="form-group" style="grid-column: span 3;">
                    <label>&nbsp;</label>
                    <div class="amount-display"></div>
                </div>
            </div>

            <!-- Particular -->
            <div class="form-group full-width">
                <label>Particular</label>
                <input type="text" name="particular" value="<%= isDeposit ? "By Cash" : "To Self" %>">
            </div>

            <% if (isWithdrawal) { %>
            <!-- Cheque Details (Withdrawal only) -->
            <div id="chequeSection" class="cheque-section" style="display: none;">
                <div class="form-row">
                    <div class="form-group">
                        <label>Cheque Type</label>
                        <div class="input-with-button">
                            <button type="button">...</button>
                            <input type="text" name="chequeType">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Cheque Series</label>
                        <input type="text" name="chequeSeries">
                    </div>
                    <div class="form-group">
                        <label>Cheque Number</label>
                        <input type="text" name="chequeNumber">
                    </div>
                    <div class="form-group">
                        <label>Cheque Date</label>
                        <input type="text" name="chequeDate">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group" style="grid-column: span 2;">
                        <label>G/L Account Code</label>
                        <input type="text" name="glAccountCodeCheque">
                    </div>
                    <div class="form-group" style="grid-column: span 2;">
                        <label>G/L Account Name</label>
                        <input type="text" name="glAccountNameCheque">
                    </div>
                </div>
            </div>

            <!-- Token Number (Withdrawal only) -->
            <div class="form-row">
                <div class="form-group">
                    <label>Token Number</label>
                    <input type="text" name="tokenNumber" value="0">
                </div>
            </div>
            <% } %>

            <% if (isDeposit) { %>
            <!-- Pigmy Collection (Deposit only) -->
            <div class="form-row">
                <div class="form-group">
                    <label>Is Pigmy Collection</label>
                    <div class="radio-group">
                        <label>
                            <input type="radio" name="isPigmyCollection" value="no" checked> No
                        </label>
                        <label>
                            <input type="radio" name="isPigmyCollection" value="yes"> Yes
                        </label>
                    </div>
                </div>
                <div class="form-group">
                    <label>Agent ID</label>
                    <div class="input-with-button">
                        <button type="button">...</button>
                        <input type="text" name="agentId">
                    </div>
                </div>
            </div>
            <% } %>

            <!-- Transaction View Dates -->
            <div class="form-row">
                <div class="form-group">
                    <label>Tran. View From Date</label>
                    <input type="text" name="tranViewFromDate" value="01/12/2059">
                </div>
                <div class="form-group">
                    <label>To Date</label>
                    <input type="text" name="tranViewToDate">
                </div>
            </div>
        </fieldset>

        <!-- Message -->
        <div class="message-box">
            <label>Message:</label>
            <div class="message-content">
                Please logout and login again!
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="action-buttons">
            <button type="button" class="disabled">Validate</button>
            <button type="button" class="disabled">Signature</button>
            <button type="button" class="disabled">Photo</button>
            <button type="button" class="disabled">Details</button>
            <button type="submit" class="disabled">Save</button>
            <button type="button" class="primary">Print Voucher</button>
            <button type="button" class="primary" onclick="window.parent.location.reload();">Cancel</button>
        </div>
            </form>
    </div>
</body>
</html>