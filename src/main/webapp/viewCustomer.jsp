<%@ page import="java.sql.*, db.DBConnection, java.text.SimpleDateFormat, java.util.Date" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%! 
    // safe getter for strings
    String getStringSafe(ResultSet r, String col) throws SQLException {
        String v = r.getString(col);
        return (v == null) ? "" : v;
    }

    // yes/no helper for check flags
    String yesNo(ResultSet r, String col) throws SQLException {
        String v = r.getString(col);
        if (v == null) return "No";
        v = v.trim();
        if (v.equalsIgnoreCase("Y") || v.equalsIgnoreCase("YES") || v.equals("1") || v.equalsIgnoreCase("true")) return "Yes";
        if (v.equalsIgnoreCase("N") || v.equalsIgnoreCase("NO") || v.equals("0") || v.equalsIgnoreCase("false")) return "No";
        return v;
    }

    // format SQL date/timestamp to yyyy-MM-dd for input[type=date] (or human readable if empty)
    String formatDateForInput(ResultSet r, String col) throws SQLException {
        java.sql.Timestamp ts = null;
        try {
            ts = r.getTimestamp(col);
        } catch (Exception ex) {
            // try date
            try {
                java.sql.Date d = r.getDate(col);
                if (d != null) ts = new java.sql.Timestamp(d.getTime());
            } catch (Exception ignore) {}
        }
        if (ts == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(new Date(ts.getTime()));
    }

    // format date to human readable (fallback)
    String formatDateHuman(ResultSet r, String col) throws SQLException {
        String val = formatDateForInput(r, col);
        return val.isEmpty() ? getStringSafe(r, col) : val;
    }
%>

<%
    String cid = request.getParameter("cid");
    if (cid == null || cid.trim().isEmpty()) {
        out.println("<h3 style='color:red;'>Customer ID (cid) not provided in query string.</h3>");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        // adjust table name if your table is CUSTOMER_MASTER instead of CUSTOMERS
        ps = conn.prepareStatement("SELECT * FROM CUSTOMERS WHERE CUSTOMER_ID = ?");
        ps.setString(1, cid);
        rs = ps.executeQuery();

        if (!rs.next()) {
            out.println("<h3 style='color:red;'>No customer found with ID: " + cid + "</h3>");
            return;
        }
%>

<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>View Customer — <%= cid %></title>
  <link rel="stylesheet" href="css/addCustomer.css">
 <style>
/* Whole page background */
body {
    background: #e8e4fc;
    font-family: Arial, sans-serif;
}

/* Fieldset Box */
.fieldset-box {
    border: 1px solid #cbc3ff;
    border-radius: 10px;
    padding: 20px;
    margin-bottom: 25px;
   
}

/* Fieldset Legend */
.fieldset-box legend {
    font-size: 20px;
    padding: 0 12px;
    font-weight: bold;
    color: #2b0d73;
}

/* Label */
.form-label {
    font-size: 14px;
    font-weight: bold;
    color: #2b0d73;
    display: block;
    margin-bottom: 5px;
}

/* Input, Select, Readonly Field */
.form-input, .form-select {
    width: 100%;
    padding: 8px;
    background: white;
    border: 1px solid #ccc;
    border-radius: 6px;
    font-size: 14px;
    color: #333;
}

/* Make them readonly visually */
.form-input[readonly], .form-select[disabled] {
    background: #f8f8f8;
    color: #555;
}

/* 3-column Grid Layout */
.grid-3 {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 18px 20px;
    margin-top: 15px;
}

/* Radio buttons group spacing */
.radio-group {
    display: flex;
    align-items: center;
    gap: 10px;
}
</style>
<script>
//Update breadcrumb on page load
window.onload = function() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Dashboard > Total Customers > View Details');
    }
};

// Go back to list
function goBackToList() {
    if (window.parent && window.parent.updateParentBreadcrumb) {
        window.parent.updateParentBreadcrumb('Dashboard > Total Customers');
    }
    window.location.href = 'totalCustomers.jsp';
}
</script>
</head>
<body>
  <form>
    <!-- CUSTOMER INFORMATION -->
    <fieldset>
      <legend>Customer Information</legend>
      <div class="form-grid">
        <div>
          <label>Customer ID</label>
          <input readonly value="<%= getStringSafe(rs,"CUSTOMER_ID") %>">
        </div>
        <div>
          <label>Branch Code</label>
          <input readonly value="<%= getStringSafe(rs,"BRANCH_CODE") %>">
        </div>
         <div>
          <label>Is Individual</label>
          <input readonly value="<%= getStringSafe(rs,"IS_INDIVIDUAL") %>">
        </div>
        <div>
          <label>Gender</label>
          <input readonly value="<%= getStringSafe(rs,"GENDER") %>">
        </div>
         <div>
          <label>Salutation</label>
          <input readonly value="<%= getStringSafe(rs,"SALUTATION_CODE") %>">
        </div>       
        <div>
          <label>First Name</label>
          <input readonly value="<%= getStringSafe(rs,"FIRST_NAME") %>">
        </div>
        <div>
          <label>Middle Name</label>
          <input readonly value="<%= getStringSafe(rs,"MIDDLE_NAME") %>">
        </div>
        <div>
          <label>Surname</label>
          <input readonly value="<%= getStringSafe(rs,"SURNAME") %>">
        </div>
        <div>
          <label>Customer Name</label>
          <input readonly value="<%= getStringSafe(rs,"CUSTOMER_NAME") %>">
        </div>
        <div>
          <label>Birth Date</label>
          <input  readonly value="<%= formatDateForInput(rs,"BIRTH_DATE") %>">
        </div>
        <div>
          <label>Registration Date</label>
          <input  readonly value="<%= formatDateForInput(rs,"REGISTRATION_DATE") %>">
        </div>
        <div>
          <label>Is Minor</label>
          <input readonly value="<%= getStringSafe(rs,"IS_MINOR") %>">
        </div>
        <div>
          <label>Guardian Name</label>
          <input readonly value="<%= getStringSafe(rs,"GUARDIAN_NAME") %>">
        </div>
        <div>
          <label>Relation with Guardian</label>
          <input readonly value="<%= getStringSafe(rs,"RELATION_GUARDIAN") %>">
        </div> 
        <div>
          <label>Religion Code</label>
          <input readonly value="<%= getStringSafe(rs,"RELIGION_CODE") %>">
        </div>
        <div>
          <label>Caste Code</label>
          <input readonly value="<%= getStringSafe(rs,"CASTE_CODE") %>">
        </div>
        <div>
          <label>Category Code</label>
          <input readonly value="<%= getStringSafe(rs,"CATEGORY_CODE") %>">
        </div>
        <div>
          <label>Sub Category Code</label>
          <input readonly value="<%= getStringSafe(rs,"SUB_CATEGORY_CODE") %>">
        </div>
        <div>
          <label>Constitution Code</label>
          <input readonly value="<%= getStringSafe(rs,"CONSTITUTION_CODE") %>">
        </div>
        <div>
          <label>Occupation Code</label>
          <input readonly value="<%= getStringSafe(rs,"OCCUPATION_CODE") %>">
        </div>
        <div>
          <label>Vehicle Owned</label>
          <input readonly value="<%= getStringSafe(rs,"VEHICLE_OWNED") %>">
        </div>

        <div>
          <label>Member Type</label>
          <input readonly value="<%= getStringSafe(rs,"MEMBER_TYPE") %>">
        </div>
         <div>
          <label>Email</label>
          <input readonly value="<%= getStringSafe(rs,"EMAIL") %>">
        </div>
        <div>
          <label>GSTIN No</label>
          <input readonly value="<%= getStringSafe(rs,"GSTIN_NO") %>">
        </div>
        <div>
          <label>Member Number</label>
          <input readonly value="<%= getStringSafe(rs,"MEMBER_NUMBER") %>">
        </div>
        <div>
          <label>CKYC No</label>
          <input readonly value="<%= getStringSafe(rs,"CKY_NO") %>">
        </div>
        <div>
          <label>Risk Category</label>
          <input readonly value="<%= getStringSafe(rs,"RISK_CATEGORY") %>">
        </div>
      </div>
    </fieldset>

    <!-- PERSONAL INFORMATION -->
    <fieldset>
      <legend>Personal Information</legend>
      <div class="personal-grid">
        <div>
          <label>Mother Name</label>
          <input readonly value="<%= getStringSafe(rs,"MOTHER_NAME") %>">
        </div>
        <div>
          <label>Father Name</label>
          <input readonly value="<%= getStringSafe(rs,"FATHER_NAME") %>">
        </div>
        <div>
          <label>Marital Status</label>
          <input readonly value="<%= getStringSafe(rs,"MARITAL_STATUS") %>">
        </div>
        <div>
          <label>No. of Children</label>
          <input readonly value="<%= getStringSafe(rs,"NO_OF_CHILDREN") %>">
        </div>
        <div>
          <label>No. of Dependents</label>
          <input readonly value="<%= getStringSafe(rs,"NO_OF_DEPENDENTS") %>">
        </div>
      </div>
    </fieldset>

    <!-- ADDRESS INFORMATION -->
    <fieldset>
      <legend>Address Information</legend>
      <div class="address-grid">
        <div>
          <label>Nationality</label>
          <input readonly value="<%= getStringSafe(rs,"NATIONALITY") %>">
        </div>
        <div>
          <label>Residence Type</label>
          <input readonly value="<%= getStringSafe(rs,"RESIDENCE_TYPE") %>">
        </div>
        <div>
          <label>Residence Status</label>
          <input readonly value="<%= getStringSafe(rs,"RESIDENCE_STATUS") %>">
        </div>
        <div>
          <label>Address 1</label>
          <input readonly value="<%= getStringSafe(rs,"ADDRESS1") %>">
        </div>
        <div>
          <label>Address 2</label>
          <input readonly value="<%= getStringSafe(rs,"ADDRESS2") %>">
        </div>
        <div>
          <label>Address 3</label>
          <input readonly value="<%= getStringSafe(rs,"ADDRESS3") %>">
        </div>
        <div>
          <label>Country</label>
          <input readonly value="<%= getStringSafe(rs,"COUNTRY") %>">
        </div>
        <div>
          <label>State</label>
          <input readonly value="<%= getStringSafe(rs,"STATE") %>">
        </div>
        <div>
          <label>City</label>
          <input readonly value="<%= getStringSafe(rs,"CITY") %>">
        </div>
        <div>
          <label>ZIP</label>
          <input readonly value="<%= getStringSafe(rs,"ZIP") %>">
        </div>
        <div>
          <label>Mobile No</label>
          <input readonly value="<%= getStringSafe(rs,"MOBILE_NO") %>">
        </div>
        <div>
          <label>Office Phone</label>
          <input readonly value="<%= getStringSafe(rs,"OFFICE_PHONE") %>">
        </div>
        <div>
          <label>Residence Phone</label>
          <input readonly value="<%= getStringSafe(rs,"RESIDENCE_PHONE") %>">
        </div>
      </div>
    </fieldset>

    <!-- KYC / DOCUMENT CHECKLIST -->
    <fieldset class="kyc-fieldset">
      <legend>KYC Document Details</legend>

      <div class="kyc-row">
        <div class="kyc-section">
          <h4>Identity Proofs</h4>
          <table>
            <tr><th>Document</th><th>Present</th><th>Expiry Date</th><th>Number</th></tr>

            <tr>
              <td>Passport</td>
              <td><%= yesNo(rs,"PASSPORT_CHECK") %></td>
              <td><input readonly value="<%= formatDateForInput(rs,"PASSPORT_EXPIRY") %>"></td>
              <td><input readonly value="<%= getStringSafe(rs,"PASSPORT_NUMBER") %>"></td>
            </tr>

            <tr>
              <td>PAN</td>
              <td><%= yesNo(rs,"PAN_CHECK") %></td>
              <td><input  readonly value="<%= formatDateForInput(rs,"PAN_EXPIRY") %>"></td>
              <td><input readonly value="<%= getStringSafe(rs,"PAN") %>"></td>
            </tr>

            <tr>
              <td>Voter ID</td>
              <td><%= yesNo(rs,"VOTERID_CHECK") %></td>
              <td><input  readonly value="<%= formatDateForInput(rs,"VOTERID_EXPIRY") %>"></td>
              <td><input readonly value="<%= getStringSafe(rs,"VOTERID") %>"></td>
            </tr>

            <tr>
              <td>Driving License</td>
              <td><%= yesNo(rs,"DL_CHECK") %></td>
              <td><input  readonly value="<%= formatDateForInput(rs,"DL_EXPIRY") %>"></td>
              <td><input readonly value="<%= getStringSafe(rs,"DL") %>"></td>
            </tr>

            <tr>
              <td>Aadhar</td>
              <td><%= yesNo(rs,"AADHAR_CHECK") %></td>
              <td><input  readonly value="<%= formatDateForInput(rs,"AADHAR_EXPIRY") %>"></td>
              <td><input readonly value="<%= getStringSafe(rs,"AADHAR") %>"></td>
            </tr>

            <tr>
              <td>NREGA</td>
              <td><%= yesNo(rs,"NREGA_CHECK") %></td>
              <td><input  readonly value="<%= formatDateForInput(rs,"NREGA_EXPIRY") %>"></td>
              <td><input readonly value="<%= getStringSafe(rs,"NREGA") %>"></td>
            </tr>
          </table>
        </div>

        <div class="kyc-divider"></div>

        <div class="kyc-section">
          <h4>Address Proofs & Others</h4>
          <table>
            <tr><th>Document</th><th>Present</th><th>Expiry Date</th><th>Number</th></tr>

            <tr>
              <td>Telephone Bill</td>
              <td><%= yesNo(rs,"TELEPHONE_CHECK") %></td>
              <td><input  readonly value="<%= formatDateForInput(rs,"TELEPHONE_EXPIRY") %>"></td>
              <td><input readonly value="<%= getStringSafe(rs,"TELEPHONE") %>"></td>
            </tr>

            <tr>
              <td>Bank Statement</td>
              <td><%= yesNo(rs,"BANK_CHECK") %></td>
              <td><input  readonly value="<%= formatDateForInput(rs,"BANK_EXPIRY") %>"></td>
              <td><input readonly value="<%= getStringSafe(rs,"BANK_STATEMENT") %>"></td>
            </tr>

            <tr>
              <td>Govt Docs</td>
              <td><%= yesNo(rs,"GOVT_CHECK") %></td>
              <td><input  readonly value="<%= formatDateForInput(rs,"GOVT_EXPIRY") %>"></td>
              <td><input readonly value="<%= getStringSafe(rs,"GOVT_DOC") %>"></td>
            </tr>

            <tr>
              <td>Electricity Bill</td>
              <td><%= yesNo(rs,"ELECTRICITY_CHECK") %></td>
              <td><input  readonly value="<%= formatDateForInput(rs,"ELECTRICITY_EXPIRY") %>"></td>
              <td><input readonly value="<%= getStringSafe(rs,"ELECTRICITY") %>"></td>
            </tr>

            <tr>
              <td>Ration Card</td>
              <td><%= yesNo(rs,"RATION_CHECK") %></td>
              <td><input  readonly value="<%= formatDateForInput(rs,"RATION_EXPIRY") %>"></td>
              <td><input readonly value="<%= getStringSafe(rs,"RATION") %>"></td>
            </tr>
          </table>
        </div>
      </div>

      <hr style="margin:12px 0; border:none; border-top:1px solid #eee;">

      <div class="kyc-row">
        <div class="kyc-section">
          <h4>Proprietary / Business Concern</h4>
          <table>
            <tr><th>Document</th><th>Present</th><th>Expiry Date</th></tr>

            <tr>
              <td>Registered Rent Agreement</td>
              <td><%= yesNo(rs,"RENT_CHECK") %></td>
              <td><input  readonly value="<%= formatDateForInput(rs,"RENT_EXPIRY") %>"></td>
            </tr>

            <tr>
              <td>Certificate / License</td>
              <td><%= yesNo(rs,"CERT_CHECK") %></td>
              <td><input  readonly value="<%= formatDateForInput(rs,"CERT_EXPIRY") %>"></td>
            </tr>

            <tr>
              <td>Sales & Income Tax Returns</td>
              <td><%= yesNo(rs,"TAX_CHECK") %></td>
              <td><input readonly value="<%= formatDateForInput(rs,"TAX_EXPIRY") %>"></td>
            </tr>

            <tr>
              <td>CST / VAT Certificate</td>
              <td><%= yesNo(rs,"CST_CHECK") %></td>
              <td><input  readonly value="<%= formatDateForInput(rs,"CST_EXPIRY") %>"></td>
            </tr>

            <tr>
              <td>License by Registering Authority</td>
              <td><%= yesNo(rs,"REG_CHECK") %></td>
              <td><input readonly value="<%= formatDateForInput(rs,"REG_EXPIRY") %>"></td>
            </tr>
          </table>
        </div>

        <div class="kyc-divider"></div>

        <div class="kyc-section">
          <h4>Business Concern</h4>
          <table>
            <tr><th>Document</th><th>Present</th><th>Expiry Date</th></tr>

            <tr>
              <td>Certificate of Incorporation</td>
              <td><%= yesNo(rs,"INC_CHECK") %></td>
              <td><input  readonly value="<%= formatDateForInput(rs,"INC_EXPIRY") %>"></td>
            </tr>

            <tr>
              <td>Resolution of Board</td>
              <td><%= yesNo(rs,"BOARD_CHECK") %></td>
              <td><input  readonly value="<%= formatDateForInput(rs,"BOARD_EXPIRY") %>"></td>
            </tr>

            <tr>
              <td>Power of Attorney</td>
              <td><%= yesNo(rs,"POA_CHECK") %></td>
              <td><input  readonly value="<%= formatDateForInput(rs,"POA_EXPIRY") %>"></td>
            </tr>
          </table>
        </div>
      </div>

    </fieldset>

    <div style="text-align:center;">
    <button type="button" onclick="goBackToList();" class="back-btn"
        style="padding:10px 22px; background:#0d6efd; color:white;
                   border:none; border-radius:6px; cursor:pointer;
                   font-size:16px; font-weight:bold;">
    ← Back to List
</button>
</div>
  </form>

</body>
</html>

<%
    } catch (Exception e) {
        // show a readable message to user and log stacktrace to server log (avoid printStackTrace(out))
        out.println("<pre style='color:red'>Error: " + e.getMessage() + "</pre>");
        e.printStackTrace(); // server log
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (ps != null) ps.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
%>
