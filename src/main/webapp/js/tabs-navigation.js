// ============================================
// TABBED NAVIGATION WITH VALIDATION
// ============================================

(function() {
    'use strict';

    // Tab configuration
    const TABS = [
        { id: 1, name: 'Customer Information', fieldsetIndex: 0 },
        { id: 2, name: 'Personal Information', fieldsetIndex: 1 },
        { id: 3, name: 'Address Information', fieldsetIndex: 2 },
        { id: 4, name: 'KYC Documents', fieldsetIndex: 3 },
        { id: 5, name: 'Photo & Signature', fieldsetIndex: 4 }
    ];

    let currentTab = 1;
    const completedTabs = new Set();
    const enabledTabs = new Set([1]); // Tab 1 starts enabled

    // Initialize tabs on page load
    function initializeTabs() {
        createTabNavigation();
        wrapFieldsetsInTabContent();
        hideOriginalButtons();
        createNavigationButtons();
        updateTabState();
        
        console.log('✅ Tab navigation initialized');
    }

    // Create tab navigation HTML
    function createTabNavigation() {
        const nav = document.createElement('div');
        nav.className = 'tab-navigation';
        nav.innerHTML = `
            <ul class="tab-list" role="tablist">
                ${TABS.map(tab => `
                    <li class="tab-item">
                        <button class="tab-button ${tab.id === 1 ? 'active' : ''}" 
                                data-tab="${tab.id}" 
                                role="tab"
                                aria-selected="${tab.id === 1}"
                                ${tab.id !== 1 ? 'disabled' : ''}>
                            <span class="tab-number">${tab.id}</span>
                            <span class="tab-label">${tab.name}</span>
                        </button>
                    </li>
                `).join('')}
            </ul>
            <div class="progress-bar-container">
                <div class="progress-bar" style="width: 20%"></div>
            </div>
        `;

        const form = document.querySelector('form');
        form.insertBefore(nav, form.firstChild);

        // Add click handlers
        document.querySelectorAll('.tab-button').forEach(btn => {
            btn.addEventListener('click', handleTabClick);
        });
    }

    // Wrap each fieldset in tab content div
    function wrapFieldsetsInTabContent() {
        const fieldsets = document.querySelectorAll('fieldset');
        
        fieldsets.forEach((fieldset, index) => {
            const wrapper = document.createElement('div');
            wrapper.className = `tab-content ${index === 0 ? 'active' : ''}`;
            wrapper.setAttribute('data-tab-content', index + 1);
            wrapper.setAttribute('role', 'tabpanel');
            
            fieldset.parentNode.insertBefore(wrapper, fieldset);
            wrapper.appendChild(fieldset);
        });
    }

    // Hide original submit/reset buttons
    function hideOriginalButtons() {
        const formButtons = document.querySelector('.form-buttons');
        if (formButtons) {
            formButtons.style.display = 'none';
        }
    }

    // Create Previous/Next navigation buttons
    function createNavigationButtons() {
        const navButtons = document.createElement('div');
        navButtons.className = 'tab-navigation-buttons';
        navButtons.innerHTML = `
            <button type="button" class="nav-button prev-btn" id="prevTabBtn" disabled>
                Previous
            </button>
            <span class="step-indicator">Step <span id="currentStep">1</span> of ${TABS.length}</span>
            <button type="button" class="nav-button next-btn" id="nextTabBtn">
                Next
            </button>
        `;

        // Insert before the last tab content
        const lastTabContent = document.querySelector('[data-tab-content="5"]');
        lastTabContent.parentNode.insertBefore(navButtons, lastTabContent.nextSibling);

        // Add event listeners
        document.getElementById('prevTabBtn').addEventListener('click', goToPreviousTab);
        document.getElementById('nextTabBtn').addEventListener('click', goToNextTab);
    }

    // Handle tab button click
    function handleTabClick(e) {
        const btn = e.currentTarget;
        const targetTab = parseInt(btn.dataset.tab);

        if (btn.disabled || !enabledTabs.has(targetTab)) {
            return;
        }

        switchToTab(targetTab);
    }

    // Switch to specific tab
    function switchToTab(tabNumber) {
        // Hide all tab contents
        document.querySelectorAll('.tab-content').forEach(content => {
            content.classList.remove('active');
        });

        // Show target tab content
        const targetContent = document.querySelector(`[data-tab-content="${tabNumber}"]`);
        if (targetContent) {
            targetContent.classList.add('active');
            
            // Smooth scroll to top
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        }

        // Update active state
        document.querySelectorAll('.tab-button').forEach(btn => {
            btn.classList.remove('active');
            btn.setAttribute('aria-selected', 'false');
        });

        const activeBtn = document.querySelector(`[data-tab="${tabNumber}"]`);
        if (activeBtn) {
            activeBtn.classList.add('active');
            activeBtn.setAttribute('aria-selected', 'true');
        }

        currentTab = tabNumber;
        updateTabState();
    }

    // Update tab state (buttons, progress, etc.)
    function updateTabState() {
        const prevBtn = document.getElementById('prevTabBtn');
        const nextBtn = document.getElementById('nextTabBtn');
        const stepIndicator = document.getElementById('currentStep');
        const formButtons = document.querySelector('.form-buttons');
        const progressBar = document.querySelector('.progress-bar');

        // Update step indicator
        if (stepIndicator) {
            stepIndicator.textContent = currentTab;
        }

        // Update progress bar
        if (progressBar) {
            const progress = (currentTab / TABS.length) * 100;
            progressBar.style.width = progress + '%';
        }

        // Enable/disable previous button
        if (prevBtn) {
            prevBtn.disabled = currentTab === 1;
        }

        // Update next button or show form buttons
        if (currentTab === TABS.length) {
            // Last tab - hide next button, show submit/reset
            if (nextBtn) nextBtn.style.display = 'none';
            if (formButtons) {
                formButtons.style.display = 'flex';
                formButtons.classList.add('show');
            }
        } else {
            // Not last tab - show next button, hide submit/reset
            if (nextBtn) nextBtn.style.display = 'flex';
            if (formButtons) {
                formButtons.style.display = 'none';
                formButtons.classList.remove('show');
            }
        }

        // Update tab button states
        document.querySelectorAll('.tab-button').forEach(btn => {
            const tabId = parseInt(btn.dataset.tab);
            
            if (enabledTabs.has(tabId)) {
                btn.disabled = false;
                btn.classList.add('enabled');
            }
            
            if (completedTabs.has(tabId)) {
                btn.classList.add('completed');
            }
        });
    }

    // Go to previous tab
    function goToPreviousTab() {
        if (currentTab > 1) {
            switchToTab(currentTab - 1);
        }
    }

    // Go to next tab with validation
    async function goToNextTab() {
        const isValid = await validateCurrentTab();
        
        if (isValid) {
            // Mark current tab as completed
            completedTabs.add(currentTab);
            
            // Enable next tab
            if (currentTab < TABS.length) {
                enabledTabs.add(currentTab + 1);
                switchToTab(currentTab + 1);
            }
        } else {
            // Validation failed - errors are already highlighted in the form
            console.log('Validation failed for tab', currentTab);
            
            // Scroll to first error field
            const firstError = document.querySelector('.field-error');
            if (firstError) {
                firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
        }
    }

    // Validate current tab
    async function validateCurrentTab() {
        const tabContent = document.querySelector(`[data-tab-content="${currentTab}"]`);
        if (!tabContent) return false;

        clearAllErrors(tabContent);

        let isValid = true;
        const errors = [];

        // Get all inputs in current tab
        const inputs = tabContent.querySelectorAll('input, select, textarea');

        for (const input of inputs) {
            // Skip disabled inputs
            if (input.disabled) continue;

            // Check required fields
            if (input.hasAttribute('required') || input.closest('[required]')) {
                if (!validateField(input)) {
                    isValid = false;
                    markFieldAsError(input);
                    errors.push(getFieldLabel(input));
                }
            }

            // Special validation for specific fields
            if (input.name && input.value) {
                const fieldValidation = validateSpecialField(input);
                if (!fieldValidation.valid) {
                    isValid = false;
                    markFieldAsError(input, fieldValidation.message);
                    errors.push(fieldValidation.message);
                }
            }
        }

        // Tab 5: Validate photo and signature uploads
        if (currentTab === 5) {
            const photoData = document.getElementById('photoData');
            const signatureData = document.getElementById('signatureData');

            if (!photoData || !photoData.value) {
                isValid = false;
                errors.push('Customer photo is required');
                const photoCard = document.querySelector('.upload-card:first-child');
                if (photoCard) photoCard.classList.add('field-error');
            }

            if (!signatureData || !signatureData.value) {
                isValid = false;
                errors.push('Customer signature is required');
                const signatureCard = document.querySelector('.upload-card:last-child');
                if (signatureCard) signatureCard.classList.add('field-error');
            }
        }

        // Validate radio button groups
        const radioGroups = getRadioGroups(tabContent);
        for (const [name, radios] of radioGroups) {
            const firstRadio = radios[0];
            if (firstRadio.hasAttribute('required')) {
                const isChecked = radios.some(r => r.checked);
                if (!isChecked) {
                    isValid = false;
                    radios.forEach(r => markFieldAsError(r));
                    errors.push(getFieldLabel(firstRadio));
                }
            }
        }

        if (!isValid) {
            console.log('Validation errors:', errors);
        }

        return isValid;
    }

    // Validate individual field
    function validateField(field) {
        if (field.type === 'radio') {
            const name = field.name;
            const group = document.querySelectorAll(`input[name="${name}"]`);
            return Array.from(group).some(r => r.checked);
        }

        if (field.type === 'checkbox') {
            return field.checked;
        }

        if (field.tagName === 'SELECT') {
            return field.value !== '' && field.value !== null;
        }

        if (field.type === 'email') {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return field.value.trim() !== '' && emailRegex.test(field.value);
        }

        return field.value.trim() !== '';
    }

    // Validate special fields with patterns
    function validateSpecialField(field) {
        const patterns = {
            mobileNo: { regex: /^[6-9][0-9]{9}$/, message: 'Invalid mobile number' },
            zip: { regex: /^[4-5][0-9]{5}$/, message: 'Invalid ZIP code' },
            pan: { regex: /^[A-Z]{5}[0-9]{4}[A-Z]{1}$/, message: 'Invalid PAN format' },
            aadhar: { regex: /^[0-9]{12}$/, message: 'Invalid Aadhar number' },
            gstinNo: { regex: /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/, message: 'Invalid GSTIN format' },
            email: { regex: /^[^\s@]+@[^\s@]+\.[^\s@]+$/, message: 'Invalid email format' }
        };

        if (patterns[field.name]) {
            const pattern = patterns[field.name];
            if (!pattern.regex.test(field.value)) {
                return { valid: false, message: pattern.message };
            }
        }

        return { valid: true };
    }

    // Get radio button groups
    function getRadioGroups(container) {
        const groups = new Map();
        const radios = container.querySelectorAll('input[type="radio"]');
        
        radios.forEach(radio => {
            if (!radio.disabled) {
                if (!groups.has(radio.name)) {
                    groups.set(radio.name, []);
                }
                groups.get(radio.name).push(radio);
            }
        });

        return groups;
    }

    // Mark field as error
    function markFieldAsError(field, message) {
        field.classList.add('field-error');
        
        // For radio buttons, mark the container
        if (field.type === 'radio') {
            const container = field.closest('.radio-group');
            if (container) {
                container.classList.add('field-error');
            }
        }

        // Add error message if provided
        if (message && !field.nextElementSibling?.classList.contains('error-message')) {
            const errorSpan = document.createElement('span');
            errorSpan.className = 'error-message';
            errorSpan.textContent = message;
            field.parentNode.insertBefore(errorSpan, field.nextSibling);
        }
    }

    // Clear all errors in container
    function clearAllErrors(container) {
        container.querySelectorAll('.field-error').forEach(el => {
            el.classList.remove('field-error');
        });
        container.querySelectorAll('.error-message').forEach(el => {
            el.remove();
        });
    }

    // Get field label
    function getFieldLabel(field) {
        const label = field.closest('div')?.querySelector('label');
        return label ? label.textContent.trim() : field.name || 'Field';
    }

    // Clear errors on input change
    function setupFieldListeners() {
        document.addEventListener('input', function(e) {
            if (e.target.matches('input, select, textarea')) {
                e.target.classList.remove('field-error');
                const errorMsg = e.target.parentNode.querySelector('.error-message');
                if (errorMsg) errorMsg.remove();
            }
        });

        document.addEventListener('change', function(e) {
            if (e.target.type === 'radio') {
                const container = e.target.closest('.radio-group');
                if (container) {
                    container.classList.remove('field-error');
                }
            }
        });
    }

    // Initialize on DOM ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            initializeTabs();
            setupFieldListeners();
        });
    } else {
        initializeTabs();
        setupFieldListeners();
    }

})();