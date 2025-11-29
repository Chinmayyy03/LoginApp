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
        <select name="gender" id="gender">
          <option value="">-- Select Gender --</option>
          <option>Male</option>
          <option>Female</option>
          <option>Other</option>
        </select>
      </div>

<div>
    <label>Salutation Code 2</label>
    <select name="salutationCode" id="salutationCode" required>
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
        <input type="date" name="birthDate" id="birthDate">
      </div>
<!-- Row 3 -->
      <div>
        <label>Registration Date</label>
        <input type="date" name="registrationDate" >
      </div>
      
      <div>
        <label>Is Minor</label>
        <div style="flex-direction: row;" class="radio-group">
          <label><input type="radio" name="isMinor" id="isMinor1" value="yes" onclick="toggleMinorFields()"> Yes</label>
          <label><input type="radio" name="isMinor" id="isMinor2" value="no" onclick="toggleMinorFields()"> No</label>
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
  <select name="constitutionCode" id="constitutionCode" required>
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
        <input type="text" name="gstinNo" id="gstinNo">
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
        <label><input type="radio" name="maritalStatus" id="maritalStatus" value="Married" onclick="toggleMarriedFields()"> Married</label>
        <label><input type="radio" name="maritalStatus" id="maritalStatus1" value="Single" onclick="toggleMarriedFields()"> Single</label>
        <label><input type="radio" name="maritalStatus" id="maritalStatus2" value="Other" onclick="toggleMarriedFields()"> Other</label>
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
    <select name="country" required>
        <option value="">-- Select Country --</option>
        <%
            PreparedStatement psCountry = null;
            ResultSet rsCountry = null;

            try (Connection conn = DBConnection.getConnection()) {
                String sql = "SELECT COUNTRY_CODE, NAME FROM GLOBALCONFIG.COUNTRY ORDER BY NAME";
                psCountry = conn.prepareStatement(sql);
                rsCountry = psCountry.executeQuery();

                while (rsCountry.next()) {
                    String code = rsCountry.getString("COUNTRY_CODE");
                    String name = rsCountry.getString("NAME");
        %>
                    <option value="<%= code %>"><%= name %></option>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (rsCountry != null) try { rsCountry.close(); } catch (Exception e) {}
                if (psCountry != null) try { psCountry.close(); } catch (Exception e) {}
            }
        %>
    </select>
</div>


    <div>
    <label>State</label>
    <select name="state" required>
        <option value="">-- Select State --</option>
        <%
            PreparedStatement psState = null;
            ResultSet rsState = null;

            try (Connection conn = DBConnection.getConnection()) {
                String sql = "SELECT STATE_CODE, NAME FROM GLOBALCONFIG.STATE ORDER BY NAME";
                psState = conn.prepareStatement(sql);
                rsState = psState.executeQuery();

                while (rsState.next()) {
                    String stateCode = rsState.getString("STATE_CODE");
                    String stateName = rsState.getString("NAME");
        %>
                    <option value="<%= stateCode %>"><%= stateName %></option>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (rsState != null) try { rsState.close(); } catch (Exception e) {}
                if (psState != null) try { psState.close(); } catch (Exception e) {}
            }
        %>
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
          <td><input type="date" id="date" name="passport_expiry"></td>
          <td><input type="text" name="passportNumber" id="passportNumber">
          </td>
        </tr>
        <tr>
          <td><input type="checkbox" name="pan_check"></td>
          <td>PAN Card</td>
          <td><input type="date" name="pan_expiry" disabled></td>
          <td><input type="text" name="pan" id="pan"
            style="text-transform:uppercase;">
          </td>
        </tr>
        <tr>
          <td><input type="checkbox" name="voterid_check"></td>
          <td>Election Card</td>
          <td><input type="date" name="voterid_expiry" disabled></td>
          <td><input type="text" name="voterid" id="voterid"
            style="text-transform:uppercase;">
          </td>
        </tr>
        <tr>
          <td><input type="checkbox" name="dl_check"></td>
          <td>Driving License</td>
          <td><input type="date" id="date" name="dl_expiry"></td>
          <td><input type="text" name="dl" id="dl"
            style="text-transform:uppercase;">
          </td>
        </tr>
        <tr>
          <td><input type="checkbox" name="aadhar_check"></td>
          <td>Aadhar Card</td>
          <td><input type="date" name="aadhar_expiry" disabled></td>
          <td><input type="text" name="aadhar">
          </td>
        </tr>
        <tr>
          <td><input type="checkbox" name="nrega_check"></td>
          <td>NREGA Job Card</td>
          <td><input type="date" name="nrega_expiry" disabled></td>
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
          <td><input type="date" id="date" name="telephone_expiry"></td>
          <td><input type="text" name="telephone"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="bank_check"></td>
          <td>Bank Statement</td>
          <td><input type="date" id="date" name="bank_expiry"></td>
          <td><input type="text" name="bank_statement"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="govt_check"></td>
          <td>Govt. Documents</td>
          <td><input type="date" id="date" name="govt_expiry"></td>
          <td><input type="text" name="govt_doc"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="electricity_check"></td>
          <td>Electricity Bill</td>
          <td><input type="date" id="date" name="electricity_expiry"></td>
          <td><input type="text" name="electricity"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="ration_check"></td>
          <td>Ration Card</td>
          <td><input type="date" name="ration_expiry" disabled></td>
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
          <td><input type="date" id="date" name="rent_expiry"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="cert_check"></td>
          <td>Certificate / License</td>
          <td><input type="date" id="date" name="cert_expiry"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="tax_check"></td>
          <td>Sales and Income Tax Returns</td>
          <td><input type="date" id="date" name="tax_expiry"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="cst_check"></td>
          <td>CST / VAT Certificate</td>
          <td><input type="date" id="date" name="cst_expiry"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="reg_check"></td>
          <td>License issued by Registering Authority</td>
          <td><input type="date" id="date" name="reg_expiry"></td>
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
          <td><input type="date" id="date" name="inc_expiry"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="board_check"></td>
          <td>Resolution of the Board of Directors</td>
          <td><input type="date" id="date" name="board_expiry"></td>
        </tr>
        <tr>
          <td><input type="checkbox" name="poa_check"></td>
          <td>Power of Attorney granted to its Managers</td>
          <td><input type="date" id="date" name="poa_expiry"></td>
        </tr>
      </table>
    </div>
  </div>
</fieldset>


<!-- Photo & Signature Upload Section -->
<fieldset>
  <legend>Photo & Signature Upload</legend>
  
  <div class="upload-container">
    <!-- Upload Photo Card -->
    <div class="upload-card">
      <h3>Upload Photo</h3>
      <div class="upload-icon-container">
        <img src="images/photo-icon.png" alt="Photo" class="upload-icon" id="photoPreviewIcon">
      </div>
      <p class="upload-text">Upload a photo</p>
      <p class="upload-subtext">Drag and drop files here</p>
      
      <input type="file" id="photoInput" name="photo" accept="image/*" style="display: none;">
      <input type="hidden" id="photoData" name="photoData">
      
      <div class="upload-buttons">
        <button type="button" class="upload-btn" onclick="openPhotoCamera()">
          <img src="images/camera-icon.png" alt="Camera" width="20"> Camera
        </button>
        <button type="button" class="upload-btn" onclick="document.getElementById('photoInput').click()">
          <img src="images/browse-icon.png" alt="Browse" width="20"> Browse
        </button>
      </div>
    </div>

    <!-- Upload Signature Card -->
    <div class="upload-card">
      <h3>Upload Signature</h3>
      <div class="upload-icon-container">
        <img src="images/signature-icon.png" alt="Signature" class="upload-icon" id="signaturePreviewIcon">
      </div>
      <p class="upload-text">Upload a signature</p>
      <p class="upload-subtext">Drag and drop files here</p>
      
      <input type="file" id="signatureInput" name="signature" accept="image/*" style="display: none;">
      <input type="hidden" id="signatureData" name="signatureData">
      
      <div class="upload-buttons">
        <button type="button" class="upload-btn" onclick="openSignatureCamera()">
          <img src="images/camera-icon.png" alt="Camera" width="20"> Camera
        </button>
        <button type="button" class="upload-btn" onclick="document.getElementById('signatureInput').click()">
          <img src="images/browse-icon.png" alt="Browse" width="20"> Browse
        </button>
      </div>
    </div>
  </div>
</fieldset>

<!-- Submit & Reset Buttons -->
  <div class="form-buttons">
    <button type="submit">Submit</button>
    <button type="reset">Reset</button>
  </div>
  
</form>

<!-- Camera Modal for Photo -->
<div id="photoCameraModal" class="camera-modal">
  <div class="camera-modal-content">
    <span class="camera-close" onclick="closePhotoCamera()">&times;</span>
    <h3>Take Photo</h3>
    <video id="photoVideo" autoplay></video>
    <canvas id="photoCanvas" style="display: none;"></canvas>
    <div class="camera-controls">
      <button type="button" class="camera-btn" onclick="capturePhoto()">Capture</button>
      <button type="button" class="camera-btn camera-btn-cancel" onclick="closePhotoCamera()">Cancel</button>
    </div>
  </div>
</div>

<!-- Camera Modal for Signature -->
<div id="signatureCameraModal" class="camera-modal">
  <div class="camera-modal-content">
    <span class="camera-close" onclick="closeSignatureCamera()">&times;</span>
    <h3>Take Signature Photo</h3>
    <video id="signatureVideo" autoplay></video>
    <canvas id="signatureCanvas" style="display: none;"></canvas>
    <div class="camera-controls">
      <button type="button" class="camera-btn" onclick="captureSignature()">Capture</button>
      <button type="button" class="camera-btn camera-btn-cancel" onclick="closeSignatureCamera()">Cancel</button>
    </div>
  </div>
</div>

<script src="js/addCustomer.js"></script>
<script type="text/javascript">
document.addEventListener('DOMContentLoaded', function () {
    function toggleFieldsByIndividual(isIndividual) {
        // Individual-specific fields
        let individualFields = [
            'firstName',
            'middleName',
            'surname',
            'customerName',
            'birthDate',
            'gender',
            'salutationCode',
            'motherName',
            'fatherName',
            'maritalStatus',
            'isMinor1',
            'isMinor2',
            'maritalStatus1',
            'maritalStatus2',
            'children',
            'dependents'
        ];
        // Non-individual fields
        let nonIndividualFields = [
            'guardianName',
            'relationGuardian',
            'gstinNo',
            'constitutionCode'
        ];
        // Individual selected
        if (isIndividual) {
            individualFields.forEach(id => {
                let el = document.getElementById(id);
                if (el) el.disabled = false;
            });
            nonIndividualFields.forEach(id => {
                let el = document.getElementById(id);
                if (el) el.disabled = true;
            });
        // Non-Individual selected
        } else {
            individualFields.forEach(id => {
                let el = document.getElementById(id);
                if (el) el.disabled = true;
            });
            nonIndividualFields.forEach(id => {
                let el = document.getElementById(id);
                if (el) el.disabled = false;
            });
        }
    }
    // Attach event listeners to radio buttons
    let individualRadios = document.querySelectorAll('input[name="isIndividual"]');
    individualRadios.forEach(function(radio) {
        radio.addEventListener('change', function() {
            toggleFieldsByIndividual(this.value === 'yes');
        });
    });
    // Initialize on load based on selected value
    let checked = Array.from(individualRadios).find(r => r.checked);
    toggleFieldsByIndividual(checked ? checked.value === 'yes' : true);
});
</script>

</body>
</html>



