<%@ page import="java.sql.*, db.DBConnection, org.json.*" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    String scrollNumber = request.getParameter("scrollNumber");
    String workingDate = request.getParameter("workingDate");
    
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        out.print("{\"error\": \"Session expired\"}");
        return;
    }
    
    String branchCode = (String) sess.getAttribute("branchCode");
    
    if (scrollNumber == null || scrollNumber.trim().isEmpty() ||
        workingDate == null || workingDate.trim().isEmpty()) {
        out.print("{\"error\": \"Scroll number and working date are required\"}");
        return;
    }
    
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        con = DBConnection.getConnection();
        
        // Query to fetch data from transaction.dailyscroll table
        String query = "SELECT BRANCH_CODE, SCROLL_DATE, SCROLL_NUMBER, SUBSCROLL_NUMBER, " +
                       "ACCOUNT_CODE, FORACCOUNT_CODE, TRANSACTIONINDICATOR_CODE, AMOUNT, PARTICULAR " +
                       "FROM TRANSACTION.DAILYSCROLL " +
                       "WHERE SCROLL_NUMBER = ? AND SCROLL_DATE = TO_DATE(?, 'DD/MM/YYYY') " +
                       "AND BRANCH_CODE = ? " +
                       "ORDER BY SUBSCROLL_NUMBER";
        
        ps = con.prepareStatement(query);
        ps.setString(1, scrollNumber.trim());
        ps.setString(2, workingDate.trim());
        ps.setString(3, branchCode);
        
        rs = ps.executeQuery();
        
        JSONObject jsonResponse = new JSONObject();
        jsonResponse.put("success", true);
        
        JSONArray rowsArray = new JSONArray();
        int srNo = 1;
        
        while (rs.next()) {
            JSONObject row = new JSONObject();
            row.put("srNo", srNo++);
            row.put("scrollNumber", rs.getString("SCROLL_NUMBER"));
            row.put("accountCode", rs.getString("ACCOUNT_CODE"));
            row.put("forAccountCode", rs.getString("FORACCOUNT_CODE"));
            row.put("transactionIndicator", rs.getString("TRANSACTIONINDICATOR_CODE"));
            row.put("amount", rs.getBigDecimal("AMOUNT"));
            row.put("particular", rs.getString("PARTICULAR"));
            row.put("subscrollNumber", rs.getInt("SUBSCROLL_NUMBER"));
            
            rowsArray.put(row);
        }
        
        jsonResponse.put("rows", rowsArray);
        jsonResponse.put("count", rowsArray.length());
        
        out.print(jsonResponse.toString());
        
    } catch (SQLException e) {
        e.printStackTrace();
        JSONObject errorResponse = new JSONObject();
        errorResponse.put("success", false);
        errorResponse.put("error", "Database error: " + e.getMessage());
        out.print(errorResponse.toString());
        
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (ps != null) try { ps.close(); } catch(SQLException e) {}
        if (con != null) try { con.close(); } catch(SQLException e) {}
    }
%>