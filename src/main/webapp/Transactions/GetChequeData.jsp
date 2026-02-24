<%@ page import="java.sql.*, db.DBConnection, org.json.*" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String accountCode = request.getParameter("accountCode");

    if (accountCode == null || accountCode.trim().isEmpty()) {
        out.print("{\"error\": \"Account code is required\", \"cheques\": []}");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = DBConnection.getConnection();

        // Fetch cheque data where STATUS = 'I' (Issued / In hand) for the given account
        String query = "SELECT CHEQUE_NUMBER, CHEQUE_SERIES " +
                       "FROM ACCOUNT.ACCOUNTCHEQUE " +
                       "WHERE ACCOUNT_CODE = ? " +
                       "AND STATUS = 'I' " +
                       "ORDER BY CHEQUE_NUMBER";

        ps = con.prepareStatement(query);
        ps.setString(1, accountCode.trim());
        rs = ps.executeQuery();

        JSONObject jsonResponse = new JSONObject();
        jsonResponse.put("success", true);

        JSONArray chequesArray = new JSONArray();
        // Collect unique CHEQUE_SERIES for cheque type dropdown
        java.util.LinkedHashSet<String> seriesSet = new java.util.LinkedHashSet<>();

        while (rs.next()) {
            JSONObject cheque = new JSONObject();

            String chequeNumber = rs.getString("CHEQUE_NUMBER");
            String chequeSeries = rs.getString("CHEQUE_SERIES");

            cheque.put("chequeNumber", chequeNumber != null ? chequeNumber.trim() : "");
            cheque.put("chequeSeries", chequeSeries != null ? chequeSeries.trim() : "");

            chequesArray.put(cheque);

            if (chequeSeries != null && !chequeSeries.trim().isEmpty()) {
                seriesSet.add(chequeSeries.trim());
            }
        }

        // Build unique series array
        JSONArray seriesArray = new JSONArray();
        for (String series : seriesSet) {
            seriesArray.put(series);
        }

        jsonResponse.put("cheques", chequesArray);
        jsonResponse.put("seriesList", seriesArray);
        jsonResponse.put("count", chequesArray.length());

        out.print(jsonResponse.toString());

    } catch (SQLException e) {
        e.printStackTrace();
        JSONObject errorResponse = new JSONObject();
        errorResponse.put("success", false);
        errorResponse.put("error", "Database error: " + e.getMessage());
        errorResponse.put("cheques", new JSONArray());
        out.print(errorResponse.toString());

    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>
