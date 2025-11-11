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
        <select name="relationGuardian" id="relationGuardian" disabled>
          <option>NOT SPECIFIED</option>
          <option>FATHER</option>
          <option>MOTHER</option>
          <option>BROTHER</option>
        </select>
      </div>
<!-- Row 4 -->
      <div>
        <label>Religion Code</label>
        <input type="text" name="religionCode">
      </div>

    

      <div>
        <label>Caste Code</label>
        <input type="text" name="casteCode">
      </div>
      
      <div>
        <label>Category Code</label>
        <input type="text" name="categoryCode" value="PUBLIC">
      </div>
      
      <div>
        <label>Sub Category Code</label>
        <input type="text" name="subCategoryCode" value="1">
      </div>

      
<!-- Row 5 -->
      <div>
        <label>Constitution Code</label>
        <input type="text" name="constitutionCode">
      </div>

      <div>
        <label>Occupation Code</label>
        <select name="occupationCode">
          <option>NOT DEFINE</option>
          <option>EMPLOYED</option>
          <option>SELF EMPLOYED</option>
        </select>
      </div>

      <div>
        <label>Vehicle Owned</label>
        <select name="vehicleOwned">
          <option>NOT APPLICABLE</option>
          <option>CAR</option>
          <option>BIKE</option>
        </select>
      </div>

       <div>
        <label>Member Type</label>
        <input type="text" name="memberType" value="B">
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
      <select name="residenceType">
        <option>NOT APPLICABLE</option>
        <option>OWNED</option>
        <option>RENTED</option>
        <option>LEASED</option>
      </select>
    </div>

    <div>
      <label>Residence Status</label>
      <select name="residenceStatus">
        <option>NOT APPLICABLE</option>
        <option>PERMANENT</option>
        <option>TEMPORARY</option>
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
      <select name="city">
        <option>GADAG</option>
        <option>DHARWAD</option>
        <option>HUBLI</option>
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
        <input type="text" value="+91" style="width: 45px; text-align: center;" readonly>
        <input type="number" name="mobileNo" value="">
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
<fieldset class="kyc-fieldset">
  <legend>KYC Document Details</legend>

  <!-- Row 1: ID Proof / Address Proof -->
  <div class="kyc-row">
    <!-- Left Column -->
    <div class="kyc-section">
      <h4>Savings Account (ID Proof)</h4>
      <table>
        <tr><th>Document</th><th>Expiry Date</th><th>Document Number</th></tr>
        <tr><td>Passport</td><td><input type="date"></td><td><input type="text" name="passportNumber" id="passportNumber" maxlength="8"oninput="this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, ''); 
            if(!/^[A-PR-WY][1-9]\d{0,6}$/.test(this.value) && this.value.length > 0){
              this.setCustomValidity('Invalid passport format (e.g. A1234567)');
            } else {
              this.setCustomValidity('');
            }"></td></tr>
        <tr><td>PAN Card</td><td><input type="date"></td><td><input type="text" name="pan" id="pan" maxlength="10" pattern="[A-Z]{5}[0-9]{4}[A-Z]{1}" title="Enter valid PAN (e.g., ABCDE1234F)" style="text-transform:uppercase;" required></td></tr>
        <tr><td>Election Card</td><td><input type="date"></td><td><input type="text" name="voterid" id="voterid" maxlength="10" pattern="[A-Z]{3}[0-9]{7}" title="Enter valid Voter ID (e.g., ABC1234567)" style="text-transform:uppercase;" required></td></tr>
        <tr><td>Driving License</td><td><input type="date"></td><td><input type="text" name="dl" id="dl" maxlength="16" pattern="^[A-Z]{2}[0-9]{2}\s?[0-9]{11}$" title="Enter valid Driving Licence No (e.g., MH14 20220012345)" style="text-transform:uppercase;" required></td></tr>
        <tr><td>Aadhar Card</td><td><input type="date"></td><td><input type="text" pattern="^[2-9][0-9]{11}$" maxlength="12" inputmode="numeric" title="Enter a valid 12-digit number starting with 2-9" required oninput="this.value=this.value.replace(/\D/g,'').slice(0,12); while(this.value && !/^[2-9]/.test(this.value)) this.value=this.value.slice(1)">
</td></tr>
        <tr><td>NREGA Job Card</td><td><input type="date"></td><td><input type="text" name="nrega" id="nrega" maxlength="20" pattern="^[A-Z]{2}-\d{2}-\d{3}-\d{3}-\d{7}$" title="Enter valid NREGA Job Card No (e.g., MH-12-123-001-0001234)" style="text-transform:uppercase;" required></td></tr>
      </table>
    </div>

    <!-- Vertical Divider -->
    <div class="kyc-divider"></div>

    <!-- Right Column -->
    <div class="kyc-section">
      <h4>Savings Account (Address Proof)</h4>
      <table>
        <tr><th>Document</th><th>Expiry Date</th><th>Document Number</th></tr>
        <tr><td>Telephone Bill</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr><td>Bank Statement</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr><td>Govt. Documents</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr><td>Electricity Bill</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr><td>Ration Card</td><td><input type="date"></td><td><input type="text" name="ration" id="ration" maxlength="15" pattern="^[A-Z]{2}-\d{2}-\d{6,7}$" title="Enter valid Ration Card No (e.g., TN-10-1234567)" style="text-transform:uppercase;" required></td></tr>
        <tr><td>Passport</td><td><input type="date"></td><td><input type="text" name="passport" id="passport" maxlength="8" pattern="^[A-PR-WYa-pr-wy][1-9][0-9]{6}$" title="Enter valid Indian Passport No (e.g., A1234567)" style="text-transform:uppercase;" required></td></tr>
        <tr><td>Aadhar Card</td><td><input type="date"></td><td><input type="text" pattern="^[2-9][0-9]{11}$" maxlength="12" inputmode="numeric" title="Enter a valid 12-digit number starting with 2-9" required oninput="this.value=this.value.replace(/\D/g,'').slice(0,12); while(this.value && !/^[2-9]/.test(this.value)) this.value=this.value.slice(1)">
</td></tr>
      </table>
    </div>
  </div>

  <hr>

  <!-- Row 2: Proprietary / Business Concern -->
  <div class="kyc-row">
    <div class="kyc-section">
      <h4>Accounts of Proprietary Concern</h4>
      <table>
        <tr><th>Document</th><th>Expiry Date</th></tr>
        <tr><td>Registered Rent Agreement Copy</td><td><input type="date"></td></tr>
        <tr><td>Certificate / License</td><td><input type="date"></td></tr>
        <tr><td>Sales and Income Tax Returns</td><td><input type="date"></td></tr>
        <tr><td>CST / VAT Certificate</td><td><input type="date"></td></tr>
        <tr><td>License issued by Registering Authority</td><td><input type="date"></td></tr>
      </table>
    </div>

    <div class="kyc-divider"></div>

    <div class="kyc-section">
      <h4>Business Concern</h4>
      <table>
        <tr><th>Document</th><th>Expiry Date</th></tr>
        <tr><td>Certificate of Incorporation</td><td><input type="date"></td></tr>
        <tr><td>Resolution of the Board of Directors</td><td><input type="date"></td></tr>
        <tr><td>Power of Attorney granted to its Managers</td><td><input type="date"></td></tr>
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

	
</script>
</body>
</html>
