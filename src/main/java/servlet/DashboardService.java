package servlet;

import db.DBConnection;
import servlet.DashboardCard;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DashboardService {

    /**
     * Fetch all dashboard card configurations from database
     * Cards are ordered by SR_NUMBER
     */
    public List<DashboardCard> getDashboardCards() throws SQLException {
        List<DashboardCard> cards = new ArrayList<>();
        String sql = "SELECT SR_NUMBER, DESCRIPTION, FUNCATION_NAME, PARAMITAR, TABLE_NAME, PAGE_LINK " +
                    "FROM GLOBALCONFIG.DASHBOARD " +
                    "WHERE DESCRIPTION IS NOT NULL " +
                    "ORDER BY SR_NUMBER";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                DashboardCard card = new DashboardCard();
                card.setSrNumber(rs.getInt("SR_NUMBER"));
                card.setDescription(rs.getString("DESCRIPTION"));
                card.setFuncationName(rs.getString("FUNCATION_NAME"));
                card.setParamitar(rs.getString("PARAMITAR"));
                card.setTableName(rs.getString("TABLE_NAME"));
                card.setPageLink(rs.getString("PAGE_LINK"));
                cards.add(card);
            }
        }
        return cards;
    }

    /**
     * Execute the database function and return the full string result
     */
    public String executeCardFunctionAsString(String functionName, String parameters, 
                                             String tableName, String branchCode) throws SQLException {
        String result = "";
        
        if (functionName == null || functionName.trim().isEmpty()) {
            return result;
        }
        
        // Parse parameters from database (comma-separated)
        String[] params = parameters != null && !parameters.trim().isEmpty() 
                         ? parameters.split(",") 
                         : new String[0];
        
        // Build SQL with function call, replacing DATE with SYSDATE and BRANCH with branchCode
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
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql.toString());
            
            // Set parameters (skip DATE, replace BRANCH with branchCode)
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
                result = rs.getString(1);
                if (result == null) {
                    result = "";
                }
            }
        } catch (SQLException e) {
            System.err.println("Error executing function: " + functionName);
            System.err.println("Parameters: " + parameters);
            System.err.println("Branch Code: " + branchCode);
            System.err.println("SQL: " + sql.toString());
            e.printStackTrace();
            throw e;
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
        
        return result;
    }

    /**
     * Get card value with proper formatting
     * Separates the two outputs from function with a dash
     */
    public String getFormattedCardValue(DashboardCard card, String branchCode) {
        try {
            // Check for null values
            if (card.getDescription() == null || card.getFuncationName() == null) {
                return "N/A";
            }
            
            // Get the full string result from function
            String fullResult = executeCardFunctionAsString(
                card.getFuncationName(), 
                card.getParamitar(), 
                card.getTableName(), 
                branchCode
            );
            
            // Parse the result - format is like "5  1212"
            if (fullResult != null && !fullResult.trim().isEmpty()) {
                String[] parts = fullResult.trim().split("\\s+");
                
                if (parts.length >= 2) {
                    // We have both parts - separate with dash
                    String firstPart = parts[0].trim();
                    String secondPart = parts[1].trim();
                    
                    try {
                        double value = Double.parseDouble(firstPart);
                        card.setValue(value);
                        
                        String description = card.getDescription().toUpperCase();
                        String functionName = card.getFuncationName().toUpperCase();
                        
                        // Format based on type
                        String formattedFirst = "";
                        
                        // Check if it's a count
                        if (description.contains("CUSTOMER") || description.contains("MEMBER") || 
                            description.contains("COUNT") || description.contains("TYPE") ||
                            description.contains("LOAN") ||
                            functionName.contains("CUSTOMER") || functionName.contains("LOAN")) {
                            formattedFirst = String.format("%d", (int) value);
                        } 
                        // Check if it's a percentage
                        else if (description.contains("%") || description.contains("PERCENT") ||
                                 functionName.contains("PERCENTAGE")) {
                            formattedFirst = String.format("%.2f%%", value);
                        } 
                        // Default: currency
                        else {
                            formattedFirst = String.format("₹%,.2f", value);
                        }
                        
                        // Return both parts separated by dash
                        return formattedFirst + " - " + secondPart;
                        
                    } catch (NumberFormatException e) {
                        return fullResult; // Return as-is if can't parse
                    }
                } else if (parts.length == 1) {
                    // Only one part returned
                    try {
                        double value = Double.parseDouble(parts[0]);
                        card.setValue(value);
                        
                        String description = card.getDescription().toUpperCase();
                        String functionName = card.getFuncationName().toUpperCase();
                        
                        // Check if it's a count
                        if (description.contains("CUSTOMER") || description.contains("MEMBER") || 
                            description.contains("COUNT") || description.contains("TYPE") ||
                            description.contains("LOAN") ||
                            functionName.contains("CUSTOMER") || functionName.contains("LOAN")) {
                            return String.format("%d", (int) value);
                        } 
                        // Check if it's a percentage
                        else if (description.contains("%") || description.contains("PERCENT") ||
                                 functionName.contains("PERCENTAGE")) {
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
            }
            
            return "0";
            
        } catch (SQLException e) {
            String errorMsg = e.getMessage();
            
            // Check if function doesn't exist
            if (errorMsg != null && (errorMsg.contains("ORA-00904") || errorMsg.contains("invalid identifier"))) {
                System.err.println("Function not found: " + card.getFuncationName());
                return "Pending";
            }
            // Check for data type conversion errors
            else if (errorMsg != null && (errorMsg.contains("ORA-17059") || errorMsg.contains("Failed to convert"))) {
                System.err.println("Data type error for card: " + card.getDescription());
                return "Pending";
            }
            
            System.err.println("SQL Error for card: " + card.getDescription());
            e.printStackTrace();
            return "Pending";
        } catch (Exception e) {
            System.err.println("General Error for card: " + card.getDescription());
            e.printStackTrace();
            return "N/A";
        }
    }
}