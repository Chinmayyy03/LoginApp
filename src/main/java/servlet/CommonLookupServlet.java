package servlet;

import db.DBConnection;
import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/CommonLookupServlet")
public class CommonLookupServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String type = request.getParameter("type");
        String action = request.getParameter("action");

        Connection conn = null;
        PrintWriter out = response.getWriter();

        try {

            if (type == null) {
                out.print("Invalid request");
                return;
            }

            // ✅ INIT CONNECTION FIRST
            conn = DBConnection.getConnection();

            // ===============================
            // 🔥 SESSION + AUTO LOAD FROM DB
            // ===============================
            HttpSession session = request.getSession();

            String isSupportUser = (String) session.getAttribute("isSupportUser");
            String sessionBranchCode = (String) session.getAttribute("branchCode");

            if (isSupportUser == null || sessionBranchCode == null) {

                String userId = (String) session.getAttribute("userId");

                if (userId != null) {

                    PreparedStatement psUser = conn.prepareStatement(
                        "SELECT IS_SUPPORT_USER, BRANCH_CODE FROM ACL.USERREGISTER WHERE USER_ID=?"
                    );
                    psUser.setString(1, userId);

                    ResultSet rsUser = psUser.executeQuery();

                    if (rsUser.next()) {

                        isSupportUser = rsUser.getString("IS_SUPPORT_USER");
                        sessionBranchCode = rsUser.getString("BRANCH_CODE");

                        // ✅ CLEAN VALUE
                        if (isSupportUser != null) {
                            isSupportUser = isSupportUser.trim().toUpperCase();
                        } else {
                            isSupportUser = "N";
                        }

                        // ✅ STORE IN SESSION
                        session.setAttribute("isSupportUser", isSupportUser);
                        session.setAttribute("branchCode", sessionBranchCode);
                    }

                    rsUser.close();
                    psUser.close();
                }
            }

            // fallback
            if (isSupportUser == null) isSupportUser = "N";
            if (sessionBranchCode == null) sessionBranchCode = "";

            // ===============================
            // 🔹 GET NAME
            // ===============================
            if ("getName".equalsIgnoreCase(action)) {

                response.setContentType("text/plain");

                String code = request.getParameter("code");

                if (code == null || code.trim().isEmpty()) {
                    out.print("");
                    return;
                }

                String query = "";

                if ("branch".equalsIgnoreCase(type)) {
                    query = "SELECT NAME FROM HEADOFFICE.BRANCH WHERE BRANCH_CODE=?";
                } else if ("account".equalsIgnoreCase(type)) {
                    query = "SELECT NAME FROM ACCOUNT.ACCOUNT WHERE ACCOUNT_CODE=?";
                } else if ("bank".equalsIgnoreCase(type)) {
                    query = "SELECT NAME FROM GLOBALCONFIG.BANK WHERE BANK_CODE=?";
                } else if ("product".equalsIgnoreCase(type)) {
                    query = "SELECT DESCRIPTION FROM HEADOFFICE.PRODUCT WHERE PRODUCT_CODE=?";
                } else {
                    out.print("");
                    return;
                }

                PreparedStatement ps = conn.prepareStatement(query);
                ps.setString(1, code);

                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    out.print(rs.getString(1));
                }

                rs.close();
                ps.close();
                return;
            }

            response.setContentType("text/html;charset=UTF-8");

            // ===============================
            // 🔹 LIST DATA
            // ===============================
            if ("branch".equalsIgnoreCase(type)) {
                listBranch(conn, out, request, isSupportUser, sessionBranchCode);
            } else if ("account".equalsIgnoreCase(type)) {
                listAccount(conn, out, request);
            } else if ("bank".equalsIgnoreCase(type)) {
                listBank(conn, out);
            } else if ("product".equalsIgnoreCase(type)) {
                listProduct(conn, out);
            } else {
                out.println("<h3 style='color:red;'>Invalid type</h3>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<h3 style='color:red;'>Error loading data</h3>");
        } finally {
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }

    // ===============================
    // 🔹 HEADER
    // ===============================
    private void printTableHeader(PrintWriter out, String title, String col1, String col2, boolean showCity) {

        out.println("<div class='lookup-container'>");
        out.println("<div class='lookup-title'>" + title + "</div>");
        out.println("<div class='lookup-table-wrapper'>");
        out.println("<table class='lookup-table'>");

        out.println("<tr>");
        out.println("<th>" + col1 + "</th>");
        out.println("<th>" + col2 + "</th>");

        if (showCity) out.println("<th>City Code</th>");

        out.println("</tr>");
    }

    private void printTableFooter(PrintWriter out) {
        out.println("</table></div></div>");
    }

    // ===============================
    // 🔹 BRANCH (ROLE BASED)
    // ===============================
    private void listBranch(Connection conn, PrintWriter out,
            HttpServletRequest request,
            String isSupportUser,
            String sessionBranchCode) throws Exception {

        boolean showCity = "true".equalsIgnoreCase(request.getParameter("showCity"));

        String sql;

        if ("Y".equalsIgnoreCase(isSupportUser)) {
            sql = "SELECT BRANCH_CODE, NAME, CITY_CODE FROM HEADOFFICE.BRANCH ORDER BY BRANCH_CODE";
        } else {
            sql = "SELECT BRANCH_CODE, NAME, CITY_CODE FROM HEADOFFICE.BRANCH WHERE BRANCH_CODE = ?";
        }

        PreparedStatement ps = conn.prepareStatement(sql);

        if (!"Y".equalsIgnoreCase(isSupportUser)) {
            ps.setString(1, sessionBranchCode);
        }

        ResultSet rs = ps.executeQuery();

        printTableHeader(out, "Select Branch", "Code", "Description", showCity);

        while (rs.next()) {

            String code = rs.getString("BRANCH_CODE");
            String name = rs.getString("NAME");
            String city = showCity ? rs.getString("CITY_CODE") : "";

            code = code == null ? "" : code.replace("'", "\\'");
            name = name == null ? "" : name.replace("'", "\\'");
            city = city == null ? "" : city.replace("'", "\\'");

            out.println("<tr class='lookup-row' onclick=\"selectBranch('"
                    + code + "','" + name + "'" +
                    (showCity ? ",'" + city + "'" : "") +
                    ")\">");

            out.println("<td>" + code + "</td>");
            out.println("<td>" + name + "</td>");
            if (showCity) out.println("<td>" + city + "</td>");

            out.println("</tr>");
        }

        printTableFooter(out);

        rs.close();
        ps.close();
    }

    // ===============================
    // 🔹 ACCOUNT
    // ===============================
    private void listAccount(Connection conn, PrintWriter out, HttpServletRequest request) throws Exception {

        String branchCode = request.getParameter("branchCode");

        if (branchCode == null || branchCode.trim().isEmpty()) {
            out.println("<h3 style='color:red;'>Branch required</h3>");
            return;
        }

        String sql =
            "SELECT ACCOUNT_CODE, NAME FROM ACCOUNT.ACCOUNT " +
            "WHERE ACCOUNT_CODE LIKE ? AND ACCOUNT_STATUS='L' AND DATEACCOUNTCLOSE IS NULL ORDER BY ACCOUNT_CODE";

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, branchCode + "%");

        ResultSet rs = ps.executeQuery();

        printTableHeader(out, "Select Account", "Account Code", "Name", false);

        while (rs.next()) {

            String code = rs.getString("ACCOUNT_CODE");
            String name = rs.getString("NAME");

            code = code == null ? "" : code.replace("'", "\\'");
            name = name == null ? "" : name.replace("'", "\\'");

            out.println("<tr class='lookup-row' onclick=\"selectAccount('"
                    + code + "','" + name + "')\">");

            out.println("<td>" + code + "</td>");
            out.println("<td>" + name + "</td>");
            out.println("</tr>");
        }

        printTableFooter(out);

        rs.close();
        ps.close();
    }

    // ===============================
    // 🔹 BANK
    // ===============================
    private void listBank(Connection conn, PrintWriter out) throws Exception {

        PreparedStatement ps = conn.prepareStatement(
            "SELECT BANK_CODE, NAME FROM GLOBALCONFIG.BANK ORDER BY BANK_CODE"
        );

        ResultSet rs = ps.executeQuery();

        printTableHeader(out, "Select Bank", "Bank Code", "Name", false);

        while (rs.next()) {

            String code = rs.getString("BANK_CODE");
            String name = rs.getString("NAME");

            out.println("<tr class='lookup-row' onclick=\"selectBank('"
                    + code + "','" + name + "')\">");

            out.println("<td>" + code + "</td>");
            out.println("<td>" + name + "</td>");
            out.println("</tr>");
        }

        printTableFooter(out);

        rs.close();
        ps.close();
    }

    // ===============================
    // 🔹 PRODUCT
    // ===============================
    private void listProduct(Connection conn, PrintWriter out) throws Exception {

        PreparedStatement ps = conn.prepareStatement(
            "SELECT PRODUCT_CODE, DESCRIPTION, ACCOUNT_TYPE FROM HEADOFFICE.PRODUCT ORDER BY PRODUCT_CODE"
        );

        ResultSet rs = ps.executeQuery();

        printTableHeader(out, "Select Product", "Code", "Description", false);

        while (rs.next()) {

            String code = rs.getString("PRODUCT_CODE");
            String name = rs.getString("DESCRIPTION");

            out.println("<tr class='lookup-row' onclick=\"selectProduct('"
                    + code + "','" + name + "','')\">");

            out.println("<td>" + code + "</td>");
            out.println("<td>" + name + "</td>");
            out.println("</tr>");
        }

        printTableFooter(out);

        rs.close();
        ps.close();
    }
}