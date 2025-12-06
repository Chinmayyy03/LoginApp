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

//Close modal when clicking outside
window.onclick = function(event) {
    const customerModal = document.getElementById('customerLookupModal');
    const installmentModal = document.getElementById('installmentLookupModal');
    const socialSectorModal = document.getElementById('socialSectorLookupModal');
    const socialSubSectorModal = document.getElementById('socialSubSectorLookupModal');
    const areaModal = document.getElementById('areaLookupModal');
    const subAreaModal = document.getElementById('subAreaLookupModal');
    
    if (event.target === customerModal) closeCustomerLookup();
    if (event.target === installmentModal) closeInstallmentLookup();
    if (event.target === socialSectorModal) closeSocialSectorLookup();
    if (event.target === socialSubSectorModal) closeSocialSubSectorLookup();
    if (event.target === areaModal) closeAreaLookup();
    if (event.target === subAreaModal) closeSubAreaLookup();
}

//Close modal on Escape key
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeCustomerLookup();
        closeInstallmentLookup();
        closeSocialSectorLookup();
        closeSocialSubSectorLookup();
        closeAreaLookup();
        closeSubAreaLookup();
    }
});