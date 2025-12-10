<%@ page import="java.sql.*, db.DBConnection, org.json.JSONObject" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    JSONObject jsonResponse = new JSONObject();
    Connection conn = null;
    CallableStatement cstmt = null;

    try {
        // Get parameters from request
        String loanAmountStr = request.getParameter("loanAmount");
        String rateStr = request.getParameter("rate");
        String periodStr = request.getParameter("period");
        String instTypeId = request.getParameter("instType");

        // Debug logging
        System.out.println("📊 EMI Calculation Request:");
        System.out.println("   Loan Amount: " + loanAmountStr);
        System.out.println("   Rate: " + rateStr);
        System.out.println("   Period: " + periodStr);
        System.out.println("   Inst Type ID: " + instTypeId);

        // Validate parameters
        if (loanAmountStr == null || rateStr == null || periodStr == null || instTypeId == null) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Missing required parameters");
            out.print(jsonResponse.toString());
            return;
        }

        // Parse parameters
        double loanAmount = Double.parseDouble(loanAmountStr);
        double rate = Double.parseDouble(rateStr);
        int period = Integer.parseInt(periodStr);

        // Validate values
        if (loanAmount <= 0 || rate <= 0 || period <= 0) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Invalid parameter values. All values must be greater than 0.");
            out.print(jsonResponse.toString());
            return;
        }

        // ✅ Convert Installment Type ID to Code
        String instTypeCode = convertInstallmentTypeToCode(instTypeId);
        System.out.println("✅ Converted ID '" + instTypeId + "' to Code '" + instTypeCode + "'");

        // Get database connection
        conn = DBConnection.getConnection();
        System.out.println("✅ Database connection established");

        // Prepare the callable statement to call the Oracle function
        String funcSql = "{? = call fn_get_emi_inst(?, ?, ?, ?)}";
        cstmt = conn.prepareCall(funcSql);

        // Register the output parameter (return value)
        cstmt.registerOutParameter(1, Types.DECIMAL);

        // Set input parameters
        cstmt.setBigDecimal(2, new java.math.BigDecimal(loanAmount));
        cstmt.setBigDecimal(3, new java.math.BigDecimal(rate));
        cstmt.setInt(4, period);
        cstmt.setString(5, instTypeCode);  // ✅ Use the converted code

        System.out.println("📞 Calling Oracle function with code: '" + instTypeCode + "'");

        // Execute the function
        cstmt.execute();

        // Get the return value
        java.math.BigDecimal emiAmountBD = cstmt.getBigDecimal(1);
        
        if (emiAmountBD == null) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Function returned null value");
            System.err.println("❌ Function returned NULL");
        } else {
            double emiAmount = emiAmountBD.doubleValue();
            
            // Prepare success response
            jsonResponse.put("success", true);
            jsonResponse.put("emiAmount", Math.round(emiAmount * 100.0) / 100.0);
            jsonResponse.put("message", "EMI calculated successfully");
            jsonResponse.put("installmentCode", instTypeCode);
            jsonResponse.put("installmentId", instTypeId);

            System.out.println("✅ EMI Calculation Success:");
            System.out.println("   Installment ID: " + instTypeId);
            System.out.println("   Installment Code: " + instTypeCode);
            System.out.println("   Calculated EMI: " + emiAmount);
        }

    } catch (NumberFormatException e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Invalid number format: " + e.getMessage());
        System.err.println("❌ Number format error: " + e.getMessage());
        e.printStackTrace();

    } catch (SQLException e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Database error: " + e.getMessage());
        System.err.println("❌ SQL error: " + e.getMessage());
        System.err.println("   SQL State: " + e.getSQLState());
        System.err.println("   Error Code: " + e.getErrorCode());
        e.printStackTrace();

    } catch (Exception e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Unexpected error: " + e.getMessage());
        System.err.println("❌ Unexpected error: " + e.getMessage());
        e.printStackTrace();

    } finally {
        // Close resources
        try {
            if (cstmt != null) cstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            System.err.println("Error closing database resources: " + e.getMessage());
        }
    }

    // Send JSON response
    out.print(jsonResponse.toString());
%>

<%!
    /**
     * Convert Installment Type ID to Code
     * Mapping based on your installment types
     */
    private String convertInstallmentTypeToCode(String installmentTypeId) {
        if (installmentTypeId == null) {
            return "0";
        }
        
        switch (installmentTypeId.trim()) {
            case "0":
                return "0";           // NOT SPECIFIED
            case "101":
                return "E";           // EMI
            case "105":
                return "P";           // PLANE PRINCIPAL
            case "201":
                return "E";           // REDUCING INSTALLMENT (uses EMI formula)
            case "301":
                return "0";           // BULLON (bullet payment - no installment)
            case "401":
                return "E";           // VARIABLE (default to EMI)
            case "501":
                return "0";           // WITH INT (interest only)
            default:
                System.out.println("⚠️ Unknown Installment Type ID: " + installmentTypeId + ", defaulting to '0'");
                return "0";           // Default to no installment
        }
    }
%>