function toggleMinorFields() {
  const isMinor = document.querySelector('input[name="isMinor"]:checked').value;
  const guardianName = document.getElementById('guardianName');
  const relationGuardian = document.getElementById('relationGuardian');

  if (isMinor === 'yes') {
    guardianName.disabled = false;
    relationGuardian.disabled = false;
  } else {
    guardianName.disabled = true;
    relationGuardian.disabled = true;
    guardianName.value = '';
    relationGuardian.value = 'NOT SPECIFIED';
  }
}

function toggleMarriedFields() {
  const maritalStatus = document.querySelector('input[name="maritalStatus"]:checked').value;
  const noOFChildren = document.getElementById('children');
  const noOfDependents = document.getElementById('dependents');

  if (maritalStatus === 'Single') {
    noOFChildren.disabled = true;
    noOfDependents.disabled = true;
  } else {
    noOFChildren.disabled = false;
    noOfDependents.disabled = false;
    noOFChildren.value = '';
    noOfDependents.value = 'NOT SPECIFIED';
  }
}

document.addEventListener("DOMContentLoaded", function() {
  // Select all rows inside the KYC tables
  document.querySelectorAll(".kyc-section table tr").forEach(row => {
    const checkbox = row.querySelector('input[type="checkbox"]');
    const inputs = row.querySelectorAll('input[type="date"], input[type="text"]');
    
    if (checkbox) {
      inputs.forEach(input => input.disabled = true);
      checkbox.addEventListener("change", () => {
        inputs.forEach(input => input.disabled = !checkbox.checked);
      });
    }
  });
});

// Validation patterns
const validationPatterns = {
    gstin: /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/,
    pan: /^[A-Z]{5}[0-9]{4}[A-Z]{1}$/,
    aadhar: /^[0-9]{12}$/,
    mobile: /^[6-9][0-9]{9}$/,
    phone: /^[0-9]{10,11}$/,
    zip: /^[0-9]{6}$/,
    voterId: /^[A-Z]{3}[0-9]{7}$/,
    drivingLicense: /^[A-Z]{2}[0-9]{13}$/,
    passport: /^[A-Z]{1}[0-9]{7}$/,
    nrega: /^[A-Z]{2}-[0-9]{2}-[0-9]{3}-[0-9]{3}-[0-9]{6}$/
};

// Real-time input formatting and validation
function setupFieldValidations() {
    const gstinField = document.querySelector('input[name="gstinNo"]');
    if (gstinField) {
        gstinField.maxLength = 15;
        gstinField.addEventListener('input', function(e) {
            this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
        });
        gstinField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.gstin.test(this.value)) {
                showError(this, 'Invalid GSTIN format (e.g., 22AAAAA0000A1Z5)');
            } else {
                clearError(this);
            }
        });
    }

    const memberField = document.querySelector('input[name="memberNumber"]');
    if (memberField) {
        memberField.maxLength = 2;
        memberField.addEventListener('input', function(e) {
            this.value = this.value.replace(/[^0-9]/g, '').slice(0, 2);
        });
        memberField.addEventListener('blur', function() {
            if (!this.value) {
                showError(this, 'Member Number is required');
            } else if (this.value.length < 1 || this.value.length > 2) {
                showError(this, 'Member Number must be 1 or 2 digits');
            } else {
                clearError(this);
            }
        });
    }

    const zipField = document.querySelector('input[name="zip"]');
    if (zipField) {
        zipField.maxLength = 6;
        zipField.addEventListener('input', function(e) {
            this.value = this.value.replace(/[^0-9]/g, '').slice(0, 6);
        });
        zipField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.zip.test(this.value)) {
                showError(this, 'ZIP code must be 6 digits');
            } else {
                clearError(this);
            }
        });
    }

    const mobileField = document.querySelector('input[name="mobileNo"]');
    if (mobileField) {
        mobileField.maxLength = 10;
        mobileField.addEventListener('input', function(e) {
            this.value = this.value.replace(/[^0-9]/g, '').slice(0, 10);
        });
        mobileField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.mobile.test(this.value)) {
                showError(this, 'Mobile number must be 10 digits starting with 6-9');
            } else {
                clearError(this);
            }
        });
    }

    const residencePhoneField = document.querySelector('input[name="residencePhone"]');
    if (residencePhoneField) {
        residencePhoneField.maxLength = 11;
        residencePhoneField.addEventListener('input', function(e) {
            this.value = this.value.replace(/[^0-9]/g, '').slice(0, 11);
        });
        residencePhoneField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.phone.test(this.value)) {
                showError(this, 'Phone number must be 10-11 digits');
            } else {
                clearError(this);
            }
        });
    }

    const officePhoneField = document.querySelector('input[name="officePhone"]');
    if (officePhoneField) {
        officePhoneField.maxLength = 11;
        officePhoneField.addEventListener('input', function(e) {
            this.value = this.value.replace(/[^0-9]/g, '').slice(0, 11);
        });
        officePhoneField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.phone.test(this.value)) {
                showError(this, 'Phone number must be 10-11 digits');
            } else {
                clearError(this);
            }
        });
    }

    const passportField = document.getElementById('passportNumber');
    if (passportField) {
        passportField.maxLength = 8;
        passportField.addEventListener('input', function(e) {
            this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
        });
        passportField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.passport.test(this.value)) {
                showError(this, 'Passport format: 1 letter + 7 digits (e.g., A1234567)');
            } else {
                clearError(this);
            }
        });
    }

    const panField = document.getElementById('pan');
    if (panField) {
        panField.maxLength = 10;
        panField.addEventListener('input', function(e) {
            this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
        });
        panField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.pan.test(this.value)) {
                showError(this, 'PAN format: ABCDE1234F (5 letters, 4 digits, 1 letter)');
            } else {
                clearError(this);
            }
        });
    }

    const voterIdField = document.getElementById('voterid');
    if (voterIdField) {
        voterIdField.maxLength = 10;
        voterIdField.addEventListener('input', function(e) {
            this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
        });
        voterIdField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.voterId.test(this.value)) {
                showError(this, 'Voter ID format: ABC1234567 (3 letters + 7 digits)');
            } else {
                clearError(this);
            }
        });
    }

    const dlField = document.getElementById('dl');
    if (dlField) {
        dlField.maxLength = 15;
        dlField.addEventListener('input', function(e) {
            this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
        });
        dlField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.drivingLicense.test(this.value)) {
                showError(this, 'DL format: AB1234567890123 (2 letters + 13 digits)');
            } else {
                clearError(this);
            }
        });
    }

    const aadharField = document.querySelector('input[name="aadhar"]');
    if (aadharField) {
        aadharField.maxLength = 12;
        aadharField.addEventListener('input', function(e) {
            this.value = this.value.replace(/[^0-9]/g, '').slice(0, 12);
        });
        aadharField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.aadhar.test(this.value)) {
                showError(this, 'Aadhar must be exactly 12 digits');
            } else {
                clearError(this);
            }
        });
    }

    const nregaField = document.getElementById('nrega');
    if (nregaField) {
        nregaField.maxLength = 22;
        nregaField.addEventListener('input', function(e) {
            let value = this.value.toUpperCase().replace(/[^A-Z0-9-]/g, '');
            if (value.length > 2 && value[2] !== '-') {
                value = value.slice(0, 2) + '-' + value.slice(2);
            }
            if (value.length > 5 && value[5] !== '-') {
                value = value.slice(0, 5) + '-' + value.slice(5);
            }
            if (value.length > 9 && value[9] !== '-') {
                value = value.slice(0, 9) + '-' + value.slice(9);
            }
            if (value.length > 13 && value[13] !== '-') {
                value = value.slice(0, 13) + '-' + value.slice(13);
            }
            this.value = value;
        });
    }

    const docFields = ['telephone', 'bank_statement', 'govt_doc', 'electricity'];
    docFields.forEach(fieldName => {
        const field = document.querySelector(`input[name="${fieldName}"]`);
        if (field) {
            field.maxLength = 20;
            field.addEventListener('input', function(e) {
                this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
            });
        }
    });

    const rationField = document.getElementById('ration');
    if (rationField) {
        rationField.maxLength = 15;
        rationField.addEventListener('input', function(e) {
            this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
        });
    }
}

function showError(field, message) {
    clearError(field);
    field.style.borderColor = '#ff0000';
    field.style.backgroundColor = '#ffe6e6';
    
    const errorDiv = document.createElement('div');
    errorDiv.className = 'error-message';
    errorDiv.style.color = '#ff0000';
    errorDiv.style.fontSize = '11px';
    errorDiv.style.marginTop = '3px';
    errorDiv.textContent = message;
    
    field.parentNode.appendChild(errorDiv);
}

function clearError(field) {
    field.style.borderColor = '';
    field.style.backgroundColor = '';
    
    const errorDiv = field.parentNode.querySelector('.error-message');
    if (errorDiv) {
        errorDiv.remove();
    }
}

function validateForm() {
    let isValid = true;
    const errors = [];

    const gstin = document.querySelector('input[name="gstinNo"]').value;
    if (gstin && !validationPatterns.gstin.test(gstin)) {
        errors.push('• Invalid GSTIN number');
        isValid = false;
    }

    const mobile = document.querySelector('input[name="mobileNo"]').value;
    if (!mobile) {
        errors.push('• Mobile number is required');
        isValid = false;
    } else if (!validationPatterns.mobile.test(mobile)) {
        errors.push('• Invalid mobile number');
        isValid = false;
    }

    const zip = document.querySelector('input[name="zip"]').value;
    if (zip && !validationPatterns.zip.test(zip)) {
        errors.push('• Invalid ZIP code');
        isValid = false;
    }

    const pan = document.getElementById('pan').value;
    if (pan && !validationPatterns.pan.test(pan)) {
        errors.push('• Invalid PAN card number');
        isValid = false;
    }

    const aadhar = document.querySelector('input[name="aadhar"]').value;
    if (aadhar && !validationPatterns.aadhar.test(aadhar)) {
        errors.push('• Invalid Aadhar number');
        isValid = false;
    }

    const passport = document.getElementById('passportNumber').value;
    if (passport && !validationPatterns.passport.test(passport)) {
        errors.push('• Invalid Passport number');
        isValid = false;
    }

    const voterId = document.getElementById('voterid').value;
    if (voterId && !validationPatterns.voterId.test(voterId)) {
        errors.push('• Invalid Voter ID');
        isValid = false;
    }

    const dl = document.getElementById('dl').value;
    if (dl && !validationPatterns.drivingLicense.test(dl)) {
        errors.push('• Invalid Driving License number');
        isValid = false;
    }

    const idProofFilled = 
        (document.querySelector('input[name="passport_check"]').checked && document.querySelector('input[name="passport_expiry"]').value && document.querySelector('input[name="passportNumber"]').value.trim()) ||
        (document.querySelector('input[name="pan_check"]').checked && document.querySelector('input[name="pan_expiry"]').value && document.getElementById('pan').value.trim()) ||
        (document.querySelector('input[name="voterid_check"]').checked && document.querySelector('input[name="voterid_expiry"]').value && document.getElementById('voterid').value.trim()) ||
        (document.querySelector('input[name="dl_check"]').checked && document.querySelector('input[name="dl_expiry"]').value && document.getElementById('dl').value.trim()) ||
        (document.querySelector('input[name="aadhar_check"]').checked && document.querySelector('input[name="aadhar_expiry"]').value && document.querySelector('input[name="aadhar"]').value.trim()) ||
        (document.querySelector('input[name="nrega_check"]').checked && document.querySelector('input[name="nrega_expiry"]').value && document.getElementById('nrega').value.trim());

    if (!idProofFilled) {
        errors.push('• At least one ID Proof document must be selected and filled');
        isValid = false;
    }

    const addressProofFilled = 
        (document.querySelector('input[name="telephone_check"]').checked && document.querySelector('input[name="telephone_expiry"]').value && document.querySelector('input[name="telephone"]').value.trim()) ||
        (document.querySelector('input[name="bank_check"]').checked && document.querySelector('input[name="bank_expiry"]').value && document.querySelector('input[name="bank_statement"]').value.trim()) ||
        (document.querySelector('input[name="govt_check"]').checked && document.querySelector('input[name="govt_expiry"]').value && document.querySelector('input[name="govt_doc"]').value.trim()) ||
        (document.querySelector('input[name="electricity_check"]').checked && document.querySelector('input[name="electricity_expiry"]').value && document.querySelector('input[name="electricity"]').value.trim()) ||
        (document.querySelector('input[name="ration_check"]').checked && document.querySelector('input[name="ration_expiry"]').value && document.getElementById('ration').value.trim());

    if (!addressProofFilled) {
        errors.push('• At least one Address Proof document must be selected and filled');
        isValid = false;
    }

    if (!isValid) {
        showValidationToast(errors);
    }

    return isValid;
}

function showValidationToast(errors) {
    const errorMessage = '❌ Please fix the following errors:\n\n' + errors.join('\n');
    
    Toastify({
        text: errorMessage,
        duration: 6000, 
        close: true,
        gravity: "top",
        position: "center",
        style: {
            background: "#fff",
            color: "#333",
            borderRadius: "8px",
            fontSize: "14px",
            padding: "20px 30px",
            boxShadow: "0 4px 12px rgba(0,0,0,0.3)",
            borderLeft: "5px solid #f44336",
            marginTop: "20px",
            maxWidth: "500px",
            whiteSpace: "pre-line"
        },
        stopOnFocus: true,
        onClick: function(){} 
    }).showToast();
}

document.addEventListener('DOMContentLoaded', function() {
    setupFieldValidations();
});

function updateCustomerName() {
    const first = document.getElementById("firstName").value.trim();
    const middle = document.getElementById("middleName").value.trim();
    const surname = document.getElementById("surname").value.trim();
    const fullName = [first, middle, surname].filter(Boolean).join(" ");
    document.getElementById("customerName").value = fullName;
}

window.onload = function() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Add Customer');
    }
};

const toastStyle = document.createElement('style');
toastStyle.textContent = `
    .toastify {
        position: fixed !important;
        z-index: 9999 !important;
        pointer-events: auto !important;
    }
    
    .toastify.on {
        position: fixed !important;
    }
`;
document.head.appendChild(toastStyle);

window.addEventListener('DOMContentLoaded', function() {
    const urlParams = new URLSearchParams(window.location.search);
    const status = urlParams.get('status');
    const customerId = urlParams.get('customerId');
    const message = urlParams.get('message');
    
    if (status === 'success') {
        const toast = Toastify({
            text: "✅ Customer added successfully!\nCustomer ID: " + customerId,
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
            },
            stopOnFocus: true,
            onClick: function(){} 
        }).showToast();
        
        const toastElement = toast.toastElement;
        const progressBar = document.createElement('div');
        progressBar.style.cssText = `
            position: absolute;
            bottom: 0;
            left: 0;
            height: 4px;
            width: 100%;
            background-color: #4caf50;
            animation: shrink 5s linear forwards;
        `;
        
        const style = document.createElement('style');
        style.textContent = `
            @keyframes shrink {
                from { width: 100%; }
                to { width: 0%; }
            }
        `;
        document.head.appendChild(style);
        
        toastElement.style.position = 'relative';
        toastElement.style.overflow = 'hidden';
        toastElement.appendChild(progressBar);
        
        setTimeout(function() {
            window.history.replaceState({}, document.title, "addCustomer.jsp");
        }, 100);
        
    } else if (status === 'error') {
        const toast = Toastify({
            text: "❌ Error: " + (message || "Failed to add customer"),
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
                borderLeft: "5px solid #f44336",
                marginTop: "20px"
            },
            stopOnFocus: true
        }).showToast();
        
        const toastElement = toast.toastElement;
        const progressBar = document.createElement('div');
        progressBar.style.cssText = `
            position: absolute;
            bottom: 0;
            left: 0;
            height: 4px;
            width: 100%;
            background-color: #f44336;
            animation: shrink 5s linear forwards;
        `;
        
        toastElement.style.position = 'relative';
        toastElement.style.overflow = 'hidden';
        toastElement.appendChild(progressBar);
        
        setTimeout(function() {
            window.history.replaceState({}, document.title, "addCustomer.jsp");
        }, 100);
    }
});

// ========== PHOTO & SIGNATURE UPLOAD FUNCTIONALITY (FIXED) ==========

let photoStream = null;
let signatureStream = null;

// Show Photo Options Modal - FIXED
function showPhotoOptions(event) {
    event.preventDefault();
    event.stopPropagation();
    
    const modal = document.getElementById('photoOptionsModal');
    modal.style.display = 'block';
    setTimeout(function() {
        modal.classList.add('show');
    }, 10);
}

// Close Photo Options Modal
function closePhotoOptions() {
    const modal = document.getElementById('photoOptionsModal');
    modal.classList.remove('show');
    setTimeout(function() {
        modal.style.display = 'none';
    }, 300);
}

// Show Signature Options Modal - FIXED
function showSignatureOptions(event) {
    event.preventDefault();
    event.stopPropagation();
    
    const modal = document.getElementById('signatureOptionsModal');
    modal.style.display = 'block';
    setTimeout(function() {
        modal.classList.add('show');
    }, 10);
}

// Close Signature Options Modal
function closeSignatureOptions() {
    const modal = document.getElementById('signatureOptionsModal');
    modal.classList.remove('show');
    setTimeout(function() {
        modal.style.display = 'none';
    }, 300);
}

// Handle Photo File
function handlePhotoFile(file) {
    if (!file.type.startsWith('image/')) {
        alert('Please select an image file');
        return;
    }
    
    const reader = new FileReader();
    reader.onload = function(e) {
        const container = document.querySelector('#photoCard .upload-icon-container');
        container.innerHTML = '<img src="' + e.target.result + '" class="preview-image" style="width:100%; height:100%; object-fit:cover; border-radius:50%;">';
        document.getElementById('photoData').value = e.target.result;
        
        showToast('✅ Photo uploaded successfully!');
    };
    reader.readAsDataURL(file);
}

// Handle Signature File
function handleSignatureFile(file) {
    if (!file.type.startsWith('image/')) {
        alert('Please select an image file');
        return;
    }
    
    const reader = new FileReader();
    reader.onload = function(e) {
        const container = document.querySelector('#signatureCard .upload-icon-container');
        container.innerHTML = '<img src="' + e.target.result + '" class="preview-image" style="width:100%; height:100%; object-fit:cover; border-radius:50%;">';
        document.getElementById('signatureData').value = e.target.result;
        
        showToast('✅ Signature uploaded successfully!');
    };
    reader.readAsDataURL(file);
}

// Initialize file input handlers and card click events
(function() {
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initFileInputs);
    } else {
        initFileInputs();
    }
    
    function initFileInputs() {
        // Photo Card Click Handler
        const photoCard = document.getElementById('photoCard');
        if (photoCard) {
            photoCard.addEventListener('click', function(e) {
                showPhotoOptions(e);
            });
        }

        // Signature Card Click Handler
        const signatureCard = document.getElementById('signatureCard');
        if (signatureCard) {
            signatureCard.addEventListener('click', function(e) {
                showSignatureOptions(e);
            });
        }

        // Photo Upload - Browse
        const photoInput = document.getElementById('photoInput');
        if (photoInput) {
            photoInput.addEventListener('change', function(e) {
                const file = e.target.files[0];
                if (file) {
                    handlePhotoFile(file);
                }
                this.value = '';
            });
        }

        // Signature Upload - Browse
        const signatureInput = document.getElementById('signatureInput');
        if (signatureInput) {
            signatureInput.addEventListener('change', function(e) {
                const file = e.target.files[0];
                if (file) {
                    handleSignatureFile(file);
                }
                this.value = '';
            });
        }
    }
})();

// Open Photo Camera
function openPhotoCamera() {
    closePhotoOptions();
    const modal = document.getElementById('photoCameraModal');
    const video = document.getElementById('photoVideo');
    
    modal.style.display = 'block';
    
    navigator.mediaDevices.getUserMedia({ video: { facingMode: 'user' } })
        .then(function(stream) {
            photoStream = stream;
            video.srcObject = stream;
        })
        .catch(function(err) {
            alert('Error accessing camera: ' + err.message);
            closePhotoCamera();
        });
}

// Close Photo Camera
function closePhotoCamera() {
    const modal = document.getElementById('photoCameraModal');
    const video = document.getElementById('photoVideo');
    
    if (photoStream) {
        photoStream.getTracks().forEach(track => track.stop());
        photoStream = null;
    }
    
    video.srcObject = null;
    modal.style.display = 'none';
}

// Capture Photo
function capturePhoto() {
    const video = document.getElementById('photoVideo');
    const canvas = document.getElementById('photoCanvas');
    const context = canvas.getContext('2d');
    
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    context.drawImage(video, 0, 0, canvas.width, canvas.height);
    
    const imageData = canvas.toDataURL('image/jpeg');
    
    const container = document.querySelector('#photoCard .upload-icon-container');
    container.innerHTML = '<img src="' + imageData + '" class="preview-image" style="width:100%; height:100%; object-fit:cover; border-radius:50%;">';
    document.getElementById('photoData').value = imageData;
    
    closePhotoCamera();
    showToast('✅ Photo captured successfully!');
}

// Open Signature Camera
function openSignatureCamera() {
    closeSignatureOptions();
    const modal = document.getElementById('signatureCameraModal');
    const video = document.getElementById('signatureVideo');
    
    modal.style.display = 'block';
    
    navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } })
        .then(function(stream) {
            signatureStream = stream;
            video.srcObject = stream;
        })
        .catch(function(err) {
            alert('Error accessing camera: ' + err.message);
            closeSignatureCamera();
        });
}

// Close Signature Camera
function closeSignatureCamera() {
    const modal = document.getElementById('signatureCameraModal');
    const video = document.getElementById('signatureVideo');
    
    if (signatureStream) {
        signatureStream.getTracks().forEach(track => track.stop());
        signatureStream = null;
    }
    
    video.srcObject = null;
    modal.style.display = 'none';
}

// Capture Signature
function captureSignature() {
    const video = document.getElementById('signatureVideo');
    const canvas = document.getElementById('signatureCanvas');
    const context = canvas.getContext('2d');
    
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    context.drawImage(video, 0, 0, canvas.width, canvas.height);
    
    const imageData = canvas.toDataURL('image/jpeg');
    
    const container = document.querySelector('#signatureCard .upload-icon-container');
    container.innerHTML = '<img src="' + imageData + '" class="preview-image" style="width:100%; height:100%; object-fit:cover; border-radius:50%;">';
    document.getElementById('signatureData').value = imageData;
    
    closeSignatureCamera();
    showToast('✅ Signature captured successfully!');
}

// Drag and Drop for Photo
const photoCardDrag = document.getElementById('photoCard');
if (photoCardDrag) {
    photoCardDrag.addEventListener('dragover', function(e) {
        e.preventDefault();
        e.stopPropagation();
        this.classList.add('dragover');
    });

    photoCardDrag.addEventListener('dragleave', function(e) {
        e.preventDefault();
        e.stopPropagation();
        this.classList.remove('dragover');
    });

    photoCardDrag.addEventListener('drop', function(e) {
        e.preventDefault();
        e.stopPropagation();
        this.classList.remove('dragover');
        
        const file = e.dataTransfer.files[0];
        if (file) {
            handlePhotoFile(file);
        }
    });
}

// Drag and Drop for Signature
const signatureCardDrag = document.getElementById('signatureCard');
if (signatureCardDrag) {
    signatureCardDrag.addEventListener('dragover', function(e) {
        e.preventDefault();
        e.stopPropagation();
        this.classList.add('dragover');
    });

    signatureCardDrag.addEventListener('dragleave', function(e) {
        e.preventDefault();
        e.stopPropagation();
        this.classList.remove('dragover');
    });

    signatureCardDrag.addEventListener('drop', function(e) {
        e.preventDefault();
        e.stopPropagation();
        this.classList.remove('dragover');
        
        const file = e.dataTransfer.files[0];
        if (file) {
            handleSignatureFile(file);
        }
    });
}

// Close modals when clicking outside
window.addEventListener('click', function(event) {
    if (event.target.id === 'photoOptionsModal') {
        closePhotoOptions();
    }
    if (event.target.id === 'signatureOptionsModal') {
        closeSignatureOptions();
    }
    if (event.target.id === 'photoCameraModal') {
        closePhotoCamera();
    }
    if (event.target.id === 'signatureCameraModal') {
        closeSignatureCamera();
    }
});

// Close on Escape key
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closePhotoOptions();
        closeSignatureOptions();
        closePhotoCamera();
        closeSignatureCamera();
    }
});

// Toast notification helper
function showToast(message) {
    if (typeof Toastify !== 'undefined') {
        Toastify({
            text: message,
            duration: 3000,
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

// ========== END PHOTO & SIGNATURE UPLOAD FUNCTIONALITY ==========