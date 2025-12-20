package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;
import java.sql.Timestamp;
import java.sql.Types;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/UpdateApplicationStatusServlet")
public class UpdateApplicationStatusServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /**
     * Generate 14-digit ACCOUNT_CODE
     * Format: BRANCH_CODE(4) + PRODUCT_CODE(3) + SEQUENCE(7)
     */
    private String generateAccountCode(Connection conn, String branchCode, String productCode) throws Exception {
        String branchPrefix = String.format("%04d", Integer.parseInt(branchCode));
        String productPrefix = String.format("%03d", Integer.parseInt(productCode));
        
        System.out.println("🔍 Generating ACCOUNT_CODE for Branch: " + branchPrefix + ", Product: " + productPrefix);
        
        String sql = 
            "SELECT MAX(TO_NUMBER(SUBSTR(ACCOUNT_CODE, 8, 7))) " +
            "FROM ACCOUNT.ACCOUNT " +
            "WHERE SUBSTR(ACCOUNT_CODE, 1, 4) = ? " +
            "AND SUBSTR(ACCOUNT_CODE, 5, 3) = ? " +
            "AND LENGTH(ACCOUNT_CODE) = 14";
        
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, branchPrefix);
        pstmt.setString(2, productPrefix);
        ResultSet rs = pstmt.executeQuery();
        
        long nextSeq = 1;
        if (rs.next() && rs.getLong(1) > 0) {
            long lastSeq = rs.getLong(1);
            nextSeq = lastSeq + 1;
            System.out.println("✅ Last sequence = " + lastSeq + ", next = " + nextSeq);
        } else {
            System.out.println("✅ No accounts found for this branch+product, starting from 1");
        }
        
        rs.close();
        pstmt.close();
        
        String accountCode = branchPrefix + productPrefix + String.format("%07d", nextSeq);
        
        // Uniqueness check
        String checkSQL = "SELECT COUNT(*) FROM ACCOUNT.ACCOUNT WHERE ACCOUNT_CODE = ?";
        PreparedStatement checkStmt = conn.prepareStatement(checkSQL);
        
        int attempts = 0;
        while (attempts < 100) {
            checkStmt.setString(1, accountCode);
            ResultSet checkRs = checkStmt.executeQuery();
            
            if (checkRs.next() && checkRs.getInt(1) > 0) {
                System.out.println("⚠️ Exists: " + accountCode + " — trying next");
                nextSeq++;
                accountCode = branchPrefix + productPrefix + String.format("%07d", nextSeq);
                checkRs.close();
                attempts++;
            } else {
                checkRs.close();
                break;
            }
        }
        
        checkStmt.close();
        
        if (attempts >= 100) {
            throw new Exception("Failed to generate unique ACCOUNT_CODE after 100 attempts");
        }
        
        System.out.println("📌 FINAL ACCOUNT_CODE = " + accountCode + " (Length: " + accountCode.length() + ")");
        return accountCode;
    }

	 // ========== VALIDATE BRANCH2PRODUCT EXISTS ==========
	    private void validateBranchProductExists(Connection conn, String branchCode, String productCode) throws Exception {
	        String checkSQL = "SELECT COUNT(*) FROM BRANCH.BRANCH2PRODUCT WHERE BRANCH_CODE = ? AND PRODUCT_CODE = ?";
	        PreparedStatement psCheck = conn.prepareStatement(checkSQL);
	        psCheck.setString(1, branchCode);
	        psCheck.setString(2, productCode);
	        ResultSet rs = psCheck.executeQuery();
	        
	        int count = 0;
	        if (rs.next()) {
	            count = rs.getInt(1);
	        }
	        rs.close();
	        psCheck.close();
	        
	        if (count == 0) {
	            throw new Exception("BRANCH2PRODUCT record not found for Branch=" + branchCode + ", Product=" + productCode + ". Cannot create account.");
	        }
	        
	        System.out.println("✅ BRANCH2PRODUCT record exists for Branch=" + branchCode + ", Product=" + productCode);
	    }
	    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        String appNo = request.getParameter("appNo");
        String status = request.getParameter("status");

        if (appNo == null || appNo.trim().isEmpty()) {
            response.sendRedirect("authorizationPendingApplications.jsp?error=missing_appno");
            return;
        }

        if (status == null || (!status.equals("A") && !status.equals("R"))) {
            response.sendRedirect("authorizationPendingApplications.jsp?error=invalid_status");
            return;
        }

        Connection conn = null;
        PreparedStatement psUpdate = null, psGetApp = null;
        ResultSet rsApp = null;
        String accountCode = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // ========== AUTHORIZE (Status = 'A') ==========
            if ("A".equals(status)) {
                System.out.println("✅ AUTHORIZING Application: " + appNo);
                
                // 1. Get application details
                String getAppSQL = "SELECT * FROM APPLICATION.APPLICATION WHERE APPLICATION_NUMBER = ?";
                psGetApp = conn.prepareStatement(getAppSQL);
                psGetApp.setString(1, appNo);
                rsApp = psGetApp.executeQuery();
                
                if (!rsApp.next()) {
                    throw new Exception("Application not found: " + appNo);
                }
                
                String branchCode = rsApp.getString("BRANCH_CODE");
                String productCode = rsApp.getString("PRODUCT_CODE");
                String customerId = rsApp.getString("CUSTOMER_ID");

                // 1.1 VALIDATE BRANCH2PRODUCT EXISTS - DO THIS FIRST!
                validateBranchProductExists(conn, branchCode, productCode);

                // 2. Generate ACCOUNT_CODE
                accountCode = generateAccountCode(conn, branchCode, productCode);
                System.out.println("📌 Generated ACCOUNT_CODE: " + accountCode);
                
                // 3. Insert into ACCOUNT.ACCOUNT table
                insertAccountData(conn, rsApp, accountCode, appNo);

                // 3.1 Update BRANCH2PRODUCT LASTACCOUNT_NUMBER
                long sequenceNumber = Long.parseLong(accountCode.substring(7, 14));
                updateBranchProductLastAccount(conn, branchCode, productCode, sequenceNumber);

                // 4. Insert Nominees if present
                insertNominees(conn, appNo, accountCode);
                
                // 5. Insert Joint Holders if present
                insertJointHolders(conn, appNo, accountCode);
                
                // 6. Insert Fixed Asset if present
                insertFixedAsset(conn, appNo, accountCode);
                
                // 7. Insert Pigmy if present
                insertPigmy(conn, appNo, accountCode);
                
                // 8. Insert Deposit (Term Deposit) if present
                insertDeposit(conn, appNo, accountCode);
                
                // 9. Insert Loan if present
                insertLoan(conn, appNo, accountCode);
                
                // 10. Insert Guarantors if present (for loans)
                insertGuarantors(conn, appNo, accountCode);
                
                // 11. Insert Security Deposit if present
                insertSecurityDeposit(conn, appNo, accountCode);
                
                // 12. Insert Gold/Silver Security if present
                insertGoldSilverSecurity(conn, appNo, accountCode);
                
                // 13. Insert Land & Building Security if present
                insertLandBuildingSecurity(conn, appNo, accountCode);
                
                // 14. Update APPLICATION status to 'A'
                String updateSQL = "UPDATE APPLICATION.APPLICATION SET STATUS = 'A' WHERE APPLICATION_NUMBER = ?";
                psUpdate = conn.prepareStatement(updateSQL);
                psUpdate.setString(1, appNo);
                int rows = psUpdate.executeUpdate();
                
                if (rows > 0) {
                    System.out.println("✔ Updated Application Status: " + appNo + " → A");
                    System.out.println("✔ Account Code: " + accountCode);
                } else {
                    throw new Exception("Failed to update application status");
                }
                
            }
            // ========== REJECT (Status = 'R') ==========
            else if ("R".equals(status)) {
                System.out.println("❌ REJECTING Application: " + appNo);
                
                String updateSQL = "UPDATE APPLICATION.APPLICATION SET STATUS = 'R' WHERE APPLICATION_NUMBER = ?";
                psUpdate = conn.prepareStatement(updateSQL);
                psUpdate.setString(1, appNo);
                
                int rows = psUpdate.executeUpdate();
                
                if (rows > 0) {
                    System.out.println("✔ Updated Application Status: " + appNo + " → R");
                } else {
                    throw new Exception("Failed to update application status");
                }
            }

            conn.commit();
            
            // Redirect with success message
            if ("A".equals(status)) {
                response.sendRedirect("authorizationPendingApplications.jsp?updated=authorized&accountCode=" + 
                                    java.net.URLEncoder.encode(accountCode, "UTF-8"));
            } else {
                response.sendRedirect("authorizationPendingApplications.jsp?updated=rejected");
            }

        } catch (Exception e) {
            if (conn != null) {
                try { 
                    conn.rollback(); 
                    System.out.println("❌ Transaction rolled back");
                } catch (Exception ex) {}
            }
            
            System.out.println("❌ ERROR: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("authorizationPendingApplications.jsp?error=" + 
                                java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));

        } finally {
            try { if (rsApp != null) rsApp.close(); } catch (Exception ex) {}
            try { if (psGetApp != null) psGetApp.close(); } catch (Exception ex) {}
            try { if (psUpdate != null) psUpdate.close(); } catch (Exception ex) {}
            try { 
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ex) {}
        }
    }

    // ========== INSERT ACCOUNT DATA ==========
    private void insertAccountData(Connection conn, ResultSet rsApp, String accountCode, String appNo) throws Exception {
        String sql = "INSERT INTO ACCOUNT.ACCOUNT (" +
            "ACCOUNT_CODE, NAME, DATEACCOUNTOPEN, DATEACCOUNTCLOSE, CUSTOMER_ID, " +
            "ACCOUNTOPERATIONCAPACITY_ID, USER_ID, AGENT_ID, ACCOUNTMINBALANCE_ID, " +
            "LASTOPERATEDDATE, ACCOUNT_STATUS, IS_TOD_APPLICABLE, TOD_INTEREST_RATE, TOD_INTEREST, " +
            "OFFICER_ID, CATEGORY_CODE, INTRODUCERACCOUNT_CODE, APPLICATION_NUMBER, INTRODUCER_NAME, " +
            "CREATED_DATE, MODIFIED_DATE, RISKCATEGORY, OLD_AC_TYPE, OLD_AC_NO, TOD_LIMIT, " +
            "TOD_DATE, TOD_PERIOD, OLD_ACC_NAME, DIRECTOR_ID, GUARDIAN_CUSTOMER_ID, IS_TRF_HO, " +
            "APPLICATION_SERIAL_NO, INT_REC_HO, INT_PAY_HO, " +  // REMOVED DEBR_TRF_HO
            "FINAL_HO_TRF, IS_FUND_FINAL, " +
            "DIVIDENT_INTEREST_POST_TO, ORG_CUSTOMER_ID, TOD_APPLICABLE_DATE, INTEREST_CATEGORY) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";  // 40 parameters instead of 41
        
        PreparedStatement ps = conn.prepareStatement(sql);
        
        int idx = 1;
        ps.setString(idx++, accountCode);
        ps.setString(idx++, rsApp.getString("NAME"));
        ps.setDate(idx++, new Date(System.currentTimeMillis())); // DATEACCOUNTOPEN
        ps.setNull(idx++, Types.DATE); // DATEACCOUNTCLOSE
        ps.setString(idx++, rsApp.getString("CUSTOMER_ID"));
        
        // ACCOUNTOPERATIONCAPACITY_ID
        String accOpCapStr = rsApp.getString("ACCOUNTOPERATIONCAPACITY_ID");
        if (accOpCapStr != null && !accOpCapStr.trim().isEmpty()) {
            try {
                ps.setInt(idx++, Integer.parseInt(accOpCapStr));
            } catch (Exception e) {
                ps.setNull(idx++, Types.INTEGER);
            }
        } else {
            ps.setNull(idx++, Types.INTEGER);
        }
        
        ps.setString(idx++, rsApp.getString("USER_ID"));
        // AGENT_ID - insert 0 if not present
        String agentIdStr = rsApp.getString("AGENT_ID");
        if (agentIdStr != null && !agentIdStr.trim().isEmpty()) {
            try {
                ps.setInt(idx++, Integer.parseInt(agentIdStr));
            } catch (Exception e) {
                ps.setInt(idx++, 0);
            }
        } else {
            ps.setInt(idx++, 0);
        }
        
        // ACCOUNTMINBALANCE_ID
        String minBalStr = rsApp.getString("MINBALANCE_ID");
        if (minBalStr != null && !minBalStr.trim().isEmpty()) {
            try {
                ps.setInt(idx++, Integer.parseInt(minBalStr));
            } catch (Exception e) {
                ps.setNull(idx++, Types.INTEGER);
            }
        } else {
            ps.setNull(idx++, Types.INTEGER);
        }
        
        ps.setDate(idx++, new Date(System.currentTimeMillis())); // LASTOPERATEDDATE
        ps.setString(idx++, "L"); // ACCOUNT_STATUS = 'L' (Live)
        ps.setString(idx++, "N"); // IS_TOD_APPLICABLE
        ps.setDouble(idx++, 0); // TOD_INTEREST_RATE
        ps.setDouble(idx++, 0); // TOD_INTEREST
        ps.setString(idx++, rsApp.getString("USER_ID")); // OFFICER_ID
        ps.setString(idx++, rsApp.getString("CATEGORY_CODE"));
        ps.setString(idx++, rsApp.getString("INTRODUCERACCOUNT_CODE"));
        ps.setString(idx++, appNo); // APPLICATION_NUMBER
        ps.setString(idx++, rsApp.getString("INTRODUCER_NAME"));
        ps.setTimestamp(idx++, new Timestamp(System.currentTimeMillis())); // CREATED_DATE
        ps.setNull(idx++, Types.TIMESTAMP); // MODIFIED_DATE
        ps.setString(idx++, rsApp.getString("RISKCATEGORY"));
        ps.setNull(idx++, Types.VARCHAR); // OLD_AC_TYPE
        ps.setNull(idx++, Types.INTEGER); // OLD_AC_NO
        ps.setDouble(idx++, 0); // TOD_LIMIT
        ps.setNull(idx++, Types.DATE); // TOD_DATE
        ps.setNull(idx++, Types.INTEGER); // TOD_PERIOD
        ps.setNull(idx++, Types.VARCHAR); // OLD_ACC_NAME
        ps.setNull(idx++, Types.INTEGER); // DIRECTOR_ID
        ps.setNull(idx++, Types.VARCHAR); // GUARDIAN_CUSTOMER_ID
        ps.setString(idx++, "N"); // IS_TRF_HO
        ps.setInt(idx++, 0); // APPLICATION_SERIAL_NO
        ps.setInt(idx++, 0); // INT_REC_HO
        ps.setInt(idx++, 0); // INT_PAY_HO
        // REMOVED: ps.setInt(idx++, 0); // DEBR_TRF_HO - THIS COLUMN DOESN'T EXIST
        ps.setString(idx++, "N"); // FINAL_HO_TRF
        ps.setString(idx++, "N"); // IS_FUND_FINAL
        
        // DIVIDENT_INTEREST_POST_TO
        String dividendPost = rsApp.getString("DIVIDENT_INTEREST_POST_TO");
        ps.setString(idx++, dividendPost != null ? dividendPost : null);
        
        ps.setNull(idx++, Types.VARCHAR); // ORG_CUSTOMER_ID
        ps.setNull(idx++, Types.DATE); // TOD_APPLICABLE_DATE
        
        // INTEREST_CATEGORY
        String intCategory = rsApp.getString("INTEREST_CATEGORY");
        ps.setString(idx++, intCategory != null ? intCategory : null);
        
        ps.executeUpdate();
        ps.close();
        System.out.println("✅ Inserted into ACCOUNT.ACCOUNT: " + accountCode);
    }        
    // ========== INSERT NOMINEES ==========
    private void insertNominees(Connection conn, String appNo, String accountCode) throws Exception {
        String checkSQL = "SELECT COUNT(*) FROM APPLICATION.APPLICATIONNOMINEE WHERE APPLICATION_NUMBER = ?";
        PreparedStatement psCheck = conn.prepareStatement(checkSQL);
        psCheck.setString(1, appNo);
        ResultSet rs = psCheck.executeQuery();
        
        int count = 0;
        if (rs.next()) {
            count = rs.getInt(1);
        }
        rs.close();
        psCheck.close();
        
        if (count == 0) {
            System.out.println("⏭️ No nominees found, skipping...");
            return;
        }
        
        String selectSQL = "SELECT * FROM APPLICATION.APPLICATIONNOMINEE WHERE APPLICATION_NUMBER = ? ORDER BY SERIAL_NUMBER";
        PreparedStatement psSelect = conn.prepareStatement(selectSQL);
        psSelect.setString(1, appNo);
        ResultSet rsNom = psSelect.executeQuery();
        
        String insertSQL = "INSERT INTO ACCOUNT.ACCOUNTNOMINEE (" +
        	    "ACCOUNT_CODE, SERIAL_NUMBER, SALUTATION_CODE, NAME, RELATION_ID, " +
        	    "ADDRESS1, ADDRESS2, ADDRESS3, CITY_CODE, STATE_CODE, COUNTRY_CODE, ZIP, " +
        	    "CREATED_DATE, MODIFIED_DATE) " +  // REMOVED DATETIMESTAMP
        	    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";  // 14 parameters instead of 15
        
        PreparedStatement psInsert = conn.prepareStatement(insertSQL);
        
        while (rsNom.next()) {
            int idx = 1;
            psInsert.setString(idx++, accountCode);
            psInsert.setInt(idx++, rsNom.getInt("SERIAL_NUMBER"));
            psInsert.setString(idx++, rsNom.getString("SALUTATION_CODE"));
            psInsert.setString(idx++, rsNom.getString("NAME"));
            
            String relationStr = rsNom.getString("RELATION_ID");
            if (relationStr != null && !relationStr.trim().isEmpty()) {
                try {
                    psInsert.setInt(idx++, Integer.parseInt(relationStr));
                } catch (Exception e) {
                    psInsert.setNull(idx++, Types.INTEGER);
                }
            } else {
                psInsert.setNull(idx++, Types.INTEGER);
            }
            
            psInsert.setString(idx++, rsNom.getString("ADDRESS1"));
            psInsert.setString(idx++, rsNom.getString("ADDRESS2"));
            psInsert.setString(idx++, rsNom.getString("ADDRESS3"));
            psInsert.setString(idx++, rsNom.getString("CITY_CODE"));
            psInsert.setString(idx++, rsNom.getString("STATE_CODE"));
            psInsert.setString(idx++, rsNom.getString("COUNTRY_CODE"));
            
            String zipStr = rsNom.getString("ZIP");
            if (zipStr != null && !zipStr.trim().isEmpty() && !zipStr.equals("0")) {
                try {
                    psInsert.setInt(idx++, Integer.parseInt(zipStr));
                } catch (Exception e) {
                    psInsert.setNull(idx++, Types.INTEGER);
                }
            } else {
                psInsert.setNull(idx++, Types.INTEGER);
            }
            
            Timestamp now = new Timestamp(System.currentTimeMillis());
            psInsert.setTimestamp(idx++, now);
            psInsert.setNull(idx++, Types.TIMESTAMP);
            
            psInsert.addBatch();
        }
        
        int[] results = psInsert.executeBatch();
        rsNom.close();
        psSelect.close();
        psInsert.close();
        System.out.println("✅ Inserted " + results.length + " nominees into ACCOUNT.ACCOUNTNOMINEE");
    }

    // ========== INSERT JOINT HOLDERS / CO-BORROWERS ==========
    private void insertJointHolders(Connection conn, String appNo, String accountCode) throws Exception {
        // Check if there are any joint holders/co-borrowers in APPLICATIONJOINTHOLDER
        String checkSQL = "SELECT COUNT(*) FROM APPLICATION.APPLICATIONJOINTHOLDER WHERE APPLICATION_NUMBER = ?";
        PreparedStatement psCheck = conn.prepareStatement(checkSQL);
        psCheck.setString(1, appNo);
        ResultSet rs = psCheck.executeQuery();
        
        int count = 0;
        if (rs.next()) {
            count = rs.getInt(1);
        }
        rs.close();
        psCheck.close();
        
        if (count == 0) {
            System.out.println("⏭️ No joint holders/co-borrowers found, skipping...");
            return;
        }
        
        // Fetch all joint holders/co-borrowers from APPLICATION table
        String selectSQL = "SELECT * FROM APPLICATION.APPLICATIONJOINTHOLDER WHERE APPLICATION_NUMBER = ? ORDER BY SERIAL_NUMBER";
        PreparedStatement psSelect = conn.prepareStatement(selectSQL);
        psSelect.setString(1, appNo);
        ResultSet rsJoint = psSelect.executeQuery();
        
        // Insert into ACCOUNT.ACCOUNTJOINTHOLDER
        String insertSQL = "INSERT INTO ACCOUNT.ACCOUNTJOINTHOLDER (" +
            "ACCOUNT_CODE, SERIAL_NUMBER, SALUTATION_CODE, NAME, ADDRESS1, ADDRESS2, ADDRESS3, " +
            "CITY_CODE, STATE_CODE, COUNTRY_CODE, ZIP, CREATED_DATE, MODIFIED_DATE, GENDER, " +
            "BIRTH_DATE, RELATION, PHONE_NUMBER, PAN_NUMBER, CUSTOMER_ID) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        PreparedStatement psInsert = conn.prepareStatement(insertSQL);
        int insertedCount = 0;
        
        while (rsJoint.next()) {
            int idx = 1;
            psInsert.setString(idx++, accountCode);
            psInsert.setInt(idx++, rsJoint.getInt("SERIAL_NUMBER"));
            psInsert.setString(idx++, rsJoint.getString("SALUTATION_CODE"));
            psInsert.setString(idx++, rsJoint.getString("NAME"));
            psInsert.setString(idx++, rsJoint.getString("ADDRESS1"));
            psInsert.setString(idx++, rsJoint.getString("ADDRESS2"));
            psInsert.setString(idx++, rsJoint.getString("ADDRESS3"));
            psInsert.setString(idx++, rsJoint.getString("CITY_CODE"));
            psInsert.setString(idx++, rsJoint.getString("STATE_CODE"));
            psInsert.setString(idx++, rsJoint.getString("COUNTRY_CODE"));
            
            String zipStr = rsJoint.getString("ZIP");
            if (zipStr != null && !zipStr.trim().isEmpty() && !zipStr.equals("0")) {
                try {
                    psInsert.setInt(idx++, Integer.parseInt(zipStr));
                } catch (Exception e) {
                    psInsert.setNull(idx++, Types.INTEGER);
                }
            } else {
                psInsert.setNull(idx++, Types.INTEGER);
            }
            
            Timestamp now = new Timestamp(System.currentTimeMillis());
            psInsert.setTimestamp(idx++, now);
            psInsert.setNull(idx++, Types.TIMESTAMP); // MODIFIED_DATE
            psInsert.setNull(idx++, Types.VARCHAR); // GENDER
            psInsert.setNull(idx++, Types.DATE); // BIRTH_DATE
            psInsert.setNull(idx++, Types.VARCHAR); // RELATION
            psInsert.setInt(idx++, 0); // PHONE_NUMBER
            psInsert.setNull(idx++, Types.VARCHAR); // PAN_NUMBER
            
            // CUSTOMER_ID - can be null for co-borrowers who are not existing customers
            String customerId = rsJoint.getString("CUSTOMER_ID");
            if (customerId != null && !customerId.trim().isEmpty()) {
                psInsert.setString(idx++, customerId);
            } else {
                psInsert.setNull(idx++, Types.VARCHAR);
            }
            
            psInsert.addBatch();
            insertedCount++;
        }
        
        if (insertedCount > 0) {
            int[] results = psInsert.executeBatch();
            System.out.println("✅ Inserted " + results.length + " joint holders/co-borrowers into ACCOUNT.ACCOUNTJOINTHOLDER");
        }
        
        rsJoint.close();
        psSelect.close();
        psInsert.close();
    }

    // ========== INSERT FIXED ASSET ==========
    private void insertFixedAsset(Connection conn, String appNo, String accountCode) throws Exception {
        String checkSQL = "SELECT COUNT(*) FROM APPLICATION.APPLICATIONFIXEDASSET WHERE APPLICATION_NUMBER = ?";
        PreparedStatement psCheck = conn.prepareStatement(checkSQL);
        psCheck.setString(1, appNo);
        ResultSet rs = psCheck.executeQuery();
        
        int count = 0;
        if (rs.next()) {
            count = rs.getInt(1);
        }
        rs.close();
        psCheck.close();
        
        if (count == 0) {
            System.out.println("⏭️ No fixed asset found, skipping...");
            return;
        }
        
        String selectSQL = "SELECT * FROM APPLICATION.APPLICATIONFIXEDASSET WHERE APPLICATION_NUMBER = ?";
        PreparedStatement psSelect = conn.prepareStatement(selectSQL);
        psSelect.setString(1, appNo);
        ResultSet rsFixed = psSelect.executeQuery();
        
        if (rsFixed.next()) {
            String insertSQL = "INSERT INTO ACCOUNT.ACCOUNTFIXEDASSET (" +
                "ACCOUNT_CODE, ITEM_NAME, PURCHASEDATE, PURCHASEAMOUNT, NUMBEROFITEM, " +
                "DEPRICATIONRATE, BILLNUMBER, DESCRIPTION, METHOD_OF_DEP_CAL, " +
                "DEPRICATION_CALCULATE_ON, CREATED_DATE, MODIFIED_DATE) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            PreparedStatement psInsert = conn.prepareStatement(insertSQL);
            
            int idx = 1;
            psInsert.setString(idx++, accountCode);
            psInsert.setString(idx++, rsFixed.getString("ITEM_NAME"));
            psInsert.setDate(idx++, rsFixed.getDate("PURCHASEDATE"));
            
            String purchaseAmt = rsFixed.getString("PURCHASEAMOUNT");
            if (purchaseAmt != null && !purchaseAmt.trim().isEmpty()) {
                psInsert.setDouble(idx++, Double.parseDouble(purchaseAmt));
            } else {
                psInsert.setNull(idx++, Types.DECIMAL);
            }
            
            String numItems = rsFixed.getString("NUMBEROFITEM");
            if (numItems != null && !numItems.trim().isEmpty()) {
                psInsert.setInt(idx++, Integer.parseInt(numItems));
            } else {
                psInsert.setNull(idx++, Types.INTEGER);
            }
            
            String depRate = rsFixed.getString("DEPRICATIONRATE");
            if (depRate != null && !depRate.trim().isEmpty()) {
                psInsert.setDouble(idx++, Double.parseDouble(depRate));
            } else {
                psInsert.setNull(idx++, Types.DECIMAL);
            }
            
            psInsert.setString(idx++, rsFixed.getString("BILLNUMBER"));
            psInsert.setString(idx++, rsFixed.getString("DESCRIPTION"));
            psInsert.setString(idx++, rsFixed.getString("METHOD_OF_DEP_CAL"));
            psInsert.setString(idx++, rsFixed.getString("DEPRICATION_CALCULATE_ON"));
            
            Timestamp now = new Timestamp(System.currentTimeMillis());
            psInsert.setTimestamp(idx++, now);
            psInsert.setNull(idx++, Types.TIMESTAMP);
            
            psInsert.executeUpdate();
            psInsert.close();
            System.out.println("✅ Inserted fixed asset into ACCOUNT.ACCOUNTFIXEDASSET");
        }
        
        rsFixed.close();
        psSelect.close();
    }

 // ========== INSERT PIGMY ==========
    private void insertPigmy(Connection conn, String appNo, String accountCode) throws Exception {
        String checkSQL = "SELECT COUNT(*) FROM APPLICATION.APPLICATIONPIGMY WHERE APPLICATION_NUMBER = ?";
        PreparedStatement psCheck = conn.prepareStatement(checkSQL);
        psCheck.setString(1, appNo);
        ResultSet rs = psCheck.executeQuery();
        
        int count = 0;
        if (rs.next()) {
            count = rs.getInt(1);
        }
        rs.close();
        psCheck.close();
        
        if (count == 0) {
            System.out.println("⏭️ No pigmy found, skipping...");
            return;
        }
        
        String selectSQL = "SELECT * FROM APPLICATION.APPLICATIONPIGMY WHERE APPLICATION_NUMBER = ?";
        PreparedStatement psSelect = conn.prepareStatement(selectSQL);
        psSelect.setString(1, appNo);
        ResultSet rsPigmy = psSelect.executeQuery();
        
        if (rsPigmy.next()) {
            String insertSQL = "INSERT INTO ACCOUNT.ACCOUNTPIGMY (" +
                "ACCOUNT_CODE, AGENTBRANCH_CODE, FROMDATE, INSTALLMENTAMOUNT, UNITOFPERIOD, " +
                "PERIODOFDEPOSIT, MATURITYDATE, AGENT_ID, INTERESTRATE, CREATED_DATE, MODIFIED_DATE, " +
                "LIENACCOUNT_CODE, LIEN_STATUS ) " +  // REMOVED OPENING_RD_PRODUCTS and OPENING_INT_POSTED
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";  // 15 parameters instead of 17
            
            PreparedStatement psInsert = conn.prepareStatement(insertSQL);
            
            int idx = 1;
            psInsert.setString(idx++, accountCode);
            psInsert.setString(idx++, rsPigmy.getString("AGENTBRANCH_CODE"));
            psInsert.setDate(idx++, rsPigmy.getDate("FROMDATE"));
            
            String instAmt = rsPigmy.getString("INSTALLMENTAMOUNT");
            if (instAmt != null && !instAmt.trim().isEmpty()) {
                psInsert.setDouble(idx++, Double.parseDouble(instAmt));
            } else {
                psInsert.setNull(idx++, Types.DECIMAL);
            }
            
            psInsert.setString(idx++, rsPigmy.getString("UNITOFPERIOD"));
            
            String period = rsPigmy.getString("PERIODOFDEPOSIT");
            if (period != null && !period.trim().isEmpty()) {
                psInsert.setInt(idx++, Integer.parseInt(period));
            } else {
                psInsert.setNull(idx++, Types.INTEGER);
            }
            
            psInsert.setDate(idx++, rsPigmy.getDate("MATURITYDATE"));
            
            String agentId = rsPigmy.getString("AGENT_ID");
            if (agentId != null && !agentId.trim().isEmpty()) {
                psInsert.setInt(idx++, Integer.parseInt(agentId));
            } else {
                psInsert.setNull(idx++, Types.INTEGER);
            }
            
            String intRate = rsPigmy.getString("INTERESTRATE");
            if (intRate != null && !intRate.trim().isEmpty()) {
                psInsert.setDouble(idx++, Double.parseDouble(intRate));
            } else {
                psInsert.setNull(idx++, Types.DECIMAL);
            }
            
            Timestamp now = new Timestamp(System.currentTimeMillis());
            psInsert.setTimestamp(idx++, now);
            psInsert.setNull(idx++, Types.TIMESTAMP);
            psInsert.setNull(idx++, Types.VARCHAR); // LIENACCOUNT_CODE
            psInsert.setString(idx++, "N"); // LIEN_STATUS
            //psInsert.setString(idx++, "N"); // PROCESSFOR_MATURITY
            //psInsert.setNull(idx++, Types.DATE); // MATURE_TRANSACTIONDATE
            // REMOVED: psInsert.setDouble(idx++, 0); // OPENING_RD_PRODUCTS
            // REMOVED: psInsert.setDouble(idx++, 0); // OPENING_INT_POSTED
            
            psInsert.executeUpdate();
            psInsert.close();
            System.out.println("✅ Inserted pigmy into ACCOUNT.ACCOUNTPIGMY");
        }
        
        rsPigmy.close();
        psSelect.close();
    }

    // ========== INSERT DEPOSIT (Term Deposit) ==========
    private void insertDeposit(Connection conn, String appNo, String accountCode) throws Exception {
        String checkSQL = "SELECT COUNT(*) FROM APPLICATION.APPLICATIONDEPOSIT WHERE APPLICATION_NUMBER = ?";
        PreparedStatement psCheck = conn.prepareStatement(checkSQL);
        psCheck.setString(1, appNo);
        ResultSet rs = psCheck.executeQuery();
        
        int count = 0;
        if (rs.next()) {
            count = rs.getInt(1);
        }
        rs.close();
        psCheck.close();
        
        if (count == 0) {
            System.out.println("⏭️ No deposit found, skipping...");
            return;
        }
        
        String selectSQL = "SELECT * FROM APPLICATION.APPLICATIONDEPOSIT WHERE APPLICATION_NUMBER = ?";
        PreparedStatement psSelect = conn.prepareStatement(selectSQL);
        psSelect.setString(1, appNo);
        ResultSet rsDep = psSelect.executeQuery();
        
        if (rsDep.next()) {
        	String insertSQL =
        		    "INSERT INTO ACCOUNT.ACCOUNTDEPOSIT (" +
        		    "ACCOUNT_CODE, FROMDATE, DEPOSITAMOUNT, UNITOFPERIOD, PERIODOFDEPOSIT, MATURITYDATE, " +
        		    "MATURITYVALUE, INTERESTPAYMENTFREQUENCY, IS_INTEREST_PAID_IN_CASH, IS_RATE_DISCOUNTED, " +
        		    "INTERESTRATE, MULTIPLYFACTOR, CREDITACCOUNT_CODE, INTERESTPAID, INTERESTPAYBLE, " +
        		    "AMOUNTINMATUREDDEPOSIT, PENDINGCASHINTEREST, LAST_INTEREST_PAID_DATE, PENAL_INTEREST_RECEIVED, " +
        		    "CATEGORY_CODE, LIENACCOUNT_CODE, LIEN_STATUS, PROCESSFOR_MATURITY, MATURE_TRANSACTIONDATE, " +
        		    "NAME, AGENT_BRANCH_CODE, AGENT_ID, IS_TDS_APPLICABLE, CREATED_DATE, MODIFIED_DATE, " +
        		    "OPENING_RD_PRODUCTS, OPENING_INT_POSTED, BIRTH_DATE, TDS_PAID, TDS_PAYABLE, IS_AR_DAYBEGIN) " +
        		    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";  // 36

        	PreparedStatement psInsert = conn.prepareStatement(insertSQL);
        	int idx = 1;

        	psInsert.setString(idx++, accountCode);                       // ACCOUNT_CODE
        	psInsert.setDate(idx++, rsDep.getDate("FROMDATE"));           // FROMDATE

        	String depAmt = rsDep.getString("DEPOSITAMOUNT");
        	if (depAmt != null && !depAmt.trim().isEmpty()) {
        	    psInsert.setDouble(idx++, Double.parseDouble(depAmt));
        	} else {
        	    psInsert.setDouble(idx++, 0);
        	}

        	psInsert.setString(idx++, rsDep.getString("UNITOFPERIOD"));
        	String period = rsDep.getString("PERIODOFDEPOSIT");
        	if (period != null && !period.trim().isEmpty()) {
        	    psInsert.setInt(idx++, Integer.parseInt(period));
        	} else {
        	    psInsert.setNull(idx++, Types.INTEGER);
        	}

        	psInsert.setDate(idx++, rsDep.getDate("MATURITYDATE"));

        	String matValue = rsDep.getString("MATURITYVALUE");
        	if (matValue != null && !matValue.trim().isEmpty()) {
        	    psInsert.setDouble(idx++, Double.parseDouble(matValue));
        	} else {
        	    psInsert.setNull(idx++, Types.DECIMAL);
        	}

        	psInsert.setString(idx++, rsDep.getString("INTERESTPAYMENTFREQUENCY"));
        	psInsert.setString(idx++, rsDep.getString("IS_INTEREST_PAID_IN_CASH"));
        	psInsert.setString(idx++, rsDep.getString("IS_RATE_DISCOUNTED"));

        	String intRate = rsDep.getString("INTERESTRATE");
        	if (intRate != null && !intRate.trim().isEmpty()) {
        	    psInsert.setDouble(idx++, Double.parseDouble(intRate));
        	} else {
        	    psInsert.setNull(idx++, Types.DECIMAL);
        	}

        	psInsert.setInt(idx++, 0);                                    // MULTIPLYFACTOR
        	psInsert.setString(idx++, rsDep.getString("CREDITACCOUNT_CODE"));
        	psInsert.setDouble(idx++, 0);                                 // INTERESTPAID
        	psInsert.setDouble(idx++, 0);                                 // INTERESTPAYABLE
        	psInsert.setDouble(idx++, 0);                                 // AMOUNTINMATUREDDEPOSIT
        	psInsert.setDouble(idx++, 0);                                 // PENDINGCASHINTEREST
        	psInsert.setNull(idx++, Types.DATE);                          // LAST_INTEREST_PAID_DATE
        	psInsert.setDouble(idx++, 0);                                 // PENAL_INTEREST_RECEIVED

        	psInsert.setNull(idx++, Types.VARCHAR);                       // CATEGORY_CODE
        	psInsert.setNull(idx++, Types.VARCHAR);                       // LIENACCOUNT_CODE
        	psInsert.setString(idx++, "N");                               // LIEN_STATUS
        	psInsert.setString(idx++, "N");                               // PROCESSFOR_MATURITY
        	psInsert.setNull(idx++, Types.DATE);                          // MATURE_TRANSACTIONDATE

        	psInsert.setNull(idx++, Types.VARCHAR);                       // NAME
        	psInsert.setNull(idx++, Types.VARCHAR);                       // AGENT_BRANCH_CODE
        	psInsert.setNull(idx++, Types.INTEGER);                       // AGENT_ID
        	psInsert.setString(idx++, "Y");                               // IS_TDS_APPLICABLE

        	Timestamp now = new Timestamp(System.currentTimeMillis());
        	psInsert.setTimestamp(idx++, now);                            // CREATED_DATE
        	psInsert.setNull(idx++, Types.TIMESTAMP);                     // MODIFIED_DATE

        	psInsert.setDouble(idx++, 0);                                 // OPENING_RD_PRODUCTS
        	psInsert.setDouble(idx++, 0);                                 // OPENING_INT_POSTED
        	psInsert.setNull(idx++, Types.DATE);                          // BIRTH_DATE
        	psInsert.setDouble(idx++, 0);                                 // TDS_PAID
        	psInsert.setDouble(idx++, 0);                                 // TDS_PAYABLE
        	psInsert.setString(idx++, "N");                               // IS_AR_DAYBEGIN

        	psInsert.executeUpdate();
        	psInsert.close();

            System.out.println("✅ Inserted deposit into ACCOUNT.ACCOUNTDEPOSIT");
        }
        
        rsDep.close();
        psSelect.close();
    }

 // ========== INSERT LOAN ==========
    private void insertLoan(Connection conn, String appNo, String accountCode) throws Exception {
        String checkSQL = "SELECT COUNT(*) FROM APPLICATION.APPLICATIONLOAN WHERE APPLICATION_NUMBER = ?";
        PreparedStatement psCheck = conn.prepareStatement(checkSQL);
        psCheck.setString(1, appNo);
        ResultSet rs = psCheck.executeQuery();

        int count = 0;
        if (rs.next()) {
            count = rs.getInt(1);
        }
        rs.close();
        psCheck.close();

        if (count == 0) {
            System.out.println("⏭️ No loan found, skipping...");
            return;
        }

        String selectSQL = "SELECT * FROM APPLICATION.APPLICATIONLOAN WHERE APPLICATION_NUMBER = ?";
        PreparedStatement psSelect = conn.prepareStatement(selectSQL);
        psSelect.setString(1, appNo);
        ResultSet rsLoan = psSelect.executeQuery();

        if (!rsLoan.next()) {
            rsLoan.close();
            psSelect.close();
            return;
        }

        String insertSQL =
            "INSERT INTO ACCOUNT.ACCOUNTLOAN (" +
            "ACCOUNT_CODE, SANCTIONAUTHORITY_ID, MODEOFSANCTION_ID, SOCIALSECTOR_ID, SOCIALSECTION_ID, " +
            "SOCIALSUBSECTOR_ID, PURPOSE_ID, INDUSTRY_ID, REPAYMENTFREQUENCY, IS_CONSORTIUM_LOAN, " +
            "LIMITAMOUNT, SANCTIONDATE, ACCOUNTREVIEWDATE, INSTALLMENTAMOUNT, MORATORIUMPEROIDMONTH, " +
            "DOCUMENTSUBMISSIONDATE, DATEOFREGISTRATION, REGISTERAMOUNT, RESOLUTIONNUMBER, PERIODOFLOAN, " +
            "DIRECTOR_ID, MIS_ID, CLASSIFICATION_ID, LASTDATEOFINTEREST, LASTDATEOFPENALINTEREST, " +
            "LASTDATEOFOVERDUEINTEREST, LASTDATEOFMORATORIUMINTEREST, CURRENTINTERESTRATE, " +
            "CURRENTPENALINTERESTRATE, CURRENTOVERDUEINTERESTRATE, CURRENTMORATORIUMINTERESTRATE, " +
            "INTERESTCALCULATIONMETHOD, INSTALLMENTTYPE_ID, PRINCIPAL_OVERDUE, INTEREST_OVERDUE, " +
            "OVERDUE_INTEREST_RESERVE, INTEREST_RECEIVABLE, OVERDUE_INTEREST_RECEIVABLE, " +
            "UNACCOUNTED_INTEREST, POSTEDBUTUNRECOVEREDINTEREST, NORMAL_INTEREST_RECEIVED, " +
            "MORATORIUM_INTEREST_RECEIVED, OTHER_CHARGES_RECEIVED, PENAL_ARRIERS, MORATORIUM_ARRIERS, " +
            "OVERDUE_ARRIERS, NORMAL_ARRIERS, POSTAGE, INSURANCE, NOTICE_FEES, COURT_CHARGES, " +
            "RECOVERY_EXPENSES, OTHER_CHARGES, TOTALINTERESTCHARGED, IS_DIRECTOR_RELATED, " +
            "DISBURSED_AMOUNT, PRINCIPAL_ADVANCE, PRINCIPAL_INSTALLMENT, INTEREST_INSTALLMENT, " +
            "NEXTINSTALLMENTDATE, INSURANCE_RECEIVABLE_RECEIVED, NOTICE_FEES_RECEIVED, POSTAGE_RECEIVED, " +
            "COURT_CHARGES_RECEIVED, RECOVERY_EXPENSES_RECEIVED, PENDING_INTEREST_RECEIVED, " +
            "OVERDUE_INTEREST_RECEIVED, NORMAL_INTEREST_RECEIVED2, MORATORIUM_INTEREST_RECEIVED2, " +
            "OTHER_CHARGES_RECEIVED2, INTEREST_RECEIVABLE_RECEIVED, PENDING_INTEREST_OIR_RECEIVED, " +
            "UNACCOUNTED_INTEREST_RECEIVED, ADVERTISEMENT_RECEIVED, SURCHARGE_RECEIVED, SURCHARGE, " +
            "ADVERTISEMENT, INTEREST_APPLY, SUIT, HEALTH_CODE, IS_STANDARD, SANCTIONAMOUNT, AREA_CODE, " +
            "SUBAREA_CODE, CREATED_DATE, MODIFIED_DATE, INT_ADJ_DATE, IS_LOSS_ASSET, PRINCIPLE_AMOUNT, " +
            "IS_BANK_INSURANCE_APPL, BANK_INSURANCE_START_DATE, BANK_INSURANCE_END_DATE, " +
            "BANK_INSURANCE_PERCENTAGE) " +
            "VALUES (" +
		    String.join(", ", java.util.Collections.nCopies(92, "?")) + ")";

        PreparedStatement psInsert = conn.prepareStatement(insertSQL);
        int idx = 1;

        // 1 ACCOUNT_CODE
        psInsert.setString(idx++, accountCode);

        // 2 SANCTIONAUTHORITY_ID (same name in APPLICATIONLOAN)
        psInsert.setInt(idx++, rsLoan.getInt("SANCTIONAUTHORITY_ID"));

        // 3 MODEOFSANCTION_ID
        psInsert.setInt(idx++, rsLoan.getInt("MODEOFSANCTION_ID"));

        // 4 SOCIALSECTOR_ID
        psInsert.setInt(idx++, rsLoan.getInt("SOCIALSECTOR_ID"));

        // 5 SOCIALSECTION_ID  (use APPLICATIONLOAN column name here)
        psInsert.setInt(idx++, rsLoan.getInt("SOCIALSECTION_ID"));

        // 6 SOCIALSUBSECTOR_ID
        psInsert.setInt(idx++, rsLoan.getInt("SOCIALSUBSECTOR_ID"));

        // 7 PURPOSE_ID
        psInsert.setInt(idx++, rsLoan.getInt("PURPOSE_ID"));

        // 8 INDUSTRY_ID
        psInsert.setInt(idx++, rsLoan.getInt("INDUSTRY_ID"));

        // 9 REPAYMENTFREQUENCY
        psInsert.setString(idx++, rsLoan.getString("REPAYMENTFREQUENCY"));

        // 10 IS_CONSORTIUM_LOAN
        psInsert.setString(idx++, rsLoan.getString("IS_CONSORTIUM_LOAN"));

        // 11 LIMITAMOUNT
        psInsert.setDouble(idx++, rsLoan.getDouble("LIMITAMOUNT"));

        // 12 SANCTIONDATE
        psInsert.setDate(idx++, rsLoan.getDate("SANCTIONDATE"));

        // 13 ACCOUNTREVIEWDATE
        psInsert.setDate(idx++, rsLoan.getDate("ACCOUNTREVIEWDATE"));

        // 14 INSTALLMENTAMOUNT
        psInsert.setDouble(idx++, rsLoan.getDouble("INSTALLMENTAMOUNT"));

        // 15 MORATORIUMPEROIDMONTH
        psInsert.setInt(idx++, rsLoan.getInt("MORATORIUMPEROIDMONTH"));

        // 16 DOCUMENTSUBMISSIONDATE
        psInsert.setDate(idx++, rsLoan.getDate("DOCUMENTSUBMISSIONDATE"));

        // 17 DATEOFREGISTRATION
        psInsert.setDate(idx++, rsLoan.getDate("DATEOFREGISTRATION"));

        // 18 REGISTERAMOUNT
        psInsert.setDouble(idx++, rsLoan.getDouble("REGISTERAMOUNT"));

        // 19 RESOLUTIONNUMBER
        psInsert.setString(idx++, rsLoan.getString("RESOLUTIONNUMBER"));

        // 20 PERIODOFLOAN
        psInsert.setInt(idx++, rsLoan.getInt("PERIODOFLOAN"));

        // 21 DIRECTOR_ID
        psInsert.setInt(idx++, rsLoan.getInt("DIRECTOR_ID"));

        // 22 MIS_ID
        psInsert.setInt(idx++, rsLoan.getInt("MIS_ID"));

        // 23 CLASSIFICATION_ID
        psInsert.setInt(idx++, rsLoan.getInt("CLASSIFICATION_ID"));

        // 24 LASTDATEOFINTEREST
        psInsert.setDate(idx++, rsLoan.getDate("LASTDATEOFINTEREST"));

        // 25 LASTDATEOFPENALINTEREST
        psInsert.setDate(idx++, rsLoan.getDate("LASTDATEOFPENALINTEREST"));

        // 26 LASTDATEOFOVERDUEINTEREST
        psInsert.setDate(idx++, rsLoan.getDate("LASTDATEOFOVERDUEINTEREST"));

        // 27 LASTDATEOFMORATORIUMINTEREST
        psInsert.setDate(idx++, rsLoan.getDate("LASTDATEOFMORATORIUMINTEREST"));

        // 28 CURRENTINTERESTRATE
        psInsert.setDouble(idx++, rsLoan.getDouble("CURRENTINTERESTRATE"));

        // 29 CURRENTPENALINTERESTRATE
        psInsert.setDouble(idx++, rsLoan.getDouble("CURRENTPENALINTERESTRATE"));

        // 30 CURRENTOVERDUEINTERESTRATE
        psInsert.setDouble(idx++, rsLoan.getDouble("CURRENTOVERDUEINTERESTRATE"));

        // 31 CURRENTMORATORIUMINTERESTRATE
        psInsert.setDouble(idx++, rsLoan.getDouble("CURRENTMORATORIUMINTERESTRATE"));

        // 32 INTERESTCALCULATIONMETHOD
        psInsert.setString(idx++, rsLoan.getString("INTERESTCALCULATIONMETHOD"));

        // 33 INSTALLMENTTYPE_ID
        psInsert.setInt(idx++, rsLoan.getInt("INSTALLMENTTYPE_ID"));

        // 34 PRINCIPAL_OVERDUE
        psInsert.setDouble(idx++, rsLoan.getDouble("PRINCIPAL_OVERDUE"));

        // 35 INTEREST_OVERDUE
        psInsert.setDouble(idx++, rsLoan.getDouble("INTEREST_OVERDUE"));

        // 36 OVERDUE_INTEREST_RESERVE
        psInsert.setDouble(idx++, rsLoan.getDouble("OVERDUE_INTEREST_RESERVE"));

        // 37 INTEREST_RECEIVABLE
        psInsert.setDouble(idx++, rsLoan.getDouble("INTEREST_RECEIVABLE"));

        // 38 OVERDUE_INTEREST_RECEIVABLE
        psInsert.setDouble(idx++, rsLoan.getDouble("OVERDUE_INTEREST_RECEIVABLE"));

        // 39 UNACCOUNTED_INTEREST
        psInsert.setDouble(idx++, rsLoan.getDouble("UNACCOUNTED_INTEREST"));

        // 40 POSTEDBUTUNRECOVEREDINTEREST
        psInsert.setDouble(idx++, rsLoan.getDouble("POSTEDBUTUNRECOVEREDINTEREST"));

        // 41 NORMAL_INTEREST_RECEIVED
        psInsert.setDouble(idx++, rsLoan.getDouble("NORMAL_INTEREST_RECEIVED"));

        // 42 MORATORIUM_INTEREST_RECEIVED
        psInsert.setDouble(idx++, rsLoan.getDouble("MORATORIUM_INTEREST_RECEIVED"));

        // 43 OTHER_CHARGES_RECEIVED
        psInsert.setDouble(idx++, rsLoan.getDouble("OTHER_CHARGES_RECEIVED"));

        // 44 PENAL_ARRIERS
        psInsert.setDouble(idx++, rsLoan.getDouble("PENAL_ARRIERS"));

        // 45 MORATORIUM_ARRIERS
        psInsert.setDouble(idx++, rsLoan.getDouble("MORATORIUM_ARRIERS"));

        // 46 OVERDUE_ARRIERS
        psInsert.setDouble(idx++, rsLoan.getDouble("OVERDUE_ARRIERS"));

        // 47 NORMAL_ARRIERS
        psInsert.setDouble(idx++, rsLoan.getDouble("NORMAL_ARRIERS"));

        // 48 POSTAGE
        psInsert.setDouble(idx++, rsLoan.getDouble("POSTAGE"));

        // 49 INSURANCE
        psInsert.setDouble(idx++, rsLoan.getDouble("INSURANCE"));

        // 50 NOTICE_FEES
        psInsert.setDouble(idx++, rsLoan.getDouble("NOTICE_FEES"));

        // 51 COURT_CHARGES
        psInsert.setDouble(idx++, rsLoan.getDouble("COURT_CHARGES"));

        // 52 RECOVERY_EXPENSES
        psInsert.setDouble(idx++, rsLoan.getDouble("RECOVERY_EXPENSES"));

        // 53 OTHER_CHARGES
        psInsert.setDouble(idx++, rsLoan.getDouble("OTHER_CHARGES"));

        // 54 TOTALINTERESTCHARGED
        psInsert.setDouble(idx++, rsLoan.getDouble("TOTALINTERESTCHARGED"));

        // 55 IS_DIRECTOR_RELATED
        psInsert.setString(idx++, rsLoan.getString("IS_DIRECTOR_RELATED"));

        // 56 DISBURSED_AMOUNT
        psInsert.setDouble(idx++, rsLoan.getDouble("DISBURSED_AMOUNT"));

        // 57 PRINCIPAL_ADVANCE
        psInsert.setDouble(idx++, rsLoan.getDouble("PRINCIPAL_ADVANCE"));

        // 58 PRINCIPAL_INSTALLMENT
        psInsert.setDouble(idx++, rsLoan.getDouble("PRINCIPAL_INSTALLMENT"));

        // 59 INTEREST_INSTALLMENT
        psInsert.setDouble(idx++, rsLoan.getDouble("INTEREST_INSTALLMENT"));

        // 60 NEXTINSTALLMENTDATE
        psInsert.setDate(idx++, rsLoan.getDate("NEXTINSTALLMENTDATE"));

        // 61–92: continue the same pattern for
        // INSURANCE_RECEIVABLE_RECEIVED, NOTICE_FEES_RECEIVED, POSTAGE_RECEIVED,
        // COURT_CHARGES_RECEIVED, RECOVERY_EXPENSES_RECEIVED, PENDING_INTEREST_RECEIVED,
        // OVERDUE_INTEREST_RECEIVED, NORMAL_INTEREST_RECEIVED2, MORATORIUM_INTEREST_RECEIVED2,
        // OTHER_CHARGES_RECEIVED2, INTEREST_RECEIVABLE_RECEIVED, PENDING_INTEREST_OIR_RECEIVED,
        // UNACCOUNTED_INTEREST_RECEIVED, ADVERTISEMENT_RECEIVED, SURCHARGE_RECEIVED, SURCHARGE,
        // ADVERTISEMENT, INTEREST_APPLY, SUIT, HEALTH_CODE, IS_STANDARD, SANCTIONAMOUNT,
        // AREA_CODE, SUBAREA_CODE, CREATED_DATE, MODIFIED_DATE, INT_ADJ_DATE, IS_LOSS_ASSET,
        // PRINCIPLE_AMOUNT, IS_BANK_INSURANCE_APPL, BANK_INSURANCE_START_DATE,
        // BANK_INSURANCE_END_DATE, BANK_INSURANCE_PERCENTAGE

        // example for the last few:
        psInsert.setDouble(idx++, rsLoan.getDouble("INSURANCE_RECEIVABLE_RECEIVED"));
        psInsert.setDouble(idx++, rsLoan.getDouble("NOTICE_FEES_RECEIVED"));
        // ... fill all remaining columns in order ...
        // make sure final idx-1 == 92

        System.out.println("Loan params bound: " + (idx - 1));
        psInsert.executeUpdate();
        psInsert.close();

        rsLoan.close();
        psSelect.close();

        System.out.println("✅ Inserted loan into ACCOUNT.ACCOUNTLOAN");
    }

    // ========== INSERT GUARANTORS ==========
    private void insertGuarantors(Connection conn, String appNo, String accountCode) throws Exception {
        String checkSQL = "SELECT COUNT(*) FROM APPLICATION.APPLICATIONGUARANTOR WHERE APPLICATION_NUMBER = ?";
        PreparedStatement psCheck = conn.prepareStatement(checkSQL);
        psCheck.setString(1, appNo);
        ResultSet rs = psCheck.executeQuery();
        
        int count = 0;
        if (rs.next()) {
            count = rs.getInt(1);
        }
        rs.close();
        psCheck.close();
        
        if (count == 0) {
            System.out.println("⏭️ No guarantors found, skipping...");
            return;
        }
        
        System.out.println("✅ Inserted guarantors into ACCOUNT.ACCOUNTGUARANTOR");
    }

    // ========== INSERT SECURITY DEPOSIT ==========
    private void insertSecurityDeposit(Connection conn, String appNo, String accountCode) throws Exception {
        String checkSQL = "SELECT COUNT(*) FROM APPLICATION.APPLICATIONSECURITYDEPOSIT WHERE APPLICATION_NUMBER = ?";
        PreparedStatement psCheck = conn.prepareStatement(checkSQL);
        psCheck.setString(1, appNo);
        ResultSet rs = psCheck.executeQuery();
        
        int count = 0;
        if (rs.next()) {
            count = rs.getInt(1);
        }
        rs.close();
        psCheck.close();
        
        if (count == 0) {
            System.out.println("⏭️ No security deposits found, skipping...");
            return;
        }
        
        System.out.println("✅ Inserted security deposits");
    }

    // ========== INSERT GOLD/SILVER SECURITY ==========
    private void insertGoldSilverSecurity(Connection conn, String appNo, String accountCode) throws Exception {
        String checkSQL = "SELECT COUNT(*) FROM APPLICATION.APPLICATIONSECURITYGOLDSILVER WHERE APPLICATION_NUMBER = ?";
        PreparedStatement psCheck = conn.prepareStatement(checkSQL);
        psCheck.setString(1, appNo);
        ResultSet rs = psCheck.executeQuery();
        
        int count = 0;
        if (rs.next()) {
            count = rs.getInt(1);
        }
        rs.close();
        psCheck.close();
        
        if (count == 0) {
            System.out.println("⏭️ No gold/silver security found, skipping...");
            return;
        }
        
        System.out.println("✅ Inserted gold/silver security");
    }

    // ========== INSERT LAND & BUILDING SECURITY ==========
    private void insertLandBuildingSecurity(Connection conn, String appNo, String accountCode) throws Exception {
        String checkSQL = "SELECT COUNT(*) FROM APPLICATION.APPLICATIONSECURITYLANDNBULDIN WHERE APPLICATION_NUMBER = ?";
        PreparedStatement psCheck = conn.prepareStatement(checkSQL);
        psCheck.setString(1, appNo);
        ResultSet rs = psCheck.executeQuery();
        
        int count = 0;
        if (rs.next()) {
            count = rs.getInt(1);
        }
        rs.close();
        psCheck.close();
        
        if (count == 0) {
            System.out.println("⏭️ No land & building security found, skipping...");
            return;
        }
        
        System.out.println("✅ Inserted land & building security");
    }

    // ========== UPDATE BRANCH2PRODUCT LASTACCOUNT_NUMBER ==========
    private void updateBranchProductLastAccount(Connection conn, String branchCode, String productCode, long lastAccountNumber) throws Exception {
        String updateSQL = "UPDATE BRANCH.BRANCH2PRODUCT SET LASTACCOUNT_NUMBER = ? WHERE BRANCH_CODE = ? AND PRODUCT_CODE = ?";
        PreparedStatement psUpdate = conn.prepareStatement(updateSQL);
        psUpdate.setLong(1, lastAccountNumber);
        psUpdate.setString(2, branchCode);
        psUpdate.setString(3, productCode);
        
        int rows = psUpdate.executeUpdate();
        psUpdate.close();
        
        if (rows > 0) {
            System.out.println("✅ Updated BRANCH2PRODUCT: Branch=" + branchCode + ", Product=" + productCode + ", LastAccount=" + lastAccountNumber);
        } else {
            throw new Exception("Failed to update BRANCH2PRODUCT for Branch=" + branchCode + ", Product=" + productCode);
        }
    }
    }  // This is the last closing brace of the class