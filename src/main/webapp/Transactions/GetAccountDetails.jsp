<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    String accountCode = request.getParameter("accountCode");
    
    if (accountCode == null || accountCode.trim().isEmpty()) {
        out.print("{\"error\": \"Account code is required\"}");
        return;
    }
    
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        con = DBConnection.getConnection();
        
        // Query to get balances and product name using function
        String query = "SELECT " +
                       "LEDGERBALANCE, " +
                       "AVAILABLEBALANCE, " +
                       "FN_GET_PRODUCT_DESC(SUBSTR(?, 5, 3)) AS PRODUCT_NAME " +
                       "FROM BALANCE.ACCOUNT " +
                       "WHERE ACCOUNT_CODE = ?";
        
        ps = con.prepareStatement(query);
        ps.setString(1, accountCode);  // For the function
        ps.setString(2, accountCode);  // For the WHERE clause
        rs = ps.executeQuery();
        
        if (rs.next()) {
            out.print("{");
            out.print("\"success\": true,");
            out.print("\"productName\": \"" + (rs.getString("PRODUCT_NAME") != null ? rs.getString("PRODUCT_NAME") : "") + "\",");
            out.print("\"ledgerBalance\": \"" + (rs.getBigDecimal("LEDGERBALANCE") != null ? rs.getBigDecimal("LEDGERBALANCE") : "0.00") + "\",");
            out.print("\"availableBalance\": \"" + (rs.getBigDecimal("AVAILABLEBALANCE") != null ? rs.getBigDecimal("AVAILABLEBALANCE") : "0.00") + "\"");
            out.print("}");
        } else {
            out.print("{\"error\": \"Account not found in balance table\"}");
        }
        
    } catch (SQLException e) {
        e.printStackTrace();
        out.print("{\"error\": \"Database error: " + e.getMessage() + "\"}");
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (ps != null) try { ps.close(); } catch(SQLException e) {}
        if (con != null) try { con.close(); } catch(SQLException e) {}
    }
%>