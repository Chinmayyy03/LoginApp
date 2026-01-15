<%@ page import="java.sql.*, db.DBConnection, org.json.*" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String accountCode = request.getParameter("accountCode");
    
    if (accountCode == null || accountCode.trim().isEmpty()) {
        out.print("{\"error\": \"Account code is required\"}");
        return;
    }
    
    // Get working date from session
    HttpSession sess = request.getSession(false);
    if (sess == null) {
        out.print("{\"error\": \"Session expired\"}");
        return;
    }
    
    Date workingDate = (Date) sess.getAttribute("workingDate");
    if (workingDate == null) {
        out.print("{\"error\": \"Working date not found in session\"}");
        return;
    }

    Connection con = null;
    PreparedStatement psColumns = null;
    PreparedStatement psLoan = null;
    CallableStatement csFunction = null;
    ResultSet rsColumns = null;
    ResultSet rsLoan = null;
    
    try {
        con = DBConnection.getConnection();
        
        // Step 1: Get all columns from LOAN_RECOV_SEQ
        String columnsQuery = "SELECT SR_NO, COLUMN_NAME, FUNCATION, PARAMITARS " +
                             "FROM HEADOFFICE.LOAN_RECOV_SEQ " +
                             "ORDER BY SEQUENCE_NO";
        
        psColumns = con.prepareStatement(columnsQuery);
        rsColumns = psColumns.executeQuery();
        
        JSONObject jsonResponse = new JSONObject();
        jsonResponse.put("success", true);
        JSONObject receivableData = new JSONObject();
        JSONArray errors = new JSONArray();
        
        // Step 2: Get loan account data
        String loanQuery = "SELECT * FROM ACCOUNT.ACCOUNTLOAN WHERE ACCOUNT_CODE = ?";
        psLoan = con.prepareStatement(loanQuery);
        psLoan.setString(1, accountCode);
        rsLoan = psLoan.executeQuery();
        
        if (!rsLoan.next()) {
            out.print("{\"error\": \"Loan account not found\"}");
            return;
        }
        
        // Step 3: Process each column
        while (rsColumns.next()) {
            String columnName = rsColumns.getString("COLUMN_NAME");
            String function = rsColumns.getString("FUNCATION");
            String parameters = rsColumns.getString("PARAMITARS");
            
            // Skip if column name is null or empty
            if (columnName == null || columnName.trim().isEmpty()) {
                continue;
            }
            
            String fieldName = columnName.toLowerCase().trim();
            double value = 0.0;
            boolean valueSet = false;
            
            // Check if function column has 'N' value or is null
            if (function == null || function.trim().isEmpty() || 
                "N".equalsIgnoreCase(function.trim()) || "(null)".equalsIgnoreCase(function.trim())) {
                // Direct column fetch from ACCOUNTLOAN table
                try {
                    value = rsLoan.getDouble(columnName);
                    valueSet = true;
                } catch (SQLException e) {
                    // Column might not exist, set to 0
                    value = 0.0;
                    valueSet = true;
                }
            } else {
                // Try to call function with different parameter combinations
                String functionName = function.trim();
                
                // Try different function call patterns
                boolean functionSuccess = false;
                
                // Pattern 1: Function with account_code and date (VARCHAR2, DATE)
                if (!functionSuccess) {
                    try {
                        String functionCall = "{? = call " + functionName + "(?, ?)}";
                        csFunction = con.prepareCall(functionCall);
                        csFunction.registerOutParameter(1, Types.NUMERIC);
                        csFunction.setString(2, accountCode);
                        csFunction.setDate(3, new java.sql.Date(workingDate.getTime()));
                        csFunction.execute();
                        value = csFunction.getDouble(1);
                        valueSet = true;
                        functionSuccess = true;
                        csFunction.close();
                        csFunction = null;
                    } catch (SQLException e) {
                        // Try next pattern
                    }
                }
                
                // Pattern 2: Procedure that takes account_code, date, and OUT parameter
                if (!functionSuccess) {
                    try {
                        String functionCall = "{call " + functionName + "(?, ?, ?)}";
                        csFunction = con.prepareCall(functionCall);
                        csFunction.setString(1, accountCode);
                        csFunction.setDate(2, new java.sql.Date(workingDate.getTime()));
                        csFunction.registerOutParameter(3, Types.NUMERIC);
                        csFunction.execute();
                        value = csFunction.getDouble(3);
                        valueSet = true;
                        functionSuccess = true;
                        csFunction.close();
                        csFunction = null;
                    } catch (SQLException e) {
                        // Try next pattern
                    }
                }
                
                // Pattern 3: Function with only account_code
                if (!functionSuccess) {
                    try {
                        String functionCall = "{? = call " + functionName + "(?)}";
                        csFunction = con.prepareCall(functionCall);
                        csFunction.registerOutParameter(1, Types.NUMERIC);
                        csFunction.setString(2, accountCode);
                        csFunction.execute();
                        value = csFunction.getDouble(1);
                        valueSet = true;
                        functionSuccess = true;
                        csFunction.close();
                        csFunction = null;
                    } catch (SQLException e) {
                        // Try next pattern
                    }
                }
                
                // Pattern 4: Try direct SELECT from function
                if (!functionSuccess) {
                    try {
                        String selectQuery = "SELECT " + functionName + "(?, ?) FROM DUAL";
                        PreparedStatement psFunc = con.prepareStatement(selectQuery);
                        psFunc.setString(1, accountCode);
                        psFunc.setDate(2, new java.sql.Date(workingDate.getTime()));
                        ResultSet rsFunc = psFunc.executeQuery();
                        if (rsFunc.next()) {
                            value = rsFunc.getDouble(1);
                            valueSet = true;
                            functionSuccess = true;
                        }
                        rsFunc.close();
                        psFunc.close();
                    } catch (SQLException e) {
                        // Function call failed completely
                    }
                }
                
                // If all function calls failed, try to get from ACCOUNTLOAN table
                if (!functionSuccess) {
                    try {
                        value = rsLoan.getDouble(columnName);
                        valueSet = true;
                        errors.put("Function " + functionName + " failed for column " + columnName + ", using table value");
                    } catch (SQLException e) {
                        value = 0.0;
                        valueSet = true;
                        errors.put("Function " + functionName + " and column " + columnName + " both failed");
                    }
                }
            }
            
            receivableData.put(fieldName, String.format("%.2f", value));
        }
        
        jsonResponse.put("receivableData", receivableData);
        if (errors.length() > 0) {
            jsonResponse.put("warnings", errors);
        }
        out.print(jsonResponse.toString());
        
    } catch (SQLException e) {
        e.printStackTrace();
        out.print("{\"error\": \"Database error: " + e.getMessage() + "\"}");
    } finally {
        if (rsColumns != null) try { rsColumns.close(); } catch(SQLException e) {}
        if (rsLoan != null) try { rsLoan.close(); } catch(SQLException e) {}
        if (psColumns != null) try { psColumns.close(); } catch(SQLException e) {}
        if (psLoan != null) try { psLoan.close(); } catch(SQLException e) {}
        if (csFunction != null) try { csFunction.close(); } catch(SQLException e) {}
        if (con != null) try { con.close(); } catch(SQLException e) {}
    }
%>