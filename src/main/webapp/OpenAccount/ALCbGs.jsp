<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // ✅ FIX: Capture productCode from request parameter
    String productCode = request.getParameter("productCode");
    if (productCode == null) {
        productCode = "";
    }
    System.out.println("📌 ALCbGs.jsp - Product Code received: " + productCode);
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Saving Account Application</title>
  <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
  <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
<style>
body {
      background-color: #e8e4fc;
      font-family: Arial, sans-serif;
      margin: 20px;
      padding: 0;
    }

    fieldset {
      background: #e8e4fc;
      border: 2px solid #aaa;
      margin: 32px 0;
      padding: 15px 20px;
      min-width: 320px;
      border-radius: 9px;
    }

    legend {
      font-weight: bold;
      letter-spacing: 1px;
      font-size: 1.18em;
      padding: 0 10px;
      color: #373279;
    }

    .form-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 10px 20px;
    }

    .form-grid div {
      flex-direction: column;
    }

    label {
      min-width: 10px;
      font-size: 13px;
      margin-bottom: 3px;
      font-weight: bold;
      color: #373279;
    }

    input[type="text"],
    input[type="date"],
    input[type="email"],
    input[type="number"],
    select {
      padding: 4px 6px;
      font-size: 13px;
      width: 90%;
      box-sizing: border-box;
    }

    input[readonly] {
      background-color: #f0f0f0;
      cursor: not-allowed;
    }

.input-icon-box {
  position: relative;
  width: 90%;
}

.input-icon-box input {
  width: 100%;
  padding-right: 40px;   /* space for icon */
  height: 30px;
  cursor: pointer;
  box-sizing: border-box;
}

.input-icon-box .inside-icon-btn {
  position: absolute;
  right: 5px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  color: #373279;
}

    .customer-modal {
      display: none;
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0, 0, 0, 0.6);
      z-index: 9999;
      justify-content: center;
      align-items: center;
    }

    .customer-modal-content {
      background: white;
      width: 85%;
      max-width: 1000px;
      max-height: 85vh;
      overflow: auto;
      padding: 25px;
      border-radius: 12px;
      box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
      position: relative;
    }

    .customer-close {
      position: absolute;
      right: 20px;
      top: 15px;
      font-size: 32px;
      font-weight: bold;
      cursor: pointer;
      color: #666;
      transition: color 0.3s;
    }

    .customer-close:hover {
      color: #373279;
    }

    .lookup-title {
      font-size: 24px;
      margin-bottom: 20px;
      font-weight: bold;
      color: #373279;
      text-align: center;
    }

    .search-box {
      margin-bottom: 20px;
    }

    .search-box input {
      width: 100%;
      padding: 12px 15px;
      font-size: 15px;
      border: 2px solid #9c8ed8;
      border-radius: 8px;
      background-color: #f5f3ff;
      box-sizing: border-box;
    }

    .search-box input:focus {
      outline: none;
      border-color: #373279;
      background-color: #fff;
    }

    .table-container {
      max-height: 400px;
      overflow-y: auto;
      border: 1px solid #ddd;
      border-radius: 8px;
      background: white;
    }

    .customer-modal-content table {
      width: 100%;
      border-collapse: collapse;
    }

    .customer-modal-content th,
    .customer-modal-content td {
      border: 1px solid #ddd;
      padding: 12px 15px;
      text-align: left;
    }

    .customer-modal-content th {
      background-color: #373279;
      color: white;
      font-weight: bold;
      position: sticky;
      top: 0;
      z-index: 10;
    }

    .customer-modal-content tbody tr {
      transition: all 0.2s;
    }

    .customer-modal-content tbody tr:hover {
      background-color: #e8e4fc;
      cursor: pointer;
      transform: scale(1.01);
    }

    .customer-modal-content tbody tr:nth-child(even) {
      background-color: #f9f9f9;
    }

    .customer-count {
      text-align: right;
      margin-bottom: 10px;
      color: #666;
      font-size: 14px;
    }

    .personal-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 12px 25px;
      align-items: start;
    }

    .personal-grid div {
      display: flex;
      flex-direction: column;
    }

    .address-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 12px 25px;
      align-items: start;
    }

    .address-grid div {
      display: flex;
      flex-direction: column;
    }

    .nominee-card {
      background: #e8e4fc;
      border: 1px solid #d0d0d0;
      border-radius: 10px;
      padding: 15px;
      margin-top: 15px;
      box-shadow: 0px 2px 6px rgba(0,0,0,0.08);
    }

    .nominee-remove {
      float: right;
      background: #c62828;
      border: none;
      color: white;
      padding: 3px 8px;
      font-size: 12px;
      border-radius: 4px;
      cursor: pointer;
    }

    .form-buttons {
      display: flex;
      justify-content: center;
      align-items: center;
      margin: 25px 0;
      gap: 20px;
    }

    .form-buttons button {
      background-color: #373279;
      color: white;
      border: none;
      padding: 10px 25px;
      border-radius: 6px;
      font-size: 14px;
      font-weight: bold;
      cursor: pointer;
      transition: background-color 0.3s ease, transform 0.2s ease;
    }

    .form-buttons button:hover {
      background-color: #2b0d73;
      transform: scale(1.05);
    }

    @media (max-width: 1024px) {
      .form-grid, .personal-grid, .address-grid {
        grid-template-columns: repeat(2, 1fr);
      }
    }

    @media (max-width: 600px) {
      .form-grid, .personal-grid, .address-grid {
        grid-template-columns: 1fr;
      }
    }
    
    .inline-fields {
    display: flex;
    align-items: center;
    gap: 20px;   /* space between the two blocks */
}

/* Replace the existing Gold/Silver section CSS with this updated version */

/* Gold/Silver responsive grid - same as application fieldset */
.goldsilver-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px 20px;
}

.goldsilver-grid div {
  flex-direction: column;
}

/* Full-width note field */
.goldsilver-note-field {
  grid-column: span 3;
}

/* Media queries for responsive behavior */
@media (max-width: 1024px) {
  .goldsilver-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .goldsilver-note-field {
    grid-column: span 2;
  }
}

@media (max-width: 600px) {
  .goldsilver-grid {
    grid-template-columns: 1fr;
  }
  
  .goldsilver-note-field {
    grid-column: span 1;
  }
}    
</style>
</head>
<body>

<form action="SaveApplicationServlet" method="post" onsubmit="return validateForm()">
  <!-- ✅ FIX: Use JSP variable to set the value -->
  <input type="hidden" id="hiddenProductCode" name="productCode" value="<%= productCode %>">

  <fieldset>
    <legend>Application</legend>
    <div class="form-grid">
      
      <!-- ✅ ADD: Display Product Code for verification -->
      <div>
        <label>Product Code</label>
        <input type="text" value="<%= productCode %>" readonly style="background-color: #f0f0f0;">
      </div>
      
      <div>
        <label>Customer ID</label>
        <div class="input-icon-box">
          <input type="text" id="customerId" name="customerId" onclick="openCustomerLookup()" readonly required>
          <button type="button" class="inside-icon-btn" onclick="openCustomerLookup()" title="Search Customer">🔍</button>
        </div>
      </div>

      <div>
        <label>Customer Name</label>
        <input type="text" id="customerName" name="customerName" readonly>
      </div>
     
      <div>
        <label>Category Code</label>
        <input type="text" id="categoryCode" name="categoryCode" readonly>
      </div>

      <div>
        <label>Introducer A/c Code</label>
        <input type="text" name="introducerAccCode">
      </div>

      <div>
        <label>Introducer A/c Name</label>
        <input type="text" name="introducerAccName">
      </div>

      <div>
        <label>Date Of Application</label>
        <input type="date" name="dateOfApplication" required>
      </div>

      <div>
        <label>Account Operation Capacity</label>
        <select name="accountOperationCapacity" required>
          <option value="">-- Select Capacity --</option>
          <%
            PreparedStatement psAccOpCap = null;
            ResultSet rsAccOpCap = null;
            try (Connection connAccOp = DBConnection.getConnection()) {
              String sql = "SELECT ACCOUNTOPERATIONCAPACITY_ID, DESCRIPTION FROM GLOBALCONFIG.ACCOUNTOPERATIONCAPACITY ORDER BY ACCOUNTOPERATIONCAPACITY_ID";
              psAccOpCap = connAccOp.prepareStatement(sql);
              rsAccOpCap = psAccOpCap.executeQuery();
              while (rsAccOpCap.next()) {
                String capacityId = rsAccOpCap.getString("ACCOUNTOPERATIONCAPACITY_ID");
                String description = rsAccOpCap.getString("DESCRIPTION");
          %>
                <option value="<%= capacityId %>"><%= description %></option>
          <%
              }
            } catch (Exception e) {
              out.println("<option disabled>Error loading capacities</option>");
            } finally {
              if (rsAccOpCap != null) rsAccOpCap.close();
              if (psAccOpCap != null) psAccOpCap.close();
            }
          %>
        </select>
      </div>

      <div>
  <label>Min Balance</label>
  <select name="minBalanceID" required>
    <option value="">-- Select Min Balance --</option>
    <%
      PreparedStatement psMinBal = null;
      ResultSet rsMinBal = null;
      try (Connection connMinBal = DBConnection.getConnection()) {
        String sql = "SELECT MINBALANCE_ID, MINBALANCE FROM HEADOFFICE.ACCOUNTMINBALANCE ORDER BY MINBALANCE_ID";
        psMinBal = connMinBal.prepareStatement(sql);
        rsMinBal = psMinBal.executeQuery();

        while (rsMinBal.next()) {
          String id = rsMinBal.getString("MINBALANCE_ID");      // ID to store
          String value = rsMinBal.getString("MINBALANCE");      // Value to show
    %>
          <option value="<%= id %>"><%= value %></option>
    <%
        }
      } catch (Exception e) {
        out.println("<option disabled>Error loading Min Balance</option>");
      } finally {
        if (rsMinBal != null) rsMinBal.close();
        if (psMinBal != null) psMinBal.close();
      }
    %>
  </select>
</div>
<div>
  <label>Risk Category</label>
  <input type="text" id="riskCategory" name="riskCategory" readonly>
</div>
      
    </div>
  </fieldset>


<!-- Loan Details Section -->
<fieldset id="loanFieldset">
  <legend>Loan Details</legend>
  <div class="form-grid">
    <div>
      <label>Submission Date</label>
      <input type="date" name="submissionDate">
    </div>

    <div>
      <label>Resolution No</label>
      <input type="text" name="resolutionNo">
    </div>

    <div>
      <label>Registration Date</label>
      <input type="date" name="registrationDate">
    </div>

    <div>
      <label>Register Amount</label>
      <input type="number" step="0.01" name="registerAmount" value="0">
    </div>

    <div>
      <label>Limit Amount</label>
      <input type="number" step="0.01" name="limitAmount" value="0">
    </div>

    <div>
      <label>Drawing Power</label>
      <input type="number" step="0.01" name="drawingPower" value="0">
    </div>

    <div>
		<label for="sanctionDate">Sanction Date</label>
		<input type="date" id="sanctionDate" name="sanctionDate">  
	</div>

    <div>
      <label>Sanction Amount</label>
      <input type="number" step="0.01" name="sanctionAmount" value="0">
    </div>

    <div>
		<label for="loanPeriod">Period of Loan (months)</label>
  		<input type="number" id="loanPeriod" name="loanPeriod" min="1">
    </div>

    <div>
      <label for="reviewDate">A/c Review Date</label>
 	  <input type="date" id="reviewDate" name="reviewDate" readonly>
    </div>


	<div>
    		<label for="installmentTypeId">Installment Type Id</label>
    	<div class="input-icon-box">
        	<input type="text" id="installmentTypeId" name="installmentTypeId" 
               onclick="openInstallmentLookup()" readonly required>
        	<button type="button" class="inside-icon-btn" 
                onclick="openInstallmentLookup()" title="Search Installment Type">🔍</button>
    	</div>
	</div>


    <div>
      <label for="installmentType">Installment Type</label>
	  <input type="text" name="installmentType" id="installmentType" readonly>
    </div>

    <div>
      <label>Repayment Freq.</label>
      <select name="repaymentFreq">
        <option value="">-- Select --</option>
        <option value="Monthly">Monthly</option>
        <option value="Quarterly">Quarterly</option>
        <option value="Half-Yearly">Half-Yearly</option>
        <option value="Yearly">Yearly</option>
      </select>
    </div>

    <div>
      <label>Int. Calculation Method</label>
      <select name="intCalcMethod">
        <option value="">-- Select --</option>
        <option value="Reducing">Reducing</option>
        <option value="Flat">Flat</option>
      </select>
    </div>

    <div>
      <label>Interest Rate</label>
      <input type="number" step="0.01" name="interestRate" value="0">
    </div>

    <div>
      <label>Penal Int. Rate</label>
      <input type="number" step="0.01" name="penalIntRate" value="0">
    </div>

    <div>
      <label>Mor. Int. Rate</label>
      <input type="number" step="0.01" name="morIntRate" value="0">
    </div>

    <div>
      <label>Overdue Int. Rate</label>
      <input type="number" step="0.01" name="overdueIntRate" value="0">
    </div>

    <div>
      <label>Mor. Period Month</label>
      <input type="number" name="morPeriodMonth" value="0">
    </div>

    <div>
      <label>Inst. Amount</label>
      <input type="number" step="0.01" name="instAmount" value="0">
    </div>

    <div>
      <label>Consortium Loan</label>
      <div>
        <label><input type="radio" name="consortiumLoan" value="Y"> Yes</label>
        <label><input type="radio" name="consortiumLoan" value="N" checked> No</label>
      </div>
    </div>

<div>
  <label>Area Code</label>
  <div class="input-icon-box">
    <input type="text" id="areaCode" name="areaCode" 
           onclick="openAreaLookup()" readonly>
    <button type="button" class="inside-icon-btn" 
            onclick="openAreaLookup()" title="Search Area">🔍</button>
  </div>
</div>

<div>
  <label>Area Name</label>
  <input type="text" id="areaName" name="areaName" readonly>
</div>
    
       <div>
  <label>Social Section Id</label>
  <select name="socialSectionId" required>
    <option value="">-- Select Social Section --</option>

    <%
      PreparedStatement psSocial = null;
      ResultSet rsSocial = null;
      try (Connection connSocial = DBConnection.getConnection()) {
        String sql = "SELECT SOCIALSECTION_ID, DESCRIPTION FROM GLOBALCONFIG.SOCIALSECTION ORDER BY SOCIALSECTION_ID";
        psSocial = connSocial.prepareStatement(sql);
        rsSocial = psSocial.executeQuery();

        while (rsSocial.next()) {
          String id = rsSocial.getString("SOCIALSECTION_ID");   // ID to store
          String desc = rsSocial.getString("DESCRIPTION");      // Text to show
    %>
          <option value="<%= id %>"><%= desc %></option>
    <%
        }
      } catch (Exception e) {
        out.println("<option disabled>Error loading Social Section</option>");
      } finally {
        if (rsSocial != null) rsSocial.close();
        if (psSocial != null) psSocial.close();
      }
    %>

  </select>
</div>


<div>
  <label>Sub Area Code</label>
  <div class="input-icon-box">
    <input type="text" id="subAreaCode" name="subAreaCode" 
           onclick="openSubAreaLookup()" readonly>
    <button type="button" class="inside-icon-btn" 
            onclick="openSubAreaLookup()" title="Search Sub Area">🔍</button>
  </div>
</div>

<div>
  <label>Sub Area Name</label>
  <input type="text" id="subAreaName" name="subAreaName" readonly>
</div>
    
    <div>
  <label>LBR Code</label>
  <select name="lbrCode">
    <option value="">MIS</option>
    <%
      PreparedStatement psMIS = null;
      ResultSet rsMIS = null;

      try (Connection conMIS = DBConnection.getConnection()) {
        String sql = "SELECT MIS_ID, DESCRIPTION FROM HEADOFFICE.MIS ORDER BY DESCRIPTION";
        psMIS = conMIS.prepareStatement(sql);
        rsMIS = psMIS.executeQuery();

        while (rsMIS.next()) {
          String id = rsMIS.getString("MIS_ID");
          String desc = rsMIS.getString("DESCRIPTION");
    %>
          <option value="<%= id %>"><%= desc %></option>
    <%
        }
      } catch (Exception e) {
        out.println("<option disabled>Error loading LBR Code</option>");
      } finally {
        if (rsMIS != null) rsMIS.close();
        if (psMIS != null) psMIS.close();
      }
    %>
  </select>
</div>

    
    <div>
  <label>Social Sector Id</label>
  <div class="input-icon-box">
    <input type="text" id="socialSectorId" name="socialSectorId" 
           onclick="openSocialSectorLookup()" readonly required>
    <button type="button" class="inside-icon-btn" 
            onclick="openSocialSectorLookup()" title="Search Social Sector">🔍</button>
  </div>
</div>

<div>
  <label>Social Sector Description</label>
  <input type="text" id="socialSectorDesc" name="socialSectorDesc" readonly>
</div>

    <div>
  <label>Purpose Id</label>
  <select name="purposeId" required>
    <option value="">-- Select Purpose --</option>
    <%
      PreparedStatement psPurpose = null;
      ResultSet rsPurpose = null;
      try (Connection connPurpose = DBConnection.getConnection()) {

        String sql = "SELECT PURPOSE_ID, DESCRIPTION FROM HEADOFFICE.PURPOSE ORDER BY DESCRIPTION";
        psPurpose = connPurpose.prepareStatement(sql);
        rsPurpose = psPurpose.executeQuery();

        while (rsPurpose.next()) {
          String id = rsPurpose.getString("PURPOSE_ID");        // value to store
          String desc = rsPurpose.getString("DESCRIPTION");     // text to display
    %>
          <option value="<%= id %>"><%= desc %></option>
    <%
        }
      } catch (Exception e) {
        out.println("<option disabled>Error loading Purpose</option>");
      } finally {
        if (rsPurpose != null) rsPurpose.close();
        if (psPurpose != null) psPurpose.close();
      }
    %>
  </select>
</div>

    
    <div>
  <label>Social SubSector Id</label>
  <div class="input-icon-box">
    <input type="text" id="socialSubSectorId" name="socialSubSectorId" 
           onclick="openSocialSubSectorLookup()" readonly required>
    <button type="button" class="inside-icon-btn" 
            onclick="openSocialSubSectorLookup()" title="Search Social SubSector">🔍</button>
  </div>
</div>

<div>
  <label>Social SubSector Description</label>
  <input type="text" id="socialSubSectorDesc" name="socialSubSectorDesc" readonly>
</div>

    <div>
  <label>Classification Id</label>
  <select name="classificationId">
    <option value="">NOT SPECIFIED</option>
    <%
      PreparedStatement psClass = null;
      ResultSet rsClass = null;

      try (Connection connClass = DBConnection.getConnection()) {

        String sql = "SELECT CLASSIFICATION_ID, DESCRIPTION FROM HEADOFFICE.CLASSIFICATION ORDER BY DESCRIPTION";
        psClass = connClass.prepareStatement(sql);
        rsClass = psClass.executeQuery();

        while (rsClass.next()) {
          String id = rsClass.getString("CLASSIFICATION_ID");     // value to store
          String desc = rsClass.getString("DESCRIPTION");         // visible text
    %>
          <option value="<%= id %>"><%= desc %></option>
    <%
        }

      } catch (Exception e) {
        out.println("<option disabled>Error loading Classification</option>");
      } finally {
        if (rsClass != null) rsClass.close();
        if (psClass != null) psClass.close();
      }
    %>
  </select>
</div>

    <div>
  <label>Mode Of San. Id</label>
  <select name="modeOfSanId">
    <option value="">NOT SPECIFIED</option>
    <%
      PreparedStatement psMOS = null;
      ResultSet rsMOS = null;

      try (Connection conMOS = DBConnection.getConnection()) {
        String sql = "SELECT MODEOFSANCTION_ID, DESCRIPTION FROM HEADOFFICE.MODEOFSANCTION ORDER BY DESCRIPTION";
        psMOS = conMOS.prepareStatement(sql);
        rsMOS = psMOS.executeQuery();

        while (rsMOS.next()) {
          String id = rsMOS.getString("MODEOFSANCTION_ID");
          String desc = rsMOS.getString("DESCRIPTION");
    %>
          <option value="<%= id %>"><%= desc %></option>
    <%
        }
      } catch (Exception e) {
        out.println("<option disabled>Error loading Mode of Sanction</option>");
      } finally {
        if (rsMOS != null) rsMOS.close();
        if (psMOS != null) psMOS.close();
      }
    %>
  </select>
</div>


    <div>
  <label>Sanction Authority Id</label>
  <select name="sanctionAuthorityId">
    <option value="">BRANCH CHAIRMAN</option>
    <%
      PreparedStatement psSA = null;
      ResultSet rsSA = null;

      try (Connection conSA = DBConnection.getConnection()) {
        String sql = "SELECT SANCTIONAUTHORITY_ID, DESCRIPTION FROM HEADOFFICE.SANCTIONAUTHORITY ORDER BY DESCRIPTION";
        psSA = conSA.prepareStatement(sql);
        rsSA = psSA.executeQuery();

        while (rsSA.next()) {
          String id = rsSA.getString("SANCTIONAUTHORITY_ID");
          String desc = rsSA.getString("DESCRIPTION");
    %>
          <option value="<%= id %>"><%= desc %></option>
    <%
        }
      } catch (Exception e) {
        out.println("<option disabled>Error loading Sanction Authority</option>");
      } finally {
        if (rsSA != null) rsSA.close();
        if (psSA != null) psSA.close();
      }
    %>
  </select>
</div>


    <div>
  <label>Industry Id</label>
  <select name="industryId">
    <option value="">NOT SPECIFIED</option>
    <%
      PreparedStatement psInd = null;
      ResultSet rsInd = null;

      try (Connection conInd = DBConnection.getConnection()) {
        String sql = "SELECT INDUSTRY_ID, DESCRIPTION FROM HEADOFFICE.INDUSTRY ORDER BY DESCRIPTION";
        psInd = conInd.prepareStatement(sql);
        rsInd = psInd.executeQuery();

        while (rsInd.next()) {
          String id = rsInd.getString("INDUSTRY_ID");
          String desc = rsInd.getString("DESCRIPTION");
    %>
          <option value="<%= id %>"><%= desc %></option>
    <%
        }
      } catch (Exception e) {
        out.println("<option disabled>Error loading Industry</option>");
      } finally {
        if (rsInd != null) rsInd.close();
        if (psInd != null) psInd.close();
      }
    %>
  </select>
</div>


    <div>
  <label>Is Director Related</label>
  <div>
    <label><input type="radio" name="isDirectorRelated" value="Y" onclick="toggleDirectorFields()"> Yes</label>
    <label><input type="radio" name="isDirectorRelated" value="N" checked onclick="toggleDirectorFields()"> No</label>
  </div>
</div>

<div>
  <label>Director Id</label>
  <input type="text" name="directorId" id="directorId" value="0">
</div>

<div>
  <label>Director Name</label>
  <input type="text" name="directorName" id="directorName">
</div>

  </div> <!-- end .form-grid -->
</fieldset>


<!-- Co-Borrower Section -->
<fieldset id="coBorrowerFieldset">
  <legend>
    Co-Borrower
    <button type="button" onclick="addCoBorrower()" 
      style="border:none;background:#373279;color:white;padding:2px 10px;
        border-radius:5px;cursor:pointer;font-size:12px;margin-left:10px;">
      ➕
    </button>
  </legend>

  <div class="nominee-card coBorrower-block">
    <button type="button" class="nominee-remove" onclick="removeCoBorrower(this)">✖</button>

    <div class="nominee-title" 
         style="font-weight:bold; font-size:15px; margin-bottom:10px; color:#373279;">
      Co-Borrower <span class="coBorrower-serial">1</span>
    </div>
    
    <div class="inline-fields">
      <div>
        <label>Has Customer ID ?</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="coBorrowerHasCustomerID_1" class="coBorrowerHasCustomerRadio" value="yes" onchange="toggleCoBorrowerCustomerID(this)"> Yes</label>
          <label><input type="radio" name="coBorrowerHasCustomerID_1" class="coBorrowerHasCustomerRadio" value="no" onchange="toggleCoBorrowerCustomerID(this)" checked> No</label>
        </div>
      </div>

      <div class="coBorrowerCustomerIDContainer" style="display:none; margin-top:10px;">
        <label>Customer ID</label>
        <div class="input-icon-box">
          <input type="text" class="coBorrowerCustomerIDInput" name="coBorrowerCustomerID[]" onclick="openCoBorrowerCustomerLookup(this)" readonly>
          <button type="button" class="inside-icon-btn" onclick="openCoBorrowerCustomerLookup(this)" title="Search Customer">🔍</button>
        </div>
      </div>
    </div>

    <br>

    <div class="personal-grid">
      <!-- ✅ FIXED: Changed from nomineeSalutation[] to coBorrowerSalutation[] -->
      <div>
        <label>Salutation Code</label>
        <select name="coBorrowerSalutation[]" required>
          <option value="">-- Select Salutation Code --</option>
          <%
              PreparedStatement psCoBorrowerSal = null;
              ResultSet rsCoBorrowerSal = null;
              try (Connection connCoBorrowerSal = DBConnection.getConnection()) {
                  String sql = "SELECT SALUTATION_CODE FROM GLOBALCONFIG.SALUTATION ORDER BY SALUTATION_CODE";
                  psCoBorrowerSal = connCoBorrowerSal.prepareStatement(sql);
                  rsCoBorrowerSal = psCoBorrowerSal.executeQuery();
                  while (rsCoBorrowerSal.next()) {
                      String salCode = rsCoBorrowerSal.getString("SALUTATION_CODE");
          %>
                      <option value="<%= salCode %>"><%= salCode %></option>
          <%
                  }
              } catch (Exception e) {
                  out.println("<option disabled>Error loading Salutation Code</option>");
                  e.printStackTrace();
              } finally {
                  if (rsCoBorrowerSal != null) rsCoBorrowerSal.close();
                  if (psCoBorrowerSal != null) psCoBorrowerSal.close();
              }
          %>
        </select>
      </div>

      <!-- ✅ FIXED: Changed from nomineeName[] to coBorrowerName[] -->
      <div>
        <label>Co-Borrower Name</label>
        <input type="text" name="coBorrowerName[]" required>
      </div>

      <div>
        <label>Address 1</label>
        <input type="text" name="coBorrowerAddress1[]">
      </div>

      <div>
        <label>Address 2</label>
        <input type="text" name="coBorrowerAddress2[]">
      </div>

      <div>
        <label>Address 3</label>
        <input type="text" name="coBorrowerAddress3[]">
      </div>

      <!-- ✅ FIXED: Changed from countryCode to coBorrowerCountry[] -->
      <div>
        <label>Country</label>
        <select name="coBorrowerCountry[]" required>
          <option value="">-- Select Country --</option>
          <%
            PreparedStatement psCountryCoBorrower = null;
            ResultSet rsCountryCoBorrower = null;
            try (Connection connCountryCB = DBConnection.getConnection()) {
                String sql = "SELECT COUNTRY_CODE, NAME FROM GLOBALCONFIG.COUNTRY ORDER BY NAME";
                psCountryCoBorrower = connCountryCB.prepareStatement(sql);
                rsCountryCoBorrower = psCountryCoBorrower.executeQuery();
                while (rsCountryCoBorrower.next()) {
                    String code = rsCountryCoBorrower.getString("COUNTRY_CODE");
                    String name = rsCountryCoBorrower.getString("NAME");
          %>
                <option value="<%= code %>"><%= name %></option>
          <%
                }
            } catch (Exception e) {
                out.println("<option disabled>Error loading countries</option>");
            } finally {
                if (rsCountryCoBorrower != null) rsCountryCoBorrower.close();
                if (psCountryCoBorrower != null) psCountryCoBorrower.close();
            }
          %>
        </select>
      </div>

      <!-- ✅ FIXED: Changed from stateCode to coBorrowerState[] -->
      <div>
        <label>State</label>
        <select name="coBorrowerState[]" required>
          <option value="">-- Select State --</option>
          <%
            PreparedStatement psStateCoBorrower = null;
            ResultSet rsStateCoBorrower = null;
            try (Connection connStateCB = DBConnection.getConnection()) {
                String sql = "SELECT STATE_CODE, NAME FROM GLOBALCONFIG.STATE ORDER BY NAME";
                psStateCoBorrower = connStateCB.prepareStatement(sql);
                rsStateCoBorrower = psStateCoBorrower.executeQuery();
                while (rsStateCoBorrower.next()) {
                    String code = rsStateCoBorrower.getString("STATE_CODE");
                    String name = rsStateCoBorrower.getString("NAME");
          %>
                <option value="<%= code %>"><%= name %></option>
          <%
                }
            } catch (Exception e) {
                out.println("<option disabled>Error loading states</option>");
            } finally {
                if (rsStateCoBorrower != null) rsStateCoBorrower.close();
                if (psStateCoBorrower != null) psStateCoBorrower.close();
            }
          %>
        </select>
      </div>

      <!-- ✅ FIXED: Changed from cityCode to coBorrowerCity[] -->
      <div>
        <label>City</label>
        <select name="coBorrowerCity[]" required>
          <option value="">-- Select City --</option>
          <%
            PreparedStatement psCityCoBorrower = null;
            ResultSet rsCityCoBorrower = null;
            try (Connection connCityCB = DBConnection.getConnection()) {
                String sql = "SELECT CITY_CODE, NAME FROM GLOBALCONFIG.CITY ORDER BY UPPER(NAME)";
                psCityCoBorrower = connCityCB.prepareStatement(sql);
                rsCityCoBorrower = psCityCoBorrower.executeQuery();
                while (rsCityCoBorrower.next()) {
                    String code = rsCityCoBorrower.getString("CITY_CODE");
                    String name = rsCityCoBorrower.getString("NAME");
          %>
                <option value="<%= code %>"><%= name %></option>
          <%
                }
            } catch (Exception e) {
                out.println("<option disabled>Error loading cities</option>");
            } finally {
                if (rsCityCoBorrower != null) rsCityCoBorrower.close();
                if (psCityCoBorrower != null) psCityCoBorrower.close();
            }
          %>
        </select>
      </div>

      <div>
        <label>Zip</label>
        <input type="number" name="coBorrowerZip[]" value="0">
      </div>
    </div>
  </div>
</fieldset>

<!-- Gold/Silver Security Section -->
<!-- Gold/Silver Security Section -->
<fieldset id="goldSilverFieldset">
  <legend>
    Gold/Silver
    <button type="button" onclick="addGoldSilver()"
      style="border:none;background:#373279;color:white;padding:2px 10px;
        border-radius:5px;cursor:pointer;font-size:12px;margin-left:10px;">
      ➕
    </button>
  </legend>

  <div class="nominee-card goldsilver-block">
    <button type="button" class="nominee-remove" onclick="removeGoldSilver(this)">✖</button>

    <div class="nominee-title"
         style="font-weight:bold; font-size:15px; margin-bottom:10px; color:#373279;">
      Gold/Silver <span class="goldsilver-serial">1</span>
    </div>

    <!-- ✅ Changed from form-grid to goldsilver-grid -->
    <div class="goldsilver-grid">
      <div>
        <label>Security Type Code</label>
        <select name="gsSecurityType[]" required>
          <option value="">-- Select Security Type --</option>
          <%
            PreparedStatement psSecType = null;
            ResultSet rsSecType = null;
            try (Connection connSecType = DBConnection.getConnection()) {
              String sql = "SELECT SECURITYTYPE_CODE FROM GLOBALCONFIG.SECURITYTYPE ORDER BY SECURITYTYPE_CODE";
              psSecType = connSecType.prepareStatement(sql);
              rsSecType = psSecType.executeQuery();
              
              while (rsSecType.next()) {
                String securityType = rsSecType.getString("SECURITYTYPE_CODE");
          %>
                <option value="<%= securityType %>"><%= securityType %></option>
          <%
              }
            } catch (Exception e) {
              out.println("<option disabled>Error loading Security Types</option>");
              e.printStackTrace();
            } finally {
              if (rsSecType != null) rsSecType.close();
              if (psSecType != null) psSecType.close();
            }
          %>
        </select>
      </div>

      <div>
        <label>Submission Date</label>
        <input type="date" name="gsSubmissionDate[]">
      </div>

      <div>
        <label>Gold Bag No.</label>
        <input type="number" name="gsGoldBagNo[]" value="0">
      </div>

      <div>
        <label>Total Wt.In Grm</label>
        <input type="number" step="0.01" name="gsTotalWeight[]" value="0">
      </div>

      <div>
        <label>Margin %</label>
        <input type="number" step="0.01" name="gsMargin[]" value="0">
      </div>

      <div>
        <label>Rate/Grams</label>
        <input type="number" step="0.01" name="gsRatePerGram[]" value="0">
      </div>

      <div>
        <label>Total Value</label>
        <input type="number" step="0.01" name="gsTotalValue[]" value="0" 
               onchange="calculateSecurityValue(this)">
      </div>

      <div>
        <label>Security Value</label>
        <input type="number" step="0.01" name="gsSecurityValue[]" value="0" readonly 
               style="background-color: #f0f0f0;">
      </div>

      <div>
        <label>Particular</label>
        <input type="text" name="gsParticular[]">
      </div>

      <!-- ✅ Changed from grid-column: span 3 to using goldsilver-note-field class -->
      <div class="goldsilver-note-field">
        <label>Note</label>
        <textarea name="gsNote[]" rows="2" style="width: 97%; padding: 8px; 
                  border: 1px solid #ccc; border-radius: 4px; font-size: 13px;
                  font-family: Arial, sans-serif;"></textarea>
      </div>
    </div>
  </div>
</fieldset>



<div class="form-buttons">
    <button type="submit">Save</button>
    <button type="reset">Reset</button>
  </div>
</form>

<!-- Customer Lookup Modal -->
<div id="customerLookupModal" class="customer-modal">
  <div class="customer-modal-content">
    <span class="customer-close" onclick="closeCustomerLookup()">&times;</span>
    <div id="customerLookupContent">
      <!-- Content will be loaded here -->
    </div>
  </div>
</div>

<!-- INSTALLMENT TYPE LOOKUP MODAL -->
<div id="installmentLookupModal" class="customer-modal">
    <div class="customer-modal-content">
        <span class="customer-close" onclick="closeInstallmentLookup()">&times;</span>
        <div id="installmentLookupContent"></div>
    </div>
</div>
<!-- SOCIAL SECTOR LOOKUP MODAL -->
<div id="socialSectorLookupModal" class="customer-modal">
    <div class="customer-modal-content">
        <span class="customer-close" onclick="closeSocialSectorLookup()">&times;</span>
        <div id="socialSectorLookupContent"></div>
    </div>
</div>

<!-- SOCIAL SUBSECTOR LOOKUP MODAL -->
<div id="socialSubSectorLookupModal" class="customer-modal">
    <div class="customer-modal-content">
        <span class="customer-close" onclick="closeSocialSubSectorLookup()">&times;</span>
        <div id="socialSubSectorLookupContent"></div>
    </div>
</div>
<!-- AREA LOOKUP MODAL -->
<div id="areaLookupModal" class="customer-modal">
    <div class="customer-modal-content">
        <span class="customer-close" onclick="closeAreaLookup()">&times;</span>
        <div id="areaLookupContent"></div>
    </div>
</div>

<!-- SUB AREA LOOKUP MODAL -->
<div id="subAreaLookupModal" class="customer-modal">
    <div class="customer-modal-content">
        <span class="customer-close" onclick="closeSubAreaLookup()">&times;</span>
        <div id="subAreaLookupContent"></div>
    </div>
</div>
<script src="js/application.js"></script>
<script src="js/savingAcc.js"></script>
<script>
//==================== INSTALLMENT TYPE LOOKUP ====================
function openInstallmentLookup() {
    let url = "lookupForLoan.jsp";

    // Load JSP content into modal using fetch()
    fetch(url)
        .then(response => response.text())
        .then(html => {
            document.getElementById("installmentLookupContent").innerHTML = html;
            document.getElementById("installmentLookupModal").style.display = "flex";
            
            // ✅ Execute any scripts in the loaded content
            const scripts = document.getElementById("installmentLookupContent").querySelectorAll('script');
            scripts.forEach(script => {
                const newScript = document.createElement('script');
                newScript.textContent = script.textContent;
                document.body.appendChild(newScript);
            });
        })
        .catch(error => {
            showToast('❌ Failed to load lookup data. Please try again.');
            console.error('Lookup error:', error);
        });
}

function closeInstallmentLookup() {
    document.getElementById("installmentLookupModal").style.display = "none";
}

// ✅ Global function to set installment data (called from lookupForLoan.jsp)
window.setInstallmentData = function(id, desc) {
    document.getElementById("installmentTypeId").value = id;
    document.getElementById("installmentType").value = desc;
    
    closeInstallmentLookup();
    showToast('✅ Installment Type selected successfully!');
};

//==================== SOCIAL SECTOR LOOKUP ====================

function openSocialSectorLookup() {
    let url = "lookupForLoan.jsp?type=socialSector";

    fetch(url)
        .then(response => response.text())
        .then(html => {
            document.getElementById("socialSectorLookupContent").innerHTML = html;
            document.getElementById("socialSectorLookupModal").style.display = "flex";
            
            const scripts = document.getElementById("socialSectorLookupContent").querySelectorAll('script');
            scripts.forEach(script => {
                const newScript = document.createElement('script');
                newScript.textContent = script.textContent;
                document.body.appendChild(newScript);
            });
        })
        .catch(error => {
            showToast('❌ Failed to load social sector lookup data. Please try again.');
            console.error('Lookup error:', error);
        });
}

function closeSocialSectorLookup() {
    document.getElementById("socialSectorLookupModal").style.display = "none";
}

window.setSocialSectorData = function(id, desc) {
    document.getElementById("socialSectorId").value = id;
    document.getElementById("socialSectorDesc").value = desc;
    
    // Clear subsector when sector changes
    document.getElementById("socialSubSectorId").value = '';
    document.getElementById("socialSubSectorDesc").value = '';
    
    closeSocialSectorLookup();
    showToast('✅ Social Sector selected successfully!');
};

//==================== SOCIAL SUBSECTOR LOOKUP ====================

function openSocialSubSectorLookup() {
    const sectorId = document.getElementById("socialSectorId").value;
    
    if (!sectorId) {
        showToast('⚠️ Please select Social Sector first!');
        return;
    }
    
    let url = "lookupForLoan.jsp?type=socialSubSector&sectorId=" + encodeURIComponent(sectorId);

    fetch(url)
        .then(response => response.text())
        .then(html => {
            document.getElementById("socialSubSectorLookupContent").innerHTML = html;
            document.getElementById("socialSubSectorLookupModal").style.display = "flex";
            
            const scripts = document.getElementById("socialSubSectorLookupContent").querySelectorAll('script');
            scripts.forEach(script => {
                const newScript = document.createElement('script');
                newScript.textContent = script.textContent;
                document.body.appendChild(newScript);
            });
        })
        .catch(error => {
            showToast('❌ Failed to load social subsector lookup data. Please try again.');
            console.error('Lookup error:', error);
        });
}

function closeSocialSubSectorLookup() {
    document.getElementById("socialSubSectorLookupModal").style.display = "none";
}

window.setSocialSubSectorData = function(id, desc) {
    document.getElementById("socialSubSectorId").value = id;
    document.getElementById("socialSubSectorDesc").value = desc;
    
    closeSocialSubSectorLookup();
    showToast('✅ Social SubSector selected successfully!');
};
// Validation function
function validateForm() {
    const customerId = document.getElementById('customerId').value.trim();
    
    if (!customerId) {
        showToast('❌ Please select a customer before submitting');
        return false;
    }
    
    return true;
}

// Check URL parameters for success/error messages
window.addEventListener('DOMContentLoaded', function() {
    const urlParams = new URLSearchParams(window.location.search);
    const status = urlParams.get('status');
    const applicationNumber = urlParams.get('applicationNumber');
    const message = urlParams.get('message');
    
    if (status === 'success' && applicationNumber) {
        Toastify({
            text: "✅ Application saved successfully!\nApplication Number: " + applicationNumber,
            duration: 6000,
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
                marginTop: "20px",
                whiteSpace: "pre-line"
            },
            stopOnFocus: true
        }).showToast();
        
        // Clear URL parameters after showing toast
        setTimeout(function() {
            const cleanUrl = window.location.pathname + window.location.search.replace(/[?&](status|applicationNumber|message)=[^&]*/g, '').replace(/^&/, '?').replace(/\?$/, '');
            window.history.replaceState({}, document.title, cleanUrl || window.location.pathname);
        }, 100);
        
    } else if (status === 'error') {
        Toastify({
            text: "❌ Error: " + (message || "Failed to save application"),
            duration: 6000,
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
        
        // Clear URL parameters after showing toast
        setTimeout(function() {
            const cleanUrl = window.location.pathname + window.location.search.replace(/[?&](status|applicationNumber|message)=[^&]*/g, '').replace(/^&/, '?').replace(/\?$/, '');
            window.history.replaceState({}, document.title, cleanUrl || window.location.pathname);
        }, 100);
    }
});


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

    // Check if this is for Co-Borrower lookup
    if (window.currentCoBorrowerInput) {
        window.currentCoBorrowerInput.value = customerId;
        fetchCustomerDetails(customerId, 'coborrower', window.currentCoBorrowerBlock);
        window.currentCoBorrowerInput = null;
        window.currentCoBorrowerBlock = null;
        closeCustomerLookup();
        showToast('✅ Loading co-borrower customer data...');
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
                } else if (type === 'coborrower') {
                    populateCoBorrowerFields(block, data.customer);
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
//==================== GOLD/SILVER SECURITY FUNCTIONS ====================

function addGoldSilver() {
  let fieldset = document.getElementById("goldSilverFieldset");
  let original = fieldset.querySelector(".goldsilver-block");
  let clone = original.cloneNode(true);

  // Clear all input fields
  clone.querySelectorAll("input, select, textarea").forEach(el => {
    if (el.tagName === 'SELECT') {
      el.selectedIndex = 0;
    } else if (el.name === 'gsSerialNo[]') {
      // Keep readonly, will be updated by updateGoldSilverSerials
    } else if (el.name === 'gsTotalWeight[]' || el.name === 'gsMargin[]' || 
               el.name === 'gsRatePerGram[]' || el.name === 'gsTotalValue[]' || 
               el.name === 'gsSecurityValue[]' || el.name === 'gsGoldBagNo[]') {
      el.value = '0';
    } else {
      el.value = "";
    }
  });

  clone.querySelector(".nominee-remove").onclick = function() {
    removeGoldSilver(this);
  };

  fieldset.appendChild(clone);
  updateGoldSilverSerials();
}

function removeGoldSilver(btn) {
  let blocks = document.querySelectorAll(".goldsilver-block");
  if (blocks.length <= 1) {
	    showToast("⚠️ At least one gold/silver entry is required.", "warning");
	    return;
	}
  btn.parentNode.remove();
  updateGoldSilverSerials();
}

function updateGoldSilverSerials() {
  let blocks = document.querySelectorAll(".goldsilver-block");
  blocks.forEach((block, index) => {
    let serial = block.querySelector(".goldsilver-serial");
    if (serial) {
      serial.textContent = (index + 1);
    }
    
    // Update Sr No input
    let srNoInput = block.querySelector('input[name="gsSerialNo[]"]');
    if (srNoInput) {
      srNoInput.value = (index + 1);
    }
  });
}

// Calculate Security Value based on Total Value and Margin
function calculateSecurityValue(totalValueInput) {
  const block = totalValueInput.closest('.goldsilver-block');
  const totalValue = parseFloat(totalValueInput.value) || 0;
  const marginInput = block.querySelector('input[name="gsMargin[]"]');
  const securityValueInput = block.querySelector('input[name="gsSecurityValue[]"]');
  
  const margin = parseFloat(marginInput.value) || 0;
  
  // Security Value = Total Value - (Total Value * Margin / 100)
  const securityValue = totalValue - (totalValue * margin / 100);
  
  securityValueInput.value = securityValue.toFixed(2);
}

// Auto-calculate when margin changes
document.addEventListener('DOMContentLoaded', function() {
  document.addEventListener('input', function(e) {
    if (e.target.name === 'gsMargin[]') {
      const block = e.target.closest('.goldsilver-block');
      const totalValueInput = block.querySelector('input[name="gsTotalValue[]"]');
      if (totalValueInput) {
        calculateSecurityValue(totalValueInput);
      }
    }
  });
});
//==================== CO-BORROWER FUNCTIONS (FIXED) ====================

function toggleCoBorrowerCustomerID(radio) {
  const coBorrowerBlock = radio.closest('.coBorrower-block');
  const container = coBorrowerBlock.querySelector('.coBorrowerCustomerIDContainer');
  const input = coBorrowerBlock.querySelector('.coBorrowerCustomerIDInput');

  if (radio.value === 'yes') {
      container.style.display = 'block';
      input.required = true;
  } else {
      container.style.display = 'none';
      input.required = false;
      input.value = '';
      clearCoBorrowerFields(coBorrowerBlock);
  }
}

function clearCoBorrowerFields(block) {
  // ✅ FIXED: Updated field names
  block.querySelector('select[name="coBorrowerSalutation[]"]').value = '';
  block.querySelector('input[name="coBorrowerName[]"]').value = '';
  block.querySelector('input[name="coBorrowerAddress1[]"]').value = '';
  block.querySelector('input[name="coBorrowerAddress2[]"]').value = '';
  block.querySelector('input[name="coBorrowerAddress3[]"]').value = '';
  block.querySelector('select[name="coBorrowerCountry[]"]').value = '';
  block.querySelector('select[name="coBorrowerState[]"]').value = '';
  block.querySelector('select[name="coBorrowerCity[]"]').value = '';
  block.querySelector('input[name="coBorrowerZip[]"]').value = '0';
}

//Update Co-Borrower Customer Lookup
function openCoBorrowerCustomerLookup(button) {
  const coBorrowerBlock = button.closest('.coBorrower-block');
  const input = coBorrowerBlock.querySelector('.coBorrowerCustomerIDInput');
  window.currentCoBorrowerInput = input;
  window.currentCoBorrowerBlock = coBorrowerBlock;
  
  // ✅ Get main customer ID to exclude from lookup
  const mainCustomerId = document.getElementById('customerId')?.value || null;
  openCustomerLookup(mainCustomerId);
}



function addCoBorrower() {
  let fieldset = document.getElementById("coBorrowerFieldset");
  let original = fieldset.querySelector(".coBorrower-block");
  let clone = original.cloneNode(true);

  clone.querySelectorAll("input, select").forEach(el => {
      if (el.type === 'radio') {
          if (el.value === 'no') el.checked = true;
          else el.checked = false;
      } else if (el.tagName === 'SELECT') {
          el.selectedIndex = 0;
      } else if (el.name === 'coBorrowerZip[]') {
          el.value = '0';
      } else {
          el.value = "";
      }
  });

  const customerIDContainer = clone.querySelector('.coBorrowerCustomerIDContainer');
  if (customerIDContainer) {
      customerIDContainer.style.display = 'none';
  }

  const coBorrowerBlocks = fieldset.querySelectorAll(".coBorrower-block");
  const newIndex = coBorrowerBlocks.length + 1;
  const radios = clone.querySelectorAll('.coBorrowerHasCustomerRadio');
  radios.forEach(radio => {
      radio.name = `coBorrowerHasCustomerID_${newIndex}`;
  });

  clone.querySelector(".nominee-remove").onclick = function() {
      removeCoBorrower(this);
  };

  fieldset.appendChild(clone);
  updateCoBorrowerSerials();
}

function removeCoBorrower(btn) {
  let blocks = document.querySelectorAll(".coBorrower-block");
  if (blocks.length <= 1) {
	    showToast("⚠️ At least one co-borrower is required.", "warning");
	    return;
	}
  btn.parentNode.remove();
  updateCoBorrowerSerials();
}

function updateCoBorrowerSerials() {
  let blocks = document.querySelectorAll(".coBorrower-block");
  blocks.forEach((block, index) => {
      let serial = block.querySelector(".coBorrower-serial");
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


 // for able and disable is Director Related
function toggleDirectorFields() {
	  const isRelated = document.querySelector('input[name="isDirectorRelated"]:checked').value;
	  
	  const idField = document.getElementById('directorId');
	  const nameField = document.getElementById('directorName');

	  if (isRelated === 'Y') {
	    idField.disabled = false;
	    nameField.disabled = false;
	  } else {
	    idField.disabled = true;
	    nameField.disabled = true;
	    idField.value = "0";       // optional: reset value
	    nameField.value = "";      // optional: clear name
	  }
	}

	// call once on page load to apply initial state
	toggleDirectorFields();
	
	function calcReviewDate() {
	    const sanctionVal = document.getElementById('sanctionDate').value;
	    const months = parseInt(document.getElementById('loanPeriod').value, 10);

	    // Need both fields
	    if (!sanctionVal || isNaN(months) || months <= 0) {
	      document.getElementById('reviewDate').value = '';
	      return;
	    }

	    // Start from selected sanction date
	    const d = new Date(sanctionVal);   // sanctionVal is "YYYY-MM-DD"
	    d.setMonth(d.getMonth() + months); // add months

	    const yyyy = d.getFullYear();
	    const mm = String(d.getMonth() + 1).padStart(2, '0');
	    const dd = String(d.getDate()).padStart(2, '0');
	    const reviewStr = yyyy + '-' + mm + '-' + dd;

	    document.getElementById('reviewDate').value = reviewStr;
	  }

	  // Recalculate whenever sanction date or loan period changes
	  window.onload = function () {
	    document.getElementById('sanctionDate').addEventListener('change', calcReviewDate);
	    document.getElementById('loanPeriod').addEventListener('input', calcReviewDate);
	  };
</script>
</body>
</html>