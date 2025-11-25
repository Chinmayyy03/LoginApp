<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }
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
  </style>
</head>
<body>

<form>
  <fieldset>
    <legend>Application</legend>
    <div class="form-grid">
      <div>
  		<label>Customer ID</label>
  		<div class="input-icon-box">
    	<input type="text" id="customerId" name="customerId"  onclick="openCustomerLookup()" readonly required>
    	<button type="button" 
            class="inside-icon-btn"
            onclick="openCustomerLookup()" 
            title="Search Customer">🔍</button>
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
        <input type="date" name="dateOfApplication">
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
        <label>Min Balance ID</label>
        <select name="minBalanceID">
          <option>0</option>
          <option>100</option>
          <option>500</option>
          <option>5000</option>
        </select>
      </div>
      
      <div>
        <label>Risk Category</label>
        <input type="text" id="riskCategory" name="riskCategory" readonly>
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
          <input type="text" class="nomineeCustomerIDInput" name="nomineeCustomerID[]" readonly>
          <button type="button" class="inside-icon-btn" onclick="openNomineeCustomerLookup(this)" title="Search Customer">🔍</button>
        </div>
      </div>
      <br>

      <div class="personal-grid">
        <div>
          <label>Salutation Code</label>
          <select name="nomineeSalutation[]" required>
            <option value="">-- Select Salutation --</option>
            <option value="MR">Mr.</option>
            <option value="MS">Ms.</option>
            <option value="MRS">Mrs.</option>
            <option value="DR">Dr.</option>
            <option value="PROF">Prof.</option>
          </select>
        </div>

        <div>
          <label>Nominee Name</label>
          <input type="text" name="nomineeName[]">
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
            <option>INDIA</option>
            <option>USA</option>
            <option>UK</option>
          </select>
        </div>

        <div>
          <label>State</label>
          <select name="nomineeState[]">
            <option>Karnataka</option>
            <option>Maharashtra</option>
            <option>Goa</option>
          </select>
        </div>

        <div>
          <label>City</label>
          <select name="nomineeCity[]">
            <option value="">-- Select City --</option>
            <% 
              PreparedStatement psCity = null;
              ResultSet rsCity = null;
              try (Connection conn6 = DBConnection.getConnection()) {
                String sql = "SELECT NAME FROM GLOBALCONFIG.CITY ORDER BY UPPER(NAME)";
                psCity = conn6.prepareStatement(sql);
                rsCity = psCity.executeQuery();
                while (rsCity.next()) {
                  String city = rsCity.getString("NAME");
            %>
                  <option value="<%= city %>"><%= city %></option>
            <% 
                }
              } catch (Exception e) {
                out.println("<option disabled>Error loading cities</option>");
              } finally {
                if (rsCity != null) rsCity.close();
                if (psCity != null) psCity.close();
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
          <select name="nomineeRelation[]">
            <option value="">-- Select Relation --</option>
            <% 
              PreparedStatement psRelation = null;
              ResultSet rsRelation = null;
              try (Connection conn9 = DBConnection.getConnection()) {
                String sql = "SELECT DESCRIPTION FROM GLOBALCONFIG.RELATION ORDER BY RELATION_ID";
                psRelation = conn9.prepareStatement(sql);
                rsRelation = psRelation.executeQuery();
                while (rsRelation.next()) {
                  String rel = rsRelation.getString("DESCRIPTION");
            %>
                  <option value="<%= rel %>"><%= rel %></option>
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
          <input type="text" class="jointCustomerIDInput" name="jointCustomerID[]" readonly>
          <button type="button" class="inside-icon-btn" onclick="openJointCustomerLookup(this)" title="Search Customer">🔍</button>
        </div>
      </div>
      <br>

      <div class="address-grid">
        <div>
          <label>Salutation Code</label>
          <select name="jointSalutation[]" required>
            <option value="">-- Select Salutation --</option>
            <option value="MR">Mr.</option>
            <option value="MS">Ms.</option>
            <option value="MRS">Mrs.</option>
            <option value="DR">Dr.</option>
            <option value="PROF">Prof.</option>
          </select>
        </div>

        <div>
          <label>Joint Holder Name</label>
          <input type="text" name="jointName[]">
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
            <option>INDIA</option>
            <option>USA</option>
            <option>UK</option>
          </select>
        </div>

        <div>
          <label>State</label>
          <select name="jointState[]">
            <option>Karnataka</option>
            <option>Maharashtra</option>
            <option>Goa</option>
          </select>
        </div>

        <div>
          <label>City</label>
          <select name="jointCity[]">
            <option value="">-- Select City --</option>
            <% 
              PreparedStatement psCityJ = null;
              ResultSet rsCityJ = null;
              try (Connection connJ = DBConnection.getConnection()) {
                String sql = "SELECT NAME FROM GLOBALCONFIG.CITY ORDER BY UPPER(NAME)";
                psCityJ = connJ.prepareStatement(sql);
                rsCityJ = psCityJ.executeQuery();
                while (rsCityJ.next()) {
                  String city = rsCityJ.getString("NAME");
            %>
                <option value="<%= city %>"><%= city %></option>
            <% 
                }
              } catch (Exception e) {
                out.println("<option disabled>Error loading cities</option>");
              } finally {
                if (rsCityJ != null) rsCityJ.close();
                if (psCityJ != null) psCityJ.close();
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

<script>
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
const salutationSelect = block.querySelector('select[name="nomineeSalutation[]"]');
if (salutationSelect && customer.salutationCode) {
 salutationSelect.value = customer.salutationCode;
}

// Nominee Name
const nameInput = block.querySelector('input[name="nomineeName[]"]');
if (nameInput && customer.customerName) {
 nameInput.value = customer.customerName;
}

// Address 1
const address1Input = block.querySelector('input[name="nomineeAddress1[]"]');
if (address1Input && customer.address1) {
 address1Input.value = customer.address1;
}

// Address 2
const address2Input = block.querySelector('input[name="nomineeAddress2[]"]');
if (address2Input && customer.address2) {
 address2Input.value = customer.address2;
}

// Address 3
const address3Input = block.querySelector('input[name="nomineeAddress3[]"]');
if (address3Input && customer.address3) {
 address3Input.value = customer.address3;
}

// Country
const countrySelect = block.querySelector('select[name="nomineeCountry[]"]');
if (countrySelect && customer.country) {
 countrySelect.value = customer.country;
}

// State
const stateSelect = block.querySelector('select[name="nomineeState[]"]');
if (stateSelect && customer.state) {
 stateSelect.value = customer.state;
}

// City
const citySelect = block.querySelector('select[name="nomineeCity[]"]');
if (citySelect && customer.city) {
 citySelect.value = customer.city;
}

// Zip
const zipInput = block.querySelector('input[name="nomineeZip[]"]');
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

//==================== NOMINEE FUNCTIONS ====================

//Toggle Nominee Customer ID visibility
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
 input.value = ''; // Clear the value when hidden
 
 // Clear all auto-populated fields when switching to "No"
 clearNomineeFields(nomineeBlock);
}
}

//Clear nominee fields
function clearNomineeFields(block) {
block.querySelector('select[name="nomineeSalutation[]"]').value = '';
block.querySelector('input[name="nomineeName[]"]').value = '';
block.querySelector('input[name="nomineeAddress1[]"]').value = '';
block.querySelector('input[name="nomineeAddress2[]"]').value = '';
block.querySelector('input[name="nomineeAddress3[]"]').value = '';
block.querySelector('select[name="nomineeCountry[]"]').value = 'INDIA';
block.querySelector('select[name="nomineeState[]"]').value = 'Karnataka';
block.querySelector('select[name="nomineeCity[]"]').value = '';
block.querySelector('input[name="nomineeZip[]"]').value = '0';
}

//Open Nominee Customer Lookup Modal
function openNomineeCustomerLookup(button) {
const nomineeBlock = button.closest('.nominee-block');
const input = nomineeBlock.querySelector('.nomineeCustomerIDInput');

// Store reference to the input field that will receive the customer ID
window.currentNomineeInput = input;
window.currentNomineeBlock = nomineeBlock;

openCustomerLookup();
}

//Add Nominee
function addNominee() {
let fieldset = document.getElementById("nomineeFieldset");
let original = fieldset.querySelector(".nominee-block");
let clone = original.cloneNode(true);

// Clear all input values
clone.querySelectorAll("input, select").forEach(el => {
 if (el.type === 'radio') {
   // Reset radio buttons to "No" by default
   if (el.value === 'no') {
     el.checked = true;
   } else {
     el.checked = false;
   }
 } else if (el.tagName === 'SELECT') {
   // Reset select to first option or specific default
   if (el.name === 'nomineeCountry[]') {
     el.value = 'INDIA';
   } else if (el.name === 'nomineeState[]') {
     el.value = 'Karnataka';
   } else {
     el.selectedIndex = 0;
   }
 } else if (el.name === 'nomineeZip[]') {
   el.value = '0';
 } else {
   el.value = "";
 }
});

// Hide Customer ID container by default
const customerIDContainer = clone.querySelector('.nomineeCustomerIDContainer');
if (customerIDContainer) {
 customerIDContainer.style.display = 'none';
}

// Update radio button names to be unique
const nomineeBlocks = fieldset.querySelectorAll(".nominee-block");
const newIndex = nomineeBlocks.length + 1;
const radios = clone.querySelectorAll('.nomineeHasCustomerRadio');
radios.forEach(radio => {
 radio.name = `nomineeHasCustomerID_${newIndex}`;
});

// Set up remove button
clone.querySelector(".nominee-remove").onclick = function() {
 removeNominee(this);
};

fieldset.appendChild(clone);
updateNomineeSerials();
}

//Remove Nominee
function removeNominee(btn) {
let blocks = document.querySelectorAll(".nominee-block");

if (blocks.length <= 1) {
 alert("At least one nominee is required.");
 return;
}

btn.parentNode.remove();
updateNomineeSerials();
}

//Update Nominee Serial Numbers
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

//Toggle Joint Holder Customer ID visibility
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
 input.value = ''; // Clear the value when hidden
 
 // Clear all auto-populated fields when switching to "No"
 clearJointFields(jointBlock);
}
}

//Clear joint holder fields
function clearJointFields(block) {
block.querySelector('select[name="jointSalutation[]"]').value = '';
block.querySelector('input[name="jointName[]"]').value = '';
block.querySelector('input[name="jointAddress1[]"]').value = '';
block.querySelector('input[name="jointAddress2[]"]').value = '';
block.querySelector('input[name="jointAddress3[]"]').value = '';
block.querySelector('select[name="jointCountry[]"]').value = 'INDIA';
block.querySelector('select[name="jointState[]"]').value = 'Karnataka';
block.querySelector('select[name="jointCity[]"]').value = '';
block.querySelector('input[name="jointZip[]"]').value = '0';
}

//Open Joint Holder Customer Lookup Modal
function openJointCustomerLookup(button) {
const jointBlock = button.closest('.joint-block');
const input = jointBlock.querySelector('.jointCustomerIDInput');

// Store reference to the input field that will receive the customer ID
window.currentJointInput = input;
window.currentJointBlock = jointBlock;

openCustomerLookup();
}

//Add Joint Holder
function addJointHolder() {
let fieldset = document.getElementById("jointFieldset");
let original = fieldset.querySelector(".joint-block");
let clone = original.cloneNode(true);

// Clear all input values
clone.querySelectorAll("input, select").forEach(el => {
 if (el.type === 'radio') {
   // Reset radio buttons to "No" by default
   if (el.value === 'no') {
     el.checked = true;
   } else {
     el.checked = false;
   }
 } else if (el.tagName === 'SELECT') {
   // Reset select to first option or specific default
   if (el.name === 'jointCountry[]') {
     el.value = 'INDIA';
   } else if (el.name === 'jointState[]') {
     el.value = 'Karnataka';
   } else {
     el.selectedIndex = 0;
   }
 } else if (el.name === 'jointZip[]') {
   el.value = '0';
 } else {
   el.value = "";
 }
});

// Hide Customer ID container by default
const customerIDContainer = clone.querySelector('.jointCustomerIDContainer');
if (customerIDContainer) {
 customerIDContainer.style.display = 'none';
}

// Update radio button names to be unique
const jointBlocks = fieldset.querySelectorAll(".joint-block");
const newIndex = jointBlocks.length + 1;
const radios = clone.querySelectorAll('.jointHasCustomerRadio');
radios.forEach(radio => {
 radio.name = `jointHasCustomerID_${newIndex}`;
});

// Set up remove button
clone.querySelector(".nominee-remove").onclick = function() {
 removeJointHolder(this);
};

fieldset.appendChild(clone);
updateJointSerials();
}

//Remove Joint Holder
function removeJointHolder(btn) {
let blocks = document.querySelectorAll(".joint-block");

if (blocks.length <= 1) {
 alert("At least one joint holder is required.");
 return;
}

btn.parentNode.remove();
updateJointSerials();
}

//Update Joint Holder Serial Numbers
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

//Toast helper function
function showToast(message) {
if (typeof Toastify !== 'undefined') {
 Toastify({
   text: message,
   duration: 3000,
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