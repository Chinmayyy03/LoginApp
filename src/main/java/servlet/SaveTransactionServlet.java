package servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

import db.DBConnection;

/**
 * Servlet for saving transactions to TRANSACTION.DAILYSCROLL table
 * Handles validation, scroll number generation, and transaction persistence
 * Includes special handling for loan recovery transactions
 */
@WebServlet("/Transactions/SaveTransactionServlet")
public class SaveTransactionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Transaction status constants
    private static final String STATUS_PENDING = "P";
    private static final String STATUS_AUTHORIZED = "A";
    private static final String STATUS_ENTERED = "E";  // Database default
    
    // Transaction indicators
    private static final String INDICATOR_CASH_CREDIT = "CSCR";
    private static final String INDICATOR_CASH_DEBIT = "CSDR";
    private static final String INDICATOR_TRANSFER_CREDIT = "TRCR";
    private static final String INDICATOR_TRANSFER_DEBIT = "TRDR";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        
        Connection con = null;
        
        try {
            // Get session
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("branchCode") == null) {
                jsonResponse.put("error", "Session expired");
                out.print(jsonResponse.toString());
                return;
            }
            
            String branchCode = (String) session.getAttribute("branchCode");
            String userId = (String) session.getAttribute("userId");
            Date workingDate = (Date) session.getAttribute("workingDate");
            
            if (workingDate == null) {
                jsonResponse.put("error", "Working date not found in session");
                out.print(jsonResponse.toString());
                return;
            }
            
            // Get parameters
            String accountCode = request.getParameter("accountCode");
            String transactionAmount = request.getParameter("transactionAmount");
            String transactionIndicator = request.getParameter("transactionIndicator");
            String particular = request.getParameter("particular");
            String operationType = request.getParameter("operationType");
            String accountCategory = request.getParameter("accountCategory");
            
            // Optional parameters
            String chequeType = request.getParameter("chequeType");
            String chequeSeries = request.getParameter("chequeSeries");
            String chequeNumber = request.getParameter("chequeNumber");
            String chequeDate = request.getParameter("chequeDate");
            String forAccountCode = request.getParameter("forAccountCode");
            
            // Get scroll number and subscroll number for transfer grouping
            String scrollNumberParam = request.getParameter("scrollNumber");
            String subscrollNumberParam = request.getParameter("subscrollNumber");
            
            // Get new account balance from frontend
            String newBalanceParam = request.getParameter("newAccountBalance");
            
            // Validate required parameters
            if (accountCode == null || accountCode.trim().isEmpty()) {
                jsonResponse.put("error", "Missing account code");
                out.print(jsonResponse.toString());
                return;
            }
            
            // Get database connection
            con = DBConnection.getConnection();
            con.setAutoCommit(false); // Start transaction
            
            // ✅ NEW: Handle loan/CC accounts differently
            if ("loan".equals(accountCategory) || "cc".equals(accountCategory)) {
                // For loan/CC, save multiple transactions from loan recovery data
                saveLoanRecoveryTransactions(con, branchCode, workingDate, accountCode, 
                                            userId, request, jsonResponse);
                
                // Commit transaction
                con.commit();
                
                // Return success response (already set in saveLoanRecoveryTransactions)
                out.print(jsonResponse.toString());
                return;
            }
            
            // ========== REGULAR TRANSACTION PROCESSING ==========
            
            // Validate transaction amount
            if (transactionAmount == null || transactionAmount.trim().isEmpty() ||
                transactionIndicator == null || transactionIndicator.trim().isEmpty() ||
                operationType == null || operationType.trim().isEmpty()) {
                
                jsonResponse.put("error", "Missing required parameters");
                out.print(jsonResponse.toString());
                return;
            }
            
            // Parse transaction amount
            BigDecimal txnAmount;
            try {
                txnAmount = new BigDecimal(transactionAmount);
                if (txnAmount.compareTo(BigDecimal.ZERO) <= 0) {
                    jsonResponse.put("error", "Transaction amount must be greater than zero");
                    out.print(jsonResponse.toString());
                    return;
                }
            } catch (NumberFormatException e) {
                jsonResponse.put("error", "Invalid transaction amount format");
                out.print(jsonResponse.toString());
                return;
            }
            
            // Step 1: Validate transaction
            String validationResult = validateTransaction(con, accountCode, workingDate, 
                                                         transactionIndicator, txnAmount);
            
            if (validationResult != null && validationResult.trim().length() > 0) {
                char flag = validationResult.charAt(0);
                String message = validationResult.length() > 1 ? 
                                validationResult.substring(1).trim() : "";
                
                if (flag == 'Y') {
                    // Validation failed
                    con.rollback();
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", message);
                    out.print(jsonResponse.toString());
                    return;
                }
            }
            
            // Step 2: Get scroll number and subscroll number
            long scrollNumber;
            int subscrollNumber;
            
            if ("transfer".equals(operationType) && scrollNumberParam != null && !scrollNumberParam.isEmpty()) {
                // For transfer, use provided scroll number and subscroll number
                scrollNumber = Long.parseLong(scrollNumberParam);
                subscrollNumber = subscrollNumberParam != null ? Integer.parseInt(subscrollNumberParam) : 1;
            } else {
                // For deposit/withdrawal, get new scroll number
                scrollNumber = getNextScrollNumber(con);
                subscrollNumber = 1;
            }
            
            // Step 3: Set forAccountCode based on operation type
            if ("deposit".equals(operationType) || "withdrawal".equals(operationType)) {
                // For deposit/withdrawal, set forAccountCode to same account
                forAccountCode = accountCode;
            }
            // For transfer, use the provided forAccountCode parameter
            
            // Step 4: Get GL Account Code
            String glAccountCode = getGLAccountCode(con, accountCode);
            
            // Step 5: Get new account balance from frontend
            BigDecimal newAccountBalance;
            
            if (newBalanceParam != null && !newBalanceParam.trim().isEmpty()) {
                try {
                    newAccountBalance = new BigDecimal(newBalanceParam);
                } catch (NumberFormatException e) {
                    jsonResponse.put("error", "Invalid new account balance format");
                    out.print(jsonResponse.toString());
                    return;
                }
            } else {
                // Fallback: get current ledger balance if new balance not provided
                newAccountBalance = getAccountBalance(con, accountCode);
            }
            
            // Get GL account balance (not modified by this transaction)
            BigDecimal glAccountBalance = BigDecimal.ZERO;
            if (glAccountCode != null && !glAccountCode.isEmpty()) {
                glAccountBalance = getAccountBalance(con, glAccountCode);
            }
            
            // Step 6: Insert transaction
            insertTransaction(con, branchCode, workingDate, scrollNumber, subscrollNumber, 
                            accountCode, glAccountCode, forAccountCode, transactionIndicator, 
                            txnAmount, newAccountBalance, glAccountBalance, chequeType, 
                            chequeSeries, chequeNumber, chequeDate, particular, userId);
            
            // Commit transaction
            con.commit();
            
            // Return success response
            jsonResponse.put("success", true);
            jsonResponse.put("message", "Transaction saved successfully");
            jsonResponse.put("scrollNumber", scrollNumber);
            jsonResponse.put("subscrollNumber", subscrollNumber);
            jsonResponse.put("newBalance", newAccountBalance.toString());
            
            out.print(jsonResponse.toString());
            
        } catch (SQLException e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            jsonResponse.put("error", "Database error: " + e.getMessage());
            out.print(jsonResponse.toString());
            
        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            jsonResponse.put("error", "Server error: " + e.getMessage());
            out.print(jsonResponse.toString());
            
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    /**
     * Save multiple transactions for loan recovery
     * Each non-zero received amount creates a separate transaction record
     */
    private void saveLoanRecoveryTransactions(Connection con, String branchCode, 
                                             Date workingDate, String accountCode,
                                             String userId, HttpServletRequest request,
                                             JSONObject jsonResponse) 
            throws SQLException {
        
        // Get scroll number once for all transactions
        long scrollNumber = getNextScrollNumber(con);
        int subscrollNumber = 1;
        int savedCount = 0;
        
        // Get loan recovery columns from database
        PreparedStatement psColumns = null;
        ResultSet rsColumns = null;
        
        try {
            String query = "SELECT COLUMN_NAME, LINK_GLCODE FROM HEADOFFICE.LOAN_RECOV_SEQ " +
                          "ORDER BY SEQUENCE_NO";
            psColumns = con.prepareStatement(query);
            rsColumns = psColumns.executeQuery();
            
            while (rsColumns.next()) {
                String columnName = rsColumns.getString("COLUMN_NAME");
                String linkGlCode = rsColumns.getString("LINK_GLCODE");
                
                if (columnName == null || columnName.trim().isEmpty()) {
                    continue;
                }
                
                if (linkGlCode == null || linkGlCode.trim().isEmpty()) {
                    continue;
                }
                
                String fieldName = columnName.toLowerCase().trim();
                
                // Get received amount for this field
                String receivedParam = request.getParameter(fieldName + "Received");
                
                if (receivedParam == null || receivedParam.trim().isEmpty()) {
                    continue;
                }
                
                BigDecimal receivedAmount;
                try {
                    receivedAmount = new BigDecimal(receivedParam);
                    
                    // Skip if amount is zero
                    if (receivedAmount.compareTo(BigDecimal.ZERO) <= 0) {
                        continue;
                    }
                } catch (NumberFormatException e) {
                    continue;
                }
                
                // Insert transaction for this recovery type
                insertLoanRecoveryTransaction(con, branchCode, workingDate, scrollNumber,
                                             subscrollNumber, linkGlCode.trim(), accountCode,
                                             receivedAmount, userId, columnName);
                
                subscrollNumber++;
                savedCount++;
            }
            
            if (savedCount == 0) {
                jsonResponse.put("error", "No loan recovery amounts to save");
            } else {
                jsonResponse.put("success", true);
                jsonResponse.put("message", "Loan recovery transactions saved successfully (" + savedCount + " records)");
                jsonResponse.put("scrollNumber", scrollNumber);
                jsonResponse.put("count", savedCount);
            }
            
        } finally {
            if (rsColumns != null) {
                try { rsColumns.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
            if (psColumns != null) {
                try { psColumns.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    /**
     * Insert single loan recovery transaction
     * ACCOUNT_CODE = LINK_GLCODE from LOAN_RECOV_SEQ
     * GLACCOUNT_CODE = LINK_GLCODE from LOAN_RECOV_SEQ
     * FORACCOUNT_CODE = Selected account code
     * ACCOUNTBALANCE = 0
     * GLACCOUNTBALANCE = 0
     */
    private void insertLoanRecoveryTransaction(Connection con, String branchCode,
                                              Date workingDate, long scrollNumber,
                                              int subscrollNumber, String linkGlCode,
                                              String forAccountCode, BigDecimal amount,
                                              String userId, String recoveryType) 
            throws SQLException {
        
        PreparedStatement ps = null;
        
        try {
            String query = "INSERT INTO TRANSACTION.DAILYSCROLL (" +
                          "BRANCH_CODE, SCROLL_DATE, SCROLL_NUMBER, SUBSCROLL_NUMBER, " +
                          "ACCOUNT_CODE, GLACCOUNT_CODE, FORACCOUNT_CODE, " +
                          "TRANSACTIONINDICATOR_CODE, AMOUNT, ACCOUNTBALANCE, " +
                          "GLACCOUNTBALANCE, CHEQUE_TYPE, CHEQUESERIES, " +
                          "CHEQUENUMBER, CHEQUEDATE, TRANIDENTIFICATION_ID, " +
                          "PARTICULAR, USER_ID, IS_PASSBOOK_PRINTED, " +
                          "TRANSACTIONSTATUS, OFFICER_ID, AUTHORISE_DATE, " +
                          "CASHHANDLING_NUMBER, GLBRANCH_CODE, CREATED_DATE, " +
                          "MODIFIED_DATE, RECON_CODE" +
                          ") VALUES (" +
                          "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATE, SYSDATE, ?" +
                          ")";
            
            ps = con.prepareStatement(query);
            
            int paramIndex = 1;
            
            // BRANCH_CODE
            ps.setString(paramIndex++, branchCode);
            
            // SCROLL_DATE
            ps.setDate(paramIndex++, new java.sql.Date(workingDate.getTime()));
            
            // SCROLL_NUMBER
            ps.setLong(paramIndex++, scrollNumber);
            
            // SUBSCROLL_NUMBER
            ps.setInt(paramIndex++, subscrollNumber);
            
            // ACCOUNT_CODE = LINK_GLCODE
            ps.setString(paramIndex++, linkGlCode);
            
            // GLACCOUNT_CODE = LINK_GLCODE
            ps.setString(paramIndex++, linkGlCode);
            
            // FORACCOUNT_CODE = selected account
            ps.setString(paramIndex++, forAccountCode);
            
            // TRANSACTIONINDICATOR_CODE (Credit for loan recovery)
            ps.setString(paramIndex++, INDICATOR_TRANSFER_CREDIT);
            
            // AMOUNT
            ps.setBigDecimal(paramIndex++, amount);
            
            // ACCOUNTBALANCE = 0
            ps.setBigDecimal(paramIndex++, BigDecimal.ZERO);
            
            // GLACCOUNTBALANCE = 0
            ps.setBigDecimal(paramIndex++, BigDecimal.ZERO);
            
            // CHEQUE_TYPE
            ps.setNull(paramIndex++, Types.VARCHAR);
            
            // CHEQUESERIES
            ps.setNull(paramIndex++, Types.VARCHAR);
            
            // CHEQUENUMBER
            ps.setNull(paramIndex++, Types.VARCHAR);
            
            // CHEQUEDATE
            ps.setNull(paramIndex++, Types.DATE);
            
            // TRANIDENTIFICATION_ID
            ps.setInt(paramIndex++, 0);
            
            // PARTICULAR
            ps.setString(paramIndex++, "Loan Recovery - " + recoveryType);
            
            // USER_ID
            ps.setString(paramIndex++, userId);
            
            // IS_PASSBOOK_PRINTED
            ps.setString(paramIndex++, "N");
            
            // TRANSACTIONSTATUS
            ps.setString(paramIndex++, STATUS_ENTERED);
            
            // OFFICER_ID
            ps.setNull(paramIndex++, Types.VARCHAR);
            
            // AUTHORISE_DATE
            ps.setNull(paramIndex++, Types.DATE);
            
            // CASHHANDLING_NUMBER
            ps.setNull(paramIndex++, Types.VARCHAR);
            
            // GLBRANCH_CODE
            ps.setString(paramIndex++, branchCode);
            
            // RECON_CODE
            ps.setNull(paramIndex++, Types.VARCHAR);
            
            int rowsInserted = ps.executeUpdate();
            
            if (rowsInserted == 0) {
                throw new SQLException("Failed to insert loan recovery transaction for " + recoveryType);
            }
            
        } finally {
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    /**
     * Validate transaction using database function
     */
    private String validateTransaction(Connection con, String accountCode, Date workingDate,
                                      String transactionIndicator, BigDecimal amount) 
            throws SQLException {
        
        CallableStatement cs = null;
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
            String workingDateStr = sdf.format(workingDate);
            
            String query = "{? = call Fn_Get_Valid_Transaction(?, TO_DATE(?, 'DD/MM/YYYY'), ?, ?)}";
            cs = con.prepareCall(query);
            
            cs.registerOutParameter(1, Types.CHAR);
            cs.setString(2, accountCode);
            cs.setString(3, workingDateStr);
            cs.setString(4, transactionIndicator);
            cs.setBigDecimal(5, amount);
            
            cs.execute();
            
            return cs.getString(1);
            
        } finally {
            if (cs != null) {
                try { cs.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    /**
     * Get next scroll number from sequence
     */
    private long getNextScrollNumber(Connection con) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String query = "SELECT NEXT_SCROLL_NO.NEXTVAL FROM DUAL";
            ps = con.prepareStatement(query);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getLong(1);
            }
            
            throw new SQLException("Failed to get next scroll number from sequence");
            
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    /**
     * Get GL Account Code for an account
     */
    private String getGLAccountCode(Connection con, String accountCode) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            String query = "SELECT FN_GET_AC_GL(?) AS GL_ACCOUNT_CODE FROM DUAL";
            ps = con.prepareStatement(query);
            ps.setString(1, accountCode);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                String glCode = rs.getString("GL_ACCOUNT_CODE");
                if (glCode != null) {
                    glCode = glCode.trim();
                    // Check for default "not found" value
                    if ("00000000000000".equals(glCode)) {
                        return null;
                    }
                    return glCode;
                }
            }
            return null;
            
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    /**
     * Get account balance
     */
    private BigDecimal getAccountBalance(Connection con, String accountCode) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            String query = "SELECT LEDGERBALANCE FROM BALANCE.ACCOUNT WHERE ACCOUNT_CODE = ?";
            ps = con.prepareStatement(query);
            ps.setString(1, accountCode);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                BigDecimal balance = rs.getBigDecimal("LEDGERBALANCE");
                return balance != null ? balance : BigDecimal.ZERO;
            }
            return BigDecimal.ZERO;
            
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    /**
     * Insert transaction into DAILYSCROLL table
     */
    private void insertTransaction(Connection con, String branchCode, Date workingDate,
                                  long scrollNumber, int subscrollNumber, String accountCode, 
                                  String glAccountCode, String forAccountCode, String transactionIndicator,
                                  BigDecimal amount, BigDecimal accountBalance,
                                  BigDecimal glAccountBalance, String chequeType,
                                  String chequeSeries, String chequeNumber, String chequeDate,
                                  String particular, String userId) throws SQLException {
        
        PreparedStatement ps = null;
        
        try {
            String query = "INSERT INTO TRANSACTION.DAILYSCROLL (" +
                          "BRANCH_CODE, SCROLL_DATE, SCROLL_NUMBER, SUBSCROLL_NUMBER, " +
                          "ACCOUNT_CODE, GLACCOUNT_CODE, FORACCOUNT_CODE, " +
                          "TRANSACTIONINDICATOR_CODE, AMOUNT, ACCOUNTBALANCE, " +
                          "GLACCOUNTBALANCE, CHEQUE_TYPE, CHEQUESERIES, " +
                          "CHEQUENUMBER, CHEQUEDATE, TRANIDENTIFICATION_ID, " +
                          "PARTICULAR, USER_ID, IS_PASSBOOK_PRINTED, " +
                          "TRANSACTIONSTATUS, OFFICER_ID, AUTHORISE_DATE, " +
                          "CASHHANDLING_NUMBER, GLBRANCH_CODE, CREATED_DATE, " +
                          "MODIFIED_DATE, RECON_CODE" +
                          ") VALUES (" +
                          "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATE, SYSDATE, ?" +
                          ")";
            
            ps = con.prepareStatement(query);
            
            int paramIndex = 1;
            
            // BRANCH_CODE
            ps.setString(paramIndex++, branchCode);
            
            // SCROLL_DATE
            ps.setDate(paramIndex++, new java.sql.Date(workingDate.getTime()));
            
            // SCROLL_NUMBER
            ps.setLong(paramIndex++, scrollNumber);
            
            // SUBSCROLL_NUMBER
            ps.setInt(paramIndex++, subscrollNumber);
            
            // ACCOUNT_CODE
            ps.setString(paramIndex++, accountCode);
            
            // GLACCOUNT_CODE
            if (glAccountCode != null && !glAccountCode.isEmpty()) {
                ps.setString(paramIndex++, glAccountCode);
            } else {
                ps.setNull(paramIndex++, Types.VARCHAR);
            }
            
            // FORACCOUNT_CODE
            if (forAccountCode != null && !forAccountCode.isEmpty()) {
                ps.setString(paramIndex++, forAccountCode);
            } else {
                ps.setNull(paramIndex++, Types.VARCHAR);
            }
            
            // TRANSACTIONINDICATOR_CODE
            ps.setString(paramIndex++, transactionIndicator);
            
            // AMOUNT
            ps.setBigDecimal(paramIndex++, amount);
            
            // ACCOUNTBALANCE
            ps.setBigDecimal(paramIndex++, accountBalance);
            
            // GLACCOUNTBALANCE
            ps.setBigDecimal(paramIndex++, glAccountBalance);
            
            // CHEQUE_TYPE
            if (chequeType != null && !chequeType.isEmpty()) {
                ps.setString(paramIndex++, chequeType);
            } else {
                ps.setNull(paramIndex++, Types.VARCHAR);
            }
            
            // CHEQUESERIES
            if (chequeSeries != null && !chequeSeries.isEmpty()) {
                ps.setString(paramIndex++, chequeSeries);
            } else {
                ps.setNull(paramIndex++, Types.VARCHAR);
            }
            
            // CHEQUENUMBER
            if (chequeNumber != null && !chequeNumber.isEmpty()) {
                ps.setString(paramIndex++, chequeNumber);
            } else {
                ps.setNull(paramIndex++, Types.VARCHAR);
            }
            
            // CHEQUEDATE
            if (chequeDate != null && !chequeDate.isEmpty()) {
                ps.setDate(paramIndex++, java.sql.Date.valueOf(chequeDate));
            } else {
                ps.setNull(paramIndex++, Types.DATE);
            }
            
            // TRANIDENTIFICATION_ID (NUMBER(2,0))
            ps.setInt(paramIndex++, 0);
            
            // PARTICULAR
            if (particular != null && !particular.isEmpty()) {
                ps.setString(paramIndex++, particular);
            } else {
                ps.setNull(paramIndex++, Types.VARCHAR);
            }
            
            // USER_ID
            ps.setString(paramIndex++, userId);
            
            // IS_PASSBOOK_PRINTED
            ps.setString(paramIndex++, "N");
            
            // TRANSACTIONSTATUS
            ps.setString(paramIndex++, STATUS_ENTERED);
            
            // OFFICER_ID
            ps.setNull(paramIndex++, Types.VARCHAR);
            
            // AUTHORISE_DATE
            ps.setNull(paramIndex++, Types.DATE);
            
            // CASHHANDLING_NUMBER
            ps.setNull(paramIndex++, Types.VARCHAR);
            
            // GLBRANCH_CODE
            ps.setString(paramIndex++, branchCode);
            
            // RECON_CODE
            ps.setNull(paramIndex++, Types.VARCHAR);
            
            int rowsInserted = ps.executeUpdate();
            
            if (rowsInserted == 0) {
                throw new SQLException("Failed to insert transaction record");
            }
            
        } finally {
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        
        jsonResponse.put("error", "GET method not supported. Use POST.");
        out.print(jsonResponse.toString());
    }
}