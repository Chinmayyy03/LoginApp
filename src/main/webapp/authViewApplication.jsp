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
        window.parent.updateParentBreadcrumb('Authorization Pending Applications > View Details');
    }
};

function goBackToList() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Authorization Pending Applications');
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
          <input readonly value="<%= getStringSafe(rsApp,"ACCOUNTOPERATIONCAPACITY_ID") %>">
        </div>
        <div>
          <label>Min Balance ID</label>
          <input readonly value="<%= getStringSafe(rsApp,"MINBALANCE_ID") %>">
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
          <label>Installment Type Id</label>
          <input readonly value="<%= getStringSafe(rsLoan,"INSTALLMENTTYPE_ID") %>">
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
          <label>Area Code</label>
          <input readonly value="<%= getStringSafe(rsLoan,"AREA_CODE") %>">
        </div>
        <div>
          <label>Social Section Id</label>
          <input readonly value="<%= getStringSafe(rsLoan,"SOCIALSECTION_ID") %>">
        </div>
        <div>
          <label>Sub Area Code</label>
          <input readonly value="<%= getStringSafe(rsLoan,"SUBAREA_CODE") %>">
        </div>
        <div>
          <label>LBR Code</label>
          <input readonly value="<%= getStringSafe(rsLoan,"MIS_ID") %>">
        </div>
        <div>
          <label>Social Sector Id</label>
          <input readonly value="<%= getStringSafe(rsLoan,"SOCIALSECTOR_ID") %>">
        </div>
        <div>
          <label>Purpose Id</label>
          <input readonly value="<%= getStringSafe(rsLoan,"PURPOSE_ID") %>">
        </div>
        <div>
          <label>Social SubSector Id</label>
          <input readonly value="<%= getStringSafe(rsLoan,"SOCIALSUBSECTOR_ID") %>">
        </div>
        <div>
          <label>Classification Id</label>
          <input readonly value="<%= getStringSafe(rsLoan,"CLASSIFICATION_ID") %>">
        </div>
        <div>
          <label>Mode Of San. Id</label>
          <input readonly value="<%= getStringSafe(rsLoan,"MODEOFSANCTION_ID") %>">
        </div>
        <div>
          <label>Sanction Authority Id</label>
          <input readonly value="<%= getStringSafe(rsLoan,"SANCTIONAUTHORITY_ID") %>">
        </div>
        <div>
          <label>Industry Id</label>
          <input readonly value="<%= getStringSafe(rsLoan,"INDUSTRY_ID") %>">
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
            <input readonly value="<%= nominee.get("COUNTRY_CODE") %>">
          </div>
          <div>
            <label>State</label>
            <input readonly value="<%= nominee.get("STATE_CODE") %>">
          </div>
          <div>
            <label>City</label>
            <input readonly value="<%= nominee.get("CITY_CODE") %>">
          </div>
          <div>
            <label>ZIP</label>
            <input readonly value="<%= nominee.get("ZIP") %>">
          </div>
          <div>
            <label>Relation</label>
            <input readonly value="<%= nominee.get("RELATION_ID") %>">
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
            <input readonly value="<%= joint.get("COUNTRY_CODE") %>">
          </div>
          <div>
            <label>State</label>
            <input readonly value="<%= joint.get("STATE_CODE") %>">
          </div>
          <div>
            <label>City</label>
            <input readonly value="<%= joint.get("CITY_CODE") %>">
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
            <input readonly value="<%= coBorrower.get("COUNTRY_CODE") %>">
          </div>
          <div>
            <label>State</label>
            <input readonly value="<%= coBorrower.get("STATE_CODE") %>">
          </div>
          <div>
            <label>City</label>
            <input readonly value="<%= coBorrower.get("CITY_CODE") %>">
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
            <input readonly value="<%= guarantor.get("COUNTRY_CODE") %>">
          </div>
          <div>
            <label>State</label>
            <input readonly value="<%= guarantor.get("STATE_CODE") %>">
          </div>
          <div>
            <label>City</label>
            <input readonly value="<%= guarantor.get("CITY_CODE") %>">
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
            <input readonly value="<%= lb.get("SECURITYTYPE_CODE") %>">
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
          <div style="grid-column: span 3;">
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
            <input readonly value="<%= deposit.get("SECURITYTYPE_CODE") %>">
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
          <div style="grid-column: span 3;">
            <label>Note</label>
            <textarea readonly style="width: 97%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; font-size: 13px; resize: vertical;" rows="2"><%= gs.get("NOTE") %></textarea>
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
    <form id="authorizeForm" action="UpdateApplicationStatusServlet" method="post" style="display:inline;" onsubmit="return showAuthorizeConfirmation(event)">
        <input type="hidden" name="appNo" value="<%= appNo %>">
        <input type="hidden" name="status" value="A">
        <button type="submit"
            style="padding:10px 22px; background:linear-gradient(45deg, #28a745, #34ce57); color:white;
                   border:none; border-radius:6px; cursor:pointer;
                   font-size:16px; font-weight:bold;">
            ✔ Authorize
        </button>
    </form>

    &nbsp;&nbsp;&nbsp;

    <form id="rejectForm" action="UpdateApplicationStatusServlet" method="post" style="display:inline;" onsubmit="return showRejectConfirmation(event)">
        <input type="hidden" name="appNo" value="<%= appNo %>">
        <input type="hidden" name="status" value="R">
        <button type="submit"
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