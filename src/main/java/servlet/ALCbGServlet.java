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

@WebServlet("/OpenAccount/ALCbGServlet")
public class ALCbGServlet extends HttpServlet {

    // ========= Utility methods =========

    private String generateApplicationNumber(Connection conn, String branchCode) throws Exception {
        String branchPrefix = String.format("%04d", Integer.parseInt(branchCode));

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

    // ========= Servlet =========

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("branchCode") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String branchCode = trimSafe((String) session.getAttribute("branchCode"));
        String userId = trimSafe((String) session.getAttribute("userId"));
        String productCode = trimSafe(request.getParameter("productCode"));
        String customerId = trimSafe(request.getParameter("customerId"));

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
            else psApp.setNull(6, Types.INTEGER);

            psApp.setString(7, userId);

            Integer minBal = parseInt(request.getParameter("minBalanceID"));
            if (minBal != null) psApp.setInt(8, minBal);
            else psApp.setNull(8, Types.INTEGER);

            psApp.setString(9, trimSafe(request.getParameter("introducerAccCode")));
            psApp.setString(10, trimSafe(request.getParameter("categoryCode")));
            psApp.setString(11, trimSafe(request.getParameter("customerName")));
            psApp.setString(12, trimSafe(request.getParameter("introducerAccName")));
            psApp.setString(13, trimSafe(request.getParameter("riskCategory")));

            psApp.executeUpdate();

            // ========== INSERT LOAN DETAILS (APPLICATIONLOAN) ==========
            String loanSQL = "INSERT INTO APPLICATION.APPLICATIONLOAN (" +
                "APPLICATION_NUMBER, SANCTIONAUTHORITY_ID, MODEOFSANCTION_ID, " +
                "SOCIALSECTOR_ID, SOCIALSECTION_ID, SOCIALSUBSECTOR_ID, PURPOSE_ID, " +
                "INDUSTRY_ID, REPAYMENTFREQUENCY, IS_CONSORTIUM_LOAN, DRAWINGPOWER, " +
                "LIMITAMOUNT, SANCTIONDATE, ACCOUNTREVIEWDATE, INSTALLMENTAMOUNT, " +
                "MORATORIUMPEROIDMONTH, DOCUMENTSUBMISSIONDATE, DATEOFREGISTRATION, " +
                "REGISTERAMOUNT, RESOLUTIONNUMBER, PERIODOFLOAN, DIRECTOR_ID, " +
                "MIS_ID, CLASSIFICATION_ID, DATETIMESTAMP, CURRENTINTERESTRATE, " +
                "CURRENTPENALINTERESTRATE, CURRENTOVERDUEINTERESTRATE, " +
                "CURRENTMORATORIUMINTERESTRATE, INTERESTCALCULATIONMETHOD, " +
                "INSTALLMENTTYPE_ID, IS_DIRECTOR_RELATED, SANCTIONAMOUNT, " +
                "AREA_CODE, SUBAREA_CODE, CREATED_DATE, MODIFIED_DATE, " +
                "MEMBER_TYPE, MEMBER_NO, PRINCIPLE_AMOUNT) " +
                "VALUES (" +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, " +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, " +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, " +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            psLoan = conn.prepareStatement(loanSQL);

            int idx = 1;

            // 1. APPLICATION_NUMBER (NOT NULL)
            psLoan.setString(idx++, applicationNumber);

            // Mandatory NUMBER(2,0) / NUMBER(3,0) / etc. – validate first
            Integer sanctionAuthorityId = parseInt(request.getParameter("sanctionAuthorityId"));
            Integer modeOfSanId = parseInt(request.getParameter("modeOfSanId"));
            Integer socialSectorId = parseInt(request.getParameter("socialSectorId"));
            Integer socialSectionId = parseInt(request.getParameter("socialSectionId"));
            Integer socialSubSectorId = parseInt(request.getParameter("socialSubSectorId"));
            Integer purposeId = parseInt(request.getParameter("purposeId"));
            Integer industryId = parseInt(request.getParameter("industryId"));
            Integer directorId = parseInt(request.getParameter("directorId"));
            Integer misId = parseInt(request.getParameter("lbrCode"));
            Integer classificationId = parseInt(request.getParameter("classificationId"));

            System.out.println(">> sanctionAuthorityId param = " + request.getParameter("sanctionAuthorityId"));
            System.out.println(">> modeOfSanId param        = " + request.getParameter("modeOfSanId"));
            System.out.println(">> socialSectorId param     = " + request.getParameter("socialSectorId"));
            System.out.println(">> socialSectionId param    = " + request.getParameter("socialSectionId"));
            System.out.println(">> socialSubSectorId param  = " + request.getParameter("socialSubSectorId"));
            System.out.println(">> purposeId param          = " + request.getParameter("purposeId"));
            System.out.println(">> industryId param         = " + request.getParameter("industryId"));
            System.out.println(">> directorId param         = " + request.getParameter("directorId"));
            System.out.println(">> lbrCode param            = " + request.getParameter("lbrCode"));
            System.out.println(">> classificationId param   = " + request.getParameter("classificationId"));

            if (sanctionAuthorityId == null || modeOfSanId == null || socialSectorId == null ||
            	    socialSectionId == null || socialSubSectorId == null || purposeId == null ||
            	    industryId == null || misId == null || classificationId == null) {
            	    conn.rollback();
            	    response.sendRedirect("ALCbG.jsp?status=error&message=" +
            	        java.net.URLEncoder.encode("Mandatory loan master fields missing", "UTF-8") +
            	        "&productCode=" + productCode);
            	    return;
            	}



            psLoan.setInt(idx++, sanctionAuthorityId); // 2
            psLoan.setInt(idx++, modeOfSanId);         // 3
            psLoan.setInt(idx++, socialSectorId);      // 4
            psLoan.setInt(idx++, socialSectionId);     // 5
            psLoan.setInt(idx++, socialSubSectorId);   // 6
            psLoan.setInt(idx++, purposeId);           // 7
            psLoan.setInt(idx++, industryId);          // 8

            // 9. REPAYMENTFREQUENCY (CHAR1, default 'M')
            String repaymentFreq = trimSafe(request.getParameter("repaymentFreq"));
            if (repaymentFreq != null && !repaymentFreq.isEmpty()) {
                psLoan.setString(idx++, repaymentFreq);
            } else {
                psLoan.setNull(idx++, Types.CHAR);     // let DB default apply
            }

            // 10. IS_CONSORTIUM_LOAN (CHAR1, default 'N')
            String consortiumLoan = trimSafe(request.getParameter("consortiumLoan"));
            if (consortiumLoan != null && !consortiumLoan.isEmpty()) {
                psLoan.setString(idx++, consortiumLoan);
            } else {
                psLoan.setNull(idx++, Types.CHAR);     // let DB default apply
            }

            // 11. DRAWINGPOWER NUMBER(15,2)
            Double drawingPower = parseDouble(request.getParameter("drawingPower"));
            if (drawingPower != null) psLoan.setDouble(idx++, drawingPower);
            else psLoan.setNull(idx++, Types.DECIMAL);

            // 12. LIMITAMOUNT NUMBER(15,2)
            Double limitAmount = parseDouble(request.getParameter("limitAmount"));
            if (limitAmount != null) psLoan.setDouble(idx++, limitAmount);
            else psLoan.setNull(idx++, Types.DECIMAL);

            // 13. SANCTIONDATE DATE
            psLoan.setDate(idx++, parseDate(request.getParameter("sanctionDate")));

            // 14. ACCOUNTREVIEWDATE DATE
            psLoan.setDate(idx++, parseDate(request.getParameter("reviewDate")));

            // 15. INSTALLMENTAMOUNT NUMBER(15,2)
            Double instAmount = parseDouble(request.getParameter("instAmount"));
            if (instAmount != null) psLoan.setDouble(idx++, instAmount);
            else psLoan.setNull(idx++, Types.DECIMAL);

            // 16. MORATORIUMPERIODMONTH NUMBER(3,0)
            Integer morPeriodMonth = parseInt(request.getParameter("morPeriodMonth"));
            if (morPeriodMonth != null) psLoan.setInt(idx++, morPeriodMonth);
            else psLoan.setNull(idx++, Types.INTEGER);

            // 17. DOCUMENTSUBMISSIONDATE DATE (default SYSDATE)
            psLoan.setDate(idx++, parseDate(request.getParameter("submissionDate")));

            // 18. DATEOFREGISTRATION DATE (default SYSDATE)
            psLoan.setDate(idx++, parseDate(request.getParameter("registrationDate")));

            // 19. REGISTERAMOUNT NUMBER(15,2)
            Double registerAmount = parseDouble(request.getParameter("registerAmount"));
            if (registerAmount != null) psLoan.setDouble(idx++, registerAmount);
            else psLoan.setNull(idx++, Types.DECIMAL);

            // 20. RESOLUTIONNUMBER CHAR(40)
            psLoan.setString(idx++, trimSafe(request.getParameter("resolutionNo")));

            // 21. PERIODOFLOAN NUMBER(3,0)
            Integer loanPeriod = parseInt(request.getParameter("loanPeriod"));
            if (loanPeriod != null) psLoan.setInt(idx++, loanPeriod);
            else psLoan.setNull(idx++, Types.INTEGER);


         // 22. DIRECTOR_ID: store 0 when empty
            if (directorId != null) {
                psLoan.setInt(idx++, directorId);
            } else {
                psLoan.setInt(idx++, 0);   // store 0 instead of NULL
            }

         // 23. MIS_ID (still mandatory)
         psLoan.setInt(idx++, misId);

         // 24. CLASSIFICATION_ID (still mandatory)
         psLoan.setInt(idx++, classificationId);


            // 25. DATETIMESTAMP TIMESTAMP(6) (default SYSDATE)
            psLoan.setTimestamp(idx++, new Timestamp(System.currentTimeMillis()));

            // 26. CURRENTINTERESTRATE NUMBER(5,2)
            Double interestRate = parseDouble(request.getParameter("interestRate"));
            if (interestRate != null) psLoan.setDouble(idx++, interestRate);
            else psLoan.setNull(idx++, Types.DECIMAL);

            // 27. CURRENTPENALINTERESTRATE NUMBER(5,2)
            Double penalIntRate = parseDouble(request.getParameter("penalIntRate"));
            if (penalIntRate != null) psLoan.setDouble(idx++, penalIntRate);
            else psLoan.setNull(idx++, Types.DECIMAL);

            // 28. CURRENTOVERDUEINTERESTRATE NUMBER(5,2)
            Double overdueIntRate = parseDouble(request.getParameter("overdueIntRate"));
            if (overdueIntRate != null) psLoan.setDouble(idx++, overdueIntRate);
            else psLoan.setNull(idx++, Types.DECIMAL);

            // 29. CURRENTMORATORIUMINTERESTRATE NUMBER(5,2)
            Double morIntRate = parseDouble(request.getParameter("morIntRate"));
            if (morIntRate != null) psLoan.setDouble(idx++, morIntRate);
            else psLoan.setNull(idx++, Types.DECIMAL);

            // 30. INTERESTCALCULATIONMETHOD CHAR(1)
            psLoan.setString(idx++, trimSafe(request.getParameter("intCalcMethod")));

            // 31. INSTALLMENTTYPE_ID NUMBER(3,0)
            Integer installmentTypeId = parseInt(request.getParameter("installmentTypeId"));
            if (installmentTypeId != null) psLoan.setInt(idx++, installmentTypeId);
            else psLoan.setNull(idx++, Types.INTEGER);

            // 32. IS_DIRECTOR_RELATED CHAR(1) (default 'N')
            String isDirectorRelated = trimSafe(request.getParameter("isDirectorRelated"));
            if (isDirectorRelated != null && !isDirectorRelated.isEmpty()) {
                psLoan.setString(idx++, isDirectorRelated);
            } else {
                psLoan.setNull(idx++, Types.CHAR);
            }

            // 33. SANCTIONAMOUNT NUMBER(15,2)
            Double sanctionAmount = parseDouble(request.getParameter("sanctionAmount"));
            if (sanctionAmount != null) psLoan.setDouble(idx++, sanctionAmount);
            else psLoan.setNull(idx++, Types.DECIMAL);

            // 34. AREA_CODE NUMBER(3,0)
            Integer areaCode = parseInt(request.getParameter("areaCode"));
            if (areaCode != null) psLoan.setInt(idx++, areaCode);
            else psLoan.setNull(idx++, Types.INTEGER);

            // 35. SUBAREA_CODE NUMBER(4,0)
            Integer subAreaCode = parseInt(request.getParameter("subAreaCode"));
            if (subAreaCode != null) psLoan.setInt(idx++, subAreaCode);
            else psLoan.setNull(idx++, Types.INTEGER);

            // 36. CREATED_DATE TIMESTAMP(6) (default SYSDATE)
            psLoan.setTimestamp(idx++, new Timestamp(System.currentTimeMillis()));

            // 37. MODIFIED_DATE TIMESTAMP(6)
            psLoan.setTimestamp(idx++, new Timestamp(System.currentTimeMillis()));

            // 38. MEMBER_TYPE CHAR(1)
            psLoan.setNull(idx++, Types.CHAR);

            // 39. MEMBER_NO NUMBER(6,0)
            psLoan.setNull(idx++, Types.INTEGER);

            // 40. PRINCIPLE_AMOUNT NUMBER(15,2)
            if (sanctionAmount != null) psLoan.setDouble(idx++, sanctionAmount);
            else psLoan.setNull(idx++, Types.DECIMAL);

            psLoan.executeUpdate();

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
            String[] guarantorNames       = request.getParameterValues("guarantorName[]");
            String[] guarantorBirthDates  = request.getParameterValues("guarantorBirthDate[]");
            String[] guarantorAddr1       = request.getParameterValues("guarantorAddress1[]");
            String[] guarantorAddr2       = request.getParameterValues("guarantorAddress2[]");
            String[] guarantorAddr3       = request.getParameterValues("guarantorAddress3[]");
            String[] guarantorCities      = request.getParameterValues("guarantorCity[]");
            String[] guarantorStates      = request.getParameterValues("guarantorState[]");
            String[] guarantorCountries   = request.getParameterValues("guarantorCountry[]");
            String[] guarantorZips        = request.getParameterValues("guarantorZip[]");
            String[] guarantorPhoneNos    = request.getParameterValues("guarantorPhoneNo[]");
            String[] guarantorMobileNos   = request.getParameterValues("guarantorMobileNo[]");
            String[] guarantorCustIDs     = request.getParameterValues("guarantorCustomerID[]");
            String[] guarantorMemberNos   = request.getParameterValues("guarantorMemberNo[]");
            String[] guarantorEmployeeIds = request.getParameterValues("guarantorEmployeeId[]");

            if (guarantorNames != null && guarantorNames.length > 0) {
                String guarantorSQL =
                    "INSERT INTO APPLICATION.APPLICATIONGUARANTOR (" +
                    "APPLICATION_NUMBER, SERIAL_NUMBER, NAME, DATEOFBIRTH, " +        // 1–4
                    "ADDRESS1, ADDRESS2, ADDRESS3, CITY_CODE, STATE_CODE, " +         // 5–9
                    "COUNTRY_CODE, ZIP, PHONENUMBER, MOBILENUMBER, CUSTOMER_ID, " +   // 10–14
                    "MEMBER_NO, EMPLOYEE_ID, DATETIMESTAMP, CREATED_DATE, MODIFIED_DATE" + // 15–19
                    ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

                psGuarantor = conn.prepareStatement(guarantorSQL);
                int serial = 1;
                int validCount = 0;

                for (int i = 0; i < guarantorNames.length; i++) {
                    String name = trimSafe(guarantorNames[i]);
                    if (name == null || name.isEmpty()) {
                        System.out.println("⚠️ Skip guarantor " + (i + 1) + " - empty name");
                        continue;
                    }

                    // mandatory DOB, CITY_CODE, STATE_CODE, COUNTRY_CODE should also be present
                    Date dob = guarantorBirthDates != null && i < guarantorBirthDates.length
                               ? parseDate(guarantorBirthDates[i]) : null;
                    String cityCode    = guarantorCities    != null && i < guarantorCities.length
                                         ? trimSafe(guarantorCities[i]) : null;
                    String stateCode   = guarantorStates    != null && i < guarantorStates.length
                                         ? trimSafe(guarantorStates[i]) : null;
                    String countryCode = guarantorCountries != null && i < guarantorCountries.length
                                         ? trimSafe(guarantorCountries[i]) : null;

                    if (dob == null || cityCode == null || cityCode.isEmpty()
                            || stateCode == null || stateCode.isEmpty()
                            || countryCode == null || countryCode.isEmpty()) {
                        System.out.println("⚠️ Skip guarantor " + (i + 1) + " - missing mandatory address/DOB");
                        continue;
                    }

                    System.out.println("✅ Guarantor " + serial + ": " + name);

                    int gIdx = 1;
                    psGuarantor.setString(gIdx++, applicationNumber);            // 1 APPLICATION_NUMBER
                    psGuarantor.setInt(gIdx++, serial);                          // 2 SERIAL_NUMBER
                    psGuarantor.setString(gIdx++, name);                         // 3 NAME
                    psGuarantor.setDate(gIdx++, dob);                            // 4 DATEOFBIRTH

                    psGuarantor.setString(gIdx++, guarantorAddr1 != null && i < guarantorAddr1.length
                                                     ? trimSafe(guarantorAddr1[i]) : null); // 5 ADDRESS1
                    psGuarantor.setString(gIdx++, guarantorAddr2 != null && i < guarantorAddr2.length
                                                     ? trimSafe(guarantorAddr2[i]) : null); // 6 ADDRESS2
                            psGuarantor.setString(gIdx++, guarantorAddr3 != null && i < guarantorAddr3.length
                            ? trimSafe(guarantorAddr3[i]) : null); // 7 ADDRESS3

					psGuarantor.setString(gIdx++, cityCode);       // 8 CITY_CODE (NOT NULL)
					psGuarantor.setString(gIdx++, stateCode);      // 9 STATE_CODE (NOT NULL)
					psGuarantor.setString(gIdx++, countryCode);    //10 COUNTRY_CODE (NOT NULL)
					
					Integer zip = guarantorZips != null && i < guarantorZips.length
					         ? parseInt(guarantorZips[i]) : null;
					if (zip != null && zip != 0) {
					psGuarantor.setInt(gIdx++, zip);           //11 ZIP
					} else {
					psGuarantor.setNull(gIdx++, Types.INTEGER);
					}
					
					psGuarantor.setString(gIdx++, guarantorPhoneNos != null && i < guarantorPhoneNos.length
					                            ? trimSafe(guarantorPhoneNos[i]) : null);  //12 PHONENUMBER
					psGuarantor.setString(gIdx++, guarantorMobileNos != null && i < guarantorMobileNos.length
					                            ? trimSafe(guarantorMobileNos[i]) : null); //13 MOBILENUMBER
					
					String custId = guarantorCustIDs != null && i < guarantorCustIDs.length
					           ? trimSafe(guarantorCustIDs[i]) : null;
					if (custId != null && !custId.isEmpty()) {
					psGuarantor.setString(gIdx++, custId);     //14 CUSTOMER_ID
					} else {
					psGuarantor.setNull(gIdx++, Types.CHAR);
					}
					
					Integer memberNo = guarantorMemberNos != null && i < guarantorMemberNos.length
					              ? parseInt(guarantorMemberNos[i]) : null;
					if (memberNo != null) {
					psGuarantor.setInt(gIdx++, memberNo);      //15 MEMBER_NO
					} else {
					psGuarantor.setNull(gIdx++, Types.INTEGER);
					}
					
					Integer empId = guarantorEmployeeIds != null && i < guarantorEmployeeIds.length
					           ? parseInt(guarantorEmployeeIds[i]) : null;
					if (empId != null) {
					psGuarantor.setInt(gIdx++, empId);         //16 EMPLOYEE_ID
					} else {
					psGuarantor.setNull(gIdx++, Types.INTEGER);
					}
					
					Timestamp now = new Timestamp(System.currentTimeMillis());
					psGuarantor.setTimestamp(gIdx++, now);         //17 DATETIMESTAMP
					psGuarantor.setTimestamp(gIdx++, now);         //18 CREATED_DATE
					psGuarantor.setTimestamp(gIdx++, now);         //19 MODIFIED_DATE
					
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
            response.sendRedirect("ALCbG.jsp?status=success&applicationNumber=" +
                                  applicationNumber + "&productCode=" + productCode);

        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ignored) {}
            }
            response.sendRedirect("ALCbG.jsp?status=error&message=" +
                java.net.URLEncoder.encode(e.getMessage(), "UTF-8") +
                "&productCode=" + (productCode != null ? productCode : ""));
        } finally {
            try { if (psApp != null) psApp.close(); } catch (Exception ignored) {}
            try { if (psLoan != null) psLoan.close(); } catch (Exception ignored) {}
            try { if (psCoBorrower != null) psCoBorrower.close(); } catch (Exception ignored) {}
            try { if (psGuarantor != null) psGuarantor.close(); } catch (Exception ignored) {}
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignored) {}
        }
    }
}
