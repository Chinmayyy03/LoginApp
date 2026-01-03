<%@ page import="java.sql.*, db.DBConnection, java.text.SimpleDateFormat, java.util.List, java.util.ArrayList, java.util.Map, java.util.HashMap" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("login.jsp");
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
    String appNo = request.getParameter("appNo");
    if (appNo == null || appNo.trim().isEmpty()) {
        out.println("<h3 style='color:red;'>Application Number not provided.</h3>");
        return;
    }

    Connection conn = null;
    PreparedStatement psApp = null, psNominee = null, psJoint = null, psCoBorrower = null;
    PreparedStatement psGuarantor = null, psLandBuilding = null, psDeposit = null, psGoldSilver = null;
    PreparedStatement psLoan = null, psMainDeposit = null, psPigmy = null, psFixed = null;
    ResultSet rsApp = null, rsNominee = null, rsJoint = null, rsCoBorrower = null;
    ResultSet rsGuarantor = null, rsLandBuilding = null, rsDeposit = null, rsGoldSilver = null;
    ResultSet rsLoan = null, rsMainDeposit = null, rsPigmy = null, rsFixed = null;

    try {
        conn = DBConnection.getConnection();
        
        // Fetch main application data
        psApp = conn.prepareStatement("SELECT * FROM APPLICATION.APPLICATION WHERE APPLICATION_NUMBER = ?");
        psApp.setString(1, appNo);
        rsApp = psApp.executeQuery();

        if (!rsApp.next()) {
            out.println("<h3 style='color:red;'>No application found with number: " + appNo + "</h3>");
            return;
        }
        
        String productCode = getStringSafe(rsApp, "PRODUCT_CODE");

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
    
    // ---- Co-Borrower NOT allowed for these product codes ----
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
  <title>View Application — <%= appNo %></title>
  <link rel="stylesheet" href="css/addCustomer.css">
  <link rel="stylesheet" href="css/authViewCustomers.css">
  <script>
  window.onload = function() {
	    if (window.parent && window.parent.updateParentBreadcrumb) {
	        window.parent.updateParentBreadcrumb('Authorization > Application List > View Details');
	    }
	};

	function goBackToList() {
	    if (window.parent && window.parent.updateParentBreadcrumb) {
	        window.parent.updateParentBreadcrumb('Authorization > Application List');
	    }
	    window.location.href = 'authorizationPendingApplications.jsp';
	}

function showAuthorizeConfirmation(event) {
    event.preventDefault();
    document.getElementById('authorizeModal').style.display = 'block';
}

function showRejectConfirmation(event) {
    event.preventDefault();
    document.getElementById('rejectModal').style.display = 'block';
}

function closeAuthorizeModal() {
    document.getElementById('authorizeModal').style.display = 'none';
}

function closeRejectModal() {
    document.getElementById('rejectModal').style.display = 'none';
}

function confirmAuthorize() {
    document.getElementById('authorizeForm').submit();
}

function confirmReject() {
    document.getElementById('rejectForm').submit();
}

window.onclick = function(event) {
    const authorizeModal = document.getElementById('authorizeModal');
    const rejectModal = document.getElementById('rejectModal');
    if (event.target === authorizeModal) {
        closeAuthorizeModal();
    }
    if (event.target === rejectModal) {
        closeRejectModal();
    }
}

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeAuthorizeModal();
        closeRejectModal();
    }
});
</script>
</head>
<body>

<form>
    <fieldset>
      <legend>Application Information</legend>
      <div class="form-grid">
        <div>
          <label>Application Number</label>
          <input readonly value="<%= getStringSafe(rsApp,"APPLICATION_NUMBER") %>">
        </div>
        <div>
          <label>Product Code</label>
          <input readonly value="<%= productCode %>">
        </div>
        <div>
          <label>Branch Code</label>
          <input readonly value="<%= getStringSafe(rsApp,"BRANCH_CODE") %>">
        </div>
        <div>
          <label>Customer ID</label>
          <input readonly value="<%= getStringSafe(rsApp,"CUSTOMER_ID") %>">
        </div>
        <div>
          <label>Customer Name</label>
          <input readonly value="<%= getStringSafe(rsApp,"NAME") %>">
        </div>
        <div>
          <label>Category Code</label>
          <input readonly value="<%= getStringSafe(rsApp,"CATEGORY_CODE") %>">
        </div>
        <div>
          <label>Introducer A/c Code</label>
          <input readonly value="<%= getStringSafe(rsApp,"INTRODUCERACCOUNT_CODE") %>">
        </div>
        <div>
          <label>Introducer A/c Name</label>
          <input readonly value="<%= getStringSafe(rsApp,"INTRODUCER_NAME") %>">
        </div>
        <div>
          <label>Date Of Application</label>
          <input readonly value="<%= formatDateForInput(rsApp,"APPLICATIONDATE") %>">
        </div>
        <div>
      <label>Account Operation Capacity</label>
      <input readonly value="<%
        String accOpCapId = getStringSafe(rsApp,"ACCOUNTOPERATIONCAPACITY_ID");
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
                accOpCapDesc = accOpCapId; // Fallback to ID if error
            } finally {
                try { if (rsAccOpCap != null) rsAccOpCap.close(); } catch (Exception ex) {}
                try { if (psAccOpCap != null) psAccOpCap.close(); } catch (Exception ex) {}
            }
        }
        out.print(accOpCapDesc.isEmpty() ? accOpCapId : accOpCapDesc);
      %>">
    </div>
        <div>
      <label>Min Balance</label>
      <input readonly value="<%
        String minBalId = getStringSafe(rsApp,"MINBALANCE_ID");
        String minBalValue = "";
        if (!minBalId.isEmpty()) {
            PreparedStatement psMinBal = null;
            ResultSet rsMinBal = null;
            try {
                psMinBal = conn.prepareStatement(
                    "SELECT MINBALANCE FROM HEADOFFICE.ACCOUNTMINBALANCE WHERE MINBALANCE_ID = ?"
                );
                psMinBal.setString(1, minBalId);
                rsMinBal = psMinBal.executeQuery();
                if (rsMinBal.next()) {
                    minBalValue = rsMinBal.getString("MINBALANCE");
                }
            } catch (Exception e) {
                minBalValue = minBalId; // Fallback to ID if error
            } finally {
                try { if (rsMinBal != null) rsMinBal.close(); } catch (Exception ex) {}
                try { if (psMinBal != null) psMinBal.close(); } catch (Exception ex) {}
            }
        }
        out.print(minBalValue.isEmpty() ? minBalId : minBalValue);
      %>">
    </div>
        <div>
          <label>Risk Category</label>
          <input readonly value="<%= getStringSafe(rsApp,"RISKCATEGORY") %>">
        </div>
      </div>
    </fieldset>
<%
	
	// Check for Term Deposit specific fields
	// Term Deposit main data (read from APPLICATIONDEPOSIT)
	psMainDeposit = conn.prepareStatement(
	    "SELECT * FROM APPLICATION.APPLICATIONDEPOSIT WHERE APPLICATION_NUMBER = ?"
	);
	psMainDeposit.setString(1, appNo);
	rsMainDeposit = psMainDeposit.executeQuery();
	
	String depositAmount = "";
	String maturityAmount = "";
	String openDate = "";
	String maturityDate = "";
	
	if (rsMainDeposit.next()) {
	    depositAmount  = getStringSafe(rsMainDeposit, "DEPOSITAMOUNT");
	    maturityAmount = getStringSafe(rsMainDeposit, "MATURITYVALUE");
	    openDate       = formatDateForInput(rsMainDeposit, "FROMDATE");
	    maturityDate   = formatDateForInput(rsMainDeposit, "MATURITYDATE");
	}

    
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
      <input readonly value="<%= getStringSafe(rsMainDeposit,"UNITOFPERIOD") %>">
    </div>
	    <div>
	      <label>Period Of Deposit</label>
	      <input readonly value="<%= getStringSafe(rsMainDeposit,"PERIODOFDEPOSIT") %>">
	    </div>
	    <div>
          <label>Maturity Date</label>
          <input readonly value="<%= maturityDate %>">
        </div> 

	    <div>
	      <label>Interest Rate</label>
	      <input readonly value="<%= getStringSafe(rsMainDeposit,"INTERESTRATE") %>">
	    </div>
	    <div>
	      <label>Interest Paid In Cash</label>
	      <input readonly value="<%= getStringSafe(rsMainDeposit,"IS_INTEREST_PAID_IN_CASH") %>">
	    </div>
	    <div>
	      <label>Rate Discounted</label>
	      <input readonly value="<%= getStringSafe(rsMainDeposit,"IS_RATE_DISCOUNTED") %>">
	    </div>
	    <div>
	      <label>Is AR Day Begin</label>
	      <input readonly value="<%= getStringSafe(rsMainDeposit,"IS_AR_DAYBEGIN") %>">
	    </div>
	    <div>
	      <label>Interest Payment Frequency</label>
	      <input readonly value="<%= getStringSafe(rsMainDeposit,"INTERESTPAYMENTFREQUENCY") %>">
	    </div>
	    <div>
	      <label>Credit A/c Code</label>
	      <input readonly value="<%= getStringSafe(rsMainDeposit,"CREDITACCOUNT_CODE") %>">
	    </div>

        <div>
          <label>Credit A/c Name</label>
          <input readonly value="<%= getStringSafe(rsApp,"NAME") %>">
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
    
 // Check for Loan Details
    // Fetch loan application data
	psLoan = conn.prepareStatement(
	    "SELECT * FROM APPLICATION.APPLICATIONLOAN WHERE APPLICATION_NUMBER = ?"
	);
	psLoan.setString(1, appNo);
	rsLoan = psLoan.executeQuery();
	
	if (rsLoan.next()) {
	    String sanctionAmount = getStringSafe(rsLoan, "SANCTIONAMOUNT");
	    String limitAmount    = getStringSafe(rsLoan, "LIMITAMOUNT");
	    String sanctionDate   = formatDateForInput(rsLoan, "SANCTIONDATE");
	
	    if (!sanctionAmount.isEmpty() || !limitAmount.isEmpty() || !sanctionDate.isEmpty())  {
%>
    <fieldset>
      <legend>Loan Details</legend>
      <div class="form-grid">
        <div>
          <label>Resolution No</label>
          <input readonly value="<%= getStringSafe(rsLoan,"RESOLUTIONNUMBER") %>">
        </div>
        <div>
          <label>Registration Date</label>
          <input readonly value="<%= formatDateForInput(rsLoan,"DATEOFREGISTRATION") %>">
        </div>
        <div>
          <label>Register Amount</label>
          <input readonly value="<%= getStringSafe(rsLoan,"REGISTERAMOUNT") %>">
        </div>
        <div>
          <label>Limit Amount</label>
          <input readonly value="<%= limitAmount %>">
        </div>
		<div>
          <label>Drawing Power</label>
          <input readonly value="<%= getStringSafe(rsLoan,"DRAWINGPOWER") %>">
        </div>
        <div>
          <label>Sanction Date</label>
          <input readonly value="<%= sanctionDate %>">
        </div>
        <div>
          <label>Sanction Amount</label>
          <input readonly value="<%= sanctionAmount %>">
        </div>
        <div>
          <label>Period of Loan (months)</label>
          <input readonly value="<%= getStringSafe(rsLoan,"PERIODOFLOAN") %>">
        </div>
        <div>
          <label>A/c Review Date</label>
          <input readonly value="<%= formatDateForInput(rsLoan,"ACCOUNTREVIEWDATE") %>">
        </div>
	 <div>
      <label>Installment Type</label>
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
          <label>Repayment Freq.</label>
          <input readonly value="<%= getStringSafe(rsLoan,"REPAYMENTFREQUENCY") %>">
        </div>
        <div>
          <label>Int. Calculation Method</label>
          <input readonly value="<%= getStringSafe(rsLoan,"INTERESTCALCULATIONMETHOD") %>">
        </div>
        <div>
          <label>Interest Rate</label>
          <input readonly value="<%= getStringSafe(rsLoan,"CURRENTINTERESTRATE") %>">
        </div>
        <div>
          <label>Penal Int. Rate</label>
          <input readonly value="<%= getStringSafe(rsLoan,"CURRENTPENALINTERESTRATE") %>">
        </div>
        <div>
          <label>Mor. Int. Rate</label>
          <input readonly value="<%= getStringSafe(rsLoan,"CURRENTMORATORIUMINTERESTRATE") %>">
        </div>
        <div>
          <label>Overdue Int. Rate</label>
          <input readonly value="<%= getStringSafe(rsLoan,"CURRENTOVERDUEINTERESTRATE") %>">
        </div>
        <div>
          <label>Mor. Period Month</label>
          <input readonly value="<%= getStringSafe(rsLoan,"MORATORIUMPEROIDMONTH") %>">
        </div>
        <div>
          <label>Inst. Amount</label>
          <input readonly value="<%= getStringSafe(rsLoan,"INSTALLMENTAMOUNT") %>">
        </div>
        <div>
          <label>Consortium Loan</label>
          <input readonly value="<%= getStringSafe(rsLoan,"IS_CONSORTIUM_LOAN") %>">
        </div>
        <div>
      <label>Area</label>
      <input readonly value="<%
        String areaCode = getStringSafe(rsLoan,"AREA_CODE");
        String areaName = "";
        if (!areaCode.isEmpty()) {
            PreparedStatement psArea = null;
            ResultSet rsArea = null;
            try {
                psArea = conn.prepareStatement(
                    "SELECT AREA_NAME FROM HEADOFFICE.AREA WHERE AREA_CODE = ?"
                );
                psArea.setString(1, areaCode);
                rsArea = psArea.executeQuery();
                if (rsArea.next()) {
                    areaName = rsArea.getString("AREA_NAME");
                }
            } catch (Exception e) {
                areaName = areaCode;
            } finally {
                try { if (rsArea != null) rsArea.close(); } catch (Exception ex) {}
                try { if (psArea != null) psArea.close(); } catch (Exception ex) {}
            }
        }
        out.print(areaName.isEmpty() ? areaCode : areaName);
      %>">
    </div>
        <div>
      <label>Social Section</label>
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
      <label>Sub Area</label>
      <input readonly value="<%
        String subAreaCode = getStringSafe(rsLoan,"SUBAREA_CODE");
        String subAreaName = "";
        if (!subAreaCode.isEmpty()) {
            PreparedStatement psSubArea = null;
            ResultSet rsSubArea = null;
            try {
                psSubArea = conn.prepareStatement(
                    "SELECT SUBAREA_NAME FROM HEADOFFICE.SUBAREA WHERE SUBAREA_CODE = ?"
                );
                psSubArea.setString(1, subAreaCode);
                rsSubArea = psSubArea.executeQuery();
                if (rsSubArea.next()) {
                    subAreaName = rsSubArea.getString("SUBAREA_NAME");
                }
            } catch (Exception e) {
                subAreaName = subAreaCode;
            } finally {
                try { if (rsSubArea != null) rsSubArea.close(); } catch (Exception ex) {}
                try { if (psSubArea != null) psSubArea.close(); } catch (Exception ex) {}
            }
        }
        out.print(subAreaName.isEmpty() ? subAreaCode : subAreaName);
      %>">
    </div>
        <div>
      <label>LBR Code</label>
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
      <label>Social Sector</label>
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
      <label>Purpose</label>
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
      <label>Social SubSector</label>
      <input readonly value="<%
        String socialSubSectorId = getStringSafe(rsLoan,"SOCIALSUBSECTOR_ID");
        String socialSubSectorDesc = "";
        if (!socialSubSectorId.isEmpty()) {
            PreparedStatement psSocialSubSector = null;
            ResultSet rsSocialSubSector = null;
            try {
                psSocialSubSector = conn.prepareStatement(
                    "SELECT DESCRIPTION FROM HEADOFFICE.SOCIALSUBSECTOR WHERE SOCIALSUBSECTOR_ID = ?"
                );
                psSocialSubSector.setString(1, socialSubSectorId);
                rsSocialSubSector = psSocialSubSector.executeQuery();
                if (rsSocialSubSector.next()) {
                    socialSubSectorDesc = rsSocialSubSector.getString("DESCRIPTION");
                }
            } catch (Exception e) {
                socialSubSectorDesc = socialSubSectorId;
            } finally {
                try { if (rsSocialSubSector != null) rsSocialSubSector.close(); } catch (Exception ex) {}
                try { if (psSocialSubSector != null) psSocialSubSector.close(); } catch (Exception ex) {}
            }
        }
        out.print(socialSubSectorDesc.isEmpty() ? socialSubSectorId : socialSubSectorDesc);
      %>">
    </div>
        <div>
      <label>Classification</label>
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
      <label>Mode Of Sanction</label>
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
      <label>Sanction Authority</label>
      <input readonly value="<%
        String sanctionAuthId = getStringSafe(rsLoan,"SANCTIONAUTHORITY_ID");
        String sanctionAuthDesc = "";
        if (!sanctionAuthId.isEmpty()) {
            PreparedStatement psSanctionAuth = null;
            ResultSet rsSanctionAuth = null;
            try {
                psSanctionAuth = conn.prepareStatement(
                    "SELECT DESCRIPTION FROM HEADOFFICE.SANCTIONAUTHORITY WHERE SANCTIONAUTHORITY_ID = ?"
                );
                psSanctionAuth.setString(1, sanctionAuthId);
                rsSanctionAuth = psSanctionAuth.executeQuery();
                if (rsSanctionAuth.next()) {
                    sanctionAuthDesc = rsSanctionAuth.getString("DESCRIPTION");
                }
            } catch (Exception e) {
                sanctionAuthDesc = sanctionAuthId;
            } finally {
                try { if (rsSanctionAuth != null) rsSanctionAuth.close(); } catch (Exception ex) {}
                try { if (psSanctionAuth != null) psSanctionAuth.close(); } catch (Exception ex) {}
            }
        }
        out.print(sanctionAuthDesc.isEmpty() ? sanctionAuthId : sanctionAuthDesc);
      %>">
    </div>
        <div>
      <label>Industry</label>
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
          <label>Is Director Related</label>
          <input readonly value="<%= getStringSafe(rsLoan,"IS_DIRECTOR_RELATED") %>">
        </div>
        <div>
          <label>Director Id</label>
          <input readonly value="<%= getStringSafe(rsLoan,"DIRECTOR_ID") %>">
        </div>
      </div>
    </fieldset>
<%
    }
	}
	 // Check for Pigmy specific fields
	    // Pigmy data
		psPigmy = conn.prepareStatement(
	    "SELECT * FROM APPLICATION.APPLICATIONPIGMY WHERE APPLICATION_NUMBER = ?"
	);
	psPigmy.setString(1, appNo);
	rsPigmy = psPigmy.executeQuery();
	
	String agentId = "";
	String installmentAmount = "";
	if (rsPigmy.next()) {
	    agentId = getStringSafe(rsPigmy, "AGENT_ID");
	    installmentAmount = getStringSafe(rsPigmy, "INSTALLMENTAMOUNT");
	}
    
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
          <label>Installment Amount</label>
          <input readonly value="<%= installmentAmount %>">
        </div>
        <div>
          <label>Interest Rate</label>
          <input readonly value="<%= getStringSafe(rsPigmy,"INTERESTRATE") %>">
        </div>
		<div>
          <label>Open Date</label>
          <input readonly value="<%= formatDateForInput(rsPigmy,"FROMDATE") %>">
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
      </div>
    </fieldset>
<%
    }
    
 // Check for Fixed Asset specific fields
    // Fixed asset data
	psFixed = conn.prepareStatement(
	    "SELECT * FROM APPLICATION.APPLICATIONFIXEDASSET WHERE APPLICATION_NUMBER = ?"
	);
	psFixed.setString(1, appNo);
	rsFixed = psFixed.executeQuery();
	
	String itemName = "";
	String purchaseAmount = "";
	if (rsFixed.next()) {
	    itemName = getStringSafe(rsFixed, "ITEM_NAME");
	    purchaseAmount = getStringSafe(rsFixed, "PURCHASEAMOUNT");
	}
    
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
          <label>No. Of Item</label>
          <input readonly value="<%= getStringSafe(rsFixed,"NUMBEROFITEM") %>">
        </div>
       <div>
          <label>Depreciation Rate</label>
          <input readonly value="<%= getStringSafe(rsFixed,"DEPRICATIONRATE") %>">
        </div>
        <div>
          <label>Description</label>
          <input readonly value="<%= getStringSafe(rsFixed,"DESCRIPTION") %>">
        </div>
        <div>
          <label>Bill Number</label>
          <input readonly value="<%= getStringSafe(rsFixed,"BILLNUMBER") %>">
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
      </div>
    </fieldset>

<%
    }

    // Check for Nominee data
    psNominee = conn.prepareStatement("SELECT * FROM APPLICATION.APPLICATIONNOMINEE WHERE APPLICATION_NUMBER = ? ORDER BY SERIAL_NUMBER");
    psNominee.setString(1, appNo);
    rsNominee = psNominee.executeQuery();
    
    List<Map<String, String>> nominees = new ArrayList<>();
    while (rsNominee.next()) {
        Map<String, String> nominee = new HashMap<>();
        nominee.put("SERIAL_NUMBER", getStringSafe(rsNominee, "SERIAL_NUMBER"));
        nominee.put("SALUTATION_CODE", getStringSafe(rsNominee, "SALUTATION_CODE"));
        nominee.put("NAME", getStringSafe(rsNominee, "NAME"));
        nominee.put("ADDRESS1", getStringSafe(rsNominee, "ADDRESS1"));
        nominee.put("ADDRESS2", getStringSafe(rsNominee, "ADDRESS2"));
        nominee.put("ADDRESS3", getStringSafe(rsNominee, "ADDRESS3"));
        nominee.put("COUNTRY_CODE", getStringSafe(rsNominee, "COUNTRY_CODE"));
        nominee.put("STATE_CODE", getStringSafe(rsNominee, "STATE_CODE"));
        nominee.put("CITY_CODE", getStringSafe(rsNominee, "CITY_CODE"));
        nominee.put("ZIP", getStringSafe(rsNominee, "ZIP"));
        nominee.put("RELATION_ID", getStringSafe(rsNominee, "RELATION_ID"));
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
            <label>Salutation</label>
            <input readonly value="<%= nominee.get("SALUTATION_CODE") %>">
          </div>
          <div>
            <label>Name</label>
            <input readonly value="<%= nominee.get("NAME") %>">
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
            <label>ZIP</label>
            <input readonly value="<%= nominee.get("ZIP") %>">
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
        </div>
      </div>
      <%
        }
      %>
    </fieldset>
<%
    }

    // Check for Joint Holder data
    psJoint = conn.prepareStatement("SELECT * FROM APPLICATION.APPLICATIONJOINTHOLDER WHERE APPLICATION_NUMBER = ? ORDER BY SERIAL_NUMBER");
    psJoint.setString(1, appNo);
    rsJoint = psJoint.executeQuery();
    
    List<Map<String, String>> jointHolders = new ArrayList<>();
    while (rsJoint.next()) {
        Map<String, String> joint = new HashMap<>();
        joint.put("SERIAL_NUMBER", getStringSafe(rsJoint, "SERIAL_NUMBER"));
        joint.put("CUSTOMER_ID", getStringSafe(rsJoint, "CUSTOMER_ID"));
        joint.put("SALUTATION_CODE", getStringSafe(rsJoint, "SALUTATION_CODE"));
        joint.put("NAME", getStringSafe(rsJoint, "NAME"));
        joint.put("ADDRESS1", getStringSafe(rsJoint, "ADDRESS1"));
        joint.put("ADDRESS2", getStringSafe(rsJoint, "ADDRESS2"));
        joint.put("ADDRESS3", getStringSafe(rsJoint, "ADDRESS3"));
        joint.put("COUNTRY_CODE", getStringSafe(rsJoint, "COUNTRY_CODE"));
        joint.put("STATE_CODE", getStringSafe(rsJoint, "STATE_CODE"));
        joint.put("CITY_CODE", getStringSafe(rsJoint, "CITY_CODE"));
        joint.put("ZIP", getStringSafe(rsJoint, "ZIP"));
        jointHolders.add(joint);
    }
    
    if (showJointHolder && !jointHolders.isEmpty()) {
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

    // Check for Co-Borrower data
    psCoBorrower = conn.prepareStatement("SELECT * FROM APPLICATION.APPLICATIONJOINTHOLDER WHERE APPLICATION_NUMBER = ? ORDER BY SERIAL_NUMBER");
    psCoBorrower.setString(1, appNo);
    rsCoBorrower = psCoBorrower.executeQuery();
    
    List<Map<String, String>> coBorrowers = new ArrayList<>();
    while (rsCoBorrower.next()) {
        Map<String, String> coBorrower = new HashMap<>();
        coBorrower.put("SERIAL_NUMBER", getStringSafe(rsCoBorrower, "SERIAL_NUMBER"));
        coBorrower.put("CUSTOMER_ID", getStringSafe(rsCoBorrower, "CUSTOMER_ID"));
        coBorrower.put("SALUTATION_CODE", getStringSafe(rsCoBorrower, "SALUTATION_CODE"));
        coBorrower.put("NAME", getStringSafe(rsCoBorrower, "NAME"));
        coBorrower.put("ADDRESS1", getStringSafe(rsCoBorrower, "ADDRESS1"));
        coBorrower.put("ADDRESS2", getStringSafe(rsCoBorrower, "ADDRESS2"));
        coBorrower.put("ADDRESS3", getStringSafe(rsCoBorrower, "ADDRESS3"));
        coBorrower.put("COUNTRY_CODE", getStringSafe(rsCoBorrower, "COUNTRY_CODE"));
        coBorrower.put("STATE_CODE", getStringSafe(rsCoBorrower, "STATE_CODE"));
        coBorrower.put("CITY_CODE", getStringSafe(rsCoBorrower, "CITY_CODE"));
        coBorrower.put("ZIP", getStringSafe(rsCoBorrower, "ZIP"));
        coBorrowers.add(coBorrower);
    }
    
    if (showCoBorrower && !coBorrowers.isEmpty()) {
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

    // Check for Guarantor data
    psGuarantor = conn.prepareStatement("SELECT * FROM APPLICATION.APPLICATIONGUARANTOR WHERE APPLICATION_NUMBER = ? ORDER BY SERIAL_NUMBER");
    psGuarantor.setString(1, appNo);
    rsGuarantor = psGuarantor.executeQuery();
    
    List<Map<String, String>> guarantors = new ArrayList<>();
    while (rsGuarantor.next()) {
        Map<String, String> guarantor = new HashMap<>();
        guarantor.put("NAME", getStringSafe(rsGuarantor, "NAME"));
        guarantor.put("ADDRESS1", getStringSafe(rsGuarantor, "ADDRESS1"));
        guarantor.put("ADDRESS2", getStringSafe(rsGuarantor, "ADDRESS2"));
        guarantor.put("ADDRESS3", getStringSafe(rsGuarantor, "ADDRESS3"));
        guarantor.put("COUNTRY_CODE", getStringSafe(rsGuarantor, "COUNTRY_CODE"));
        guarantor.put("STATE_CODE", getStringSafe(rsGuarantor, "STATE_CODE"));
        guarantor.put("CITY_CODE", getStringSafe(rsGuarantor, "CITY_CODE"));
        guarantor.put("ZIP", getStringSafe(rsGuarantor, "ZIP"));
        guarantor.put("MEMBER_NO", getStringSafe(rsGuarantor, "MEMBER_NO"));
        guarantor.put("EMPLOYEE_ID", getStringSafe(rsGuarantor, "EMPLOYEE_ID"));
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
            <label>ZIP</label>
            <input readonly value="<%= guarantor.get("ZIP") %>">
          </div>
          <div>
            <label>Member No</label>
            <input readonly value="<%= guarantor.get("MEMBER_NO") %>">
          </div>
          <div>
            <label>Employee ID</label>
            <input readonly value="<%= guarantor.get("EMPLOYEE_ID") %>">
          </div>
          <div>
            <label>Birth Date</label>
            <input readonly value="<%= guarantor.get("DATEOFBIRTH") %>">
          </div>
          <div>
            <label>Phone No</label>
            <input readonly value="<%= guarantor.get("PHONENUMBER") %>">
          </div>
          <div>
            <label>Mobile No</label>
            <input readonly value="<%= guarantor.get("MOBILENUMBER") %>">
          </div>
        </div>
      </div>
      <%
        }
      %>
    </fieldset>
<%
    }

    // Check for Land & Building data
    psLandBuilding = conn.prepareStatement("SELECT * FROM APPLICATION.APPLICATIONSECURITYLANDNBULDIN WHERE APPLICATION_NUMBER = ? ORDER BY SERIAL_NUMBER");
    psLandBuilding.setString(1, appNo);
    rsLandBuilding = psLandBuilding.executeQuery();
    
    List<Map<String, String>> landBuildings = new ArrayList<>();
    while (rsLandBuilding.next()) {
        Map<String, String> lb = new HashMap<>();
        lb.put("SECURITYTYPE_CODE", getStringSafe(rsLandBuilding, "SECURITYTYPE_CODE"));
        lb.put("SUBMISSIONDATE", formatDateForInput(rsLandBuilding, "SUBMISSIONDATE"));
        lb.put("VALUEDAMOUNT", getStringSafe(rsLandBuilding, "VALUEDAMOUNT"));
        lb.put("MARGINEPERCENTAGE", getStringSafe(rsLandBuilding, "MARGINEPERCENTAGE"));
        lb.put("AREA", getStringSafe(rsLandBuilding, "AREA"));
        lb.put("UNITOFAREA", getStringSafe(rsLandBuilding, "UNITOFAREA"));
        lb.put("LOCATION", getStringSafe(rsLandBuilding, "LOCATION"));
        lb.put("SECURITYVALUE", getStringSafe(rsLandBuilding, "SECURITYVALUE"));
        lb.put("REMARK", getStringSafe(rsLandBuilding, "REMARK"));
        lb.put("PARTICULAR", getStringSafe(rsLandBuilding, "PARTICULAR"));
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
            <input readonly value="<%= lb.get("SUBMISSIONDATE") %>">
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
            <label>Particular</label>
            <textarea readonly style="width: 97%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; font-size: 13px; resize: vertical;" rows="2"><%= lb.get("PARTICULAR") %></textarea>
          </div>
        </div>
      </div>
      <%
        }
      %>
    </fieldset>
<%
    }

    // Check for Deposit Details data
    psDeposit = conn.prepareStatement("SELECT * FROM APPLICATION.APPLICATIONSECURITYDEPOSIT WHERE APPLICATION_NUMBER = ? ORDER BY SERIAL_NUMBER");
    psDeposit.setString(1, appNo);
    rsDeposit = psDeposit.executeQuery();
    
    List<Map<String, String>> deposits = new ArrayList<>();
    while (rsDeposit.next()) {
        Map<String, String> deposit = new HashMap<>();
        deposit.put("SECURITYTYPE_CODE", getStringSafe(rsDeposit, "SECURITYTYPE_CODE"));
        deposit.put("SUBMISSIONDATE", formatDateForInput(rsDeposit, "SUBMISSIONDATE"));
        deposit.put("MARGINPERCENTAGE", getStringSafe(rsDeposit, "MARGINPERCENTAGE"));
        deposit.put("DEPOSITACCOUNT_CODE", getStringSafe(rsDeposit, "DEPOSITACCOUNT_CODE"));
        deposit.put("MATURITYDATE", formatDateForInput(rsDeposit, "MATURITYDATE"));
        deposit.put("SECURITYVALUE", getStringSafe(rsDeposit, "SECURITYVALUE"));
        deposit.put("TD_VALUE", getStringSafe(rsDeposit, "TD_VALUE"));
        deposit.put("PARTICULAR", getStringSafe(rsDeposit, "PARTICULAR"));
        deposits.add(deposit);
    }
    
    if (!deposits.isEmpty()) {
%>
    <fieldset>
      <legend>Deposit Details</legend>
      <%
        for (int i = 0; i < deposits.size(); i++) {
            Map<String, String> deposit = deposits.get(i);
      %>
      <div class="nominee-card" style="background: #e8e4fc; border: 1px solid #d0d0d0; border-radius: 10px; padding: 15px; margin-top: 15px;">
        <h4 style="color: #373279; margin-bottom: 10px;">Deposit <%= (i+1) %></h4>
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
            <label>Maturity Date</label>
            <input readonly value="<%= deposit.get("MATURITYDATE") %>">
          </div>
          <div>
            <label>Security Value</label>
            <input readonly value="<%= deposit.get("SECURITYVALUE") %>">
          </div>
          <div>
            <label>TD Value</label>
            <input readonly value="<%= deposit.get("TD_VALUE") %>">
          </div>
          <div>
            <label>Particular</label>
            <input readonly value="<%= deposit.get("PARTICULAR") %>">
          </div>
        </div>
      </div>
      <%
        }
      %>
    </fieldset>
<%
    }

    // Check for Gold/Silver data
    psGoldSilver = conn.prepareStatement("SELECT * FROM APPLICATION.APPLICATIONSECURITYGOLDSILVER WHERE APPLICATION_NUMBER = ? ORDER BY SERIAL_NUMBER");
    psGoldSilver.setString(1, appNo);
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
            <label>Security Type</label>
            <input readonly value="<%= gs.get("SECURITYTYPE_CODE") %>">
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
            <label>Margin %</label>
            <input readonly value="<%= gs.get("MARGINPERCENTAGE") %>">
          </div>
          <div>
            <label>Rate/Gram</label>
            <input readonly value="<%= gs.get("RATEPER10GMS") %>">
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
            <label>Particular</label>
            <input readonly value="<%= gs.get("PARTICULAR") %>">
          </div>
          <div>
            <label>Note</label>
            <textarea readonly style="width: 97%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; font-size: 13px; resize: vertical;" rows="2"><%= gs.get("NOTE") %></textarea>
          </div>
        </div>

      <%
        }
      %>
    </fieldset>
<%
    }
%>

<div style="text-align:center;">
    <button type="button" onclick="goBackToList();" class="back-btn"
        style="padding:10px 22px; background:#373279; color:white;
               border:none; border-radius:6px; cursor:pointer;
               font-size:16px; font-weight:bold;">
    ← Back to List
    </button>
</div>
</form>

<div style="text-align:center; margin-top:30px;">
    <form id="authorizeForm" action="UpdateApplicationStatusServlet" method="post" style="display:inline;">
        <input type="hidden" name="appNo" value="<%= appNo %>">
        <input type="hidden" name="status" value="A">
        <button type="button" onclick="showAuthorizeConfirmation(event)"
            style="padding:10px 22px; background:linear-gradient(45deg, #28a745, #34ce57); color:white;
                   border:none; border-radius:6px; cursor:pointer;
                   font-size:16px; font-weight:bold;">
            ✔ Authorize
        </button>
    </form>

    &nbsp;&nbsp;&nbsp;

    <form id="rejectForm" action="UpdateApplicationStatusServlet" method="post" style="display:inline;">
        <input type="hidden" name="appNo" value="<%= appNo %>">
        <input type="hidden" name="status" value="R">
        <button type="button" onclick="showRejectConfirmation(event)"
            style="padding:10px 22px; background:linear-gradient(45deg, #dc3545, #e74c3c); color:white;
                   border:none; border-radius:6px; cursor:pointer;
                   font-size:16px; font-weight:bold;">
            ✘ Reject
        </button>
    </form>
</div>

<div id="authorizeModal" class="confirmation-modal">
    <div class="confirmation-modal-content">
        <h2>✔ Confirm Authorization</h2>
        <p>Are you sure you want to <strong>authorize</strong> this application?<br>Application Number: <strong><%= appNo %></strong></p>
        <div class="confirmation-modal-buttons">
            <button class="confirmation-btn confirmation-btn-cancel" onclick="closeAuthorizeModal()">Cancel</button>
            <button class="confirmation-btn confirmation-btn-confirm" onclick="confirmAuthorize()">Yes, Authorize</button>
        </div>
    </div>
</div>

<div id="rejectModal" class="confirmation-modal">
    <div class="confirmation-modal-content">
        <h2>✘ Confirm Rejection</h2>
        <p>Are you sure you want to <strong>reject</strong> this application?<br>Application Number: <strong><%= appNo %></strong></p>
        <div class="confirmation-modal-buttons">
            <button class="confirmation-btn confirmation-btn-cancel" onclick="closeRejectModal()">Cancel</button>
            <button class="confirmation-btn confirmation-btn-reject" onclick="confirmReject()">Yes, Reject</button>
        </div>
    </div>
</div>
<script>
function showAuthorizeConfirmation(event) {
    event.preventDefault(); // Prevent default form submission
    document.getElementById('authorizeModal').style.display = 'block';
    return false; // Don't submit yet
}

function showRejectConfirmation(event) {
    event.preventDefault(); // Prevent default form submission
    document.getElementById('rejectModal').style.display = 'block';
    return false; // Don't submit yet
}

function closeAuthorizeModal() {
    document.getElementById('authorizeModal').style.display = 'none';
}

function closeRejectModal() {
    document.getElementById('rejectModal').style.display = 'none';
}

function confirmAuthorize() {
    document.getElementById('authorizeForm').submit();
}

function confirmReject() {
    document.getElementById('rejectForm').submit();
}
</script>
</body>
</html>

<%
    } 
    catch (Exception e) {
        out.println("<pre style='color:red'>Error: " + e.getMessage() + "</pre>");
        e.printStackTrace();
    } finally {
    	try { if (rsLoan != null) rsLoan.close(); } catch (Exception ex) {}
        try { if (rsMainDeposit != null) rsMainDeposit.close(); } catch (Exception ex) {}
        try { if (rsPigmy != null) rsPigmy.close(); } catch (Exception ex) {}
        try { if (rsFixed != null) rsFixed.close(); } catch (Exception ex) {}
        try { if (psLoan != null) psLoan.close(); } catch (Exception ex) {}
        try { if (psMainDeposit != null) psMainDeposit.close(); } catch (Exception ex) {}
        try { if (psPigmy != null) psPigmy.close(); } catch (Exception ex) {}
        try { if (psFixed != null) psFixed.close(); } catch (Exception ex) {}
        try { if (rsApp != null) rsApp.close(); } catch (Exception ex) {}
        try { if (rsNominee != null) rsNominee.close(); } catch (Exception ex) {}
        try { if (rsJoint != null) rsJoint.close(); } catch (Exception ex) {}
        try { if (rsCoBorrower != null) rsCoBorrower.close(); } catch (Exception ex) {}
        try { if (rsGuarantor != null) rsGuarantor.close(); } catch (Exception ex) {}
        try { if (rsLandBuilding != null) rsLandBuilding.close(); } catch (Exception ex) {}
        try { if (rsDeposit != null) rsDeposit.close(); } catch (Exception ex) {}
        try { if (rsGoldSilver != null) rsGoldSilver.close(); } catch (Exception ex) {}
        try { if (psApp != null) psApp.close(); } catch (Exception ex) {}
        try { if (psNominee != null) psNominee.close(); } catch (Exception ex) {}
        try { if (psJoint != null) psJoint.close(); } catch (Exception ex) {}
        try { if (psCoBorrower != null) psCoBorrower.close(); } catch (Exception ex) {}
        try { if (psGuarantor != null) psGuarantor.close(); } catch (Exception ex) {}
        try { if (psLandBuilding != null) psLandBuilding.close(); } catch (Exception ex) {}
        try { if (psDeposit != null) psDeposit.close(); } catch (Exception ex) {}
        try { if (psGoldSilver != null) psGoldSilver.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
        
    }
%>