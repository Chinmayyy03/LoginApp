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

	/**
	 * Generate unique 14-digit APPLICATION_NUMBER
	 * Format: BranchCode(4 digits) + GlobalSequence(10 digits)
	 *
	 * GlobalSequence = MAX(last 10 digits of all APPLICATION_NUMBERs in DB)
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
            System.out.println("Session invalid");
            response.sendRedirect("login.jsp");
            return;
        }

        String branchCode = (String) session.getAttribute("branchCode");
        String userId = (String) session.getAttribute("userId");
        String productCode = request.getParameter("productCode");
        String customerId = request.getParameter("customerId");
        
        System.out.println("Branch: " + branchCode + ", User: " + userId);
        System.out.println("Product: " + productCode + ", Customer: " + customerId);
        
        if (productCode == null || productCode.trim().isEmpty()) {
            response.sendRedirect("savingAcc.jsp?status=error&message=" + 
                java.net.URLEncoder.encode("Product Code required", "UTF-8"));
            return;
        }
        
        if (customerId == null || customerId.trim().isEmpty()) {
            response.sendRedirect("savingAcc.jsp?status=error&message=" + 
                java.net.URLEncoder.encode("Customer ID required", "UTF-8"));
            return;
        }
        
        Connection conn = null;
        PreparedStatement psApp = null, psNominee = null, psJoint = null;
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
            
            psApp.setString(9, request.getParameter("introducerAccCode"));
            psApp.setString(10, request.getParameter("categoryCode"));
            psApp.setString(11, request.getParameter("customerName"));
            psApp.setString(12, request.getParameter("introducerAccName"));
            psApp.setString(13, request.getParameter("riskCategory"));

            int appRows = psApp.executeUpdate();
            System.out.println("Application inserted: " + appRows + " row(s)");

            // Insert NOMINEES
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
                    if (nomineeNames[i] == null || nomineeNames[i].trim().isEmpty()) {
                        System.out.println("⚠️ Skip nominee " + (i+1) + " - empty");
                        continue;
                    }
                    
                    String sal = nomineeSalutations != null && i < nomineeSalutations.length ? nomineeSalutations[i] : null;
                    if (sal == null || sal.trim().isEmpty()) {
                        System.out.println("⚠️ Skip nominee " + (i+1) + " - no salutation");
                        continue;
                    }
                    
                    System.out.println("✅ Nominee " + serial + ": " + nomineeNames[i]);
                    
                    psNominee.setString(1, applicationNumber);
                    psNominee.setInt(2, serial);
                    psNominee.setString(3, sal);
                    psNominee.setString(4, nomineeNames[i]);
                    
                    Integer rel = nomineeRelations != null && i < nomineeRelations.length ? parseInt(nomineeRelations[i]) : null;
                    if (rel != null) psNominee.setInt(5, rel);
                    else psNominee.setNull(5, java.sql.Types.INTEGER);
                    
                    psNominee.setString(6, nomineeAddr1 != null && i < nomineeAddr1.length ? nomineeAddr1[i] : null);
                    psNominee.setString(7, nomineeAddr2 != null && i < nomineeAddr2.length ? nomineeAddr2[i] : null);
                    psNominee.setString(8, nomineeAddr3 != null && i < nomineeAddr3.length ? nomineeAddr3[i] : null);
                    psNominee.setString(9, nomineeCities != null && i < nomineeCities.length ? nomineeCities[i] : null);
                    psNominee.setString(10, nomineeStates != null && i < nomineeStates.length ? nomineeStates[i] : null);
                    psNominee.setString(11, nomineeCountries != null && i < nomineeCountries.length ? nomineeCountries[i] : null);
                    
                    Integer zip = nomineeZips != null && i < nomineeZips.length ? parseInt(nomineeZips[i]) : null;
                    if (zip != null) psNominee.setInt(12, zip);
                    else psNominee.setNull(12, java.sql.Types.INTEGER);

                    psNominee.addBatch();
                    validCount++;
                    serial++;
                }

                if (validCount > 0) {
                    int[] nomRows = psNominee.executeBatch();
                    System.out.println("Nominees inserted: " + nomRows.length);
                }
            }

            // Insert JOINT HOLDERS
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
                    if (jointNames[i] == null || jointNames[i].trim().isEmpty()) {
                        System.out.println("⚠️ Skip joint " + (i+1) + " - empty");
                        continue;
                    }
                    
                    String sal = jointSalutations != null && i < jointSalutations.length ? jointSalutations[i] : null;
                    if (sal == null || sal.trim().isEmpty()) {
                        System.out.println("⚠️ Skip joint " + (i+1) + " - no salutation");
                        continue;
                    }
                    
                    System.out.println("✅ Joint " + serial + ": " + jointNames[i]);
                    
                    psJoint.setString(1, applicationNumber);
                    psJoint.setInt(2, serial);
                    psJoint.setString(3, sal);
                    psJoint.setString(4, jointNames[i]);
                    psJoint.setString(5, jointAddr1 != null && i < jointAddr1.length ? jointAddr1[i] : null);
                    psJoint.setString(6, jointAddr2 != null && i < jointAddr2.length ? jointAddr2[i] : null);
                    psJoint.setString(7, jointAddr3 != null && i < jointAddr3.length ? jointAddr3[i] : null);
                    psJoint.setString(8, jointCities != null && i < jointCities.length ? jointCities[i] : null);
                    psJoint.setString(9, jointStates != null && i < jointStates.length ? jointStates[i] : null);
                    psJoint.setString(10, jointCountries != null && i < jointCountries.length ? jointCountries[i] : null);
                    
                    Integer zip = jointZips != null && i < jointZips.length ? parseInt(jointZips[i]) : null;
                    if (zip != null) psJoint.setInt(11, zip);
                    else psJoint.setNull(11, java.sql.Types.INTEGER);
                    
                    String custId = jointCustIDs != null && i < jointCustIDs.length ? jointCustIDs[i] : null;
                    if (custId != null && !custId.trim().isEmpty()) psJoint.setString(12, custId);
                    else psJoint.setNull(12, java.sql.Types.VARCHAR);

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
            System.out.println("✅ SUCCESS!");

            response.sendRedirect("savingAcc.jsp?status=success&applicationNumber=" + applicationNumber);

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                    System.out.println("❌ Rolled back");
                } catch (Exception ex) {}
            }
            
            System.out.println("ERROR: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("savingAcc.jsp?status=error&message=" + 
                java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } finally {
            try { if (psApp != null) psApp.close(); } catch (Exception e) {}
            try { if (psNominee != null) psNominee.close(); } catch (Exception e) {}
            try { if (psJoint != null) psJoint.close(); } catch (Exception e) {}
            try { 
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception e) {}
        }
    }
}


