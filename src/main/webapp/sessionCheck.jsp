<%@ page contentType="application/json; charset=UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    HttpSession existingSession = request.getSession(false);
    boolean isValid = false;
    if (existingSession != null) {
        String userId = (String) existingSession.getAttribute("userId");
        String branchCode = (String) existingSession.getAttribute("branchCode");
        isValid = (userId != null && branchCode != null);
    }
%>
{"sessionValid": <%= isValid %>}