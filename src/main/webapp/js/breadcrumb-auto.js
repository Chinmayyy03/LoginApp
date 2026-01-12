/**
 * AUTO-BREADCRUMB SYSTEM
 * Most pages work automatically - only add exceptions below
 */

// ============================================
// ONLY ADD PAGES WITH CUSTOM NAMES HERE
// ============================================
const PAGE_EXCEPTIONS = {
		// View Details pages
	    'Dashboard/viewCustomer.jsp': 'View Details',
	    'View/viewAccount.jsp': 'View Details',
	    'authViewCustomers.jsp': 'View Details',
	    
	    // Special formatting
	    'Dashboard/aTypeMember.jsp': 'A Type Member',
	    'Dashboard/bTypeMember.jsp': 'B Type Member',
	    'Dashboard/otherMember.jsp': 'OTHER',
	    
	    // Loan pages
	    'Dashboard/loadOverdue.jsp': 'Loan Overdue',
	    'Dashboard/loanNPA.jsp': 'Loan NPA',
	    'Dashboard/loanRegular.jsp': 'Loan Regular',
	    'Dashboard/personalLoan.jsp': 'Personal Loan',
	    'Dashboard/securedLoan.jsp': 'Secured Loan',
	    'Dashboard/unsecuredLoan.jsp': 'Unsecured Loan',
	    'Dashboard/totalLoan.jsp': 'Total Loan',
		
		'Transactions/transactions.jsp': 'Transactions',
		'View/totalAccounts.jsp': 'Total Accounts',
		
		// Authorization pages
		'authorizationPending.jsp': 'Authorization',
		'authorizationPendingCustomers.jsp': 'Customer List',
		'authorizationPendingApplications.jsp': 'Application List',
		'authViewCustomers.jsp': 'View Details',
		'authViewApplication.jsp': 'View Details',
		    
		// Other pages
		'addCustomer.jsp': 'Add Customer',
		'newApplication.jsp': 'Open Account',

	
	//Transactions
	
	
	// View
};

// ============================================
// AUTO-GENERATE TITLE FROM FILENAME
// ============================================
function autoGenerateTitle(filename) {
    return filename
        .replace(/([A-Z])/g, ' $1')
        .replace(/^./, str => str.toUpperCase())
        .trim();
}

// ============================================
// BUILD BREADCRUMB PATH
// ============================================
function buildBreadcrumbPath(pagePath, returnPage = null) {
    // Handle dynamic parent (for View Details pages)
    if (returnPage) {
        let parentBreadcrumb = buildBreadcrumbPath(returnPage);
        let currentTitle = PAGE_EXCEPTIONS[pagePath] || getPageTitle(pagePath);
        return parentBreadcrumb + ' > ' + currentTitle;
    }
    
    // Normal case: build from URL
    let parts = pagePath.replace('.jsp', '').split('/');
    
    return parts.map((part, index) => {
        let fullPath = parts.slice(0, index + 1).join('/') + '.jsp';
        return PAGE_EXCEPTIONS[fullPath] || autoGenerateTitle(part);
    }).join(' > ');
}

// ============================================
// GET PAGE TITLE
// ============================================
function getPageTitle(pagePath) {
    if (PAGE_EXCEPTIONS[pagePath]) {
        return PAGE_EXCEPTIONS[pagePath];
    }
    let filename = pagePath.replace('.jsp', '').split('/').pop();
    return autoGenerateTitle(filename);
}

// ============================================
// MAKE AVAILABLE GLOBALLY
// ============================================
window.buildBreadcrumbPath = buildBreadcrumbPath;
window.getPageTitle = getPageTitle;