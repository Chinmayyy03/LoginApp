<%@ page import="java.sql.*, db.DBConnection" %> 
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String query = "SELECT INSTALLMENTTYPE_ID, DISCRIPTION " +
                   "FROM HEADOFFICE.INSTALLMENTTYPE " +
                   "ORDER BY INSTALLMENTTYPE_ID";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        con = DBConnection.getConnection();
        ps = con.prepareStatement(query);
        rs = ps.executeQuery();
%>

<div class="lookup-title">🔍 Select Installment Type</div>

<div class="search-box">
    <input type="text" 
           id="installmentSearch" 
           placeholder="Search by ID or Description..." 
           onkeyup="searchInstallment()">
</div>

<div class="customer-count">
    Total Installment Types: <strong id="installmentCount">0</strong>
</div>

<div class="table-container">
    <table id="installmentTable">
        <thead>
            <tr>
                <th>Installment Type ID</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
<%
        boolean hasResults = false;
        int totalCount = 0;
        
        while (rs.next()) {
            hasResults = true;
            totalCount++;
            
            String installmentTypeId = rs.getString("INSTALLMENTTYPE_ID");
            String installmentType = rs.getString("DISCRIPTION");
            
            installmentTypeId = (installmentTypeId != null) ? installmentTypeId : "";
            installmentType = (installmentType != null) ? installmentType : "";
%>
<%
    String sanitizedType = installmentType.replace("'", "\\'");
%>

<tr onclick="setInstallmentData('<%= installmentTypeId %>', '<%= sanitizedType %>')">

                <td><%= installmentTypeId %></td>
                <td><%= installmentType %></td>
            </tr>
<%
        }
        
        if (!hasResults) {
%>
        <tr>
            <td colspan="2" style="text-align:center;padding:40px;color:#666;">
                <strong>⚠️ No Installment Types Found</strong>
            </td>
        </tr>
<%
        }
%>
        </tbody>
    </table>
</div>

<script>
document.getElementById('installmentCount').textContent = '<%= totalCount %>';

function searchInstallment() {
    const input = document.getElementById('installmentSearch');
    const filter = input.value.toUpperCase();
    const table = document.getElementById('installmentTable');
    const tbody = table.getElementsByTagName('tbody')[0];
    const rows = tbody.getElementsByTagName('tr');
    
    let visibleCount = 0;
    
    for (let i = 0; i < rows.length; i++) {
        const cells = rows[i].getElementsByTagName('td');
        
        if (cells.length === 1) continue;
        
        let found = false;
        
        for (let j = 0; j < cells.length; j++) {
            const cellText = cells[j].textContent || cells[j].innerText;
            if (cellText.toUpperCase().indexOf(filter) > -1) {
                found = true;
                break;
            }
        }
        
        if (found) {
            rows[i].style.display = '';
            visibleCount++;
        } else {
            rows[i].style.display = 'none';
        }
    }
    
    document.getElementById('installmentCount').textContent = visibleCount;
}
</script>

<%
    } catch (Exception e) {
        out.println("<div style='text-align:center;padding:40px;color:red;'>");
        out.println("<strong>❌ Error Loading Installment Types</strong><br><br>");
        out.println("Error: " + e.getMessage());
        out.println("</div>");
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (ps != null) ps.close(); } catch (Exception ex) {}
        try { if (con != null) con.close(); } catch (Exception ex) {}
    }
%>
