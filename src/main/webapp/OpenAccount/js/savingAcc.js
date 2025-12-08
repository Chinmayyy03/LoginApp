//==================== CUSTOMER LOOKUP FUNCTIONS ====================

//Global function to set customer data (will be called from loaded content)
window.setCustomerData = function(customerId, customerName, categoryCode, riskCategory) {
    // Check if this is for nominee lookup
    if (window.currentNomineeInput) {
        window.currentNomineeInput.value = customerId;
        fetchCustomerDetails(customerId, 'nominee', window.currentNomineeBlock);
        window.currentNomineeInput = null;
        window.currentNomineeBlock = null;
        closeCustomerLookup();
        showToast('Loading nominee customer data...');
        return;
    }

    // Check if this is for joint holder lookup
    if (window.currentJointInput) {
        window.currentJointInput.value = customerId;
        fetchCustomerDetails(customerId, 'joint', window.currentJointBlock);
        window.currentJointInput = null;
        window.currentJointBlock = null;
        closeCustomerLookup();
        showToast('Loading joint holder customer data...');
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
    console.log('🔍 Fetching customer details for:', customerId, 'Type:', type);
    
    fetch('getCustomerDetails.jsp?customerId=' + encodeURIComponent(customerId))
        .then(response => response.json())
        .then(data => {
            console.log('📦 Received data:', data);
            
            if (data.success) {
                if (type === 'nominee') {
                    populateNomineeFields(block, data.customer);
                } else if (type === 'joint') {
                    populateJointFields(block, data.customer);
                }
                showToast('✅ Customer data loaded successfully!');
            } else {
                showToast('❌ Error: ' + (data.message || 'Failed to load customer data'), 'error');
            }
        })
        .catch(error => {
            console.error('❌ Error fetching customer details:', error);
            showToast('Failed to load customer data', 'error');
        });
}

// Helper function to set select value with multiple matching strategies
function setSelectValue(selectElement, value, fieldName) {
    if (!selectElement) {
        console.warn('⚠️ Select element not found for:', fieldName);
        return false;
    }
    
    if (!value || value.trim() === '') {
        console.log('⚠️ Empty value for:', fieldName);
        return false;
    }
    
    const trimmedValue = value.trim().toUpperCase();
    console.log(`🔧 Setting ${fieldName} to: "${trimmedValue}"`);
    
    let found = false;
    
    // Strategy 1: Try exact match on value (case-insensitive)
    for (let i = 0; i < selectElement.options.length; i++) {
        const optionValue = selectElement.options[i].value.trim().toUpperCase();
        if (optionValue === trimmedValue) {
            selectElement.selectedIndex = i;
            found = true;
            console.log(`✅ ${fieldName} set successfully (exact match) to: "${trimmedValue}"`);
            return true;
        }
    }
    
    // Strategy 2: Try matching on text content
    for (let i = 0; i < selectElement.options.length; i++) {
        const optionText = selectElement.options[i].text.trim().toUpperCase();
        if (optionText.includes(trimmedValue) || trimmedValue.includes(optionText)) {
            selectElement.selectedIndex = i;
            found = true;
            console.log(`✅ ${fieldName} set successfully (text match) to: "${selectElement.options[i].value}"`);
            return true;
        }
    }
    
    // Strategy 3: Try partial match on value
    for (let i = 0; i < selectElement.options.length; i++) {
        const optionValue = selectElement.options[i].value.trim().toUpperCase();
        if (optionValue.includes(trimmedValue) || trimmedValue.includes(optionValue)) {
            selectElement.selectedIndex = i;
            found = true;
            console.log(`✅ ${fieldName} set successfully (partial match) to: "${selectElement.options[i].value}"`);
            return true;
        }
    }
    
    if (!found) {
        console.warn(`⚠️ Value "${trimmedValue}" not found in ${fieldName} dropdown`);
        console.log('First 10 available options:');
        for (let i = 0; i < Math.min(10, selectElement.options.length); i++) {
            console.log(`  [${i}] value="${selectElement.options[i].value}" text="${selectElement.options[i].text}"`);
        }
    }
    
    return found;
}

//Customer Lookup Functions with exclusion support
function openCustomerLookup(excludeCustomerId = null) {
  const modal = document.getElementById('customerLookupModal');
  const content = document.getElementById('customerLookupContent');

  modal.style.display = 'flex';
  content.innerHTML = '<div style="text-align:center;padding:40px;">Loading customers...</div>';

  // ✅ Build URL with exclusion parameter if provided
  let url = 'lookupForCustomerId.jsp';
  if (excludeCustomerId) {
    url += '?excludeCustomerId=' + encodeURIComponent(excludeCustomerId);
  }

  fetch(url)
      .then(response => response.text())
      .then(html => {
          content.innerHTML = html;
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

window.onclick = function(event) {
    const modal = document.getElementById('customerLookupModal');
    if (event.target === modal) {
        closeCustomerLookup();
    }
}

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeCustomerLookup();
    }
});

//==================== NOMINEE FUNCTIONS ====================

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
        input.value = '';
        clearNomineeFields(nomineeBlock);
    }
}

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

// Update Nominee Customer Lookup
function openNomineeCustomerLookup(button) {
  const nomineeBlock = button.closest('.nominee-block');
  const input = nomineeBlock.querySelector('.nomineeCustomerIDInput');
  window.currentNomineeInput = input;
  window.currentNomineeBlock = nomineeBlock;
  
  // ✅ Get main customer ID to exclude from lookup
  const mainCustomerId = document.getElementById('customerId')?.value || null;
  openCustomerLookup(mainCustomerId);
}

function addNominee() {
    let fieldset = document.getElementById("nomineeFieldset");
    let original = fieldset.querySelector(".nominee-block");
    let clone = original.cloneNode(true);

    clone.querySelectorAll("input, select").forEach(el => {
        if (el.type === 'radio') {
            if (el.value === 'no') el.checked = true;
            else el.checked = false;
        } else if (el.tagName === 'SELECT') {
            el.selectedIndex = 0;
        } else if (el.name === 'nomineeZip[]') {
            el.value = '0';
        } else {
            el.value = "";
        }
    });

    const customerIDContainer = clone.querySelector('.nomineeCustomerIDContainer');
    if (customerIDContainer) {
        customerIDContainer.style.display = 'none';
    }

    const nomineeBlocks = fieldset.querySelectorAll(".nominee-block");
    const newIndex = nomineeBlocks.length + 1;
    const radios = clone.querySelectorAll('.nomineeHasCustomerRadio');
    radios.forEach(radio => {
        radio.name = `nomineeHasCustomerID_${newIndex}`;
    });

    clone.querySelector(".nominee-remove").onclick = function() {
        removeNominee(this);
    };

    fieldset.appendChild(clone);
    updateNomineeSerials();
}

function removeNominee(btn) {
    let blocks = document.querySelectorAll(".nominee-block");
    if (blocks.length <= 1) {
        showToast("At least one nominee is required.", "warning");
        return;
    }
    btn.parentNode.remove();
    updateNomineeSerials();
}

function updateNomineeSerials() {
    let blocks = document.querySelectorAll(".nominee-block");
    blocks.forEach((block, index) => {
        let serial = block.querySelector(".nominee-serial");
        if (serial) {
            serial.textContent = (index + 1);
        }
    });
}

//Populate Nominee fields with customer data
function populateNomineeFields(block, customer) {
    console.log('📝 Populating Nominee fields:', customer);
    
    const salutationSelect = block.querySelector('select[name="nomineeSalutation[]"]');
    if (salutationSelect && customer.salutationCode) {
        setSelectValue(salutationSelect, customer.salutationCode, 'Nominee Salutation');
    }

    const nameInput = block.querySelector('input[name="nomineeName[]"]');
    if (nameInput && customer.customerName) {
        nameInput.value = customer.customerName;
    }

    const address1Input = block.querySelector('input[name="nomineeAddress1[]"]');
    if (address1Input && customer.address1) {
        address1Input.value = customer.address1;
    }

    const address2Input = block.querySelector('input[name="nomineeAddress2[]"]');
    if (address2Input && customer.address2) {
        address2Input.value = customer.address2;
    }

    const address3Input = block.querySelector('input[name="nomineeAddress3[]"]');
    if (address3Input && customer.address3) {
        address3Input.value = customer.address3;
    }

    const countrySelect = block.querySelector('select[name="nomineeCountry[]"]');
    if (countrySelect && customer.country) {
        setSelectValue(countrySelect, customer.country, 'Nominee Country');
    }

    const stateSelect = block.querySelector('select[name="nomineeState[]"]');
    if (stateSelect && customer.state) {
        setSelectValue(stateSelect, customer.state, 'Nominee State');
    }

    const citySelect = block.querySelector('select[name="nomineeCity[]"]');
    if (citySelect && customer.city) {
        setSelectValue(citySelect, customer.city, 'Nominee City');
    }

    const zipInput = block.querySelector('input[name="nomineeZip[]"]');
    if (zipInput && customer.zip) {
        zipInput.value = customer.zip;
    }
}

//==================== JOINT HOLDER FUNCTIONS ====================

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
        input.value = '';
        clearJointFields(jointBlock);
    }
}

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

// Update Joint Holder Customer Lookup
function openJointCustomerLookup(button) {
  const jointBlock = button.closest('.joint-block');
  const input = jointBlock.querySelector('.jointCustomerIDInput');
  window.currentJointInput = input;
  window.currentJointBlock = jointBlock;
  
  // ✅ Get main customer ID to exclude from lookup
  const mainCustomerId = document.getElementById('customerId')?.value || null;
  openCustomerLookup(mainCustomerId);
}

function addJointHolder() {
    let fieldset = document.getElementById("jointFieldset");
    let original = fieldset.querySelector(".joint-block");
    let clone = original.cloneNode(true);

    clone.querySelectorAll("input, select").forEach(el => {
        if (el.type === 'radio') {
            if (el.value === 'no') el.checked = true;
            else el.checked = false;
        } else if (el.tagName === 'SELECT') {
            el.selectedIndex = 0;
        } else if (el.name === 'jointZip[]') {
            el.value = '0';
        } else {
            el.value = "";
        }
    });

    const customerIDContainer = clone.querySelector('.jointCustomerIDContainer');
    if (customerIDContainer) {
        customerIDContainer.style.display = 'none';
    }

    const jointBlocks = fieldset.querySelectorAll(".joint-block");
    const newIndex = jointBlocks.length + 1;
    const radios = clone.querySelectorAll('.jointHasCustomerRadio');
    radios.forEach(radio => {
        radio.name = `jointHasCustomerID_${newIndex}`;
    });

    clone.querySelector(".nominee-remove").onclick = function() {
        removeJointHolder(this);
    };

    fieldset.appendChild(clone);
    updateJointSerials();
}

function removeJointHolder(btn) {
    let blocks = document.querySelectorAll(".joint-block");
    if (blocks.length <= 1) {
        showToast("At least one joint holder is required.", "warning");
        return;
    }
    btn.parentNode.remove();
    updateJointSerials();
}

function updateJointSerials() {
    let blocks = document.querySelectorAll(".joint-block");
    blocks.forEach((block, index) => {
        let serial = block.querySelector(".joint-serial");
        if (serial) {
            serial.textContent = (index + 1);
        }
    });
}

//Populate Joint Holder fields with customer data
function populateJointFields(block, customer) {
    console.log('📝 Populating Joint Holder fields:', customer);
    
    const salutationSelect = block.querySelector('select[name="jointSalutation[]"]');
    if (salutationSelect && customer.salutationCode) {
        setSelectValue(salutationSelect, customer.salutationCode, 'Joint Salutation');
    }

    const nameInput = block.querySelector('input[name="jointName[]"]');
    if (nameInput && customer.customerName) {
        nameInput.value = customer.customerName;
    }

    const address1Input = block.querySelector('input[name="jointAddress1[]"]');
    if (address1Input && customer.address1) {
        address1Input.value = customer.address1;
    }

    const address2Input = block.querySelector('input[name="jointAddress2[]"]');
    if (address2Input && customer.address2) {
        address2Input.value = customer.address2;
    }

    const address3Input = block.querySelector('input[name="jointAddress3[]"]');
    if (address3Input && customer.address3) {
        address3Input.value = customer.address3;
    }

    const countrySelect = block.querySelector('select[name="jointCountry[]"]');
    if (countrySelect && customer.country) {
        setSelectValue(countrySelect, customer.country, 'Joint Country');
    }

    const stateSelect = block.querySelector('select[name="jointState[]"]');
    if (stateSelect && customer.state) {
        setSelectValue(stateSelect, customer.state, 'Joint State');
    }

    const citySelect = block.querySelector('select[name="jointCity[]"]');
    if (citySelect && customer.city) {
        setSelectValue(citySelect, customer.city, 'Joint City');
    }

    const zipInput = block.querySelector('input[name="jointZip[]"]');
    if (zipInput && customer.zip) {
        zipInput.value = customer.zip;
    }
}
//==================== CO-BORROWER FUNCTIONS (FIXED) ====================

// ✅ FIXED: Updated field names in populate function
function populateCoBorrowerFields(block, customer) {
  console.log('📝 Populating Co-Borrower fields:', customer);
  
  // Salutation Code
  const salutationSelect = block.querySelector('select[name="coBorrowerSalutation[]"]');
  if (salutationSelect && customer.salutationCode) {
      setSelectValue(salutationSelect, customer.salutationCode, 'Co-Borrower Salutation');
  }

  // Co-Borrower Name
  const nameInput = block.querySelector('input[name="coBorrowerName[]"]');
  if (nameInput && customer.customerName) {
      nameInput.value = customer.customerName;
  }

  // Address fields
  const address1Input = block.querySelector('input[name="coBorrowerAddress1[]"]');
  if (address1Input && customer.address1) {
      address1Input.value = customer.address1;
  }

  const address2Input = block.querySelector('input[name="coBorrowerAddress2[]"]');
  if (address2Input && customer.address2) {
      address2Input.value = customer.address2;
  }

  const address3Input = block.querySelector('input[name="coBorrowerAddress3[]"]');
  if (address3Input && customer.address3) {
      address3Input.value = customer.address3;
  }

  // Country
  const countrySelect = block.querySelector('select[name="coBorrowerCountry[]"]');
  if (countrySelect && customer.country) {
      setSelectValue(countrySelect, customer.country, 'Co-Borrower Country');
  }

  // State
  const stateSelect = block.querySelector('select[name="coBorrowerState[]"]');
  if (stateSelect && customer.state) {
      setSelectValue(stateSelect, customer.state, 'Co-Borrower State');
  }

  // City
  const citySelect = block.querySelector('select[name="coBorrowerCity[]"]');
  if (citySelect && customer.city) {
      setSelectValue(citySelect, customer.city, 'Co-Borrower City');
  }

  // Zip
  const zipInput = block.querySelector('input[name="coBorrowerZip[]"]');
  if (zipInput && customer.zip) {
      zipInput.value = customer.zip;
  }
}


//==================== GUARANTOR FUNCTIONS ====================

//Populate Guarantor fields with customer data
function populateGuarantorFields(block, customer) {
  console.log('📝 Populating Guarantor fields:', customer);
  
  const salutationSelect = block.querySelector('select[name="guarantorSalutation[]"]');
  if (salutationSelect && customer.salutationCode) {
      setSelectValue(salutationSelect, customer.salutationCode, 'Guarantor Salutation');
  }

  const nameInput = block.querySelector('input[name="guarantorName[]"]');
  if (nameInput && customer.customerName) {
      nameInput.value = customer.customerName;
  }

  const address1Input = block.querySelector('input[name="guarantorAddress1[]"]');
  if (address1Input && customer.address1) {
      address1Input.value = customer.address1;
  }

  const address2Input = block.querySelector('input[name="guarantorAddress2[]"]');
  if (address2Input && customer.address2) {
      address2Input.value = customer.address2;
  }

  const address3Input = block.querySelector('input[name="guarantorAddress3[]"]');
  if (address3Input && customer.address3) {
      address3Input.value = customer.address3;
  }

  const countrySelect = block.querySelector('select[name="guarantorCountry[]"]');
  if (countrySelect && customer.country) {
      setSelectValue(countrySelect, customer.country, 'Guarantor Country');
  }

  const stateSelect = block.querySelector('select[name="guarantorState[]"]');
  if (stateSelect && customer.state) {
      setSelectValue(stateSelect, customer.state, 'Guarantor State');
  }

  const citySelect = block.querySelector('select[name="guarantorCity[]"]');
  if (citySelect && customer.city) {
      setSelectValue(citySelect, customer.city, 'Guarantor City');
  }

  const zipInput = block.querySelector('input[name="guarantorZip[]"]');
  if (zipInput && customer.zip) {
      zipInput.value = customer.zip;
  }

  const memberNoInput = block.querySelector('input[name="guarantorMemberNo[]"]');
  if (memberNoInput && customer.memberNumber) {
      memberNoInput.value = customer.memberNumber;
  }

  const birthDateInput = block.querySelector('input[name="guarantorBirthDate[]"]');
  if (birthDateInput && customer.birthDate) {
      birthDateInput.value = customer.birthDate;
  }

  const phoneNoInput = block.querySelector('input[name="guarantorPhoneNo[]"]');
  if (phoneNoInput && customer.residencePhone) {
      phoneNoInput.value = customer.residencePhone;
  }

  const mobileNoInput = block.querySelector('input[name="guarantorMobileNo[]"]');
  if (mobileNoInput && customer.mobileNo) {
      mobileNoInput.value = customer.mobileNo;
  }
}
//==================== UTILITY FUNCTIONS ====================

// Enhanced toast utility function with different types
function showToast(message, type = 'success') {
    if (typeof Toastify === 'undefined') {
        console.warn('Toastify library not loaded');
        return;
    }
    
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
    
    const style = styles[type] || styles.info;
    
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