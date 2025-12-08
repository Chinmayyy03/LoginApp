//==================== AREA LOOKUP ====================

function openAreaLookup() {
    let url = "lookupForLoan.jsp?type=area";

    fetch(url)
        .then(response => response.text())
        .then(html => {
            document.getElementById("areaLookupContent").innerHTML = html;
            document.getElementById("areaLookupModal").style.display = "flex";
            
            const scripts = document.getElementById("areaLookupContent").querySelectorAll('script');
            scripts.forEach(script => {
                const newScript = document.createElement('script');
                newScript.textContent = script.textContent;
                document.body.appendChild(newScript);
            });
        })
        .catch(error => {
            showToast('❌ Failed to load area lookup data. Please try again.');
            console.error('Lookup error:', error);
        });
}

function closeAreaLookup() {
    document.getElementById("areaLookupModal").style.display = "none";
}

window.setAreaData = function(code, name) {
    document.getElementById("areaCode").value = code;
    document.getElementById("areaName").value = name;
    
    // Clear sub area when area changes
    document.getElementById("subAreaCode").value = '';
    document.getElementById("subAreaName").value = '';
    
    closeAreaLookup();
    showToast('✅ Area selected successfully!');
};

//==================== SUB AREA LOOKUP ====================

function openSubAreaLookup() {
    const areaCode = document.getElementById("areaCode").value;
    
    if (!areaCode) {
        showToast('⚠️ Please select Area first!');
        return;
    }
    
    let url = "lookupForLoan.jsp?type=subArea&areaCode=" + encodeURIComponent(areaCode);

    fetch(url)
        .then(response => response.text())
        .then(html => {
            document.getElementById("subAreaLookupContent").innerHTML = html;
            document.getElementById("subAreaLookupModal").style.display = "flex";
            
            const scripts = document.getElementById("subAreaLookupContent").querySelectorAll('script');
            scripts.forEach(script => {
                const newScript = document.createElement('script');
                newScript.textContent = script.textContent;
                document.body.appendChild(newScript);
            });
        })
        .catch(error => {
            showToast('❌ Failed to load sub area lookup data. Please try again.');
            console.error('Lookup error:', error);
        });
}

function closeSubAreaLookup() {
    document.getElementById("subAreaLookupModal").style.display = "none";
}

window.setSubAreaData = function(code, name) {
    document.getElementById("subAreaCode").value = code;
    document.getElementById("subAreaName").value = name;
    
    closeSubAreaLookup();
    showToast('✅ Sub Area selected successfully!');
};

// ==================== LOAN FIELD AUTO-FILL FUNCTIONALITY ====================

/**
 * Get today's date in YYYY-MM-DD format
 * @returns {string} Today's date formatted for HTML date input
 */
function getTodayDate() {
    const today = new Date();
    const yyyy = today.getFullYear();
    const mm = String(today.getMonth() + 1).padStart(2, '0');
    const dd = String(today.getDate()).padStart(2, '0');
    return `${yyyy}-${mm}-${dd}`;
}

/**
 * Handle limit amount changes and update related fields
 * When user enters limit amount:
 * - Sets sanction amount (readonly) to same value
 * - Sets drawing power (editable) to same value
 */
function handleLimitAmountChange() {
    const limitAmount = document.getElementById('limitAmount');
    const sanctionAmount = document.getElementById('sanctionAmount');
    const drawingPower = document.getElementById('drawingPower');
    
    if (limitAmount && sanctionAmount && drawingPower) {
        limitAmount.addEventListener('input', function() {
            const value = this.value || '0';
            // Set sanction amount (readonly)
            sanctionAmount.value = value;
            // Set drawing power (editable)
            drawingPower.value = value;
        });
    }
}

/**
 * Initialize loan fields on page load
 * - Sets submission date to today
 * - Sets registration date to today
 * - Makes sanction amount readonly with gray background
 * - Sets up limit amount change handler
 */
function initializeLoanFields() {
    // Set today's date for submission and registration dates
    const submissionDate = document.getElementById('submissionDate');
    const registrationDate = document.getElementById('registrationDate');
    
    const today = getTodayDate();
    
    if (submissionDate) {
        submissionDate.value = today;
    }
    
    if (registrationDate) {
        registrationDate.value = today;
    }
    
    // Make sanction amount readonly with visual indication
    const sanctionAmount = document.getElementById('sanctionAmount');
    if (sanctionAmount) {
        sanctionAmount.readOnly = true;
        sanctionAmount.style.backgroundColor = '#f0f0f0';
        sanctionAmount.style.cursor = 'not-allowed';
    }
    
    // Set up limit amount change handler
    handleLimitAmountChange();
}

// Auto-initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
    initializeLoanFields();
});

// ==================== END LOAN FIELD AUTO-FILL FUNCTIONALITY ====================