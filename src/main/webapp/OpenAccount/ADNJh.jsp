<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String productCode = request.getParameter("productCode");
    if (productCode == null) {
        productCode = "";
    }
    System.out.println("📌 ADNJh.jsp - Product Code received: " + productCode);
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Term Deposit Application</title>
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
      display: flex;
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
  padding-right: 40px;
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
    gap: 20px;
}
    
</style>
</head>
<body>

<form action="SaveApplicationServlet" method="post" onsubmit="return validateForm()">
  <input type="hidden" id="hiddenProductCode" name="productCode" value="<%= productCode %>">

  <fieldset>
    <legend>Application</legend>
    <div class="form-grid">
      
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
          String id = rsMinBal.getString("MINBALANCE_ID");
          String value = rsMinBal.getString("MINBALANCE");
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

  <!-- Term Deposit Details Section -->
  <fieldset>
    <legend>Deposit</legend>
    <div class="form-grid">
      
      <div>
        <label>Account Type</label>
        <input type="text" name="accountType" readonly value="TD">
      </div>

      <div>
        <label>Unit Of Period</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="unitOfPeriod" value="Day"> Day</label>
          <label><input type="radio" name="unitOfPeriod" value="Month" checked> Month</label>
        </div>
      </div>

      <div>
        <label>Period Of Deposit</label>
        <input type="number" name="periodOfDeposit" min="0">
      </div>

      <div>
        <label>Open Date</label>
        <input type="date" name="openDate">
      </div>

      <div>
        <label>Maturity Date</label>
        <input type="date" name="maturityDate">
      </div>

      <div>
        <label>Interest Rate</label>
        <input type="number" step="0.01" name="interestRate" value="0">
      </div>

      <div>
        <label>Interest Payment Frequency</label>
        <select name="interestPaymentFrequency">
          <option value="">-- Select Frequency --</option>
          <option value="On Maturity">On Maturity</option>
          <option value="Monthly">Monthly</option>
          <option value="Quarterly">Quarterly</option>
          <option value="Half-Yearly">Half-Yearly</option>
          <option value="Yearly">Yearly</option>
        </select>
      </div>

      <div>
        <label>Interest Paid In Cash</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="interestPaidInCash" value="Yes"> Yes</label>
          <label><input type="radio" name="interestPaidInCash" value="No" checked> No</label>
        </div>
      </div>

      <div>
        <label>Rate Discounted</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="rateDiscounted" value="Yes"> Yes</label>
          <label><input type="radio" name="rateDiscounted" value="No" checked> No</label>
        </div>
      </div>

      <div>
        <label>Is AR Day Begin</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="isARDayBegin" value="Yes"> Yes</label>
          <label><input type="radio" name="isARDayBegin" value="No" checked> No</label>
        </div>
      </div>

      <div>
        <label>Credit A/c Code</label>
        <input type="text" name="creditAccCode">
      </div>

      <div>
        <label>Credit A/c Name</label>
        <input type="text" name="creditAccName">
      </div>

      <div>
        <label>Deposit Amount</label>
        <input type="number" step="0.01" name="depositAmount" value="0">
      </div>

      <div>
        <label>Maturity Amount</label>
        <input type="number" step="0.01" name="maturityAmount" value="0">
      </div>

      <div>
        <label>Cash</label>
        <input type="number" step="0.01" name="cash" value="0">
      </div>

      <div>
        <label>Clearing</label>
        <input type="number" step="0.01" name="clearing" value="0">
      </div>

      <div>
        <label>Transfer</label>
        <input type="number" step="0.01" name="transfer" value="0">
      </div>

    </div>
  </fieldset>

  <!-- Nominee Section -->
  <fieldset id="nomineeFieldset">
    <legend>
      Nominee
      <button type="button" onclick="addNominee()" 
        style="border:none;background:#373279;color:white;padding:2px 10px;
        border-radius:5px;cursor:pointer;font-size:12px;margin-left:10px;">
        ➕
      </button>
    </legend>

    <div class="nominee-card nominee-block">
      <button type="button" class="nominee-remove" onclick="removeNominee(this)">✖</button>

      <div class="nominee-title" 
           style="font-weight:bold; font-size:15px; margin-bottom:10px; color:#373279;">
        Nominee <span class="nominee-serial">1</span>
      </div>
      
<div class="inline-fields">

    <div>
        <label>Has Customer ID ?</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="nomineeHasCustomerID_1" class="nomineeHasCustomerRadio" value="yes" onchange="toggleNomineeCustomerID(this)"> Yes</label>
          <label><input type="radio" name="nomineeHasCustomerID_1" class="nomineeHasCustomerRadio" value="no" onchange="toggleNomineeCustomerID(this)" checked> No</label>
        </div>
    </div>

    <div class="nomineeCustomerIDContainer" style="display:none; margin-top:10px;">
        <label>Customer ID</label>
        <div class="input-icon-box">
          <input type="text" class="nomineeCustomerIDInput" name="nomineeCustomerID[]" onclick="openNomineeCustomerLookup(this)" readonly>
          <button type="button" class="inside-icon-btn" onclick="openNomineeCustomerLookup(this)" title="Search Customer">🔍</button>
        </div>
    </div>

</div>

      <br>

      <div class="personal-grid">
<div>
    <label>Salutation Code</label>
    <select name="nomineeSalutation[]" required>
        <option value="">-- Select Salutation Code --</option>
        <%
            PreparedStatement psnomineeSalutation = null;
            ResultSet rsnomineeSalutation = null;
            try (Connection conn1 = DBConnection.getConnection()) {
                String sql1 = "SELECT SALUTATION_CODE FROM GLOBALCONFIG.SALUTATION ORDER BY SALUTATION_CODE";
                psnomineeSalutation = conn1.prepareStatement(sql1);
                rsnomineeSalutation = psnomineeSalutation.executeQuery();
                while (rsnomineeSalutation.next()) {
                    String nomineeSalutation = rsnomineeSalutation.getString("SALUTATION_CODE");
        %>
                    <option value="<%= nomineeSalutation %>"><%= nomineeSalutation %></option>
        <%
                }
            } catch (Exception e) {
                out.println("<option disabled>Error loading Salutation Code</option>");
                e.printStackTrace();
            } finally {
                if (rsnomineeSalutation != null) rsnomineeSalutation.close();
                if (psnomineeSalutation != null) psnomineeSalutation.close();
            }
        %>
    </select>
</div>

        <div>
          <label>Nominee Name</label>
          <input type="text" name="nomineeName[]" required>
        </div>

        <div>
          <label>Address 1</label>
          <input type="text" name="nomineeAddress1[]">
        </div>

        <div>
          <label>Address 2</label>
          <input type="text" name="nomineeAddress2[]">
        </div>

        <div>
          <label>Address 3</label>
          <input type="text" name="nomineeAddress3[]">
        </div>

        <div>
          <label>Country</label>
          <select name="nomineeCountry[]">
            <option value="">-- Select Country --</option>
            <% 
              PreparedStatement psCountryNominee = null;
              ResultSet rsCountryNominee = null;
              try (Connection connCountryN = DBConnection.getConnection()) {
                String sql = "SELECT COUNTRY_CODE, NAME FROM GLOBALCONFIG.COUNTRY ORDER BY NAME";
                psCountryNominee = connCountryN.prepareStatement(sql);
                rsCountryNominee = psCountryNominee.executeQuery();
                while (rsCountryNominee.next()) {
                  String countryCode = rsCountryNominee.getString("COUNTRY_CODE");
                  String countryName = rsCountryNominee.getString("NAME");
            %>
                  <option value="<%= countryCode %>"><%= countryName %></option>
            <% 
                }
              } catch (Exception e) {
                out.println("<option disabled>Error loading countries</option>");
              } finally {
                if (rsCountryNominee != null) rsCountryNominee.close();
                if (psCountryNominee != null) psCountryNominee.close();
              }
            %>
          </select>
        </div>

        <div>
          <label>State</label>
          <select name="nomineeState[]">
            <option value="">-- Select State --</option>
            <% 
              PreparedStatement psStateNominee = null;
              ResultSet rsStateNominee = null;
              try (Connection connStateN = DBConnection.getConnection()) {
                String sql = "SELECT STATE_CODE, NAME FROM GLOBALCONFIG.STATE ORDER BY NAME";
                psStateNominee = connStateN.prepareStatement(sql);
                rsStateNominee = psStateNominee.executeQuery();
                while (rsStateNominee.next()) {
                  String stateCode = rsStateNominee.getString("STATE_CODE");
                  String stateName = rsStateNominee.getString("NAME");
            %>
                  <option value="<%= stateCode %>"><%= stateName %></option>
            <% 
                }
              } catch (Exception e) {
                out.println("<option disabled>Error loading states</option>");
                e.printStackTrace();
              } finally {
                if (rsStateNominee != null) rsStateNominee.close();
                if (psStateNominee != null) psStateNominee.close();
              }
            %>
          </select>
        </div>

        <div>
          <label>City</label>
          <select name="nomineeCity[]">
            <option value="">-- Select City --</option>
            <% 
              PreparedStatement psCityNominee = null;
              ResultSet rsCityNominee = null;
              try (Connection connCityN = DBConnection.getConnection()) {
                String sql = "SELECT CITY_CODE, NAME FROM GLOBALCONFIG.CITY ORDER BY UPPER(NAME)";
                psCityNominee = connCityN.prepareStatement(sql);
                rsCityNominee = psCityNominee.executeQuery();
                while (rsCityNominee.next()) {
                  String cityCode = rsCityNominee.getString("CITY_CODE");
                  String cityName = rsCityNominee.getString("NAME");
            %>
                  <option value="<%= cityCode %>"><%= cityName %></option>
            <% 
                }
              } catch (Exception e) {
                out.println("<option disabled>Error loading cities</option>");
                e.printStackTrace();
              } finally {
                if (rsCityNominee != null) rsCityNominee.close();
                if (psCityNominee != null) psCityNominee.close();
              }
            %>
          </select>
        </div>

        <div>
          <label>Zip</label>
          <input type="number" name="nomineeZip[]" value="0">
        </div>

        <div>
          <label>Relation with Guardian</label>
          <select name="nomineeRelation[]" required>
            <option value="">-- Select Relation --</option>
            <% 
              PreparedStatement psRelation = null;
              ResultSet rsRelation = null;
              try (Connection conn9 = DBConnection.getConnection()) {
                String sql = "SELECT RELATION_ID, DESCRIPTION FROM GLOBALCONFIG.RELATION ORDER BY RELATION_ID";
                psRelation = conn9.prepareStatement(sql);
                rsRelation = psRelation.executeQuery();
                while (rsRelation.next()) {
                  String relationId = rsRelation.getString("RELATION_ID");
                  String description = rsRelation.getString("DESCRIPTION");
            %>
                  <option value="<%= relationId %>"><%= description %></option>
            <% 
                }
              } catch (Exception e) {
                out.println("<option disabled>Error loading relation</option>");
              } finally {
                if (rsRelation != null) rsRelation.close();
                if (psRelation != null) psRelation.close();
              }
            %>
          </select>
        </div>
      </div>
    </div>
  </fieldset>

  <!-- Joint Holder Section -->
  <fieldset id="jointFieldset">
    <legend>
      Joint Holder
      <button type="button" onclick="addJointHolder()"
        style="border:none;background:#373279;color:white;padding:2px 10px;
        border-radius:5px;cursor:pointer;font-size:12px;margin-left:10px;">
        ➕
      </button>
    </legend>

    <div class="nominee-card joint-block">
      <button type="button" class="nominee-remove" onclick="removeJointHolder(this)">✖</button>

      <div class="nominee-title"
           style="font-weight:bold; font-size:15px; margin-bottom:10px; color:#373279;">
        Joint Holder <span class="joint-serial">1</span>
      </div>
      
      <div class="inline-fields">
        <div>
          <label>Has Customer ID ?</label>
          <div style="flex-direction: row;" class="radio-group">
            <label><input type="radio" name="jointHasCustomerID_1" class="jointHasCustomerRadio" value="yes" onchange="toggleJointCustomerID(this)"> Yes</label>
            <label><input type="radio" name="jointHasCustomerID_1" class="jointHasCustomerRadio" value="no" onchange="toggleJointCustomerID(this)" checked> No</label>
          </div>
        </div>

        <div class="jointCustomerIDContainer" style="display:none; margin-top:10px;">
          <label>Customer ID</label>
          <div class="input-icon-box">
            <input type="text" class="jointCustomerIDInput" name="jointCustomerID[]" onclick="openJointCustomerLookup(this)" readonly>
            <button type="button" class="inside-icon-btn" onclick="openJointCustomerLookup(this)" title="Search Customer">🔍</button>
          </div>
        </div>
      </div>

      <br>

      <div class="address-grid">
        <div>
          <label>Salutation Code</label>
          <select name="jointSalutation[]" required>
            <option value="">-- Select Salutation Code --</option>
            <%
              PreparedStatement psSalutation2 = null;
              ResultSet rsSalutation2 = null;
              try (Connection conn2 = DBConnection.getConnection()) {
                String sql2 = "SELECT SALUTATION_CODE FROM GLOBALCONFIG.SALUTATION ORDER BY SALUTATION_CODE";
                psSalutation2 = conn2.prepareStatement(sql2);
                rsSalutation2 = psSalutation2.executeQuery();
                while (rsSalutation2.next()) {
                  String salutationCode2 = rsSalutation2.getString("SALUTATION_CODE");
            %>
                  <option value="<%= salutationCode2 %>"><%= salutationCode2 %></option>
            <%
                }
              } catch (Exception e) {
                out.println("<option disabled>Error loading Salutation Code</option>");
                e.printStackTrace();
              } finally {
                if (rsSalutation2 != null) rsSalutation2.close();
                if (psSalutation2 != null) psSalutation2.close();
              }
            %>
          </select>
        </div>

        <div>
          <label>Joint Holder Name</label>
          <input type="text" name="jointName[]" required>
        </div>

        <div>
          <label>Address 1</label>
          <input type="text" name="jointAddress1[]">
        </div>

        <div>
          <label>Address 2</label>
          <input type="text" name="jointAddress2[]">
        </div>

        <div>
          <label>Address 3</label>
          <input type="text" name="jointAddress3[]">
        </div>

        <div>
          <label>Country</label>
          <select name="jointCountry[]">
            <option value="">-- Select Country --</option>
            <% 
              PreparedStatement psCountryJoint = null;
              ResultSet rsCountryJoint = null;
              try (Connection connCountryJ = DBConnection.getConnection()) {
                String sql = "SELECT COUNTRY_CODE, NAME FROM GLOBALCONFIG.COUNTRY ORDER BY NAME";
                psCountryJoint = connCountryJ.prepareStatement(sql);
                rsCountryJoint = psCountryJoint.executeQuery();
                while (rsCountryJoint.next()) {
                  String countryCode = rsCountryJoint.getString("COUNTRY_CODE");
                  String countryName = rsCountryJoint.getString("NAME");
            %>
                  <option value="<%= countryCode %>"><%= countryName %></option>
            <% 
                }
              } catch (Exception e) {
                out.println("<option disabled>Error loading countries</option>");
              } finally {
                if (rsCountryJoint != null) rsCountryJoint.close();
                if (psCountryJoint != null) psCountryJoint.close();
              }
            %>
          </select>
        </div>

        <div>
          <label>State</label>
          <select name="jointState[]">
            <option value="">-- Select State --</option>
            <% 
              PreparedStatement psStateJoint = null;
              ResultSet rsStateJoint = null;
              try (Connection connStateJ = DBConnection.getConnection()) {
                String sql = "SELECT STATE_CODE, NAME FROM GLOBALCONFIG.STATE ORDER BY NAME";
                psStateJoint = connStateJ.prepareStatement(sql);
                rsStateJoint = psStateJoint.executeQuery();
                while (rsStateJoint.next()) {
                  String stateCode = rsStateJoint.getString("STATE_CODE");
                  String stateName = rsStateJoint.getString("NAME");
            %>
                  <option value="<%= stateCode %>"><%= stateName %></option>
            <% 
                }
              } catch (Exception e) {
                out.println("<option disabled>Error loading states</option>");
                e.printStackTrace();
              } finally {
                if (rsStateJoint != null) rsStateJoint.close();
                if (psStateJoint != null) psStateJoint.close();
              }
            %>
          </select>
        </div>

        <div>
          <label>City</label>
          <select name="jointCity[]">
            <option value="">-- Select City --</option>
            <% 
              PreparedStatement psCityJoint = null;
              ResultSet rsCityJoint = null;
              try (Connection connCityJ = DBConnection.getConnection()) {
                String sql = "SELECT CITY_CODE, NAME FROM GLOBALCONFIG.CITY ORDER BY UPPER(NAME)";
                psCityJoint = connCityJ.prepareStatement(sql);
                rsCityJoint = psCityJoint.executeQuery();
                while (rsCityJoint.next()) {
                  String cityCode = rsCityJoint.getString("CITY_CODE");
                  String cityName = rsCityJoint.getString("NAME");
            %>
                  <option value="<%= cityCode %>"><%= cityName %></option>
            <% 
                }
              } catch (Exception e) {
                out.println("<option disabled>Error loading cities</option>");
                e.printStackTrace();
              } finally {
                if (rsCityJoint != null) rsCityJoint.close();
                if (psCityJoint != null) psCityJoint.close();
              }
            %>
          </select>
        </div>

        <div>
          <label>Zip</label>
          <input type="number" name="jointZip[]" value="0">
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
            text: "✅ Term Deposit Application saved successfully!\nApplication Number: " + applicationNumber,
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
            text: "❌ Error: " + (message || "Failed to save term deposit application"),
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

    // Check if this is for co-borrower lookup
    if (window.currentCoBorrowerInput) {
        window.currentCoBorrowerInput.value = customerId;
        fetchCustomerDetails(customerId, 'coborrower', window.currentCoBorrowerBlock);
        window.currentCoBorrowerInput = null;
        window.currentCoBorrowerBlock = null;
        closeCustomerLookup();
        showToast('✅ Loading co-borrower customer data...');
        return;
    }

    // Check if this is for guarantor lookup
    if (window.currentGuarantorInput) {
        window.currentGuarantorInput.value = customerId;
        fetchCustomerDetails(customerId, 'guarantor', window.currentGuarantorBlock);
        window.currentGuarantorInput = null;
        window.currentGuarantorBlock = null;
        closeCustomerLookup();
        showToast('✅ Loading guarantor customer data...');
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
            console.error('❌ Error fetching customer details:', error);
            showToast('❌ Failed to load customer data');
        });
}

// ✅ FIXED: Helper function to set select value with multiple matching strategies
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
    
    // Strategy 2: Try matching on text content (for cases where DB stores names)
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

//Populate Nominee fields with customer data
function populateNomineeFields(block, customer) {
    console.log('📝 Populating Nominee fields:', customer);
    
    // Salutation Code
    const salutationSelect = block.querySelector('select[name="nomineeSalutation[]"]');
    if (salutationSelect && customer.salutationCode) {
        setSelectValue(salutationSelect, customer.salutationCode, 'Nominee Salutation');
    }

    // Nominee Name
    const nameInput = block.querySelector('input[name="nomineeName[]"]');
    if (nameInput && customer.customerName) {
        nameInput.value = customer.customerName;
    }

    // Address fields
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

    // Country
    const countrySelect = block.querySelector('select[name="nomineeCountry[]"]');
    if (countrySelect && customer.country) {
        setSelectValue(countrySelect, customer.country, 'Nominee Country');
    }

    // State
    const stateSelect = block.querySelector('select[name="nomineeState[]"]');
    if (stateSelect && customer.state) {
        setSelectValue(stateSelect, customer.state, 'Nominee State');
    }

    // City
    const citySelect = block.querySelector('select[name="nomineeCity[]"]');
    if (citySelect && customer.city) {
        setSelectValue(citySelect, customer.city, 'Nominee City');
    }

    // Zip
    const zipInput = block.querySelector('input[name="nomineeZip[]"]');
    if (zipInput && customer.zip) {
        zipInput.value = customer.zip;
    }
}

//Populate Joint Holder fields with customer data
function populateJointFields(block, customer) {
    console.log('📝 Populating Joint Holder fields:', customer);
    
    // Salutation Code
    const salutationSelect = block.querySelector('select[name="jointSalutation[]"]');
    if (salutationSelect && customer.salutationCode) {
        setSelectValue(salutationSelect, customer.salutationCode, 'Joint Salutation');
    }

    // Joint Holder Name
    const nameInput = block.querySelector('input[name="jointName[]"]');
    if (nameInput && customer.customerName) {
        nameInput.value = customer.customerName;
    }

    // Address fields
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

    // Country
    const countrySelect = block.querySelector('select[name="jointCountry[]"]');
    if (countrySelect && customer.country) {
        setSelectValue(countrySelect, customer.country, 'Joint Country');
    }

    // State
    const stateSelect = block.querySelector('select[name="jointState[]"]');
    if (stateSelect && customer.state) {
        setSelectValue(stateSelect, customer.state, 'Joint State');
    }

    // City
    const citySelect = block.querySelector('select[name="jointCity[]"]');
    if (citySelect && customer.city) {
        setSelectValue(citySelect, customer.city, 'Joint City');
    }

    // Zip
    const zipInput = block.querySelector('input[name="jointZip[]"]');
    if (zipInput && customer.zip) {
        zipInput.value = customer.zip;
    }
}

//Populate Co-Borrower fields with customer data
function populateCoBorrowerFields(block, customer) {
    console.log('📝 Populating Co-Borrower fields:', customer);
    
    // Salutation Code
    const salutationSelect = block.querySelector('select[name="nomineeSalutation[]"]');
    if (salutationSelect && customer.salutationCode) {
        setSelectValue(salutationSelect, customer.salutationCode, 'Co-Borrower Salutation');
    }

    // Co-Borrower Name
    const nameInput = block.querySelector('input[name="nomineeName[]"]');
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
    const countrySelect = block.querySelector('select[name="countryCode"]');
    if (countrySelect && customer.country) {
        setSelectValue(countrySelect, customer.country, 'Co-Borrower Country');
    }

    // State
    const stateSelect = block.querySelector('select[name="stateCode"]');
    if (stateSelect && customer.state) {
        setSelectValue(stateSelect, customer.state, 'Co-Borrower State');
    }

    // City
    const citySelect = block.querySelector('select[name="cityCode"]');
    if (citySelect && customer.city) {
        setSelectValue(citySelect, customer.city, 'Co-Borrower City');
    }

    // Zip
    const zipInput = block.querySelector('input[name="coBorrowerZip[]"]');
    if (zipInput && customer.zip) {
        zipInput.value = customer.zip;
    }
}

//Populate Guarantor fields with customer data
function populateGuarantorFields(block, customer) {
    console.log('📝 Populating Guarantor fields:', customer);
    
    // Salutation Code
    const salutationSelect = block.querySelector('select[name="guarantorsalutation[]"]');
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
    const countrySelect = block.querySelector('select[name="jointCountry[]"]');
    if (countrySelect && customer.country) {
        setSelectValue(countrySelect, customer.country, 'Guarantor Country');
    }

    // State
    const stateSelect = block.querySelector('select[name="jointState[]"]');
    if (stateSelect && customer.state) {
        setSelectValue(stateSelect, customer.state, 'Guarantor State');
    }

    // City
    const citySelect = block.querySelector('select[name="jointCity[]"]');
    if (citySelect && customer.city) {
        setSelectValue(citySelect, customer.city, 'Guarantor City');
    }

    // Zip
    const zipInput = block.querySelector('input[name="guarantorZip[]"]');
    if (zipInput && customer.zip) {
        zipInput.value = customer.zip;
    }
}

//Customer Lookup Functions
function openCustomerLookup() {
    const modal = document.getElementById('customerLookupModal');
    const content = document.getElementById('customerLookupContent');

    modal.style.display = 'flex';
    content.innerHTML = '<div style="text-align:center;padding:40px;">Loading customers...</div>';

    fetch('lookupForCustomerId.jsp')
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

function openNomineeCustomerLookup(button) {
    const nomineeBlock = button.closest('.nominee-block');
    const input = nomineeBlock.querySelector('.nomineeCustomerIDInput');
    window.currentNomineeInput = input;
    window.currentNomineeBlock = nomineeBlock;
    openCustomerLookup();
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

//Replace the existing removeNominee function
function removeNominee(btn) {
    let blocks = document.querySelectorAll(".nominee-block");
    if (blocks.length <= 1) {
        Toastify({
            text: "⚠️ At least one nominee is required.",
            duration: 4000,
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
                borderLeft: "5px solid #ff9800",
                marginTop: "20px"
            },
            stopOnFocus: true
        }).showToast();
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

function openJointCustomerLookup(button) {
    const jointBlock = button.closest('.joint-block');
    const input = jointBlock.querySelector('.jointCustomerIDInput');
    window.currentJointInput = input;
    window.currentJointBlock = jointBlock;
    openCustomerLookup();
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
        Toastify({
            text: "⚠️ At least one joint holder is required.",
            duration: 4000,
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
                borderLeft: "5px solid #ff9800",
                marginTop: "20px"
            },
            stopOnFocus: true
        }).showToast();
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

//==================== UTILITY FUNCTIONS ====================

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
</script>
</body>
</html>