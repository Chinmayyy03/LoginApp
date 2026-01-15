<%@ page import="java.sql.*, db.DBConnection, org.json.*" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        con = DBConnection.getConnection();
        
        // Query to get loan recovery sequence columns ordered by SEQUENCE_NO
        String query = "SELECT SR_NO, DISCRIPTATION, SEQUENCE_NO, COLUMN_NAME " +
                       "FROM HEADOFFICE.LOAN_RECOV_SEQ " +
                       "ORDER BY SEQUENCE_NO";
        
        ps = con.prepareStatement(query);
        rs = ps.executeQuery();
        
        JSONObject jsonResponse = new JSONObject();
        jsonResponse.put("success", true);
        
        JSONArray columnsArray = new JSONArray();
        
        while (rs.next()) {
            JSONObject column = new JSONObject();
            column.put("srNo", rs.getInt("SR_NO"));
            
            String description = rs.getString("DISCRIPTATION");
            String columnName = rs.getString("COLUMN_NAME");
            
            // Skip rows with null or empty column names
            if (columnName == null || columnName.trim().isEmpty()) {
                continue;
            }
            
            column.put("description", description != null ? description : "");
            column.put("sequenceNo", rs.getInt("SEQUENCE_NO"));
            column.put("columnName", columnName.trim());
            
            columnsArray.put(column);
        }
        
        jsonResponse.put("columns", columnsArray);
        jsonResponse.put("count", columnsArray.length());
        
        out.print(jsonResponse.toString());
        
    } catch (SQLException e) {
        e.printStackTrace();
        
        JSONObject errorResponse = new JSONObject();
        errorResponse.put("success", false);
        errorResponse.put("error", "Database error: " + e.getMessage());
        errorResponse.put("columns", new JSONArray());
        
        out.print(errorResponse.toString());
        
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e) { e.printStackTrace(); }
        if (ps != null) try { ps.close(); } catch(SQLException e) { e.printStackTrace(); }
        if (con != null) try { con.close(); } catch(SQLException e) { e.printStackTrace(); }
    }
%>