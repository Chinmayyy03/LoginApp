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
    select {
      padding: 4px 6px;
      font-size: 13px;
      width: 90%;
      box-sizing: border-box;
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

  </style>
</head>
<body>

<form>
  <!-- Main customer details -->
  <fieldset>
    <legend>Application</legend>
    <div class="form-grid">
<!-- Row 1 -->
 	<div>
	 <label>Customer ID</label>
        <input type="text">
      </div>
	<div>
        <label>Customer Name</label>
        <input type="text" name="customerName" id="customerName" oninput="this.value = this.value.replace(/[^A-Za-z]/g, ' ')">
      </div>
     
        <div>
        <label>Category Code</label>
        <input type="text" name="categoryCode" value="PUBLIC">
      </div>
	<div>
        <label>Introducer A/c Code</label>
        <input type="text" name="IntroducerA/cCode" >
      </div>
	<div>
        <label>Introducer A/c Name</label>
        <input type="text" name="IntroducerA/cName">
      </div>
      <div>
        <label>Date Of Application</label>
        <input type="date" name="DateOfApplication">
      </div>

	<div>
      <label>Account Operation Capacity</label>
      <select name="AccountOperationCapacity">
        <option>NOT APPLICABLE</option>
        <option>SELF</option>
        <option>ONLY FIRST</option>
        <option>ANYONE</option>
      </select>
    </div>

	<div>
      <label>MinBalance ID</label>
      <select name="MinBalanceID">
        <option>0</option>
        <option>100</option>
        <option>500</option>
        <option>5000</option>
      </select>
    </div>
      
      <div>
        <label>Risk Category</label>
        <select name="riskCategory">
          <option>LOW</option>
          <option>MEDIUM</option>
          <option>HIGH</option>
        </select>
      </div>

  </fieldset>
  <!-- ================= NOMINEE SECTION ================= -->
<fieldset id="nomineeFieldset">
  <legend>
    Nominee
    <button type="button" onclick="addNominee()" 
      style="border:none;background:#373279;color:white;padding:2px 10px;
      border-radius:5px;cursor:pointer;font-size:12px;margin-left:10px;">
      ➕
    </button>
  </legend>

  <!-- FIRST NOMINEE BLOCK -->
  <div class="nominee-card nominee-block">

    <!-- REMOVE BUTTON -->
    <button type="button" class="nominee-remove" onclick="removeNominee(this)">✖</button>

    <!-- SERIAL NUMBER (NEW) -->
    <div class="nominee-title" 
         style="font-weight:bold; font-size:15px; margin-bottom:10px; color:#373279;">
        Nominee <span class="nominee-serial">1</span>
    </div>

    <div class="personal-grid">
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




  <!-- Permanent/Address Info -->
 <fieldset id="jointFieldset">
  <legend>
    Joint Holder
    <button type="button" onclick="addJointHolder()"
      style="border:none;background:#373279;color:white;padding:2px 10px;
      border-radius:5px;cursor:pointer;font-size:12px;margin-left:10px;">
      ➕
    </button>
  </legend>

  <!-- FIRST JOINT HOLDER BLOCK -->
  <div class="nominee-card joint-block">

    <!-- REMOVE BUTTON -->
    <button type="button" class="nominee-remove" onclick="removeJointHolder(this)">✖</button>

    <!-- SERIAL NUMBER (NEW) -->
    <div class="nominee-title"
         style="font-weight:bold; font-size:15px; margin-bottom:10px; color:#373279;">
        Joint Holder <span class="joint-serial">1</span>
    </div>

    <div class="address-grid">
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
            // SAME CITY QUERY USED HERE
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


<!-------------------------------- submit and reset button---------------------->

<div class="form-buttons">
    <button type="submit">Save</button>
    <button type="reset" onclick="resetPreview()">Reset</button>
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







function showOptions(id) {
    document.getElementById(id).style.display = "block";
}

// Open Camera
function openCamera(inputId) {
    const input = document.getElementById(inputId);
    input.setAttribute("capture", "environment");
    input.click();
}

// Open Browse
function openBrowse(inputId) {
    const input = document.getElementById(inputId);
    input.removeAttribute("capture");
    input.click();
}

// Preview Image
function previewFile(event, previewId, iconId, textId, removeId, optionsId) {
    const file = event.target.files[0];
    if (!file) return;

    document.getElementById(previewId).src = URL.createObjectURL(file);
    document.getElementById(previewId).style.display = "block";

    document.getElementById(iconId).style.display = "none";
    document.getElementById(textId).style.display = "none";
    document.getElementById(removeId).style.display = "block";
    document.getElementById(optionsId).style.display = "none";
}

// Remove uploaded image
function removeUpload(inputId, previewId, iconId, textId, removeId) {
    document.getElementById(inputId).value = "";
    document.getElementById(previewId).style.display = "none";
    document.getElementById(iconId).style.display = "block";
    document.getElementById(textId).style.display = "block";
    document.getElementById(removeId).style.display = "none";
}

// Modal Preview
function openFullImage(src) {
    document.getElementById('modalImg').src = src;
    document.getElementById('imageModal').style.display = "flex";
}
function closeModal() {
    document.getElementById('imageModal').style.display = "none";
}

</script>
<script>
function addNominee() {
    let fieldset = document.getElementById("nomineeFieldset");
    let original = fieldset.querySelector(".nominee-block");

    let clone = original.cloneNode(true);

    clone.querySelectorAll("input, select").forEach(el => el.value = "");

    clone.querySelector(".nominee-remove").onclick = function() {
        removeNominee(this);
    };

    fieldset.appendChild(clone);
    updateNomineeSerials();
}

function removeNominee(btn) {
    let blocks = document.querySelectorAll(".nominee-block");

    if (blocks.length <= 1) {
        alert("At least one nominee is required.");
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


function addJointHolder() {
    let fieldset = document.getElementById("jointFieldset");
    let original = fieldset.querySelector(".joint-block");
    
    let clone = original.cloneNode(true);

    clone.querySelectorAll("input, select").forEach(el => el.value = "");

    clone.querySelector(".nominee-remove").onclick = function() {
        removeJointHolder(this);
    };

    fieldset.appendChild(clone);
    updateJointSerials();
}

function removeJointHolder(btn) {
    let blocks = document.querySelectorAll(".joint-block");

    if (blocks.length <= 1) {
        alert("At least one joint holder is required.");
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

</script>

<!-- Modal -->
<div id="imageModal" onclick="closeModal()">
    <img id="modalImg">
</div>
</body>
</html>
