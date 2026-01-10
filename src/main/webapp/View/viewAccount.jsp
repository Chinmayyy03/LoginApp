<%@ page import="java.sql.*, db.DBConnection, java.text.SimpleDateFormat, java.util.List, java.util.ArrayList, java.util.Map, java.util.HashMap" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // ✅ ADD THIS AT THE TOP - BEFORE ANY OTHER CODE
    String returnPage = request.getParameter("returnPage");
    if (returnPage == null || returnPage.trim().isEmpty()) {
        returnPage = "View/totalAccounts.jsp"; // default fallback
    }
%>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    String branchCode = (String) sess.getAttribute("branchCode");
%>
<%! 
    String getStringSafe(ResultSet r, String col) throws SQLException {
        String v = r.getString(col);
        return (v == null) ? "" : v;
    }
    
    String formatDateForInput(ResultSet r, String col) throws SQLException {
        java.sql.Timestamp ts = null;
        try {
            ts = r.getTimestamp(col);
        } catch (Exception ex) {
            try {
                java.sql.Date d = r.getDate(col);
                if (d != null) ts = new java.sql.Timestamp(d.getTime());
            } catch (Exception ignore) {}
        }
        if (ts == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(new java.util.Date(ts.getTime()));
    }
%>

<%
    String accountCode = request.getParameter("accountCode");
    if (accountCode == null || accountCode.trim().isEmpty()) {
        out.println("<h3 style='color:red;'>Account Code not provided.</h3>");
        return;
    }

    Connection conn = null;
    PreparedStatement psAccount = null, psNominee = null, psJoint = null, psGuarantor = null;
    PreparedStatement psDeposit = null, psLoan = null, psPigmy = null, psFixed = null;
    PreparedStatement psLandBuilding = null, psDepositSec = null, psGoldSilver = null;
    ResultSet rsAccount = null, rsNominee = null, rsJoint = null, rsGuarantor = null;
    ResultSet rsDeposit = null, rsLoan = null, rsPigmy = null, rsFixed = null;
    ResultSet rsLandBuilding = null, rsDepositSec = null, rsGoldSilver = null;

    try {
        conn = DBConnection.getConnection();
        
        // Fetch main account data
        psAccount = conn.prepareStatement("SELECT * FROM ACCOUNT.ACCOUNT WHERE ACCOUNT_CODE = ?");
        psAccount.setString(1, accountCode);
        rsAccount = psAccount.executeQuery();

        if (!rsAccount.next()) {
            out.println("<h3 style='color:red;'>No account found with code: " + accountCode + "</h3>");
            return;
        }
        
        // Extract product code from account code (5th, 6th, 7th digits)
        String productCode = "";
        if (accountCode.length() >= 7) {
            productCode = accountCode.substring(4, 7);
        }

    // ---- Joint Holder allowed product codes ----
    boolean showJointHolder = false;
    try {
        int pc = Integer.parseInt(productCode);

        if (
            pc == 101 || pc == 102 || pc == 103 || pc == 110 ||
            pc == 115 || pc == 116 || pc == 117 || pc == 118 ||
            pc == 119 || pc == 120 || pc == 121 || pc == 122 ||
            pc == 123 || pc == 151 || pc == 201 || pc == 210 ||
            pc == 211 || pc == 601 || pc == 615 || pc == 901 ||
            (pc >= 401 && pc <= 417) ||
            pc == 420 ||
            (pc >= 461 && pc <= 475) ||
            pc == 499
        ) {
            showJointHolder = true;
        }
    } catch (Exception e) {
        showJointHolder = false;
    }
    // ---- Co-Borrower NOT allowed for these product codes (same logic as application) ----
    boolean showCoBorrower = true;

    try {
        int pc = Integer.parseInt(productCode);

        if (
            pc == 101 || pc == 102 || pc == 103 || pc == 110 ||
            pc == 115 || pc == 116 || pc == 117 || pc == 118 ||
            pc == 119 || pc == 120 || pc == 121 || pc == 122 ||
            pc == 123 || pc == 151 || pc == 201 || pc == 210 ||
            pc == 211 || pc == 601 || pc == 615 || pc == 901 ||
            (pc >= 401 && pc <= 417) ||
            pc == 420 ||
            (pc >= 461 && pc <= 475) ||
            pc == 499
        ) {
            showCoBorrower = false;   // ❌ hide co-borrower
        }
    } catch (Exception e) {
        showCoBorrower = true;
    }
    
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>View Account — <%= accountCode %></title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/addCustomer.css">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/authViewCustomers.css">
  <script>
window.onload = function() {
    var returnPage = '<%= returnPage %>';
    var breadcrumb = 'View > Total Accounts > View Details';
    
    if (returnPage.includes('totalLoan.jsp')) {
        breadcrumb = 'Dashboard > Total Loan > View Details';
    } else if (returnPage.includes('totalAccounts.jsp')) {
        breadcrumb = 'View > Total Accounts > View Details';
    }
    else if (returnPage.includes('personalLoan.jsp')) {
        breadcrumb = 'Dashboard > Personal Loan > View Details';
    } else if (returnPage.includes('securedLoan.jsp')) {
        breadcrumb = 'Dashboard > Secured Loan > View Details';
    } else if (returnPage.includes('unsecuredLoan.jsp')) {
        breadcrumb = 'Dashboard > Unsecured Loan > View Details';
    }
    
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(breadcrumb);
    }
};

function goBackToList() {
    var returnPage = '<%= returnPage %>';
    var breadcrumb = 'View > Total Accounts';
    
    if (returnPage.includes('totalLoan.jsp')) {
        breadcrumb = 'Dashboard > Total Loan';
    } else if (returnPage.includes('totalAccounts.jsp')) {
        breadcrumb = 'View > Total Accounts';
    }
    else if (returnPage.includes('personalLoan.jsp')) {
        breadcrumb = 'Dashboard > Personal Loan';
    } else if (returnPage.includes('securedLoan.jsp')) {
        breadcrumb = 'Dashboard > Secured Loan';
    } else if (returnPage.includes('unsecuredLoan.jsp')) {
        breadcrumb = 'Dashboard > Unsecured Loan';
    }
    
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(breadcrumb);
    }
    
    window.location.href = '<%= request.getContextPath() %>/' + returnPage;
}
</script>
</head>
<body>

<form>
    <fieldset>
      <legend>Account Information</legend>
      <div class="form-grid">
        <div>
          <label>Account Code</label>
          <input readonly value="<%= accountCode %>">
        </div>
        <div>
          <label>Product Code</label>
          <input readonly value="<%= productCode %>">
        </div>
        <div>
          <label>Customer Name</label>
          <input readonly value="<%= getStringSafe(rsAccount,"NAME") %>">
        </div>
        <div>
          <label>Account Open Date</label>
          <input readonly value="<%= formatDateForInput(rsAccount,"DATEACCOUNTOPEN") %>">
        </div>
        <div>
          <label>Account Close Date</label>
          <input readonly value="<%= formatDateForInput(rsAccount,"DATEACCOUNTCLOSE") %>">
        </div>
        <div>
          <label>Customer ID</label>
          <input readonly value="<%= getStringSafe(rsAccount,"CUSTOMER_ID") %>">
        </div>
        <div>
          <label>Account Operation Capacity</label>
          <input readonly value="<%
            String accOpCapId = getStringSafe(rsAccount,"ACCOUNTOPERATIONCAPACITY_ID");
            String accOpCapDesc = "";
            if (!accOpCapId.isEmpty()) {
                PreparedStatement psAccOpCap = null;
                ResultSet rsAccOpCap = null;
                try {
                    psAccOpCap = conn.prepareStatement(
                        "SELECT DESCRIPTION FROM GLOBALCONFIG.ACCOUNTOPERATIONCAPACITY WHERE ACCOUNTOPERATIONCAPACITY_ID = ?"
                    );
                    psAccOpCap.setString(1, accOpCapId);
                    rsAccOpCap = psAccOpCap.executeQuery();
                    if (rsAccOpCap.next()) {
                        accOpCapDesc = rsAccOpCap.getString("DESCRIPTION");
                    }
                } catch (Exception e) {
                    accOpCapDesc = accOpCapId;
                } finally {
                    try { if (rsAccOpCap != null) rsAccOpCap.close(); } catch (Exception ex) {}
                    try { if (psAccOpCap != null) psAccOpCap.close(); } catch (Exception ex) {}
                }
            }
            out.print(accOpCapDesc.isEmpty() ? accOpCapId : accOpCapDesc);
          %>">
        </div>
        <div>
          <label>User ID</label>
          <input readonly value="<%= getStringSafe(rsAccount,"USER_ID") %>">
        </div>
        <div>
          <label>Agent ID</label>
          <input readonly value="<%= getStringSafe(rsAccount,"AGENT_ID") %>">
        </div>
        <div>
          <label>Account Min Balance ID</label>
          <input readonly value="<%= getStringSafe(rsAccount,"ACCOUNTMINBALANCE_ID") %>">
        </div>
        <div>
          <label>Last Operated Date</label>
          <input readonly value="<%= formatDateForInput(rsAccount,"LASTOPERATEDDATE") %>">
        </div>
        <div>
          <label>Account Status</label>
          <input readonly value="<%= getStringSafe(rsAccount,"ACCOUNT_STATUS") %>">
        </div>
        <div>
          <label>TOD Applicable</label>
          <input readonly value="<%= getStringSafe(rsAccount,"IS_TOD_APPLICABLE") %>">
        </div>
        <div>
          <label>TOD Interest Rate</label>
          <input readonly value="<%= getStringSafe(rsAccount,"TOD_INTEREST_RATE") %>">
        </div>
        <div>
          <label>TOD Interest</label>
          <input readonly value="<%= getStringSafe(rsAccount,"TOD_INTEREST") %>">
        </div>
        <div>
          <label>Officer ID</label>
          <input readonly value="<%= getStringSafe(rsAccount,"OFFICER_ID") %>">
        </div>
        <div>
          <label>Category Code</label>
          <input readonly value="<%= getStringSafe(rsAccount,"CATEGORY_CODE") %>">
        </div>
        <div>
          <label>Introducer Account Code</label>
          <input readonly value="<%= getStringSafe(rsAccount,"INTRODUCERACCOUNT_CODE") %>">
        </div>
        <div>
          <label>Application Number</label>
          <input readonly value="<%= getStringSafe(rsAccount,"APPLICATION_NUMBER") %>">
        </div>
        <div>
          <label>Introducer Name</label>
          <input readonly value="<%= getStringSafe(rsAccount,"INTRODUCER_NAME") %>">
        </div>
        <div>
          <label>Risk Category</label>
          <input readonly value="<%= getStringSafe(rsAccount,"RISKCATEGORY") %>">
        </div>
        <div>
          <label>Old Account Type</label>
          <input readonly value="<%= getStringSafe(rsAccount,"OLD_AC_TYPE") %>">
        </div>
        <div>
          <label>Old Account No</label>
          <input readonly value="<%= getStringSafe(rsAccount,"OLD_AC_NO") %>">
        </div>
        <div>
          <label>TOD Limit</label>
          <input readonly value="<%= getStringSafe(rsAccount,"TOD_LIMIT") %>">
        </div>
        <div>
          <label>TOD Date</label>
          <input readonly value="<%= formatDateForInput(rsAccount,"TOD_DATE") %>">
        </div>
        <div>
          <label>TOD Period</label>
          <input readonly value="<%= getStringSafe(rsAccount,"TOD_PERIOD") %>">
        </div>
        <div>
          <label>Old Account Name</label>
          <input readonly value="<%= getStringSafe(rsAccount,"OLD_ACC_NAME") %>">
        </div>
        <div>
          <label>Director ID</label>
          <input readonly value="<%= getStringSafe(rsAccount,"DIRECTOR_ID") %>">
        </div>
        <div>
          <label>Guardian Customer ID</label>
          <input readonly value="<%= getStringSafe(rsAccount,"GUARDIAN_CUSTOMER_ID") %>">
        </div>
        <div>
          <label>TRF HO</label>
          <input readonly value="<%= getStringSafe(rsAccount,"IS_TRF_HO") %>">
        </div>
        <div>
          <label>Application Serial No</label>
          <input readonly value="<%= getStringSafe(rsAccount,"APPLICATION_SERIAL_NO") %>">
        </div>
        <div>
          <label>Interest Received HO</label>
          <input readonly value="<%= getStringSafe(rsAccount,"INT_REC_HO") %>">
        </div>
        <div>
          <label>Interest Payable HO</label>
          <input readonly value="<%= getStringSafe(rsAccount,"INT_PAY_HO") %>">
        </div>
        <div>
          <label>Debit TRF HO</label>
          <input readonly value="<%= getStringSafe(rsAccount,"DEPR_TRF_HO") %>">
        </div>
        <div>
          <label>Final HO TRF</label>
          <input readonly value="<%= getStringSafe(rsAccount,"FINAL_HO_TRF") %>">
        </div>
        <div>
          <label>Fund Final</label>
          <input readonly value="<%= getStringSafe(rsAccount,"IS_FUND_FINAL") %>">
        </div>
        <div>
          <label>Dividend Interest Post To</label>
          <input readonly value="<%= getStringSafe(rsAccount,"DIVIDENT_INTEREST_POST_TO") %>">
        </div>
        <div>
          <label>Original Customer ID</label>
          <input readonly value="<%= getStringSafe(rsAccount,"ORG_CUSTOMER_ID") %>">
        </div>
        <div>
          <label>TOD Applicable Date</label>
          <input readonly value="<%= formatDateForInput(rsAccount,"TOD_APPLICABLE_DATE") %>">
        </div>
        <div>
          <label>Interest Category</label>
          <input readonly value="<%= getStringSafe(rsAccount,"INTEREST_CATEGORY") %>">
        </div>
      </div>
    </fieldset>

<%
    // Check for Term Deposit specific fields
    psDeposit = conn.prepareStatement(
        "SELECT * FROM ACCOUNT.ACCOUNTDEPOSIT WHERE ACCOUNT_CODE = ?"
    );
    psDeposit.setString(1, accountCode);
    rsDeposit = psDeposit.executeQuery();
    
    if (rsDeposit.next()) {
        String depositAmount = getStringSafe(rsDeposit, "DEPOSITAMOUNT");
        String maturityAmount = getStringSafe(rsDeposit, "MATURITYVALUE");
        String openDate = formatDateForInput(rsDeposit, "FROMDATE");
        String maturityDate = formatDateForInput(rsDeposit, "MATURITYDATE");
        
        if (!depositAmount.isEmpty() || !maturityAmount.isEmpty() || !openDate.isEmpty()) {
%>
    <fieldset>
      <legend>Term Deposit Details</legend>
      <div class="form-grid">
        <div>
          <label>Open Date</label>
          <input readonly value="<%= openDate %>">
        </div>
        <div>
          <label>Unit Of Period</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"UNITOFPERIOD") %>">
        </div>
        <div>
          <label>Period Of Deposit</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"PERIODOFDEPOSIT") %>">
        </div>
        <div>
          <label>Maturity Date</label>
          <input readonly value="<%= maturityDate %>">
        </div>
        <div>
          <label>Interest Rate</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"INTERESTRATE") %>">
        </div>
        <div>
          <label>Multiply Factor</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"MULTIPLYFACTOR") %>">
        </div>
        <div>
          <label>Credit Account Code</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"CREDITACCOUNT_CODE") %>">
        </div>
        <div>
          <label>Interest Paid</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"INTERESTPAID") %>">
        </div>
        <div>
          <label>Interest Payable</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"INTERESTPAYBLE") %>">
        </div>
        <div>
          <label>Amount In Matured Deposit</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"AMOUNTINMATUREDDEPOSIT") %>">
        </div>
        <div>
          <label>Pending Cash Interest</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"PENDINGCASHINTEREST") %>">
        </div>
        <div>
          <label>Last Interest Paid Date</label>
          <input readonly value="<%= formatDateForInput(rsDeposit,"LAST_INTEREST_PAID_DATE") %>">
        </div>
        <div>
          <label>Penal Interest Received</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"PENAL_INTEREST_RECEIVED") %>">
        </div>
        <div>
          <label>Category Code</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"CATEGORY_CODE") %>">
        </div>
        <div>
          <label>Lien Account Code</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"LIENACCOUNT_CODE") %>">
        </div>
        <div>
          <label>Lien Status</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"LIEN_STATUS") %>">
        </div>
        <div>
          <label>Process For Maturity</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"PROCESSFOR_MATURITY") %>">
        </div>
        <div>
          <label>Mature Transaction Date</label>
          <input readonly value="<%= formatDateForInput(rsDeposit,"MATURE_TRANSACTIONDATE") %>">
        </div>
        <div>
          <label>Opening RD Products</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"OPENING_RD_PRODUCTS") %>">
        </div>
        <div>
          <label>Opening Int Posted</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"OPENING_INT_POSTED") %>">
        </div>
        <div>
          <label>Name</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"NAME") %>">
        </div>
        <div>
          <label>Agent Branch Code</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"AGENT_BRANCH_CODE") %>">
        </div>
        <div>
          <label>Agent ID</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"AGENT_ID") %>">
        </div>
        <div>
          <label>TDS Applicable</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"IS_TDS_APPLICABLE") %>">
        </div>
        <div>
          <label>Birth Date</label>
          <input readonly value="<%= formatDateForInput(rsDeposit,"BIRTH_DATE") %>">
        </div>
        <div>
          <label>TDS Paid</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"TDS_PAID") %>">
        </div>
        <div>
          <label>TDS Payable</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"TDS_PAYABLE") %>">
        </div>
        <div>
          <label>AR Day Begin</label>
          <input readonly value="<%= getStringSafe(rsDeposit,"IS_AR_DAYBEGIN") %>">
        </div>
        <div>
          <label>Deposit Amount</label>
          <input readonly value="<%= depositAmount %>">
        </div>
        <div>
          <label>Maturity Amount</label>
          <input readonly value="<%= maturityAmount %>">
        </div>
      </div>
    </fieldset>
<%
        }
    }
    
    // Check for Loan Details
    psLoan = conn.prepareStatement(
        "SELECT * FROM ACCOUNT.ACCOUNTLOAN WHERE ACCOUNT_CODE = ?"
    );
    psLoan.setString(1, accountCode);
    rsLoan = psLoan.executeQuery();
    
    if (rsLoan.next()) {
        String sanctionAmount = getStringSafe(rsLoan, "SANCTIONAMOUNT");
        String limitAmount = getStringSafe(rsLoan, "LIMITAMOUNT");
        
        if (!sanctionAmount.isEmpty() || !limitAmount.isEmpty()) {
%>
    <fieldset>
      <legend>Loan Details</legend>
      <div class="form-grid">
        <div>
          <label>Sanction Authority Id</label>
          <input readonly value="<%= getStringSafe(rsLoan,"SANCTIONAUTHORITY_ID") %>">
        </div>
        <div>
          <label>Mode Of Sanction ID</label>
          <input readonly value="<%
            String modeOfSanId = getStringSafe(rsLoan,"MODEOFSANCTION_ID");
            String modeOfSanDesc = "";
            if (!modeOfSanId.isEmpty()) {
                PreparedStatement psModeOfSan = null;
                ResultSet rsModeOfSan = null;
                try {
                    psModeOfSan = conn.prepareStatement(
                        "SELECT DESCRIPTION FROM HEADOFFICE.MODEOFSANCTION WHERE MODEOFSANCTION_ID = ?"
                    );
                    psModeOfSan.setString(1, modeOfSanId);
                    rsModeOfSan = psModeOfSan.executeQuery();
                    if (rsModeOfSan.next()) {
                        modeOfSanDesc = rsModeOfSan.getString("DESCRIPTION");
                    }
                } catch (Exception e) {
                    modeOfSanDesc = modeOfSanId;
                } finally {
                    try { if (rsModeOfSan != null) rsModeOfSan.close(); } catch (Exception ex) {}
                    try { if (psModeOfSan != null) psModeOfSan.close(); } catch (Exception ex) {}
                }
            }
            out.print(modeOfSanDesc.isEmpty() ? modeOfSanId : modeOfSanDesc);
          %>">
        </div>
        <div>
          <label>Social Sector ID</label>
          <input readonly value="<%
            String socialSectorId = getStringSafe(rsLoan,"SOCIALSECTOR_ID");
            String socialSectorDesc = "";
            if (!socialSectorId.isEmpty()) {
                PreparedStatement psSocialSector = null;
                ResultSet rsSocialSector = null;
                try {
                    psSocialSector = conn.prepareStatement(
                        "SELECT DESCRIPTION FROM HEADOFFICE.SOCIALSECTOR WHERE SOCIALSECTOR_ID = ?"
                    );
                    psSocialSector.setString(1, socialSectorId);
                    rsSocialSector = psSocialSector.executeQuery();
                    if (rsSocialSector.next()) {
                        socialSectorDesc = rsSocialSector.getString("DESCRIPTION");
                    }
                } catch (Exception e) {
                    socialSectorDesc = socialSectorId;
                } finally {
                    try { if (rsSocialSector != null) rsSocialSector.close(); } catch (Exception ex) {}
                    try { if (psSocialSector != null) psSocialSector.close(); } catch (Exception ex) {}
                }
            }
            out.print(socialSectorDesc.isEmpty() ? socialSectorId : socialSectorDesc);
          %>">
        </div>
        <div>
          <label>Social Section ID</label>
          <input readonly value="<%
            String socialSecId = getStringSafe(rsLoan,"SOCIALSECTION_ID");
            String socialSecDesc = "";
            if (!socialSecId.isEmpty()) {
                PreparedStatement psSocialSec = null;
                ResultSet rsSocialSec = null;
                try {
                    psSocialSec = conn.prepareStatement(
                        "SELECT DESCRIPTION FROM GLOBALCONFIG.SOCIALSECTION WHERE SOCIALSECTION_ID = ?"
                    );
                    psSocialSec.setString(1, socialSecId);
                    rsSocialSec = psSocialSec.executeQuery();
                    if (rsSocialSec.next()) {
                        socialSecDesc = rsSocialSec.getString("DESCRIPTION");
                    }
                } catch (Exception e) {
                    socialSecDesc = socialSecId;
                } finally {
                    try { if (rsSocialSec != null) rsSocialSec.close(); } catch (Exception ex) {}
                    try { if (psSocialSec != null) psSocialSec.close(); } catch (Exception ex) {}
                }
            }
            out.print(socialSecDesc.isEmpty() ? socialSecId : socialSecDesc);
          %>">
        </div>
        <div>
          <label>Consortium Loan</label>
          <input readonly value="<%= getStringSafe(rsLoan,"IS_COMSORTIUML_LOAN") %>">
        </div>
        <div>
          <label>Drawing Power</label>
          <input readonly value="<%= getStringSafe(rsLoan,"DRAWINGPOWER") %>">
        </div>
        <div>
          <label>Period Of Loan</label>
          <input readonly value="<%= getStringSafe(rsLoan,"PERIODOFLOAN") %>">
        </div>
        <div>
          <label>Resolution Number</label>
          <input readonly value="<%= getStringSafe(rsLoan,"RESOLUTIONNUMBER") %>">
        </div>
        <div>
          <label>Classification ID</label>
          <input readonly value="<%
            String classificationId = getStringSafe(rsLoan,"CLASSIFICATION_ID");
            String classificationDesc = "";
            if (!classificationId.isEmpty()) {
                PreparedStatement psClassification = null;
                ResultSet rsClassification = null;
                try {
                    psClassification = conn.prepareStatement(
                        "SELECT DESCRIPTION FROM HEADOFFICE.CLASSIFICATION WHERE CLASSIFICATION_ID = ?"
                    );
                    psClassification.setString(1, classificationId);
                    rsClassification = psClassification.executeQuery();
                    if (rsClassification.next()) {
                        classificationDesc = rsClassification.getString("DESCRIPTION");
                    }
                } catch (Exception e) {
                    classificationDesc = classificationId;
                } finally {
                    try { if (rsClassification != null) rsClassification.close(); } catch (Exception ex) {}
                    try { if (psClassification != null) psClassification.close(); } catch (Exception ex) {}
                }
            }
            out.print(classificationDesc.isEmpty() ? classificationId : classificationDesc);
          %>">
        </div>
        <div>
          <label>Director ID</label>
          <input readonly value="<%= getStringSafe(rsLoan,"DIRECTOR_ID") %>">
        </div>
        <div>
          <label>MIS ID</label>
          <input readonly value="<%
            String misId = getStringSafe(rsLoan,"MIS_ID");
            String misDesc = "";
            if (!misId.isEmpty()) {
                PreparedStatement psMIS = null;
                ResultSet rsMIS = null;
                try {
                    psMIS = conn.prepareStatement(
                        "SELECT DESCRIPTION FROM HEADOFFICE.MIS WHERE MIS_ID = ?"
                    );
                    psMIS.setString(1, misId);
                    rsMIS = psMIS.executeQuery();
                    if (rsMIS.next()) {
                        misDesc = rsMIS.getString("DESCRIPTION");
                    }
                } catch (Exception e) {
                    misDesc = misId;
                } finally {
                    try { if (rsMIS != null) rsMIS.close(); } catch (Exception ex) {}
                    try { if (psMIS != null) psMIS.close(); } catch (Exception ex) {}
                }
            }
            out.print(misDesc.isEmpty() ? misId : misDesc);
          %>">
        </div>
        <div>
          <label>Limit Amount</label>
          <input readonly value="<%= limitAmount %>">
        </div>
        <div>
          <label>Sanction Amount</label>
          <input readonly value="<%= sanctionAmount %>">
        </div>
        <div>
          <label>Installment Amount</label>
          <input readonly value="<%= getStringSafe(rsLoan,"INSTALLMENTAMOUNT") %>">
        </div>
        <div>
          <label>Sanction Date</label>
          <input readonly value="<%= formatDateForInput(rsLoan,"SANCTIONDATE") %>">
        </div>
        <div>
          <label>Register Amount</label>
          <input readonly value="<%= getStringSafe(rsLoan,"REGISTERAMOUNT") %>">
        </div>
        <div>
          <label>Document Submission Date</label>
          <input readonly value="<%= formatDateForInput(rsLoan,"DOCUMENTSUBMISSIONDATE") %>">
        </div>
        <div>
          <label>Moratorium Period Month</label>
          <input readonly value="<%= getStringSafe(rsLoan,"MORATORIUMPEROIDMONTH") %>">
        </div>
        <div>
          <label>Date Of Registration</label>
          <input readonly value="<%= formatDateForInput(rsLoan,"DATEOFREGISTRATION") %>">
        </div>
        <div>
          <label>Purpose ID</label>
          <input readonly value="<%
            String purposeId = getStringSafe(rsLoan,"PURPOSE_ID");
            String purposeDesc = "";
            if (!purposeId.isEmpty()) {
                PreparedStatement psPurpose = null;
                ResultSet rsPurpose = null;
                try {
                    psPurpose = conn.prepareStatement(
                        "SELECT DESCRIPTION FROM HEADOFFICE.PURPOSE WHERE PURPOSE_ID = ?"
                    );
                    psPurpose.setString(1, purposeId);
                    rsPurpose = psPurpose.executeQuery();
                    if (rsPurpose.next()) {
                        purposeDesc = rsPurpose.getString("DESCRIPTION");
                    }
                } catch (Exception e) {
                    purposeDesc = purposeId;
                } finally {
                    try { if (rsPurpose != null) rsPurpose.close(); } catch (Exception ex) {}
                    try { if (psPurpose != null) psPurpose.close(); } catch (Exception ex) {}
                }
            }
            out.print(purposeDesc.isEmpty() ? purposeId : purposeDesc);
          %>">
        </div>
        <div>
          <label>Industry ID</label>
          <input readonly value="<%
            String industryId = getStringSafe(rsLoan,"INDUSTRY_ID");
            String industryDesc = "";
            if (!industryId.isEmpty()) {
                PreparedStatement psIndustry = null;
                ResultSet rsIndustry = null;
                try {
                    psIndustry = conn.prepareStatement(
                        "SELECT DESCRIPTION FROM HEADOFFICE.INDUSTRY WHERE INDUSTRY_ID = ?"
                    );
                    psIndustry.setString(1, industryId);
                    rsIndustry = psIndustry.executeQuery();
                    if (rsIndustry.next()) {
                        industryDesc = rsIndustry.getString("DESCRIPTION");
                    }
                } catch (Exception e) {
                    industryDesc = industryId;
                } finally {
                    try { if (rsIndustry != null) rsIndustry.close(); } catch (Exception ex) {}
                    try { if (psIndustry != null) psIndustry.close(); } catch (Exception ex) {}
                }
            }
            out.print(industryDesc.isEmpty() ? industryId : industryDesc);
          %>">
        </div>
        <div>
          <label>Repayment Frequency</label>
          <input readonly value="<%= getStringSafe(rsLoan,"REPAYMENTFREQUENCY") %>">
        </div>
        <div>
          <label>Installment Type ID</label>
          <input readonly value="<%
            String instTypeId = getStringSafe(rsLoan,"INSTALLMENTTYPE_ID");
            String instTypeDesc = "";
            if (!instTypeId.isEmpty()) {
                PreparedStatement psInstType = null;
                ResultSet rsInstType = null;
                try {
                    psInstType = conn.prepareStatement(
                        "SELECT INSTALLMENTTYPE FROM HEADOFFICE.INSTALLMENTTYPE WHERE INSTALLMENTTYPE_ID = ?"
                    );
                    psInstType.setString(1, instTypeId);
                    rsInstType = psInstType.executeQuery();
                    if (rsInstType.next()) {
                        instTypeDesc = rsInstType.getString("INSTALLMENTTYPE");
                    }
                } catch (Exception e) {
                    instTypeDesc = instTypeId;
                } finally {
                    try { if (rsInstType != null) rsInstType.close(); } catch (Exception ex) {}
                    try { if (psInstType != null) psInstType.close(); } catch (Exception ex) {}
                }
            }
            out.print(instTypeDesc.isEmpty() ? instTypeId : instTypeDesc);
          %>">
        </div>
        <div>
          <label>Principal Overdue</label>
          <input readonly value="<%= getStringSafe(rsLoan,"PRINCIPAL_OVERDUE") %>">
        </div>
        <div>
          <label>Interest Calculation Method</label>
          <input readonly value="<%= getStringSafe(rsLoan,"INTERESTCALCULATIONMETHOD") %>">
        </div>
        <div>
          <label>Principal Advance</label>
          <input readonly value="<%= getStringSafe(rsLoan,"PRINCIPAL_ADAVANCE") %>">
        </div>
        <div>
          <label>Last Date Of Penal Interest</label>
          <input readonly value="<%= formatDateForInput(rsLoan,"LASTDATEOFPENALINTEREST") %>">
        </div>
        <div>
          <label>Principal Installment</label>
          <input readonly value="<%= getStringSafe(rsLoan,"PRINCIPAL_INSTALLMENT") %>">
        </div>
        <div>
          <label>Last Date Of Overdue Interest</label>
          <input readonly value="<%= formatDateForInput(rsLoan,"LASTDATEOFOVERDUEINTEREST") %>">
        </div>
        <div>
          <label>Current Interest Rate</label>
          <input readonly value="<%= getStringSafe(rsLoan,"CURRENTINTERESTRATE") %>">
        </div>
        <div>
          <label>Last Date Of Penal Interest Charged</label>
          <input readonly value="<%= formatDateForInput(rsLoan,"LASTDATEOFPENALINTERESTCHARGED") %>">
        </div>
        <div>
          <label>Current Overdue Interest Rate</label>
          <input readonly value="<%= getStringSafe(rsLoan,"CURRENTOVERDUEINTERESTRATE") %>">
        </div>
        <div>
          <label>Total Interest Charged</label>
          <input readonly value="<%= getStringSafe(rsLoan,"TOTALINTERESTCHARGED") %>">
        </div>
        <div>
          <label>Current Penal Interest Rate</label>
          <input readonly value="<%= getStringSafe(rsLoan,"CURRENTPENALINTERESTRATE") %>">
        </div>
        <div>
          <label>Is Interest Charged</label>
          <input readonly value="<%= getStringSafe(rsLoan,"INTEREST_APPLY") %>">
        </div>
        <div>
          <label>Current Moratorium Interest Rate</label>
          <input readonly value="<%= getStringSafe(rsLoan,"CURRENTMORATORIUMINTERESTRATE") %>">
        </div>
        <div>
          <label>Unaccounted Interest</label>
          <input readonly value="<%= getStringSafe(rsLoan,"UNACCOUNTED_INTEREST") %>">
        </div>
        <div>
          <label>Interest Overdue</label>
          <input readonly value="<%= getStringSafe(rsLoan,"INTEREST_OVERDUE") %>">
        </div>
        <div>
          <label>Interest Receivable</label>
          <input readonly value="<%= getStringSafe(rsLoan,"INTEREST_RECEIVABLE") %>">
        </div>
        <div>
          <label>Overdue Interest Receivable</label>
          <input readonly value="<%= getStringSafe(rsLoan,"OVERDUE_INTEREST_RECEIVABLE") %>">
        </div>
        <div>
          <label>Pending Interest Received</label>
          <input readonly value="<%= getStringSafe(rsLoan,"PENDING_INTEREST_RECEIVED") %>">
        </div>
        <div>
          <label>Unaccounted Interest Received</label>
          <input readonly value="<%= getStringSafe(rsLoan,"UNACCOUNTED_INTEREST_RECEIVED") %>">
        </div>
        <div>
          <label>Penal Arrears</label>
          <input readonly value="<%= getStringSafe(rsLoan,"PENAL_ARRIERS") %>">
        </div>
        <div>
          <label>Moratorium Interest Arrears</label>
          <input readonly value="<%= getStringSafe(rsLoan,"MORATORIUM_ARRIERS") %>">
        </div>
        <div>
          <label>Normal Arrears</label>
          <input readonly value="<%= getStringSafe(rsLoan,"NORMAL_ARRIERS") %>">
        </div>
        <div>
          <label>Overdue Arrears</label>
          <input readonly value="<%= getStringSafe(rsLoan,"OVERDUE_ARRIERS") %>">
        </div>
        <div>
          <label>Other Charges</label>
          <input readonly value="<%= getStringSafe(rsLoan,"OTHER_CHARGES") %>">
        </div>
        <div>
          <label>Insurance</label>
          <input readonly value="<%= getStringSafe(rsLoan,"INSURANCE") %>">
        </div>
        <div>
          <label>Notice Fees</label>
          <input readonly value="<%= getStringSafe(rsLoan,"NOTICE_FEES") %>">
        </div>
        <div>
          <label>Court Charges</label>
          <input readonly value="<%= getStringSafe(rsLoan,"COURT_CHARGES") %>">
        </div>
        <div>
          <label>Recovery Expenses</label>
          <input readonly value="<%= getStringSafe(rsLoan,"RECOVERY_EXPENSES") %>">
        </div>
        <div>
          <label>Disbursed Amount</label>
          <input readonly value="<%= getStringSafe(rsLoan,"DISBURESED_AMOUNT") %>">
        </div>
        <div>
          <label>Is Standard</label>
          <input readonly value="<%= getStringSafe(rsLoan,"IS_STANDARD") %>">
        </div>
        <div>
          <label>Suit</label>
          <input readonly value="<%= getStringSafe(rsLoan,"SUIT") %>">
        </div>
        <div>
          <label>Health Code</label>
          <input readonly value="<%= getStringSafe(rsLoan,"HEALTH_CODE") %>">
        </div>
        <div>
          <label>Is Loss Asset</label>
          <input readonly value="<%= getStringSafe(rsLoan,"IS_LOSS_ASSET") %>">
        </div>
        <div>
          <label>Principal Amount</label>
          <input readonly value="<%= getStringSafe(rsLoan,"PRINCIPLE_AMOUNT") %>">
        </div>
        <div>
          <label>Is Bank Insurance Apply</label>
          <input readonly value="<%= getStringSafe(rsLoan,"IS_BANK_INSURANCE_APPL") %>">
        </div>
        <div>
          <label>Bank Insurance Start Date</label>
          <input readonly value="<%= formatDateForInput(rsLoan,"BANK_INSURANCE_START_DATE") %>">
        </div>
        <div>
          <label>Bank Insurance Percentage</label>
          <input readonly value="<%= getStringSafe(rsLoan,"BANK_INSURANCE_PERCENTAGE") %>">
        </div>
      </div>
    </fieldset>
<%
        }
    }

    // Check for Pigmy Details
    psPigmy = conn.prepareStatement(
        "SELECT * FROM ACCOUNT.ACCOUNTPIGMY WHERE ACCOUNT_CODE = ?"
    );
    psPigmy.setString(1, accountCode);
    rsPigmy = psPigmy.executeQuery();
    
    if (rsPigmy.next()) {
        String agentId = getStringSafe(rsPigmy, "AGENT_ID");
        String installmentAmount = getStringSafe(rsPigmy, "INSTALLMENTAMOUNT");
        
        if (!agentId.isEmpty() || !installmentAmount.isEmpty()) {
%>
    <fieldset>
      <legend>Pigmy Details</legend>
      <div class="form-grid">
        <div>
          <label>Agent Branch Code</label>
          <input readonly value="<%= getStringSafe(rsPigmy,"AGENTBRANCH_CODE") %>">
        </div>
        <div>
          <label>Open Date</label>
          <input readonly value="<%= formatDateForInput(rsPigmy,"FROMDATE") %>">
        </div>
        <div>
          <label>Installment Amount</label>
          <input readonly value="<%= installmentAmount %>">
        </div>
        <div>
          <label>Unit Of Period</label>
          <input readonly value="<%= getStringSafe(rsPigmy,"UNITOFPERIOD") %>">
        </div>
        <div>
          <label>Period Of Deposit</label>
          <input readonly value="<%= getStringSafe(rsPigmy,"PERIODOFDEPOSIT") %>">
        </div>
        <div>
          <label>Maturity Date</label>
          <input readonly value="<%= formatDateForInput(rsPigmy,"MATURITYDATE") %>">
        </div>
        <div>
          <label>Agent ID</label>
          <input readonly value="<%= agentId %>">
        </div>
        <div>
          <label>Interest Rate</label>
          <input readonly value="<%= getStringSafe(rsPigmy,"INTERESTRATE") %>">
        </div>
        <div>
          <label>Created Date</label>
          <input readonly value="<%= formatDateForInput(rsPigmy,"CREATED_DATE") %>">
        </div>
        <div>
          <label>Modified Date</label>
          <input readonly value="<%= formatDateForInput(rsPigmy,"MODIFIED_DATE") %>">
        </div>
        <div>
          <label>Lien Account Code</label>
          <input readonly value="<%= getStringSafe(rsPigmy,"LIENACCOUNT_CODE") %>">
        </div>
        <div>
          <label>Lien Status</label>
          <input readonly value="<%= getStringSafe(rsPigmy,"LIEN_STATUS") %>">
        </div>
        <div>
          <label>Opening PG Products</label>
          <input readonly value="<%= getStringSafe(rsPigmy,"OPENING_PG_PRODUCTS") %>">
        </div>
        <div>
          <label>Installment Frequency</label>
          <input readonly value="<%= getStringSafe(rsPigmy,"INSTALLMENTFREQUENCY") %>">
        </div>
        <div>
          <label>Is Agent Account</label>
          <input readonly value="<%= getStringSafe(rsPigmy,"IS_AGENT_ACCOUNT") %>">
        </div>
      </div>
    </fieldset>
<%
        }
    }

    // Check for Fixed Asset Details
    psFixed = conn.prepareStatement(
        "SELECT * FROM ACCOUNT.ACCOUNTFIXEDASSET WHERE ACCOUNT_CODE = ?"
    );
    psFixed.setString(1, accountCode);
    rsFixed = psFixed.executeQuery();
    
    if (rsFixed.next()) {
        String itemName = getStringSafe(rsFixed, "ITEM_NAME");
        String purchaseAmount = getStringSafe(rsFixed, "PURCHASEAMOUNT");
        
        if (!itemName.isEmpty() || !purchaseAmount.isEmpty()) {
%>
    <fieldset>
      <legend>Fixed Asset Details</legend>
      <div class="form-grid">
        <div>
          <label>Item Name</label>
          <input readonly value="<%= itemName %>">
        </div>
        <div>
          <label>Purchase Date</label>
          <input readonly value="<%= formatDateForInput(rsFixed,"PURCHASEDATE") %>">
        </div>
        <div>
          <label>Purchase Amount</label>
          <input readonly value="<%= purchaseAmount %>">
        </div>
        <div>
          <label>Number Of Item</label>
          <input readonly value="<%= getStringSafe(rsFixed,"NUMBEROFITEM") %>">
        </div>
        <div>
          <label>Depreciation Rate</label>
          <input readonly value="<%= getStringSafe(rsFixed,"DEPRICATIONRATE") %>">
        </div>
        <div>
          <label>Bill Number</label>
          <input readonly value="<%= getStringSafe(rsFixed,"BILLNUMBER") %>">
        </div>
        <div>
          <label>Description</label>
          <input readonly value="<%= getStringSafe(rsFixed,"DESCRIPTION") %>">
        </div>
        <div>
          <label>Method Of Depreciation</label>
          <input readonly value="<%= getStringSafe(rsFixed,"METHOD_OF_DEP_CAL") %>">
        </div>
        <div>
          <label>Depreciation Calculate On</label>
          <input readonly value="<%= getStringSafe(rsFixed,"DEPRICATION_CALCULATE_ON") %>">
        </div>
        <div>
          <label>Created Date</label>
          <input readonly value="<%= formatDateForInput(rsFixed,"CREATD_DATE") %>">
        </div>
        <div>
          <label>Modified Date</label>
          <input readonly value="<%= formatDateForInput(rsFixed,"MODIFIED_DATE") %>">
        </div>
      </div>
    </fieldset>
<%
        }
    }

    // Check for Nominee Details
    psNominee = conn.prepareStatement("SELECT * FROM ACCOUNT.ACCOUNTNOMINEE WHERE ACCOUNT_CODE = ? ORDER BY SERIAL_NUMBER");
    psNominee.setString(1, accountCode);
    rsNominee = psNominee.executeQuery();
    
    List<Map<String, String>> nominees = new ArrayList<>();
    while (rsNominee.next()) {
        Map<String, String> nominee = new HashMap<>();
        nominee.put("NAME", getStringSafe(rsNominee, "NAME"));
        nominee.put("RELATION_ID", getStringSafe(rsNominee, "RELATION_ID"));
        nominee.put("ADDRESS1", getStringSafe(rsNominee, "ADDRESS1"));
        nominee.put("ADDRESS2", getStringSafe(rsNominee, "ADDRESS2"));
        nominee.put("ADDRESS3", getStringSafe(rsNominee, "ADDRESS3"));
        nominee.put("CITY_CODE", getStringSafe(rsNominee, "CITY_CODE"));
        nominee.put("STATE_CODE", getStringSafe(rsNominee, "STATE_CODE"));
        nominee.put("COUNTRY_CODE", getStringSafe(rsNominee, "COUNTRY_CODE"));
        nominee.put("ZIP", getStringSafe(rsNominee, "ZIP"));
        nominees.add(nominee);
    }
    
    if (!nominees.isEmpty()) {
%>
    <fieldset>
      <legend>Nominee Details</legend>
      <%
        for (int i = 0; i < nominees.size(); i++) {
            Map<String, String> nominee = nominees.get(i);
      %>
      <div class="nominee-card" style="background: #e8e4fc; border: 1px solid #d0d0d0; border-radius: 10px; padding: 15px; margin-top: 15px;">
        <h4 style="color: #373279; margin-bottom: 10px;">Nominee <%= (i+1) %></h4>
        <div class="personal-grid">
          <div>
            <label>Name</label>
            <input readonly value="<%= nominee.get("NAME") %>">
          </div>
          <div>
            <label>Relation</label>
            <input readonly value="<%
              String relationId = nominee.get("RELATION_ID");
              String relationDesc = "";
              if (!relationId.isEmpty()) {
                  PreparedStatement psRelation = null;
                  ResultSet rsRelation = null;
                  try {
                      psRelation = conn.prepareStatement(
                          "SELECT DESCRIPTION FROM GLOBALCONFIG.RELATION WHERE RELATION_ID = ?"
                      );
                      psRelation.setString(1, relationId);
                      rsRelation = psRelation.executeQuery();
                      if (rsRelation.next()) {
                          relationDesc = rsRelation.getString("DESCRIPTION");
                      }
                  } catch (Exception e) {
                      relationDesc = relationId;
                  } finally {
                      try { if (rsRelation != null) rsRelation.close(); } catch (Exception ex) {}
                      try { if (psRelation != null) psRelation.close(); } catch (Exception ex) {}
                  }
              }
              out.print(relationDesc.isEmpty() ? relationId : relationDesc);
            %>">
          </div>
          <div>
            <label>Address 1</label>
            <input readonly value="<%= nominee.get("ADDRESS1") %>">
          </div>
          <div>
            <label>Address 2</label>
            <input readonly value="<%= nominee.get("ADDRESS2") %>">
          </div>
          <div>
            <label>Address 3</label>
            <input readonly value="<%= nominee.get("ADDRESS3") %>">
          </div>
          <div>
            <label>City</label>
            <input readonly value="<%
              String cityCode = nominee.get("CITY_CODE");
              String cityName = "";
              if (!cityCode.isEmpty()) {
                  PreparedStatement psCity = null;
                  ResultSet rsCity = null;
                  try {
                      psCity = conn.prepareStatement(
                          "SELECT NAME FROM GLOBALCONFIG.CITY WHERE CITY_CODE = ?"
                      );
                      psCity.setString(1, cityCode);
                      rsCity = psCity.executeQuery();
                      if (rsCity.next()) {
                          cityName = rsCity.getString("NAME");
                      }
                  } catch (Exception e) {
                      cityName = cityCode;
                  } finally {
                      try { if (rsCity != null) rsCity.close(); } catch (Exception ex) {}
                      try { if (psCity != null) psCity.close(); } catch (Exception ex) {}
                  }
              }
              out.print(cityName.isEmpty() ? cityCode : cityName);
            %>">
          </div>
          <div>
            <label>State</label>
            <input readonly value="<%
              String stateCode = nominee.get("STATE_CODE");
              String stateName = "";
              if (!stateCode.isEmpty()) {
                  PreparedStatement psState = null;
                  ResultSet rsState = null;
                  try {
                      psState = conn.prepareStatement(
                          "SELECT NAME FROM GLOBALCONFIG.STATE WHERE STATE_CODE = ?"
                      );
                      psState.setString(1, stateCode);
                      rsState = psState.executeQuery();
                      if (rsState.next()) {
                          stateName = rsState.getString("NAME");
                      }
                  } catch (Exception e) {
                      stateName = stateCode;
                  } finally {
                      try { if (rsState != null) rsState.close(); } catch (Exception ex) {}
                      try { if (psState != null) psState.close(); } catch (Exception ex) {}
                  }
              }
              out.print(stateName.isEmpty() ? stateCode : stateName);
            %>">
          </div>
          <div>
            <label>Country</label>
            <input readonly value="<%
              String countryCode = nominee.get("COUNTRY_CODE");
              String countryName = "";
              if (!countryCode.isEmpty()) {
                  PreparedStatement psCountry = null;
                  ResultSet rsCountry = null;
                  try {
                      psCountry = conn.prepareStatement(
                          "SELECT NAME FROM GLOBALCONFIG.COUNTRY WHERE COUNTRY_CODE = ?"
                      );
                      psCountry.setString(1, countryCode);
                      rsCountry = psCountry.executeQuery();
                      if (rsCountry.next()) {
                          countryName = rsCountry.getString("NAME");
                      }
                  } catch (Exception e) {
                      countryName = countryCode;
                  } finally {
                      try { if (rsCountry != null) rsCountry.close(); } catch (Exception ex) {}
                      try { if (psCountry != null) psCountry.close(); } catch (Exception ex) {}
                  }
              }
              out.print(countryName.isEmpty() ? countryCode : countryName);
            %>">
          </div>
          <div>
            <label>ZIP</label>
            <input readonly value="<%= nominee.get("ZIP") %>">
          </div>
        </div>
      </div>
      <%
        }
      %>
    </fieldset>
<%
    }
    // Check for Co-Borrower Details (using same ACCOUNTJOINTHOLDER table)
    if (showCoBorrower) {
        PreparedStatement psCoBorrower = conn.prepareStatement("SELECT * FROM ACCOUNT.ACCOUNTJOINTHOLDER WHERE ACCOUNT_CODE = ? ORDER BY SERIAL_NUMBER");
        psCoBorrower.setString(1, accountCode);
        ResultSet rsCoBorrower = psCoBorrower.executeQuery();
        
        List<Map<String, String>> coBorrowers = new ArrayList<>();
        while (rsCoBorrower.next()) {
            Map<String, String> coBorrower = new HashMap<>();
            coBorrower.put("CUSTOMER_ID", getStringSafe(rsCoBorrower, "CUSTOMER_ID"));
            coBorrower.put("SALUTATION_CODE", getStringSafe(rsCoBorrower, "SALUTATION_CODE"));
            coBorrower.put("NAME", getStringSafe(rsCoBorrower, "NAME"));
            coBorrower.put("ADDRESS1", getStringSafe(rsCoBorrower, "ADDRESS1"));
            coBorrower.put("ADDRESS2", getStringSafe(rsCoBorrower, "ADDRESS2"));
            coBorrower.put("ADDRESS3", getStringSafe(rsCoBorrower, "ADDRESS3"));
            coBorrower.put("CITY_CODE", getStringSafe(rsCoBorrower, "CITY_CODE"));
            coBorrower.put("STATE_CODE", getStringSafe(rsCoBorrower, "STATE_CODE"));
            coBorrower.put("COUNTRY_CODE", getStringSafe(rsCoBorrower, "COUNTRY_CODE"));
            coBorrower.put("ZIP", getStringSafe(rsCoBorrower, "ZIP"));
            coBorrower.put("GENDER", getStringSafe(rsCoBorrower, "GENDER"));
            coBorrower.put("BIRTH_DATE", formatDateForInput(rsCoBorrower, "BIRTH_DATE"));
            coBorrower.put("RELATION", getStringSafe(rsCoBorrower, "RELATION"));
            coBorrower.put("PHONE_NUMBER", getStringSafe(rsCoBorrower, "PHONE_NUMBER"));
            coBorrower.put("PAN_NUMBER", getStringSafe(rsCoBorrower, "PAN_NUMBER"));
            coBorrowers.add(coBorrower);
        }
        
        if (!coBorrowers.isEmpty()) {
%>
    <fieldset>
      <legend>Co-Borrower Details</legend>
      <%
        for (int i = 0; i < coBorrowers.size(); i++) {
            Map<String, String> coBorrower = coBorrowers.get(i);
      %>
      <div class="nominee-card" style="background: #e8e4fc; border: 1px solid #d0d0d0; border-radius: 10px; padding: 15px; margin-top: 15px;">
        <h4 style="color: #373279; margin-bottom: 10px;">Co-Borrower <%= (i+1) %></h4>
        <div class="personal-grid">
          <% if (!coBorrower.get("CUSTOMER_ID").isEmpty()) { %>
          <div>
            <label>Customer ID</label>
            <input readonly value="<%= coBorrower.get("CUSTOMER_ID") %>">
          </div>
          <% } %>
          <div>
            <label>Salutation</label>
            <input readonly value="<%= coBorrower.get("SALUTATION_CODE") %>">
          </div>
          <div>
            <label>Name</label>
            <input readonly value="<%= coBorrower.get("NAME") %>">
          </div>
          <div>
            <label>Gender</label>
            <input readonly value="<%= coBorrower.get("GENDER") %>">
          </div>
          <div>
            <label>Birth Date</label>
            <input readonly value="<%= coBorrower.get("BIRTH_DATE") %>">
          </div>
          <div>
            <label>Relation</label>
            <input readonly value="<%= coBorrower.get("RELATION") %>">
          </div>
          <div>
            <label>Phone Number</label>
            <input readonly value="<%= coBorrower.get("PHONE_NUMBER") %>">
          </div>
          <div>
            <label>PAN Number</label>
            <input readonly value="<%= coBorrower.get("PAN_NUMBER") %>">
          </div>
          <div>
            <label>Address 1</label>
            <input readonly value="<%= coBorrower.get("ADDRESS1") %>">
          </div>
          <div>
            <label>Address 2</label>
            <input readonly value="<%= coBorrower.get("ADDRESS2") %>">
          </div>
          <div>
            <label>Address 3</label>
            <input readonly value="<%= coBorrower.get("ADDRESS3") %>">
          </div>
          <div>
            <label>City</label>
            <input readonly value="<%
              String cbCityCode = coBorrower.get("CITY_CODE");
              String cbCityName = "";
              if (!cbCityCode.isEmpty()) {
                  PreparedStatement psCbCity = null;
                  ResultSet rsCbCity = null;
                  try {
                      psCbCity = conn.prepareStatement(
                          "SELECT NAME FROM GLOBALCONFIG.CITY WHERE CITY_CODE = ?"
                      );
                      psCbCity.setString(1, cbCityCode);
                      rsCbCity = psCbCity.executeQuery();
                      if (rsCbCity.next()) {
                          cbCityName = rsCbCity.getString("NAME");
                      }
                  } catch (Exception e) {
                      cbCityName = cbCityCode;
                  } finally {
                      try { if (rsCbCity != null) rsCbCity.close(); } catch (Exception ex) {}
                      try { if (psCbCity != null) psCbCity.close(); } catch (Exception ex) {}
                  }
              }
              out.print(cbCityName.isEmpty() ? cbCityCode : cbCityName);
            %>">
          </div>
          <div>
            <label>State</label>
            <input readonly value="<%
              String cbStateCode = coBorrower.get("STATE_CODE");
              String cbStateName = "";
              if (!cbStateCode.isEmpty()) {
                  PreparedStatement psCbState = null;
                  ResultSet rsCbState = null;
                  try {
                      psCbState = conn.prepareStatement(
                          "SELECT NAME FROM GLOBALCONFIG.STATE WHERE STATE_CODE = ?"
                      );
                      psCbState.setString(1, cbStateCode);
                      rsCbState = psCbState.executeQuery();
                      if (rsCbState.next()) {
                          cbStateName = rsCbState.getString("NAME");
                      }
                  } catch (Exception e) {
                      cbStateName = cbStateCode;
                  } finally {
                      try { if (rsCbState != null) rsCbState.close(); } catch (Exception ex) {}
                      try { if (psCbState != null) psCbState.close(); } catch (Exception ex) {}
                  }
              }
              out.print(cbStateName.isEmpty() ? cbStateCode : cbStateName);
            %>">
          </div>
          <div>
            <label>Country</label>
            <input readonly value="<%
              String cbCountryCode = coBorrower.get("COUNTRY_CODE");
              String cbCountryName = "";
              if (!cbCountryCode.isEmpty()) {
                  PreparedStatement psCbCountry = null;
                  ResultSet rsCbCountry = null;
                  try {
                      psCbCountry = conn.prepareStatement(
                          "SELECT NAME FROM GLOBALCONFIG.COUNTRY WHERE COUNTRY_CODE = ?"
                      );
                      psCbCountry.setString(1, cbCountryCode);
                      rsCbCountry = psCbCountry.executeQuery();
                      if (rsCbCountry.next()) {
                          cbCountryName = rsCbCountry.getString("NAME");
                      }
                  } catch (Exception e) {
                      cbCountryName = cbCountryCode;
                  } finally {
                      try { if (rsCbCountry != null) rsCbCountry.close(); } catch (Exception ex) {}
                      try { if (psCbCountry != null) psCbCountry.close(); } catch (Exception ex) {}
                  }
              }
              out.print(cbCountryName.isEmpty() ? cbCountryCode : cbCountryName);
            %>">
          </div>
          <div>
            <label>ZIP</label>
            <input readonly value="<%= coBorrower.get("ZIP") %>">
          </div>
        </div>
      </div>
      <%
        }
      %>
    </fieldset>
<%
        }
        try { if (rsCoBorrower != null) rsCoBorrower.close(); } catch (Exception ex) {}
        try { if (psCoBorrower != null) psCoBorrower.close(); } catch (Exception ex) {}
    }

    // Check for Land & Building Details
    psLandBuilding = conn.prepareStatement("SELECT * FROM ACCOUNT.ACCOUNTSECURITYLANDBUILDING WHERE ACCOUNT_CODE = ? ORDER BY SERIAL_NUMBER");
    psLandBuilding.setString(1, accountCode);
    rsLandBuilding = psLandBuilding.executeQuery();
    
    List<Map<String, String>> landBuildings = new ArrayList<>();
    while (rsLandBuilding.next()) {
        Map<String, String> lb = new HashMap<>();
        lb.put("SECURITYTYPE_CODE", getStringSafe(rsLandBuilding, "SECURITYTYPE_CODE"));
        lb.put("SUBMISSION_DATE", formatDateForInput(rsLandBuilding, "SUBMISSION_DATE"));
        lb.put("VALUEDAMOUNT", getStringSafe(rsLandBuilding, "VALUEDAMOUNT"));
        lb.put("MARGINEPERCENTAGE", getStringSafe(rsLandBuilding, "MARGINEPERCENTAGE"));
        lb.put("AREA", getStringSafe(rsLandBuilding, "AREA"));
        lb.put("UNITOFAREA", getStringSafe(rsLandBuilding, "UNITOFAREA"));
        lb.put("LOCATION", getStringSafe(rsLandBuilding, "LOCATION"));
        lb.put("SECURITYVALUE", getStringSafe(rsLandBuilding, "SECURITYVALUE"));
        lb.put("REMARK", getStringSafe(rsLandBuilding, "REMARK"));
        lb.put("PARTICULAR", getStringSafe(rsLandBuilding, "PARTICULAR"));
        lb.put("EAST", getStringSafe(rsLandBuilding, "EAST"));
        lb.put("WEST", getStringSafe(rsLandBuilding, "WEST"));
        lb.put("NORTH", getStringSafe(rsLandBuilding, "NORTH"));
        lb.put("SOUTH", getStringSafe(rsLandBuilding, "SOUTH"));
        lb.put("ENGINEER_NAME", getStringSafe(rsLandBuilding, "ENGINEER_NAME"));
        lb.put("CREATED_DATE", formatDateForInput(rsLandBuilding, "CREATED_DATE"));
        lb.put("MODIFIED_DATE", formatDateForInput(rsLandBuilding, "MODIFIED_DATE"));
        landBuildings.add(lb);
    }
    
    if (!landBuildings.isEmpty()) {
%>
    <fieldset>
      <legend>Land & Building Details</legend>
      <%
        for (int i = 0; i < landBuildings.size(); i++) {
            Map<String, String> lb = landBuildings.get(i);
      %>
      <div class="nominee-card" style="background: #e8e4fc; border: 1px solid #d0d0d0; border-radius: 10px; padding: 15px; margin-top: 15px;">
        <h4 style="color: #373279; margin-bottom: 10px;">Land & Building <%= (i+1) %></h4>
        <div class="form-grid">
          <div>
            <label>Security Type</label>
            <input readonly value="<%
              String lbSecTypeCode = lb.get("SECURITYTYPE_CODE");
              String lbSecTypeDesc = "";
              if (!lbSecTypeCode.isEmpty()) {
                  PreparedStatement psLbSecType = null;
                  ResultSet rsLbSecType = null;
                  try {
                      psLbSecType = conn.prepareStatement(
                          "SELECT DESCRIPTION FROM GLOBALCONFIG.SECURITYTYPE WHERE SECURITYTYPE_CODE = ?"
                      );
                      psLbSecType.setString(1, lbSecTypeCode);
                      rsLbSecType = psLbSecType.executeQuery();
                      if (rsLbSecType.next()) {
                          lbSecTypeDesc = rsLbSecType.getString("DESCRIPTION");
                      }
                  } catch (Exception e) {
                      lbSecTypeDesc = lbSecTypeCode;
                  } finally {
                      try { if (rsLbSecType != null) rsLbSecType.close(); } catch (Exception ex) {}
                      try { if (psLbSecType != null) psLbSecType.close(); } catch (Exception ex) {}
                  }
              }
              out.print(lbSecTypeDesc.isEmpty() ? lbSecTypeCode : lbSecTypeDesc);
            %>">
          </div>
          <div>
            <label>Submission Date</label>
            <input readonly value="<%= lb.get("SUBMISSION_DATE") %>">
          </div>
          <div>
            <label>Amount Valued</label>
            <input readonly value="<%= lb.get("VALUEDAMOUNT") %>">
          </div>
          <div>
            <label>Margin %</label>
            <input readonly value="<%= lb.get("MARGINEPERCENTAGE") %>">
          </div>
          <div>
            <label>Area</label>
            <input readonly value="<%= lb.get("AREA") %>">
          </div>
          <div>
            <label>Unit Of Area</label>
            <input readonly value="<%= lb.get("UNITOFAREA") %>">
          </div>
          <div>
            <label>Location</label>
            <input readonly value="<%= lb.get("LOCATION") %>">
          </div>
          <div>
            <label>Security Value</label>
            <input readonly value="<%= lb.get("SECURITYVALUE") %>">
          </div>
          <div>
            <label>Remark</label>
            <input readonly value="<%= lb.get("REMARK") %>">
          </div>
          <div>
            <label>East</label>
            <input readonly value="<%= lb.get("EAST") %>">
          </div>
          <div>
            <label>West</label>
            <input readonly value="<%= lb.get("WEST") %>">
          </div>
          <div>
            <label>North</label>
            <input readonly value="<%= lb.get("NORTH") %>">
          </div>
          <div>
            <label>South</label>
            <input readonly value="<%= lb.get("SOUTH") %>">
          </div>
          <div>
            <label>Engineer Name</label>
            <input readonly value="<%= lb.get("ENGINEER_NAME") %>">
          </div>
          <div>
		  <label>Particular</label>
		  <textarea readonly style="padding: 8px; border: 1px solid #ccc; border-radius: 4px; font-size: 13px; resize: vertical;" rows="2"><%= lb.get("PARTICULAR") %></textarea>
		</div>
        </div>
      </div>
      <%
        }
      %>
    </fieldset>
<%
    }

    // Check for Deposit Security Details
    psDepositSec = conn.prepareStatement("SELECT * FROM ACCOUNT.ACCOUNTSECURITYDEPOSIT WHERE ACCOUNT_CODE = ? ORDER BY SERIAL_NUMBER");
    psDepositSec.setString(1, accountCode);
    rsDepositSec = psDepositSec.executeQuery();
    
    List<Map<String, String>> depositSecurities = new ArrayList<>();
    while (rsDepositSec.next()) {
        Map<String, String> deposit = new HashMap<>();
        deposit.put("SECURITYTYPE_CODE", getStringSafe(rsDepositSec, "SECURITYTYPE_CODE"));
        deposit.put("SUBMISSIONDATE", formatDateForInput(rsDepositSec, "SUBMISSIONDATE"));
        deposit.put("MARGINPERCENTAGE", getStringSafe(rsDepositSec, "MARGINPERCENTAGE"));
        deposit.put("DEPOSITACCOUNT_CODE", getStringSafe(rsDepositSec, "DEPOSITACCOUNT_CODE"));
        deposit.put("RELEASEDATE", formatDateForInput(rsDepositSec, "RELEASEDATE"));
        deposit.put("SECURITYVALUE", getStringSafe(rsDepositSec, "SECURITYVALUE"));
        deposit.put("PARTICULAR", getStringSafe(rsDepositSec, "PARTICULAR"));
        depositSecurities.add(deposit);
    }
    
    if (!depositSecurities.isEmpty()) {
%>
    <fieldset>
      <legend>Security Deposit Details</legend>
      <%
        for (int i = 0; i < depositSecurities.size(); i++) {
            Map<String, String> deposit = depositSecurities.get(i);
      %>
      <div class="nominee-card" style="background: #e8e4fc; border: 1px solid #d0d0d0; border-radius: 10px; padding: 15px; margin-top: 15px;">
        <h4 style="color: #373279; margin-bottom: 10px;">Security Deposit <%= (i+1) %></h4>
        <div class="form-grid">
          <div>
            <label>Security Type</label>
            <input readonly value="<%
              String depSecTypeCode = deposit.get("SECURITYTYPE_CODE");
              String depSecTypeDesc = "";
              if (!depSecTypeCode.isEmpty()) {
                  PreparedStatement psDepSecType = null;
                  ResultSet rsDepSecType = null;
                  try {
                      psDepSecType = conn.prepareStatement(
                          "SELECT DESCRIPTION FROM GLOBALCONFIG.SECURITYTYPE WHERE SECURITYTYPE_CODE = ?"
                      );
                      psDepSecType.setString(1, depSecTypeCode);
                      rsDepSecType = psDepSecType.executeQuery();
                      if (rsDepSecType.next()) {
                          depSecTypeDesc = rsDepSecType.getString("DESCRIPTION");
                      }
                  } catch (Exception e) {
                      depSecTypeDesc = depSecTypeCode;
                  } finally {
                      try { if (rsDepSecType != null) rsDepSecType.close(); } catch (Exception ex) {}
                      try { if (psDepSecType != null) psDepSecType.close(); } catch (Exception ex) {}
                  }
              }
              out.print(depSecTypeDesc.isEmpty() ? depSecTypeCode : depSecTypeDesc);
            %>">
          </div>
          <div>
            <label>Submission Date</label>
            <input readonly value="<%= deposit.get("SUBMISSIONDATE") %>">
          </div>
          <div>
            <label>Margin %</label>
            <input readonly value="<%= deposit.get("MARGINPERCENTAGE") %>">
          </div>
          <div>
            <label>Deposit A/c Code</label>
            <input readonly value="<%= deposit.get("DEPOSITACCOUNT_CODE") %>">
          </div>
          <div>
            <label>Release Date</label>
            <input readonly value="<%= deposit.get("RELEASEDATE") %>">
          </div>
          <div>
            <label>Security Value</label>
            <input readonly value="<%= deposit.get("SECURITYVALUE") %>">
          </div>
          <div style="grid-column: span 3;">
            <label>Particular</label>
            <textarea readonly style="width: 97%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; font-size: 13px; resize: vertical;" rows="2"><%= deposit.get("PARTICULAR") %></textarea>
          </div>
        </div>
      </div>
      <%
        }
      %>
    </fieldset>
<%
    }

 // Check for Gold/Silver Details
    psGoldSilver = conn.prepareStatement("SELECT * FROM ACCOUNT.ACCOUNTSECURITYGOLDSILVER WHERE ACCOUNT_CODE = ? ORDER BY SERIAL_NUMBER");
    psGoldSilver.setString(1, accountCode);
    rsGoldSilver = psGoldSilver.executeQuery();
    
    List<Map<String, String>> goldSilvers = new ArrayList<>();
    while (rsGoldSilver.next()) {
        Map<String, String> gs = new HashMap<>();
        gs.put("SECURITYTYPE_CODE", getStringSafe(rsGoldSilver, "SECURITYTYPE_CODE"));
        gs.put("SUBMISSIONDATE", formatDateForInput(rsGoldSilver, "SUBMISSIONDATE"));
        gs.put("GOLDBAGNO", getStringSafe(rsGoldSilver, "GOLDBAGNO"));
        gs.put("WEIGHTTOTALGMS", getStringSafe(rsGoldSilver, "WEIGHTTOTALGMS"));
        gs.put("MARGINPERCENTAGE", getStringSafe(rsGoldSilver, "MARGINPERCENTAGE"));
        gs.put("RATEPER10GMS", getStringSafe(rsGoldSilver, "RATEPER10GMS"));
        gs.put("TOTALVALUE", getStringSafe(rsGoldSilver, "TOTALVALUE"));
        gs.put("SECURITYVALUE", getStringSafe(rsGoldSilver, "SECURITYVALUE"));
        gs.put("PARTICULAR", getStringSafe(rsGoldSilver, "PARTICULAR"));
        gs.put("NOTE", getStringSafe(rsGoldSilver, "NOTE"));
        gs.put("RELEASEDATE", formatDateForInput(rsGoldSilver, "RELEASEDATE"));
        gs.put("GOLDRECIEPTNO", getStringSafe(rsGoldSilver, "GOLDRECIEPTNO"));
        gs.put("GOLDDRAWERNO", getStringSafe(rsGoldSilver, "GOLDDRAWERNO"));
        gs.put("GROSTOTALGMS", getStringSafe(rsGoldSilver, "GROSTOTALGMS"));
        gs.put("VALUATION_RATE", getStringSafe(rsGoldSilver, "VALUATION_RATE"));
        gs.put("CURRENT_RATE", getStringSafe(rsGoldSilver, "CURRENT_RATE"));
        gs.put("CREATED_DATE", formatDateForInput(rsGoldSilver, "CREATED_DATE"));
        gs.put("MODIFIED_DATE", formatDateForInput(rsGoldSilver, "MODIFIED_DATE"));
        goldSilvers.add(gs);
    }
    
    if (!goldSilvers.isEmpty()) {
%>
    <fieldset>
      <legend>Gold/Silver Details</legend>
      <%
        for (int i = 0; i < goldSilvers.size(); i++) {
            Map<String, String> gs = goldSilvers.get(i);
      %>
      <div class="nominee-card" style="background: #e8e4fc; border: 1px solid #d0d0d0; border-radius: 10px; padding: 15px; margin-top: 15px;">
        <h4 style="color: #373279; margin-bottom: 10px;">Gold/Silver <%= (i+1) %></h4>
        <div class="form-grid">
          <div>
            <label>Security Type</label>
            <input readonly value="<%
              String gsSecTypeCode = gs.get("SECURITYTYPE_CODE");
              String gsSecTypeDesc = "";
              if (!gsSecTypeCode.isEmpty()) {
                  PreparedStatement psGsSecType = null;
                  ResultSet rsGsSecType = null;
                  try {
                      psGsSecType = conn.prepareStatement(
                          "SELECT DESCRIPTION FROM GLOBALCONFIG.SECURITYTYPE WHERE SECURITYTYPE_CODE = ?"
                      );
                      psGsSecType.setString(1, gsSecTypeCode);
                      rsGsSecType = psGsSecType.executeQuery();
                      if (rsGsSecType.next()) {
                          gsSecTypeDesc = rsGsSecType.getString("DESCRIPTION");
                      }
                  } catch (Exception e) {
                      gsSecTypeDesc = gsSecTypeCode;
                  } finally {
                      try { if (rsGsSecType != null) rsGsSecType.close(); } catch (Exception ex) {}
                      try { if (psGsSecType != null) psGsSecType.close(); } catch (Exception ex) {}
                  }
              }
              out.print(gsSecTypeDesc.isEmpty() ? gsSecTypeCode : gsSecTypeDesc);
            %>">
          </div>
          <div>
            <label>Submission Date</label>
            <input readonly value="<%= gs.get("SUBMISSIONDATE") %>">
          </div>
          <div>
            <label>Gold Bag No</label>
            <input readonly value="<%= gs.get("GOLDBAGNO") %>">
          </div>
          <div>
            <label>Total Weight (Grm)</label>
            <input readonly value="<%= gs.get("WEIGHTTOTALGMS") %>">
          </div>
          <div>
            <label>Gross Total (Grm)</label>
            <input readonly value="<%= gs.get("GROSTOTALGMS") %>">
          </div>
          <div>
            <label>Margin %</label>
            <input readonly value="<%= gs.get("MARGINPERCENTAGE") %>">
          </div>
          <div>
            <label>Rate/10Grm</label>
            <input readonly value="<%= gs.get("RATEPER10GMS") %>">
          </div>
          <div>
            <label>Valuation Rate</label>
            <input readonly value="<%= gs.get("VALUATION_RATE") %>">
          </div>
          <div>
            <label>Current Rate</label>
            <input readonly value="<%= gs.get("CURRENT_RATE") %>">
          </div>
          <div>
            <label>Total Value</label>
            <input readonly value="<%= gs.get("TOTALVALUE") %>">
          </div>
          <div>
            <label>Security Value</label>
            <input readonly value="<%= gs.get("SECURITYVALUE") %>">
          </div>
          <div>
            <label>Release Date</label>
            <input readonly value="<%= gs.get("RELEASEDATE") %>">
          </div>
          <div>
            <label>Gold Receipt No</label>
            <input readonly value="<%= gs.get("GOLDRECIEPTNO") %>">
          </div>
          <div>
            <label>Gold Drawer No</label>
            <input readonly value="<%= gs.get("GOLDDRAWERNO") %>">
          </div>
          <div>
            <label>Particular</label>
            <input readonly value="<%= gs.get("PARTICULAR") %>">
          </div>
          <div>
            <label>Created Date</label>
            <input readonly value="<%= gs.get("CREATED_DATE") %>">
          </div>
          <div>
            <label>Modified Date</label>
            <input readonly value="<%= gs.get("MODIFIED_DATE") %>">
          </div>
          <div>
		  <label>Note</label>
		  <textarea readonly style="padding: 8px; border: 1px solid #ccc; border-radius: 4px; font-size: 13px; resize: vertical;" rows="2"><%= gs.get("NOTE") %></textarea>
		</div>
        </div>
      </div>
      <%
        }
      %>
    </fieldset>
<%
    }

    // Check for Joint Holder Details
    if (showJointHolder) {
        psJoint = conn.prepareStatement("SELECT * FROM ACCOUNT.ACCOUNTJOINTHOLDER WHERE ACCOUNT_CODE = ? ORDER BY SERIAL_NUMBER");
        psJoint.setString(1, accountCode);
        rsJoint = psJoint.executeQuery();
        
        List<Map<String, String>> jointHolders = new ArrayList<>();
        while (rsJoint.next()) {
            Map<String, String> joint = new HashMap<>();
            joint.put("CUSTOMER_ID", getStringSafe(rsJoint, "CUSTOMER_ID"));
            joint.put("SALUTATION_CODE", getStringSafe(rsJoint, "SALUTATION_CODE"));
            joint.put("NAME", getStringSafe(rsJoint, "NAME"));
            joint.put("ADDRESS1", getStringSafe(rsJoint, "ADDRESS1"));
            joint.put("ADDRESS2", getStringSafe(rsJoint, "ADDRESS2"));
            joint.put("ADDRESS3", getStringSafe(rsJoint, "ADDRESS3"));
            joint.put("CITY_CODE", getStringSafe(rsJoint, "CITY_CODE"));
            joint.put("STATE_CODE", getStringSafe(rsJoint, "STATE_CODE"));
            joint.put("COUNTRY_CODE", getStringSafe(rsJoint, "COUNTRY_CODE"));
            joint.put("ZIP", getStringSafe(rsJoint, "ZIP"));
            joint.put("GENDER", getStringSafe(rsJoint, "GENDER"));
            joint.put("BIRTH_DATE", formatDateForInput(rsJoint, "BIRTH_DATE"));
            joint.put("RELATION", getStringSafe(rsJoint, "RELATION"));
            joint.put("PHONE_NUMBER", getStringSafe(rsJoint, "PHONE_NUMBER"));
            joint.put("PAN_NUMBER", getStringSafe(rsJoint, "PAN_NUMBER"));
            jointHolders.add(joint);
        }
        
        if (!jointHolders.isEmpty()) {
%>
    <fieldset>
      <legend>Joint Holder Details</legend>
      <%
        for (int i = 0; i < jointHolders.size(); i++) {
            Map<String, String> joint = jointHolders.get(i);
      %>
      <div class="nominee-card" style="background: #e8e4fc; border: 1px solid #d0d0d0; border-radius: 10px; padding: 15px; margin-top: 15px;">
        <h4 style="color: #373279; margin-bottom: 10px;">Joint Holder <%= (i+1) %></h4>
        <div class="address-grid">
          <% if (!joint.get("CUSTOMER_ID").isEmpty()) { %>
          <div>
            <label>Customer ID</label>
            <input readonly value="<%= joint.get("CUSTOMER_ID") %>">
          </div>
          <% } %>
          <div>
            <label>Salutation</label>
            <input readonly value="<%= joint.get("SALUTATION_CODE") %>">
          </div>
          <div>
            <label>Name</label>
            <input readonly value="<%= joint.get("NAME") %>">
          </div>
          <div>
            <label>Gender</label>
            <input readonly value="<%= joint.get("GENDER") %>">
          </div>
          <div>
            <label>Birth Date</label>
            <input readonly value="<%= joint.get("BIRTH_DATE") %>">
          </div>
          <div>
            <label>Relation</label>
            <input readonly value="<%= joint.get("RELATION") %>">
          </div>
          <div>
            <label>Phone Number</label>
            <input readonly value="<%= joint.get("PHONE_NUMBER") %>">
          </div>
          <div>
            <label>PAN Number</label>
            <input readonly value="<%= joint.get("PAN_NUMBER") %>">
          </div>
          <div>
            <label>Address 1</label>
            <input readonly value="<%= joint.get("ADDRESS1") %>">
          </div>
          <div>
            <label>Address 2</label>
            <input readonly value="<%= joint.get("ADDRESS2") %>">
          </div>
          <div>
            <label>Address 3</label>
            <input readonly value="<%= joint.get("ADDRESS3") %>">
          </div>
          <div>
            <label>City</label>
            <input readonly value="<%
              String jCityCode = joint.get("CITY_CODE");
              String jCityName = "";
              if (!jCityCode.isEmpty()) {
                  PreparedStatement psJCity = null;
                  ResultSet rsJCity = null;
                  try {
                      psJCity = conn.prepareStatement(
                          "SELECT NAME FROM GLOBALCONFIG.CITY WHERE CITY_CODE = ?"
                      );
                      psJCity.setString(1, jCityCode);
                      rsJCity = psJCity.executeQuery();
                      if (rsJCity.next()) {
                          jCityName = rsJCity.getString("NAME");
                      }
                  } catch (Exception e) {
                      jCityName = jCityCode;
                  } finally {
                      try { if (rsJCity != null) rsJCity.close(); } catch (Exception ex) {}
                      try { if (psJCity != null) psJCity.close(); } catch (Exception ex) {}
                  }
              }
              out.print(jCityName.isEmpty() ? jCityCode : jCityName);
            %>">
          </div>
          <div>
            <label>State</label>
            <input readonly value="<%
              String jStateCode = joint.get("STATE_CODE");
              String jStateName = "";
              if (!jStateCode.isEmpty()) {
                  PreparedStatement psJState = null;
                  ResultSet rsJState = null;
                  try {
                      psJState = conn.prepareStatement(
                          "SELECT NAME FROM GLOBALCONFIG.STATE WHERE STATE_CODE = ?"
                      );
                      psJState.setString(1, jStateCode);
                      rsJState = psJState.executeQuery();
                      if (rsJState.next()) {
                          jStateName = rsJState.getString("NAME");
                      }
                  } catch (Exception e) {
                      jStateName = jStateCode;
                  } finally {
                      try { if (rsJState != null) rsJState.close(); } catch (Exception ex) {}
                      try { if (psJState != null) psJState.close(); } catch (Exception ex) {}
                  }
              }
              out.print(jStateName.isEmpty() ? jStateCode : jStateName);
            %>">
          </div>
          <div>
            <label>Country</label>
            <input readonly value="<%
              String jCountryCode = joint.get("COUNTRY_CODE");
              String jCountryName = "";
              if (!jCountryCode.isEmpty()) {
                  PreparedStatement psJCountry = null;
                  ResultSet rsJCountry = null;
                  try {
                      psJCountry = conn.prepareStatement(
                          "SELECT NAME FROM GLOBALCONFIG.COUNTRY WHERE COUNTRY_CODE = ?"
                      );
                      psJCountry.setString(1, jCountryCode);
                      rsJCountry = psJCountry.executeQuery();
                      if (rsJCountry.next()) {
                          jCountryName = rsJCountry.getString("NAME");
                      }
                  } catch (Exception e) {
                      jCountryName = jCountryCode;
                  } finally {
                      try { if (rsJCountry != null) rsJCountry.close(); } catch (Exception ex) {}
                      try { if (psJCountry != null) psJCountry.close(); } catch (Exception ex) {}
                  }
              }
              out.print(jCountryName.isEmpty() ? jCountryCode : jCountryName);
            %>">
          </div>
          <div>
            <label>ZIP</label>
            <input readonly value="<%= joint.get("ZIP") %>">
          </div>
        </div>
      </div>
      <%
        }
      %>
    </fieldset>
<%
        }
    }

    // Check for Guarantor Details
    psGuarantor = conn.prepareStatement("SELECT * FROM ACCOUNT.ACCOUNTGUARANTOR WHERE ACCOUNT_CODE = ? ORDER BY SERIAL_NUMBER");
    psGuarantor.setString(1, accountCode);
    rsGuarantor = psGuarantor.executeQuery();
    
    List<Map<String, String>> guarantors = new ArrayList<>();
    while (rsGuarantor.next()) {
        Map<String, String> guarantor = new HashMap<>();
        guarantor.put("NAME", getStringSafe(rsGuarantor, "NAME"));
        guarantor.put("ADDRESS1", getStringSafe(rsGuarantor, "ADDRESS1"));
        guarantor.put("ADDRESS2", getStringSafe(rsGuarantor, "ADDRESS2"));
        guarantor.put("ADDRESS3", getStringSafe(rsGuarantor, "ADDRESS3"));
        guarantor.put("CITY_CODE", getStringSafe(rsGuarantor, "CITY_CODE"));
        guarantor.put("STATE_CODE", getStringSafe(rsGuarantor, "STATE_CODE"));
        guarantor.put("COUNTRY_CODE", getStringSafe(rsGuarantor, "COUNTRY_CODE"));
        guarantor.put("ZIP", getStringSafe(rsGuarantor, "ZIP"));
        guarantor.put("DATEOFBIRTH", formatDateForInput(rsGuarantor, "DATEOFBIRTH"));
        guarantor.put("PHONENUMBER", getStringSafe(rsGuarantor, "PHONENUMBER"));
        guarantor.put("MOBILENUMBER", getStringSafe(rsGuarantor, "MOBILENUMBER"));
        guarantors.add(guarantor);
    }
    
    if (!guarantors.isEmpty()) {
%>
    <fieldset>
      <legend>Guarantor Details</legend>
      <%
        for (int i = 0; i < guarantors.size(); i++) {
            Map<String, String> guarantor = guarantors.get(i);
      %>
      <div class="nominee-card" style="background: #e8e4fc; border: 1px solid #d0d0d0; border-radius: 10px; padding: 15px; margin-top: 15px;">
        <h4 style="color: #373279; margin-bottom: 10px;">Guarantor <%= (i+1) %></h4>
        <div class="address-grid">
          <div>
            <label>Name</label>
            <input readonly value="<%= guarantor.get("NAME") %>">
          </div>
          <div>
            <label>Date Of Birth</label>
            <input readonly value="<%= guarantor.get("DATEOFBIRTH") %>">
          </div>
          <div>
            <label>Phone Number</label>
            <input readonly value="<%= guarantor.get("PHONENUMBER") %>">
          </div>
          <div>
            <label>Mobile Number</label>
            <input readonly value="<%= guarantor.get("MOBILENUMBER") %>">
          </div>
          <div>
            <label>Address 1</label>
            <input readonly value="<%= guarantor.get("ADDRESS1") %>">
          </div>
          <div>
            <label>Address 2</label>
            <input readonly value="<%= guarantor.get("ADDRESS2") %>">
          </div>
          <div>
            <label>Address 3</label>
            <input readonly value="<%= guarantor.get("ADDRESS3") %>">
          </div>
          <div>
            <label>City</label>
            <input readonly value="<%
              String gCityCode = guarantor.get("CITY_CODE");
              String gCityName = "";
              if (!gCityCode.isEmpty()) {
                  PreparedStatement psGCity = null;
                  ResultSet rsGCity = null;
                  try {
                      psGCity = conn.prepareStatement(
                          "SELECT NAME FROM GLOBALCONFIG.CITY WHERE CITY_CODE = ?"
                      );
                      psGCity.setString(1, gCityCode);
                      rsGCity = psGCity.executeQuery();
                      if (rsGCity.next()) {
                          gCityName = rsGCity.getString("NAME");
                      }
                  } catch (Exception e) {
                      gCityName = gCityCode;
                  } finally {
                      try { if (rsGCity != null) rsGCity.close(); } catch (Exception ex) {}
                      try { if (psGCity != null) psGCity.close(); } catch (Exception ex) {}
                  }
              }
              out.print(gCityName.isEmpty() ? gCityCode : gCityName);
            %>">
          </div>
          <div>
            <label>State</label>
            <input readonly value="<%
              String gStateCode = guarantor.get("STATE_CODE");
              String gStateName = "";
              if (!gStateCode.isEmpty()) {
                  PreparedStatement psGState = null;
                  ResultSet rsGState = null;
                  try {
                      psGState = conn.prepareStatement(
                          "SELECT NAME FROM GLOBALCONFIG.STATE WHERE STATE_CODE = ?"
                      );
                      psGState.setString(1, gStateCode);
                      rsGState = psGState.executeQuery();
                      if (rsGState.next()) {
                          gStateName = rsGState.getString("NAME");
                      }
                  } catch (Exception e) {
                      gStateName = gStateCode;
                  } finally {
                      try { if (rsGState != null) rsGState.close(); } catch (Exception ex) {}
                      try { if (psGState != null) psGState.close(); } catch (Exception ex) {}
                  }
              }
              out.print(gStateName.isEmpty() ? gStateCode : gStateName);
            %>">
          </div>
          <div>
            <label>Country</label>
            <input readonly value="<%
              String gCountryCode = guarantor.get("COUNTRY_CODE");
              String gCountryName = "";
              if (!gCountryCode.isEmpty()) {
                  PreparedStatement psGCountry = null;
                  ResultSet rsGCountry = null;
                  try {
                      psGCountry = conn.prepareStatement(
                          "SELECT NAME FROM GLOBALCONFIG.COUNTRY WHERE COUNTRY_CODE = ?"
                      );
                      psGCountry.setString(1, gCountryCode);
                      rsGCountry = psGCountry.executeQuery();
                      if (rsGCountry.next()) {
                          gCountryName = rsGCountry.getString("NAME");
                      }
                  } catch (Exception e) {
                      gCountryName = gCountryCode;
                  } finally {
                      try { if (rsGCountry != null) rsGCountry.close(); } catch (Exception ex) {}
                      try { if (psGCountry != null) psGCountry.close(); } catch (Exception ex) {}
                  }
              }
              out.print(gCountryName.isEmpty() ? gCountryCode : gCountryName);
            %>">
          </div>
          <div>
            <label>ZIP</label>
            <input readonly value="<%= guarantor.get("ZIP") %>">
          </div>
        </div>
      </div>
      <%
        }
      %>
    </fieldset>
<%
    }
%>

<div style="text-align:center; margin-top:20px;">
    <button type="button" onclick="goBackToList();" class="back-btn"
        style="padding:10px 22px; background:#373279; color:white;
               border:none; border-radius:6px; cursor:pointer;
               font-size:16px; font-weight:bold;">
    ← Back to List
    </button>
</div>
</form>

</body>
</html>

<%
    } 
    catch (Exception e) {
        out.println("<pre style='color:red'>Error: " + e.getMessage() + "</pre>");
        e.printStackTrace();
    } finally {
        try { if (rsAccount != null) rsAccount.close(); } catch (Exception ex) {}
        try { if (rsNominee != null) rsNominee.close(); } catch (Exception ex) {}
        try { if (rsJoint != null) rsJoint.close(); } catch (Exception ex) {}
        try { if (rsGuarantor != null) rsGuarantor.close(); } catch (Exception ex) {}
        try { if (rsDeposit != null) rsDeposit.close(); } catch (Exception ex) {}
        try { if (rsLoan != null) rsLoan.close(); } catch (Exception ex) {}
        try { if (rsPigmy != null) rsPigmy.close(); } catch (Exception ex) {}
        try { if (rsFixed != null) rsFixed.close(); } catch (Exception ex) {}
        try { if (psAccount != null) psAccount.close(); } catch (Exception ex) {}
        try { if (psNominee != null) psNominee.close(); } catch (Exception ex) {}
        try { if (psJoint != null) psJoint.close(); } catch (Exception ex) {}
        try { if (psGuarantor != null) psGuarantor.close(); } catch (Exception ex) {}
        try { if (psDeposit != null) psDeposit.close(); } catch (Exception ex) {}
        try { if (psLoan != null) psLoan.close(); } catch (Exception ex) {}
        try { if (psPigmy != null) psPigmy.close(); } catch (Exception ex) {}
        try { if (psFixed != null) psFixed.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
        try { if (rsLandBuilding != null) rsLandBuilding.close(); } catch (Exception ex) {}
        try { if (psLandBuilding != null) psLandBuilding.close(); } catch (Exception ex) {}
        try { if (rsDepositSec != null) rsDepositSec.close(); } catch (Exception ex) {}
        try { if (psDepositSec != null) psDepositSec.close(); } catch (Exception ex) {}
        try { if (rsGoldSilver != null) rsGoldSilver.close(); } catch (Exception ex) {}
        try { if (psGoldSilver != null) psGoldSilver.close(); } catch (Exception ex) {}
        
    }
%>