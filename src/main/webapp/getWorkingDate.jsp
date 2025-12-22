<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String branchCode = (String) session.getAttribute("branchCode");
    
    if (branchCode == null) {
        out.print("{\"error\": \"Session expired\"}");
        return;
    }

    Connection conn = null;
    CallableStatement cstmt = null;

    try {
        conn = DBConnection.getConnection();
        
        // Default bank code is 0100 for all branches
        String bankCode = "0100";
        
        // Call the function to get working date
        String functionCall = "{? = call SYSTEM.FN_GET_WORKINGDATE(?, ?)}";
        cstmt = conn.prepareCall(functionCall);
        cstmt.registerOutParameter(1, Types.DATE);
        cstmt.setString(2, bankCode);
        cstmt.setString(3, branchCode);
        cstmt.execute();
        
        Date workingDate = cstmt.getDate(1);
        
        // Format the date to match JavaScript's toLocaleDateString format
        SimpleDateFormat sdf = new SimpleDateFormat("EEEE, MMMM d, yyyy");
        String formattedDate = sdf.format(workingDate);
        
        // Return JSON response
        out.print("{\"workingDate\": \"" + formattedDate + "\"}");
        
    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"error\": \"" + e.getMessage().replace("\"", "'") + "\"}");
    } finally {
        try { if (cstmt != null) cstmt.close(); } catch (Exception ignored) {}
        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
    }
%>