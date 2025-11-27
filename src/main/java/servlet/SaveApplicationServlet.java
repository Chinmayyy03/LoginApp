package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/SaveApplicationServlet")
public class SaveApplicationServlet extends HttpServlet {

    // Generate 14-digit APPLICATION_NUMBER: BranchCode(4) + Sequential(10)
    private String generateApplicationNumber(Connection conn, String branchCode) throws Exception {
        String branchPrefix = String.format("%04d", Integer.parseInt(branchCode));
        
        String maxSQL = "SELECT MAX(APPLICATION_NUMBER) FROM APPLICATION.APPLICATION WHERE BRANCH_CODE = ?";
        PreparedStatement pstmt = conn.prepareStatement(maxSQL);
        pstmt.setString(1, branchCode);
        ResultSet rs = pstmt.executeQuery();
        
        long nextNumber = 1;
        if (rs.next()) {
            String maxAppNum = rs.getString(1);
            if (maxAppNum != null && maxAppNum.length() == 14) {
                String lastTenDigits = maxAppNum.substring(4);
                nextNumber = Long.parseLong(lastTenDigits) + 1;
            }
        }
        rs.close();
        pstmt.close();
        
        String applicationNumber = branchPrefix + String.format("%010d", nextNumber);
        return applicationNumber;
    }

    private Date parseDate(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) {
            return null;
        }
        try {
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
            return new Date(sdf.parse(dateStr).getTime());
        } catch (Exception e) {
            return null;
        }
    }

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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        
        System.out.println("=== SaveApplicationServlet called ===");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("branchCode") == null) {
            System.out.println("Session is null or branchCode not found");
            response.sendRedirect("login.jsp");
            return;
        }

        String branchCode = (String) session.getAttribute("branchCode");
        String userId = (String) session.getAttribute("userId");
        System.out.println("Branch Code: " + branchCode);
        System.out.println("User ID: " + userId);
        
        // Debug form parameters
        String productCode = request.getParameter("productCode");
        String customerId = request.getParameter("customerId");
        System.out.println("📌 Form Parameters:");
        System.out.println("   - productCode: '" + productCode + "'");
        System.out.println("   - customerId: '" + customerId + "'");
        
        // Validate required fields
        if (productCode == null || productCode.trim().isEmpty()) {
            String errorMsg = "Product Code is required but was not provided";
            System.out.println("❌ VALIDATION ERROR: " + errorMsg);
            response.sendRedirect("savingAcc.jsp?status=error&message=" + 
                java.net.URLEncoder.encode(errorMsg, "UTF-8"));
            return;
        }
        
        if (customerId == null || customerId.trim().isEmpty()) {
            String errorMsg = "Customer ID is required";
            System.out.println("❌ VALIDATION ERROR: " + errorMsg);
            response.sendRedirect("savingAcc.jsp?status=error&message=" + 
                java.net.URLEncoder.encode(errorMsg, "UTF-8"));
            return;
        }
        
        Connection conn = null;
        PreparedStatement psApp = null;
        PreparedStatement psNominee = null;
        PreparedStatement psJoint = null;
        String applicationNumber = null;

        try {
            System.out.println("Attempting database connection...");
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            System.out.println("Database connected successfully");

            applicationNumber = generateApplicationNumber(conn, branchCode);
            System.out.println("Generated Application Number: " + applicationNumber);

            // ========== 1. INSERT APPLICATION DETAILS ==========
            String appSQL = "INSERT INTO APPLICATION.APPLICATION (" +
                "APPLICATION_NUMBER, BRANCH_CODE, PRODUCT_CODE, APPLICATIONDATE, " +
                "CUSTOMER_ID, ACCOUNTOPERATIONCAPACITY_ID, USER_ID, MINBALANCE_ID, " +
                "INTRODUCERACCOUNT_CODE, CATEGORY_CODE, NAME, INTRODUCER_NAME, " +
                "RISKCATEGORY, STATUS" +
                ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'E')";

            psApp = conn.prepareStatement(appSQL);
            psApp.setString(1, applicationNumber);
            psApp.setString(2, branchCode);
            psApp.setString(3, productCode);
            psApp.setDate(4, parseDate(request.getParameter("dateOfApplication")));
            psApp.setString(5, customerId);
            
            Integer accOpCapacity = parseInt(request.getParameter("accountOperationCapacity"));
            if (accOpCapacity != null) {
                psApp.setInt(6, accOpCapacity);
            } else {
                psApp.setNull(6, java.sql.Types.INTEGER);
            }
            
            psApp.setString(7, userId);
            
            Integer minBalance = parseInt(request.getParameter("minBalanceID"));
            if (minBalance != null) {
                psApp.setInt(8, minBalance);
            } else {
                psApp.setNull(8, java.sql.Types.INTEGER);
            }
            
            psApp.setString(9, request.getParameter("introducerAccCode"));
            psApp.setString(10, request.getParameter("categoryCode"));
            psApp.setString(11, request.getParameter("customerName"));
            psApp.setString(12, request.getParameter("introducerAccName"));
            psApp.setString(13, request.getParameter("riskCategory"));

            System.out.println("=== INSERT Parameters ===");
            System.out.println("1. APPLICATION_NUMBER: " + applicationNumber);
            System.out.println("2. PRODUCT_CODE: " + productCode);
            System.out.println("3. CUSTOMER_ID: " + customerId);
            
            int appRows = psApp.executeUpdate();
            System.out.println("Application inserted: " + appRows + " row(s)");

            // ========== 2. INSERT NOMINEE DETAILS ==========
            String[] nomineeCustomerIDs = request.getParameterValues("nomineeCustomerID[]");
            String[] nomineeSalutations = request.getParameterValues("nomineeSalutation[]");
            String[] nomineeNames = request.getParameterValues("nomineeName[]");
            String[] nomineeRelations = request.getParameterValues("nomineeRelation[]");
            String[] nomineeAddress1 = request.getParameterValues("nomineeAddress1[]");
            String[] nomineeAddress2 = request.getParameterValues("nomineeAddress2[]");
            String[] nomineeAddress3 = request.getParameterValues("nomineeAddress3[]");
            String[] nomineeCities = request.getParameterValues("nomineeCity[]");
            String[] nomineeStates = request.getParameterValues("nomineeState[]");
            String[] nomineeCountries = request.getParameterValues("nomineeCountry[]");
            String[] nomineeZips = request.getParameterValues("nomineeZip[]");

            if (nomineeNames != null && nomineeNames.length > 0) {
                String nomineeSQL = "INSERT INTO APPLICATION.APPLICATIONNOMINEE (" +
                    "APPLICATION_NUMBER, SERIAL_NUMBER, SALUTATION_CODE, NAME, " +
                    "RELATION_ID, ADDRESS1, ADDRESS2, ADDRESS3, CITY_CODE, " +
                    "STATE_CODE, COUNTRY_CODE, ZIP" +
                    ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

                psNominee = conn.prepareStatement(nomineeSQL);

                for (int i = 0; i < nomineeNames.length; i++) {
                    // Skip if name is empty
                    if (nomineeNames[i] == null || nomineeNames[i].trim().isEmpty()) {
                        System.out.println("⚠️ Skipping nominee " + (i+1) + " - empty name");
                        continue;
                    }
                    
                    // ✅ FIX: Validate salutation before inserting
                    String salutation = nomineeSalutations != null && i < nomineeSalutations.length ? nomineeSalutations[i] : null;
                    if (salutation == null || salutation.trim().isEmpty()) {
                        System.out.println("⚠️ Skipping nominee " + (i+1) + " (" + nomineeNames[i] + ") - no salutation provided");
                        continue;
                    }
                    
                    System.out.println("✅ Processing nominee " + (i+1) + ": " + nomineeNames[i] + " with salutation: " + salutation);
                    
                    psNominee.setString(1, applicationNumber);
                    psNominee.setInt(2, i + 1);
                    psNominee.setString(3, salutation);
                    psNominee.setString(4, nomineeNames[i]);
                    
                    Integer relationId = nomineeRelations != null && i < nomineeRelations.length ? parseInt(nomineeRelations[i]) : null;
                    if (relationId != null) {
                        psNominee.setInt(5, relationId);
                    } else {
                        psNominee.setNull(5, java.sql.Types.INTEGER);
                    }
                    
                    psNominee.setString(6, nomineeAddress1 != null && i < nomineeAddress1.length ? nomineeAddress1[i] : null);
                    psNominee.setString(7, nomineeAddress2 != null && i < nomineeAddress2.length ? nomineeAddress2[i] : null);
                    psNominee.setString(8, nomineeAddress3 != null && i < nomineeAddress3.length ? nomineeAddress3[i] : null);
                    psNominee.setString(9, nomineeCities != null && i < nomineeCities.length ? nomineeCities[i] : null);
                    psNominee.setString(10, nomineeStates != null && i < nomineeStates.length ? nomineeStates[i] : null);
                    psNominee.setString(11, nomineeCountries != null && i < nomineeCountries.length ? nomineeCountries[i] : null);
                    
                    Integer zip = nomineeZips != null && i < nomineeZips.length ? parseInt(nomineeZips[i]) : null;
                    if (zip != null) {
                        psNominee.setInt(12, zip);
                    } else {
                        psNominee.setNull(12, java.sql.Types.INTEGER);
                    }

                    psNominee.addBatch();
                }

                int[] nomineeRows = psNominee.executeBatch();
                System.out.println("Nominees inserted: " + nomineeRows.length + " row(s)");
            }

            // ========== 3. INSERT JOINT HOLDER DETAILS ==========
            String[] jointCustomerIDs = request.getParameterValues("jointCustomerID[]");
            String[] jointSalutations = request.getParameterValues("jointSalutation[]");
            String[] jointNames = request.getParameterValues("jointName[]");
            String[] jointAddress1 = request.getParameterValues("jointAddress1[]");
            String[] jointAddress2 = request.getParameterValues("jointAddress2[]");
            String[] jointAddress3 = request.getParameterValues("jointAddress3[]");
            String[] jointCities = request.getParameterValues("jointCity[]");
            String[] jointStates = request.getParameterValues("jointState[]");
            String[] jointCountries = request.getParameterValues("jointCountry[]");
            String[] jointZips = request.getParameterValues("jointZip[]");

            System.out.println("📌 Joint Holder Debug:");
            System.out.println("   - jointNames length: " + (jointNames != null ? jointNames.length : "null"));
            System.out.println("   - jointSalutations length: " + (jointSalutations != null ? jointSalutations.length : "null"));

            if (jointNames != null && jointNames.length > 0) {
                String jointSQL = "INSERT INTO APPLICATION.APPLICATIONJOINTHOLDER (" +
                    "APPLICATION_NUMBER, SERIAL_NUMBER, SALUTATION_CODE, NAME, " +
                    "ADDRESS1, ADDRESS2, ADDRESS3, CITY_CODE, STATE_CODE, " +
                    "COUNTRY_CODE, ZIP, CUSTOMER_ID" +
                    ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

                psJoint = conn.prepareStatement(jointSQL);
                int validJointCount = 0;

                for (int i = 0; i < jointNames.length; i++) {
                    // Skip if name is empty
                    if (jointNames[i] == null || jointNames[i].trim().isEmpty()) {
                        System.out.println("⚠️ Skipping joint holder " + (i+1) + " - empty name");
                        continue;
                    }
                    
                    // ✅ FIX: Validate salutation before inserting
                    String salutation = jointSalutations != null && i < jointSalutations.length ? jointSalutations[i] : null;
                    if (salutation == null || salutation.trim().isEmpty()) {
                        System.out.println("⚠️ Skipping joint holder " + (i+1) + " (" + jointNames[i] + ") - no salutation provided");
                        continue;
                    }
                    
                    System.out.println("✅ Processing joint holder " + (i+1) + ": " + jointNames[i] + " with salutation: " + salutation);
                    
                    psJoint.setString(1, applicationNumber);
                    psJoint.setInt(2, i + 1);
                    psJoint.setString(3, salutation);
                    psJoint.setString(4, jointNames[i]);
                    psJoint.setString(5, jointAddress1 != null && i < jointAddress1.length ? jointAddress1[i] : null);
                    psJoint.setString(6, jointAddress2 != null && i < jointAddress2.length ? jointAddress2[i] : null);
                    psJoint.setString(7, jointAddress3 != null && i < jointAddress3.length ? jointAddress3[i] : null);
                    psJoint.setString(8, jointCities != null && i < jointCities.length ? jointCities[i] : null);
                    psJoint.setString(9, jointStates != null && i < jointStates.length ? jointStates[i] : null);
                    psJoint.setString(10, jointCountries != null && i < jointCountries.length ? jointCountries[i] : null);
                    
                    Integer zip = jointZips != null && i < jointZips.length ? parseInt(jointZips[i]) : null;
                    if (zip != null) {
                        psJoint.setInt(11, zip);
                    } else {
                        psJoint.setNull(11, java.sql.Types.INTEGER);
                    }
                    
                    String custId = jointCustomerIDs != null && i < jointCustomerIDs.length ? jointCustomerIDs[i] : null;
                    if (custId != null && !custId.trim().isEmpty()) {
                        psJoint.setString(12, custId);
                    } else {
                        psJoint.setNull(12, java.sql.Types.VARCHAR);
                    }

                    psJoint.addBatch();
                    validJointCount++;
                }

                if (validJointCount > 0) {
                    int[] jointRows = psJoint.executeBatch();
                    System.out.println("Joint Holders inserted: " + jointRows.length + " row(s)");
                } else {
                    System.out.println("No valid joint holders to insert");
                }
            }

            conn.commit();
            System.out.println("✅ Transaction committed successfully!");

            response.sendRedirect("savingAcc.jsp?status=success&applicationNumber=" + applicationNumber);

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                    System.out.println("❌ Transaction rolled back due to error");
                } catch (Exception rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            
            System.out.println("ERROR: " + e.getMessage());
            e.printStackTrace();
            String errorMsg = e.getMessage().replace("'", "\\'");
            response.sendRedirect("savingAcc.jsp?status=error&message=" + 
                java.net.URLEncoder.encode(errorMsg, "UTF-8") + 
                "&productCode=" + productCode);
        } finally {
            try { if (psApp != null) psApp.close(); } catch (Exception ignored) {}
            try { if (psNominee != null) psNominee.close(); } catch (Exception ignored) {}
            try { if (psJoint != null) psJoint.close(); } catch (Exception ignored) {}
            try { 
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close(); 
                }
            } catch (Exception ignored) {}
        }
    }
}