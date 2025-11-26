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

@WebServlet("/SaveApplicationServlet")
public class SaveApplicationServlet extends HttpServlet {

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

    // Generate APPLICATION_NUMBER: BranchCode(4 digits) + Sequential(10 digits)
    private String generateApplicationNumber(Connection conn, String branchCode) throws Exception {
        // Format branch code to 4 digits
        String branchPrefix = String.format("%04d", Integer.parseInt(branchCode));
        
        // Get the MAX APPLICATION_NUMBER for this branch
        String countSQL = "SELECT MAX(APPLICATION_NUMBER) FROM APPLICATION.APPLICATION WHERE SUBSTR(APPLICATION_NUMBER, 1, 4) = ?";
        PreparedStatement pstmt = conn.prepareStatement(countSQL);
        pstmt.setString(1, branchPrefix);
        ResultSet rs = pstmt.executeQuery();
        
        long maxNumber = 0;
        if (rs.next()) {
            String maxAppNum = rs.getString(1);
            if (maxAppNum != null && maxAppNum.length() >= 14) {
                maxNumber = Long.parseLong(maxAppNum.substring(4)); // Get last 10 digits
            }
        }
        rs.close();
        pstmt.close();
        
        // Generate new APPLICATION_NUMBER
        String applicationNumber = branchPrefix + String.format("%010d", maxNumber + 1);
        return applicationNumber;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
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
        
        Connection conn = null;
        PreparedStatement psApp = null;
        PreparedStatement psNominee = null;
        PreparedStatement psJoint = null;
        String applicationNumber = null;

        try {
            System.out.println("Attempting database connection...");
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction
            System.out.println("Database connected successfully");

            // Generate Application Number
            applicationNumber = generateApplicationNumber(conn, branchCode);
            System.out.println("Generated Application Number: " + applicationNumber);

            // ========== INSERT INTO APPLICATION.APPLICATION ==========
            String insertAppSQL = "INSERT INTO APPLICATION.APPLICATION (" +
                "APPLICATION_NUMBER, BRANCH_CODE, CUSTOMER_ID, ACCOUNTOPERATIONCAPACITY_ID, " +
                "USER_ID, MINBALANCE_ID, INTRODUCERACCOUNT_CODE, CATEGORYCODE, " +
                "NAME, INTRODUCERNAME, RISKCATEGORY, APPLICATIONDATE, STATUS, DATETIMESTAMP" +
                ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";

            psApp = conn.prepareStatement(insertAppSQL);
            
            int idx = 1;
            psApp.setString(idx++, applicationNumber);
            psApp.setString(idx++, branchCode);
            psApp.setString(idx++, request.getParameter("customerId"));
            psApp.setString(idx++, request.getParameter("accountOperationCapacity"));
            psApp.setString(idx++, userId);
            
            Integer minBalanceId = parseInt(request.getParameter("minBalanceID"));
            if (minBalanceId != null) {
                psApp.setInt(idx++, minBalanceId);
            } else {
                psApp.setNull(idx++, java.sql.Types.INTEGER);
            }
            
            psApp.setString(idx++, request.getParameter("introducerAccCode"));
            psApp.setString(idx++, request.getParameter("categoryCode"));
            psApp.setString(idx++, request.getParameter("customerName"));
            psApp.setString(idx++, request.getParameter("introducerAccName"));
            psApp.setString(idx++, request.getParameter("riskCategory"));
            psApp.setDate(idx++, parseDate(request.getParameter("dateOfApplication")));
            psApp.setString(idx++, "P"); // Status = Pending

            int rowsApp = psApp.executeUpdate();
            System.out.println("Application inserted: " + rowsApp + " rows");

            // ========== INSERT NOMINEES ==========
            String[] nomineeSalutations = request.getParameterValues("nomineeSalutation[]");
            String[] nomineeNames = request.getParameterValues("nomineeName[]");
            String[] nomineeAddress1 = request.getParameterValues("nomineeAddress1[]");
            String[] nomineeAddress2 = request.getParameterValues("nomineeAddress2[]");
            String[] nomineeAddress3 = request.getParameterValues("nomineeAddress3[]");
            String[] nomineeCountries = request.getParameterValues("nomineeCountry[]");
            String[] nomineeStates = request.getParameterValues("nomineeState[]");
            String[] nomineeCities = request.getParameterValues("nomineeCity[]");
            String[] nomineeZips = request.getParameterValues("nomineeZip[]");
            String[] nomineeRelations = request.getParameterValues("nomineeRelation[]");
            String[] nomineeCustomerIDs = request.getParameterValues("nomineeCustomerID[]");

            if (nomineeNames != null && nomineeNames.length > 0) {
                String insertNomineeSQL = "INSERT INTO APPLICATION.APPLICATIONNOMINEE (" +
                    "APPLICATION_NUMBER, SERIAL_NUMBER, SALUTATION_CODE, NAME, " +
                    "RELATION_ID, ADDRESS1, ADDRESS2, ADDRESS3, " +
                    "CITY_CODE, STATE_CODE, COUNTRY_CODE, ZIP, CUSTOMER_ID" +
                    ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

                psNominee = conn.prepareStatement(insertNomineeSQL);

                for (int i = 0; i < nomineeNames.length; i++) {
                    if (nomineeNames[i] == null || nomineeNames[i].trim().isEmpty()) {
                        continue; // Skip empty nominees
                    }

                    int nIdx = 1;
                    psNominee.setString(nIdx++, applicationNumber);
                    psNominee.setInt(nIdx++, i + 1); // SERIAL_NUMBER
                    psNominee.setString(nIdx++, nomineeSalutations[i]);
                    psNominee.setString(nIdx++, nomineeNames[i]);
                    psNominee.setString(nIdx++, nomineeRelations[i]);
                    psNominee.setString(nIdx++, nomineeAddress1[i]);
                    psNominee.setString(nIdx++, nomineeAddress2[i]);
                    psNominee.setString(nIdx++, nomineeAddress3[i]);
                    psNominee.setString(nIdx++, nomineeCities[i]);
                    psNominee.setString(nIdx++, nomineeStates[i]);
                    psNominee.setString(nIdx++, nomineeCountries[i]);
                    
                    Integer zip = parseInt(nomineeZips[i]);
                    if (zip != null) {
                        psNominee.setInt(nIdx++, zip);
                    } else {
                        psNominee.setNull(nIdx++, java.sql.Types.INTEGER);
                    }
                    
                    // Handle nominee customer ID (can be null)
                    String nomineeCustomerId = (nomineeCustomerIDs != null && i < nomineeCustomerIDs.length) 
                        ? nomineeCustomerIDs[i] : null;
                    if (nomineeCustomerId != null && !nomineeCustomerId.trim().isEmpty()) {
                        psNominee.setString(nIdx++, nomineeCustomerId);
                    } else {
                        psNominee.setNull(nIdx++, java.sql.Types.VARCHAR);
                    }

                    psNominee.addBatch();
                }

                int[] nomineeRows = psNominee.executeBatch();
                System.out.println("Nominees inserted: " + nomineeRows.length + " rows");
            }

            // ========== INSERT JOINT HOLDERS ==========
            String[] jointSalutations = request.getParameterValues("jointSalutation[]");
            String[] jointNames = request.getParameterValues("jointName[]");
            String[] jointAddress1 = request.getParameterValues("jointAddress1[]");
            String[] jointAddress2 = request.getParameterValues("jointAddress2[]");
            String[] jointAddress3 = request.getParameterValues("jointAddress3[]");
            String[] jointCountries = request.getParameterValues("jointCountry[]");
            String[] jointStates = request.getParameterValues("jointState[]");
            String[] jointCities = request.getParameterValues("jointCity[]");
            String[] jointZips = request.getParameterValues("jointZip[]");
            String[] jointCustomerIDs = request.getParameterValues("jointCustomerID[]");

            if (jointNames != null && jointNames.length > 0) {
                String insertJointSQL = "INSERT INTO APPLICATION.APPLICATIONJOINTHOLDER (" +
                    "APPLICATION_NUMBER, SERIAL_NUMBER, SALUTATION_CODE, NAME, " +
                    "ADDRESS1, ADDRESS2, ADDRESS3, " +
                    "CITY_CODE, STATE_CODE, COUNTRY_CODE, ZIP, CUSTOMER_ID" +
                    ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

                psJoint = conn.prepareStatement(insertJointSQL);

                for (int i = 0; i < jointNames.length; i++) {
                    if (jointNames[i] == null || jointNames[i].trim().isEmpty()) {
                        continue; // Skip empty joint holders
                    }

                    int jIdx = 1;
                    psJoint.setString(jIdx++, applicationNumber);
                    psJoint.setInt(jIdx++, i + 1); // SERIAL_NUMBER
                    psJoint.setString(jIdx++, jointSalutations[i]);
                    psJoint.setString(jIdx++, jointNames[i]);
                    psJoint.setString(jIdx++, jointAddress1[i]);
                    psJoint.setString(jIdx++, jointAddress2[i]);
                    psJoint.setString(jIdx++, jointAddress3[i]);
                    psJoint.setString(jIdx++, jointCities[i]);
                    psJoint.setString(jIdx++, jointStates[i]);
                    psJoint.setString(jIdx++, jointCountries[i]);
                    
                    Integer zip = parseInt(jointZips[i]);
                    if (zip != null) {
                        psJoint.setInt(jIdx++, zip);
                    } else {
                        psJoint.setNull(jIdx++, java.sql.Types.INTEGER);
                    }
                    
                    // Handle joint holder customer ID (can be null)
                    String jointCustomerId = (jointCustomerIDs != null && i < jointCustomerIDs.length) 
                        ? jointCustomerIDs[i] : null;
                    if (jointCustomerId != null && !jointCustomerId.trim().isEmpty()) {
                        psJoint.setString(jIdx++, jointCustomerId);
                    } else {
                        psJoint.setNull(jIdx++, java.sql.Types.VARCHAR);
                    }

                    psJoint.addBatch();
                }

                int[] jointRows = psJoint.executeBatch();
                System.out.println("Joint Holders inserted: " + jointRows.length + " rows");
            }

            // Commit transaction
            conn.commit();
            System.out.println("Transaction committed successfully!");

            // Redirect with success message
            response.sendRedirect("savingAcc.jsp?status=success&applicationNumber=" + applicationNumber);

        } catch (Exception e) {
            // Rollback on error
            if (conn != null) {
                try {
                    conn.rollback();
                    System.out.println("Transaction rolled back due to error");
                } catch (Exception rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            
            System.out.println("ERROR: " + e.getMessage());
            e.printStackTrace();
            String errorMsg = e.getMessage().replace("'", "\\'");
            response.sendRedirect("savingAcc.jsp?status=error&message=" + java.net.URLEncoder.encode(errorMsg, "UTF-8"));
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