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
<!-- Personal Info -->
    <fieldset>
  <legend>Nominee</legend>
  <div class="personal-grid">

    <!-- Row 1 -->
    <div>
      <label>Nominee Name</label>
      <input type="text" id="Nominee Name" name="Nominee Name">
    </div>
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
      <input type="number" name="zip" value="0">
    </div>
     
      <div>
        <label>Relation with Guardian</label>
        <select name="relationGuardian" id="relationGuardian">
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

    
</fieldset>


  <!-- Permanent/Address Info -->
  <fieldset>
  <legend>Joint Holder</legend>
  <div class="address-grid">
      <!-- Row 1 -->
    <div>
      <label>Nominee Name</label>
      <input type="text" id="Nominee Name" name="Nominee Name">
    </div>
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
      PreparedStatement pssCity = null;
      ResultSet rssCity = null;
      try (Connection conn7 = DBConnection.getConnection()) {
          String sql = "SELECT NAME FROM GLOBALCONFIG.CITY ORDER BY UPPER(NAME) ";
          pssCity = conn7.prepareStatement(sql);
          rssCity = pssCity.executeQuery();
          while (rssCity.next()) {
              String city = rssCity.getString("NAME");
    %>
              <option value="<%= city %>"><%= city %></option>
    <%
          }
      } catch (Exception e) {
          out.println("<option disabled>Error loading Residence Type</option>");
          e.printStackTrace();
      } finally {
          if (rssCity != null) rssCity.close();
          if (pssCity != null) pssCity.close();
      }
    %>
  </select>
</div>
    <!-- Row 4 -->
    <div>
      <label>Zip</label>
      <input type="number" name="zip" value="0">
    </div>
</fieldset>

<!-------------------------------- submit and reset button---------------------->

<div class="form-buttons">
    <button type="submit">Submit</button>
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
<!-- Modal -->
<div id="imageModal" onclick="closeModal()">
    <img id="modalImg">
</div>
</body>
</html>
