<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        out.print("{\"error\": \"Not authenticated\"}");
        return;
    }
    
    // Get card type and identifier
    String cardType = request.getParameter("type");      // "dashboard", "view", "auth"
    String cardId = request.getParameter("id");          // Card identifier
    
    if (cardType == null || cardId == null) {
        out.print("{\"error\": \"Missing parameters\"}");
        return;
    }
    
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    CallableStatement cstmt = null;
    
    try {
        conn = DBConnection.getConnection();
        String value = "N/A";  // Default for missing/invalid data
        
        // Get working date from session
        Date workingDate = (Date) session.getAttribute("workingDate");
        
        switch(cardType.toLowerCase()) {
            case "dashboard":
                // Dashboard cards - use function calls
                ps = conn.prepareStatement(
                    "SELECT FUNCATION_NAME, PARAMITAR, TABLE_NAME, DESCRIPTION " +
                    "FROM GLOBALCONFIG.DASHBOARD " +
                    "WHERE SR_NUMBER = ? AND DESCRIPTION IS NOT NULL"
                );
                ps.setString(1, cardId);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    String functionName = rs.getString("FUNCATION_NAME");
                    String parameters = rs.getString("PARAMITAR");
                    String tableName = rs.getString("TABLE_NAME");
                    String description = rs.getString("DESCRIPTION");
                    
                    if (functionName != null && !functionName.trim().isEmpty()) {
                        value = executeCardFunction(conn, functionName, parameters, tableName, branchCode, description);
                    } else {
                        value = "N/A";  // No function configured, but valid card
                    }
                } else {
                    value = "N/A";  // Card not found in database
                }
                break;
                
            case "view":
                // View page cards
                if ("total_accounts".equals(cardId)) {
                    if (workingDate != null) {
                        ps = conn.prepareStatement(
                            "SELECT COUNT(*) as TOTAL " +
                            "FROM ACCOUNT.ACCOUNT " +
                            "WHERE SUBSTR(ACCOUNT_CODE, 1, 4) = ? " +
                            "AND TRUNC(DATEACCOUNTOPEN) = TRUNC(?)"
                        );
                        ps.setString(1, branchCode);
                        ps.setDate(2, workingDate);
                        rs = ps.executeQuery();
                        
                        if (rs.next()) {
                            value = String.valueOf(rs.getInt("TOTAL"));
                        } else {
                            value = "0";  // Query executed but no results
                        }
                    } else {
                        value = "N/A";  // Working date not available
                    }
                }
                // Add more view cards here as needed
                break;
                
            case "auth":
                // Authorization pending cards
                if ("pending_customers".equals(cardId)) {
                    ps = conn.prepareStatement(
                        "SELECT COUNT(*) FROM CUSTOMERS " +
                        "WHERE BRANCH_CODE=? AND STATUS = 'P'"
                    );
                    ps.setString(1, branchCode);
                    rs = ps.executeQuery();
                    
                    if (rs.next()) {
                        value = String.valueOf(rs.getInt(1));
                    } else {
                        value = "0";  // Query executed but no results
                    }
                    
                } else if ("pending_applications".equals(cardId)) {
                    if (workingDate != null) {
                        ps = conn.prepareStatement(
                            "SELECT COUNT(*) FROM APPLICATION.APPLICATION " +
                            "WHERE BRANCH_CODE=? AND STATUS = 'E' " +
                            "AND TRUNC(APPLICATIONDATE) = TRUNC(?)"
                        );
                        ps.setString(1, branchCode);
                        ps.setDate(2, workingDate);
                        rs = ps.executeQuery();
                        
                        if (rs.next()) {
                            value = String.valueOf(rs.getInt(1));
                        } else {
                            value = "0";  // Query executed but no results
                        }
                    } else {
                        value = "N/A";  // Working date not available
                    }
                }
                break;
                
            default:
                out.print("{\"error\": \"Unknown card type\"}");
                return;
        }
        
        // Return success response
        out.print("{\"value\": \"" + value.replace("\"", "\\\"") + "\", \"status\": \"success\"}");
        
    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"error\": \"" + e.getMessage().replace("\"", "\\\"") + "\"}");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (ps != null) ps.close(); } catch (Exception ex) {}
        try { if (cstmt != null) cstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
%>

<%!
    // Helper method to execute dashboard card functions
    private String executeCardFunction(Connection conn, String functionName, String parameters, 
                                      String tableName, String branchCode, String description) 
                                      throws SQLException {
        
        if (functionName == null || functionName.trim().isEmpty()) {
            return "N/A";  // No function configured
        }
        
        // Parse parameters
        String[] params = parameters != null && !parameters.trim().isEmpty() 
                         ? parameters.split(",") 
                         : new String[0];
        
        // Build SQL with function call
        StringBuilder sql = new StringBuilder("SELECT ").append(functionName).append("(");
        
        int paramCount = 0;
        for (int i = 0; i < params.length; i++) {
            if (paramCount > 0) sql.append(", ");
            
            String param = params[i].trim().toUpperCase();
            if (param.equals("DATE")) {
                sql.append("SYSDATE");
                paramCount++;
            } else if (param.equals("BRANCH")) {
                sql.append("?");
                paramCount++;
            } else {
                sql.append("?");
                paramCount++;
            }
        }
        sql.append(") FROM DUAL");
        
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            ps = conn.prepareStatement(sql.toString());
            
            // Set parameters
            int paramIndex = 1;
            for (int i = 0; i < params.length; i++) {
                String param = params[i].trim().toUpperCase();
                if (!param.equals("DATE")) {
                    if (param.equals("BRANCH")) {
                        ps.setString(paramIndex++, branchCode);
                    } else {
                        ps.setString(paramIndex++, params[i].trim());
                    }
                }
            }
            
            rs = ps.executeQuery();
            if (rs.next()) {
                String result = rs.getString(1);
                if (result == null) {
                    return "0";
                }
                
                // Format the result based on description
                return formatCardValue(result, description, functionName);
            }
            
            return "0";
            
        } catch (SQLException e) {
            System.err.println("Error executing function: " + functionName);
            e.printStackTrace();
            return "Pending";
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ex) {}
            try { if (ps != null) ps.close(); } catch (Exception ex) {}
        }
    }
    
    // Format card value based on type
    private String formatCardValue(String fullResult, String description, String functionName) {
        if (fullResult == null || fullResult.trim().isEmpty()) {
            return "0";
        }
        
        // Parse the result - format might be like "5  1212"
        String[] parts = fullResult.trim().split("\\s+");
        
        if (parts.length >= 2) {
            // We have both parts - separate with dash
            String firstPart = parts[0].trim();
            String secondPart = parts[1].trim();
            
            try {
                double value = Double.parseDouble(firstPart);
                
                String descUpper = description.toUpperCase();
                String funcUpper = functionName.toUpperCase();
                
                // Format based on type
                String formattedFirst = "";
                
                // Check if it's a count
                if (descUpper.contains("CUSTOMER") || descUpper.contains("MEMBER") || 
                    descUpper.contains("COUNT") || descUpper.contains("TYPE") ||
                    descUpper.contains("LOAN") ||
                    funcUpper.contains("CUSTOMER") || funcUpper.contains("LOAN")) {
                    formattedFirst = String.format("%d", (int) value);
                } 
                // Check if it's a percentage
                else if (descUpper.contains("%") || descUpper.contains("PERCENT") ||
                         funcUpper.contains("PERCENTAGE")) {
                    formattedFirst = String.format("%.2f%%", value);
                } 
                // Default: currency
                else {
                    formattedFirst = String.format("₹%,.2f", value);
                }
                
                // Return both parts separated by dash
                return formattedFirst + " - " + secondPart;
                
            } catch (NumberFormatException e) {
                return fullResult;
            }
        } else if (parts.length == 1) {
            // Only one part returned
            try {
                double value = Double.parseDouble(parts[0]);
                
                String descUpper = description.toUpperCase();
                String funcUpper = functionName.toUpperCase();
                
                // Check if it's a count
                if (descUpper.contains("CUSTOMER") || descUpper.contains("MEMBER") || 
                    descUpper.contains("COUNT") || descUpper.contains("TYPE") ||
                    descUpper.contains("LOAN") ||
                    funcUpper.contains("CUSTOMER") || funcUpper.contains("LOAN")) {
                    return String.format("%d", (int) value);
                } 
                // Check if it's a percentage
                else if (descUpper.contains("%") || descUpper.contains("PERCENT") ||
                         funcUpper.contains("PERCENTAGE")) {
                    return String.format("%.2f%%", value);
                } 
                // Default: currency
                else {
                    return String.format("₹%,.2f", value);
                }
            } catch (NumberFormatException e) {
                return fullResult;
            }
        }
        
        return "0";
    }
%>