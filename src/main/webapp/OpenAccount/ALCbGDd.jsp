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
    System.out.println("📌 ALCbGDd.jsp - Product Code received: " + productCode);
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
      <input type="number" step="0.01" name="registerAmount">
    </div>

    <div>
      <label>Limit Amount</label>
      <input type="number" step="0.01" name="limitAmount">
    </div>

    <div>
      <label>Drawing Power</label>
      <input type="number" step="0.01" name="drawingPower">
    </div>

    <div>
		<label for="sanctionDate">Sanction Date</label>
		<input type="date" id="sanctionDate" name="sanctionDate">  
	</div>

    <div>
      <label>Sanction Amount</label>
      <input type="number" step="0.01" name="sanctionAmount">
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
      <label>Installment Type Id</label>
      <input type="text" name="installmentTypeId">
    </div>

    <div>
      <label>Installment Type</label>
      <input type="text" name="installmentType">
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
      <input type="number" step="0.01" name="interestRate">
    </div>

    <div>
      <label>Penal Int. Rate</label>
      <input type="number" step="0.01" name="penalIntRate">
    </div>

    <div>
      <label>Mor. Int. Rate</label>
      <input type="number" step="0.01" name="morIntRate">
    </div>

    <div>
      <label>Overdue Int. Rate</label>
      <input type="number" step="0.01" name="overdueIntRate">
    </div>

    <div>
      <label>Mor. Period Month</label>
      <input type="number" name="morPeriodMonth">
    </div>

    <div>
      <label>Inst. Amount</label>
      <input type="number" step="0.01" name="instAmount">
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
      <input type="text" name="areaCode">
    </div>

    <div>
      <label>Area Name</label>
      <input type="text" name="areaName">
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
      <input type="text" name="subAreaCode">
    </div>

    <div>
      <label>Sub Area Name</label>
      <input type="text" name="subAreaName">
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
      <input type="text" name="socialSectorId">
    </div>
    
      <div>
      <label>Description 1</label>
      <input type="text" name="description1">
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
      <input type="text" name="socialSubSectorId">
    </div>
    
    <div>
      <label>Description 2</label>
      <input type="text" name="description2">
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
  <input type="text" name="directorId" id="directorId">
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
        <input type="number" name="coBorrowerZip[]">
      </div>
    </div>
  </div>
</fieldset>

<!-- Guarantor Section - FIXED VERSION -->
<fieldset id="guarantorFieldset">
  <legend>
    Guarantor
    <button type="button" onclick="addGuarantor()"
      style="border:none;background:#373279;color:white;padding:2px 10px;
        border-radius:5px;cursor:pointer;font-size:12px;margin-left:10px;">
      ➕
    </button>
  </legend>

  <div class="nominee-card guarantor-block">
    <button type="button" class="nominee-remove" onclick="removeGuarantor(this)">✖</button>

    <div class="nominee-title"
         style="font-weight:bold; font-size:15px; margin-bottom:10px; color:#373279;">
      Guarantor <span class="guarantor-serial">1</span>
    </div>
    
    <div class="inline-fields">
      <div>
        <label>Has Customer ID ?</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="guarantorHasCustomerID_1" class="guarantorHasCustomerRadio" value="yes" onchange="toggleGuarantorCustomerID(this)"> Yes</label>
          <label><input type="radio" name="guarantorHasCustomerID_1" class="guarantorHasCustomerRadio" value="no" onchange="toggleGuarantorCustomerID(this)" checked> No</label>
        </div>
      </div>

      <div class="guarantorCustomerIDContainer" style="display:none; margin-top:10px;">
        <label>Customer ID</label>
        <div class="input-icon-box">
          <input type="text" class="guarantorCustomerIDInput" name="guarantorCustomerID[]" onclick="openGuarantorCustomerLookup(this)" readonly>
          <button type="button" class="inside-icon-btn" onclick="openGuarantorCustomerLookup(this)" title="Search Customer">🔍</button>
        </div>
      </div>
    </div>

    <br>

    <div class="address-grid">
      <!-- ✅ FIXED: Changed from guarantorsalutation[] to guarantorSalutation[] -->
      <div>
        <label>Salutation Code</label>
        <select name="guarantorSalutation[]" required>
          <option value="">-- Select Salutation Code --</option>
          <%
              PreparedStatement psGuarantorSal = null;
              ResultSet rsGuarantorSal = null;
              try (Connection connGuarantorSal = DBConnection.getConnection()) {
                  String sql = "SELECT SALUTATION_CODE FROM GLOBALCONFIG.SALUTATION ORDER BY SALUTATION_CODE";
                  psGuarantorSal = connGuarantorSal.prepareStatement(sql);
                  rsGuarantorSal = psGuarantorSal.executeQuery();
                  while (rsGuarantorSal.next()) {
                      String salCode = rsGuarantorSal.getString("SALUTATION_CODE");
          %>
                      <option value="<%= salCode %>"><%= salCode %></option>
          <%
                  }
              } catch (Exception e) {
                  out.println("<option disabled>Error loading Salutation Code</option>");
                  e.printStackTrace();
              } finally {
                  if (rsGuarantorSal != null) rsGuarantorSal.close();
                  if (psGuarantorSal != null) psGuarantorSal.close();
              }
          %>
        </select>
      </div>

      <div>
        <label>Guarantor Name</label>
        <input type="text" name="guarantorName[]" required>
      </div>

      <div>
        <label>Address 1</label>
        <input type="text" name="guarantorAddress1[]">
      </div>

      <div>
        <label>Address 2</label>
        <input type="text" name="guarantorAddress2[]">
      </div>

      <div>
        <label>Address 3</label>
        <input type="text" name="guarantorAddress3[]">
      </div>

      <!-- ✅ FIXED: Changed from jointCountry[] to guarantorCountry[] -->
      <div>
        <label>Country</label>
        <select name="guarantorCountry[]">
          <option value="">-- Select Country --</option>
          <% 
            PreparedStatement psCountryGuarantor = null;
            ResultSet rsCountryGuarantor = null;
            try (Connection connCountryG = DBConnection.getConnection()) {
              String sql = "SELECT COUNTRY_CODE, NAME FROM GLOBALCONFIG.COUNTRY ORDER BY NAME";
              psCountryGuarantor = connCountryG.prepareStatement(sql);
              rsCountryGuarantor = psCountryGuarantor.executeQuery();
              while (rsCountryGuarantor.next()) {
                String countryCode = rsCountryGuarantor.getString("COUNTRY_CODE");
                String countryName = rsCountryGuarantor.getString("NAME");
          %>
                <option value="<%= countryCode %>"><%= countryName %></option>
          <% 
              }
            } catch (Exception e) {
              out.println("<option disabled>Error loading countries</option>");
            } finally {
              if (rsCountryGuarantor != null) rsCountryGuarantor.close();
              if (psCountryGuarantor != null) psCountryGuarantor.close();
            }
          %>
        </select>
      </div>

      <!-- ✅ FIXED: Changed from jointState[] to guarantorState[] -->
      <div>
        <label>State</label>
        <select name="guarantorState[]">
          <option value="">-- Select State --</option>
          <% 
            PreparedStatement psStateGuarantor = null;
            ResultSet rsStateGuarantor = null;
            try (Connection connStateG = DBConnection.getConnection()) {
              String sql = "SELECT STATE_CODE, NAME FROM GLOBALCONFIG.STATE ORDER BY NAME";
              psStateGuarantor = connStateG.prepareStatement(sql);
              rsStateGuarantor = psStateGuarantor.executeQuery();
              while (rsStateGuarantor.next()) {
                String stateCode = rsStateGuarantor.getString("STATE_CODE");
                String stateName = rsStateGuarantor.getString("NAME");
          %>
                <option value="<%= stateCode %>"><%= stateName %></option>
          <% 
              }
            } catch (Exception e) {
              out.println("<option disabled>Error loading states</option>");
              e.printStackTrace();
            } finally {
              if (rsStateGuarantor != null) rsStateGuarantor.close();
              if (psStateGuarantor != null) psStateGuarantor.close();
            }
          %>
        </select>
      </div>

      <!-- ✅ FIXED: Changed from jointCity[] to guarantorCity[] -->
      <div>
        <label>City</label>
        <select name="guarantorCity[]">
          <option value="">-- Select City --</option>
          <% 
            PreparedStatement psCityGuarantor = null;
            ResultSet rsCityGuarantor = null;
            try (Connection connCityG = DBConnection.getConnection()) {
              String sql = "SELECT CITY_CODE, NAME FROM GLOBALCONFIG.CITY ORDER BY UPPER(NAME)";
              psCityGuarantor = connCityG.prepareStatement(sql);
              rsCityGuarantor = psCityGuarantor.executeQuery();
              while (rsCityGuarantor.next()) {
                String cityCode = rsCityGuarantor.getString("CITY_CODE");
                String cityName = rsCityGuarantor.getString("NAME");
          %>
                <option value="<%= cityCode %>"><%= cityName %></option>
          <% 
              }
            } catch (Exception e) {
              out.println("<option disabled>Error loading cities</option>");
              e.printStackTrace();
            } finally {
              if (rsCityGuarantor != null) rsCityGuarantor.close();
              if (psCityGuarantor != null) psCityGuarantor.close();
            }
          %>
        </select>
      </div>

      <div>
        <label>Zip</label>
        <input type="number" name="guarantorZip[]">
      </div>

      <div>
        <label>Member No</label>
        <input type="text" name="guarantorMemberNo[]">
      </div>

      <div>
        <label>Employee Id</label>
        <input type="text" name="guarantorEmployeeId[]">
      </div>

      <div>
        <label>Birth Date</label>
        <input type="date" name="guarantorBirthDate[]">
      </div>

      <div>
        <label>Phone No</label>
        <input type="text" name="guarantorPhoneNo[]">
      </div>

      <div>
        <label>Mobile No</label>
        <input type="text" name="guarantorMobileNo[]">
      </div>
    </div>
  </div>
</fieldset>

<!-- Deposit Details Section - Add after Guarantor fieldset -->
<fieldset id="depositDetailsFieldset">
  <legend>
    Deposit Details
    <button type="button" onclick="addDepositDetails()"
      style="border:none;background:#373279;color:white;padding:2px 10px;
        border-radius:5px;cursor:pointer;font-size:12px;margin-left:10px;">
      ➕
    </button>
  </legend>

  <div class="nominee-card deposit-block">
    <button type="button" class="nominee-remove" onclick="removeDepositDetails(this)">✖</button>

    <div class="nominee-title"
         style="font-weight:bold; font-size:15px; margin-bottom:10px; color:#373279;">
      Deposit Details <span class="deposit-serial">1</span>
    </div>

    <div class="form-grid">

      <div>
  <label>Security Type Code</label>
  <select name="securityTypeCode[]" required>
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
        <input type="date" name="submissionDate[]">
      </div>

      <div>
        <label>Margin %</label>
        <input type="number" step="0.01" name="marginPercent[]" value="0" min="0" max="100">
      </div>

      <div>
        <label>Deposit A/c Code</label>
        <input type="text" name="depositAccCode[]">
      </div>

      <div>
        <label>Maturity Date</label>
        <input type="date" name="maturityDate[]">
      </div>

      <div>
        <label>Security Value</label>
        <input type="number" step="0.01" name="securityValue[]">
      </div>

      <div>
        <label>TD Value</label>
        <input type="number" step="0.01" name="tdValue[]" value="0" readonly style="background-color: #f0f0f0;">
      </div>

      <div>
        <label>Particular</label>
        <input type="text" name="particular[]">
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

<script src="js/savingAcc.js"></script>
<script>
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
    const salutationSelect = block.querySelector('select[name="coBorrowerSalutation[]"]');
    if (salutationSelect && customer.salutationCode) {
        salutationSelect.value = customer.salutationCode;
    }

    // Nominee Name
    const nameInput = block.querySelector('input[name="coBorrowerName[]"]');
    if (nameInput && customer.customerName) {
        nameInput.value = customer.customerName;
    }

    // Address 1
    const address1Input = block.querySelector('input[name="coBorrowerAddress1[]"]');
    if (address1Input && customer.address1) {
        address1Input.value = customer.address1;
    }

    // Address 2
    const address2Input = block.querySelector('input[name="coBorrowerAddress2[]"]');
    if (address2Input && customer.address2) {
        address2Input.value = customer.address2;
    }

    // Address 3
    const address3Input = block.querySelector('input[name="coBorrowerAddress3[]"]');
    if (address3Input && customer.address3) {
        address3Input.value = customer.address3;
    }

    // Country
    const countrySelect = block.querySelector('select[name="coBorrowerCountry[]"]');
    if (countrySelect && customer.country) {
        countrySelect.value = customer.country;
    }

    // State
    const stateSelect = block.querySelector('select[name="coBorrowerState[]"]');
    if (stateSelect && customer.state) {
        stateSelect.value = customer.state;
    }

    // City
    const citySelect = block.querySelector('select[name="coBorrowerCity[]"]');
    if (citySelect && customer.city) {
        citySelect.value = customer.city;
    }

    // Zip
    const zipInput = block.querySelector('input[name="coBorrowerZip[]"]');
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
  block.querySelector('input[name="coBorrowerZip[]"]').value = '';
}

function openCoBorrowerCustomerLookup(button) {
  const coBorrowerBlock = button.closest('.coBorrower-block');
  const input = coBorrowerBlock.querySelector('.coBorrowerCustomerIDInput');
  window.currentCoBorrowerInput = input;
  window.currentCoBorrowerBlock = coBorrowerBlock;
  openCustomerLookup();
}

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

// ==================== GUARANTOR FUNCTIONS (FIXED) ====================

function toggleGuarantorCustomerID(radio) {
  const guarantorBlock = radio.closest('.guarantor-block');
  const container = guarantorBlock.querySelector('.guarantorCustomerIDContainer');
  const input = guarantorBlock.querySelector('.guarantorCustomerIDInput');

  if (radio.value === 'yes') {
      container.style.display = 'block';
      input.required = true;
  } else {
      container.style.display = 'none';
      input.required = false;
      input.value = '';
      clearGuarantorFields(guarantorBlock);
  }
}

function clearGuarantorFields(block) {
  // ✅ FIXED: Updated field names
  block.querySelector('select[name="guarantorSalutation[]"]').value = '';
  block.querySelector('input[name="guarantorName[]"]').value = '';
  block.querySelector('input[name="guarantorAddress1[]"]').value = '';
  block.querySelector('input[name="guarantorAddress2[]"]').value = '';
  block.querySelector('input[name="guarantorAddress3[]"]').value = '';
  block.querySelector('select[name="guarantorCountry[]"]').value = '';
  block.querySelector('select[name="guarantorState[]"]').value = '';
  block.querySelector('select[name="guarantorCity[]"]').value = '';
  block.querySelector('input[name="guarantorZip[]"]').value = '0';
  
  block.querySelector('input[name="guarantorMemberNo[]"]').value = '';
  block.querySelector('input[name="guarantorPhoneNo[]"]').value = '';
  block.querySelector('input[name="guarantorMobileNo[]"]').value = '';
  block.querySelector('input[name="guarantorBirthDate[]"]').value = '';
}

function openGuarantorCustomerLookup(button) {
  const guarantorBlock = button.closest('.guarantor-block');
  const input = guarantorBlock.querySelector('.guarantorCustomerIDInput');
  window.currentGuarantorInput = input;
  window.currentGuarantorBlock = guarantorBlock;
  openCustomerLookup();
}

// ✅ FIXED: Updated field names in populate function
function populateGuarantorFields(block, customer) {
  console.log('📝 Populating Guarantor fields:', customer);
  
  // Salutation Code
  const salutationSelect = block.querySelector('select[name="guarantorSalutation[]"]');
  if (salutationSelect && customer.salutationCode) {
      setSelectValue(salutationSelect, customer.salutationCode, 'Guarantor Salutation');
  }

  // Guarantor Name
  const nameInput = block.querySelector('input[name="guarantorName[]"]');
  if (nameInput && customer.customerName) {
      nameInput.value = customer.customerName;
  }

  // Address fields
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

  // Country
  const countrySelect = block.querySelector('select[name="guarantorCountry[]"]');
  if (countrySelect && customer.country) {
      setSelectValue(countrySelect, customer.country, 'Guarantor Country');
  }

  // State
  const stateSelect = block.querySelector('select[name="guarantorState[]"]');
  if (stateSelect && customer.state) {
      setSelectValue(stateSelect, customer.state, 'Guarantor State');
  }

  // City
  const citySelect = block.querySelector('select[name="guarantorCity[]"]');
  if (citySelect && customer.city) {
      setSelectValue(citySelect, customer.city, 'Guarantor City');
  }

  // Zip
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

function addGuarantor() {
  let fieldset = document.getElementById("guarantorFieldset");
  let original = fieldset.querySelector(".guarantor-block");
  let clone = original.cloneNode(true);

  clone.querySelectorAll("input, select").forEach(el => {
      if (el.type === 'radio') {
          if (el.value === 'no') el.checked = true;
          else el.checked = false;
      } else if (el.tagName === 'SELECT') {
          el.selectedIndex = 0;
      } else if (el.name === 'guarantorZip[]') {
          el.value = '0';
      } else {
          el.value = "";
      }
  });

  const customerIDContainer = clone.querySelector('.guarantorCustomerIDContainer');
  if (customerIDContainer) {
      customerIDContainer.style.display = 'none';
  }

  const guarantorBlocks = fieldset.querySelectorAll(".guarantor-block");
  const newIndex = guarantorBlocks.length + 1;
  const radios = clone.querySelectorAll('.guarantorHasCustomerRadio');
  radios.forEach(radio => {
      radio.name = `guarantorHasCustomerID_${newIndex}`;
  });

  clone.querySelector(".nominee-remove").onclick = function() {
      removeGuarantor(this);
  };

  fieldset.appendChild(clone);
  updateGuarantorSerials();
}

function removeGuarantor(btn) {
  let blocks = document.querySelectorAll(".guarantor-block");
  if (blocks.length <= 1) {
	    showToast("⚠️ At least one guarantor is required.", "warning");
	    return;
	}
  btn.parentNode.remove();
  updateGuarantorSerials();
}

function updateGuarantorSerials() {
  let blocks = document.querySelectorAll(".guarantor-block");
  blocks.forEach((block, index) => {
      let serial = block.querySelector(".guarantor-serial");
      if (serial) {
          serial.textContent = (index + 1);
      }
  });
}
//==================== DEPOSIT DETAILS FUNCTIONS ====================

function addDepositDetails() {
  let fieldset = document.getElementById("depositDetailsFieldset");
  let original = fieldset.querySelector(".deposit-block");
  let clone = original.cloneNode(true);

  // Clear all inputs in the cloned block
  clone.querySelectorAll("input, select").forEach(el => {
    if (el.tagName === 'SELECT') {
      el.selectedIndex = 0;
    } else if (el.name === 'depositSrNo[]') {
      // Sr No will be updated by updateDepositSerials()
      el.value = '';
    } else if (el.name === 'marginPercent[]' || el.name === 'securityValue[]' || el.name === 'tdValue[]') {
      el.value = '0';
    } else {
      el.value = '';
    }
  });

  // Update remove button onclick
  clone.querySelector(".nominee-remove").onclick = function() {
    removeDepositDetails(this);
  };

  fieldset.appendChild(clone);
  updateDepositSerials();
  
  // Auto-calculate TD Value for new block
  setupTDValueCalculation(clone);
}

function removeDepositDetails(btn) {
  let blocks = document.querySelectorAll(".deposit-block");
  if (blocks.length <= 1) {
	    showToast("⚠️ At least one deposit detail is required.", "warning");
	    return;
	}
  btn.parentNode.remove();
  updateDepositSerials();
}

function updateDepositSerials() {
  let blocks = document.querySelectorAll(".deposit-block");
  blocks.forEach((block, index) => {
    let serial = block.querySelector(".deposit-serial");
    if (serial) {
      serial.textContent = (index + 1);
    }
    
    // Update Sr No input
    let srNoInput = block.querySelector('input[name="depositSrNo[]"]');
    if (srNoInput) {
      srNoInput.value = (index + 1);
    }
  });
}

// Auto-calculate TD Value based on Security Value and Margin %
function calculateTDValue(block) {
  const securityValue = parseFloat(block.querySelector('input[name="securityValue[]"]').value) || 0;
  const marginPercent = parseFloat(block.querySelector('input[name="marginPercent[]"]').value) || 0;
  const tdValueInput = block.querySelector('input[name="tdValue[]"]');
  
  // TD Value = Security Value × (Margin % / 100)
  const tdValue = securityValue * (marginPercent / 100);
  tdValueInput.value = tdValue.toFixed(2);
}

function setupTDValueCalculation(block) {
  const securityValueInput = block.querySelector('input[name="securityValue[]"]');
  const marginPercentInput = block.querySelector('input[name="marginPercent[]"]');
  
  securityValueInput.addEventListener('input', () => calculateTDValue(block));
  marginPercentInput.addEventListener('input', () => calculateTDValue(block));
}

// Initialize TD Value calculation for the first deposit block on page load
document.addEventListener('DOMContentLoaded', function() {
  const firstDepositBlock = document.querySelector('.deposit-block');
  if (firstDepositBlock) {
    setupTDValueCalculation(firstDepositBlock);
  }
});

//==================== MODIFIED setCustomerData FUNCTION ====================
//This needs to be updated in your existing script to handle Co-Borrower and Guarantor

window.setCustomerData = function(customerId, customerName, categoryCode, riskCategory) {
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

 // Check if this is for Guarantor lookup
 if (window.currentGuarantorInput) {
     window.currentGuarantorInput.value = customerId;
     fetchCustomerDetails(customerId, 'guarantor', window.currentGuarantorBlock);
     window.currentGuarantorInput = null;
     window.currentGuarantorBlock = null;
     closeCustomerLookup();
     showToast('✅ Loading guarantor customer data...');
     return;
 }

 // Check if this is for nominee lookup
 if (window.currentNomineeInput) {
     window.currentNomineeInput.value = customerId;
     fetchCustomerDetails(customerId, 'nominee', window.currentNomineeBlock);
     window.currentNomineeInput = null;
     window.currentNomineeBlock = null;
     closeCustomerLookup();
     showToast('✅ Loading nominee customer data...');
     return;
 }

 // Check if this is for joint holder lookup
 if (window.currentJointInput) {
     window.currentJointInput.value = customerId;
     fetchCustomerDetails(customerId, 'joint', window.currentJointBlock);
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
 showToast('✅ Customer data loaded successfully!');
};

//==================== MODIFIED fetchCustomerDetails FUNCTION ====================

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
             } else if (type === 'guarantor') {
                 populateGuarantorFields(block, data.customer);
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