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
        
        // ✅ CRITICAL FIX: Get customer data first, then look up codes separately
        String sql = "SELECT " +
                     "TRIM(c.SALUTATION_CODE) as SALUTATION_CODE, " +
                     "TRIM(c.CUSTOMER_NAME) as CUSTOMER_NAME, " +
                     "TRIM(c.ADDRESS1) as ADDRESS1, " +
                     "TRIM(c.ADDRESS2) as ADDRESS2, " +
                     "TRIM(c.ADDRESS3) as ADDRESS3, " +
                     "TRIM(c.COUNTRY) as COUNTRY, " +
                     "TRIM(c.STATE) as STATE, " +
                     "TRIM(c.CITY) as CITY, " +
                     "c.ZIP " +
                     "FROM CUSTOMERS c " +
                     "WHERE c.CUSTOMER_ID = ? AND c.STATUS = 'A'";
        
        ps = conn.prepareStatement(sql);
        ps.setString(1, customerId);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            JSONObject customer = new JSONObject();
            
            // Get basic fields
            String salutationCode = rs.getString("SALUTATION_CODE");
            String customerName = rs.getString("CUSTOMER_NAME");
            String address1 = rs.getString("ADDRESS1");
            String address2 = rs.getString("ADDRESS2");
            String address3 = rs.getString("ADDRESS3");
            String countryName = rs.getString("COUNTRY");
            String stateName = rs.getString("STATE");
            String cityName = rs.getString("CITY");
            int zip = rs.getInt("ZIP");
            
            customer.put("customerName", customerName != null ? customerName : "");
            customer.put("address1", address1 != null ? address1 : "");
            customer.put("address2", address2 != null ? address2 : "");
            customer.put("address3", address3 != null ? address3 : "");
            customer.put("zip", rs.wasNull() ? 0 : zip);
            
            // ✅ SALUTATION: Use the code directly (even if NULL, we'll handle it in JS)
            customer.put("salutationCode", salutationCode != null ? salutationCode : "");
            
            // ✅ CITY: Look up code from CITY table
            String cityCode = null;
            if (cityName != null && !cityName.trim().isEmpty()) {
                PreparedStatement psCity = conn.prepareStatement(
                    "SELECT CITY_CODE FROM GLOBALCONFIG.CITY WHERE UPPER(TRIM(NAME)) = UPPER(TRIM(?))"
                );
                psCity.setString(1, cityName);
                ResultSet rsCity = psCity.executeQuery();
                if (rsCity.next()) {
                    cityCode = rsCity.getString("CITY_CODE");
                }
                rsCity.close();
                psCity.close();
            }
            // If code found, use it; otherwise use the name itself
            customer.put("city", cityCode != null ? cityCode.trim() : (cityName != null ? cityName : ""));
            
            // ✅ STATE: Look up code from STATE table
            String stateCode = null;
            if (stateName != null && !stateName.trim().isEmpty()) {
                PreparedStatement psState = conn.prepareStatement(
                    "SELECT STATE_CODE FROM GLOBALCONFIG.STATE WHERE UPPER(TRIM(NAME)) = UPPER(TRIM(?)) OR UPPER(TRIM(STATE_CODE)) = UPPER(TRIM(?))"
                );
                psState.setString(1, stateName);
                psState.setString(2, stateName); // Also try matching the code directly
                ResultSet rsState = psState.executeQuery();
                if (rsState.next()) {
                    stateCode = rsState.getString("STATE_CODE");
                }
                rsState.close();
                psState.close();
            }
            // If code found, use it; otherwise use the name/code as stored
            customer.put("state", stateCode != null ? stateCode.trim() : (stateName != null ? stateName : ""));
            
            // ✅ COUNTRY: Look up code from COUNTRY table
            String countryCode = null;
            if (countryName != null && !countryName.trim().isEmpty()) {
                PreparedStatement psCountry = conn.prepareStatement(
                    "SELECT COUNTRY_CODE FROM GLOBALCONFIG.COUNTRY WHERE UPPER(TRIM(NAME)) = UPPER(TRIM(?)) OR UPPER(TRIM(COUNTRY_CODE)) = UPPER(TRIM(?))"
                );
                psCountry.setString(1, countryName);
                psCountry.setString(2, countryName); // Also try matching the code directly
                ResultSet rsCountry = psCountry.executeQuery();
                if (rsCountry.next()) {
                    countryCode = rsCountry.getString("COUNTRY_CODE");
                }
                rsCountry.close();
                psCountry.close();
            }
            // If code found, use it; otherwise use the name/code as stored
            customer.put("country", countryCode != null ? countryCode.trim() : (countryName != null ? countryName : ""));
            
            jsonResponse.put("success", true);
            jsonResponse.put("customer", customer);
            
            // ✅ ENHANCED DEBUG: Show detailed lookup results
            System.out.println("✅ Customer Data Retrieved for ID: " + customerId);
            System.out.println("   Salutation Code: " + (salutationCode != null ? "'" + salutationCode + "'" : "NULL"));
            System.out.println("   City: Name='" + (cityName != null ? cityName : "NULL") + "' -> Code='" + (cityCode != null ? cityCode : "NOT_FOUND") + "' -> Using='" + customer.getString("city") + "'");
            System.out.println("   State: Name='" + (stateName != null ? stateName : "NULL") + "' -> Code='" + (stateCode != null ? stateCode : "NOT_FOUND") + "' -> Using='" + customer.getString("state") + "'");
            System.out.println("   Country: Name='" + (countryName != null ? countryName : "NULL") + "' -> Code='" + (countryCode != null ? countryCode : "NOT_FOUND") + "' -> Using='" + customer.getString("country") + "'");
            
        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Customer not found or not authorized");
        }
        
    } catch (Exception e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Database error: " + e.getMessage());
        e.printStackTrace();
        System.out.println("❌ Error fetching customer: " + e.getMessage());
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (ps != null) ps.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
    
    out.print(jsonResponse.toString());
%>