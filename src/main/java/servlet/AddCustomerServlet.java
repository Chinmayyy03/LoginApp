package servlet;

import db.DBConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AddCustomerServlet")
public class AddCustomerServlet extends HttpServlet {

    // Helper method to parse date safely
    private java.sql.Date parseDate(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) {
            return null;
        }
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            return new java.sql.Date(sdf.parse(dateStr).getTime());
        } catch (Exception e) {
            return null;
        }
    }

    // Helper method to safely trim and get parameter
    private String getTrimmedParameter(HttpServletRequest request, String param) {
        String value = request.getParameter(param);
        if (value == null) {
            return null;
        }
        value = value.trim();
        return value.isEmpty() ? null : value;
    }

    // Helper method to parse integer safely
    private Integer parseInt(String str) {
        if (str == null || str.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(str);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    // Helper method to parse long safely
    private Long parseLong(String str) {
        if (str == null || str.trim().isEmpty()) {
            return null;
        }
        try {
            return Long.parseLong(str);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    // Generate GLOBALLY UNIQUE Customer ID based on branch code
    private String generateCustomerId(Connection conn, String branchCode) throws Exception {
        // Format branch code to 4 digits (pad with zeros if needed)
        String branchPrefix = String.format("%04d", Integer.parseInt(branchCode));
        
        // Get the TOTAL count of ALL customers across ALL branches (globally unique)
        String countSQL = "SELECT COUNT(*) FROM CUSTOMER.CUSTOMER";
        PreparedStatement pstmt = conn.prepareStatement(countSQL);
        ResultSet rs = pstmt.executeQuery();
        
        int totalCustomers = 0;
        if (rs.next()) {
            totalCustomers = rs.getInt(1);
        }
        rs.close();
        pstmt.close();
        
        // Generate new customer ID: branchCode (4 digits) + global sequential number (6 digits)
        String customerId = branchPrefix + String.format("%06d", totalCustomers + 1);
        return customerId;
    }

    // Get RELATION_ID from relation description
    private Integer getRelationId(Connection conn, String relationDesc) throws Exception {
        if (relationDesc == null || relationDesc.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT RELATION_ID FROM GLOBALCONFIG.RELATION WHERE DESCRIPTION = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, relationDesc);
        ResultSet rs = pstmt.executeQuery();
        Integer relationId = null;
        if (rs.next()) {
            relationId = rs.getInt("RELATION_ID");
        }
        rs.close();
        pstmt.close();
        return relationId;
    }

    // Get OCCUPATION_ID from occupation description
    private Integer getOccupationId(Connection conn, String occupationDesc) throws Exception {
        if (occupationDesc == null || occupationDesc.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT OCCUPATION_ID FROM GLOBALCONFIG.OCCUPATION WHERE DESCRIPTION = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, occupationDesc);
        ResultSet rs = pstmt.executeQuery();
        Integer occupationId = null;
        if (rs.next()) {
            occupationId = rs.getInt("OCCUPATION_ID");
        }
        rs.close();
        pstmt.close();
        return occupationId;
    }

    // Get RESIDENCETYPE code from description
    private Integer getResidenceTypeId(Connection conn, String residenceTypeDesc) throws Exception {
        if (residenceTypeDesc == null || residenceTypeDesc.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT RESIDENCETYPE_ID FROM GLOBALCONFIG.RESIDENCETYPE WHERE DESCRIPTION = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, residenceTypeDesc);
        ResultSet rs = pstmt.executeQuery();
        Integer residenceTypeId = null;
        if (rs.next()) {
            residenceTypeId = rs.getInt("RESIDENCETYPE_ID");
        }
        rs.close();
        pstmt.close();
        return residenceTypeId;
    }

    // Convert residence status to numeric code
    private Integer getResidenceStatusCode(String residenceStatus) {
        if (residenceStatus == null || residenceStatus.trim().isEmpty()) {
            return null;
        }
        switch (residenceStatus.toUpperCase()) {
            case "BANGLOW": return 1;
            case "ROW HOUSE": return 2;
            case "FLAT": return 3;
            case "OTHER": return 4;
            case "NOT APPLICABLE": return 0;
            default: return null;
        }
    }

    // Convert vehicle owned to numeric code
    private Integer getVehicleOwnedCode(String vehicleOwned) {
        if (vehicleOwned == null || vehicleOwned.trim().isEmpty()) {
            return 0;
        }
        switch (vehicleOwned.toUpperCase()) {
            case "CAR": return 1;
            case "BIKE": return 2;
            case "BOTH": return 3;
            case "NOT APPLICABLE": return 0;
            default: return 0;
        }
    }

    // Convert gender to single character
    private String getGenderCode(String gender) {
        if (gender == null || gender.trim().isEmpty()) {
            return null;
        }
        switch (gender.toLowerCase()) {
            case "male": return "M";
            case "female": return "F";
            case "other": return "O";
            default: return null;
        }
    }

    // Convert marital status to single character
    private String getMaritalStatusCode(String maritalStatus) {
        if (maritalStatus == null || maritalStatus.trim().isEmpty()) {
            return "O";
        }
        switch (maritalStatus.toLowerCase()) {
            case "married": return "M";
            case "single": return "S";
            case "other": return "O";
            default: return "O";
        }
    }

    // Convert yes/no to Y/N
    private String convertYesNo(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "N";
        }
        return value.equalsIgnoreCase("yes") ? "Y" : "N";
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        System.out.println("=== SaveCustomerServlet called ===");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("branchCode") == null) {
            System.out.println("Session is null or branchCode not found");
            response.sendRedirect("login.jsp");
            return;
        }

        String branchCode = (String) session.getAttribute("branchCode");
        String userId = (String) session.getAttribute("userId");
        System.out.println("Branch Code: " + branchCode);
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        String customerId = null;

        try {
            System.out.println("Attempting database connection...");
            conn = DBConnection.getConnection();
            System.out.println("Database connected successfully");

            // Generate Customer ID
            customerId = generateCustomerId(conn, branchCode);
            System.out.println("Generated Customer ID: " + customerId);

            // Get lookup IDs
            Integer relationId = getRelationId(conn, getTrimmedParameter(request, "relationGuardian"));
            Integer occupationId = getOccupationId(conn, getTrimmedParameter(request, "occupationCode"));
            Integer residenceTypeId = getResidenceTypeId(conn, getTrimmedParameter(request, "residenceType"));
            Integer residenceStatusCode = getResidenceStatusCode(getTrimmedParameter(request, "residenceStatus"));
            Integer vehicleOwnedCode = getVehicleOwnedCode(getTrimmedParameter(request, "vehicleOwned"));

            // Build INSERT SQL for CUSTOMER.CUSTOMER table
            String insertSQL = "INSERT INTO CUSTOMER.CUSTOMER (" +
                "CUSTOMER_ID, SALUTATION_CODE, NAMEFIRST, NAMEMIDDLE, NAMELAST, " +
                "DATEOFBIRTH, GENDER, OCCUPATION_ID, IS_MINOR, RELIGION_CODE, " +
                "CASTE_CODE, CATEGORY_CODE, CONSTITUTION_CODE, VEHICLEOWNED, PASSPORTNUMBER, " +
                "PANNO, FORM60, FORM61, NAMEOFGUARDIAN, RELATION_ID, " +
                "NATIONALITY, RESIDENCETYPE, RESIDENCESTATUS, ADDRESS1, ADDRESS2, " +
                "ADDRESS3, CITY_CODE, COUNTRY_CODE, STATE_CODE, ZIP, " +
                "PHONERESIDENCE, PHONEOFFICE, PHONEMOBILE, MOTHERNAME, FATHERNAME, " +
                "MARITALSTATUS, NUMBEROFDEPENDENT, NUMBEROFCHILDREN, CUSTOMERGROUP_CODE, IS_PERMANENT_ADDRESS_SAME, " +
                "PERMANENTADDRESS1, PERMANENTADDRESS2, PERMANENTADDRESS3, PERMANENTCITY_CODE, PERMANENTCOUNTRY_CODE, " +
                "PERMANENTZIP, IS_OFFICE_RESIDENCE, IS_OFFICE_RESIDENCE_SAME, OFFICERESIDENCEADDRESS1, OFFICERESIDENCEADDRESS2, " +
                "OFFICERESIDENCEADDRESS3, OFFICERESIDENCECITY_CODE, OFFICERESIDENCECOUNTRY_CODE, OFFICERESIDENCEZIP, INTRODUCERACCOUNT_CODE, " +
                "NAME, REGISTRATION_DATE, MEMBER_NUMBER, MEMBER_TYPE, TDS_AMOUNT, " +
                "CREATED_DATE, SHORT_NAME, AADHAR_CARD_NO, EMAIL_ID, AC_AREACODE, " +
                "AC_MAIN_AREACODE, TDS_APPLICABLE, FORM15G, FORM15H, CKYC_NO, " +
                "GSTIN, HOME_BRANCH, STATUS" +
                ") VALUES (" +
                "?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, " +
                "?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, " +
                "?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, " +
                "?,?,?,?,?, ?,?,?,?,?, ?,?,?" +
                ")";

            pstmt = conn.prepareStatement(insertSQL);
            System.out.println("PreparedStatement created");

            int idx = 1;
            
            // 1-5: Basic Info
            pstmt.setString(idx++, customerId);
            pstmt.setString(idx++, getTrimmedParameter(request, "salutationCode"));
            pstmt.setString(idx++, getTrimmedParameter(request, "firstName"));
            pstmt.setString(idx++, getTrimmedParameter(request, "middleName"));
            pstmt.setString(idx++, getTrimmedParameter(request, "surname"));
            
            // 6-10: Personal Details
            pstmt.setDate(idx++, parseDate(getTrimmedParameter(request, "birthDate")));
            pstmt.setString(idx++, getGenderCode(getTrimmedParameter(request, "gender")));
            if (occupationId != null) {
                pstmt.setInt(idx++, occupationId);
            } else {
                pstmt.setNull(idx++, java.sql.Types.INTEGER);
            }
            pstmt.setString(idx++, convertYesNo(getTrimmedParameter(request, "isMinor")));
            pstmt.setString(idx++, getTrimmedParameter(request, "religionyCode"));
            
            // 11-15: Caste, Category, Constitution
            pstmt.setString(idx++, getTrimmedParameter(request, "casteCode"));
            pstmt.setString(idx++, getTrimmedParameter(request, "categoryCode"));
            pstmt.setString(idx++, getTrimmedParameter(request, "constitutionCode"));
            if (vehicleOwnedCode != null) {
                pstmt.setInt(idx++, vehicleOwnedCode);
            } else {
                pstmt.setNull(idx++, java.sql.Types.INTEGER);
            }
            pstmt.setString(idx++, getTrimmedParameter(request, "passportNumber"));
            
            // 16-20: ID Proofs and Guardian
            pstmt.setString(idx++, getTrimmedParameter(request, "pan"));
            pstmt.setString(idx++, "N"); // FORM60 - default N
            pstmt.setString(idx++, "N"); // FORM61 - default N
            pstmt.setString(idx++, getTrimmedParameter(request, "guardianName"));
            if (relationId != null) {
                pstmt.setInt(idx++, relationId);
            } else {
                pstmt.setNull(idx++, java.sql.Types.INTEGER);
            }
            
            // 21-25: Address Details
            pstmt.setString(idx++, getTrimmedParameter(request, "nationality"));
            if (residenceTypeId != null) {
                pstmt.setInt(idx++, residenceTypeId);
            } else {
                pstmt.setNull(idx++, java.sql.Types.INTEGER);
            }
            if (residenceStatusCode != null) {
                pstmt.setInt(idx++, residenceStatusCode);
            } else {
                pstmt.setNull(idx++, java.sql.Types.INTEGER);
            }
            pstmt.setString(idx++, getTrimmedParameter(request, "address1"));
            pstmt.setString(idx++, getTrimmedParameter(request, "address2"));
            
            // 26-30: Address continuation
            pstmt.setString(idx++, getTrimmedParameter(request, "address3"));
            pstmt.setString(idx++, getTrimmedParameter(request, "city"));
            pstmt.setString(idx++, getTrimmedParameter(request, "country"));
            pstmt.setString(idx++, getTrimmedParameter(request, "state"));
            Integer zip = parseInt(getTrimmedParameter(request, "zip"));
            if (zip != null) {
                pstmt.setInt(idx++, zip);
            } else {
                pstmt.setNull(idx++, java.sql.Types.INTEGER);
            }
            
            // 31-35: Contact Details
            Long residencePhone = parseLong(getTrimmedParameter(request, "residencePhone"));
            if (residencePhone != null) {
                pstmt.setLong(idx++, residencePhone);
            } else {
                pstmt.setNull(idx++, java.sql.Types.BIGINT);
            }
            
            Long officePhone = parseLong(getTrimmedParameter(request, "officePhone"));
            if (officePhone != null) {
                pstmt.setLong(idx++, officePhone);
            } else {
                pstmt.setNull(idx++, java.sql.Types.BIGINT);
            }
            
            Long mobileNo = parseLong(getTrimmedParameter(request, "mobileNo"));
            if (mobileNo != null) {
                pstmt.setLong(idx++, mobileNo);
            } else {
                pstmt.setNull(idx++, java.sql.Types.BIGINT);
            }
            
            pstmt.setString(idx++, getTrimmedParameter(request, "motherName"));
            pstmt.setString(idx++, getTrimmedParameter(request, "fatherName"));
            
            // 36-40: Family Details
            pstmt.setString(idx++, getMaritalStatusCode(getTrimmedParameter(request, "maritalStatus")));
            
            Integer dependents = parseInt(getTrimmedParameter(request, "dependents"));
            pstmt.setInt(idx++, dependents != null ? dependents : 0);
            
            Integer children = parseInt(getTrimmedParameter(request, "children"));
            pstmt.setInt(idx++, children != null ? children : 0);
            
            pstmt.setString(idx++, getTrimmedParameter(request, "subCategoryCode")); // CUSTOMERGROUP_CODE
            pstmt.setString(idx++, "Y"); // IS_PERMANENT_ADDRESS_SAME - default Y
            
            // 41-45: Permanent Address (same as current address by default)
            pstmt.setString(idx++, getTrimmedParameter(request, "address1"));
            pstmt.setString(idx++, getTrimmedParameter(request, "address2"));
            pstmt.setString(idx++, getTrimmedParameter(request, "address3"));
            pstmt.setString(idx++, getTrimmedParameter(request, "city"));
            pstmt.setString(idx++, getTrimmedParameter(request, "country"));
            
            // 46-50: Permanent Address continuation
            if (zip != null) {
                pstmt.setInt(idx++, zip);
            } else {
                pstmt.setNull(idx++, java.sql.Types.INTEGER);
            }
            pstmt.setString(idx++, "R"); // IS_OFFICE_RESIDENCE - default R (Residence)
            pstmt.setString(idx++, "Y"); // IS_OFFICE_RESIDENCE_SAME - default Y
            pstmt.setString(idx++, getTrimmedParameter(request, "address1")); // Office address same as residence
            pstmt.setString(idx++, getTrimmedParameter(request, "address2"));
            
            // 51-55: Office Address continuation
            pstmt.setString(idx++, getTrimmedParameter(request, "address3"));
            pstmt.setString(idx++, getTrimmedParameter(request, "city"));
            pstmt.setString(idx++, getTrimmedParameter(request, "country"));
            if (zip != null) {
                pstmt.setInt(idx++, zip);
            } else {
                pstmt.setNull(idx++, java.sql.Types.INTEGER);
            }
            pstmt.setNull(idx++, java.sql.Types.CHAR); // INTRODUCERACCOUNT_CODE
            
            // 56-60: Member Details
            pstmt.setString(idx++, getTrimmedParameter(request, "customerName")); // NAME
            pstmt.setDate(idx++, parseDate(getTrimmedParameter(request, "registrationDate")));
            Integer memberNumber = parseInt(getTrimmedParameter(request, "memberNumber"));
            if (memberNumber != null) {
                pstmt.setInt(idx++, memberNumber);
            } else {
                pstmt.setNull(idx++, java.sql.Types.INTEGER);
            }
            pstmt.setString(idx++, getTrimmedParameter(request, "memberType"));
            pstmt.setDouble(idx++, 0); // TDS_AMOUNT - default 0
            
            // 61-65: Audit and Additional Fields
            pstmt.setDate(idx++, new java.sql.Date(System.currentTimeMillis())); // CREATED_DATE
            pstmt.setString(idx++, getTrimmedParameter(request, "firstName")); // SHORT_NAME
            
            Long aadharNo = parseLong(getTrimmedParameter(request, "aadhar"));
            if (aadharNo != null) {
                pstmt.setLong(idx++, aadharNo);
            } else {
                pstmt.setLong(idx++, 0);
            }
            
            pstmt.setString(idx++, getTrimmedParameter(request, "email"));
            pstmt.setNull(idx++, java.sql.Types.VARCHAR); // AC_AREACODE
            
            // 66-70: Additional Configuration
            pstmt.setNull(idx++, java.sql.Types.INTEGER); // AC_MAIN_AREACODE
            pstmt.setString(idx++, "N"); // TDS_APPLICABLE - default N
            pstmt.setString(idx++, "N"); // FORM15G - default N
            pstmt.setString(idx++, "N"); // FORM15H - default N
            pstmt.setString(idx++, getTrimmedParameter(request, "ckyNo"));
            
            // 71-73: Final Fields
            pstmt.setString(idx++, getTrimmedParameter(request, "gstinNo"));
            pstmt.setString(idx++, branchCode); // HOME_BRANCH
            pstmt.setString(idx++, "E"); // STATUS - Entry/Pending

            System.out.println("All parameters set. Total parameters: " + (idx - 1));
            
            int rows = pstmt.executeUpdate();
            System.out.println("Rows inserted: " + rows);

            if (rows > 0) {
                System.out.println("Customer added successfully to CUSTOMER.CUSTOMER table!");
                
                // Upload photo and signature
                String photoData = request.getParameter("photoData");
                String signatureData = request.getParameter("signatureData");
                String registrationDate = request.getParameter("registrationDate");
                
                uploadPhotoAndSignature(customerId, userId, photoData, signatureData, registrationDate);
                
                response.sendRedirect("addCustomer.jsp?status=success&customerId=" + customerId);
            } else {
                System.out.println("Failed to insert customer");
                response.sendRedirect("addCustomer.jsp?status=error&message=Failed to add customer");
            }

        } catch (Exception e) {
            System.out.println("ERROR: " + e.getMessage());
            e.printStackTrace();
            String errorMsg = e.getMessage().replace("'", "\\'");
            response.sendRedirect("addCustomer.jsp?status=error&message=" + java.net.URLEncoder.encode(errorMsg, "UTF-8"));
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
    
    private void uploadPhotoAndSignature(String customerId, String userId, String photoData, 
            String signatureData, String registrationDate) {
        Connection conn = null;
        PreparedStatement psPhoto = null;
        PreparedStatement psSignature = null;

        try {
            conn = DBConnection.getConnection();

            // Insert Photo
            if (photoData != null && !photoData.isEmpty()) {
                if (photoData.contains(",")) {
                    photoData = photoData.split(",")[1];
                }

                byte[] photoBytes = java.util.Base64.getDecoder().decode(photoData);
                String photoFilename = "PHOTO_" + customerId + ".jpg";

                String sqlPhoto = "INSERT INTO SIGNATURES.CUSTOMERPHOTO " +
                    "(CUSTOMER_ID, PHOTO, USER_ID, OFFICER_ID, DATEOFREGISTRATION, PHOTOFILENAME, UPLOAD_ID) " +
                    "VALUES (?, ?, ?, NULL, ?, ?, ?)";

                psPhoto = conn.prepareStatement(sqlPhoto);
                psPhoto.setString(1, customerId);
                psPhoto.setBytes(2, photoBytes);
                psPhoto.setString(3, userId);
                psPhoto.setDate(4, parseDate(registrationDate));
                psPhoto.setString(5, photoFilename);
                psPhoto.setString(6, userId);

                psPhoto.executeUpdate();
                System.out.println("✅ Photo uploaded for customer: " + customerId);
            }

            // Insert Signature
            if (signatureData != null && !signatureData.isEmpty()) {
                if (signatureData.contains(",")) {
                    signatureData = signatureData.split(",")[1];
                }

                byte[] signatureBytes = java.util.Base64.getDecoder().decode(signatureData);
                String signatureFilename = "SIGN_" + customerId + ".jpg";

                String sqlSignature = "INSERT INTO SIGNATURES.CUSTOMERSIGNATURE " +
                    "(CUSTOMER_ID, SIGNATURE, USER_ID, OFFICER_ID, DATEOFREGISTRATION, SIGNATUREFILENAME, UPLOAD_ID) " +
                    "VALUES (?, ?, ?, NULL, ?, ?, ?)";

                psSignature = conn.prepareStatement(sqlSignature);
                psSignature.setString(1, customerId);
                psSignature.setBytes(2, signatureBytes);
                psSignature.setString(3, userId);
                psSignature.setDate(4, parseDate(registrationDate));
                psSignature.setString(5, signatureFilename);
                psSignature.setString(6, userId);

                psSignature.executeUpdate();
                System.out.println("✅ Signature uploaded for customer: " + customerId);
            }

        } catch (Exception e) {
            System.out.println("❌ Photo/Signature upload error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try { if (psPhoto != null) psPhoto.close(); } catch (Exception ignored) {}
            try { if (psSignature != null) psSignature.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
}