<%@ page import="java.sql.*, db.DBConnection" %> 
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Get branch code from session
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String branchCode = (String) sess.getAttribute("branchCode");
    String lookupType = request.getParameter("type");
    
    // Default to installment type if no type specified
    if (lookupType == null || lookupType.isEmpty()) {
        lookupType = "installmentType";
    }
%>

<style>
table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 10px;
}
th, td {
    border: 1px solid #999;
    padding: 10px;
    cursor: pointer;
}
th {
    background-color: #373279;
    color: white;
    font-weight: bold;
}
tr:hover { 
    background-color: #e8e4fc;
}
.lookup-title {
    font-size: 20px;
    margin-bottom: 10px;
    font-weight: bold;
    color: #373279;
}
</style>

<%
    if ("installmentType".equals(lookupType)) {
        // INSTALLMENT TYPE LOOKUP
        String query = "SELECT INSTALLMENTTYPE_ID, DISCRIPTION FROM HEADOFFICE.INSTALLMENTTYPE ORDER BY INSTALLMENTTYPE_ID";
        
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(query);
        ResultSet rs = ps.executeQuery();
%>

<div class="lookup-title">
    Select Installment Type
</div>

<table>
    <tr>
        <th>Installment Type ID</th>
        <th>Description</th>
    </tr>

<%
        while (rs.next()) {
            String id = rs.getString(1);
            String desc = rs.getString(2);
%>
    <tr onclick="sendBackInstallment('<%=id%>', '<%=desc%>')">
        <td><%=id%></td>
        <td><%=desc%></td>
    </tr>
<% 
        } 
        rs.close();
        ps.close();
        con.close(); 
%>
</table>

<script>
function sendBackInstallment(id, desc) {
    if (window.parent && window.parent.setInstallmentData) {
        window.parent.setInstallmentData(id, desc);
    } else if (window.setInstallmentData) {
        window.setInstallmentData(id, desc);
    } else {
        parent.document.getElementById('installmentTypeId').value = id;
        parent.document.getElementById('installmentType').value = desc;
        parent.closeInstallmentLookup();
    }
}
</script>

<%
    } else if ("socialSector".equals(lookupType)) {
        // SOCIAL SECTOR LOOKUP
        String query = "SELECT SOCIALSECTOR_ID, DESCRIPTION FROM GLOBALCONFIG.SOCIALSECTOR ORDER BY SOCIALSECTOR_ID";
        
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(query);
        ResultSet rs = ps.executeQuery();
%>

<div class="lookup-title">
    Select Social Sector
</div>

<table>
    <tr>
        <th>Social Sector ID</th>
        <th>Description</th>
    </tr>

<%
        while (rs.next()) {
            String id = rs.getString(1);
            String desc = rs.getString(2);
%>
    <tr onclick="sendBackSocialSector('<%=id%>', '<%=desc%>')">
        <td><%=id%></td>
        <td><%=desc%></td>
    </tr>
<% 
        } 
        rs.close();
        ps.close();
        con.close(); 
%>
</table>

<script>
function sendBackSocialSector(id, desc) {
    if (window.parent && window.parent.setSocialSectorData) {
        window.parent.setSocialSectorData(id, desc);
    } else if (window.setSocialSectorData) {
        window.setSocialSectorData(id, desc);
    } else {
        parent.document.getElementById('socialSectorId').value = id;
        parent.document.getElementById('socialSectorDesc').value = desc;
        parent.closeSocialSectorLookup();
    }
}
</script>

<%
    } else if ("socialSubSector".equals(lookupType)) {
        // SOCIAL SUBSECTOR LOOKUP (filtered by sector)
        String sectorId = request.getParameter("sectorId");
        
        if (sectorId == null || sectorId.isEmpty()) {
            out.println("<div style='color:red; padding:20px;'>Error: Social Sector ID is required</div>");
        } else {
            String query = "SELECT SOCIALSUBSECTOR_ID, DESCRIPTION FROM GLOBALCONFIG.SOCIALSUBSECTOR " +
                          "WHERE SOCIALSECTOR_ID = ? ORDER BY SOCIALSUBSECTOR_ID";
            
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, sectorId);
            ResultSet rs = ps.executeQuery();
%>

<div class="lookup-title">
    Select Social SubSector (for Sector ID: <%=sectorId%>)
</div>

<table>
    <tr>
        <th>Social SubSector ID</th>
        <th>Description</th>
    </tr>

<%
            boolean hasRecords = false;
            while (rs.next()) {
                hasRecords = true;
                String id = rs.getString(1);
                String desc = rs.getString(2);
%>
    <tr onclick="sendBackSocialSubSector('<%=id%>', '<%=desc%>')">
        <td><%=id%></td>
        <td><%=desc%></td>
    </tr>
<% 
            }
            
            if (!hasRecords) {
%>
    <tr>
        <td colspan="2" style="text-align:center; color:#999;">
            No subsectors found for this sector
        </td>
    </tr>
<%
            }
            
            rs.close();
            ps.close();
            con.close(); 
%>
</table>

<script>
function sendBackSocialSubSector(id, desc) {
    if (window.parent && window.parent.setSocialSubSectorData) {
        window.parent.setSocialSubSectorData(id, desc);
    } else if (window.setSocialSubSectorData) {
        window.setSocialSubSectorData(id, desc);
    } else {
        parent.document.getElementById('socialSubSectorId').value = id;
        parent.document.getElementById('socialSubSectorDesc').value = desc;
        parent.closeSocialSubSectorLookup();
    }
}
</script>

<%
        }
    } else {
        out.println("<div style='color:red; padding:20px;'>Invalid lookup type</div>");
    }
%>