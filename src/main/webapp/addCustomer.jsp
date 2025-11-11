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
 
</head>
<body>

<form>
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
          <option value="">Select Gender</option>
          <option>Male</option>
          <option>Female</option>
          <option>Other</option>
        </select>
      </div>

      <div>
        <label>Salutation Code</label>
       <select name="salutationCode" id="salutationCode" required>
  			<option value=""> Select Salutation</option>
  			<option value="MR">Mr.</option>
 	 		<option value="MS">Ms.</option>
  			<option value="MRS">Mrs.</option>
  			<option value="DR">Dr.</option>
  			<option value="PROF">Prof.</option>
		</select>
      </div>

      <div>
        <label>First Name</label>
        <input type="text" name="firstName" id="firstName" oninput="this.value = this.value.replace(/[^A-Za-z]/g, '')">
      </div>
<!-- Row 2 -->
      <div>
        <label>Surname Name</label>
        <input type="text" name="surname" id="surname" oninput="this.value = this.value.replace(/[^A-Za-z]/g, '')">
      </div>

      <div>
        <label>Middle Name</label>
        <input type="text" name="middleName" id="middleName" oninput="this.value = this.value.replace(/[^A-Za-z]/g, '')">
      </div>
      
      <div>
        <label>Customer Name</label>
        <input type="text" name="customerName" id="customerName" oninput="this.value = this.value.replace(/[^A-Za-z]/g, ' ')">
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
        <select name="relationGuardian" id="relationGuardian" required>
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
        <select name="Caste Code" required>
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
  <select name="categoryCode" required>
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
        <input type="text" name="memberNumber" value="">
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
      <input type="number" id="children" name="children" value="" min="0">
    </div>

    <div>
      <label for="dependents">No. of Dependents</label>
      <input type="number" id="dependents" name="dependents" value="" min="0">
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
        <option>Karnataka</option>
        <option>Maharashtra</option>
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
      <input type="number" name="zip" value="">
    </div>

    <div>
      <label>Mobile No</label>
      <div style="display: flex; gap: 5px;">

        <input type="number" name="mobileNo">
      </div>
    </div>

    <div>
      <label>Residence Phone</label>
      <input type="number" name="residencePhone" value="">
    </div>

    <!-- Row 5 -->
    <div>
      <label>Office Phone</label>
      <input type="number" name="officePhone" value="">
    </div>
  </div>
</fieldset>


  <!------------------------------------------------------------------ KYC and Document Checklist ----------------------------------------------------------------->
  <!-- KYC and Document Checklist -->
<fieldset class="kyc-fieldset">
  <legend>KYC Document Details</legend>

  <!-- Row 1: ID Proof / Address Proof -->
  <div class="kyc-row">
    <!-- Left Column -->
    <div class="kyc-section">
      <h4>Savings Account (ID Proof)</h4>
      <table>
        <tr>
          <th>Select</th><th>Document</th><th>Expiry Date</th><th>Document Number</th>
        </tr>
        <tr>
          <td><input type="checkbox" name="passport_check"></td>
          <td>Passport</td>
          <td><input type="date"></td>
          <td><input type="text" name="passportNumber" id="passportNumber" maxlength="8"
            oninput="this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, ''); 
              if(!/^[A-PR-WY][1-9]\d{0,6}$/.test(this.value) && this.value.length > 0){
                this.setCustomValidity('Invalid passport format (e.g. A1234567)');
              } else {
                this.setCustomValidity('');
              }">
          </td>
        </tr>
        <tr>
          <td><input type="checkbox" name="pan_check"></td>
          <td>PAN Card</td>
          <td><input type="date"></td>
          <td><input type="text" name="pan" id="pan" maxlength="10"
            pattern="[A-Z]{5}[0-9]{4}[A-Z]{1}" title="Enter valid PAN (e.g., ABCDE1234F)"
            style="text-transform:uppercase;" required>
          </td>
        </tr>
        <tr>
          <td><input type="checkbox" name="voterid_check"></td>
          <td>Election Card</td>
          <td><input type="date"></td>
          <td><input type="text" name="voterid" id="voterid" maxlength="10"
            pattern="[A-Z]{3}[0-9]{7}" title="Enter valid Voter ID (e.g., ABC1234567)"
            style="text-transform:uppercase;" required>
          </td>
        </tr>
        <tr>
          <td><input type="checkbox" name="dl_check"></td>
          <td>Driving License</td>
          <td><input type="date"></td>
          <td><input type="text" name="dl" id="dl" maxlength="16"
            pattern="^[A-Z]{2}[0-9]{2}\s?[0-9]{11}$" title="Enter valid Driving Licence No (e.g., MH14 20220012345)"
            style="text-transform:uppercase;" required>
          </td>
        </tr>
        <tr>
          <td><input type="checkbox" name="aadhar_check"></td>
          <td>Aadhar Card</td>
          <td><input type="date"></td>
          <td><input type="text" pattern="^[2-9][0-9]{11}$" maxlength="12"
            inputmode="numeric" title="Enter a valid 12-digit number starting with 2-9"
            required oninput="this.value=this.value.replace(/\D/g,'').slice(0,12);
              while(this.value && !/^[2-9]/.test(this.value)) this.value=this.value.slice(1)">
          </td>
        </tr>
        <tr>
          <td><input type="checkbox" name="nrega_check"></td>
          <td>NREGA Job Card</td>
          <td><input type="date"></td>
          <td><input type="text" name="nrega" id="nrega" maxlength="20"
            pattern="^[A-Z]{2}-\d{2}-\d{3}-\d{3}-\d{7}$"
            title="Enter valid NREGA Job Card No (e.g., MH-12-123-001-0001234)"
            style="text-transform:uppercase;" required>
          </td>
        </tr>
      </table>
    </div>

    <!-- Vertical Divider -->
    <div class="kyc-divider"></div>

    <!-- Right Column -->
    <div class="kyc-section">
      <h4>Savings Account (Address Proof)</h4>
      <table>
        <tr>
          <th>Select</th><th>Document</th><th>Expiry Date</th><th>Document Number</th>
        </tr>
        <tr><td><input type="checkbox"></td><td>Telephone Bill</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr><td><input type="checkbox"></td><td>Bank Statement</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr><td><input type="checkbox"></td><td>Govt. Documents</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr><td><input type="checkbox"></td><td>Electricity Bill</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr>
          <td><input type="checkbox"></td>
          <td>Ration Card</td>
          <td><input type="date"></td>
          <td><input type="text" name="ration" id="ration" maxlength="15"
            pattern="^[A-Z]{2}-\d{2}-\d{6,7}$"
            title="Enter valid Ration Card No (e.g., TN-10-1234567)"
            style="text-transform:uppercase;" required>
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
        <tr><td><input type="checkbox"></td><td>Registered Rent Agreement Copy</td><td><input type="date"></td></tr>
        <tr><td><input type="checkbox"></td><td>Certificate / License</td><td><input type="date"></td></tr>
        <tr><td><input type="checkbox"></td><td>Sales and Income Tax Returns</td><td><input type="date"></td></tr>
        <tr><td><input type="checkbox"></td><td>CST / VAT Certificate</td><td><input type="date"></td></tr>
        <tr><td><input type="checkbox"></td><td>License issued by Registering Authority</td><td><input type="date"></td></tr>
      </table>
    </div>

    <div class="kyc-divider"></div>

    <div class="kyc-section">
      <h4>Business Concern</h4>
      <table>
        <tr><th>Select</th><th>Document</th><th>Expiry Date</th></tr>
        <tr><td><input type="checkbox"></td><td>Certificate of Incorporation</td><td><input type="date"></td></tr>
        <tr><td><input type="checkbox"></td><td>Resolution of the Board of Directors</td><td><input type="date"></td></tr>
        <tr><td><input type="checkbox"></td><td>Power of Attorney granted to its Managers</td><td><input type="date"></td></tr>
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


</script>
</body>
</html>
