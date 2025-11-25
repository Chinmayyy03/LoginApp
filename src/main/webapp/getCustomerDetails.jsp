<%@ page import="java.sql.*, db.DBConnection, org.json.JSONObject" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String customerId = request.getParameter("customerId");
    JSONObject jsonResponse = new JSONObject();
    
    if (customerId == null || customerId.trim().isEmpty()) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Customer ID is required");
        out.print(jsonResponse.toString());
        return;
    }
    
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        conn = DBConnection.getConnection();
        
        // Query to fetch customer details
        String sql = "SELECT SALUTATION_CODE, CUSTOMER_NAME, ADDRESS1, ADDRESS2, ADDRESS3, " +
                     "COUNTRY, STATE, CITY, ZIP " +
                     "FROM CUSTOMERS " +
                     "WHERE CUSTOMER_ID = ? AND STATUS = 'A'";
        
        ps = conn.prepareStatement(sql);
        ps.setString(1, customerId);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            JSONObject customer = new JSONObject();
            
            // Get all fields with null checks
            customer.put("salutationCode", rs.getString("SALUTATION_CODE") != null ? rs.getString("SALUTATION_CODE") : "");
            customer.put("customerName", rs.getString("CUSTOMER_NAME") != null ? rs.getString("CUSTOMER_NAME") : "");
            customer.put("address1", rs.getString("ADDRESS1") != null ? rs.getString("ADDRESS1") : "");
            customer.put("address2", rs.getString("ADDRESS2") != null ? rs.getString("ADDRESS2") : "");
            customer.put("address3", rs.getString("ADDRESS3") != null ? rs.getString("ADDRESS3") : "");
            customer.put("country", rs.getString("COUNTRY") != null ? rs.getString("COUNTRY") : "INDIA");
            customer.put("state", rs.getString("STATE") != null ? rs.getString("STATE") : "Karnataka");
            customer.put("city", rs.getString("CITY") != null ? rs.getString("CITY") : "");
            
            // Handle ZIP as integer
            int zip = rs.getInt("ZIP");
            customer.put("zip", rs.wasNull() ? 0 : zip);
            
            jsonResponse.put("success", true);
            jsonResponse.put("customer", customer);
        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Customer not found or not authorized");
        }
        
    } catch (Exception e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Database error: " + e.getMessage());
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (ps != null) ps.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
    
    out.print(jsonResponse.toString());
%>