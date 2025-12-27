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
        String sql = "SELECT SR_NUMBER, DESCRIPTION, FUNCATION_NAME, PARAMITAR, TABLE_NAME " +
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
                cards.add(card);
            }
        }
        return cards;
    }

    /**
     * Execute the database function to get card value
     * This calls your existing database functions
     */
    public double executeCardFunction(String functionName, String parameters, String tableName, String branchCode) throws SQLException {
        double result = 0.0;
        
        if (functionName == null || functionName.trim().isEmpty()) {
            return result;
        }
        
        // Parse parameters
        String[] params = parameters != null && !parameters.trim().isEmpty() ? parameters.split(",") : new String[0];
        
        // Try different function signatures
        // First try: FUNCTION(branchCode, param1, param2)
        try {
            result = callFunctionWithBranchFirst(functionName, params, branchCode);
            return result;
        } catch (SQLException e1) {
            // If that fails, try: FUNCTION(param1, branchCode, param2)
            try {
                result = callFunctionWithBranchMiddle(functionName, params, branchCode);
                return result;
            } catch (SQLException e2) {
                // If that fails too, try: FUNCTION(branchCode)
                try {
                    result = callFunctionWithBranchOnly(functionName, branchCode);
                    return result;
                } catch (SQLException e3) {
                    System.err.println("Error executing function: " + functionName);
                    System.err.println("Parameters: " + parameters);
                    e3.printStackTrace();
                    throw e3;
                }
            }
        }
    }

    /**
     * Try calling function with branch code as first parameter
     * FUNCTION(branchCode, param1, param2, ...)
     */
    private double callFunctionWithBranchFirst(String functionName, String[] params, String branchCode) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT ").append(functionName).append("(");
        sql.append("?"); // Branch code first
        
        for (int i = 0; i < params.length; i++) {
            sql.append(", ?");
        }
        sql.append(") FROM DUAL");
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            ps.setString(1, branchCode);
            
            for (int i = 0; i < params.length; i++) {
                setParameter(ps, i + 2, params[i].trim());
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        }
        return 0.0;
    }

    /**
     * Try calling function with branch code in middle
     * FUNCTION(param1, branchCode, param2, ...)
     */
    private double callFunctionWithBranchMiddle(String functionName, String[] params, String branchCode) throws SQLException {
        if (params.length == 0) {
            throw new SQLException("No parameters for middle position");
        }
        
        StringBuilder sql = new StringBuilder("SELECT ").append(functionName).append("(");
        sql.append("?"); // First param
        sql.append(", ?"); // Branch code
        
        for (int i = 1; i < params.length; i++) {
            sql.append(", ?");
        }
        sql.append(") FROM DUAL");
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            setParameter(ps, 1, params[0].trim()); // First param
            ps.setString(2, branchCode); // Branch code
            
            for (int i = 1; i < params.length; i++) {
                setParameter(ps, i + 2, params[i].trim());
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        }
        return 0.0;
    }

    /**
     * Try calling function with only branch code
     * FUNCTION(branchCode)
     */
    private double callFunctionWithBranchOnly(String functionName, String branchCode) throws SQLException {
        String sql = "SELECT " + functionName + "(?) FROM DUAL";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, branchCode);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        }
        return 0.0;
    }

    /**
     * Set parameter based on its value
     */
    private void setParameter(PreparedStatement ps, int index, String param) throws SQLException {
        if (param.equalsIgnoreCase("DATE")) {
            ps.setDate(index, new java.sql.Date(System.currentTimeMillis()));
        } else {
            ps.setString(index, param);
        }
    }

    /**
     * Get card value with proper formatting
     */
    public String getFormattedCardValue(DashboardCard card, String branchCode) {
        try {
            // Check for null values
            if (card.getDescription() == null || card.getFuncationName() == null) {
                return "N/A";
            }
            
            double value = executeCardFunction(
                card.getFuncationName(), 
                card.getParamitar(), 
                card.getTableName(), 
                branchCode
            );
            card.setValue(value);
            
            String description = card.getDescription().toUpperCase();
            String functionName = card.getFuncationName().toUpperCase();
            
            // Check if it's a count
            if (description.contains("CUSTOMER") || description.contains("MEMBER") || 
                description.contains("COUNT") || description.contains("TYPE") ||
                functionName.contains("CUSTOMER")) {
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
        } catch (SQLException e) {
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