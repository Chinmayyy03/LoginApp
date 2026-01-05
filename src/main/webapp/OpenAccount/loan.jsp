<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Fetch working date for this branch
    String workingDateStr = "";
    try (Connection connWorkDate = DBConnection.getConnection()) {
        String bankCode = "0100";
        CallableStatement cstmtWorkDate = connWorkDate.prepareCall("{? = call SYSTEM.FN_GET_WORKINGDATE(?, ?)}");
        cstmtWorkDate.registerOutParameter(1, Types.DATE);
        cstmtWorkDate.setString(2, bankCode);
        cstmtWorkDate.setString(3, branchCode);
        cstmtWorkDate.execute();
        
        Date workingDate = cstmtWorkDate.getDate(1);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        workingDateStr = sdf.format(workingDate);
        
        cstmtWorkDate.close();
    } catch (Exception e) {
        e.printStackTrace();
        workingDateStr = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    }
    
    // Get product code from request
    String productCode = request.getParameter("productCode");
    if (productCode == null) {
        productCode = "";
    }
    System.out.println("📌 loan.jsp - Product Code received: " + productCode);
    
    // Fetch product parameters to determine which fieldsets to show
    boolean showNominee = false;
    boolean showJointHolder = false;
    boolean showGuarantor = false;
    boolean showLandBuilding = false;
    boolean showDeposit = false;
    boolean showGold = false;
    
    if (!productCode.isEmpty()) {
        PreparedStatement psProduct = null;
        ResultSet rsProduct = null;
        try (Connection connProduct = DBConnection.getConnection()) {
            String sql = "SELECT " +
                        "PPL.IS_NOMINEE_REQUIRED, " +
                        "PPL.IS_JOINT_HOLDER_REQUIRED, " +
                        "PPL.IS_GUARANTOR_REQUIRED, " +
                        "PPL.IS_LAND_N_BUILDING_DETAILS_REQ, " +
                        "PPL.IS_DEPOSIT_DETAILS_REQUIRED, " +
                        "PPL.IS_GOLD_DETAILS_REQUIRED " +
                        "FROM HEADOFFICE.PRODUCT P " +
                        "JOIN HEADOFFICE.PRODUCTPARAMETERLOAN PPL ON P.PRODUCT_CODE = PPL.PRODUCT_CODE " +
                        "WHERE P.PRODUCT_CODE = ?";
            
            psProduct = connProduct.prepareStatement(sql);
            psProduct.setString(1, productCode);
            rsProduct = psProduct.executeQuery();
            
            if (rsProduct.next()) {
                showNominee = "Y".equalsIgnoreCase(rsProduct.getString("IS_NOMINEE_REQUIRED"));
                showJointHolder = "Y".equalsIgnoreCase(rsProduct.getString("IS_JOINT_HOLDER_REQUIRED"));
                showGuarantor = "Y".equalsIgnoreCase(rsProduct.getString("IS_GUARANTOR_REQUIRED"));
                showLandBuilding = "Y".equalsIgnoreCase(rsProduct.getString("IS_LAND_N_BUILDING_DETAILS_REQ"));
                showDeposit = "Y".equalsIgnoreCase(rsProduct.getString("IS_DEPOSIT_DETAILS_REQUIRED"));
                showGold = "Y".equalsIgnoreCase(rsProduct.getString("IS_GOLD_DETAILS_REQUIRED"));
                
                System.out.println("🔍 Product Parameters for " + productCode + ":");
                System.out.println("   - Nominee: " + showNominee);
                System.out.println("   - Joint Holder (Co-Borrower): " + showJointHolder);
                System.out.println("   - Guarantor: " + showGuarantor);
                System.out.println("   - Land & Building: " + showLandBuilding);
                System.out.println("   - Deposit: " + showDeposit);
                System.out.println("   - Gold: " + showGold);
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("❌ Error fetching product parameters: " + e.getMessage());
        } finally {
            if (rsProduct != null) rsProduct.close();
            if (psProduct != null) psProduct.close();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Loan Account Application</title>
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

.lb-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px 20px;
  align-items: start;
}

.lb-grid div {
  display: flex;
  flex-direction: column;
}

@media (max-width: 1024px) {
  .lb-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 600px) {
  .lb-grid {
    grid-template-columns: 1fr;
  }
}
    
</style>
</head>
<body>

<h2 style="color: #373279; text-align: center;">Loan Account Application - Product: <%= productCode %></h2>

<form action="LoanServlet" method="post">
  <input type="hidden" name="productCode" value="<%= productCode %>">

  <!-- Application Fieldset - Always Show -->
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
  		<label>Introduer A/c Code</label>
  		<input type="text" name="introducerAccCode" maxlength="14" pattern="[0-9]{14}" inputmode="numeric"
    	title="Introduer Account Code must be exactly 14 digits">
	</div>

      <div>
  		<label>Introducer A/c Name</label>
  		<input type="text" name="introducerAccName" required oninput="this.value = this.value
        .replace(/[^A-Za-z ]/g, '')
        .replace(/\s{2,}/g, ' ')
        .replace(/^\s+/g, '')
        .toLowerCase()
        .replace(/\b\w/g, c => c.toUpperCase());">
	</div>

      <div>
    	<label>Date Of Application</label>
    	<input type="date" name="dateOfApplication" value="<%= workingDateStr %>" readonly 
           style="background-color: #f0f0f0; cursor: not-allowed;" required>
	</div>

      <div>
        <label>Account Operation Capacity</label>
        <select name="accountOperationCapacity" required>
          <option value="">-- Select --</option>
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
    <option value="">-- Select --</option>
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


  <!-- Loan Details Fieldset - Always Show -->
  <fieldset>
    <legend>Loan Details</legend>
    <div class="info-text">Loan details fields will be displayed here</div>
  </fieldset>

  <!-- Nominee Fieldset - Conditional -->
  <% if (showNominee) { %>
  <fieldset id="nomineeFieldset">
    <legend>Nominee</legend>
    <div class="info-text">Nominee fields will be displayed here</div>
  </fieldset>
  <% } %>

  <!-- Co-Borrower/Joint Holder Fieldset - Conditional -->
  <% if (showJointHolder) { %>
  <fieldset id="coBorrowerFieldset">
    <legend>Co-Borrower</legend>
    <div class="info-text">Co-Borrower fields will be displayed here</div>
  </fieldset>
  <% } %>

  <!-- Guarantor Fieldset - Conditional -->
  <% if (showGuarantor) { %>
  <fieldset id="guarantorFieldset">
    <legend>Guarantor</legend>
    <div class="info-text">Guarantor fields will be displayed here</div>
  </fieldset>
  <% } %>

  <!-- Land & Building Fieldset - Conditional -->
  <% if (showLandBuilding) { %>
  <fieldset id="landBuildingFieldset">
    <legend>Land & Building</legend>
    <div class="info-text">Land & Building fields will be displayed here</div>
  </fieldset>
  <% } %>

  <!-- Deposit Details Fieldset - Conditional -->
  <% if (showDeposit) { %>
  <fieldset id="depositFieldset">
    <legend>Deposit Details</legend>
    <div class="info-text">Deposit details fields will be displayed here</div>
  </fieldset>
  <% } %>

  <!-- Gold Details Fieldset - Conditional -->
  <% if (showGold) { %>
  <fieldset id="goldFieldset">
    <legend>Gold Details</legend>
    <div class="info-text">Gold details fields will be displayed here</div>
  </fieldset>
  <% } %>

  <div class="form-buttons">
    <button type="submit">Save</button>
    <button type="reset">Reset</button>
  </div>
</form>

<script>
console.log('Product Code: <%= productCode %>');
console.log('Show Nominee: <%= showNominee %>');
console.log('Show Joint Holder: <%= showJointHolder %>');
console.log('Show Guarantor: <%= showGuarantor %>');
console.log('Show Land & Building: <%= showLandBuilding %>');
console.log('Show Deposit: <%= showDeposit %>');
console.log('Show Gold: <%= showGold %>');
</script>

</body>
</html>