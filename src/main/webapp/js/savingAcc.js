//==================== CUSTOMER LOOKUP FUNCTIONS ====================

//Global function to set customer data (will be called from loaded content)
window.setCustomerData = function(customerId, customerName, categoryCode, riskCategory) {
    // Check if this is for nominee lookup
    if (window.currentNomineeInput) {
        window.currentNomineeInput.value = customerId;
        
        // Fetch full customer details from database
        fetchCustomerDetails(customerId, 'nominee', window.currentNomineeBlock);
        
        // Clear the stored references
        window.currentNomineeInput = null;
        window.currentNomineeBlock = null;
        
        closeCustomerLookup();
        showToast('✅ Loading nominee customer data...');
        return;
    }

    // Check if this is for joint holder lookup
    if (window.currentJointInput) {
        window.currentJointInput.value = customerId;
        
        // Fetch full customer details from database
        fetchCustomerDetails(customerId, 'joint', window.currentJointBlock);
        
        // Clear the stored references
        window.currentJointInput = null;
        window.currentJointBlock = null;
        
        closeCustomerLookup();
        showToast('✅ Loading joint holder customer data...');
        return;
    }

    // Otherwise, this is for the main customer ID field
    document.getElementById('customerId').value = customerId;
    document.getElementById('customerName').value = customerName;
    document.getElementById('categoryCode').value = categoryCode || '';
    document.getElementById('riskCategory').value = riskCategory || '';

    closeCustomerLookup();

    if (typeof Toastify !== 'undefined') {
        Toastify({
            text: "✅ Customer data loaded successfully!",
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
                borderLeft: "5px solid #4caf50",
                marginTop: "20px"
            }
        }).showToast();
    }
};

//Fetch customer details from database
function fetchCustomerDetails(customerId, type, block) {
    fetch('getCustomerDetails.jsp?customerId=' + encodeURIComponent(customerId))
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                if (type === 'nominee') {
                    populateNomineeFields(block, data.customer);
                } else if (type === 'joint') {
                    populateJointFields(block, data.customer);
                }
                showToast('✅ Customer data loaded successfully!');
            } else {
                showToast('❌ Error: ' + (data.message || 'Failed to load customer data'));
            }
        })
        .catch(error => {
            console.error('Error fetching customer details:', error);
            showToast('❌ Failed to load customer data');
        });
}

//Populate Nominee fields with customer data
function populateNomineeFields(block, customer) {
    // Salutation Code
    const salutationSelect = block.querySelector('select[name="nomineeSalutation[]"]');
    if (salutationSelect && customer.salutationCode) {
        salutationSelect.value = customer.salutationCode;
    }

    // Nominee Name
    const nameInput = block.querySelector('input[name="nomineeName[]"]');
    if (nameInput && customer.customerName) {
        nameInput.value = customer.customerName;
    }

    // Address 1
    const address1Input = block.querySelector('input[name="nomineeAddress1[]"]');
    if (address1Input && customer.address1) {
        address1Input.value = customer.address1;
    }

    // Address 2
    const address2Input = block.querySelector('input[name="nomineeAddress2[]"]');
    if (address2Input && customer.address2) {
        address2Input.value = customer.address2;
    }

    // Address 3
    const address3Input = block.querySelector('input[name="nomineeAddress3[]"]');
    if (address3Input && customer.address3) {
        address3Input.value = customer.address3;
    }

    // Country
    const countrySelect = block.querySelector('select[name="nomineeCountry[]"]');
    if (countrySelect && customer.country) {
        countrySelect.value = customer.country;
    }

    // State
    const stateSelect = block.querySelector('select[name="nomineeState[]"]');
    if (stateSelect && customer.state) {
        stateSelect.value = customer.state;
    }

    // City
    const citySelect = block.querySelector('select[name="nomineeCity[]"]');
    if (citySelect && customer.city) {
        citySelect.value = customer.city;
    }

    // Zip
    const zipInput = block.querySelector('input[name="nomineeZip[]"]');
    if (zipInput && customer.zip) {
        zipInput.value = customer.zip;
    }
}

//Populate Joint Holder fields with customer data
function populateJointFields(block, customer) {
    // Salutation Code
    const salutationSelect = block.querySelector('select[name="jointSalutation[]"]');
    if (salutationSelect && customer.salutationCode) {
        salutationSelect.value = customer.salutationCode;
    }

    // Joint Holder Name
    const nameInput = block.querySelector('input[name="jointName[]"]');
    if (nameInput && customer.customerName) {
        nameInput.value = customer.customerName;
    }

    // Address 1
    const address1Input = block.querySelector('input[name="jointAddress1[]"]');
    if (address1Input && customer.address1) {
        address1Input.value = customer.address1;
    }

    // Address 2
    const address2Input = block.querySelector('input[name="jointAddress2[]"]');
    if (address2Input && customer.address2) {
        address2Input.value = customer.address2;
    }

    // Address 3
    const address3Input = block.querySelector('input[name="jointAddress3[]"]');
    if (address3Input && customer.address3) {
        address3Input.value = customer.address3;
    }

    // Country
    const countrySelect = block.querySelector('select[name="jointCountry[]"]');
    if (countrySelect && customer.country) {
        countrySelect.value = customer.country;
    }

    // State
    const stateSelect = block.querySelector('select[name="jointState[]"]');
    if (stateSelect && customer.state) {
        stateSelect.value = customer.state;
    }

    // City
    const citySelect = block.querySelector('select[name="jointCity[]"]');
    if (citySelect && customer.city) {
        citySelect.value = customer.city;
    }

    // Zip
    const zipInput = block.querySelector('input[name="jointZip[]"]');
    if (zipInput && customer.zip) {
        zipInput.value = customer.zip;
    }
}

//Customer Lookup Functions
function openCustomerLookup() {
    const modal = document.getElementById('customerLookupModal');
    const content = document.getElementById('customerLookupContent');

    // Show modal immediately
    modal.style.display = 'flex';
    content.innerHTML = '<div style="text-align:center;padding:40px;">Loading customers...</div>';

    // Fetch customer data
    fetch('lookupForCustomerId.jsp')
        .then(response => response.text())
        .then(html => {
            content.innerHTML = html;
            
            // Execute any scripts in the loaded content
            const scripts = content.querySelectorAll('script');
            scripts.forEach(script => {
                const newScript = document.createElement('script');
                newScript.textContent = script.textContent;
                document.body.appendChild(newScript);
                document.body.removeChild(newScript);
            });
        })
        .catch(error => {
            console.error('Error loading customer lookup:', error);
            content.innerHTML = '<div style="text-align:center;padding:40px;color:red;">Failed to load customer list. Please try again.</div>';
        });
}

function closeCustomerLookup() {
    document.getElementById('customerLookupModal').style.display = 'none';
}

//Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('customerLookupModal');
    if (event.target === modal) {
        closeCustomerLookup();
    }
}

//Close modal on Escape key
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeCustomerLookup();
    }
});

//==================== NOMINEE FUNCTIONS ====================

//Toggle Nominee Customer ID visibility
function toggleNomineeCustomerID(radio) {
    const nomineeBlock = radio.closest('.nominee-block');
    const container = nomineeBlock.querySelector('.nomineeCustomerIDContainer');
    const input = nomineeBlock.querySelector('.nomineeCustomerIDInput');

    if (radio.value === 'yes') {
        container.style.display = 'block';
        input.required = true;
    } else {
        container.style.display = 'none';
        input.required = false;
        input.value = ''; // Clear the value when hidden
        
        // Clear all auto-populated fields when switching to "No"
        clearNomineeFields(nomineeBlock);
    }
}

//Clear nominee fields
function clearNomineeFields(block) {
    block.querySelector('select[name="nomineeSalutation[]"]').value = '';
    block.querySelector('input[name="nomineeName[]"]').value = '';
    block.querySelector('input[name="nomineeAddress1[]"]').value = '';
    block.querySelector('input[name="nomineeAddress2[]"]').value = '';
    block.querySelector('input[name="nomineeAddress3[]"]').value = '';
    block.querySelector('select[name="nomineeCountry[]"]').value = '';
    block.querySelector('select[name="nomineeState[]"]').value = '';
    block.querySelector('select[name="nomineeCity[]"]').value = '';
    block.querySelector('input[name="nomineeZip[]"]').value = '0';
}

//Open Nominee Customer Lookup Modal
function openNomineeCustomerLookup(button) {
    const nomineeBlock = button.closest('.nominee-block');
    const input = nomineeBlock.querySelector('.nomineeCustomerIDInput');

    // Store reference to the input field that will receive the customer ID
    window.currentNomineeInput = input;
    window.currentNomineeBlock = nomineeBlock;

    openCustomerLookup();
}

//Add Nominee
function addNominee() {
    let fieldset = document.getElementById("nomineeFieldset");
    let original = fieldset.querySelector(".nominee-block");
    let clone = original.cloneNode(true);

    // Clear all input values
    clone.querySelectorAll("input, select").forEach(el => {
        if (el.type === 'radio') {
            // Reset radio buttons to "No" by default
            if (el.value === 'no') {
                el.checked = true;
            } else {
                el.checked = false;
            }
        } else if (el.tagName === 'SELECT') {
            // Reset select to first option
            el.selectedIndex = 0;
        } else if (el.name === 'nomineeZip[]') {
            el.value = '0';
        } else {
            el.value = "";
        }
    });

    // Hide Customer ID container by default
    const customerIDContainer = clone.querySelector('.nomineeCustomerIDContainer');
    if (customerIDContainer) {
        customerIDContainer.style.display = 'none';
    }

    // Update radio button names to be unique
    const nomineeBlocks = fieldset.querySelectorAll(".nominee-block");
    const newIndex = nomineeBlocks.length + 1;
    const radios = clone.querySelectorAll('.nomineeHasCustomerRadio');
    radios.forEach(radio => {
        radio.name = `nomineeHasCustomerID_${newIndex}`;
    });

    // Set up remove button
    clone.querySelector(".nominee-remove").onclick = function() {
        removeNominee(this);
    };

    fieldset.appendChild(clone);
    updateNomineeSerials();
}

//Remove Nominee
function removeNominee(btn) {
    let blocks = document.querySelectorAll(".nominee-block");

    if (blocks.length <= 1) {
        alert("At least one nominee is required.");
        return;
    }

    btn.parentNode.remove();
    updateNomineeSerials();
}

//Update Nominee Serial Numbers
function updateNomineeSerials() {
    let blocks = document.querySelectorAll(".nominee-block");
    blocks.forEach((block, index) => {
        let serial = block.querySelector(".nominee-serial");
        if (serial) {
            serial.textContent = (index + 1);
        }
    });
}

//==================== JOINT HOLDER FUNCTIONS ====================

//Toggle Joint Holder Customer ID visibility
function toggleJointCustomerID(radio) {
    const jointBlock = radio.closest('.joint-block');
    const container = jointBlock.querySelector('.jointCustomerIDContainer');
    const input = jointBlock.querySelector('.jointCustomerIDInput');

    if (radio.value === 'yes') {
        container.style.display = 'block';
        input.required = true;
    } else {
        container.style.display = 'none';
        input.required = false;
        input.value = ''; // Clear the value when hidden
        
        // Clear all auto-populated fields when switching to "No"
        clearJointFields(jointBlock);
    }
}

//Clear joint holder fields
function clearJointFields(block) {
    block.querySelector('select[name="jointSalutation[]"]').value = '';
    block.querySelector('input[name="jointName[]"]').value = '';
    block.querySelector('input[name="jointAddress1[]"]').value = '';
    block.querySelector('input[name="jointAddress2[]"]').value = '';
    block.querySelector('input[name="jointAddress3[]"]').value = '';
    block.querySelector('select[name="jointCountry[]"]').value = '';
    block.querySelector('select[name="jointState[]"]').value = '';
    block.querySelector('select[name="jointCity[]"]').value = '';
    block.querySelector('input[name="jointZip[]"]').value = '0';
}

//Open Joint Holder Customer Lookup Modal
function openJointCustomerLookup(button) {
    const jointBlock = button.closest('.joint-block');
    const input = jointBlock.querySelector('.jointCustomerIDInput');

    // Store reference to the input field that will receive the customer ID
    window.currentJointInput = input;
    window.currentJointBlock = jointBlock;

    openCustomerLookup();
}

//Add Joint Holder
function addJointHolder() {
    let fieldset = document.getElementById("jointFieldset");
    let original = fieldset.querySelector(".joint-block");
    let clone = original.cloneNode(true);

    // Clear all input values
    clone.querySelectorAll("input, select").forEach(el => {
        if (el.type === 'radio') {
            // Reset radio buttons to "No" by default
            if (el.value === 'no') {
                el.checked = true;
            } else {
                el.checked = false;
            }
        } else if (el.tagName === 'SELECT') {
            // Reset select to first option
            el.selectedIndex = 0;
        } else if (el.name === 'jointZip[]') {
            el.value = '0';
        } else {
            el.value = "";
        }
    });

    // Hide Customer ID container by default
    const customerIDContainer = clone.querySelector('.jointCustomerIDContainer');
    if (customerIDContainer) {
        customerIDContainer.style.display = 'none';
    }

    // Update radio button names to be unique
    const jointBlocks = fieldset.querySelectorAll(".joint-block");
    const newIndex = jointBlocks.length + 1;
    const radios = clone.querySelectorAll('.jointHasCustomerRadio');
    radios.forEach(radio => {
        radio.name = `jointHasCustomerID_${newIndex}`;
    });

    // Set up remove button
    clone.querySelector(".nominee-remove").onclick = function() {
        removeJointHolder(this);
    };

    fieldset.appendChild(clone);
    updateJointSerials();
}

//Remove Joint Holder
function removeJointHolder(btn) {
    let blocks = document.querySelectorAll(".joint-block");

    if (blocks.length <= 1) {
        alert("At least one joint holder is required.");
        return;
    }

    btn.parentNode.remove();
    updateJointSerials();
}

//Update Joint Holder Serial Numbers
function updateJointSerials() {
    let blocks = document.querySelectorAll(".joint-block");
    blocks.forEach((block, index) => {
        let serial = block.querySelector(".joint-serial");
        if (serial) {
            serial.textContent = (index + 1);
        }
    });
}

//==================== UTILITY FUNCTIONS ====================

//Toast helper function
function showToast(message) {
    if (typeof Toastify !== 'undefined') {
        Toastify({
            text: message,
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
                borderLeft: "5px solid #4caf50",
                marginTop: "20px"
            }
        }).showToast();
    }
}