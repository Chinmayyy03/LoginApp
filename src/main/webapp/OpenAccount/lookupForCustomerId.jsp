<%@ page import="java.sql.*, db.DBConnection, java.util.*, java.util.stream.Collectors" %> 
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String branchCode = (String) sess.getAttribute("branchCode");
    
    // ✅ Get excludeCustomerIds parameter (comma-separated list)
    String excludeCustomerIdsParam = request.getParameter("excludeCustomerIds");
    List<String> excludeCustomerIds = new ArrayList<>();
    
    if (excludeCustomerIdsParam != null && !excludeCustomerIdsParam.trim().isEmpty()) {
        String[] idsArray = excludeCustomerIdsParam.split(",");
        for (String id : idsArray) {
            String trimmedId = id.trim();
            if (!trimmedId.isEmpty()) {
                excludeCustomerIds.add(trimmedId);
            }
        }
    }
    
    System.out.println("🔍 Customer Lookup - Excluding IDs: " + excludeCustomerIds);
    
    // Build dynamic query with placeholders for excluded IDs
    StringBuilder queryBuilder = new StringBuilder();
    queryBuilder.append("SELECT CUSTOMER_ID, CUSTOMER_NAME, CATEGORY_CODE, RISK_CATEGORY ");
    queryBuilder.append("FROM CUSTOMERS ");
    queryBuilder.append("WHERE BRANCH_CODE = ? AND STATUS = 'A'");
    
    if (!excludeCustomerIds.isEmpty()) {
        queryBuilder.append(" AND CUSTOMER_ID NOT IN (");
        queryBuilder.append(excludeCustomerIds.stream()
            .map(id -> "?")
            .collect(Collectors.joining(", ")));
        queryBuilder.append(")");
    }
    
    queryBuilder.append(" ORDER BY CUSTOMER_ID");
    
    String query = queryBuilder.toString();
    System.out.println("📌 Query: " + query);

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        con = DBConnection.getConnection();
        ps = con.prepareStatement(query);
        
        // Set branch code parameter
        ps.setString(1, branchCode);
        
        // Set excluded customer ID parameters
        int paramIndex = 2;
        for (String excludeId : excludeCustomerIds) {
            ps.setString(paramIndex++, excludeId);
        }
        
        rs = ps.executeQuery();
%>

<div class="lookup-title">🔍 Select Customer</div>

<% if (!excludeCustomerIds.isEmpty()) { %>
<div style="text-align:center; margin-bottom: 15px; padding: 10px; background: #fff3cd; border-radius: 6px; color: #856404;">
    <strong>ℹ️ Note:</strong> <%= excludeCustomerIds.size() %> customer(s) already selected are excluded from this list
</div>
<% } %>

<div class="search-box">
    <input type="text" 
           id="customerSearch" 
           placeholder="Search by Customer ID or Name..." 
           onkeyup="searchCustomer()">
</div>

<div class="customer-count">
    Total Available Customers: <strong id="customerCount">0</strong>
</div>

<div class="table-container">
    <table id="customerTable">
        <thead>
            <tr>
                <th>Customer ID</th>
                <th>Customer Name</th>
                <th>Category Code</th>
                <th>Risk Category</th>
            </tr>
        </thead>
        <tbody>
<%
        boolean hasResults = false;
        int totalCount = 0;
        
        while (rs.next()) {
            hasResults = true;
            totalCount++;
            
            String customerId = rs.getString("CUSTOMER_ID");
            String customerName = rs.getString("CUSTOMER_NAME");
            String categoryCode = rs.getString("CATEGORY_CODE");
            String riskCategory = rs.getString("RISK_CATEGORY");
            
            customerName = (customerName != null) ? customerName : "";
            categoryCode = (categoryCode != null) ? categoryCode : "";
            riskCategory = (riskCategory != null) ? riskCategory : "";
%>
            <tr onclick="setCustomerData('<%= customerId %>', '<%= customerName.replace("'", "\\'") %>', '<%= categoryCode %>', '<%= riskCategory %>')">
                <td><%= customerId %></td>
                <td><%= customerName %></td>
                <td><%= categoryCode %></td>
                <td><%= riskCategory %></td>
            </tr>
<%
        }
        
        if (!hasResults) {
            String message = excludeCustomerIds.isEmpty() 
                ? "⚠️ No Authorized Customers Found<br><br>Please add and authorize customers first."
                : "⚠️ No Available Customers Found<br><br>All authorized customers in this branch are already selected in other sections.";
%>
        <tr>
            <td colspan="4" style="text-align:center;padding:40px;color:#666;">
                <strong><%= message %></strong>
            </td>
        </tr>
<%
        }
%>
        </tbody>
    </table>
</div>

<script>
document.getElementById('customerCount').textContent = '<%= totalCount %>';

function searchCustomer() {
    const input = document.getElementById('customerSearch');
    const filter = input.value.toUpperCase();
    const table = document.getElementById('customerTable');
    const tbody = table.getElementsByTagName('tbody')[0];
    const rows = tbody.getElementsByTagName('tr');
    
    let visibleCount = 0;
    
    for (let i = 0; i < rows.length; i++) {
        const cells = rows[i].getElementsByTagName('td');
        
        // Skip "no results" row
        if (cells.length === 1) continue;
        
        let found = false;
        
        // Search in Customer ID and Name columns only
        for (let j = 0; j < Math.min(cells.length, 2); j++) {
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
    
    document.getElementById('customerCount').textContent = visibleCount;
}
</script>

<%
    } catch (Exception e) {
        out.println("<div style='text-align:center;padding:40px;color:red;'>");
        out.println("<strong>❌ Error Loading Customers</strong><br><br>");
        out.println("Error: " + e.getMessage());
        out.println("</div>");
        e.printStackTrace();
        System.out.println("❌ Error in customer lookup: " + e.getMessage());
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (ps != null) ps.close(); } catch (Exception ex) {}
        try { if (con != null) con.close(); } catch (Exception ex) {}
    }
%>