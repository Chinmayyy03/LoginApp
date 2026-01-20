<%@ page import="java.sql.*, db.DBConnection, java.text.SimpleDateFormat" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String returnPage = request.getParameter("returnPage");
    if (returnPage == null || returnPage.trim().isEmpty()) {
        returnPage = "View/allCustomers.jsp";
    }
%>

<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    String branchCode = (String) sess.getAttribute("branchCode");
%>

<%! 
    String getStringSafe(ResultSet r, String col) throws SQLException {
        String v = r.getString(col);
        return (v == null) ? "" : v;
    }
    
    String formatDateForInput(ResultSet r, String col) throws SQLException {
        java.sql.Timestamp ts = null;
        try {
            ts = r.getTimestamp(col);
        } catch (Exception ex) {
            try {
                java.sql.Date d = r.getDate(col);
                if (d != null) ts = new java.sql.Timestamp(d.getTime());
            } catch (Exception ignore) {}
        }
        if (ts == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(new java.util.Date(ts.getTime()));
    }
%>

<%
    String customerId = request.getParameter("customerId");
    if (customerId == null || customerId.trim().isEmpty()) {
        out.println("<h3 style='color:red;'>Customer ID not provided.</h3>");
        return;
    }

    Connection conn = null;
    PreparedStatement psCustomer = null;
    ResultSet rsCustomer = null;

    try {
        conn = DBConnection.getConnection();
        
        // Fetch main customer data
        psCustomer = conn.prepareStatement("SELECT * FROM CUSTOMER.CUSTOMER WHERE CUSTOMER_ID = ?");
        psCustomer.setString(1, customerId);
        rsCustomer = psCustomer.executeQuery();

        if (!rsCustomer.next()) {
            out.println("<h3 style='color:red;'>No customer found with ID: " + customerId + "</h3>");
            return;
        }
        
        // Combine name parts
        String firstName = getStringSafe(rsCustomer, "NAMEFIRST");
        String middleName = getStringSafe(rsCustomer, "NAMEMIDDLE");
        String lastName = getStringSafe(rsCustomer, "NAMELAST");
        String fullName = (firstName + " " + middleName + " " + lastName).trim().replaceAll("\\s+", " ");
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>View Customer — <%= customerId %></title>
  <script src="<%= request.getContextPath() %>/js/breadcrumb-auto.js"></script>
  
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/addCustomer.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/authViewCustomers.css">
  
  <style>
    .action-buttons {
      display: flex;
      gap: 15px;
      justify-content: center;
      margin: 20px 0;
      flex-wrap: wrap;
    }
    
    .action-btn {
      background: #2b0d73;
      color: white;
      padding: 10px 20px;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      font-size: 14px;
      font-weight: bold;
      transition: background 0.3s;
      text-decoration: none;
      display: inline-block;
    }
    
    .action-btn:hover {
      background: #1a0548;
    }
    
    .back-btn {
      background: #373279;
    }
    
    .back-btn:hover {
      background: #2b0d73;
    }
  </style>
  
  <script>
window.onload = function() {
    var returnPage = '<%= returnPage %>';
    
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath('View/viewCustomer.jsp', returnPage)
        );
    }
};

function goBackToList() {
    var returnPage = '<%= returnPage %>';
    
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb(
            window.buildBreadcrumbPath(returnPage)
        );
    }
    
    window.location.href = '<%= request.getContextPath() %>/' + returnPage;
}

function viewAccounts() {
    // Navigate to accounts page filtered by this customer
    alert('View accounts for customer: <%= customerId %>');
    // You can implement actual navigation here
}

function modifyKYC() {
    alert('Modify KYC Details for customer: <%= customerId %>');
    // Implement navigation to KYC modification page
}

function modifyProfile() {
    alert('Modify Profile Details for customer: <%= customerId %>');
    // Implement navigation to profile modification page
}
</script>
</head>
<body>

<form>
    <!-- Action Buttons -->
    <div class="action-buttons">
        <button type="button" class="action-btn" onclick="viewAccounts()">
            📋 Accounts
        </button>
        <button type="button" class="action-btn" onclick="modifyKYC()">
            📝 Modify K.Y.C. Details
        </button>
        <button type="button" class="action-btn" onclick="modifyProfile()">
            👤 Modify Profile Details
        </button>
    </div>

    <!-- Customer Details -->
    <fieldset>
      <legend>Customer Details</legend>
      <div class="form-grid">
        <div>
          <label>Customer ID</label>
          <input readonly value="<%= customerId %>">
        </div>

        <div>
          <label>Name</label>
          <input readonly value="<%= firstName %>">
        </div>

        <div>
          <label>Gender</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "GENDER") %>">
        </div>
        <div>
          <label>Date of Birth</label>
          <input readonly value="<%= formatDateForInput(rsCustomer, "DATEOFBIRTH") %>">
        </div>
        <div>
          <label>Is Minor</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "IS_MINOR") %>">
        </div>
        <div>
          <label>Marital Status</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "MARITALSTATUS") %>">
        </div>
        <div>
          <label>Number of Dependents</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "NUMBEROFDEPENDENT") %>">
        </div>
        <div>
          <label>Number of Children</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "NUMBEROFCHILDREN") %>">
        </div>
        <div>
          <label>Category Code</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "CATEGORY_CODE") %>">
        </div>
        <div>
          <label>Customer Group</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "CUSTOMERGROUP_CODE") %>">
        </div>
        <div>
          <label>Occupation</label>
          <input readonly value="<%
            String occupationId = getStringSafe(rsCustomer, "OCCUPATION_ID");
            String occupationDesc = "";
            if (!occupationId.isEmpty()) {
                PreparedStatement psOccupation = null;
                ResultSet rsOccupation = null;
                try {
                    psOccupation = conn.prepareStatement(
                        "SELECT DESCRIPTION FROM GLOBALCONFIG.OCCUPATION WHERE OCCUPATION_ID = ?"
                    );
                    psOccupation.setString(1, occupationId);
                    rsOccupation = psOccupation.executeQuery();
                    if (rsOccupation.next()) {
                        occupationDesc = rsOccupation.getString("DESCRIPTION");
                    }
                } catch (Exception e) {
                    occupationDesc = occupationId;
                } finally {
                    try { if (rsOccupation != null) rsOccupation.close(); } catch (Exception ex) {}
                    try { if (psOccupation != null) psOccupation.close(); } catch (Exception ex) {}
                }
            }
            out.print(occupationDesc.isEmpty() ? occupationId : occupationDesc);
          %>">
        </div>
        <div>
          <label>Nationality</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "NATIONALITY") %>">
        </div>
        <div>
          <label>Religion</label>
          <input readonly value="<%
            String religionCode = getStringSafe(rsCustomer, "RELIGION_CODE");
            String religionDesc = "";
            if (!religionCode.isEmpty()) {
                PreparedStatement psReligion = null;
                ResultSet rsReligion = null;
                try {
                    psReligion = conn.prepareStatement(
                        "SELECT DESCRIPTION FROM GLOBALCONFIG.RELIGION WHERE RELIGION_CODE = ?"
                    );
                    psReligion.setString(1, religionCode);
                    rsReligion = psReligion.executeQuery();
                    if (rsReligion.next()) {
                        religionDesc = rsReligion.getString("DESCRIPTION");
                    }
                } catch (Exception e) {
                    religionDesc = religionCode;
                } finally {
                    try { if (rsReligion != null) rsReligion.close(); } catch (Exception ex) {}
                    try { if (psReligion != null) psReligion.close(); } catch (Exception ex) {}
                }
            }
            out.print(religionDesc.isEmpty() ? religionCode : religionDesc);
          %>">
        </div>
        <div>
          <label>Caste</label>
          <input readonly value="<%
            String casteCode = getStringSafe(rsCustomer, "CASTE_CODE");
            String casteDesc = "";
            if (!casteCode.isEmpty()) {
                PreparedStatement psCaste = null;
                ResultSet rsCaste = null;
                try {
                    psCaste = conn.prepareStatement(
                        "SELECT DESCRIPTION FROM GLOBALCONFIG.CASTE WHERE CASTE_CODE = ?"
                    );
                    psCaste.setString(1, casteCode);
                    rsCaste = psCaste.executeQuery();
                    if (rsCaste.next()) {
                        casteDesc = rsCaste.getString("DESCRIPTION");
                    }
                } catch (Exception e) {
                    casteDesc = casteCode;
                } finally {
                    try { if (rsCaste != null) rsCaste.close(); } catch (Exception ex) {}
                    try { if (psCaste != null) psCaste.close(); } catch (Exception ex) {}
                }
            }
            out.print(casteDesc.isEmpty() ? casteCode : casteDesc);
          %>">
        </div>
        <div>
          <label>Constitution</label>
          <input readonly value="<%
            String constitutionCode = getStringSafe(rsCustomer, "CONSTITUTION_CODE");
            String constitutionDesc = "";
            if (!constitutionCode.isEmpty()) {
                PreparedStatement psConstitution = null;
                ResultSet rsConstitution = null;
                try {
                    psConstitution = conn.prepareStatement(
                        "SELECT DESCRIPTION FROM GLOBALCONFIG.CONSTITUTION WHERE CONSTITUTION_CODE = ?"
                    );
                    psConstitution.setString(1, constitutionCode);
                    rsConstitution = psConstitution.executeQuery();
                    if (rsConstitution.next()) {
                        constitutionDesc = rsConstitution.getString("DESCRIPTION");
                    }
                } catch (Exception e) {
                    constitutionDesc = constitutionCode;
                } finally {
                    try { if (rsConstitution != null) rsConstitution.close(); } catch (Exception ex) {}
                    try { if (psConstitution != null) psConstitution.close(); } catch (Exception ex) {}
                }
            }
            out.print(constitutionDesc.isEmpty() ? constitutionCode : constitutionDesc);
          %>">
        </div>
         <div>
          <label>Office Phone</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "PHONEOFFICE") %>">
        </div>
        <div>
          <label>Mobile Number</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "PHONEMOBILE") %>">
        </div>
        <div>
          <label>Vehicle Owned</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "VEHICLEOWNED") %>">
        </div>
        <div>
          <label>Residence Type</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "RESIDENCETYPE") %>">
        </div>
        <div>
          <label>Residence Status</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "RESIDENCESTATUS") %>">
        </div>
                <div>
          <label>Name of Guardian</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "NAMEOFGUARDIAN") %>">
        </div>
                <div>
          <label>Relation</label>
          <input readonly value="<%
            String relationId = getStringSafe(rsCustomer, "RELATION_ID");
            String relationDesc = "";
            if (!relationId.isEmpty()) {
                PreparedStatement psRelation = null;
                ResultSet rsRelation = null;
                try {
                    psRelation = conn.prepareStatement(
                        "SELECT DESCRIPTION FROM GLOBALCONFIG.RELATION WHERE RELATION_ID = ?"
                    );
                    psRelation.setString(1, relationId);
                    rsRelation = psRelation.executeQuery();
                    if (rsRelation.next()) {
                        relationDesc = rsRelation.getString("DESCRIPTION");
                    }
                } catch (Exception e) {
                    relationDesc = relationId;
                } finally {
                    try { if (rsRelation != null) rsRelation.close(); } catch (Exception ex) {}
                    try { if (psRelation != null) psRelation.close(); } catch (Exception ex) {}
                }
            }
            out.print(relationDesc.isEmpty() ? relationId : relationDesc);
          %>">
        </div>
                <div>
          <label>Father Name</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "FATHERNAME") %>">
        </div>
        <div>
          <label>Mother Name</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "MOTHERNAME") %>">
        </div>
      </div>
    </fieldset>



   <!-- Address Details -->
    <fieldset>
      <legend>Address Details</legend>
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
        
        <!-- Permanent Address (Left) -->
        <div style="border: 1px solid #d0d0d0; padding: 15px; border-radius: 10px; background: #e8e4fc;">
          <h4 style="color: #373279; margin-top: 0; margin-bottom: 15px;">Permanent Address</h4>
          <div class="form-grid" style="grid-template-columns: repeat(2, 1fr);">
            <div>
              <label>Address Line 1</label>
              <input readonly value="<%= getStringSafe(rsCustomer, "PERMANENTADDRESS1") %>">
            </div>
            <div>
              <label>Address Line 2</label>
              <input readonly value="<%= getStringSafe(rsCustomer, "PERMANENTADDRESS2") %>">
            </div>
            <div>
              <label>Address Line 3</label>
              <input readonly value="<%= getStringSafe(rsCustomer, "PERMANENTADDRESS3") %>">
            </div>
            <div>
              <label>City</label>
              <input readonly value="<%
                String permCityCode = getStringSafe(rsCustomer, "PERMANENTCITY_CODE");
                String permCityName = "";
                if (!permCityCode.isEmpty()) {
                    PreparedStatement psPermCity = null;
                    ResultSet rsPermCity = null;
                    try {
                        psPermCity = conn.prepareStatement(
                            "SELECT NAME FROM GLOBALCONFIG.CITY WHERE CITY_CODE = ?"
                        );
                        psPermCity.setString(1, permCityCode);
                        rsPermCity = psPermCity.executeQuery();
                        if (rsPermCity.next()) {
                            permCityName = rsPermCity.getString("NAME");
                        }
                    } catch (Exception e) {
                        permCityName = permCityCode;
                    } finally {
                        try { if (rsPermCity != null) rsPermCity.close(); } catch (Exception ex) {}
                        try { if (psPermCity != null) psPermCity.close(); } catch (Exception ex) {}
                    }
                }
                out.print(permCityName.isEmpty() ? permCityCode : permCityName);
              %>">
            </div>
            <div>
              <label>Country</label>
              <input readonly value="<%
                String permCountryCode = getStringSafe(rsCustomer, "PERMANENTCOUNTRY_CODE");
                String permCountryName = "";
                if (!permCountryCode.isEmpty()) {
                    PreparedStatement psPermCountry = null;
                    ResultSet rsPermCountry = null;
                    try {
                        psPermCountry = conn.prepareStatement(
                            "SELECT NAME FROM GLOBALCONFIG.COUNTRY WHERE COUNTRY_CODE = ?"
                        );
                        psPermCountry.setString(1, permCountryCode);
                        rsPermCountry = psPermCountry.executeQuery();
                        if (rsPermCountry.next()) {
                            permCountryName = rsPermCountry.getString("NAME");
                        }
                    } catch (Exception e) {
                        permCountryName = permCountryCode;
                    } finally {
                        try { if (rsPermCountry != null) rsPermCountry.close(); } catch (Exception ex) {}
                        try { if (psPermCountry != null) psPermCountry.close(); } catch (Exception ex) {}
                    }
                }
                out.print(permCountryName.isEmpty() ? permCountryCode : permCountryName);
              %>">
            </div>
            <div>
              <label>ZIP/Postal Code</label>
              <input readonly value="<%= getStringSafe(rsCustomer, "PERMANENTZIP") %>">
            </div>
          </div>
        </div>

        <!-- Office/Residence Address (Right) -->
        <div style="border: 1px solid #d0d0d0; padding: 15px; border-radius: 10px; background: #e8e4fc;">
          <h4 style="color: #373279; margin-top: 0; margin-bottom: 15px;">Office Address</h4>
          <div class="form-grid" style="grid-template-columns: repeat(2, 1fr);">
            <div>
              <label>Address Line 1</label>
              <input readonly value="<%= getStringSafe(rsCustomer, "OFFICERESIDENCEADDRESS1") %>">
            </div>
            <div>
              <label>Address Line 2</label>
              <input readonly value="<%= getStringSafe(rsCustomer, "OFFICERESIDENCEADDRESS2") %>">
            </div>
            <div>
              <label>Address Line 3</label>
              <input readonly value="<%= getStringSafe(rsCustomer, "OFFICERESIDENCEADDRESS3") %>">
            </div>
            <div>
              <label>City</label>
              <input readonly value="<%
                String offCityCode = getStringSafe(rsCustomer, "OFFICERESIDENCECITY_CODE");
                String offCityName = "";
                if (!offCityCode.isEmpty()) {
                    PreparedStatement psOffCity = null;
                    ResultSet rsOffCity = null;
                    try {
                        psOffCity = conn.prepareStatement(
                            "SELECT NAME FROM GLOBALCONFIG.CITY WHERE CITY_CODE = ?"
                        );
                        psOffCity.setString(1, offCityCode);
                        rsOffCity = psOffCity.executeQuery();
                        if (rsOffCity.next()) {
                            offCityName = rsOffCity.getString("NAME");
                        }
                    } catch (Exception e) {
                        offCityName = offCityCode;
                    } finally {
                        try { if (rsOffCity != null) rsOffCity.close(); } catch (Exception ex) {}
                        try { if (psOffCity != null) psOffCity.close(); } catch (Exception ex) {}
                    }
                }
                out.print(offCityName.isEmpty() ? offCityCode : offCityName);
              %>">
            </div>
            <div>
              <label>Country</label>
              <input readonly value="<%
                String offCountryCode = getStringSafe(rsCustomer, "OFFICERESIDENCECOUNTRY_CODE");
                String offCountryName = "";
                if (!offCountryCode.isEmpty()) {
                    PreparedStatement psOffCountry = null;
                    ResultSet rsOffCountry = null;
                    try {
                        psOffCountry = conn.prepareStatement(
                            "SELECT NAME FROM GLOBALCONFIG.COUNTRY WHERE COUNTRY_CODE = ?"
                        );
                        psOffCountry.setString(1, offCountryCode);
                        rsOffCountry = psOffCountry.executeQuery();
                        if (rsOffCountry.next()) {
                            offCountryName = rsOffCountry.getString("NAME");
                        }
                    } catch (Exception e) {
                        offCountryName = offCountryCode;
                    } finally {
                        try { if (rsOffCountry != null) rsOffCountry.close(); } catch (Exception ex) {}
                        try { if (psOffCountry != null) psOffCountry.close(); } catch (Exception ex) {}
                    }
                }
                out.print(offCountryName.isEmpty() ? offCountryCode : offCountryName);
              %>">
            </div>
            <div>
              <label>ZIP/Postal Code</label>
              <input readonly value="<%= getStringSafe(rsCustomer, "OFFICERESIDENCEZIP") %>">
            </div>
          </div>
        </div>
        
      </div>
    </fieldset>


    <!-- KYC Details -->
    <fieldset>
      <legend>KYC & Identification Details</legend>
      <div class="form-grid">
        <div>
          <label>PAN Number</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "PANNO") %>">
        </div>
        <div>
          <label>Passport Number</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "PASSPORTNUMBER") %>">
        </div>
        <div>
          <label>Form 60</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "FORM60") %>">
        </div>
        <div>
          <label>Form 61</label>
          <input readonly value="<%= getStringSafe(rsCustomer, "FORM61") %>">
        </div>
      </div>
    </fieldset>

    <!-- Back Button -->
    <div style="text-align:center; margin-top:20px;">
        <button type="button" onclick="goBackToList();" class="back-btn action-btn">
            ← Back to List
        </button>
    </div>
</form>

</body>
</html>

<%
    } 
    catch (Exception e) {
        out.println("<pre style='color:red'>Error: " + e.getMessage() + "</pre>");
        e.printStackTrace();
    } finally {
        try { if (rsCustomer != null) rsCustomer.close(); } catch (Exception ex) {}
        try { if (psCustomer != null) psCustomer.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
%>