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

@WebServlet("/OpenAccount/ALCbGServlet")
public class ALCbGServlet extends HttpServlet {

    /**
     * Generate unique 14-digit APPLICATION_NUMBER
     * Format: BranchCode(4 digits) + GlobalSequence(10 digits)
     */
    private String generateApplicationNumber(Connection conn, String branchCode) throws Exception {
        String branchPrefix = String.format("%04d", Integer.parseInt(branchCode));

        System.out.println("🔍 Fetching GLOBAL max sequence from APPLICATION table...");

        // Get MAX sequence of ALL branches (last 10 digits only)
        String sql = 
            "SELECT MAX(TO_NUMBER(SUBSTR(APPLICATION_NUMBER, 5, 10))) " +
            "FROM APPLICATION.APPLICATION " +
            "WHERE LENGTH(APPLICATION_NUMBER) = 14";

        PreparedStatement pstmt = conn.prepareStatement(sql);
        ResultSet rs = pstmt.executeQuery();

        long nextSeq = 1;
        if (rs.next() && rs.getLong(1) > 0) {
            long lastSeq = rs.getLong(1);
            nextSeq = lastSeq + 1;
            System.out.println("✅ Global max seq = " + lastSeq + ", next = " + nextSeq);
        } else {
            System.out.println("✅ No applications found, starting from 1");
        }

        rs.close();
        pstmt.close();

        // Build new application number
        String applicationNumber = branchPrefix + String.format("%010d", nextSeq);

        // Uniqueness check
        String checkSQL = "SELECT COUNT(*) FROM APPLICATION.APPLICATION WHERE APPLICATION_NUMBER = ?";
        PreparedStatement checkStmt = conn.prepareStatement(checkSQL);

        int attempts = 0;
        while (attempts < 100) {
            checkStmt.setString(1, applicationNumber);
            ResultSet checkRs = checkStmt.executeQuery();

            if (checkRs.next() && checkRs.getInt(1) > 0) {
                System.out.println("⚠️ Exists: " + applicationNumber + " — trying next");
                nextSeq++;
                applicationNumber = branchPrefix + String.format("%010d", nextSeq);
                checkRs.close();
                attempts++;
            } else {
                checkRs.close();
                break;
            }
        }

        checkStmt.close();

        if (attempts >= 100) {
            throw new Exception("Failed to generate unique APPLICATION_NUMBER after 100 attempts");
        }

        System.out.println("📌 FINAL APPLICATION_NUMBER = " + applicationNumber);
        return applicationNumber;
    }

    private Date parseDate(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) return null;
        try {
            return new Date(new java.text.SimpleDateFormat("yyyy-MM-dd").parse(dateStr).getTime());
        } catch (Exception e) {
            return null;
        }
    }

    private Integer parseInt(String str) {
        if (str == null || str.trim().isEmpty()) return null;
        try {
            return Integer.parseInt(str.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
    
    private Double parseDouble(String str) {
        if (str == null || str.trim().isEmpty()) return null;
        try {
            return Double.parseDouble(str.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
    
    private String trimSafe(String str) {
        return (str == null) ? null : str.trim();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
                    System.out.println("=== ALCbGServlet called ===");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("branchCode") == null) {
            System.out.println("Session invalid");
            response.sendRedirect("login.jsp");
            return;
        }

        String branchCode = trimSafe((String) session.getAttribute("branchCode"));
        String userId = trimSafe((String) session.getAttribute("userId"));
        String productCode = trimSafe(request.getParameter("productCode"));
        String customerId = trimSafe(request.getParameter("customerId"));
        
        System.out.println("Branch: " + branchCode + ", User: " + userId);
        System.out.println("Product: " + productCode + ", Customer: " + customerId);
        
        if (productCode == null || productCode.isEmpty()) {
            response.sendRedirect("ALCbG.jsp?status=error&message=" + 
                java.net.URLEncoder.encode("Product Code required", "UTF-8"));
            return;
        }
        
        if (customerId == null || customerId.isEmpty()) {
            response.sendRedirect("ALCbG.jsp?status=error&message=" + 
                java.net.URLEncoder.encode("Customer ID required", "UTF-8") +
                "&productCode=" + productCode);
            return;
        }
        
        Connection conn = null;
        PreparedStatement psApp = null, psLoan = null, psCoBorrower = null, psGuarantor = null;
        String applicationNumber = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            applicationNumber = generateApplicationNumber(conn, branchCode);
            System.out.println("✅ Generated: " + applicationNumber);

            // ========== INSERT APPLICATION ==========
            String appSQL = "INSERT INTO APPLICATION.APPLICATION (" +
                "APPLICATION_NUMBER, BRANCH_CODE, PRODUCT_CODE, APPLICATIONDATE, " +
                "CUSTOMER_ID, ACCOUNTOPERATIONCAPACITY_ID, USER_ID, MINBALANCE_ID, " +
                "INTRODUCERACCOUNT_CODE, CATEGORY_CODE, NAME, INTRODUCER_NAME, " +
                "RISKCATEGORY, STATUS) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'E')";

            psApp = conn.prepareStatement(appSQL);
            psApp.setString(1, applicationNumber);
            psApp.setString(2, branchCode);
            psApp.setString(3, productCode);
            psApp.setDate(4, parseDate(request.getParameter("dateOfApplication")));
            psApp.setString(5, customerId);
            
            Integer accOpCap = parseInt(request.getParameter("accountOperationCapacity"));
            if (accOpCap != null) psApp.setInt(6, accOpCap);
            else psApp.setNull(6, java.sql.Types.INTEGER);
            
            psApp.setString(7, userId);
            
            Integer minBal = parseInt(request.getParameter("minBalanceID"));
            if (minBal != null) psApp.setInt(8, minBal);
            else psApp.setNull(8, java.sql.Types.INTEGER);
            
            psApp.setString(9, trimSafe(request.getParameter("introducerAccCode")));
            psApp.setString(10, trimSafe(request.getParameter("categoryCode")));
            psApp.setString(11, trimSafe(request.getParameter("customerName")));
            psApp.setString(12, trimSafe(request.getParameter("introducerAccName")));
            psApp.setString(13, trimSafe(request.getParameter("riskCategory")));

            int appRows = psApp.executeUpdate();
            System.out.println("Application inserted: " + appRows + " row(s)");

            // ========== INSERT LOAN DETAILS (APPLICATIONLOAN table) ==========
            String loanSQL = "INSERT INTO APPLICATION.APPLICATIONLOAN (" +
                "APPLICATION_NUMBER, SUBMISSION_DATE, RESOLUTION_NO, REGISTRATION_DATE, " +
                "REGISTER_AMOUNT, LIMIT_AMOUNT, DRAWING_POWER, SANCTION_DATE, " +
                "SANCTION_AMOUNT, LOAN_PERIOD, REVIEW_DATE, INSTALLMENT_TYPE_ID, " +
                "INSTALLMENT_TYPE, REPAYMENT_FREQ, INT_CALC_METHOD, INTEREST_RATE, " +
                "PENAL_INT_RATE, MOR_INT_RATE, OVERDUE_INT_RATE, MOR_PERIOD_MONTH, " +
                "INST_AMOUNT, CONSORTIUM_LOAN, AREA_CODE, AREA_NAME, SOCIALSECTION_ID, " +
                "SUB_AREA_CODE, SUB_AREA_NAME, LBR_CODE, SOCIAL_SECTOR_ID, SOCIAL_SECTOR_DESC, " +
                "PURPOSE_ID, SOCIALSUBSECTOR_ID, SOCIAL_SUBSECTOR_DESC, CLASSIFICATION_ID, " +
                "MODEOFSANCTION_ID, SANCTIONAUTHORITY_ID, INDUSTRY_ID, IS_DIRECTOR_RELATED, " +
                "DIRECTOR_ID) VALUES (" +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, " +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            System.out.println("📝 Loan SQL prepared with 40 parameters");
            
            psLoan = conn.prepareStatement(loanSQL);
            
            int idx = 1;
            psLoan.setString(idx++, applicationNumber);
            psLoan.setDate(idx++, parseDate(request.getParameter("submissionDate")));
            psLoan.setString(idx++, trimSafe(request.getParameter("resolutionNo")));
            psLoan.setDate(idx++, parseDate(request.getParameter("registrationDate")));
            
            Double registerAmount = parseDouble(request.getParameter("registerAmount"));
            if (registerAmount != null) psLoan.setDouble(idx++, registerAmount);
            else psLoan.setNull(idx++, java.sql.Types.NUMERIC);
            
            Double limitAmount = parseDouble(request.getParameter("limitAmount"));
            if (limitAmount != null) psLoan.setDouble(idx++, limitAmount);
            else psLoan.setNull(idx++, java.sql.Types.NUMERIC);
            
            Double drawingPower = parseDouble(request.getParameter("drawingPower"));
            if (drawingPower != null) psLoan.setDouble(idx++, drawingPower);
            else psLoan.setNull(idx++, java.sql.Types.NUMERIC);
            
            psLoan.setDate(idx++, parseDate(request.getParameter("sanctionDate")));
            
            Double sanctionAmount = parseDouble(request.getParameter("sanctionAmount"));
            if (sanctionAmount != null) psLoan.setDouble(idx++, sanctionAmount);
            else psLoan.setNull(idx++, java.sql.Types.NUMERIC);
            
            Integer loanPeriod = parseInt(request.getParameter("loanPeriod"));
            if (loanPeriod != null) psLoan.setInt(idx++, loanPeriod);
            else psLoan.setNull(idx++, java.sql.Types.INTEGER);
            
            psLoan.setDate(idx++, parseDate(request.getParameter("reviewDate")));
            
            Integer installmentTypeId = parseInt(request.getParameter("installmentTypeId"));
            if (installmentTypeId != null) psLoan.setInt(idx++, installmentTypeId);
            else psLoan.setNull(idx++, java.sql.Types.INTEGER);
            
            psLoan.setString(idx++, trimSafe(request.getParameter("installmentType")));
            psLoan.setString(idx++, trimSafe(request.getParameter("repaymentFreq")));
            psLoan.setString(idx++, trimSafe(request.getParameter("intCalcMethod")));
            
            Double interestRate = parseDouble(request.getParameter("interestRate"));
            if (interestRate != null) psLoan.setDouble(idx++, interestRate);
            else psLoan.setNull(idx++, java.sql.Types.NUMERIC);
            
            Double penalIntRate = parseDouble(request.getParameter("penalIntRate"));
            if (penalIntRate != null) psLoan.setDouble(idx++, penalIntRate);
            else psLoan.setNull(idx++, java.sql.Types.NUMERIC);
            
            Double morIntRate = parseDouble(request.getParameter("morIntRate"));
            if (morIntRate != null) psLoan.setDouble(idx++, morIntRate);
            else psLoan.setNull(idx++, java.sql.Types.NUMERIC);
            
            Double overdueIntRate = parseDouble(request.getParameter("overdueIntRate"));
            if (overdueIntRate != null) psLoan.setDouble(idx++, overdueIntRate);
            else psLoan.setNull(idx++, java.sql.Types.NUMERIC);
            
            Integer morPeriodMonth = parseInt(request.getParameter("morPeriodMonth"));
            if (morPeriodMonth != null) psLoan.setInt(idx++, morPeriodMonth);
            else psLoan.setNull(idx++, java.sql.Types.INTEGER);
            
            Double instAmount = parseDouble(request.getParameter("instAmount"));
            if (instAmount != null) psLoan.setDouble(idx++, instAmount);
            else psLoan.setNull(idx++, java.sql.Types.NUMERIC);
            
            psLoan.setString(idx++, trimSafe(request.getParameter("consortiumLoan")));
            psLoan.setString(idx++, trimSafe(request.getParameter("areaCode")));
            psLoan.setString(idx++, trimSafe(request.getParameter("areaName")));
            
            Integer socialSectionId = parseInt(request.getParameter("socialSectionId"));
            if (socialSectionId != null) psLoan.setInt(idx++, socialSectionId);
            else psLoan.setNull(idx++, java.sql.Types.INTEGER);
            
            psLoan.setString(idx++, trimSafe(request.getParameter("subAreaCode")));
            psLoan.setString(idx++, trimSafe(request.getParameter("subAreaName")));
            psLoan.setString(idx++, trimSafe(request.getParameter("lbrCode")));
            
            Integer socialSectorId = parseInt(request.getParameter("socialSectorId"));
            if (socialSectorId != null) psLoan.setInt(idx++, socialSectorId);
            else psLoan.setNull(idx++, java.sql.Types.INTEGER);
            
            psLoan.setString(idx++, trimSafe(request.getParameter("socialSectorDesc")));
            
            Integer purposeId = parseInt(request.getParameter("purposeId"));
            if (purposeId != null) psLoan.setInt(idx++, purposeId);
            else psLoan.setNull(idx++, java.sql.Types.INTEGER);
            
            Integer socialSubSectorId = parseInt(request.getParameter("socialSubSectorId"));
            if (socialSubSectorId != null) psLoan.setInt(idx++, socialSubSectorId);
            else psLoan.setNull(idx++, java.sql.Types.INTEGER);
            
            psLoan.setString(idx++, trimSafe(request.getParameter("socialSubSectorDesc")));
            
            Integer classificationId = parseInt(request.getParameter("classificationId"));
            if (classificationId != null) psLoan.setInt(idx++, classificationId);
            else psLoan.setNull(idx++, java.sql.Types.INTEGER);
            
            Integer modeOfSanId = parseInt(request.getParameter("modeOfSanId"));
            if (modeOfSanId != null) psLoan.setInt(idx++, modeOfSanId);
            else psLoan.setNull(idx++, java.sql.Types.INTEGER);
            
            Integer sanctionAuthorityId = parseInt(request.getParameter("sanctionAuthorityId"));
            if (sanctionAuthorityId != null) psLoan.setInt(idx++, sanctionAuthorityId);
            else psLoan.setNull(idx++, java.sql.Types.INTEGER);
            
            Integer industryId = parseInt(request.getParameter("industryId"));
            if (industryId != null) psLoan.setInt(idx++, industryId);
            else psLoan.setNull(idx++, java.sql.Types.INTEGER);
            
            psLoan.setString(idx++, trimSafe(request.getParameter("isDirectorRelated")));
            
            Integer directorId = parseInt(request.getParameter("directorId"));
            if (directorId != null) psLoan.setInt(idx++, directorId);
            else psLoan.setNull(idx++, java.sql.Types.INTEGER);

            System.out.println("🚀 Executing Loan INSERT with " + (idx - 1) + " parameters");

            int loanRows = psLoan.executeUpdate();
            System.out.println("Loan details inserted: " + loanRows + " row(s)");

            // ========== INSERT CO-BORROWERS (Using APPLICATIONJOINTHOLDER table) ==========
            String[] coBorrowerNames = request.getParameterValues("coBorrowerName[]");
            String[] coBorrowerSalutations = request.getParameterValues("coBorrowerSalutation[]");
            String[] coBorrowerAddr1 = request.getParameterValues("coBorrowerAddress1[]");
            String[] coBorrowerAddr2 = request.getParameterValues("coBorrowerAddress2[]");
            String[] coBorrowerAddr3 = request.getParameterValues("coBorrowerAddress3[]");
            String[] coBorrowerCities = request.getParameterValues("coBorrowerCity[]");
            String[] coBorrowerStates = request.getParameterValues("coBorrowerState[]");
            String[] coBorrowerCountries = request.getParameterValues("coBorrowerCountry[]");
            String[] coBorrowerZips = request.getParameterValues("coBorrowerZip[]");
            String[] coBorrowerCustIDs = request.getParameterValues("coBorrowerCustomerID[]");

            if (coBorrowerNames != null && coBorrowerNames.length > 0) {
                String coBorrowerSQL = "INSERT INTO APPLICATION.APPLICATIONJOINTHOLDER (" +
                    "APPLICATION_NUMBER, SERIAL_NUMBER, SALUTATION_CODE, NAME, " +
                    "ADDRESS1, ADDRESS2, ADDRESS3, CITY_CODE, STATE_CODE, " +
                    "COUNTRY_CODE, ZIP, CUSTOMER_ID) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

                psCoBorrower = conn.prepareStatement(coBorrowerSQL);
                int serial = 1;
                int validCount = 0;

                for (int i = 0; i < coBorrowerNames.length; i++) {
                    String name = trimSafe(coBorrowerNames[i]);
                    if (name == null || name.isEmpty()) {
                        System.out.println("⚠️ Skip co-borrower " + (i+1) + " - empty name");
                        continue;
                    }
                    
                    String sal = coBorrowerSalutations != null && i < coBorrowerSalutations.length ? 
                                 trimSafe(coBorrowerSalutations[i]) : null;
                    if (sal == null || sal.isEmpty()) {
                        System.out.println("⚠️ Skip co-borrower " + (i+1) + " - no salutation");
                        continue;
                    }
                    
                    System.out.println("✅ Co-Borrower " + serial + ": " + name);
                    
                    psCoBorrower.setString(1, applicationNumber);
                    psCoBorrower.setInt(2, serial);
                    psCoBorrower.setString(3, sal);
                    psCoBorrower.setString(4, name);
                    psCoBorrower.setString(5, coBorrowerAddr1 != null && i < coBorrowerAddr1.length ? 
                                         trimSafe(coBorrowerAddr1[i]) : null);
                    psCoBorrower.setString(6, coBorrowerAddr2 != null && i < coBorrowerAddr2.length ? 
                                         trimSafe(coBorrowerAddr2[i]) : null);
                    psCoBorrower.setString(7, coBorrowerAddr3 != null && i < coBorrowerAddr3.length ? 
                                         trimSafe(coBorrowerAddr3[i]) : null);
                    psCoBorrower.setString(8, coBorrowerCities != null && i < coBorrowerCities.length ? 
                                         trimSafe(coBorrowerCities[i]) : null);
                    psCoBorrower.setString(9, coBorrowerStates != null && i < coBorrowerStates.length ? 
                                         trimSafe(coBorrowerStates[i]) : null);
                    psCoBorrower.setString(10, coBorrowerCountries != null && i < coBorrowerCountries.length ? 
                                          trimSafe(coBorrowerCountries[i]) : null);
                    
                    Integer zip = coBorrowerZips != null && i < coBorrowerZips.length ? 
                                  parseInt(coBorrowerZips[i]) : null;
                    if (zip != null && zip != 0) psCoBorrower.setInt(11, zip);
                    else psCoBorrower.setNull(11, java.sql.Types.INTEGER);
                    
                    String custId = coBorrowerCustIDs != null && i < coBorrowerCustIDs.length ? 
                                    trimSafe(coBorrowerCustIDs[i]) : null;
                    if (custId != null && !custId.isEmpty()) psCoBorrower.setString(12, custId);
                    else psCoBorrower.setNull(12, java.sql.Types.VARCHAR);

                    psCoBorrower.addBatch();
                    validCount++;
                    serial++;
                }

                if (validCount > 0) {
                    int[] coBorrowerRows = psCoBorrower.executeBatch();
                    System.out.println("Co-Borrowers inserted: " + coBorrowerRows.length);
                }
            }

            // ========== INSERT GUARANTORS (APPLICATIONGUARANTOR table) ==========
            String[] guarantorNames = request.getParameterValues("guarantorName[]");
            String[] guarantorSalutations = request.getParameterValues("guarantorSalutation[]");
            String[] guarantorAddr1 = request.getParameterValues("guarantorAddress1[]");
            String[] guarantorAddr2 = request.getParameterValues("guarantorAddress2[]");
            String[] guarantorAddr3 = request.getParameterValues("guarantorAddress3[]");
            String[] guarantorCities = request.getParameterValues("guarantorCity[]");
            String[] guarantorStates = request.getParameterValues("guarantorState[]");
            String[] guarantorCountries = request.getParameterValues("guarantorCountry[]");
            String[] guarantorZips = request.getParameterValues("guarantorZip[]");
            String[] guarantorMemberNos = request.getParameterValues("guarantorMemberNo[]");
            String[] guarantorEmployeeIds = request.getParameterValues("guarantorEmployeeId[]");
            String[] guarantorBirthDates = request.getParameterValues("guarantorBirthDate[]");
            String[] guarantorPhoneNos = request.getParameterValues("guarantorPhoneNo[]");
            String[] guarantorMobileNos = request.getParameterValues("guarantorMobileNo[]");
            String[] guarantorCustIDs = request.getParameterValues("guarantorCustomerID[]");

            if (guarantorNames != null && guarantorNames.length > 0) {
                String guarantorSQL = "INSERT INTO APPLICATION.APPLICATIONGUARANTOR (" +
                    "APPLICATION_NUMBER, SERIAL_NUMBER, SALUTATION_CODE, NAME, " +
                    "ADDRESS1, ADDRESS2, ADDRESS3, CITY_CODE, STATE_CODE, " +
                    "COUNTRY_CODE, ZIP, MEMBER_NO, EMPLOYEE_ID, BIRTH_DATE, " +
                    "PHONE_NO, MOBILE_NO, CUSTOMER_ID) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

                psGuarantor = conn.prepareStatement(guarantorSQL);
                int serial = 1;
                int validCount = 0;

                for (int i = 0; i < guarantorNames.length; i++) {
                    String name = trimSafe(guarantorNames[i]);
                    if (name == null || name.isEmpty()) {
                        System.out.println("⚠️ Skip guarantor " + (i+1) + " - empty name");
                        continue;
                    }
                    
                    String sal = guarantorSalutations != null && i < guarantorSalutations.length ? 
                                 trimSafe(guarantorSalutations[i]) : null;
                    if (sal == null || sal.isEmpty()) {
                        System.out.println("⚠️ Skip guarantor " + (i+1) + " - no salutation");
                        continue;
                    }
                    
                    System.out.println("✅ Guarantor " + serial + ": " + name);
                    
                    psGuarantor.setString(1, applicationNumber);
                    psGuarantor.setInt(2, serial);
                    psGuarantor.setString(3, sal);
                    psGuarantor.setString(4, name);
                    psGuarantor.setString(5, guarantorAddr1 != null && i < guarantorAddr1.length ? 
                                          trimSafe(guarantorAddr1[i]) : null);
                    psGuarantor.setString(6, guarantorAddr2 != null && i < guarantorAddr2.length ? 
                                          trimSafe(guarantorAddr2[i]) : null);
                    psGuarantor.setString(7, guarantorAddr3 != null && i < guarantorAddr3.length ? 
                                          trimSafe(guarantorAddr3[i]) : null);
                    psGuarantor.setString(8, guarantorCities != null && i < guarantorCities.length ? 
                                          trimSafe(guarantorCities[i]) : null);
                    psGuarantor.setString(9, guarantorStates != null && i < guarantorStates.length ? 
                                           trimSafe(guarantorStates[i]) : null);
                    psGuarantor.setString(10, guarantorCountries != null && i < guarantorCountries.length ? 
                                           trimSafe(guarantorCountries[i]) : null);
                    
                    Integer zip = guarantorZips != null && i < guarantorZips.length ? 
                                  parseInt(guarantorZips[i]) : null;
                    if (zip != null && zip != 0) psGuarantor.setInt(11, zip);
                    else psGuarantor.setNull(11, java.sql.Types.INTEGER);
                    
                    psGuarantor.setString(12, guarantorMemberNos != null && i < guarantorMemberNos.length ? 
                                             trimSafe(guarantorMemberNos[i]) : null);
                    psGuarantor.setString(13, guarantorEmployeeIds != null && i < guarantorEmployeeIds.length ? 
                                             trimSafe(guarantorEmployeeIds[i]) : null);
                    psGuarantor.setDate(14, guarantorBirthDates != null && i < guarantorBirthDates.length ? 
                                           parseDate(guarantorBirthDates[i]) : null);
                    psGuarantor.setString(15, guarantorPhoneNos != null && i < guarantorPhoneNos.length ? 
                                             trimSafe(guarantorPhoneNos[i]) : null);
                    psGuarantor.setString(16, guarantorMobileNos != null && i < guarantorMobileNos.length ? 
                                             trimSafe(guarantorMobileNos[i]) : null);
                    
                    String custId = guarantorCustIDs != null && i < guarantorCustIDs.length ? 
                                    trimSafe(guarantorCustIDs[i]) : null;
                    if (custId != null && !custId.isEmpty()) psGuarantor.setString(17, custId);
                    else psGuarantor.setNull(17, java.sql.Types.VARCHAR);

                    psGuarantor.addBatch();
                    validCount++;
                    serial++;
                }

                if (validCount > 0) {
                    int[] guarantorRows = psGuarantor.executeBatch();
                    System.out.println("Guarantors inserted: " + guarantorRows.length);
                }
            }

            conn.commit();
            System.out.println("✅ SUCCESS! Loan Application saved");

            response.sendRedirect("ALCbG.jsp?status=success&applicationNumber=" + 
                                 applicationNumber + "&productCode=" + productCode);

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                    System.out.println("❌ Rolled back");
                } catch (Exception ex) {}
            }
            
            System.out.println("ERROR: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("ALCbG.jsp?status=error&message=" + 
                java.net.URLEncoder.encode(e.getMessage(), "UTF-8") + 
                "&productCode=" + (productCode != null ? productCode : ""));
        } finally {
            try { if (psApp != null) psApp.close(); } catch (Exception e) {}
            try { if (psLoan != null) psLoan.close(); } catch (Exception e) {}
            try { if (psCoBorrower != null) psCoBorrower.close(); } catch (Exception e) {}
            try { if (psGuarantor != null) psGuarantor.close(); } catch (Exception e) {}
            try { 
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception e) {}
        }
    }
}