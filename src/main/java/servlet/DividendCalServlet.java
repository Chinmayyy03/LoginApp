package servlet;

import db.DBConnection;

import com.lowagie.text.*;
import com.lowagie.text.pdf.*;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.awt.Color;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/dividendCal")
public class DividendCalServlet extends HttpServlet {

    private String jsonSafe(String s) {
        if (s == null) return "";
        return s.trim()
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "")
                .replace("\n", "");
    }

    private String jsonSafeErr(Exception e) {
        String msg = e.getMessage();
        if (msg == null) msg = "DB error";
        return msg.replace("\"", "'").replace("\r", "").replace("\n", " ");
    }

    private String nvl(String s) { return s == null ? "" : s.trim(); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException { doPost(req, res); }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession sess = req.getSession(false);
        if (sess == null || sess.getAttribute("branchCode") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action     = nvl(req.getParameter("action"));
        String branchCode = nvl((String) sess.getAttribute("branchCode"));
        String userId     = nvl((String) sess.getAttribute("userId"));

        // ── File-streaming actions: must be handled BEFORE JSON PrintWriter is opened ──
        if ("reportPDF".equals(action)) {
            generatePDF(req, res, branchCode, userId);
            return;
        }
        if ("reportXLS".equals(action) || "reportSBXls".equals(action) || "reportCRXls".equals(action)) {
            String mode = "reportSBXls".equals(action) ? "SB"
                        : "reportCRXls".equals(action) ? "CR" : "ALL";
            generateExcelCSV(req, res, branchCode, mode);
            return;
        }

        // ── All other actions return JSON ──
        res.reset();
        res.setContentType("application/json; charset=UTF-8");
        PrintWriter pw = res.getWriter();

        try {
            switch (action) {
                case "getDefaults":    getDefaults(pw);                                 break;
                case "getMemberTypes": getMemberTypes(pw);                              break;
                case "getAccounts":    getAccounts(req, pw);                            break;
                case "calculate":      calculate(req, pw, branchCode, userId);          break;
                case "report":         report(req, pw, branchCode);                     break;
                case "reportMain":     reportMain(req, pw, branchCode);                 break;
                case "reportSB":       reportSB(req, pw, branchCode);                   break;
                case "reportCR":       reportCR(req, pw, branchCode);                   break;
                case "postingPayable": postingPayable(req, pw, branchCode, userId);     break;
                case "postingSB":      postingSB(req, pw, branchCode, userId);          break;
                default:               pw.print("{\"success\":false,\"message\":\"Unknown action\"}");
            }
        } finally {
            pw.flush();
        }
    }

    // ══════════════════════════════════════════
    // ACTION 0 — Auto-fill defaults from SHARES.SHARES_PARAMETER
    // ══════════════════════════════════════════
    private void getDefaults(PrintWriter pw) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            String sql =
                "SELECT TO_CHAR(FINANCIAL_YEARFROM,'YYYY-MM-DD') AS YEAR_FROM," +
                " TO_CHAR(FINANCIAL_YEARTO,'YYYY-MM-DD') AS YEAR_TO," +
                " TO_CHAR(NEXT_RESERVE_DATE,'YYYY-MM-DD') AS DIV_BAL_DATE," +
                " DIVIDENT_PERCENTAGE" +
                " FROM SHARES.SHARES_PARAMETER" +
                " WHERE ROWNUM = 1";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                String yearFrom = jsonSafe(rs.getString("YEAR_FROM"));
                String yearTo   = jsonSafe(rs.getString("YEAR_TO"));
                String balDate  = jsonSafe(rs.getString("DIV_BAL_DATE"));
                String pct      = jsonSafe(rs.getString("DIVIDENT_PERCENTAGE"));
                pw.print("{\"success\":true,"
                    + "\"yearBegin\":\""  + yearFrom + "\","
                    + "\"yearEnd\":\""    + yearTo   + "\","
                    + "\"divBalDate\":\"" + balDate  + "\","
                    + "\"percentage\":\""  + pct     + "\"}");
            } else {
                pw.print("{\"success\":false,\"message\":\"No record found in SHARES.SHARES_PARAMETER\"}");
            }
        } catch (Exception e) {
            pw.print("{\"success\":false,\"message\":\"" + jsonSafeErr(e) + "\"}");
        } finally {
            closeQuietly(rs, ps, conn);
        }
    }

    // ══════════════════════════════════════════
    // ACTION 1 — Get Member Types for Lookup Popup
    // ══════════════════════════════════════════
    private void getMemberTypes(PrintWriter pw) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        StringBuilder sb = new StringBuilder("[");
        try {
            conn = DBConnection.getConnection();
            String sql =
                "SELECT DISTINCT SUBSTR(ACCOUNT_NUMBER, 5, 3) AS PRODUCT_CODE, " +
                "       MEMBER_TYPE " +
                "FROM SHARES.CERTIFICATE_MASTER " +
                "WHERE MEMBER_TYPE IN ('A','B') " +
                "AND   STATUS = 'A' " +
                "AND   ACCOUNT_NUMBER IS NOT NULL " +
                "ORDER BY MEMBER_TYPE, SUBSTR(ACCOUNT_NUMBER, 5, 3)";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                sb.append("{")
                  .append("\"productCode\":\"").append(jsonSafe(rs.getString("PRODUCT_CODE"))).append("\",")
                  .append("\"memberType\":\"").append(jsonSafe(rs.getString("MEMBER_TYPE"))).append("\"")
                  .append("}");
                first = false;
            }
            sb.append("]");
            pw.print(sb.toString());
        } catch (Exception e) {
            pw.print("{\"error\":\"" + jsonSafeErr(e) + "\"}");
        } finally {
            closeQuietly(rs, ps, conn);
        }
    }

    // ══════════════════════════════════════════
    // ACTION 2 — Get count of active accounts
    // ══════════════════════════════════════════
    private void getAccounts(HttpServletRequest req, PrintWriter pw) {
        String memberType  = nvl(req.getParameter("memberType"));
        String productCode = nvl(req.getParameter("productCode"));
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            String sql =
                "SELECT COUNT(*) AS total " +
                "FROM SHARES.CERTIFICATE_MASTER " +
                "WHERE MEMBER_TYPE = ? " +
                "AND   SUBSTR(ACCOUNT_NUMBER, 5, 3) = ? " +
                "AND   STATUS = 'A'";
            ps = conn.prepareStatement(sql);
            ps.setString(1, memberType);
            ps.setString(2, productCode);
            rs = ps.executeQuery();
            int count = 0;
            if (rs.next()) count = rs.getInt("total");
            pw.print("{\"success\":true,\"count\":" + count + ",\"memberType\":\"" + jsonSafe(memberType) + "\"}");
        } catch (Exception e) {
            pw.print("{\"success\":false,\"message\":\"" + jsonSafeErr(e) + "\"}");
        } finally {
            closeQuietly(rs, ps, conn);
        }
    }

    // ══════════════════════════════════════════
    // ACTION 3 — Calculate Dividend
    // ══════════════════════════════════════════
    private void calculate(HttpServletRequest req, PrintWriter pw,
                           String branchCode, String userId) {
        String productCode = nvl(req.getParameter("productCode"));
        String yearBegin   = nvl(req.getParameter("yearBegin"));
        String yearEnd     = nvl(req.getParameter("yearEnd"));
        String divBalDate  = nvl(req.getParameter("divBalDate"));
        Connection conn    = null;
        CallableStatement cs = null;
        try {
            conn = DBConnection.getConnection();
            cs = conn.prepareCall("{call sp_dividend_calc(?,?,?,?,?,?)}");
            cs.setString(1, branchCode);
            cs.setDate(2, new java.sql.Date(new java.util.Date().getTime()));
            cs.setDate(3, java.sql.Date.valueOf(divBalDate));
            cs.setDate(4, java.sql.Date.valueOf(yearBegin));
            cs.setDate(5, java.sql.Date.valueOf(yearEnd));
            cs.setString(6, productCode);
            cs.execute();
            pw.print("{\"success\":true,\"message\":\"Dividend calculated successfully for product " + jsonSafe(productCode) + "\"}");
        } catch (Exception e) {
            pw.print("{\"success\":false,\"message\":\"" + jsonSafeErr(e) + "\"}");
        } finally {
            closeQuietly(null, cs, conn);
        }
    }

    // ══════════════════════════════════════════
    // ACTION 4 — Original report (backward compat)
    // ══════════════════════════════════════════
    private void report(HttpServletRequest req, PrintWriter pw, String branchCode) {
        String productCode = nvl(req.getParameter("productCode"));
        String memberType  = nvl(req.getParameter("memberType"));
        String yearBegin   = nvl(req.getParameter("yearBegin"));
        String yearEnd     = nvl(req.getParameter("yearEnd"));
        String divBalDate  = nvl(req.getParameter("divBalDate"));
        Connection conn    = null;
        PreparedStatement ps = null;
        ResultSet rs       = null;
        try {
            conn = DBConnection.getConnection();
            String sql =
                "SELECT MEMBER_CODE, PAYABLE_AC, CR_ACCOUNT_CODE, " +
                "       BAL_SHARES_FOR_DIV, CURR_BALANCE, DIV_PERCENTAGE, " +
                "       DIV_AMOUNT, DIV_AMOUNT_POST, DIV_WARR_NO, " +
                "       NVL(PAYABLE_TXN_NO,0) AS PAYABLE_TXN_NO, " +
                "       TO_CHAR(PAYABLE_TXN_DATE,'DD-MM-YYYY') AS PAYABLE_TXN_DATE " +
                "FROM shares.dividend_calc " +
                "WHERE BRANCH_CODE = ? " +
                "AND Y_BEGIN_DATE  = TO_DATE(?,'YYYY-MM-DD') " +
                "AND Y_END_DATE    = TO_DATE(?,'YYYY-MM-DD') " +
                "AND DIV_BAL_DATE  = TO_DATE(?,'YYYY-MM-DD') " +
                "AND MEMBER_TYPE   = ? " +
                "ORDER BY MEMBER_CODE";
            ps = conn.prepareStatement(sql);
            ps.setString(1, branchCode);
            ps.setString(2, yearBegin);
            ps.setString(3, yearEnd);
            ps.setString(4, divBalDate);
            ps.setString(5, productCode);
            rs = ps.executeQuery();
            double total = 0;
            int count = 0;
            StringBuilder rows = new StringBuilder("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) rows.append(",");
                double amt = rs.getDouble("DIV_AMOUNT_POST");
                total += amt;
                count++;
                rows.append("{")
                    .append("\"memberCode\":\"").append(jsonSafe(rs.getString("MEMBER_CODE"))).append("\",")
                    .append("\"payableAc\":\"").append(jsonSafe(rs.getString("PAYABLE_AC"))).append("\",")
                    .append("\"crAccountCode\":\"").append(jsonSafe(rs.getString("CR_ACCOUNT_CODE"))).append("\",")
                    .append("\"balForDiv\":").append(rs.getDouble("BAL_SHARES_FOR_DIV")).append(",")
                    .append("\"currBalance\":").append(rs.getDouble("CURR_BALANCE")).append(",")
                    .append("\"divPercentage\":").append(rs.getDouble("DIV_PERCENTAGE")).append(",")
                    .append("\"divAmount\":").append(rs.getDouble("DIV_AMOUNT")).append(",")
                    .append("\"divAmountPost\":").append(amt).append(",")
                    .append("\"divWarrNo\":").append(rs.getLong("DIV_WARR_NO")).append(",")
                    .append("\"payableTxnNo\":").append(rs.getLong("PAYABLE_TXN_NO")).append(",")
                    .append("\"payableTxnDate\":\"").append(jsonSafe(rs.getString("PAYABLE_TXN_DATE"))).append("\"")
                    .append("}");
                first = false;
            }
            rows.append("]");
            pw.print("{\"success\":true,\"count\":" + count + ",\"total\":" + total + ",\"rows\":" + rows + "}");
        } catch (Exception e) {
            pw.print("{\"success\":false,\"message\":\"" + jsonSafeErr(e) + "\"}");
        } finally {
            closeQuietly(rs, ps, conn);
        }
    }

    // ══════════════════════════════════════════
    // ACTION reportMain
    // ══════════════════════════════════════════
    private void reportMain(HttpServletRequest req, PrintWriter pw, String branchCode) {
        String productCode = nvl(req.getParameter("productCode"));
        String yearBegin   = nvl(req.getParameter("yearBegin"));
        String yearEnd     = nvl(req.getParameter("yearEnd"));
        String divBalDate  = nvl(req.getParameter("divBalDate"));
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            String sql =
                "SELECT ROWNUM SR_NO, MEMBER_CODE, NAME, BAL_SHARES_FOR_DIV, " +
                "       DIV_AMOUNT, DIV_AMOUNT_POST, CR_ACCOUNT_CODE, DIV_PERCENTAGE " +
                "FROM (" +
                "  SELECT TO_NUMBER(SUBSTR(A.MEMBER_CODE,8)) AS MEMBER_CODE, " +
                "         TRIM(B.NAME) AS NAME, " +
                "         A.BAL_SHARES_FOR_DIV, A.DIV_AMOUNT, A.DIV_AMOUNT_POST, " +
                "         DECODE(TO_CHAR(TO_NUMBER(DECODE(TRIM(A.CR_ACCOUNT_CODE),'0','0'," +
                "           TRIM(SUBSTR(A.CR_ACCOUNT_CODE,8))))),'0',''," +
                "           TO_CHAR(TO_NUMBER(DECODE(TRIM(A.CR_ACCOUNT_CODE),'0','0'," +
                "           TRIM(SUBSTR(A.CR_ACCOUNT_CODE,8)))))) AS CR_ACCOUNT_CODE, " +
                "         A.DIV_PERCENTAGE " +
                "  FROM SHARES.DIVIDEND_CALC A, ACCOUNT.ACCOUNT B " +
                "  WHERE A.MEMBER_CODE = B.ACCOUNT_CODE " +
                "  AND SUBSTR(A.MEMBER_CODE,1,4) = ? " +
                "  AND SUBSTR(B.ACCOUNT_CODE,5,3) = ? " +
                "  AND A.Y_BEGIN_DATE  = TO_DATE(?,'YYYY-MM-DD') " +
                "  AND A.Y_END_DATE    = TO_DATE(?,'YYYY-MM-DD') " +
                "  AND A.DIV_BAL_DATE  = TO_DATE(?,'YYYY-MM-DD') " +
                "  ORDER BY TO_NUMBER(SUBSTR(A.MEMBER_CODE,8))" +
                ")";
            ps = conn.prepareStatement(sql);
            ps.setString(1, branchCode);
            ps.setString(2, productCode);
            ps.setString(3, yearBegin);
            ps.setString(4, yearEnd);
            ps.setString(5, divBalDate);
            rs = ps.executeQuery();
            double total = 0;
            int count = 0;
            StringBuilder rows = new StringBuilder("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) rows.append(",");
                double postAmt = rs.getDouble("DIV_AMOUNT_POST");
                total += postAmt;
                count++;
                rows.append("{")
                    .append("\"srNo\":").append(rs.getInt("SR_NO")).append(",")
                    .append("\"memberCode\":\"").append(jsonSafe(rs.getString("MEMBER_CODE"))).append("\",")
                    .append("\"name\":\"").append(jsonSafe(rs.getString("NAME"))).append("\",")
                    .append("\"balForDiv\":").append(rs.getDouble("BAL_SHARES_FOR_DIV")).append(",")
                    .append("\"divAmount\":").append(rs.getDouble("DIV_AMOUNT")).append(",")
                    .append("\"divAmountPost\":").append(postAmt).append(",")
                    .append("\"crAccountCode\":\"").append(jsonSafe(rs.getString("CR_ACCOUNT_CODE"))).append("\",")
                    .append("\"divPercentage\":").append(rs.getDouble("DIV_PERCENTAGE"))
                    .append("}");
                first = false;
            }
            rows.append("]");
            pw.print("{\"success\":true,\"count\":" + count + ",\"total\":" + total + ",\"rows\":" + rows + "}");
        } catch (Exception e) {
            pw.print("{\"success\":false,\"message\":\"" + jsonSafeErr(e) + "\"}");
        } finally {
            closeQuietly(rs, ps, conn);
        }
    }

    // ══════════════════════════════════════════
    // ACTION reportSB
    // ══════════════════════════════════════════
    private void reportSB(HttpServletRequest req, PrintWriter pw, String branchCode) {
        String productCode = nvl(req.getParameter("productCode"));
        String yearBegin   = nvl(req.getParameter("yearBegin"));
        String yearEnd     = nvl(req.getParameter("yearEnd"));
        String divBalDate  = nvl(req.getParameter("divBalDate"));
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            String sql =
                "SELECT ROWNUM SR_NO, MEMBER_CODE, NAME, BAL_SHARES_FOR_DIV, " +
                "       DIV_AMOUNT, DIV_AMOUNT_POST, CR_ACCOUNT_CODE, DIV_PERCENTAGE, BRANCH_CODE " +
                "FROM (" +
                "  SELECT TO_NUMBER(SUBSTR(A.MEMBER_CODE,8)) AS MEMBER_CODE, " +
                "         B.NAME, " +
                "         A.BAL_SHARES_FOR_DIV, A.DIV_AMOUNT, A.DIV_AMOUNT_POST, " +
                "         SUBSTR(A.CR_ACCOUNT_CODE,3,2)||'/'||" +
                "           TO_NUMBER(SUBSTR(A.CR_ACCOUNT_CODE,8)) AS CR_ACCOUNT_CODE, " +
                "         A.DIV_PERCENTAGE, " +
                "         SUBSTR(A.CR_ACCOUNT_CODE,1,4) AS BRANCH_CODE " +
                "  FROM SHARES.DIVIDEND_CALC A, ACCOUNT.ACCOUNT B " +
                "  WHERE A.MEMBER_CODE = B.ACCOUNT_CODE " +
                "  AND SUBSTR(A.MEMBER_CODE,1,4) = ? " +
                "  AND SUBSTR(B.ACCOUNT_CODE,5,3) = ? " +
                "  AND A.Y_BEGIN_DATE  = TO_DATE(?,'YYYY-MM-DD') " +
                "  AND A.Y_END_DATE    = TO_DATE(?,'YYYY-MM-DD') " +
                "  AND A.DIV_BAL_DATE  = TO_DATE(?,'YYYY-MM-DD') " +
                "  AND SUBSTR(A.CR_ACCOUNT_CODE,5,1) = '2' " +
                "  ORDER BY TO_NUMBER(SUBSTR(A.MEMBER_CODE,8))" +
                ") ORDER BY BRANCH_CODE";
            ps = conn.prepareStatement(sql);
            ps.setString(1, branchCode);
            ps.setString(2, productCode);
            ps.setString(3, yearBegin);
            ps.setString(4, yearEnd);
            ps.setString(5, divBalDate);
            rs = ps.executeQuery();
            double total = 0;
            int count = 0;
            StringBuilder rows = new StringBuilder("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) rows.append(",");
                double postAmt = rs.getDouble("DIV_AMOUNT_POST");
                total += postAmt;
                count++;
                rows.append("{")
                    .append("\"srNo\":").append(rs.getInt("SR_NO")).append(",")
                    .append("\"memberCode\":\"").append(jsonSafe(rs.getString("MEMBER_CODE"))).append("\",")
                    .append("\"name\":\"").append(jsonSafe(rs.getString("NAME"))).append("\",")
                    .append("\"balForDiv\":").append(rs.getDouble("BAL_SHARES_FOR_DIV")).append(",")
                    .append("\"divAmount\":").append(rs.getDouble("DIV_AMOUNT")).append(",")
                    .append("\"divAmountPost\":").append(postAmt).append(",")
                    .append("\"crAccountCode\":\"").append(jsonSafe(rs.getString("CR_ACCOUNT_CODE"))).append("\",")
                    .append("\"divPercentage\":").append(rs.getDouble("DIV_PERCENTAGE")).append(",")
                    .append("\"branchCode\":\"").append(jsonSafe(rs.getString("BRANCH_CODE"))).append("\"")
                    .append("}");
                first = false;
            }
            rows.append("]");
            pw.print("{\"success\":true,\"count\":" + count + ",\"total\":" + total + ",\"rows\":" + rows + "}");
        } catch (Exception e) {
            pw.print("{\"success\":false,\"message\":\"" + jsonSafeErr(e) + "\"}");
        } finally {
            closeQuietly(rs, ps, conn);
        }
    }

    // ══════════════════════════════════════════
    // ACTION reportCR
    // ══════════════════════════════════════════
    private void reportCR(HttpServletRequest req, PrintWriter pw, String branchCode) {
        String productCode = nvl(req.getParameter("productCode"));
        String yearBegin   = nvl(req.getParameter("yearBegin"));
        String yearEnd     = nvl(req.getParameter("yearEnd"));
        String divBalDate  = nvl(req.getParameter("divBalDate"));
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            String sql =
                "SELECT A.MEMBER_CODE, TRIM(B.NAME) AS NAME, " +
                "       A.BAL_SHARES_FOR_DIV, A.DIV_AMOUNT, A.DIV_AMOUNT_POST, A.DIV_PERCENTAGE " +
                "FROM SHARES.DIVIDEND_CALC A, ACCOUNT.ACCOUNT B " +
                "WHERE A.MEMBER_CODE = B.ACCOUNT_CODE " +
                "AND SUBSTR(A.MEMBER_CODE,1,4) = ? " +
                "AND SUBSTR(B.ACCOUNT_CODE,5,3) = ? " +
                "AND A.Y_BEGIN_DATE  = TO_DATE(?,'YYYY-MM-DD') " +
                "AND A.Y_END_DATE    = TO_DATE(?,'YYYY-MM-DD') " +
                "AND A.DIV_BAL_DATE  = TO_DATE(?,'YYYY-MM-DD') " +
                "AND TRIM(A.CR_ACCOUNT_CODE) = '0' " +
                "ORDER BY A.MEMBER_CODE";
            ps = conn.prepareStatement(sql);
            ps.setString(1, branchCode);
            ps.setString(2, productCode);
            ps.setString(3, yearBegin);
            ps.setString(4, yearEnd);
            ps.setString(5, divBalDate);
            rs = ps.executeQuery();
            double total = 0;
            int count = 0;
            StringBuilder rows = new StringBuilder("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) rows.append(",");
                double postAmt = rs.getDouble("DIV_AMOUNT_POST");
                total += postAmt;
                count++;
                rows.append("{")
                    .append("\"memberCode\":\"").append(jsonSafe(rs.getString("MEMBER_CODE"))).append("\",")
                    .append("\"name\":\"").append(jsonSafe(rs.getString("NAME"))).append("\",")
                    .append("\"balForDiv\":").append(rs.getDouble("BAL_SHARES_FOR_DIV")).append(",")
                    .append("\"divAmount\":").append(rs.getDouble("DIV_AMOUNT")).append(",")
                    .append("\"divAmountPost\":").append(postAmt).append(",")
                    .append("\"divPercentage\":").append(rs.getDouble("DIV_PERCENTAGE"))
                    .append("}");
                first = false;
            }
            rows.append("]");
            pw.print("{\"success\":true,\"count\":" + count + ",\"total\":" + total + ",\"rows\":" + rows + "}");
        } catch (Exception e) {
            pw.print("{\"success\":false,\"message\":\"" + jsonSafeErr(e) + "\"}");
        } finally {
            closeQuietly(rs, ps, conn);
        }
    }

    // ══════════════════════════════════════════
    // Excel / CSV download
    // ══════════════════════════════════════════
    private void generateExcelCSV(HttpServletRequest req, HttpServletResponse res,
                                   String branchCode, String mode) throws IOException {
        String productCode = nvl(req.getParameter("productCode"));
        String yearBegin   = nvl(req.getParameter("yearBegin"));
        String yearEnd     = nvl(req.getParameter("yearEnd"));
        String divBalDate  = nvl(req.getParameter("divBalDate"));
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            String sql;
            if ("SB".equals(mode)) {
                sql =
                    "SELECT ROWNUM SR_NO, MEMBER_CODE, NAME, BAL_SHARES_FOR_DIV, " +
                    "       DIV_AMOUNT, DIV_AMOUNT_POST, CR_ACCOUNT_CODE, DIV_PERCENTAGE, BRANCH_CODE " +
                    "FROM (" +
                    "  SELECT TO_NUMBER(SUBSTR(A.MEMBER_CODE,8)) MEMBER_CODE, B.NAME, " +
                    "         A.BAL_SHARES_FOR_DIV, A.DIV_AMOUNT, A.DIV_AMOUNT_POST, " +
                    "         SUBSTR(A.CR_ACCOUNT_CODE,3,2)||'/'||TO_NUMBER(SUBSTR(A.CR_ACCOUNT_CODE,8)) CR_ACCOUNT_CODE, " +
                    "         A.DIV_PERCENTAGE, SUBSTR(A.CR_ACCOUNT_CODE,1,4) BRANCH_CODE " +
                    "  FROM SHARES.DIVIDEND_CALC A, ACCOUNT.ACCOUNT B " +
                    "  WHERE A.MEMBER_CODE = B.ACCOUNT_CODE " +
                    "  AND SUBSTR(A.MEMBER_CODE,1,4) = ? AND SUBSTR(B.ACCOUNT_CODE,5,3) = ? " +
                    "  AND A.Y_BEGIN_DATE = TO_DATE(?,'YYYY-MM-DD') " +
                    "  AND A.Y_END_DATE   = TO_DATE(?,'YYYY-MM-DD') " +
                    "  AND A.DIV_BAL_DATE = TO_DATE(?,'YYYY-MM-DD') " +
                    "  AND SUBSTR(A.CR_ACCOUNT_CODE,5,1) = '2' " +
                    "  ORDER BY TO_NUMBER(SUBSTR(A.MEMBER_CODE,8))" +
                    ") ORDER BY BRANCH_CODE";
            } else if ("CR".equals(mode)) {
                sql =
                    "SELECT A.MEMBER_CODE, TRIM(B.NAME) NAME, " +
                    "       A.BAL_SHARES_FOR_DIV, A.DIV_AMOUNT, A.DIV_AMOUNT_POST, A.DIV_PERCENTAGE " +
                    "FROM SHARES.DIVIDEND_CALC A, ACCOUNT.ACCOUNT B " +
                    "WHERE A.MEMBER_CODE = B.ACCOUNT_CODE " +
                    "AND SUBSTR(A.MEMBER_CODE,1,4) = ? AND SUBSTR(B.ACCOUNT_CODE,5,3) = ? " +
                    "AND A.Y_BEGIN_DATE = TO_DATE(?,'YYYY-MM-DD') " +
                    "AND A.Y_END_DATE   = TO_DATE(?,'YYYY-MM-DD') " +
                    "AND A.DIV_BAL_DATE = TO_DATE(?,'YYYY-MM-DD') " +
                    "AND TRIM(A.CR_ACCOUNT_CODE) = '0' " +
                    "ORDER BY A.MEMBER_CODE";
            } else {
                // ALL
                sql =
                    "SELECT ROWNUM SR_NO, MEMBER_CODE, NAME, BAL_SHARES_FOR_DIV, " +
                    "       DIV_AMOUNT, DIV_AMOUNT_POST, CR_ACCOUNT_CODE, DIV_PERCENTAGE " +
                    "FROM (" +
                    "  SELECT TO_NUMBER(SUBSTR(A.MEMBER_CODE,8)) MEMBER_CODE, TRIM(B.NAME) NAME, " +
                    "         A.BAL_SHARES_FOR_DIV, A.DIV_AMOUNT, A.DIV_AMOUNT_POST, " +
                    "         DECODE(TO_CHAR(TO_NUMBER(DECODE(TRIM(A.CR_ACCOUNT_CODE),'0','0'," +
                    "           TRIM(SUBSTR(A.CR_ACCOUNT_CODE,8))))),'0',''," +
                    "           TO_CHAR(TO_NUMBER(DECODE(TRIM(A.CR_ACCOUNT_CODE),'0','0'," +
                    "           TRIM(SUBSTR(A.CR_ACCOUNT_CODE,8)))))) CR_ACCOUNT_CODE, " +
                    "         A.DIV_PERCENTAGE " +
                    "  FROM SHARES.DIVIDEND_CALC A, ACCOUNT.ACCOUNT B " +
                    "  WHERE A.MEMBER_CODE = B.ACCOUNT_CODE " +
                    "  AND SUBSTR(A.MEMBER_CODE,1,4) = ? AND SUBSTR(B.ACCOUNT_CODE,5,3) = ? " +
                    "  AND A.Y_BEGIN_DATE = TO_DATE(?,'YYYY-MM-DD') " +
                    "  AND A.Y_END_DATE   = TO_DATE(?,'YYYY-MM-DD') " +
                    "  AND A.DIV_BAL_DATE = TO_DATE(?,'YYYY-MM-DD') " +
                    "  ORDER BY TO_NUMBER(SUBSTR(A.MEMBER_CODE,8))" +
                    ")";
            }

            ps = conn.prepareStatement(sql);
            ps.setString(1, branchCode);
            ps.setString(2, productCode);
            ps.setString(3, yearBegin);
            ps.setString(4, yearEnd);
            ps.setString(5, divBalDate);
            rs = ps.executeQuery();

            String filename = "Dividend_" + mode + "_" + productCode + "_" + yearBegin + ".csv";
            res.reset();
            res.setContentType("text/csv; charset=UTF-8");
            res.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

            PrintWriter out = res.getWriter();
            out.write('\uFEFF'); // UTF-8 BOM for Excel

            if ("SB".equals(mode)) {
                out.println("Sr No,Member Code,Name,Bal Shares for Div,Div Amount,Post Amount,SB Account,Div %,Branch");
                while (rs.next()) {
                    out.println(
                        rs.getString("SR_NO") + "," +
                        rs.getString("MEMBER_CODE") + "," +
                        csvSafe(rs.getString("NAME")) + "," +
                        rs.getString("BAL_SHARES_FOR_DIV") + "," +
                        rs.getString("DIV_AMOUNT") + "," +
                        rs.getString("DIV_AMOUNT_POST") + "," +
                        csvSafe(rs.getString("CR_ACCOUNT_CODE")) + "," +
                        rs.getString("DIV_PERCENTAGE") + "," +
                        csvSafe(rs.getString("BRANCH_CODE"))
                    );
                }
            } else if ("CR".equals(mode)) {
                out.println("Member Code,Name,Bal Shares for Div,Div Amount,Post Amount,Div %");
                while (rs.next()) {
                    out.println(
                        rs.getString("MEMBER_CODE") + "," +
                        csvSafe(rs.getString("NAME")) + "," +
                        rs.getString("BAL_SHARES_FOR_DIV") + "," +
                        rs.getString("DIV_AMOUNT") + "," +
                        rs.getString("DIV_AMOUNT_POST") + "," +
                        rs.getString("DIV_PERCENTAGE")
                    );
                }
            } else {
                out.println("Sr No,Member Code,Name,Bal Shares for Div,Div Amount,Post Amount,CR Account,Div %");
                while (rs.next()) {
                    out.println(
                        rs.getString("SR_NO") + "," +
                        rs.getString("MEMBER_CODE") + "," +
                        csvSafe(rs.getString("NAME")) + "," +
                        rs.getString("BAL_SHARES_FOR_DIV") + "," +
                        rs.getString("DIV_AMOUNT") + "," +
                        rs.getString("DIV_AMOUNT_POST") + "," +
                        csvSafe(rs.getString("CR_ACCOUNT_CODE")) + "," +
                        rs.getString("DIV_PERCENTAGE")
                    );
                }
            }
            out.flush();

        } catch (Exception e) {
            if (!res.isCommitted()) {
                res.reset();
                res.setContentType("application/json; charset=UTF-8");
                res.getWriter().print("{\"success\":false,\"message\":\"Excel error: " + jsonSafeErr(e) + "\"}");
            }
        } finally {
            closeQuietly(rs, ps, conn);
        }
    }

    private String csvSafe(String s) {
        if (s == null) return "";
        s = s.trim();
        if (s.contains(",") || s.contains("\"") || s.contains("\n"))
            return "\"" + s.replace("\"", "\"\"") + "\"";
        return s;
    }

    // ══════════════════════════════════════════
    // ACTION 7 — Generate PDF Report
    // ══════════════════════════════════════════
    private void generatePDF(HttpServletRequest req, HttpServletResponse res,
                              String branchCode, String userId) throws IOException {

        String productCode = nvl(req.getParameter("productCode"));
        String memberType  = nvl(req.getParameter("memberType"));
        String yearBegin   = nvl(req.getParameter("yearBegin"));
        String yearEnd     = nvl(req.getParameter("yearEnd"));
        String divBalDate  = nvl(req.getParameter("divBalDate"));
        String percentage  = nvl(req.getParameter("percentage"));

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        Color NAVY      = new Color(0x1a, 0x14, 0x64);
        Color LAVENDER  = new Color(0xE6, 0xE6, 0xFA);
        Color WHITE     = Color.WHITE;
        Color ORANGE    = new Color(0xEF, 0x9F, 0x27);
        Color GREEN_BD  = new Color(0x5D, 0xCA, 0xA5);
        Color GREEN_BG  = new Color(0xE0, 0xF5, 0xEA);
        Color ORANGE_BG = new Color(0xFF, 0xF5, 0xE0);

        try {
            conn = DBConnection.getConnection();
            String sql =
                "SELECT MEMBER_CODE, PAYABLE_AC, CR_ACCOUNT_CODE, " +
                "       BAL_SHARES_FOR_DIV, CURR_BALANCE, DIV_PERCENTAGE, " +
                "       DIV_AMOUNT, DIV_AMOUNT_POST, DIV_WARR_NO, " +
                "       NVL(PAYABLE_TXN_NO,0) AS PAYABLE_TXN_NO, " +
                "       TO_CHAR(PAYABLE_TXN_DATE,'DD-MM-YYYY') AS PAYABLE_TXN_DATE " +
                "FROM shares.dividend_calc " +
                "WHERE BRANCH_CODE = ? " +
                "AND Y_BEGIN_DATE  = TO_DATE(?,'YYYY-MM-DD') " +
                "AND Y_END_DATE    = TO_DATE(?,'YYYY-MM-DD') " +
                "AND DIV_BAL_DATE  = TO_DATE(?,'YYYY-MM-DD') " +
                "AND MEMBER_TYPE   = ? " +
                "ORDER BY MEMBER_CODE";
            ps = conn.prepareStatement(sql);
            ps.setString(1, branchCode);
            ps.setString(2, yearBegin);
            ps.setString(3, yearEnd);
            ps.setString(4, divBalDate);
            ps.setString(5, productCode);
            rs = ps.executeQuery();

            java.util.List<Object[]> dataRows = new java.util.ArrayList<>();
            double grandTotal = 0;
            while (rs.next()) {
                double amt = rs.getDouble("DIV_AMOUNT_POST");
                grandTotal += amt;
                dataRows.add(new Object[]{
                    rs.getString("MEMBER_CODE"),
                    rs.getString("PAYABLE_AC"),
                    rs.getString("CR_ACCOUNT_CODE"),
                    rs.getDouble("BAL_SHARES_FOR_DIV"),
                    rs.getDouble("DIV_PERCENTAGE"),
                    rs.getDouble("DIV_AMOUNT"),
                    amt,
                    rs.getLong("DIV_WARR_NO"),
                    rs.getLong("PAYABLE_TXN_NO"),
                    rs.getString("PAYABLE_TXN_DATE")
                });
            }

            res.reset();
            res.setContentType("application/pdf");
            res.setHeader("Content-Disposition",
                "inline; filename=\"DividendReport_" + productCode + "_" + yearBegin + ".pdf\"");

            Document doc = new Document(PageSize.A4.rotate(), 28, 28, 36, 28);
            PdfWriter writer = PdfWriter.getInstance(doc, res.getOutputStream());

            writer.setPageEvent(new PdfPageEventHelper() {
                Font footFont = FontFactory.getFont(FontFactory.HELVETICA, 7, Color.GRAY);
                @Override
                public void onEndPage(PdfWriter w, Document d) {
                    PdfContentByte cb = w.getDirectContent();
                    String footLeft  = "Generated: " + new SimpleDateFormat("dd-MM-yyyy HH:mm").format(new Date())
                                       + "  |  shares.dividend_calc";
                    String footRight = "** System Generated Report **    Page " + w.getPageNumber();
                    ColumnText.showTextAligned(cb, Element.ALIGN_LEFT,
                        new Phrase(footLeft, footFont), d.leftMargin(), d.bottomMargin() - 10, 0);
                    ColumnText.showTextAligned(cb, Element.ALIGN_RIGHT,
                        new Phrase(footRight, footFont), d.right() - d.rightMargin(), d.bottomMargin() - 10, 0);
                }
            });

            doc.open();

            Font titleFont   = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 13, WHITE);
            Font subFont     = FontFactory.getFont(FontFactory.HELVETICA,       9, WHITE);
            Font boldSmall   = FontFactory.getFont(FontFactory.HELVETICA_BOLD,  8, NAVY);
            Font colHdr      = FontFactory.getFont(FontFactory.HELVETICA_BOLD,  7, WHITE);
            Font cellFont    = FontFactory.getFont(FontFactory.HELVETICA,        7, NAVY);
            Font cellFontB   = FontFactory.getFont(FontFactory.HELVETICA_BOLD,  7, NAVY);
            Font footTotFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD,  8, WHITE);

            // Banner
            PdfPTable banner = new PdfPTable(2);
            banner.setWidthPercentage(100);
            banner.setWidths(new float[]{3f, 1.6f});
            banner.setSpacingAfter(8);
            PdfPCell orgCell = new PdfPCell();
            orgCell.setBackgroundColor(NAVY); orgCell.setBorder(Rectangle.NO_BORDER); orgCell.setPadding(10);
            orgCell.addElement(new Phrase("Co-operative Bank", titleFont));
            orgCell.addElement(new Phrase("Shares Division  —  Dividend Calculation Report", subFont));
            banner.addCell(orgCell);
            String today = new SimpleDateFormat("dd-MM-yyyy").format(new Date());
            PdfPCell metaCell = new PdfPCell();
            metaCell.setBackgroundColor(NAVY); metaCell.setBorder(Rectangle.NO_BORDER);
            metaCell.setPadding(10); metaCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
            metaCell.addElement(new Phrase("Branch : " + branchCode + "    User : " + userId, subFont));
            metaCell.addElement(new Phrase("Date   : " + today, subFont));
            banner.addCell(metaCell);
            doc.add(banner);

            // Summary pills
            PdfPTable summary = new PdfPTable(8);
            summary.setWidthPercentage(100); summary.setSpacingAfter(10);
            String[] sumLabels = { "Product Code","Member Type","Year Begin","Year End",
                                   "Div Bal Date","Rate %","Total Members","Total Dividend" };
            String[] sumVals   = { productCode, memberType, fmtDate(yearBegin), fmtDate(yearEnd),
                                   fmtDate(divBalDate), percentage + "%",
                                   String.valueOf(dataRows.size()),
                                   "\u20B9 " + String.format("%,.2f", grandTotal) };
            for (int i = 0; i < sumLabels.length; i++) {
                PdfPCell sc = new PdfPCell();
                sc.setBackgroundColor(LAVENDER);
                sc.setBorderColor(new Color(0xB8, 0xB8, 0xE6)); sc.setBorderWidth(0.5f); sc.setPadding(5);
                sc.addElement(new Phrase(sumLabels[i], FontFactory.getFont(FontFactory.HELVETICA, 6.5f, NAVY)));
                sc.addElement(new Phrase(sumVals[i], boldSmall));
                summary.addCell(sc);
            }
            doc.add(summary);

            // Data table
            PdfPTable tbl = new PdfPTable(11);
            tbl.setWidthPercentage(100);
            tbl.setWidths(new float[]{0.5f,1.4f,1.8f,1.8f,1.4f,0.7f,1.3f,1.3f,1.0f,0.9f,1.1f});
            tbl.setHeaderRows(1);
            String[] headers = { "#","Member Code","Payable Account","SB Account",
                                  "Bal for Div (\u20B9)","Rate %",
                                  "Div Amount (\u20B9)","Post Amount (\u20B9)",
                                  "Warrant No","Status","Txn Date" };
            for (String h : headers) {
                PdfPCell hc = new PdfPCell(new Phrase(h, colHdr));
                hc.setBackgroundColor(NAVY); hc.setBorder(Rectangle.NO_BORDER);
                hc.setPaddingTop(5); hc.setPaddingBottom(5);
                hc.setPaddingLeft(4); hc.setPaddingRight(4);
                hc.setHorizontalAlignment(Element.ALIGN_CENTER);
                tbl.addCell(hc);
            }

            int sr = 0;
            for (Object[] row : dataRows) {
                sr++;
                Color bg    = (sr % 2 == 0) ? new Color(0xF0,0xF0,0xFA) : WHITE;
                String memCode = nvlStr(row[0]);
                String payAc   = nvlStr(row[1]);
                String crAc    = nvlStr(row[2]);
                double bal     = (Double) row[3];
                double pct     = (Double) row[4];
                double divAmt  = (Double) row[5];
                double postAmt = (Double) row[6];
                long   warrNo  = (Long)   row[7];
                long   txnNo   = (Long)   row[8];
                String txnDate = nvlStr(row[9]);
                boolean posted = txnNo != 0;

                tbl.addCell(tblCell(String.valueOf(sr),                                  cellFont,  bg, Element.ALIGN_CENTER));
                tbl.addCell(tblCell(memCode,                                             cellFont,  bg, Element.ALIGN_LEFT));
                tbl.addCell(tblCell(payAc,                                               cellFontB, bg, Element.ALIGN_LEFT));
                tbl.addCell(tblCell(crAc.isEmpty() || "0".equals(crAc) ? "-" : crAc,   cellFont,  bg, Element.ALIGN_LEFT));
                tbl.addCell(tblCell(String.format("%,.2f", bal),                        cellFont,  bg, Element.ALIGN_RIGHT));
                tbl.addCell(tblCell(pct + "%",                                          cellFont,  bg, Element.ALIGN_RIGHT));
                tbl.addCell(tblCell(String.format("%,.2f", divAmt),                    cellFont,  bg, Element.ALIGN_RIGHT));
                tbl.addCell(tblCell(String.format("%,.2f", postAmt),                   cellFontB, bg, Element.ALIGN_RIGHT));
                tbl.addCell(tblCell(String.valueOf(warrNo),                             cellFont,  bg, Element.ALIGN_CENTER));

                PdfPCell statusCell = new PdfPCell(new Phrase(posted ? "Posted" : "Pending",
                    FontFactory.getFont(FontFactory.HELVETICA_BOLD, 6.5f,
                        posted ? new Color(0x0F,0x6E,0x56) : new Color(0x85,0x4F,0x0B))));
                statusCell.setBackgroundColor(posted ? GREEN_BG : ORANGE_BG);
                statusCell.setBorderColor(posted ? GREEN_BD : ORANGE);
                statusCell.setBorderWidth(0.5f); statusCell.setPadding(3);
                statusCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                statusCell.setVerticalAlignment(Element.ALIGN_MIDDLE);
                tbl.addCell(statusCell);

                tbl.addCell(tblCell(txnDate == null || txnDate.isEmpty() ? "-" : txnDate,
                                    cellFont, bg, Element.ALIGN_CENTER));
            }

            PdfPCell totLabel = new PdfPCell(new Phrase("Total Dividend to Post :", footTotFont));
            totLabel.setColspan(7); totLabel.setBackgroundColor(NAVY);
            totLabel.setBorder(Rectangle.NO_BORDER); totLabel.setPadding(5);
            totLabel.setHorizontalAlignment(Element.ALIGN_RIGHT);
            tbl.addCell(totLabel);
            PdfPCell totVal = new PdfPCell(new Phrase("\u20B9 " + String.format("%,.2f", grandTotal), footTotFont));
            totVal.setBackgroundColor(NAVY); totVal.setBorder(Rectangle.NO_BORDER);
            totVal.setPadding(5); totVal.setHorizontalAlignment(Element.ALIGN_RIGHT);
            tbl.addCell(totVal);
            PdfPCell totBlank = new PdfPCell(new Phrase(""));
            totBlank.setColspan(3); totBlank.setBackgroundColor(NAVY);
            totBlank.setBorder(Rectangle.NO_BORDER); totBlank.setPadding(5);
            tbl.addCell(totBlank);

            doc.add(tbl);
            doc.close();

        } catch (Exception e) {
            if (!res.isCommitted()) {
                res.reset();
                res.setContentType("application/json; charset=UTF-8");
                res.getWriter().print("{\"success\":false,\"message\":\"PDF error: " + jsonSafeErr(e) + "\"}");
            }
        } finally {
            closeQuietly(rs, ps, conn);
        }
    }

    private PdfPCell tblCell(String text, Font f, Color bg, int align) {
        PdfPCell c = new PdfPCell(new Phrase(text == null ? "" : text, f));
        c.setBackgroundColor(bg);
        c.setBorderColor(new Color(0xD8, 0xD8, 0xF0)); c.setBorderWidth(0.4f);
        c.setPaddingTop(4); c.setPaddingBottom(4);
        c.setPaddingLeft(4); c.setPaddingRight(4);
        c.setHorizontalAlignment(align); c.setVerticalAlignment(Element.ALIGN_MIDDLE);
        return c;
    }

    private String fmtDate(String d) {
        if (d == null || d.length() < 10) return d;
        try { String[] p = d.split("-"); return p[2] + "-" + p[1] + "-" + p[0]; }
        catch (Exception e) { return d; }
    }

    private String nvlStr(Object o) { return o == null ? "" : o.toString().trim(); }

    // ══════════════════════════════════════════
    // ACTION 5 — Posting Payable
    // Calls sp_dividend_pay — credits the PAYABLE account per member
    // and inserts DIVIDEND_WARR_PAID_UNPAID rows as 'UP'
    // ══════════════════════════════════════════
    private void postingPayable(HttpServletRequest req, PrintWriter pw,
                                String branchCode, String userId) {
        String productCode = nvl(req.getParameter("productCode"));
        String yearBegin   = nvl(req.getParameter("yearBegin"));
        String yearEnd     = nvl(req.getParameter("yearEnd"));
        String divBalDate  = nvl(req.getParameter("divBalDate"));
        Connection conn    = null;
        CallableStatement cs = null;
        try {
            conn = DBConnection.getConnection();
            cs = conn.prepareCall("{call sp_dividend_pay(?,?,?,?,?,?,?)}");
            cs.setString(1, branchCode);
            cs.setDate(2, new java.sql.Date(new java.util.Date().getTime()));
            cs.setDate(3, java.sql.Date.valueOf(divBalDate));
            cs.setDate(4, java.sql.Date.valueOf(yearBegin));
            cs.setDate(5, java.sql.Date.valueOf(yearEnd));
            cs.setString(6, productCode);
            cs.setString(7, userId);
            cs.execute();
            pw.print("{\"success\":true,\"message\":\"Dividend posted successfully to all accounts!\"}");
        } catch (Exception e) {
            pw.print("{\"success\":false,\"message\":\"" + jsonSafeErr(e) + "\"}");
        } finally {
            closeQuietly(null, cs, conn);
        }
    }

    // ══════════════════════════════════════════
    // ACTION 6 — Posting SB
    // FIX: was calling sp_dividend_pay (WRONG — same as Posting Payable).
    // Corrected to call sp_dividend_post which:
    //   - debits the payable account
    //   - credits the member's SB savings account (CR_ACCOUNT_CODE)
    //   - updates DIVIDEND_WARR_PAID_UNPAID status from 'UP' to 'PD'
    //   - stamps CR_TXN_NO on SHARES.DIVIDEND_CALC
    // NOTE: sp_dividend_post has 8 parameters. The 8th (p_ho_br_code) defaults
    // to '0001' but MUST be passed explicitly as branchCode, otherwise the cursor
    // will filter on branch '0001' and skip all members if your branch differs.
    // ══════════════════════════════════════════
    private void postingSB(HttpServletRequest req, PrintWriter pw,
                           String branchCode, String userId) {
        String productCode = nvl(req.getParameter("productCode"));
        String yearBegin   = nvl(req.getParameter("yearBegin"));
        String yearEnd     = nvl(req.getParameter("yearEnd"));
        String divBalDate  = nvl(req.getParameter("divBalDate"));
        Connection conn    = null;
        CallableStatement cs = null;
        try {
            conn = DBConnection.getConnection();
            // FIX: changed from sp_dividend_pay(7 params) to sp_dividend_post(8 params)
            cs = conn.prepareCall("{call sp_dividend_post(?,?,?,?,?,?,?,?)}");
            cs.setString(1, branchCode);                                          // p_branch_code
            cs.setDate(2, new java.sql.Date(new java.util.Date().getTime()));     // p_working_date
            cs.setDate(3, java.sql.Date.valueOf(divBalDate));                     // p_div_bal_date
            cs.setDate(4, java.sql.Date.valueOf(yearBegin));                      // p_y_begin_date
            cs.setDate(5, java.sql.Date.valueOf(yearEnd));                        // p_y_end_date
            cs.setString(6, productCode);                                         // p_mem_product_type
            cs.setString(7, userId);                                              // p_user_id
            cs.setString(8, branchCode);                                          // p_ho_br_code (FIX: pass branchCode, not default '0001')
            cs.execute();
            pw.print("{\"success\":true,\"message\":\"Dividend posted to SB accounts successfully!\"}");
        } catch (Exception e) {
            pw.print("{\"success\":false,\"message\":\"" + jsonSafeErr(e) + "\"}");
        } finally {
            closeQuietly(null, cs, conn);
        }
    }

    private void closeQuietly(ResultSet rs, Statement st, Connection conn) {
        try { if (rs   != null) rs.close();  } catch (Exception ignored) {}
        try { if (st   != null) st.close();  } catch (Exception ignored) {}
        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
    }
}
