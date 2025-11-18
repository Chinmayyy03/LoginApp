<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int totalCustomers = 0;
    double totalLoan = 0; // static for now

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM CUSTOMERS WHERE BRANCH_CODE=?")) {
        ps.setString(1, branchCode);
        ResultSet rs = ps.executeQuery();		
        if (rs.next()) {
            totalCustomers = rs.getInt(1);
        }
    } catch (Exception e) {
        totalCustomers = 0;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Complete Bank Customer Form</title>
  <link rel="stylesheet" href="css/addCustomer.css">
 <!-- Add Toastify CSS -->
  <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
  
  <!-- Add Toastify JS -->
  <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
</head>
<body>

<form action="AddCustomerServlet" method="post" onsubmit="return validateForm()">
  <!----------------------------------------------------------------------- Main customer details -------------------------------------------------------------------->

  
  <fieldset>
    <legend>Customer Information</legend>
    <div class="form-grid">
<!-- Row 1 -->
      <div>
        <label>Is Individual</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="isIndividual" value="yes"> Yes</label>
          <label><input type="radio" name="isIndividual" value="no"> No</label>
        </div>
      </div>

      <div>
        <label>Gender</label>
        <select name="gender">
          <option value="">-- Select Gender --</option>
          <option>Male</option>
          <option>Female</option>
          <option>Other</option>
        </select>
      </div>

      <div>
        <label>Salutation Code</label>
       <select name="salutationCode" id="salutationCode" required>
  			<option value="">-- Select Salutation --</option>
  			<option value="MR">Mr.</option>
 	 		<option value="MS">Ms.</option>
  			<option value="MRS">Mrs.</option>
  			<option value="DR">Dr.</option>
  			<option value="PROF">Prof.</option>
		</select>
      </div>

      <div>
        <label>First Name</label>
        <input type="text" name="firstName" id="firstName" oninput="this.value = this.value.replace(/[^A-Za-z]/g, ''); updateCustomerName();">
      </div>
<!-- Row 2 -->
      <div>
        <label>Surname Name</label>
        <input type="text" name="surname" id="surname" oninput="this.value = this.value.replace(/[^A-Za-z]/g, ''); updateCustomerName();">
      </div>

      <div>
        <label>Middle Name</label>
        <input type="text" name="middleName" id="middleName" oninput="this.value = this.value.replace(/[^A-Za-z]/g, ''); updateCustomerName();">
      </div>
      
      <div>
        <label>Customer Name</label>
        <input type="text" name="customerName" id="customerName" oninput="this.value = this.value.replace(/[^A-Za-z]/g, ' ')" readonly>
      </div>

      <div>
        <label>Birth Date</label>
        <input type="date" name="birthDate">
      </div>
<!-- Row 3 -->
      <div>
        <label>Registration Date</label>
        <input type="date" name="registrationDate" >
      </div>
      
      <div>
        <label>Is Minor</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="isMinor" value="yes" onclick="toggleMinorFields()"> Yes</label>
          <label><input type="radio" name="isMinor" value="no" onclick="toggleMinorFields()"> No</label>
        </div>
      </div>

      

      <div>
        <label>Guardian Name</label>
        <input type="text" name="guardianName" id="guardianName" oninput="this.value = this.value.replace(/[^A-Za-z]/g, ' ')" disabled>
      </div>

      <div>
        <label>Relation with Guardian</label>
        <select name="relationGuardian" id="relationGuardian" disabled>
    <option value="">-- Select Relation with Guardian --</option>
    <%
      PreparedStatement psRelationWithGuardian = null;
      ResultSet rsRelationWithGuardian = null;
      try (Connection conn9 = DBConnection.getConnection()) {
          String sql = "SELECT DESCRIPTION FROM GLOBALCONFIG.RELATION ORDER BY RELATION_ID";
          psRelationWithGuardian = conn9.prepareStatement(sql);
          rsRelationWithGuardian = psRelationWithGuardian.executeQuery();
          while (rsRelationWithGuardian.next()) {
              String relationWithGuardian = rsRelationWithGuardian.getString("DESCRIPTION");
    %>
              <option value="<%= relationWithGuardian %>"><%= relationWithGuardian %></option>
    <%
          }
      } catch (Exception e) {
          out.println("<option disabled>Error loading Relation With Guardian</option>");
          e.printStackTrace();
      } finally {
          if (rsRelationWithGuardian != null) rsRelationWithGuardian.close();
          if (psRelationWithGuardian != null) psRelationWithGuardian.close();
      }
    %>
  </select>
      </div>
<!-- Row 4 -->
      <div>
        <label>Religion Code</label>
        <select name="religionyCode" required>
    <option value="">-- Select Religion Code --</option>
    <%
      PreparedStatement psReligionCode = null;
      ResultSet rsReligionCode = null;
      try (Connection conn7 = DBConnection.getConnection()) {
          String sql = "SELECT RELIGION_CODE FROM GLOBALCONFIG.RELIGIONCASTE ORDER BY RELIGION_CODE";
          psReligionCode = conn7.prepareStatement(sql);
          rsReligionCode = psReligionCode.executeQuery();
          while (rsReligionCode.next()) {
              String religionCode = rsReligionCode.getString("RELIGION_CODE");
    %>
              <option value="<%= religionCode %>"><%= religionCode %></option>
    <%
          }
      } catch (Exception e) {
          out.println("<option disabled>Error loading Religion Code</option>");
          e.printStackTrace();
      } finally {
          if (rsReligionCode != null) rsReligionCode.close();
          if (psReligionCode != null) psReligionCode.close();
      }
    %>
  </select>
</div>

    

      <div>
        <label>Caste Code</label>
        <select name="casteCode" required>
    <option value="">-- Select Caste Code --</option>
    <%
      PreparedStatement psCasteCode = null;
      ResultSet rsCasteCode = null;
      try (Connection conn8 = DBConnection.getConnection()) {
          String sql = "SELECT CASTE_CODE FROM GLOBALCONFIG.RELIGIONCASTE ORDER BY CASTE_CODE";
          psCasteCode = conn8.prepareStatement(sql);
          rsCasteCode = psCasteCode.executeQuery();
          while (rsCasteCode.next()) {
              String casteCode = rsCasteCode.getString("CASTE_CODE");
    %>
              <option value="<%= casteCode %>"><%= casteCode %></option>
    <%
          }
      } catch (Exception e) {
          out.println("<option disabled>Error loading Caste Code</option>");
          e.printStackTrace();
      } finally {
          if (rsCasteCode != null) rsCasteCode.close();
          if (psCasteCode != null) psCasteCode.close();
      }
    %>
  </select>
      </div>
      
      <div>
  <label>Category Code</label>
  <select name="categoryCode" required>
    <option value="">-- Select Category --</option>
    <%
      PreparedStatement psCategory = null;
      ResultSet rsCategory = null;
      try (Connection conn2 = DBConnection.getConnection()) {
          String sql = "SELECT CATEGORY_CODE FROM GLOBALCONFIG.CATEGORY ORDER BY CATEGORY_CODE";
          psCategory = conn2.prepareStatement(sql);
          rsCategory = psCategory.executeQuery();
          while (rsCategory.next()) {
              String categoryCode = rsCategory.getString("CATEGORY_CODE");
    %>
              <option value="<%= categoryCode %>"><%= categoryCode %></option>
    <%
          }
      } catch (Exception e) {
          out.println("<option disabled>Error loading categories</option>");
          e.printStackTrace();
      } finally {
          if (rsCategory != null) rsCategory.close();
          if (psCategory != null) psCategory.close();
      }
    %>
  </select>
</div>
      
      <div>
        <label>Sub Category Code</label>
        <input type="text" name="subCategoryCode" value="1">
      </div>

      
<!-- Row 5 -->
      <div>
  <label>Constitution Code</label>
  <select name="constitutionCode" required>
    <option value="">-- Select Constitution Code --</option>
    <%
      PreparedStatement psConstitutionCode = null;
      ResultSet rsConstitutionCode = null;
      try (Connection conn3 = DBConnection.getConnection()) {
          String sql = "SELECT CONSTITUTION_CODE FROM GLOBALCONFIG.CONSTITUTION ORDER BY CONSTITUTION_CODE";
          psConstitutionCode = conn3.prepareStatement(sql);
          rsConstitutionCode = psConstitutionCode.executeQuery();
          while (rsConstitutionCode.next()) {
              String constitutionCode = rsConstitutionCode.getString("CONSTITUTION_CODE");
    %>
              <option value="<%= constitutionCode %>"><%= constitutionCode %></option>
    <%
          }
      } catch (Exception e) {
          out.println("<option disabled>Error loading Constitution Code</option>");
          e.printStackTrace();
      } finally {
          if (rsConstitutionCode != null) rsConstitutionCode.close();
          if (psConstitutionCode != null) psConstitutionCode.close();
      }
    %>
  </select>
</div>

      <div>
  <label>Occupation Code</label>
  <select name="occupationCode" required>
    <option value="">-- Select Occupation Code --</option>
    <%
      PreparedStatement psOccupationCode = null;
      ResultSet rsOccupationCode = null;
      try (Connection conn4 = DBConnection.getConnection()) {
          String sql = "SELECT DESCRIPTION FROM GLOBALCONFIG.OCCUPATION ORDER BY OCCUPATION_ID";
          psOccupationCode = conn4.prepareStatement(sql);
          rsOccupationCode = psOccupationCode.executeQuery();
          while (rsOccupationCode.next()) {
              String occupationCode = rsOccupationCode.getString("DESCRIPTION");
    %>
              <option value="<%= occupationCode %>"><%= occupationCode %></option>
    <%
          }
      } catch (Exception e) {
          out.println("<option disabled>Error loading Occupation Code</option>");
          e.printStackTrace();
      } finally {
          if (rsOccupationCode != null) rsOccupationCode.close();
          if (psOccupationCode != null) psOccupationCode.close();
      }
    %>
  </select>
</div>

      <div>
        <label>Vehicle Owned</label>
        <select name="vehicleOwned">
          <option>NOT APPLICABLE</option>
          <option>CAR</option>
          <option>BIKE</option>
          <option>BOTH</option>
        </select>
      </div>

       <div>
        <label>Member Type</label>
        <select name="memberType">
          <option>A</option>
          <option>B</option>
          <option>O</option>
        </select>
      </div>

      
<!-- Row 6 -->
      <div>
        <label>Email ID</label>
        <input type="email" name="email">
      </div>

      <div>
        <label>GSTIN No</label>
        <input type="text" name="gstinNo">
      </div>
      
      <div>
        <label>Member Number</label>
        <input type="text" name="memberNumber" value="" maxlength="2">
      </div>

      <div>
        <label>CKYC No</label>
        <input type="text" name="ckyNo">
      </div>

      
<!-- Row 7 -->
     <div>
        <label>Risk Category</label>
        <select name="riskCategory">
          <option>LOW</option>
          <option>MEDIUM</option>
          <option>HIGH</option>
        </select>
      </div>
      
  </fieldset>
  
  
<!------------------------------------------------------------------ Personal Info --------------------------------------------------------------------------------->
    <fieldset>
  <legend>Personal Information</legend>
  <div class="personal-grid">

    <!-- Row 1 -->
    <div>
      <label for="motherName">Mother Name</label>
      <input type="text" id="motherName" name="motherName">
    </div>

    <div>
      <label for="fatherName">Father Name</label>
      <input type="text" id="fatherName" name="fatherName">
    </div>

    <div>
      <label>Marital Status</label>
      <div class="radio-group">
        <label><input type="radio" name="maritalStatus" value="Married" onclick="toggleMarriedFields()"> Married</label>
        <label><input type="radio" name="maritalStatus" value="Single" onclick="toggleMarriedFields()"> Single</label>
        <label><input type="radio" name="maritalStatus" value="Other" onclick="toggleMarriedFields()"> Other</label>
      </div>
    </div>

    <!-- Row 2 -->
    <div>
      <label for="children">No. of Children</label>
		<input type="number" id="children" name="children" value="" min="0" oninput="if(this.value.length > 2) this.value = this.value.slice(0,2);">
    </div>

    <div>
      <label for="dependents">No. of Dependents</label>
      <input type="number" id="dependents" name="dependents" value="" min="0" oninput="if(this.value.length > 2) this.value = this.value.slice(0,2);">
    </div>
    
</fieldset>


  <!------------------------------------------------------------- Permanent/Address Info ---------------------------------------------------------------------------->
  <fieldset>
  <legend>Permanent / Address Information</legend>
  <div class="address-grid">
    <!-- Row 1 -->
    <div>
      <label>Nationality</label>
      <input type="text" name="nationality" value="INDIAN">
    </div>

    <div>
  <label>Residence Type</label>
  <select name="residenceType" required>
    <option value="">-- Select Residence Type --</option>
    <%
      PreparedStatement psResidenceType = null;
      ResultSet rsResidenceType = null;
      try (Connection conn5 = DBConnection.getConnection()) {
          String sql = "SELECT DESCRIPTION FROM GLOBALCONFIG.RESIDENCETYPE ORDER BY RESIDENCETYPE_ID ";
          psResidenceType = conn5.prepareStatement(sql);
          rsResidenceType = psResidenceType.executeQuery();
          while (rsResidenceType.next()) {
              String residenceType = rsResidenceType.getString("DESCRIPTION");
    %>
              <option value="<%= residenceType %>"><%= residenceType %></option>
    <%
          }
      } catch (Exception e) {
          out.println("<option disabled>Error loading Residence Type</option>");
          e.printStackTrace();
      } finally {
          if (rsResidenceType != null) rsResidenceType.close();
          if (psResidenceType != null) psResidenceType.close();
      }
    %>
  </select>
</div>

    <div>
      <label>Residence Status</label>
      <select name="residenceStatus">
        <option>NOT APPLICABLE</option>
        <option>BANGLOW</option>
        <option>ROW HOUSE</option>
        <option>FLAT</option>
        <option>OTHER</option>
      </select>
    </div>

    <!-- Row 2 -->
    <div>
      <label>Address 1</label>
      <input type="text" name="address1">
    </div>

    <div>
      <label>Address 2</label>
      <input type="text" name="address2">
    </div>

    <div>
      <label>Address 3</label>
      <input type="text" name="address3">
    </div>

    <!-- Row 3 -->
    <div>
      <label>Country</label>
      <select name="country">
        <option>INDIA</option>
        <option>USA</option>
        <option>UK</option>
      </select>
    </div>

    <div>
      <label>State</label>
      <select name="state">
        <option>Maharashtra</option>
        <option>Karnataka</option>
        <option>Goa</option>
      </select>
    </div>
    
    
    <div>
      <label>City</label>
      <select name="city" required>
    <option value="">-- Select City --</option>
    <%
      PreparedStatement psCity = null;
      ResultSet rsCity = null;
      try (Connection conn6 = DBConnection.getConnection()) {
          String sql = "SELECT NAME FROM GLOBALCONFIG.CITY ORDER BY UPPER(NAME) ";
          psCity = conn6.prepareStatement(sql);
          rsCity = psCity.executeQuery();
          while (rsCity.next()) {
              String city = rsCity.getString("NAME");
    %>
              <option value="<%= city %>"><%= city %></option>
    <%
          }
      } catch (Exception e) {
          out.println("<option disabled>Error loading Residence Type</option>");
          e.printStackTrace();
      } finally {
          if (rsCity != null) rsCity.close();
          if (psCity != null) psCity.close();
      }
    %>
  </select>
</div>

    <!-- Row 4 -->
    <div>
      <label>Zip</label>
      <input type="text" name="zip" value="">
    </div>

    <div>
      <label>Mobile No</label>
      <div style="display: flex; gap: 5px;">

        <input type="text" name="mobileNo">
      </div>
    </div>

    <div>
      <label>Residence Phone</label>
      <input type="text" name="residencePhone" value="">
    </div>

    <!-- Row 5 -->
    <div>
      <label>Office Phone</label>
      <input type="text" name="officePhone" value="">
    </div>
  </div>
</fieldset>


  <!------------------------------------------------------------------ KYC and Document Checklist ----------------------------------------------------------------->
  <!-- KYC and Document Checklist -->
<fieldset class="kyc-fieldset">
  <legend>KYC Document Details</legend>

  <!-- Row 1: ID Proof / Address Proof -->
  <div class="kyc-row">
    <!-- Left Column: ID Proof -->
    <div class="kyc-section">
      <h4>Savings Account (ID Proof)</h4>
      <table>
        <tr>
          <th>Select</th><th>Document</th><th>Expiry Date</th><th>Document Number</th>
        </tr>
        <tr>
          <td><input type="checkbox" name="passport_check"></td>
          <td>Passport</td>
          <td><input type="date" name="passport_expiry"></td>
          <td><input type="text" name="passportNumber" id="passportNumber">
          </td>
        </tr>
        <tr>
          <td><input type="checkbox" name="pan_check"></td>
          <td>PAN Card</td>
          <td><input type="date" name="pan_expiry"></td>
          <td><input type="text" name="pan" id="pan"
            style="text-transform:uppercase;">
          </td>
        </tr>
        <tr>
          <td><input type="checkbox" name="voterid_check"></td>
          <td>Election Card</td>
          <td><input type="date" name="voterid_expiry"></td>
          <td><input type="text" name="voterid" id="voterid"
            style="text-transform:uppercase;">
          </td>
        </tr>
        <tr>
          <td><input type="checkbox" name="dl_check"></td>
          <td>Driving License</td>
          <td><input type="date" name="dl_expiry"></td>
          <td><input type="text" name="dl" id="dl"
            style="text-transform:uppercase;">
          </td>
        </tr>
        <tr>
          <td><input type="checkbox" name="aadhar_check"></td>
          <td>Aadhar Card</td>
          <td><input type="date" name="aadhar_expiry"></td>
          <td><input type="text" name="aadhar">
          </td>
        </tr>
        <tr>
          <td><input type="checkbox" name="nrega_check"></td>
          <td>NREGA Job Card</td>
          <td><input type="date" name="nrega_expiry"></td>
          <td><input type="text" name="nrega" id="nrega"
            style="text-transform:uppercase;">
          </td>
        </tr>
      </table>
    </div>

    <!-- Vertical Divider -->
    <div class="kyc-divider"></div>

    <!-- Right Column: Address Proof -->
    <div class="kyc-section">
      <h4>Savings Account (Address Proof)</h4>
      <table>
        <tr>
          <th>Select</th><th>Document</th><th>Expiry Date</th><th>Document Number</th>
        </tr>
        <tr>
          <td><input type="checkbox" name="telephone_check"></td>
          <td>Telephone Bill</td>
          <td><input type="date" name="telephone_expiry"></td>
          <td><input type="text" name="telephone"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="bank_check"></td>
          <td>Bank Statement</td>
          <td><input type="date" name="bank_expiry"></td>
          <td><input type="text" name="bank_statement"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="govt_check"></td>
          <td>Govt. Documents</td>
          <td><input type="date" name="govt_expiry"></td>
          <td><input type="text" name="govt_doc"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="electricity_check"></td>
          <td>Electricity Bill</td>
          <td><input type="date" name="electricity_expiry"></td>
          <td><input type="text" name="electricity"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="ration_check"></td>
          <td>Ration Card</td>
          <td><input type="date" name="ration_expiry"></td>
          <td><input type="text" name="ration" id="ration"
            style="text-transform:uppercase;">
          </td>
        </tr>
      </table>
    </div>
  </div>

  <hr>

  <!-- Row 2: Proprietary / Business Concern -->
  <div class="kyc-row">
    <div class="kyc-section">
      <h4>Accounts of Proprietary Concern</h4>
      <table>
        <tr><th>Select</th><th>Document</th><th>Expiry Date</th></tr>
        <tr>
          <td><input type="checkbox" name="rent_check"></td>
          <td>Registered Rent Agreement Copy</td>
          <td><input type="date" name="rent_expiry"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="cert_check"></td>
          <td>Certificate / License</td>
          <td><input type="date" name="cert_expiry"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="tax_check"></td>
          <td>Sales and Income Tax Returns</td>
          <td><input type="date" name="tax_expiry"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="cst_check"></td>
          <td>CST / VAT Certificate</td>
          <td><input type="date" name="cst_expiry"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="reg_check"></td>
          <td>License issued by Registering Authority</td>
          <td><input type="date" name="reg_expiry"></td>
        </tr>
      </table>
    </div>

    <div class="kyc-divider"></div>

    <div class="kyc-section">
      <h4>Business Concern</h4>
      <table>
        <tr><th>Select</th><th>Document</th><th>Expiry Date</th></tr>
        <tr>
          <td><input type="checkbox" name="inc_check"></td>
          <td>Certificate of Incorporation</td>
          <td><input type="date" name="inc_expiry"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="board_check"></td>
          <td>Resolution of the Board of Directors</td>
          <td><input type="date" name="board_expiry"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="poa_check"></td>
          <td>Power of Attorney granted to its Managers</td>
          <td><input type="date" name="poa_expiry"></td>
        </tr>
      </table>
    </div>
  </div>
</fieldset>
<!-- Submit & Reset Buttons -->
  <div class="form-buttons">
    <button type="submit">Submit</button>
    <button type="reset">Reset</button>
  </div>
  
</form>
<script>
function toggleMinorFields() {
  const isMinor = document.querySelector('input[name="isMinor"]:checked').value;
  const guardianName = document.getElementById('guardianName');
  const relationGuardian = document.getElementById('relationGuardian');

  if (isMinor === 'yes') {
    guardianName.disabled = false;
    relationGuardian.disabled = false;
  } else {
    guardianName.disabled = true;
    relationGuardian.disabled = true;

    // Optional: clear fields when disabled
    guardianName.value = '';
    relationGuardian.value = 'NOT SPECIFIED';
  }
}

function toggleMarriedFields() {
	  const maritalStatus = document.querySelector('input[name="maritalStatus"]:checked').value;
	  const noOFChildren = document.getElementById('children');
	  const noOfDependents = document.getElementById('dependents');

	  if (maritalStatus === 'Single') {
		  noOFChildren.disabled = true;
		  noOfDependents.disabled = true;
	  } else {
		  noOFChildren.disabled = false;
		  noOfDependents.disabled = false;

	    // Optional: clear fields when disabled
	    noOFChildren.value = '';
	    noOfDependents.value = 'NOT SPECIFIED';
	  }
	}


document.addEventListener("DOMContentLoaded", function() {
  // Select all rows inside the KYC tables
  document.querySelectorAll(".kyc-section table tr").forEach(row => {
    const checkbox = row.querySelector('input[type="checkbox"]');
    const inputs = row.querySelectorAll('input[type="date"], input[type="text"]');
    
    if (checkbox) {
      // Initially disable all input fields
      inputs.forEach(input => input.disabled = true);

      // Toggle enable/disable based on checkbox status
      checkbox.addEventListener("change", () => {
        inputs.forEach(input => input.disabled = !checkbox.checked);
      });
    }
  });
});



//Validation patterns
const validationPatterns = {
    gstin: /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/,
    pan: /^[A-Z]{5}[0-9]{4}[A-Z]{1}$/,
    aadhar: /^[0-9]{12}$/,
    mobile: /^[6-9][0-9]{9}$/,
    phone: /^[0-9]{10,11}$/,
    zip: /^[0-9]{6}$/,
    voterId: /^[A-Z]{3}[0-9]{7}$/,
    drivingLicense: /^[A-Z]{2}[0-9]{13}$/,
    passport: /^[A-Z]{1}[0-9]{7}$/,
    nrega: /^[A-Z]{2}-[0-9]{2}-[0-9]{3}-[0-9]{3}-[0-9]{6}$/
};

// Real-time input formatting and validation
function setupFieldValidations() {
    // GSTIN validation
    const gstinField = document.querySelector('input[name="gstinNo"]');
    if (gstinField) {
        gstinField.maxLength = 15;
        gstinField.addEventListener('input', function(e) {
            this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
        });
        gstinField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.gstin.test(this.value)) {
                showError(this, 'Invalid GSTIN format (e.g., 22AAAAA0000A1Z5)');
            } else {
                clearError(this);
            }
        });
    }

    // Member Number validation (only 2 digits)
  const memberField = document.querySelector('input[name="memberNumber"]');
if (memberField) {
    memberField.maxLength = 2;

    memberField.addEventListener('input', function(e) {
        // Allow only numbers, max 2 digits
        this.value = this.value.replace(/[^0-9]/g, '').slice(0, 2);
    });

    memberField.addEventListener('blur', function() {
        if (!this.value) {
            showError(this, 'Member Number is required');
        } else if (this.value.length < 1 || this.value.length > 2) {
            showError(this, 'Member Number must be 1 or 2 digits');
        } else {
            clearError(this);
        }
    });
}

    // ZIP Code validation
    const zipField = document.querySelector('input[name="zip"]');
    if (zipField) {
        zipField.maxLength = 6;
        zipField.addEventListener('input', function(e) {
            this.value = this.value.replace(/[^0-9]/g, '').slice(0, 6);
        });
        zipField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.zip.test(this.value)) {
                showError(this, 'ZIP code must be 6 digits');
            } else {
                clearError(this);
            }
        });
    }

    // Mobile Number validation
    const mobileField = document.querySelector('input[name="mobileNo"]');
    if (mobileField) {
        mobileField.maxLength = 10;
        mobileField.addEventListener('input', function(e) {
            this.value = this.value.replace(/[^0-9]/g, '').slice(0, 10);
        });
        mobileField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.mobile.test(this.value)) {
                showError(this, 'Mobile number must be 10 digits starting with 6-9');
            } else {
                clearError(this);
            }
        });
    }

    // Residence Phone validation
    const residencePhoneField = document.querySelector('input[name="residencePhone"]');
    if (residencePhoneField) {
        residencePhoneField.maxLength = 11;
        residencePhoneField.addEventListener('input', function(e) {
            this.value = this.value.replace(/[^0-9]/g, '').slice(0, 11);
        });
        residencePhoneField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.phone.test(this.value)) {
                showError(this, 'Phone number must be 10-11 digits');
            } else {
                clearError(this);
            }
        });
    }

    // Office Phone validation
    const officePhoneField = document.querySelector('input[name="officePhone"]');
    if (officePhoneField) {
        officePhoneField.maxLength = 11;
        officePhoneField.addEventListener('input', function(e) {
            this.value = this.value.replace(/[^0-9]/g, '').slice(0, 11);
        });
        officePhoneField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.phone.test(this.value)) {
                showError(this, 'Phone number must be 10-11 digits');
            } else {
                clearError(this);
            }
        });
    }

    // Passport Number validation
    const passportField = document.getElementById('passportNumber');
    if (passportField) {
        passportField.maxLength = 8;
        passportField.addEventListener('input', function(e) {
            this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
        });
        passportField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.passport.test(this.value)) {
                showError(this, 'Passport format: 1 letter + 7 digits (e.g., A1234567)');
            } else {
                clearError(this);
            }
        });
    }

    // PAN Card validation
    const panField = document.getElementById('pan');
    if (panField) {
        panField.maxLength = 10;
        panField.addEventListener('input', function(e) {
            this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
        });
        panField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.pan.test(this.value)) {
                showError(this, 'PAN format: ABCDE1234F (5 letters, 4 digits, 1 letter)');
            } else {
                clearError(this);
            }
        });
    }

    // Voter ID validation
    const voterIdField = document.getElementById('voterid');
    if (voterIdField) {
        voterIdField.maxLength = 10;
        voterIdField.addEventListener('input', function(e) {
            this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
        });
        voterIdField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.voterId.test(this.value)) {
                showError(this, 'Voter ID format: ABC1234567 (3 letters + 7 digits)');
            } else {
                clearError(this);
            }
        });
    }

    // Driving License validation
    const dlField = document.getElementById('dl');
    if (dlField) {
        dlField.maxLength = 15;
        dlField.addEventListener('input', function(e) {
            this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
        });
        dlField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.drivingLicense.test(this.value)) {
                showError(this, 'DL format: AB1234567890123 (2 letters + 13 digits)');
            } else {
                clearError(this);
            }
        });
    }

    // Aadhar Card validation
    const aadharField = document.querySelector('input[name="aadhar"]');
    if (aadharField) {
        aadharField.maxLength = 12;
        aadharField.addEventListener('input', function(e) {
            this.value = this.value.replace(/[^0-9]/g, '').slice(0, 12);
        });
        aadharField.addEventListener('blur', function() {
            if (this.value && !validationPatterns.aadhar.test(this.value)) {
                showError(this, 'Aadhar must be exactly 12 digits');
            } else {
                clearError(this);
            }
        });
    }

    // NREGA Job Card validation
    const nregaField = document.getElementById('nrega');
    if (nregaField) {
        nregaField.maxLength = 22;
        nregaField.addEventListener('input', function(e) {
            let value = this.value.toUpperCase().replace(/[^A-Z0-9-]/g, '');
            // Auto-format: AB-12-345-678-901234
            if (value.length > 2 && value[2] !== '-') {
                value = value.slice(0, 2) + '-' + value.slice(2);
            }
            if (value.length > 5 && value[5] !== '-') {
                value = value.slice(0, 5) + '-' + value.slice(5);
            }
            if (value.length > 9 && value[9] !== '-') {
                value = value.slice(0, 9) + '-' + value.slice(9);
            }
            if (value.length > 13 && value[13] !== '-') {
                value = value.slice(0, 13) + '-' + value.slice(13);
            }
            this.value = value;
        });
    }

    // Document number validations (alphanumeric)
    const docFields = ['telephone', 'bank_statement', 'govt_doc', 'electricity'];
    docFields.forEach(fieldName => {
        const field = document.querySelector(`input[name="${fieldName}"]`);
        if (field) {
            field.maxLength = 20;
            field.addEventListener('input', function(e) {
                this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
            });
        }
    });

    // Ration Card validation
    const rationField = document.getElementById('ration');
    if (rationField) {
        rationField.maxLength = 15;
        rationField.addEventListener('input', function(e) {
            this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
        });
    }
}

// Show error message
function showError(field, message) {
    clearError(field);
    field.style.borderColor = '#ff0000';
    field.style.backgroundColor = '#ffe6e6';
    
    const errorDiv = document.createElement('div');
    errorDiv.className = 'error-message';
    errorDiv.style.color = '#ff0000';
    errorDiv.style.fontSize = '11px';
    errorDiv.style.marginTop = '3px';
    errorDiv.textContent = message;
    
    field.parentNode.appendChild(errorDiv);
}

// Clear error message
function clearError(field) {
    field.style.borderColor = '';
    field.style.backgroundColor = '';
    
    const errorDiv = field.parentNode.querySelector('.error-message');
    if (errorDiv) {
        errorDiv.remove();
    }
}

//Enhanced form validation before submit
function validateForm() {
    let isValid = true;
    const errors = [];

    // Validate GSTIN if filled
    const gstin = document.querySelector('input[name="gstinNo"]').value;
    if (gstin && !validationPatterns.gstin.test(gstin)) {
        errors.push('• Invalid GSTIN number');
        isValid = false;
    }

    // Validate Mobile Number (required)
    const mobile = document.querySelector('input[name="mobileNo"]').value;
    if (!mobile) {
        errors.push('• Mobile number is required');
        isValid = false;
    } else if (!validationPatterns.mobile.test(mobile)) {
        errors.push('• Invalid mobile number');
        isValid = false;
    }

    // Validate ZIP if filled
    const zip = document.querySelector('input[name="zip"]').value;
    if (zip && !validationPatterns.zip.test(zip)) {
        errors.push('• Invalid ZIP code');
        isValid = false;
    }

    // Validate PAN if filled
    const pan = document.getElementById('pan').value;
    if (pan && !validationPatterns.pan.test(pan)) {
        errors.push('• Invalid PAN card number');
        isValid = false;
    }

    // Validate Aadhar if filled
    const aadhar = document.querySelector('input[name="aadhar"]').value;
    if (aadhar && !validationPatterns.aadhar.test(aadhar)) {
        errors.push('• Invalid Aadhar number');
        isValid = false;
    }

    // Validate Passport if filled
    const passport = document.getElementById('passportNumber').value;
    if (passport && !validationPatterns.passport.test(passport)) {
        errors.push('• Invalid Passport number');
        isValid = false;
    }

    // Validate Voter ID if filled
    const voterId = document.getElementById('voterid').value;
    if (voterId && !validationPatterns.voterId.test(voterId)) {
        errors.push('• Invalid Voter ID');
        isValid = false;
    }

    // Validate Driving License if filled
    const dl = document.getElementById('dl').value;
    if (dl && !validationPatterns.drivingLicense.test(dl)) {
        errors.push('• Invalid Driving License number');
        isValid = false;
    }

    // ✅ Validate at least one ID Proof document is filled
    const idProofFilled = 
        (document.querySelector('input[name="passport_check"]').checked && document.querySelector('input[name="passport_expiry"]').value && document.querySelector('input[name="passportNumber"]').value.trim()) ||
        (document.querySelector('input[name="pan_check"]').checked && document.querySelector('input[name="pan_expiry"]').value && document.getElementById('pan').value.trim()) ||
        (document.querySelector('input[name="voterid_check"]').checked && document.querySelector('input[name="voterid_expiry"]').value && document.getElementById('voterid').value.trim()) ||
        (document.querySelector('input[name="dl_check"]').checked && document.querySelector('input[name="dl_expiry"]').value && document.getElementById('dl').value.trim()) ||
        (document.querySelector('input[name="aadhar_check"]').checked && document.querySelector('input[name="aadhar_expiry"]').value && document.querySelector('input[name="aadhar"]').value.trim()) ||
        (document.querySelector('input[name="nrega_check"]').checked && document.querySelector('input[name="nrega_expiry"]').value && document.getElementById('nrega').value.trim());

    if (!idProofFilled) {
        errors.push('• At least one ID Proof document must be selected and filled');
        isValid = false;
    }

    // ✅ Validate at least one Address Proof document is filled
    const addressProofFilled = 
        (document.querySelector('input[name="telephone_check"]').checked && document.querySelector('input[name="telephone_expiry"]').value && document.querySelector('input[name="telephone"]').value.trim()) ||
        (document.querySelector('input[name="bank_check"]').checked && document.querySelector('input[name="bank_expiry"]').value && document.querySelector('input[name="bank_statement"]').value.trim()) ||
        (document.querySelector('input[name="govt_check"]').checked && document.querySelector('input[name="govt_expiry"]').value && document.querySelector('input[name="govt_doc"]').value.trim()) ||
        (document.querySelector('input[name="electricity_check"]').checked && document.querySelector('input[name="electricity_expiry"]').value && document.querySelector('input[name="electricity"]').value.trim()) ||
        (document.querySelector('input[name="ration_check"]').checked && document.querySelector('input[name="ration_expiry"]').value && document.getElementById('ration').value.trim());

    if (!addressProofFilled) {
        errors.push('• At least one Address Proof document must be selected and filled');
        isValid = false;
    }

    if (!isValid) {
        // Show toast notification with all errors
        showValidationToast(errors);
    }

    return isValid;
}

// Function to show validation errors as toast
function showValidationToast(errors) {
    const errorMessage = '❌ Please fix the following errors:\n\n' + errors.join('\n');
    
    Toastify({
        text: errorMessage,
        duration: 6000, 
        close: true,
        gravity: "top",
        position: "center",
        style: {
            background: "#fff",
            color: "#333",
            borderRadius: "8px",
            fontSize: "14px",
            padding: "20px 30px",
            boxShadow: "0 4px 12px rgba(0,0,0,0.3)",
            borderLeft: "5px solid #f44336",
            marginTop: "20px",
            maxWidth: "500px",
            whiteSpace: "pre-line"
        },
        stopOnFocus: true,
        onClick: function(){} 
    }).showToast();
}

// Initialize validations when page loads
document.addEventListener('DOMContentLoaded', function() {
    setupFieldValidations();
});


// for add name in customer name from input fields
function updateCustomerName() {
    const first = document.getElementById("firstName").value.trim();
    const middle = document.getElementById("middleName").value.trim();
    const surname = document.getElementById("surname").value.trim();

    // Build full name (only include non-empty parts)
    const fullName = [first, middle, surname].filter(Boolean).join(" ");

    document.getElementById("customerName").value = fullName;
  }
  
  
  
//Update breadcrumb on page load
// Update breadcrumb on page load
window.onload = function() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Add Customer');
    }
};




//Add custom CSS for toast overlay positioning
const toastStyle = document.createElement('style');
toastStyle.textContent = `
    .toastify {
        position: fixed !important;
        z-index: 9999 !important;
        pointer-events: auto !important;
    }
    
    .toastify.on {
        position: fixed !important;
    }
`;
document.head.appendChild(toastStyle);

// Check URL parameters for success/error messages
window.addEventListener('DOMContentLoaded', function() {
    const urlParams = new URLSearchParams(window.location.search);
    const status = urlParams.get('status');
    const customerId = urlParams.get('customerId');
    const message = urlParams.get('message');
    
    if (status === 'success') {
        const toast = Toastify({
            text: "✅ Customer added successfully!\nCustomer ID: " + customerId,
            duration: 5000,
            close: true,
            gravity: "top", // top or bottom
            position: "center", // left, center or right
            style: {
                background: "#fff",
                color: "#333",
                borderRadius: "8px",
                fontSize: "14px",
                padding: "16px 24px",
                boxShadow: "0 3px 10px rgba(0,0,0,0.2)",
                borderLeft: "5px solid #4caf50",
                marginTop: "20px"
            },
            stopOnFocus: true,
            onClick: function(){} // Callback after click
        }).showToast();
        
        // Add progress bar animation
        const toastElement = toast.toastElement;
        const progressBar = document.createElement('div');
        progressBar.style.cssText = `
            position: absolute;
            bottom: 0;
            left: 0;
            height: 4px;
            width: 100%;
            background-color: #4caf50;
            animation: shrink 5s linear forwards;
        `;
        
        // Add keyframe animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes shrink {
                from { width: 100%; }
                to { width: 0%; }
            }
        `;
        document.head.appendChild(style);
        
        toastElement.style.position = 'relative';
        toastElement.style.overflow = 'hidden';
        toastElement.appendChild(progressBar);
        
        // Clear URL parameters after showing toast
        setTimeout(function() {
            window.history.replaceState({}, document.title, "addCustomer.jsp");
        }, 100);
        
    } else if (status === 'error') {
        const toast = Toastify({
            text: "❌ Error: " + (message || "Failed to add customer"),
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
                borderLeft: "5px solid #f44336",
                marginTop: "20px"
            },
            stopOnFocus: true
        }).showToast();
        
        // Add progress bar animation for error
        const toastElement = toast.toastElement;
        const progressBar = document.createElement('div');
        progressBar.style.cssText = `
            position: absolute;
            bottom: 0;
            left: 0;
            height: 4px;
            width: 100%;
            background-color: #f44336;
            animation: shrink 5s linear forwards;
        `;
        
        toastElement.style.position = 'relative';
        toastElement.style.overflow = 'hidden';
        toastElement.appendChild(progressBar);
        
        // Clear URL parameters after showing toast
        setTimeout(function() {
            window.history.replaceState({}, document.title, "addCustomer.jsp");
        }, 100);
    }
});
</script>
</body>
</html>