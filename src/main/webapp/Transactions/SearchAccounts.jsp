<%@ page import="java.sql.*, db.DBConnection, java.util.*, org.json.*" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        out.print("{\"error\": \"Only POST method allowed\", \"accounts\": []}");
        return;
    }

    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        out.print("{\"error\": \"Session expired\", \"accounts\": []}");
        return;
    }

    String branchCode = (String) sess.getAttribute("branchCode");
    String searchNumber = request.getParameter("searchNumber");
    String category = request.getParameter("category");
    
    if (searchNumber == null || searchNumber.trim().isEmpty() || 
        category == null || category.trim().isEmpty()) {
        out.print("{\"error\": \"Invalid parameters\", \"accounts\": []}");
        return;
    }

    searchNumber = searchNumber.trim();
    category = category.trim().toLowerCase();

    if (!searchNumber.matches("\\d+")) {
        out.print("{\"error\": \"Invalid search number\", \"accounts\": []}");
        return;
    }

    if (searchNumber.length() < 3) {
        out.print("{\"error\": \"Search term too short\", \"accounts\": []}");
        return;
    }

    // PAD THE SEARCH NUMBER WITH LEADING ZEROS TO MAKE IT 7 DIGITS
    String paddedSearchNumber = String.format("%07d", Integer.parseInt(searchNumber));

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        con = DBConnection.getConnection();
        
        String query = "";
        
        if ("loan".equals(category)) {
            // Search from the END of account code (last 7 digits)
            query = "SELECT ACCOUNT_CODE, NAME " +
                    "FROM ACCOUNT.ACCOUNT " +
                    "WHERE SUBSTR(ACCOUNT_CODE, 1, 4) = ? " +
                    "AND SUBSTR(ACCOUNT_CODE, 5, 1) IN ('5','7') " +
                    "AND SUBSTR(ACCOUNT_CODE, -7) LIKE ? " +  // Last 7 digits
                    "AND ACCOUNT_STATUS = 'L' " +
                    "ORDER BY ACCOUNT_CODE";
        } else {
            String productCodePattern = "";
            switch(category) {
                case "saving": productCodePattern = "2"; break;
                case "deposit": productCodePattern = "4"; break;
                case "pigmy": productCodePattern = "6"; break;
                case "current": productCodePattern = "1"; break;
                case "cc": productCodePattern = "3"; break;
                default: 
                    out.print("{\"error\": \"Invalid category\", \"accounts\": []}");
                    return;
            }
            
            // Search from the END of account code (last 7 digits)
            query = "SELECT ACCOUNT_CODE, NAME " +
                    "FROM ACCOUNT.ACCOUNT " +
                    "WHERE SUBSTR(ACCOUNT_CODE, 1, 4) = ? " +
                    "AND SUBSTR(ACCOUNT_CODE, 5, 1) = ? " +
                    "AND SUBSTR(ACCOUNT_CODE, -7) LIKE ? " +  // Last 7 digits
                    "AND ACCOUNT_STATUS = 'L' " +
                    "ORDER BY ACCOUNT_CODE";
        }
        
        ps = con.prepareStatement(query);
        ps.setString(1, branchCode);
        
        if ("loan".equals(category)) {
            // Use padded number with wildcards for pattern matching
            ps.setString(2, "%" + paddedSearchNumber + "%");
        } else {
            String productCodePattern = "";
            switch(category) {
                case "saving": productCodePattern = "2"; break;
                case "deposit": productCodePattern = "4"; break;
                case "pigmy": productCodePattern = "6"; break;
                case "current": productCodePattern = "1"; break;
                case "cc": productCodePattern = "3"; break;
            }
            ps.setString(2, productCodePattern);
            // Use padded number with wildcards for pattern matching
            ps.setString(3, "%" + paddedSearchNumber + "%");
        }
        
        rs = ps.executeQuery();
        
        JSONObject jsonResponse = new JSONObject();
        jsonResponse.put("success", true);
        
        JSONArray accountsArray = new JSONArray();
        int count = 0;
        
        while (rs.next()) {
            JSONObject account = new JSONObject();
            account.put("code", rs.getString("ACCOUNT_CODE"));
            account.put("name", rs.getString("NAME"));
            accountsArray.put(account);
            count++;
        }
        
        jsonResponse.put("count", count);
        jsonResponse.put("accounts", accountsArray);
        jsonResponse.put("searchNumber", searchNumber);
        jsonResponse.put("paddedSearchNumber", paddedSearchNumber);
        jsonResponse.put("category", category);
        
        out.print(jsonResponse.toString());
        
    } catch (NumberFormatException e) {
        JSONObject errorResponse = new JSONObject();
        errorResponse.put("success", false);
        errorResponse.put("error", "Invalid number format");
        errorResponse.put("accounts", new JSONArray());
        out.print(errorResponse.toString());
        
    } catch (SQLException e) {
        e.printStackTrace();
        
        JSONObject errorResponse = new JSONObject();
        errorResponse.put("success", false);
        errorResponse.put("error", "Database error: " + e.getMessage());
        errorResponse.put("accounts", new JSONArray());
        
        out.print(errorResponse.toString());
        
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e) { e.printStackTrace(); }
        if (ps != null) try { ps.close(); } catch(SQLException e) { e.printStackTrace(); }
        if (con != null) try { con.close(); } catch(SQLException e) { e.printStackTrace(); }
    }
%>