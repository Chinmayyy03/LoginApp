<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String accountCode = request.getParameter("accountCode");
    String workingDate = request.getParameter("workingDate");
    String transactionIndicator = request.getParameter("transactionIndicator");
    String transactionAmount = request.getParameter("transactionAmount");
    
    if (accountCode == null || workingDate == null || 
        transactionIndicator == null || transactionAmount == null) {
        out.print("{\"error\": \"Missing required parameters\"}");
        return;
    }
    
    Connection con = null;
    CallableStatement cs = null;
    
    try {
        con = DBConnection.getConnection();
        
        // Call the validation function
        String functionCall = "{? = call Fn_Get_Valid_Transaction(?, TO_DATE(?, 'DD/MM/YYYY'), ?, ?)}";
        cs = con.prepareCall(functionCall);
        
        // Register output parameter
        cs.registerOutParameter(1, Types.CHAR);
        
        // Set input parameters
        cs.setString(2, accountCode);
        cs.setString(3, workingDate);
        cs.setString(4, transactionIndicator);
        cs.setDouble(5, Double.parseDouble(transactionAmount));
        
        // Execute
        cs.execute();
        
        // Get result
        String result = cs.getString(1);
        
        if (result != null && result.trim().length() > 0) {
            // First character is the flag (Y/N)
            char flag = result.charAt(0);
            String message = result.length() > 1 ? result.substring(1).trim() : "";
            
            if (flag == 'Y') {
                // Validation failed
                out.print("{\"success\": false, \"message\": \"" + message + "\"}");
            } else {
                // Validation passed
                out.print("{\"success\": true, \"message\": \"Transaction validated successfully\"}");
            }
        } else {
            out.print("{\"success\": true, \"message\": \"Transaction validated successfully\"}");
        }
        
    } catch (SQLException e) {
        e.printStackTrace();
        out.print("{\"error\": \"Database error: " + e.getMessage() + "\"}");
    } catch (NumberFormatException e) {
        out.print("{\"error\": \"Invalid transaction amount\"}");
    } finally {
        if (cs != null) try { cs.close(); } catch(SQLException e) {}
        if (con != null) try { con.close(); } catch(SQLException e) {}
    }
%>