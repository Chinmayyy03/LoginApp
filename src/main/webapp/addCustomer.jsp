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
  <style>
    body {
      background-color: #e8e4fc; /* soft violet */
      font-family: Arial, sans-serif;
      margin: 20px;
      padding: 0;
    }

    fieldset {
      background: #e8e4fc; /* same as body */
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

    /* Grid Layout */
    .form-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
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
    select {
      padding: 4px 6px;
      font-size: 13px;
      width: 95%;
      box-sizing: border-box;
    }

    .radio-group {
      display: flex;
      align-items: center;
      gap: 5px;
      font-size: 13px;
    }

    input[type="radio"] {
      transform: scale(0.9);
    }

    .full-width {
      grid-column: span 4;
    }

    /* Responsive Adjustments */
    @media (max-width: 1024px) {
      .form-grid {
        grid-template-columns: repeat(2, 1fr);
      }
      .full-width {
        grid-column: span 2;
      }
    }

    @media (max-width: 600px) {
      body {
        margin: 10px;
      }

      fieldset {
        padding: 10px 15px;
      }

      .form-grid {
        grid-template-columns: 1fr;
      }

      .full-width {
        grid-column: span 1;
      }

      label {
        font-size: 12px;
      }

      input[type="text"],
      input[type="date"],
      input[type="email"],
      select {
        width: 100%;
        font-size: 12px;
      }

      legend {
        font-size: 1em;
      }
    }

    /* Additional styling for non-grid sections */
    .form-row {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      margin-bottom: 10px;
      gap: 10px;
    }

    .form-label {
      min-width: 140px;
      font-weight: bold;
      color: #373279;
      font-size: 13px;
    }

    .form-input {
      flex: 1;
      padding: 4px 6px;
      font-size: 13px;
    }

    @media (max-width: 600px) {
      .form-row {
        flex-direction: column;
        align-items: flex-start;
      }
      .form-label {
        min-width: auto;
      }
      .form-input {
        width: 100%;
      }
    }
    
   /* PERSONAL INFO SPECIFIC */
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

.personal-grid label {
  min-width: 10px;
      font-size: 13px;
      margin-bottom: 3px;
      font-weight: bold;
      color: #373279;
}

.personal-grid input[type="text"],
.personal-grid input[type="number"] {
  width: 90%;
  font-size: 13px;
  padding: 4px 6px;
  box-sizing: border-box;
}

.personal-grid .radio-group {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 8px;
}

.personal-grid .full-width {
  grid-column: span 3;
  width: 95%;
}

/* Responsive layout */
@media (max-width: 900px) {
  .personal-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .personal-grid .full-width {
    grid-column: span 2;
  }
}

@media (max-width: 600px) {
  .personal-grid {
    grid-template-columns: 1fr;
  }
  .personal-grid .full-width {
    grid-column: span 1;
  }
}


/* ADDRESS INFO GRID */
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

.address-grid label {
  font-weight: bold;
  color: #373279;
  font-size: 13px;
  margin-bottom: 4px;
}

.address-grid input[type="text"],
.address-grid input[type="number"],
.address-grid select {
  width: 90%;
  font-size: 13px;
  padding: 4px 6px;
  box-sizing: border-box;
}

.address-grid .full-width {
  grid-column: span 3;
  width: 95%;
}

@media (max-width: 900px) {
  .address-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .address-grid .full-width {
    grid-column: span 2;
  }
}

@media (max-width: 600px) {
  .address-grid {
    grid-template-columns: 1fr;
  }
  .address-grid .full-width {
    grid-column: span 1;
  }
}

/*for kyc fieldset */


.kyc-row {
  display: flex;
  justify-content: space-between;
  position: relative;
  flex-wrap: wrap;
  margin-bottom: 20px;
}

.kyc-section {
  flex: 1 1 48%;
  min-width: 300px;
}

.kyc-section h4 {
  color:#373279;
  text-align: center;
  font-weight: bold;
  text-decoration: underline;
}

.kyc-section table {
  width: 100%;
  border-collapse: collapse;
}

.kyc-section th {
  color: #373279;
  font-weight: bold;
  text-align: left;
  padding-bottom: 4px;
}

.kyc-section td {
  color: #373279;
  font-size: 13px;
  font-weight: bold;
  padding: 4px 6px;
}

.kyc-section input[type="text"],
.kyc-section input[type="date"] {
  width: 90%;
  padding: 3px 5px;
  border: 1px solid #888;
  font-size: 0.9rem;
}

/* Vertical Divider */
.kyc-divider {
  width: 2px;
  background-color: #666;
  margin: 0 15px;
}

/* Divider Between Rows */
hr {
  border: 0;
  border-top: 1px solid #888;
  margin: 15px 0;
}

/* 🔹 Responsive Adjustments */
@media (max-width: 900px) {
  .kyc-row {
    flex-direction: column;
  }

  .kyc-section {
    width: 100%;
    margin-bottom: 20px;
  }

  .kyc-divider {
    display: none;
  }

  .kyc-section input[type="text"],
  .kyc-section input[type="date"] {
    width: 100%;
  }

  .kyc-section table {
    font-size: 0.9rem;
  }
}

 /* Button Styling */
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

.form-buttons button:active {
  transform: scale(0.97);
}

/* Responsive buttons for small screens */
@media (max-width: 600px) {
  .form-buttons {
    flex-direction: column;
    gap: 10px;
  }

  .form-buttons button {
    width: 80%;
    padding: 10px;
  }
}
  </style>
</head>
<body>

<form>
  <!-- Main customer details -->
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
        <label>Registration Date</label>
        <input type="date" name="registrationDate" >
      </div>

      <div>
        <label>Birth Date</label>
        <input type="date" name="birthDate">
      </div>
<!-- Row 3 -->
      <div>
        <label>Is Minor</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="isMinor" value="yes" onclick="toggleMinorFields()"> Yes</label>
          <label><input type="radio" name="isMinor" value="no" onclick="toggleMinorFields()"> No</label>
        </div>
      </div>

      <div>
        <label>Customer Name</label>
        <input type="text" name="customerName" id="customerName" oninput="this.value = this.value.replace(/[^A-Za-z]/g, ' ')">
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
        <label>Passport Number</label>
        <input type="text" name="passportNumber" id="passportNumber" maxlength="8"oninput="this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, ''); 
            if(!/^[A-PR-WY][1-9]\d{0,6}$/.test(this.value) && this.value.length > 0){
              this.setCustomValidity('Invalid passport format (e.g. A1234567)');
            } else {
              this.setCustomValidity('');
            }">
        
      </div>

      <div>
        <label>Caste Code</label>
        <input type="text" name="casteCode">
      </div>

      <div>
        <label>Pan Number</label>
        <input type="text" name="panNumber" maxlength="10" required>
      </div>
<!-- Row 5 -->
      <div>
        <label>Aadhar Card No</label>
        <input type="text" name="aadharNo" maxlength="12" id="aadharNo" oninput="this.value = this.value.replace(/[^0-9]/g, '')">
      </div>

      <div>
        <label>Form60</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="form60" value="yes"> Yes</label>
          <label><input type="radio" name="form60" value="no"> No</label>
        </div>
      </div>

      <div>
        <label>Form61</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="form61" value="yes"> Yes</label>
          <label><input type="radio" name="form61" value="no"> No</label>
        </div>
      </div>

      <div>
        <label>Category Code</label>
        <input type="text" name="categoryCode" value="PUBLIC">
      </div>
<!-- Row 6 -->
      <div>
        <label>Sub Category Code</label>
        <input type="text" name="subCategoryCode" value="1">
      </div>

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
<!-- Row 7 -->
      <div>
        <label>Customer Group Code</label>
        <select name="customerGroupCode">
          <option>NON GROUP</option>
          <option>GROUP A</option>
          <option>GROUP B</option>
        </select>
      </div>

      <div>
        <label>Member Type</label>
        <input type="text" name="memberType" value="B">
      </div>

      <div>
        <label>Email ID</label>
        <input type="email" name="email">
      </div>

      <div>
        <label>GSTIN No</label>
        <input type="text" name="gstinNo">
      </div>
<!-- Row 8 -->
      <div>
        <label>Member Number</label>
        <input type="text" name="memberNumber" value="0">
      </div>

      <div>
        <label>CKYC No</label>
        <input type="text" name="ckyNo">
      </div>

      <div>
        <label>Risk Category</label>
        <select name="riskCategory">
          <option>LOW</option>
          <option>MEDIUM</option>
          <option>HIGH</option>
        </select>
      </div>

      <div class="full-width">
        <label>Message</label>
        <input type="text" name="message">
      </div>
    </div>
  </fieldset>
<!-- Personal Info -->
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
        <label><input type="radio" name="maritalStatus" value="Married"> Married</label>
        <label><input type="radio" name="maritalStatus" value="Single"> Single</label>
        <label><input type="radio" name="maritalStatus" value="Other"> Other</label>
      </div>
    </div>

    <!-- Row 2 -->
    <div>
      <label for="children">No. of Children</label>
      <input type="number" id="children" name="children" value="0" min="0">
    </div>

    <div>
      <label for="dependents">No. of Dependents</label>
      <input type="number" id="dependents" name="dependents" value="0" min="0">
    </div>

    <div class="full-width">
      <label for="message">Message</label>
      <input type="text" id="message" name="message">
    </div>
  </div>
</fieldset>


  <!-- Permanent/Address Info -->
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
      <input type="number" name="zip" value="0">
    </div>

    <div>
      <label>Mobile No</label>
      <div style="display: flex; gap: 5px;">
        <input type="text" value="+91" style="width: 45px; text-align: center;" readonly>
        <input type="number" name="mobileNo" value="0">
      </div>
    </div>

    <div>
      <label>Residence Phone</label>
      <input type="number" name="residencePhone" value="0">
    </div>

    <!-- Row 5 -->
    <div>
      <label>Office Phone</label>
      <input type="number" name="officePhone" value="0">
    </div>

    <div class="full-width">
      <label>Message</label>
      <input type="text" name="message">
    </div>
  </div>
</fieldset>


  <!-- KYC and Document Checklist -->
<fieldset class="kyc-fieldset">
  <legend>KYC Document Details</legend>

  <!-- Row 1: ID Proof / Address Proof -->
  <div class="kyc-row">
    <!-- Left Column -->
    <div class="kyc-section">
      <h4>Savings Account (ID Proof)</h4>
      <table>
        <tr><th>Document</th><th>Expiry Date</th><th>Document Number</th></tr>
        <tr><td>Passport</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr><td>PAN Card</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr><td>Election Card</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr><td>Driving License</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr><td>–</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr><td>Aadhar Card</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr><td>NREGA Job Card</td><td><input type="date"></td><td><input type="text"></td></tr>
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
        <tr><td>Ration Card</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr><td>Passport</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr><td>–</td><td><input type="date"></td><td><input type="text"></td></tr>
        <tr><td>Aadhar Card</td><td><input type="date"></td><td><input type="text"></td></tr>
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
	
</script>
</body>
</html>
