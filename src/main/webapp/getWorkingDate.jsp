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
    PreparedStatement psBank = null;
    ResultSet rsBank = null;

    try {
        conn = DBConnection.getConnection();
        
        // ✅ Bank Code (Change this to switch banks)
        String bankCode = "0100";
        
        // ✅ Step 1: Fetch Bank Name from GLOBALCONFIG.BANK
        String bankName = "";
        String bankShortName = "";
        
        String bankQuery = "SELECT NAME, SHORTNAME FROM GLOBALCONFIG.BANK WHERE BANK_CODE = ?";
        psBank = conn.prepareStatement(bankQuery);
        psBank.setString(1, bankCode);
        rsBank = psBank.executeQuery();
        
        if (rsBank.next()) {
            bankName = rsBank.getString("NAME");
            bankShortName = rsBank.getString("SHORTNAME");
            
            // Store in session for future use
            session.setAttribute("bankCode", bankCode);
            session.setAttribute("bankName", bankName);
            session.setAttribute("bankShortName", bankShortName);
        } else {
            bankName = "Bank Not Found";
            bankShortName = "N/A";
        }
        
        rsBank.close();
        psBank.close();
        
        // ✅ Step 2: Fetch Working Date
        String functionCall = "{? = call SYSTEM.FN_GET_WORKINGDATE(?, ?)}";
        cstmt = conn.prepareCall(functionCall);
        cstmt.registerOutParameter(1, Types.DATE);
        cstmt.setString(2, bankCode);
        cstmt.setString(3, branchCode);
        cstmt.execute();
        
        Date workingDate = cstmt.getDate(1);
        
        // Store working date in session
        session.setAttribute("workingDate", workingDate);
        
        SimpleDateFormat sdf = new SimpleDateFormat("EEEE, MMMM d, yyyy");
        String formattedDate = sdf.format(workingDate);
        
        // ✅ Step 3: Return JSON with both Bank Name and Working Date
        out.print("{");
        out.print("\"bankName\": \"" + bankName.replace("\"", "'") + "\",");
        out.print("\"bankShortName\": \"" + bankShortName.replace("\"", "'") + "\",");
        out.print("\"bankCode\": \"" + bankCode + "\",");
        out.print("\"workingDate\": \"" + formattedDate + "\"");
        out.print("}");
        
    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"error\": \"" + e.getMessage().replace("\"", "'") + "\"}");
    } finally {
        try { if (rsBank != null) rsBank.close(); } catch (Exception ignored) {}
        try { if (psBank != null) psBank.close(); } catch (Exception ignored) {}
        try { if (cstmt != null) cstmt.close(); } catch (Exception ignored) {}
        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
    }
%>