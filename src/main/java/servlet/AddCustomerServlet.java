package servlet;

import db.DBConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AddCustomerServlet")
public class AddCustomerServlet extends HttpServlet {

    // Helper method to convert checkbox to "on"/"off"
    private String getCheckValue(HttpServletRequest request, String param) {
        return request.getParameter(param) != null ? "on" : "off";
    }

    // Helper method to parse date safely
    private java.sql.Date parseDate(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) {
            return null;
        }
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            return new java.sql.Date(sdf.parse(dateStr).getTime());
        } catch (Exception e) {
            return null;
        }
    }

    // Helper method to parse integer safely
    private Integer parseInt(String str) {
        if (str == null || str.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(str);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    // Helper method to parse long safely
    private Long parseLong(String str) {
        if (str == null || str.trim().isEmpty()) {
            return null;
        }
        try {
            return Long.parseLong(str);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    // Generate GLOBALLY UNIQUE Customer ID based on branch code
    private String generateCustomerId(Connection conn, String branchCode) throws Exception {
        // Format branch code to 4 digits (pad with zeros if needed)
        String branchPrefix = String.format("%04d", Integer.parseInt(branchCode));
        
        // Get the TOTAL count of ALL customers across ALL branches (globally unique)
        String countSQL = "SELECT COUNT(*) FROM CUSTOMERS";
        PreparedStatement pstmt = conn.prepareStatement(countSQL);
        ResultSet rs = pstmt.executeQuery();
        
        int totalCustomers = 0;
        if (rs.next()) {
            totalCustomers = rs.getInt(1);
        }
        rs.close();
        pstmt.close();
        
        // Generate new customer ID: branchCode (4 digits) + global sequential number (6 digits)
        String customerId = branchPrefix + String.format("%06d", totalCustomers + 1);
        return customerId;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        System.out.println("=== AddCustomerServlet called ===");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("branchCode") == null) {
            System.out.println("Session is null or branchCode not found");
            response.sendRedirect("login.jsp");
            return;
        }

        String branchCode = (String) session.getAttribute("branchCode");
        System.out.println("Branch Code: " + branchCode);
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String customerId = null;

        try {
            System.out.println("Attempting database connection...");
            conn = DBConnection.getConnection();
            System.out.println("Database connected successfully");

            // Generate Customer ID based on branch code (GLOBALLY UNIQUE)
            customerId = generateCustomerId(conn, branchCode);
            System.out.println("Generated Customer ID: " + customerId);

            // Simplified INSERT with exact parameter count
            String insertSQL = "INSERT INTO CUSTOMERS (" +
                "CUSTOMER_ID, BRANCH_CODE, IS_INDIVIDUAL, GENDER, SALUTATION_CODE, " +
                "FIRST_NAME, SURNAME, MIDDLE_NAME, CUSTOMER_NAME, BIRTH_DATE, " +
                "REGISTRATION_DATE, IS_MINOR, GUARDIAN_NAME, RELATION_GUARDIAN, RELIGION_CODE, " +
                "CASTE_CODE, CATEGORY_CODE, SUB_CATEGORY_CODE, CONSTITUTION_CODE, OCCUPATION_CODE, " +
                "VEHICLE_OWNED, MEMBER_TYPE, EMAIL, GSTIN_NO, MEMBER_NUMBER, " +
                "CKY_NO, RISK_CATEGORY, MOTHER_NAME, FATHER_NAME, MARITAL_STATUS, " +
                "NO_OF_CHILDREN, NO_OF_DEPENDENTS, NATIONALITY, RESIDENCE_TYPE, RESIDENCE_STATUS, " +
                "ADDRESS1, ADDRESS2, ADDRESS3, COUNTRY, STATE, " +
                "CITY, ZIP, MOBILE_NO, RESIDENCE_PHONE, OFFICE_PHONE, " +
                "PASSPORT_CHECK, PASSPORT_EXPIRY, PASSPORT_NUMBER, PAN_CHECK, PAN_EXPIRY, " +
                "PAN, VOTERID_CHECK, VOTERID_EXPIRY, VOTERID, DL_CHECK, " +
                "DL_EXPIRY, DL, AADHAR_CHECK, AADHAR_EXPIRY, AADHAR, " +
                "NREGA_CHECK, NREGA_EXPIRY, NREGA, TELEPHONE_CHECK, TELEPHONE_EXPIRY, " +
                "TELEPHONE, BANK_CHECK, BANK_EXPIRY, BANK_STATEMENT, GOVT_CHECK, " +
                "GOVT_EXPIRY, GOVT_DOC, ELECTRICITY_CHECK, ELECTRICITY_EXPIRY, ELECTRICITY, " +
                "RATION_CHECK, RATION_EXPIRY, RATION, RENT_CHECK, RENT_EXPIRY, " +
                "CERT_CHECK, CERT_EXPIRY, TAX_CHECK, TAX_EXPIRY, CST_CHECK, " +
                "CST_EXPIRY, REG_CHECK, REG_EXPIRY, INC_CHECK, INC_EXPIRY, " +
                "BOARD_CHECK, BOARD_EXPIRY, POA_CHECK, POA_EXPIRY" +
                ") VALUES (" +
                "?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, " +
                "?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, " +
                "?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, " +
                "?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, " +
                "?,?,?,?,?, ?,?,?,?,?, ?,?,?,?" +
                ")";

            pstmt = conn.prepareStatement(insertSQL);
            System.out.println("PreparedStatement created");

            // Set all parameters - EXACT count: 94 parameters
            int idx = 1;
            
            // 1-5
            pstmt.setString(idx++, customerId);
            pstmt.setString(idx++, branchCode);
            pstmt.setString(idx++, request.getParameter("isIndividual"));
            pstmt.setString(idx++, request.getParameter("gender"));
            pstmt.setString(idx++, request.getParameter("salutationCode"));
            
            // 6-10
            pstmt.setString(idx++, request.getParameter("firstName"));
            pstmt.setString(idx++, request.getParameter("surname"));
            pstmt.setString(idx++, request.getParameter("middleName"));
            pstmt.setString(idx++, request.getParameter("customerName"));
            pstmt.setDate(idx++, parseDate(request.getParameter("birthDate")));
            
            // 11-15
            pstmt.setDate(idx++, parseDate(request.getParameter("registrationDate")));
            pstmt.setString(idx++, request.getParameter("isMinor"));
            pstmt.setString(idx++, request.getParameter("guardianName"));
            pstmt.setString(idx++, request.getParameter("relationGuardian"));
            pstmt.setString(idx++, request.getParameter("religionyCode"));
            
            // 16-20
            pstmt.setString(idx++, request.getParameter("casteCode"));
            pstmt.setString(idx++, request.getParameter("categoryCode"));
            pstmt.setString(idx++, request.getParameter("subCategoryCode"));
            pstmt.setString(idx++, request.getParameter("constitutionCode"));
            pstmt.setString(idx++, request.getParameter("occupationCode"));
            
            // 21-25
            pstmt.setString(idx++, request.getParameter("vehicleOwned"));
            pstmt.setString(idx++, request.getParameter("memberType"));
            pstmt.setString(idx++, request.getParameter("email"));
            pstmt.setString(idx++, request.getParameter("gstinNo"));
            pstmt.setString(idx++, request.getParameter("memberNumber"));
            
            // 26-30
            pstmt.setString(idx++, request.getParameter("ckyNo"));
            pstmt.setString(idx++, request.getParameter("riskCategory"));
            pstmt.setString(idx++, request.getParameter("motherName"));
            pstmt.setString(idx++, request.getParameter("fatherName"));
            pstmt.setString(idx++, request.getParameter("maritalStatus"));
            
            // 31-32
            Integer children = parseInt(request.getParameter("children"));
            if (children != null) {
                pstmt.setInt(idx++, children);
            } else {
                pstmt.setNull(idx++, java.sql.Types.INTEGER);
            }
            
            Integer dependents = parseInt(request.getParameter("dependents"));
            if (dependents != null) {
                pstmt.setInt(idx++, dependents);
            } else {
                pstmt.setNull(idx++, java.sql.Types.INTEGER);
            }
            
            // 33-37
            pstmt.setString(idx++, request.getParameter("nationality"));
            pstmt.setString(idx++, request.getParameter("residenceType"));
            pstmt.setString(idx++, request.getParameter("residenceStatus"));
            pstmt.setString(idx++, request.getParameter("address1"));
            pstmt.setString(idx++, request.getParameter("address2"));
            
            // 38-42
            pstmt.setString(idx++, request.getParameter("address3"));
            pstmt.setString(idx++, request.getParameter("country"));
            pstmt.setString(idx++, request.getParameter("state"));
            pstmt.setString(idx++, request.getParameter("city"));
            
            Integer zip = parseInt(request.getParameter("zip"));
            if (zip != null) {
                pstmt.setInt(idx++, zip);
            } else {
                pstmt.setNull(idx++, java.sql.Types.INTEGER);
            }
            
            // 43-45
            Long mobileNo = parseLong(request.getParameter("mobileNo"));
            if (mobileNo != null) {
                pstmt.setLong(idx++, mobileNo);
            } else {
                pstmt.setNull(idx++, java.sql.Types.BIGINT);
            }
            
            Long residencePhone = parseLong(request.getParameter("residencePhone"));
            if (residencePhone != null) {
                pstmt.setLong(idx++, residencePhone);
            } else {
                pstmt.setNull(idx++, java.sql.Types.BIGINT);
            }
            
            Long officePhone = parseLong(request.getParameter("officePhone"));
            if (officePhone != null) {
                pstmt.setLong(idx++, officePhone);
            } else {
                pstmt.setNull(idx++, java.sql.Types.BIGINT);
            }
            
            // 46-48: Passport
            pstmt.setString(idx++, getCheckValue(request, "passport_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("passport_expiry")));
            pstmt.setString(idx++, request.getParameter("passportNumber"));
            
            // 49-51: PAN
            pstmt.setString(idx++, getCheckValue(request, "pan_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("pan_expiry")));
            pstmt.setString(idx++, request.getParameter("pan"));
            
            // 52-54: Voter ID
            pstmt.setString(idx++, getCheckValue(request, "voterid_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("voterid_expiry")));
            pstmt.setString(idx++, request.getParameter("voterid"));
            
            // 55-57: DL
            pstmt.setString(idx++, getCheckValue(request, "dl_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("dl_expiry")));
            pstmt.setString(idx++, request.getParameter("dl"));
            
            // 58-60: Aadhar
            pstmt.setString(idx++, getCheckValue(request, "aadhar_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("aadhar_expiry")));
            pstmt.setString(idx++, request.getParameter("aadhar"));
            
            // 61-63: NREGA
            pstmt.setString(idx++, getCheckValue(request, "nrega_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("nrega_expiry")));
            pstmt.setString(idx++, request.getParameter("nrega"));
            
            // 64-66: Telephone
            pstmt.setString(idx++, getCheckValue(request, "telephone_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("telephone_expiry")));
            pstmt.setString(idx++, request.getParameter("telephone"));
            
            // 67-69: Bank
            pstmt.setString(idx++, getCheckValue(request, "bank_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("bank_expiry")));
            pstmt.setString(idx++, request.getParameter("bank_statement"));
            
            // 70-72: Govt
            pstmt.setString(idx++, getCheckValue(request, "govt_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("govt_expiry")));
            pstmt.setString(idx++, request.getParameter("govt_doc"));
            
            // 73-75: Electricity
            pstmt.setString(idx++, getCheckValue(request, "electricity_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("electricity_expiry")));
            pstmt.setString(idx++, request.getParameter("electricity"));
            
            // 76-78: Ration
            pstmt.setString(idx++, getCheckValue(request, "ration_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("ration_expiry")));
            pstmt.setString(idx++, request.getParameter("ration"));
            
            // 79-80: Rent
            pstmt.setString(idx++, getCheckValue(request, "rent_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("rent_expiry")));
            
            // 81-82: Cert
            pstmt.setString(idx++, getCheckValue(request, "cert_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("cert_expiry")));
            
            // 83-84: Tax
            pstmt.setString(idx++, getCheckValue(request, "tax_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("tax_expiry")));
            
            // 85-86: CST
            pstmt.setString(idx++, getCheckValue(request, "cst_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("cst_expiry")));
            
            // 87-88: Reg
            pstmt.setString(idx++, getCheckValue(request, "reg_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("reg_expiry")));
            
            // 89-90: Inc
            pstmt.setString(idx++, getCheckValue(request, "inc_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("inc_expiry")));
            
            // 91-92: Board
            pstmt.setString(idx++, getCheckValue(request, "board_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("board_expiry")));
            
            // 93-94: POA
            pstmt.setString(idx++, getCheckValue(request, "poa_check"));
            pstmt.setDate(idx++, parseDate(request.getParameter("poa_expiry")));

            System.out.println("All parameters set. Total parameters: " + (idx - 1));
            
            int rows = pstmt.executeUpdate();
            System.out.println("Rows inserted: " + rows);

            if (rows > 0) {
                System.out.println("Customer added successfully!");
                response.sendRedirect("addCustomer.jsp?status=success&customerId=" + customerId);
            } else {
                System.out.println("Failed to insert customer");
                response.sendRedirect("addCustomer.jsp?status=error&message=Failed to add customer");
            }

        } catch (Exception e) {
            System.out.println("ERROR: " + e.getMessage());
            e.printStackTrace();
            String errorMsg = e.getMessage().replace("'", "\\'");
            response.sendRedirect("addCustomer.jsp?status=error&message=" + java.net.URLEncoder.encode(errorMsg, "UTF-8"));
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
}