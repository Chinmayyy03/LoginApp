<%@ page import="java.sql.*, db.DBConnection, servlet.DashboardService, servlet.DashboardCard, java.util.List" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    
    String branchCode = (String) session.getAttribute("branchCode");
    if (branchCode == null) {
        out.print("{\"error\": \"Not authenticated\"}");
        return;
    }
    
    String srParam = request.getParameter("sr");
    if (srParam == null || srParam.trim().isEmpty()) {
        out.print("{\"error\": \"Missing sr parameter\"}");
        return;
    }
    
    try {
        int srNumber = Integer.parseInt(srParam);
        
        DashboardService service = new DashboardService();
        List<DashboardCard> cards = service.getDashboardCards();
        
        // Find the card
        DashboardCard targetCard = null;
        for (DashboardCard card : cards) {
            if (card.getSrNumber() == srNumber) {
                targetCard = card;
                break;
            }
        }
        
        if (targetCard == null) {
            out.print("{\"error\": \"Card not found\"}");
            return;
        }
        
        // Get the value
        String formattedValue = service.getFormattedCardValue(targetCard, branchCode);
        
        // Return JSON
        out.print("{\"value\": \"" + formattedValue.replace("\"", "\\\"") + "\", \"status\": \"success\"}");
        
    } catch (NumberFormatException e) {
        out.print("{\"error\": \"Invalid sr parameter\"}");
    } catch (Exception e) {
        out.print("{\"error\": \"" + e.getMessage().replace("\"", "\\\"") + "\"}");
    }
%>