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

    String type = request.getParameter("type");
    String accType = request.getParameter("accType");
    String productCode = request.getParameter("productCode");
    String query = "";

    if ("transaction".equals(type)) {
        query = "SELECT CODE_TYPE, DESCRIPTION FROM HEADOFFICE.TRANSACTIONS_TYPE ORDER BY CODE_TYPE";
    } 
    else if ("accountType".equals(type)) {
        query = "SELECT ACCOUNT_TYPE, NAME FROM HEADOFFICE.ACCOUNTTYPE ORDER BY ACCOUNT_TYPE";
    }
    else if ("product".equals(type)) {
        query = "SELECT PRODUCT_CODE, DESCRIPTION FROM HEADOFFICE.PRODUCT WHERE ACCOUNT_TYPE = ? ORDER BY PRODUCT_CODE";
    }
    else if ("account".equals(type)) {
        // New: Account lookup filtered by branch and product code
        query = "SELECT ACCOUNT_CODE, NAME FROM ACCOUNT.ACCOUNT " +
                "WHERE SUBSTR(ACCOUNT_CODE, 1, 4) = ? " +
                "AND SUBSTR(ACCOUNT_CODE, 5, 3) = ? " +
                "ORDER BY ACCOUNT_CODE";
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        con = DBConnection.getConnection();
        ps = con.prepareStatement(query);
        
        // Set parameter for product lookup
        if ("product".equals(type)) {
            ps.setString(1, accType);
        }
        // Set parameters for account lookup
        else if ("account".equals(type)) {
            ps.setString(1, branchCode);
            ps.setString(2, productCode);
        }
        
        rs = ps.executeQuery();
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
.search-box {
    margin: 15px 0;
    padding: 10px;
    width: 100%;
    border: 2px solid #C8B7F6;
    border-radius: 8px;
    background-color: #F4EDFF;
    outline: none;
    font-size: 14px;
    box-sizing: border-box;
}
.search-box:focus {
    border-color: #8066E8;
}
.no-results {
    text-align: center;
    padding: 20px;
    color: #999;
    font-style: italic;
}
</style>

<div class="lookup-title">
    Select <%= ("transaction".equals(type) ? "Transaction Type" : 
                 "accountType".equals(type) ? "Account Type" : 
                 "product".equals(type) ? "Product Code" : "Account") %>
</div>

<% if ("account".equals(type)) { %>
    <input type="text" 
           id="searchBox" 
           class="search-box" 
           placeholder="🔍 Search by Account Code or Name..." 
           onkeyup="filterTable()">
<% } %>

<table id="lookupTable">
    <tr>
        <th>Code</th>
        <th><%= "account".equals(type) ? "Name" : "Description" %></th>
    </tr>

<%
        while (rs.next()) {
            String code = rs.getString(1);
            String desc = rs.getString(2);
%>

    <tr class="data-row" onclick="sendBack('<%=code%>', '<%=desc%>', '<%=type%>')">
        <td><%=code%></td>
        <td><%=desc%></td>
    </tr>

<% 
        }
    } catch (SQLException e) {
        out.println("<tr><td colspan='2' style='color: red; text-align: center;'>Error loading data: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (ps != null) try { ps.close(); } catch(SQLException e) {}
        if (con != null) try { con.close(); } catch(SQLException e) {}
    }
%>
</table>

<% if ("account".equals(type)) { %>
<script>
function filterTable() {
    const searchValue = document.getElementById('searchBox').value.toLowerCase();
    const table = document.getElementById('lookupTable');
    const rows = table.getElementsByClassName('data-row');
    let visibleCount = 0;
    
    for (let i = 0; i < rows.length; i++) {
        const code = rows[i].getElementsByTagName('td')[0].textContent.toLowerCase();
        const name = rows[i].getElementsByTagName('td')[1].textContent.toLowerCase();
        
        if (code.includes(searchValue) || name.includes(searchValue)) {
            rows[i].style.display = '';
            visibleCount++;
        } else {
            rows[i].style.display = 'none';
        }
    }
    
    // Show "no results" message if no rows are visible
    let noResultsRow = document.getElementById('noResultsRow');
    if (visibleCount === 0) {
        if (!noResultsRow) {
            noResultsRow = table.insertRow(-1);
            noResultsRow.id = 'noResultsRow';
            noResultsRow.innerHTML = '<td colspan="2" class="no-results">No accounts found matching your search</td>';
        }
        noResultsRow.style.display = '';
    } else {
        if (noResultsRow) {
            noResultsRow.style.display = 'none';
        }
    }
}
</script>
<% } %>