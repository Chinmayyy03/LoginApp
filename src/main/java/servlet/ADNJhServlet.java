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

@WebServlet("/OpenAccount/ADNJhServlet")
public class ADNJhServlet extends HttpServlet {

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
            response.sendRedirect("ADNJh.jsp?status=error&message=" +
                java.net.URLEncoder.encode("Product Code required", "UTF-8"));
            return;
        }

        if (customerId == null || customerId.isEmpty()) {
            response.sendRedirect("ADNJh.jsp?status=error&message=" +
                java.net.URLEncoder.encode("Customer ID required", "UTF-8") +
                "&productCode=" + productCode);
            return;
        }

        Connection conn = null;
        PreparedStatement psApp = null, psDeposit = null, psNominee = null, psJoint = null;
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

            // ========== INSERT TERM DEPOSIT (APPLICATIONDEPOSIT) ==========
            String depositSQL = "INSERT INTO APPLICATION.APPLICATIONDEPOSIT (" +
                "APPLICATION_NUMBER, FROMDATE, UNITOFPERIOD, PERIODOFDEPOSIT, " +
                "MATURITYDATE, MATURITYVALUE, DEPOSITAMOUNT, INTERESTRATE, " +
                "INTERESTPAYMENTFREQUENCY, IS_INTEREST_PAID_IN_CASH, " +
                "IS_RATE_DISCOUNTED, IS_AR_DAYBEGIN, MULTIPLYFACTOR, " +
                "CREDITACCOUNT_CODE, DATETIMESTAMP, CREATED_DATE, MODIFIED_DATE) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            psDeposit = conn.prepareStatement(depositSQL);

            int idx = 1;

            // 1. APPLICATION_NUMBER (NOT NULL)
            psDeposit.setString(idx++, applicationNumber);

            // 2. FROMDATE (Open Date)
            psDeposit.setDate(idx++, parseDate(request.getParameter("openDate")));

            // 3. UNITOFPERIOD (CHAR1)
            String unitOfPeriod = trimSafe(request.getParameter("unitOfPeriod"));
            if (unitOfPeriod != null && !unitOfPeriod.isEmpty()) {
                // Convert "Day" to "D" and "Month" to "M"
                if ("Day".equalsIgnoreCase(unitOfPeriod)) {
                    psDeposit.setString(idx++, "D");
                } else if ("Month".equalsIgnoreCase(unitOfPeriod)) {
                    psDeposit.setString(idx++, "M");
                } else {
                    psDeposit.setString(idx++, unitOfPeriod.substring(0, 1).toUpperCase());
                }
            } else {
                psDeposit.setNull(idx++, Types.CHAR);
            }

            // 4. PERIODOFDEPOSIT (NUMBER5,0)
            Integer periodOfDeposit = parseInt(request.getParameter("periodOfDeposit"));
            if (periodOfDeposit != null) psDeposit.setInt(idx++, periodOfDeposit);
            else psDeposit.setNull(idx++, Types.INTEGER);

            // 5. MATURITYDATE
            psDeposit.setDate(idx++, parseDate(request.getParameter("maturityDate")));

            // 6. MATURITYVALUE (MATURITYAMOUNT)
            Double maturityAmount = parseDouble(request.getParameter("maturityAmount"));
            if (maturityAmount != null) psDeposit.setDouble(idx++, maturityAmount);
            else psDeposit.setNull(idx++, Types.DECIMAL);

            // 7. DEPOSITAMOUNT (NOT NULL)
            Double depositAmount = parseDouble(request.getParameter("depositAmount"));
            if (depositAmount != null) psDeposit.setDouble(idx++, depositAmount);
            else psDeposit.setDouble(idx++, 0);

            // 8. INTERESTRATE
            Double interestRate = parseDouble(request.getParameter("interestRate"));
            if (interestRate != null) psDeposit.setDouble(idx++, interestRate);
            else psDeposit.setNull(idx++, Types.DECIMAL);

            // 9. INTERESTPAYMENTFREQUENCY (CHAR1)
            String intFreq = trimSafe(request.getParameter("interestPaymentFrequency"));
            if (intFreq != null && !intFreq.isEmpty()) {
                // Convert full text to code
                if ("On Maturity".equalsIgnoreCase(intFreq)) {
                    psDeposit.setString(idx++, "O");
                } else if ("Monthly".equalsIgnoreCase(intFreq)) {
                    psDeposit.setString(idx++, "M");
                } else if ("Quarterly".equalsIgnoreCase(intFreq)) {
                    psDeposit.setString(idx++, "Q");
                } else if ("Half-Yearly".equalsIgnoreCase(intFreq)) {
                    psDeposit.setString(idx++, "H");
                } else if ("Yearly".equalsIgnoreCase(intFreq)) {
                    psDeposit.setString(idx++, "Y");
                } else {
                    psDeposit.setString(idx++, intFreq.substring(0, 1).toUpperCase());
                }
            } else {
                psDeposit.setNull(idx++, Types.CHAR);
            }

            // 10. INTERESTPAIDINCASH (CHAR1) - note: no underscore between INTEREST and PAID
            String intPaidInCash = trimSafe(request.getParameter("interestPaidInCash"));
            if (intPaidInCash != null && !intPaidInCash.isEmpty()) {
                psDeposit.setString(idx++, "Yes".equalsIgnoreCase(intPaidInCash) ? "Y" : "N");
            } else {
                psDeposit.setNull(idx++, Types.CHAR);
            }

            // 11. IS_RATE_DISCOUNTED (CHAR1)
            String rateDiscounted = trimSafe(request.getParameter("rateDiscounted"));
            if (rateDiscounted != null && !rateDiscounted.isEmpty()) {
                psDeposit.setString(idx++, "Yes".equalsIgnoreCase(rateDiscounted) ? "Y" : "N");
            } else {
                psDeposit.setNull(idx++, Types.CHAR);
            }

            // 12. IS_AR_DAYBEGIN (CHAR1) - note: no underscore between DAY and BEGIN
            String isARDayBegin = trimSafe(request.getParameter("isARDayBegin"));
            if (isARDayBegin != null && !isARDayBegin.isEmpty()) {
                psDeposit.setString(idx++, "Yes".equalsIgnoreCase(isARDayBegin) ? "Y" : "N");
            } else {
                psDeposit.setNull(idx++, Types.CHAR);
            }

            // 13. MULTIPLYFACTOR (NUMBER6,3) - default 1
            psDeposit.setDouble(idx++, 1);

            // 14. CREDITACCOUNT_CODE (CHAR14)
            psDeposit.setString(idx++, trimSafe(request.getParameter("creditAccCode")));

            // 15. DATETIMESTAMP
            Timestamp now = new Timestamp(System.currentTimeMillis());
            psDeposit.setTimestamp(idx++, now);

            // 16. CREATED_DATE
            psDeposit.setTimestamp(idx++, now);

            // 17. MODIFIED_DATE
            psDeposit.setTimestamp(idx++, now);

            psDeposit.executeUpdate();

            // ========== INSERT NOMINEES (APPLICATIONNOMINEE) ==========
            String[] nomineeNames = request.getParameterValues("nomineeName[]");
            String[] nomineeSalutations = request.getParameterValues("nomineeSalutation[]");
            String[] nomineeRelations = request.getParameterValues("nomineeRelation[]");
            String[] nomineeAddr1 = request.getParameterValues("nomineeAddress1[]");
            String[] nomineeAddr2 = request.getParameterValues("nomineeAddress2[]");
            String[] nomineeAddr3 = request.getParameterValues("nomineeAddress3[]");
            String[] nomineeCities = request.getParameterValues("nomineeCity[]");
            String[] nomineeStates = request.getParameterValues("nomineeState[]");
            String[] nomineeCountries = request.getParameterValues("nomineeCountry[]");
            String[] nomineeZips = request.getParameterValues("nomineeZip[]");

            if (nomineeNames != null && nomineeNames.length > 0) {
                String nomSQL = "INSERT INTO APPLICATION.APPLICATIONNOMINEE (" +
                    "APPLICATION_NUMBER, SERIAL_NUMBER, SALUTATION_CODE, NAME, " +
                    "RELATION_ID, ADDRESS1, ADDRESS2, ADDRESS3, CITY_CODE, " +
                    "STATE_CODE, COUNTRY_CODE, ZIP) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

                psNominee = conn.prepareStatement(nomSQL);
                int serial = 1;
                int validCount = 0;

                for (int i = 0; i < nomineeNames.length; i++) {
                    String name = trimSafe(nomineeNames[i]);
                    if (name == null || name.isEmpty()) {
                        System.out.println("⚠️ Skip nominee " + (i+1) + " - empty name");
                        continue;
                    }

                    String sal = nomineeSalutations != null && i < nomineeSalutations.length ?
                                 trimSafe(nomineeSalutations[i]) : null;
                    if (sal == null || sal.isEmpty()) {
                        System.out.println("⚠️ Skip nominee " + (i+1) + " - no salutation");
                        continue;
                    }

                    System.out.println("✅ Nominee " + serial + ": " + name);

                    psNominee.setString(1, applicationNumber);
                    psNominee.setInt(2, serial);
                    psNominee.setString(3, sal);
                    psNominee.setString(4, name);

                    Integer rel = nomineeRelations != null && i < nomineeRelations.length ?
                                  parseInt(nomineeRelations[i]) : null;
                    if (rel != null) psNominee.setInt(5, rel);
                    else psNominee.setNull(5, Types.INTEGER);

                    psNominee.setString(6, nomineeAddr1 != null && i < nomineeAddr1.length ?
                                          trimSafe(nomineeAddr1[i]) : null);
                    psNominee.setString(7, nomineeAddr2 != null && i < nomineeAddr2.length ?
                                          trimSafe(nomineeAddr2[i]) : null);
                    psNominee.setString(8, nomineeAddr3 != null && i < nomineeAddr3.length ?
                                          trimSafe(nomineeAddr3[i]) : null);
                    psNominee.setString(9, nomineeCities != null && i < nomineeCities.length ?
                                          trimSafe(nomineeCities[i]) : null);
                    psNominee.setString(10, nomineeStates != null && i < nomineeStates.length ?
                                           trimSafe(nomineeStates[i]) : null);
                    psNominee.setString(11, nomineeCountries != null && i < nomineeCountries.length ?
                                           trimSafe(nomineeCountries[i]) : null);

                    Integer zip = nomineeZips != null && i < nomineeZips.length ?
                                  parseInt(nomineeZips[i]) : null;
                    if (zip != null && zip != 0) psNominee.setInt(12, zip);
                    else psNominee.setNull(12, Types.INTEGER);

                    psNominee.addBatch();
                    validCount++;
                    serial++;
                }

                if (validCount > 0) {
                    int[] nomRows = psNominee.executeBatch();
                    System.out.println("Nominees inserted: " + nomRows.length);
                }
            }

            // ========== INSERT JOINT HOLDERS (APPLICATIONJOINTHOLDER) ==========
            String[] jointNames = request.getParameterValues("jointName[]");
            String[] jointSalutations = request.getParameterValues("jointSalutation[]");
            String[] jointAddr1 = request.getParameterValues("jointAddress1[]");
            String[] jointAddr2 = request.getParameterValues("jointAddress2[]");
            String[] jointAddr3 = request.getParameterValues("jointAddress3[]");
            String[] jointCities = request.getParameterValues("jointCity[]");
            String[] jointStates = request.getParameterValues("jointState[]");
            String[] jointCountries = request.getParameterValues("jointCountry[]");
            String[] jointZips = request.getParameterValues("jointZip[]");
            String[] jointCustIDs = request.getParameterValues("jointCustomerID[]");

            if (jointNames != null && jointNames.length > 0) {
                String jointSQL = "INSERT INTO APPLICATION.APPLICATIONJOINTHOLDER (" +
                    "APPLICATION_NUMBER, SERIAL_NUMBER, SALUTATION_CODE, NAME, " +
                    "ADDRESS1, ADDRESS2, ADDRESS3, CITY_CODE, STATE_CODE, " +
                    "COUNTRY_CODE, ZIP, CUSTOMER_ID) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

                psJoint = conn.prepareStatement(jointSQL);
                int serial = 1;
                int validCount = 0;

                for (int i = 0; i < jointNames.length; i++) {
                    String name = trimSafe(jointNames[i]);
                    if (name == null || name.isEmpty()) {
                        System.out.println("⚠️ Skip joint " + (i+1) + " - empty name");
                        continue;
                    }

                    String sal = jointSalutations != null && i < jointSalutations.length ?
                                 trimSafe(jointSalutations[i]) : null;
                    if (sal == null || sal.isEmpty()) {
                        System.out.println("⚠️ Skip joint " + (i+1) + " - no salutation");
                        continue;
                    }

                    System.out.println("✅ Joint " + serial + ": " + name);

                    psJoint.setString(1, applicationNumber);
                    psJoint.setInt(2, serial);
                    psJoint.setString(3, sal);
                    psJoint.setString(4, name);
                    psJoint.setString(5, jointAddr1 != null && i < jointAddr1.length ?
                                         trimSafe(jointAddr1[i]) : null);
                    psJoint.setString(6, jointAddr2 != null && i < jointAddr2.length ?
                                         trimSafe(jointAddr2[i]) : null);
                    psJoint.setString(7, jointAddr3 != null && i < jointAddr3.length ?
                                         trimSafe(jointAddr3[i]) : null);
                    psJoint.setString(8, jointCities != null && i < jointCities.length ?
                                         trimSafe(jointCities[i]) : null);
                    psJoint.setString(9, jointStates != null && i < jointStates.length ?
                                         trimSafe(jointStates[i]) : null);
                    psJoint.setString(10, jointCountries != null && i < jointCountries.length ?
                                          trimSafe(jointCountries[i]) : null);

                    Integer zip = jointZips != null && i < jointZips.length ?
                                  parseInt(jointZips[i]) : null;
                    if (zip != null && zip != 0) psJoint.setInt(11, zip);
                    else psJoint.setNull(11, Types.INTEGER);

                    String custId = jointCustIDs != null && i < jointCustIDs.length ?
                                    trimSafe(jointCustIDs[i]) : null;
                    if (custId != null && !custId.isEmpty()) psJoint.setString(12, custId);
                    else psJoint.setNull(12, Types.VARCHAR);

                    psJoint.addBatch();
                    validCount++;
                    serial++;
                }

                if (validCount > 0) {
                    int[] jointRows = psJoint.executeBatch();
                    System.out.println("Joint holders inserted: " + jointRows.length);
                }
            }

            conn.commit();
            response.sendRedirect("ADNJh.jsp?status=success&applicationNumber=" +
                                  applicationNumber + "&productCode=" + productCode);

        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ignored) {}
            }
            e.printStackTrace();
            response.sendRedirect("ADNJh.jsp?status=error&message=" +
                java.net.URLEncoder.encode(e.getMessage(), "UTF-8") +
                "&productCode=" + (productCode != null ? productCode : ""));
        } finally {
            try { if (psApp != null) psApp.close(); } catch (Exception ignored) {}
            try { if (psDeposit != null) psDeposit.close(); } catch (Exception ignored) {}
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