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
    
    // Build SQL query to fetch only authorized customers
    String query = "SELECT CUSTOMER_ID, CUSTOMER_NAME, CATEGORY_CODE, RISK_CATEGORY " +
                   "FROM CUSTOMERS " +
                   "WHERE BRANCH_CODE = ? AND STATUS = 'A' " +
                   "ORDER BY CUSTOMER_ID";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        con = DBConnection.getConnection();
        ps = con.prepareStatement(query);
        ps.setString(1, branchCode);
        rs = ps.executeQuery();
%>

<style>
.lookup-container {
    padding: 10px;
}

.lookup-title {
    font-size: 24px;
    margin-bottom: 20px;
    font-weight: bold;
    color: #373279;
    text-align: center;
}

.search-box {
    margin-bottom: 20px;
}

.search-box input {
    width: 100%;
    padding: 12px 15px;
    font-size: 15px;
    border: 2px solid #9c8ed8;
    border-radius: 8px;
    background-color: #f5f3ff;
    box-sizing: border-box;
}

.search-box input:focus {
    outline: none;
    border-color: #373279;
    background-color: #fff;
}

.table-container {
    max-height: 450px;
    overflow-y: auto;
    border: 1px solid #ddd;
    border-radius: 8px;
    background: white;
}

table {
    width: 100%;
    border-collapse: collapse;
}

th, td {
    border: 1px solid #ddd;
    padding: 12px 15px;
    text-align: left;
}

th {
    background-color: #373279;
    color: white;
    font-weight: bold;
    position: sticky;
    top: 0;
    z-index: 10;
}

tbody tr {
    transition: all 0.2s;
}

tbody tr:hover {
    background-color: #e8e4fc;
    cursor: pointer;
    transform: scale(1.01);
}

tbody tr:nth-child(even) {
    background-color: #f9f9f9;
}

.no-results {
    text-align: center;
    padding: 40px;
    color: #666;
    font-size: 16px;
}

.customer-count {
    text-align: right;
    margin-bottom: 10px;
    color: #666;
    font-size: 14px;
}

/* Scrollbar styling */
.table-container::-webkit-scrollbar {
    width: 8px;
}

.table-container::-webkit-scrollbar-track {
    background: #f1f1f1;
}

.table-container::-webkit-scrollbar-thumb {
    background: #888;
    border-radius: 4px;
}

.table-container::-webkit-scrollbar-thumb:hover {
    background: #555;
}
</style>

<div class="lookup-container">
    <div class="lookup-title">🔍 Select Customer</div>

    <div class="search-box">
        <input type="text" 
               id="customerSearch" 
               placeholder="Search by Customer ID or Name..." 
               onkeyup="searchCustomer()"
               autofocus>
    </div>

    <div class="customer-count">
        Total Customers: <strong id="customerCount">0</strong>
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
            
            // Handle null values
            customerName = (customerName != null) ? customerName : "";
            categoryCode = (categoryCode != null) ? categoryCode : "";
            riskCategory = (riskCategory != null) ? riskCategory : "";
%>
                <tr onclick="selectCustomer('<%= customerId %>', '<%= customerName.replace("'", "\\'") %>', '<%= categoryCode %>', '<%= riskCategory %>')">
                    <td><%= customerId %></td>
                    <td><%= customerName %></td>
                    <td><%= categoryCode %></td>
                    <td><%= riskCategory %></td>
                </tr>
<%
        }
        
        if (!hasResults) {
%>
            <tr>
                <td colspan="4" class="no-results">
                    <strong>⚠️ No Authorized Customers Found</strong>
                    <br><br>
                    Please add and authorize customers first.
                </td>
            </tr>
<%
        }
%>
            </tbody>
        </table>
    </div>
</div>

<script>
// Set initial customer count
document.getElementById('customerCount').textContent = '<%= totalCount %>';

function selectCustomer(customerId, customerName, categoryCode, riskCategory) {
    // Call parent window function to set the customer data
    if (window.parent && window.parent.setCustomerData) {
        window.parent.setCustomerData(customerId, customerName, categoryCode, riskCategory);
    }
}

function searchCustomer() {
    const input = document.getElementById('customerSearch');
    const filter = input.value.toUpperCase();
    const table = document.getElementById('customerTable');
    const tbody = table.getElementsByTagName('tbody')[0];
    const rows = tbody.getElementsByTagName('tr');
    
    let visibleCount = 0;
    
    for (let i = 0; i < rows.length; i++) {
        const cells = rows[i].getElementsByTagName('td');
        
        // Skip if this is the "no results" row
        if (cells.length === 1) continue;
        
        let found = false;
        
        // Search in Customer ID (first cell) and Customer Name (second cell)
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
    
    // Update visible count
    document.getElementById('customerCount').textContent = visibleCount;
}

// Auto-focus on search input
document.getElementById('customerSearch').focus();
</script>

<%
    } catch (Exception e) {
        out.println("<div class='no-results'>");
        out.println("<strong>❌ Error Loading Customers</strong><br><br>");
        out.println("Error: " + e.getMessage());
        out.println("</div>");
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (ps != null) ps.close(); } catch (Exception ex) {}
        try { if (con != null) con.close(); } catch (Exception ex) {}
    }
%>