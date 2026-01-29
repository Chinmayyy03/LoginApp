<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="net.sf.jasperreports.engine.*" %>
<%@ page import="net.sf.jasperreports.engine.export.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
String action = request.getParameter("action");

if ("download".equals(action)) {

    String reporttype = request.getParameter("reporttype");
    String bankCode   = request.getParameter("bank_code");
    String branchCode = request.getParameter("branch_code");
    String asOnDate   = request.getParameter("as_on_date");

    Connection conn = null;

    try {
        /* -------- RESPONSE RESET -------- */
        response.reset();
        response.setBufferSize(1024 * 1024);
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        /* -------- DB CONNECTION -------- */
        Class.forName("oracle.jdbc.OracleDriver");
        conn = DriverManager.getConnection(
            "jdbc:oracle:thin:@192.168.1.117:1521:xe",
            "system",
            "info123"
        );

        /* -------- DATE FORMAT -------- */
        SimpleDateFormat inFmt  = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat outFmt = new SimpleDateFormat("dd-MMM-yyyy");
        String oracleDate = outFmt.format(inFmt.parse(asOnDate)).toUpperCase();

        /* -------- TALLY QUERY (YOUR LOGIC) -------- */
        double tr_receipt = 0, tr_payment = 0;
        double cl_receipt = 0, cl_payment = 0;

        String message = "** Day Book Tallied.";

        String tallySql =
            "SELECT " +
            " SUM(CASE WHEN TRANSACTIONINDICATOR_CODE='TRCR' THEN AMOUNT ELSE 0 END) AS TRANSFER_RECEIPT, " +
            " SUM(CASE WHEN TRANSACTIONINDICATOR_CODE='TRDR' THEN AMOUNT ELSE 0 END) AS TRANSFER_PAYMENT, " +
            " SUM(CASE WHEN TRANSACTIONINDICATOR_CODE='CLCR' THEN AMOUNT ELSE 0 END) AS CLEARING_RECEIPT, " +
            " SUM(CASE WHEN TRANSACTIONINDICATOR_CODE='CLDR' THEN AMOUNT ELSE 0 END) AS CLEARING_PAYMENT " +
            "FROM TRANSACTION.TRANSACTION_HT_VIEW t " +
            "JOIN ACCOUNTLINK.DEFAULTBANKACCOUNTS d ON (d.BANK_CODE = ?) " +
            "WHERE t.TXN_DATE = TO_DATE(?, 'DD-MON-YYYY') " +
            "AND t.BRANCH_CODE = ? " +
            "AND t.TXN_NUMBER <> 0 " +
            "AND t.GLACCOUNT_CODE <> d.ACCOUNT_CODE_CASH_IN_HAND";

        PreparedStatement ps = conn.prepareStatement(tallySql);
        ps.setString(1, bankCode);
        ps.setString(2, oracleDate);
        ps.setString(3, branchCode);

        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            tr_receipt = rs.getDouble("TRANSFER_RECEIPT");
            tr_payment = rs.getDouble("TRANSFER_PAYMENT");
            cl_receipt = rs.getDouble("CLEARING_RECEIPT");
            cl_payment = rs.getDouble("CLEARING_PAYMENT");
        }
        rs.close();
        ps.close();

        if (tr_receipt != tr_payment && cl_receipt != cl_payment) {
            message = "** Transfer And Clearing Not Tally.";
        } else if (tr_receipt != tr_payment) {
            message = "** Transfer Not Tallied.";
        } else if (cl_receipt != cl_payment) {
            message = "** Clearing Not Tallied.";
        }

        /* -------- JASPER -------- */
        String reportPath = application.getRealPath("/Reports/daybookRG.jrxml");
        JasperReport jasperReport = JasperCompileManager.compileReport(reportPath);

        Map<String, Object> parameters = new HashMap<>();
        parameters.put("bank_code", bankCode);
        parameters.put("branch_code", branchCode);
        parameters.put("as_on_date", oracleDate);
        parameters.put("tally_message", message);

        JasperPrint jasperPrint =
            JasperFillManager.fillReport(jasperReport, parameters, conn);

        /* -------- FIXED VARIABLE NAME (NO DUPLICATE 'out') -------- */
        ServletOutputStream outputStream = response.getOutputStream();

        if ("pdf".equalsIgnoreCase(reporttype)) {
            response.setContentType("application/pdf");
            response.setHeader(
                "Content-Disposition",
                "attachment; filename=DayBook_" + asOnDate.replace("-", "_") + ".pdf"
            );
            JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);
        } else {
            response.setContentType("application/vnd.ms-excel");
            response.setHeader(
                "Content-Disposition",
                "attachment; filename=DayBook_" + asOnDate.replace("-", "_") + ".xls"
            );
            JRXlsExporter exporter = new JRXlsExporter();
            exporter.setParameter(JRXlsExporterParameter.JASPER_PRINT, jasperPrint);
            exporter.setParameter(JRXlsExporterParameter.OUTPUT_STREAM, outputStream);
            exporter.exportReport();
        }

        outputStream.flush();
        outputStream.close();
        return;

    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("errorMessage", e.getMessage());
    } finally {
        if (conn != null) conn.close();
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Day Book Report</title>

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">

    <style>
        body {
            background-color: #eef1f5;
            padding-top: 50px;
        }
        .card {
            box-shadow: 0 4px 10px rgba(0,0,0,.1);
        }
    </style>
</head>

<body>

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-7">

            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert alert-danger">
                    <strong>Error:</strong> <%= request.getAttribute("errorMessage") %>
                </div>
            <% } %>

            <div class="card">
                <div class="card-header bg-primary text-white text-center">
                    <h5>Day Book Report</h5>
                </div>

                <div class="card-body">
                    <form method="post">

                        <input type="hidden" name="action" value="download"/>

                        <div class="form-group">
                            <label>Bank Code</label>
                            <input type="text" name="bank_code"
                                   class="form-control" required>
                        </div>

                        <div class="form-group">
                            <label>Branch Code</label>
                            <input type="text" name="branch_code"
                                   class="form-control" required>
                        </div>

                        <div class="form-group">
                            <label>As On Date</label>
                            <input type="date" name="as_on_date"
                                   class="form-control" required>
                        </div>

                        <div class="form-group">
                            <label>Report Format</label><br>
                            <label>
                                <input type="radio" name="reporttype"
                                       value="pdf" checked> PDF
                            </label>
                            &nbsp;&nbsp;
                            <label>
                                <input type="radio" name="reporttype"
                                       value="xls"> Excel
                            </label>
                        </div>

                        <div class="text-center">
                            <button type="submit"
                                    class="btn btn-success">
                                Download Report
                            </button>
                        </div>

                    </form>
                </div>
            </div>

        </div>
    </div>
</div>

</body>
</html>

