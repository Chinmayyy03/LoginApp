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

@WebServlet("/OpenAccount/ALCbServlet")
public class ALCbServlet extends HttpServlet {

    private String generateApplicationNumber(Connection conn, String branchCode) throws Exception {
        String branchPrefix = String.format("%04d", Integer.parseInt(branchCode));
        System.out.println("🔍 Fetching GLOBAL max sequence from APPLICATION table...");

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

        String applicationNumber = branchPrefix + String.format("%010d", nextSeq);

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
        System.out.println("=== ALCbServlet called ===");

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
            response.sendRedirect("ALCb.jsp?status=error&message=" + 
                java.net.URLEncoder.encode("Product Code required", "UTF-8"));
            return;
        }
        
        if (customerId == null || customerId.isEmpty()) {
            response.sendRedirect("ALCb.jsp?status=error&message=" + 
                java.net.URLEncoder.encode("Customer ID required", "UTF-8") +
                "&productCode=" + productCode);
            return;
        }
        
        Connection conn = null;
        PreparedStatement psApp = null, psLoan = null, psCoBorrower = null;
        String applicationNumber = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            applicationNumber = generateApplicationNumber(conn, branchCode);
            System.out.println("✅ Generated: " + applicationNumber);

            // Insert APPLICATION
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

            // Insert LOAN DATA
            String loanSQL = "INSERT INTO APPLICATION.APPLICATIONLOAN (" +
                "APPLICATION_NUMBER, SANCTIONAUTHORITY_ID, MODEOFSANCTION_ID, " +
                "SOCIALSECTION_ID, SOCIALSECTOR_ID, SOCIALSUBSECTOR_ID, PURPOSE_ID, " +
                "INDUSTRY_ID, REPAYMENTFREQUENCY, IS_CONSORTIUM_LOAN, DRAWINGPOWER, " +
                "LIMITAMOUNT, INSTALLMENTAMOUNT, SANCTIONDATE, ACCOUNTREVIEWDATE, " +
                "DATEOFREGISTRATION, REGISTERAMOUNT, RESOLUTIONNUMBER, PERIODOFLOANA, " +
                "DOCUMENTSUBMISSIONDATE, INTERESTCALCULATIONMETHOD, IS_DIRECTOR_RELATED, " +
                "DIRECTOR_ID, CURRENTPENALINTERESTRATE, CURRENTMORATORIUMINTEREST, " +
                "CURRENTOVERDUEINTERESTRATE, MORATORIUMPERIODMONTH, " +
                "CURRENTINTERESTRATE, INSTALLMENTTYPE_ID, AREA_CODE, SUBAREA_CODE, " +
                "MIS_ID, CLASSIFICATION_ID, DIVIDENT_INTEREST_POST_TO, INTEREST_CATEGORY) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            psLoan = conn.prepareStatement(loanSQL);
            psLoan.setString(1, applicationNumber);
            
            // Set all loan parameters
            Integer sanctionAuthId = parseInt(request.getParameter("sanctionAuthorityId"));
            if (sanctionAuthId != null) psLoan.setInt(2, sanctionAuthId);
            else psLoan.setNull(2, java.sql.Types.INTEGER);
            
            Integer modeOfSanId = parseInt(request.getParameter("modeOfSanId"));
            if (modeOfSanId != null) psLoan.setInt(3, modeOfSanId);
            else psLoan.setNull(3, java.sql.Types.INTEGER);
            
            Integer socialSectionId = parseInt(request.getParameter("socialSectionId"));
            if (socialSectionId != null) psLoan.setInt(4, socialSectionId);
            else psLoan.setNull(4, java.sql.Types.INTEGER);
            
            Integer socialSectorId = parseInt(request.getParameter("socialSectorId"));
            if (socialSectorId != null) psLoan.setInt(5, socialSectorId);
            else psLoan.setNull(5, java.sql.Types.INTEGER);
            
            Integer socialSubSectorId = parseInt(request.getParameter("socialSubSectorId"));
            if (socialSubSectorId != null) psLoan.setInt(6, socialSubSectorId);
            else psLoan.setNull(6, java.sql.Types.INTEGER);
            
            Integer purposeId = parseInt(request.getParameter("purposeId"));
            if (purposeId != null) psLoan.setInt(7, purposeId);
            else psLoan.setNull(7, java.sql.Types.INTEGER);
            
            Integer industryId = parseInt(request.getParameter("industryId"));
            if (industryId != null) psLoan.setInt(8, industryId);
            else psLoan.setNull(8, java.sql.Types.INTEGER);
            
            psLoan.setString(9, trimSafe(request.getParameter("repaymentFreq")));
            psLoan.setString(10, trimSafe(request.getParameter("consortiumLoan")));
            
            Double drawingPower = parseDouble(request.getParameter("drawingPower"));
            if (drawingPower != null) psLoan.setDouble(11, drawingPower);
            else psLoan.setNull(11, java.sql.Types.NUMERIC);
            
            Double limitAmount = parseDouble(request.getParameter("limitAmount"));
            if (limitAmount != null) psLoan.setDouble(12, limitAmount);
            else psLoan.setNull(12, java.sql.Types.NUMERIC);
            
            Double instAmount = parseDouble(request.getParameter("instAmount"));
            if (instAmount != null) psLoan.setDouble(13, instAmount);
            else psLoan.setNull(13, java.sql.Types.NUMERIC);
            
            psLoan.setDate(14, parseDate(request.getParameter("sanctionDate")));
            psLoan.setDate(15, parseDate(request.getParameter("reviewDate")));
            psLoan.setDate(16, parseDate(request.getParameter("registrationDate")));
            
            Double registerAmount = parseDouble(request.getParameter("registerAmount"));
            if (registerAmount != null) psLoan.setDouble(17, registerAmount);
            else psLoan.setNull(17, java.sql.Types.NUMERIC);
            
            psLoan.setString(18, trimSafe(request.getParameter("resolutionNo")));
            
            Integer loanPeriod = parseInt(request.getParameter("loanPeriod"));
            if (loanPeriod != null) psLoan.setInt(19, loanPeriod);
            else psLoan.setNull(19, java.sql.Types.INTEGER);
            
            psLoan.setDate(20, parseDate(request.getParameter("submissionDate")));
            psLoan.setString(21, trimSafe(request.getParameter("intCalcMethod")));
            psLoan.setString(22, trimSafe(request.getParameter("isDirectorRelated")));
            
            Integer directorId = parseInt(request.getParameter("directorId"));
            if (directorId != null) psLoan.setInt(23, directorId);
            else psLoan.setNull(23, java.sql.Types.INTEGER);
            
            Double penalIntRate = parseDouble(request.getParameter("penalIntRate"));
            if (penalIntRate != null) psLoan.setDouble(24, penalIntRate);
            else psLoan.setNull(24, java.sql.Types.NUMERIC);
            
            Double morIntRate = parseDouble(request.getParameter("morIntRate"));
            if (morIntRate != null) psLoan.setDouble(25, morIntRate);
            else psLoan.setNull(25, java.sql.Types.NUMERIC);
            
            Double overdueIntRate = parseDouble(request.getParameter("overdueIntRate"));
            if (overdueIntRate != null) psLoan.setDouble(26, overdueIntRate);
            else psLoan.setNull(26, java.sql.Types.NUMERIC);
            
            Integer morPeriodMonth = parseInt(request.getParameter("morPeriodMonth"));
            if (morPeriodMonth != null) psLoan.setInt(27, morPeriodMonth);
            else psLoan.setNull(27, java.sql.Types.INTEGER);
            
            Double interestRate = parseDouble(request.getParameter("interestRate"));
            if (interestRate != null) psLoan.setDouble(28, interestRate);
            else psLoan.setNull(28, java.sql.Types.NUMERIC);
            
            Integer installmentTypeId = parseInt(request.getParameter("installmentTypeId"));
            if (installmentTypeId != null) psLoan.setInt(29, installmentTypeId);
            else psLoan.setNull(29, java.sql.Types.INTEGER);
            
            Integer areaCode = parseInt(request.getParameter("areaCode"));
            if (areaCode != null) psLoan.setInt(30, areaCode);
            else psLoan.setNull(30, java.sql.Types.INTEGER);
            
            Integer subAreaCode = parseInt(request.getParameter("subAreaCode"));
            if (subAreaCode != null) psLoan.setInt(31, subAreaCode);
            else psLoan.setNull(31, java.sql.Types.INTEGER);
            
            Integer lbrCode = parseInt(request.getParameter("lbrCode"));
            if (lbrCode != null) psLoan.setInt(32, lbrCode);
            else psLoan.setNull(32, java.sql.Types.INTEGER);
            
            Integer classificationId = parseInt(request.getParameter("classificationId"));
            if (classificationId != null) psLoan.setInt(33, classificationId);
            else psLoan.setNull(33, java.sql.Types.INTEGER);
            
            psLoan.setString(34, trimSafe(request.getParameter("dividentInterestPostTo")));
            psLoan.setString(35, trimSafe(request.getParameter("interestCategory")));

            int loanRows = psLoan.executeUpdate();
            System.out.println("Loan details inserted: " + loanRows + " row(s)");

            // Insert CO-BORROWERS
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
                    System.out.println("Co-borrowers inserted: " + coBorrowerRows.length);
                }
            }

            conn.commit();
            System.out.println("✅ SUCCESS! Loan Application saved");

            response.sendRedirect("ALCb.jsp?status=success&applicationNumber=" + 
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
            response.sendRedirect("ALCb.jsp?status=error&message=" + 
                java.net.URLEncoder.encode(e.getMessage(), "UTF-8") + 
                "&productCode=" + (productCode != null ? productCode : ""));
        } finally {
            try { if (psApp != null) psApp.close(); } catch (Exception e) {}
            try { if (psLoan != null) psLoan.close(); } catch (Exception e) {}
            try { if (psCoBorrower != null) psCoBorrower.close(); } catch (Exception e) {}
            try { 
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception e) {}
        }
    }
}