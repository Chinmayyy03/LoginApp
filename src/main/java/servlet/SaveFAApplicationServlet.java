package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;
import java.sql.Timestamp;
import java.sql.Types;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "SaveFAApplicationServlet", urlPatterns = {"/OpenAccount/SaveFAApplicationServlet"})
public class SaveFAApplicationServlet extends HttpServlet {

    // ========= Utility methods =========

    private String generateApplicationNumber(Connection conn, String branchCode) throws Exception {
        String branchPrefix = String.format("%04d", Integer.parseInt(branchCode));

        String sql =
            "SELECT MAX(TO_NUMBER(SUBSTR(APPLICATION_NUMBER, 5, 10))) " +
            "FROM APPLICATION.APPLICATION " +
            "WHERE LENGTH(APPLICATION_NUMBER) = 14";

        PreparedStatement pstmt = conn.prepareStatement(sql);
        ResultSet rs = pstmt.executeQuery();

        long nextSeq = 1;
        if (rs.next() && rs.getLong(1) > 0) {
            long lastSeq = rs.getLong(1);
            nextSeq = lastSeq + 1;
        }

        rs.close();
        pstmt.close();

        String applicationNumber = branchPrefix + String.format("%010d", nextSeq);

        String checkSQL = "SELECT COUNT(*) FROM APPLICATION.APPLICATION WHERE APPLICATION_NUMBER = ?";
        PreparedStatement checkStmt = conn.prepareStatement(checkSQL);

        int attempts = 0;
        while (attempts < 100) {
            checkStmt.setString(1, applicationNumber);
            ResultSet checkRs = checkStmt.executeQuery();

            if (checkRs.next() && checkRs.getInt(1) > 0) {
                nextSeq++;
                applicationNumber = branchPrefix + String.format("%010d", nextSeq);
                checkRs.close();
                attempts++;
            } else {
                checkRs.close();
                break;
            }
        }

        checkStmt.close();

        if (attempts >= 100) {
            throw new Exception("Failed to generate unique APPLICATION_NUMBER after 100 attempts");
        }
        System.out.println("📌 FINAL APPLICATION_NUMBER = " + applicationNumber);
        return applicationNumber;
    }

    private Date parseDate(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) return null;
        try {
            return new Date(new java.text.SimpleDateFormat("yyyy-MM-dd").parse(dateStr).getTime());
        } catch (Exception e) {
            return null;
        }
    }

    private Integer parseInt(String str) {
        if (str == null || str.trim().isEmpty()) return null;
        try {
            return Integer.parseInt(str.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Double parseDouble(String str) {
        if (str == null || str.trim().isEmpty()) return null;
        try {
            return Double.parseDouble(str.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String trimSafe(String str) {
        return (str == null) ? null : str.trim();
    }

    // ========= Servlet =========

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("branchCode") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String branchCode = trimSafe((String) session.getAttribute("branchCode"));
        String userId = trimSafe((String) session.getAttribute("userId"));
        String productCode = trimSafe(request.getParameter("productCode"));
        String customerId = trimSafe(request.getParameter("customerId"));
        String customerName = trimSafe(request.getParameter("customerName"));

        if (productCode == null || productCode.isEmpty()) {
            response.sendRedirect("fAApplication.jsp?status=error&message=" +
                java.net.URLEncoder.encode("Product Code required", "UTF-8"));
            return;
        }

        if (customerId == null || customerId.isEmpty()) {
            response.sendRedirect("fAApplication.jsp?status=error&message=" +
                java.net.URLEncoder.encode("Customer ID required", "UTF-8") +
                "&productCode=" + productCode);
            return;
        }

        Connection conn = null;
        PreparedStatement psApp = null, psFixedAsset = null, psGetCategory = null;
        ResultSet rsCategory = null;
        String applicationNumber = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            applicationNumber = generateApplicationNumber(conn, branchCode);

            // ========== GET CATEGORY_CODE FROM CUSTOMERS TABLE ==========
            String categoryCode = null;
            String getCategorySQL = "SELECT CATEGORY_CODE FROM CUSTOMERS WHERE CUSTOMER_ID = ?";
            psGetCategory = conn.prepareStatement(getCategorySQL);
            psGetCategory.setString(1, customerId);
            rsCategory = psGetCategory.executeQuery();
            
            if (rsCategory.next()) {
                categoryCode = rsCategory.getString("CATEGORY_CODE");
            }
            
            rsCategory.close();
            psGetCategory.close();

            // ========== INSERT APPLICATION ==========
            String appSQL = "INSERT INTO APPLICATION.APPLICATION (" +
                "APPLICATION_NUMBER, BRANCH_CODE, PRODUCT_CODE, APPLICATIONDATE, " +
                "CUSTOMER_ID, ACCOUNTOPERATIONCAPACITY_ID, USER_ID, NAME, CATEGORY_CODE, STATUS) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'E')";

            psApp = conn.prepareStatement(appSQL);
            psApp.setString(1, applicationNumber);
            psApp.setString(2, branchCode);
            psApp.setString(3, productCode);
            psApp.setDate(4, parseDate(request.getParameter("dateOfApplication")));
            psApp.setString(5, customerId);
            psApp.setInt(6, 0); // Default ACCOUNTOPERATIONCAPACITY_ID to 0
            psApp.setString(7, userId);
            psApp.setString(8, customerName); // Customer Name
            psApp.setString(9, categoryCode); // Category Code from CUSTOMERS table

            psApp.executeUpdate();

            // ========== INSERT FIXED ASSET DETAILS ==========
            String faSQL = "INSERT INTO APPLICATION.APPLICATIONFIXEDASSET (" +
                "APPLICATION_NUMBER, ITEM_NAME, PURCHASEDATE, PURCHASEAMOUNT, " +
                "NUMBEROFITEM, DEPRICATIONRATE, BILLNUMBER, DESCRIPTION, " +
                "METHOD_OF_DEP_CAL, DEPRICATION_CALCULATE_ON, CREATD_DATE) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            psFixedAsset = conn.prepareStatement(faSQL);

            int idx = 1;

            // 1. APPLICATION_NUMBER (NOT NULL)
            psFixedAsset.setString(idx++, applicationNumber);

            // 2. ITEM_NAME - VARCHAR2(50 BYTE)
            String itemName = trimSafe(request.getParameter("itemName"));
            if (itemName != null && !itemName.isEmpty()) {
                psFixedAsset.setString(idx++, itemName);
            } else {
                psFixedAsset.setNull(idx++, Types.VARCHAR);
            }

            // 3. PURCHASEDATE - DATE
            Date purchaseDate = parseDate(request.getParameter("purchaseDate"));
            if (purchaseDate != null) {
                psFixedAsset.setDate(idx++, purchaseDate);
            } else {
                psFixedAsset.setNull(idx++, Types.DATE);
            }

            // 4. PURCHASEAMOUNT - NUMBER(15,2)
            Double purchaseAmount = parseDouble(request.getParameter("purchaseAmount"));
            if (purchaseAmount != null) {
                psFixedAsset.setDouble(idx++, purchaseAmount);
            } else {
                psFixedAsset.setNull(idx++, Types.DECIMAL);
            }

            // 5. NUMBEROFITEM - NUMBER(5,0)
            Integer noOfItem = parseInt(request.getParameter("noOfItem"));
            if (noOfItem != null) {
                psFixedAsset.setInt(idx++, noOfItem);
            } else {
                psFixedAsset.setNull(idx++, Types.INTEGER);
            }

            // 6. DEPRICATIONRATE - NUMBER(5,2)
            Double depreciationRate = parseDouble(request.getParameter("depreciationRate"));
            if (depreciationRate != null) {
                psFixedAsset.setDouble(idx++, depreciationRate);
            } else {
                psFixedAsset.setNull(idx++, Types.DECIMAL);
            }

            // 7. BILLNUMBER - VARCHAR2(20 BYTE)
            String billNumber = trimSafe(request.getParameter("billNumber"));
            if (billNumber != null && !billNumber.isEmpty()) {
                psFixedAsset.setString(idx++, billNumber);
            } else {
                psFixedAsset.setNull(idx++, Types.VARCHAR);
            }

            // 8. DESCRIPTION - VARCHAR2(50 BYTE)
            String description = trimSafe(request.getParameter("description"));
            if (description != null && !description.isEmpty()) {
                psFixedAsset.setString(idx++, description);
            } else {
                psFixedAsset.setNull(idx++, Types.VARCHAR);
            }

            // 9. METHOD_OF_DEP_CAL - CHAR(1 BYTE)
            String methodOfDepreciation = trimSafe(request.getParameter("methodOfDepreciation"));
            if (methodOfDepreciation != null && !methodOfDepreciation.isEmpty()) {
                // Store first character: "D" for Day, "M" for Month
                char methodChar = methodOfDepreciation.charAt(0);
                psFixedAsset.setString(idx++, String.valueOf(methodChar));
            } else {
                psFixedAsset.setString(idx++, "M"); // Default to Month
            }

            // 10. DEPRICATION_CALCULATE_ON - CHAR(1 BYTE)
            String depCalculateOn = trimSafe(request.getParameter("depreciationCalculateOn"));
            if (depCalculateOn != null && !depCalculateOn.isEmpty()) {
                // Store first character: "O" for Opening Balance, "C" for Current Balance
                char calcChar = depCalculateOn.contains("Opening") ? 'O' : 'C';
                psFixedAsset.setString(idx++, String.valueOf(calcChar));
            } else {
                psFixedAsset.setString(idx++, "C"); // Default to Current Balance
            }

            // 11. CREATD_DATE - TIMESTAMP(6) - Default SYSDATE
            Timestamp now = new Timestamp(System.currentTimeMillis());
            psFixedAsset.setTimestamp(idx++, now);

            psFixedAsset.executeUpdate();

            conn.commit();
            
            System.out.println("✅ Fixed Asset Application saved successfully!");
            System.out.println("   Application Number: " + applicationNumber);
            System.out.println("   Item Name: " + itemName);
            System.out.println("   Purchase Amount: " + purchaseAmount);
            
            response.sendRedirect("fAApplication.jsp?status=success&applicationNumber=" +
                                  applicationNumber + "&productCode=" + productCode);

        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ignored) {}
            }
            e.printStackTrace();
            System.out.println("❌ Error saving Fixed Asset Application: " + e.getMessage());
            response.sendRedirect("fAApplication.jsp?status=error&message=" +
                java.net.URLEncoder.encode(e.getMessage(), "UTF-8") +
                "&productCode=" + (productCode != null ? productCode : ""));
        } finally {
            try { if (rsCategory != null) rsCategory.close(); } catch (Exception ignored) {}
            try { if (psGetCategory != null) psGetCategory.close(); } catch (Exception ignored) {}
            try { if (psApp != null) psApp.close(); } catch (Exception ignored) {}
            try { if (psFixedAsset != null) psFixedAsset.close(); } catch (Exception ignored) {}
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignored) {}
        }
    }
}