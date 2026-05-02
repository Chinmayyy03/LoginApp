/**
 * loan-security-type-fill.js
 *
 * Drop this <script> block into loan.jsp AFTER the existing loadFormDropdowns IIFE.
 *
 * It watches for window._formDropdownData (set by the loader) and fills every
 * select[name] that ends with "SecurityType[]" using the already-loaded data,
 * eliminating the 10+ repeated DB round-trips in the JSP scriptlets.
 *
 * USAGE IN loan.jsp:
 *   1. Remove all the <%  PreparedStatement psSecType ... %>  scriptlet blocks
 *      that build <option> tags for Security Type inside each fieldset.
 *   2. Replace each <select name="...SecurityType[]"> with:
 *         <select name="xyzSecurityType[]" class="js-security-type" required>
 *           <option value="">-- Select --</option>
 *         </select>
 *   3. Include this script after the loadFormDropdowns block.
 */

(function fillSecurityTypeSelects() {
    // Selectors that should receive the security-type options.
    // Matches: securityTypeCode[], gsSecurityType[], sharesHolderSecurityType[],
    //          plantSecurityType[], motorSecurityType[], insSecurityType[], etc.
    var SEC_TYPE_NAME_PATTERN = /SecurityType\[\]$|securityTypeCode\[\]$/i;

    function doFill(data) {
        var items = data.securityType; // [{v:"...", l:"..."}] from OpenAccountFormLoader
        if (!Array.isArray(items) || !items.length) return;

        document.querySelectorAll('select').forEach(function (sel) {
            if (!SEC_TYPE_NAME_PATTERN.test(sel.name)) return;

            // Only fill if still showing the placeholder / empty
            if (sel.options.length > 1) return; // already populated

            // Keep the first "-- Select --" option, append the rest
            items.forEach(function (item) {
                var opt = document.createElement('option');
                opt.value       = item.v;
                opt.textContent = item.v; // security type codes are self-descriptive
                sel.appendChild(opt);
            });
        });
    }

    // If the loader already finished, fill immediately; otherwise poll briefly.
    if (window._formDropdownData) {
        doFill(window._formDropdownData);
    } else {
        var attempts = 0;
        var timer = setInterval(function () {
            if (window._formDropdownData) {
                clearInterval(timer);
                doFill(window._formDropdownData);
            } else if (++attempts > 40) { // give up after ~4 s
                clearInterval(timer);
            }
        }, 100);
    }
})();