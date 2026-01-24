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
    
    //  Clear loan fields when account code is cleared
    if (currentValue === '' || currentValue.length === 0) {
        const accountCategory = document.getElementById('accountCategory').value;
        if (accountCategory === 'loan' || accountCategory === 'cc') {
            clearLoanFields();
            resetLoanReceivedFields();
        }
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

//Update selectAccountFromSearch to fetch loan data
function selectAccountFromSearch(code, name) {
    document.getElementById('accountCode').value = code;
    document.getElementById('accountName').value = name;
    previousAccountCode = code;
    document.getElementById('searchResults').classList.remove('active');
    
    setTimeout(function() { 
        submitTransactionForm(); 
        
        const transactionType = document.querySelector("input[name='transactionTypeRadio']:checked").value;
        const accountCategory = document.getElementById('accountCategory').value;
        
        // ✅ Populate closing fields if in closing mode
        if (transactionType === 'closing') {
            setTimeout(() => {
                populateClosingFieldsFromIframe();
            }, 1500);
        }
        
        // ✅ Fetch loan data if category is loan
        if (accountCategory === 'loan' || accountCategory === 'cc') {
            setTimeout(() => {
                fetchLoanReceivableData(code);
            }, 1500);
        }
    }, 500);
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
	
	//  Clear loan fields when operation changes
	    const accountCategory = document.getElementById('accountCategory').value;
	    if (accountCategory === 'loan' || accountCategory === 'cc') {
	        clearLoanFields();
	        resetLoanReceivedFields();
	    }

    // Clear transaction data
    creditAccountsData = [];
    refreshCreditAccountsTable();
    updateTotals();
	if (accountCategory === 'loan' || accountCategory === 'cc') {
	    const principalReceived = document.getElementById('principalReceived');
	    if (principalReceived) {
	        principalReceived.value = (parseFloat(this.value) || 0).toFixed(2);
	    }
	    calculateRemaining('principal');
	}


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
	updateParticularField();

}

//========== TOGGLE LOAN FIELDS VISIBILITY ==========
function toggleLoanFields() {
    const accountCategory = document.getElementById('accountCategory').value;
    const loanFieldsSection = document.getElementById('loanFieldsSection');
	const transactionType = document.querySelector("input[name='transactionTypeRadio']:checked").value;
	
	// ✅ ADD THIS CHECK - Don't show loan fields in closing mode
	    if (transactionType === 'closing') {
	        loanFieldsSection.classList.remove('active');
	        clearLoanFields();
	        return;
	    }
		
    if (accountCategory === 'loan' || accountCategory === 'cc') {
        loanFieldsSection.classList.add('active');
        
        // Fetch columns if not already loaded
        if (loanRecoveryColumns.length === 0) {
            fetchLoanRecoveryColumns();
        }
    } else {
        loanFieldsSection.classList.remove('active');
        clearLoanFields();
    }
}

//Calculate remaining amount (Receivable - Received)
function calculateRemaining(fieldName) {
	
	if (fieldName === 'principal') {
	        const r = document.getElementById('principalReceivable');
	        const g = document.getElementById('principalReceived');
	        const m = document.getElementById('principalRemaining');

	        if (!r || !g || !m) return;

	        const receivable = parseFloat(r.value) || 0;
	        const received = parseFloat(g.value) || 0;

	        m.value = (receivable - received).toFixed(2);
	        return;
	    }

    const receivableEl = document.getElementById(fieldName + 'Receivable');
    const receivedEl = document.getElementById(fieldName + 'Received');
    const remainingEl = document.getElementById(fieldName + 'Remaining');
    
    if (!receivableEl || !receivedEl || !remainingEl) return;
    
    const receivable = parseFloat(receivableEl.value.replace(/,/g, '')) || 0;
    const received = parseFloat(receivedEl.value.replace(/,/g, '')) || 0;
    const remaining = receivable - received;
    
    remainingEl.value = remaining.toFixed(2);
    
    // Color coding for remaining amount
    if (remaining < 0) {
        remainingEl.style.color = 'red';
        remainingEl.style.fontWeight = 'bold';
    } else if (remaining === 0) {
        remainingEl.style.color = 'green';
        remainingEl.style.fontWeight = 'bold';
    } else {
        remainingEl.style.color = '#666';
        remainingEl.style.fontWeight = 'normal';
    }
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
	
	// Fetch loan recovery columns from database
    fetchLoanRecoveryColumns();
	
	// Fetch closing sequence columns from database
	    fetchClosingSequenceColumns();
		
    // Initialize transaction table
    refreshCreditAccountsTable();
    
    // Transaction type change handler - NEW
    const transactionTypeRadios = document.querySelectorAll("input[name='transactionTypeRadio']");
    transactionTypeRadios.forEach(function(radio) {
        radio.addEventListener('change', function() {
            handleTransactionTypeChange();
        });
    });
    
    // Initial call to set proper visibility
    handleTransactionTypeChange();
    
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
			updateParticularField();
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
	        
	        // ✅ Clear loan fields when switching away from loan/cc
	        const oldCategory = currentCategory;
	        if (oldCategory === 'loan' || oldCategory === 'cc') {
	            clearLoanFields();
	            resetLoanReceivedFields();
	        }
	        
	        // Toggle loan fields visibility
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
    
    // Initial calls to set visibility
    updateLabelsBasedOnOperation();
    toggleLoanFields();
    toggleTransferFields();
	updateParticularField(); 
});
// ================= FINAL & ONLY TRANSACTION AMOUNT HANDLER =================
const transactionAmountInput = document.getElementById('transactionamount');
if (transactionAmountInput) {
    transactionAmountInput.removeAttribute('oninput');

    transactionAmountInput.addEventListener('input', function () {
        const accountCategory = document.getElementById('accountCategory').value;
        const txnAmount = parseFloat(this.value) || 0;

        // ✅ LOAN / CC PRINCIPAL HANDLING (LAST)
        if (accountCategory === 'loan' || accountCategory === 'cc') {
            resetLoanReceivedFields();

            const principalReceived = document.getElementById('principalReceived');
            if (principalReceived) {
                principalReceived.value = txnAmount.toFixed(2);
            }

            calculateRemaining('principal');
        }

        // ✅ EXISTING FLOW
        calculateNewBalanceInIframe();
        updateTotals();
    });
}


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
    
    setTimeout(function() { 
        submitTransactionForm(); 
        
        const transactionType = document.querySelector("input[name='transactionTypeRadio']:checked").value;
        const accountCategory = document.getElementById('accountCategory').value;
        
        // ✅ Populate closing fields if in closing mode
        if (transactionType === 'closing') {
            setTimeout(() => {
                populateClosingFieldsFromIframe();
            }, 1500);
        }
        
        // ✅ Fetch loan data if category is loan
        if (accountCategory === 'loan' || accountCategory === 'cc') {
            setTimeout(() => {
                fetchLoanReceivableData(code);
            }, 1500);
        }
    }, 500);
}

//Update the submitTransactionForm function
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
        
        // ✅ ADD THIS: Fetch loan receivable data if it's a loan account
        if (accountCategory === 'loan' && accountCode) {
            setTimeout(() => {
                fetchLoanReceivableData(accountCode);
            }, 1000); // Wait for iframe to load
        }
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
    const accountCategory = document.getElementById('accountCategory').value;
    
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
                // For loan accounts with deposit/credit, use sequential deduction
                const opType = document.getElementById('opType') ? document.getElementById('opType').value : '';
                const shouldUseSequential = (accountCategory === 'loan' || accountCategory === 'cc') && 
                                           ((operationType === 'deposit') || 
                                            (operationType === 'transfer' && opType === 'Credit'));
                
                if (shouldUseSequential) {
                    // Call sequential deduction function
                    calculateSequentialLoanDeduction();
                    return; // Let sequential function handle everything
                }
                
                // Normal calculation for non-loan or withdrawal
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
    // Find the account being removed
    const removedAccount = creditAccountsData.find(acc => acc.id === accountId);
    
    // Remove from array
    creditAccountsData = creditAccountsData.filter(acc => acc.id !== accountId);
    refreshCreditAccountsTable();
    updateTotals();
    
    // ✅ Only clear iframe if the removed account is in the current iframe URL
    if (removedAccount) {
        const iframe = document.getElementById('resultFrame');
        const iframeSrc = iframe.src || '';
        
        // Check if the removed account code is in the iframe URL
        if (iframeSrc.includes(encodeURIComponent(removedAccount.code))) {
            clearIframe();
        }
    }
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
    const talliedMessage = document.getElementById('talliedMessage');
    if (totalDebit === totalCredit && totalDebit > 0) {
        document.getElementById('totalDebit').style.borderColor = 'green';
        document.getElementById('totalCredit').style.borderColor = 'green';
        
        // Show "Transaction tallied" message
        if (talliedMessage) {
            talliedMessage.style.display = 'block';
        }
    } else {
        document.getElementById('totalDebit').style.borderColor = '#C8B7F6';
        document.getElementById('totalCredit').style.borderColor = '#C8B7F6';
        
        // Hide message
        if (talliedMessage) {
            talliedMessage.style.display = 'none';
        }
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
	
	// ========== DYNAMIC LOAN FIELDS ==========
	let loanRecoveryColumns = [];
	let closingSequenceColumns = [];

	// Fetch loan recovery columns from database
	function fetchLoanRecoveryColumns() {
	    fetch('GetLoanRecoveryColumns.jsp')
	        .then(response => response.json())
	        .then(data => {
	            if (data.success && data.columns && data.columns.length > 0) {
	                loanRecoveryColumns = data.columns;
	                buildLoanFieldsTable();
	            } else {
	                showToast('Failed to load loan recovery columns', 'error');
	                console.error('Error:', data.error || 'No columns found');
	            }
	        })
	        .catch(error => {
	            console.error('Error fetching loan recovery columns:', error);
	            showToast('Failed to load loan recovery columns', 'error');
	        });
	}

	// Build the dynamic loan fields table
function buildLoanFieldsTable() {
    const loader = document.getElementById('loanFieldsLoader');
    const tableContainer = document.getElementById('loanFieldsTableContainer');
    const headerRow = document.getElementById('loanTableHeader');
    const tableBody = document.getElementById('loanTableBody');
    
    if (!loanRecoveryColumns || loanRecoveryColumns.length === 0) {
        loader.innerHTML = '<p style="color: #f44336;">No loan recovery columns configured</p>';
        return;
    }
    
    // Hide loader and show table
    loader.style.display = 'none';
    tableContainer.style.display = 'block';
    
    // Build table headers
    let headerHTML = '<tr><th>Type</th>';
    loanRecoveryColumns.forEach(col => {
        // Safety check for undefined/null values
        if (!col || !col.description) {
            console.warn('Skipping invalid column:', col);
            return;
        }
        
        // Truncate long descriptions for display
        const displayName = col.description.length > 10 
            ? col.description.substring(0, 20) 
            : col.description;
        headerHTML += '<th title="' + escapeHtml(col.description) + '">' + escapeHtml(displayName) + '</th>';
    });
	headerHTML += '<th>Principal</th>';
    headerHTML += '</tr>';
    headerRow.innerHTML = headerHTML;
    
	/* ================= ROWS ================= */
	let receivableRow = '<tr class="receivable-row"><td>Receivable</td>';
	let receivedRow   = '<tr class="received-row"><td>Received</td>';
	let remainingRow  = '<tr class="remaining-row"><td>Remaining</td>';
    
    loanRecoveryColumns.forEach(col => {
        // Safety check for undefined/null values
        if (!col || !col.columnName) {
            console.warn('Skipping invalid column:', col);
            return;
        }
        
        const fieldName = col.columnName.toLowerCase().trim();
		if (fieldName === 'principal') return;
        // Skip if fieldName is empty
        if (!fieldName) {
            console.warn('Empty fieldName for column:', col);
            return;
        }
        
        // Receivable row (readonly)
        receivableRow += '<td><input type="text" name="' + fieldName + 'Receivable" ' +
                        'id="' + fieldName + 'Receivable" placeholder="0.00" readonly></td>';
        
        // Received row (editable with oninput)
        receivedRow += '<td><input type="text" name="' + fieldName + 'Received" ' +
                      'id="' + fieldName + 'Received" placeholder="0.00" ' +
                      'oninput="calculateRemaining(\'' + fieldName + '\')"></td>';
        
        // Remaining row (readonly)
        remainingRow += '<td><input type="text" id="' + fieldName + 'Remaining" ' +
                       'placeholder="0.00" readonly></td>';
    });
    
	receivableRow += '<td><input type="text" id="principalReceivable" placeholder="0.00" readonly></td>';
	    receivedRow   += '<td><input type="text" id="principalReceived" placeholder="0.00"></td>';
	    remainingRow  += '<td><input type="text" id="principalRemaining"  placeholder="0.00" readonly></td>';
		
    receivableRow += '</tr>';
    receivedRow += '</tr>';
    remainingRow += '</tr>';
    
    tableBody.innerHTML = receivableRow + receivedRow + remainingRow;
}
function buildClosingFieldsTable() {
    const loader = document.getElementById('closingFieldsLoader');
    const tableContainer = document.getElementById('closingFieldsTableContainer');
    const headerRow = document.getElementById('closingTableHeader');
    const tableBody = document.getElementById('closingTableBody');
    
    if (!closingSequenceColumns || closingSequenceColumns.length === 0) {
        loader.innerHTML = '<p style="color: #f44336;">No closing sequence columns configured</p>';
        return;
    }
    
    // Hide loader and show table
    loader.style.display = 'none';
    tableContainer.style.display = 'block';
    
    // Build table headers
    let headerHTML = '<tr><th>Type</th>';
    closingSequenceColumns.forEach(col => {
        if (!col || !col.description) {
            console.warn('Skipping invalid column:', col);
            return;
        }
        
        const displayName = col.description.length > 10 
            ? col.description.substring(0, 20) 
            : col.description;
        headerHTML += '<th title="' + escapeHtml(col.description) + '">' + escapeHtml(displayName) + '</th>';
    });
    headerHTML += '</tr>';
    headerRow.innerHTML = headerHTML;
    
    // Build table rows (Receivable, Received, Remaining)
    let receivableRow = '<tr class="receivable-row"><td>Receivable</td>';
    let receivedRow   = '<tr class="received-row"><td>Received</td>';
    let remainingRow  = '<tr class="remaining-row"><td>Remaining</td>';
    
    closingSequenceColumns.forEach(col => {
        if (!col || !col.columnName) {
            console.warn('Skipping invalid column:', col);
            return;
        }
        
        const fieldName = col.columnName.toLowerCase().trim();
        
        if (!fieldName) {
            console.warn('Empty fieldName for column:', col);
            return;
        }
        
        // Receivable row (readonly)
        receivableRow += '<td><input type="text" name="' + fieldName + 'Receivable" ' +
                        'id="closing_' + fieldName + 'Receivable" placeholder="0.00" readonly></td>';
        
        // Received row (editable)
        receivedRow += '<td><input type="text" name="' + fieldName + 'Received" ' +
                      'id="closing_' + fieldName + 'Received" placeholder="0.00" ' +
                      'oninput="calculateClosingRemaining(\'' + fieldName + '\')"></td>';
        
        // Remaining row (readonly)
        remainingRow += '<td><input type="text" id="closing_' + fieldName + 'Remaining" ' +
                       'placeholder="0.00" readonly></td>';
    });
    
    receivableRow += '</tr>';
    receivedRow += '</tr>';
    remainingRow += '</tr>';
    
    tableBody.innerHTML = receivableRow + receivedRow + remainingRow;
}

// Helper function to escape HTML (add this if not already present)
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

//Add this function after the buildLoanFieldsTable() function

function fetchLoanReceivableData(accountCode) {
    if (!accountCode || accountCode.trim() === '') {
        return;
    }
    
    fetch('GetLoanReceivableData.jsp?accountCode=' + encodeURIComponent(accountCode))
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                showToast('Error loading loan data: ' + data.error, 'error');
                console.error('Error:', data.error);
                return;
            }
            
            if (data.success && data.receivableData) {
                populateLoanReceivableFields(data.receivableData);
            }
        })
        .catch(error => {
            console.error('Error fetching loan receivable data:', error);
            showToast('Failed to fetch loan receivable data', 'error');
        });
}

function fetchClosingSequenceColumns() {
    fetch('GetClosingSequenceColumns.jsp')
        .then(response => response.json())
        .then(data => {
            if (data.success && data.columns && data.columns.length > 0) {
                closingSequenceColumns = data.columns;
                buildClosingFieldsTable();
            } else {
                showToast('Failed to load closing sequence columns', 'error');
                console.error('Error:', data.error || 'No columns found');
            }
        })
        .catch(error => {
            console.error('Error fetching closing sequence columns:', error);
            showToast('Failed to load closing sequence columns', 'error');
        });
}

function populateLoanReceivableFields(receivableData) {
    let totalReceivable = 0;

    for (const fieldName in receivableData) {
        if (fieldName === 'principal') continue;

        const receivableField = document.getElementById(fieldName + 'Receivable');
        const value = parseFloat(receivableData[fieldName]) || 0;

        if (receivableField) {
            receivableField.value = value.toFixed(2);
            totalReceivable += value;
        }

        calculateRemaining(fieldName);
    }

    // ✅ SET PRINCIPAL RECEIVABLE
    const principalReceivable = document.getElementById('principalReceivable');
    if (principalReceivable) {
        principalReceivable.value = totalReceivable.toFixed(2);
    }

    calculateRemaining('principal');
}


//Updated clearLoanFields to work with dynamic fields
function clearLoanFields() {
    if (!loanRecoveryColumns || loanRecoveryColumns.length === 0) {
        return;
    }
    
    loanRecoveryColumns.forEach(col => {
        // Safety check
        if (!col || !col.columnName) {
            return;
        }
        
        const fieldName = col.columnName.toLowerCase().trim();
        
        // Skip if fieldName is empty
        if (!fieldName) {
            return;
        }
        
        ['Receivable', 'Received', 'Remaining'].forEach(suffix => {
            const el = document.getElementById(fieldName + suffix);
            if (el) {
                el.value = '';
                el.style.color = '';
                el.style.fontWeight = '';
            }
        });
    });
}


// Add this new function to handle sequential loan deduction
function calculateSequentialLoanDeduction() {
    const transactionAmountInput = document.getElementById('transactionamount');
    const transactionAmount = parseFloat(transactionAmountInput.value) || 0;
    const operationType = document.querySelector("input[name='operationType']:checked").value;
    const accountCategory = document.getElementById('accountCategory').value;
    
    // Only proceed if it's a deposit or (transfer with credit OP Type)
    const opType = document.getElementById('opType') ? document.getElementById('opType').value : '';
    const shouldProcess = (operationType === 'deposit') || 
                         (operationType === 'transfer' && opType === 'Credit');
    
    if (!shouldProcess || (accountCategory !== 'loan' && accountCategory !== 'cc')) {
        return;
    }
    
    // ✅ ALWAYS CLEAR ALL RECEIVED FIELDS FIRST (even if amount is 0)
    if (loanRecoveryColumns && loanRecoveryColumns.length > 0) {
        loanRecoveryColumns.forEach(col => {
            if (!col || !col.columnName) return;
            const fieldName = col.columnName.toLowerCase().trim();
            if (!fieldName) return;
            
            const receivedEl = document.getElementById(fieldName + 'Received');
            if (receivedEl) {
                receivedEl.value = '';
                receivedEl.style.backgroundColor = '';
                receivedEl.style.fontWeight = '';
            }
            
            // ✅ Also recalculate remaining to show full receivable
            calculateRemaining(fieldName);
        });
    }
    
    // ✅ If transaction amount is 0 or empty, stop here (don't recalculate)
    if (transactionAmount <= 0) {
        return;
    }
    
    let remainingAmount = transactionAmount;
    
    // Process each loan column sequentially
    if (loanRecoveryColumns && loanRecoveryColumns.length > 0) {
        for (let i = 0; i < loanRecoveryColumns.length; i++) {
            const col = loanRecoveryColumns[i];
            if (!col || !col.columnName) continue;
            
            const fieldName = col.columnName.toLowerCase().trim();
            if (!fieldName) continue;
            
            const receivableEl = document.getElementById(fieldName + 'Receivable');
            const receivedEl = document.getElementById(fieldName + 'Received');
            const remainingEl = document.getElementById(fieldName + 'Remaining');
            
            if (!receivableEl || !receivedEl || !remainingEl) continue;
            
            // Get receivable and current received values
            const receivable = parseFloat(receivableEl.value.replace(/,/g, '')) || 0;
            const currentReceived = parseFloat(receivedEl.value.replace(/,/g, '')) || 0;
            const outstanding = receivable - currentReceived;
            
            if (outstanding > 0 && remainingAmount > 0) {
                // Calculate how much to deduct from this field
                const deductionAmount = Math.min(outstanding, remainingAmount);
                const newReceived = currentReceived + deductionAmount;
                
                // Update the received field
                receivedEl.value = newReceived.toFixed(2);
                
                // Recalculate remaining
                calculateRemaining(fieldName);
                
                // Reduce remaining amount
                remainingAmount -= deductionAmount;
                
                // Highlight the updated field
                receivedEl.style.backgroundColor = '#e6f7ff';
                receivedEl.style.fontWeight = 'bold';
                
                setTimeout(() => {
                    receivedEl.style.backgroundColor = '';
                }, 2000);
            }
            
            // If no remaining amount, stop processing
            if (remainingAmount <= 0) {
                break;
            }
        }
    }
    
	let lastToastMessage = '';
	let lastToastTime = 0;
	// If there's still remaining amount, deduct from ledger balance
	    if (remainingAmount > 0) {
	        const iframe = document.getElementById('resultFrame');
	        
	        try {
	            const iframeWindow = iframe.contentWindow;
	            const iframeDoc = iframeWindow.document;
	            
	            const ledgerBalanceField = iframeDoc.getElementById('ledgerBalance');
	            const newLedgerBalanceField = iframeDoc.getElementById('newLedgerBalance');
	            
	            if (ledgerBalanceField && newLedgerBalanceField) {
	                const ledgerBalance = parseFloat(ledgerBalanceField.value) || 0;
	                const newLedgerBalance = ledgerBalance + remainingAmount;
	                
	                newLedgerBalanceField.value = newLedgerBalance.toFixed(2);
	                
	                // Highlight ledger balance update
	                newLedgerBalanceField.style.backgroundColor = '#e6f7ff';
	                newLedgerBalanceField.style.fontWeight = 'bold';
	                
	                setTimeout(() => {
	                    newLedgerBalanceField.style.backgroundColor = '';
	                }, 2000);
	                
	                // ✅ PREVENT DUPLICATE TOASTS
	                const message = '₹' + remainingAmount.toFixed(2) + ' applied to Ledger Balance after loan recovery deductions';
	                const now = Date.now();
	                
	                // Only show toast if message is different or enough time has passed (500ms)
	                if (lastToastMessage !== message || (now - lastToastTime) > 500) {
	                    showToast(message, 'info');
	                    lastToastMessage = message;
	                    lastToastTime = now;
	                }
	                
	                remainingAmount = 0;
	            }
	        } catch (e) {
	            console.error('Error updating ledger balance:', e);
	        }
	    }
    // If there's STILL remaining amount (shouldn't happen normally), alert user
    if (remainingAmount > 0) {
        showToast('WARNING: ₹' + remainingAmount.toFixed(2) + ' remaining after all deductions!', 'warning');
    }
}

// Add reset function to clear loan received fields when needed
function resetLoanReceivedFields() {
    if (!loanRecoveryColumns || loanRecoveryColumns.length === 0) return;
    
    loanRecoveryColumns.forEach(col => {
        if (!col || !col.columnName) return;
        
        const fieldName = col.columnName.toLowerCase().trim();
        if (!fieldName) return;
        
        const receivedEl = document.getElementById(fieldName + 'Received');
        if (receivedEl) {
            receivedEl.value = '';
            receivedEl.style.backgroundColor = '';
            receivedEl.style.fontWeight = '';
        }
        
        calculateRemaining(fieldName);
    });
}

// Call this when transaction amount is cleared or changed significantly
function handleTransactionAmountChange() {
    const transactionAmount = parseFloat(document.getElementById('transactionamount').value) || 0;
    
    if (transactionAmount === 0) {
        // Reset all loan received fields if amount is cleared
        resetLoanReceivedFields();
    }
    
    calculateNewBalanceInIframe();
    updateTotals();
}

// Handle transaction amount changes (only on blur/enter)
function handleTransactionAmountFinalized() {
    calculateNewBalanceInIframe();
    updateTotals();
}

 function updateParticularField() {
    const operationType = document.querySelector("input[name='operationType']:checked").value;
    const particularField = document.getElementById('particular');
    
    if (!particularField) return;
    
    // Only auto-fill if the field is empty
    if (particularField.value.trim() !== '') return;
    
    if (operationType === 'deposit') {
        particularField.value = 'By Cash';
    } else if (operationType === 'withdrawal') {
        particularField.value = 'To Cash';
    } else if (operationType === 'transfer') {
        const opType = document.getElementById('opType').value;
        if (opType === 'Debit') {
            particularField.value = 'To Transfer';
        } else	if (opType === 'Credit') {
			 particularField.value = 'By Transfer';
		}
    }
}

// ========== HANDLE TRANSACTION TYPE CHANGE (REGULAR/CLOSING) ==========
function handleTransactionTypeChange() {
    const transactionType = document.querySelector("input[name='transactionTypeRadio']:checked").value;
    
    // Get elements to hide/show
    const operationTypeSection = document.querySelector('.radio-group-inline:has(input[name="operationType"])');
    const transferFieldsSection = document.getElementById('transferFieldsSection');
    const loanFieldsSection = document.getElementById('loanFieldsSection');
    const creditAccountsContainer = document.getElementById('creditAccountsContainer');
    const addButtonParent = document.querySelector('.add-btn') ? document.querySelector('.add-btn').parentElement : null;
    const transactionAmountDiv = document.querySelector('#transactionamount') ? document.querySelector('#transactionamount').closest('div') : null;
    
    if (transactionType === 'closing') {
        // ========== CLOSING MODE ==========
        
        // Hide elements for closing transaction
        //if (operationTypeSection) operationTypeSection.style.display = 'none';
        if (transferFieldsSection) transferFieldsSection.classList.remove('active');
        if (loanFieldsSection) loanFieldsSection.classList.remove('active');
        if (creditAccountsContainer) creditAccountsContainer.style.display = 'none';
        if (addButtonParent) addButtonParent.style.display = 'none';
		// Show closing fields section
		    const closingFieldsSection = document.getElementById('closingFieldsSection');
		    if (closingFieldsSection) {
		        closingFieldsSection.classList.add('active');
		        
		        // Fetch columns if not already loaded
		        if (closingSequenceColumns.length === 0) {
		            fetchClosingSequenceColumns();
		        }
		    }
        
        // Clear iframe
        clearIframe();
        
        // Clear inputs
        document.getElementById('accountCode').value = '';
        document.getElementById('accountName').value = '';
        if (document.getElementById('transactionamount')) {
            document.getElementById('transactionamount').value = '';
        }
        document.getElementById('particular').value = '';
        previousAccountCode = '';
        
        // Clear transaction data
        creditAccountsData = [];
        refreshCreditAccountsTable();
        
        // Clear loan fields if they were active
        clearLoanFields();
        resetLoanReceivedFields();
        
        // Clear closing fields
        clearClosingFields();
        
    } else {
        // ========== REGULAR MODE ==========
        
        // Show operation type section
        if (operationTypeSection) operationTypeSection.style.display = 'flex';
        
        // Show add button and transaction amount
        if (addButtonParent) addButtonParent.style.display = 'flex';
        if (transactionAmountDiv) transactionAmountDiv.style.display = 'block';
        
        // Show credit accounts container
        if (creditAccountsContainer) creditAccountsContainer.style.display = 'block';
        
		const closingFieldsSection = document.getElementById('closingFieldsSection');
		   if (closingFieldsSection) closingFieldsSection.classList.remove('active');
        
        // Clear inputs when switching back to regular
        document.getElementById('accountCode').value = '';
        document.getElementById('accountName').value = '';
        if (document.getElementById('transactionamount')) {
            document.getElementById('transactionamount').value = '';
        }
        document.getElementById('particular').value = '';
        previousAccountCode = '';
        
        // Clear iframe
        clearIframe();
        
        // Clear transaction data
        creditAccountsData = [];
        refreshCreditAccountsTable();
        updateTotals();
        
        // Clear loan fields
        clearLoanFields();
        resetLoanReceivedFields();
        
        // ✅ IMPORTANT: Re-evaluate visibility based on current selections
        const currentOperationType = document.querySelector("input[name='operationType']:checked").value;
        const accountCategory = document.getElementById('accountCategory').value;
        
        // Show/hide transfer fields based on operation type
        if (currentOperationType === 'transfer') {
            if (transferFieldsSection) transferFieldsSection.classList.add('active');
        } else {
            if (transferFieldsSection) transferFieldsSection.classList.remove('active');
        }
        
        // Show/hide loan fields based on account category
        if (accountCategory === 'loan' || accountCategory === 'cc') {
            if (loanFieldsSection) loanFieldsSection.classList.add('active');
        } else {
            if (loanFieldsSection) loanFieldsSection.classList.remove('active');
        }
        
        // Update labels and other UI elements
        updateLabelsBasedOnOperation();
        updateParticularField();
    }
}



// Clear closing fields
function clearClosingFields() {
    const closingFields = [
        'closingLedgerBalance',
        'closingAvailableBalance',
        'closingTransactionAmount',
        'closingInterest',
        'closingBalance',
        'againstEffectInt',
        'todInterest',
        'serviceCharges',
        'otherCharges',
        'serviceTax'
    ];
    
    closingFields.forEach(fieldId => {
        const field = document.getElementById(fieldId);
        if (field) {
            field.value = '';
        }
    });
}

// Populate closing fields from iframe
function populateClosingFieldsFromIframe() {
    const accountCode = document.getElementById('accountCode').value;
    
    if (!accountCode) {
        showToast('Please select an account first', 'error');
        return;
    }
    
    const iframe = document.getElementById('resultFrame');
    
    try {
        const iframeWindow = iframe.contentWindow;
        const iframeDoc = iframeWindow.document;
        
        const ledgerBalanceField = iframeDoc.getElementById('ledgerBalance');
        const availableBalanceField = iframeDoc.getElementById('availableBalance');
        
        if (ledgerBalanceField && availableBalanceField) {
            const ledgerBalance = ledgerBalanceField.value || '0.00';
            const availableBalance = availableBalanceField.value || '0.00';
            
            document.getElementById('closingLedgerBalance').value = ledgerBalance;
            document.getElementById('closingAvailableBalance').value = availableBalance;
            
            
            showToast('Account details loaded successfully', 'success');
        } else {
            showToast('Could not fetch account details from iframe', 'error');
        }
    } catch (e) {
        console.error('Error reading iframe:', e);
        showToast('Error reading account details. Please wait for the page to load completely.', 'error');
    }
}