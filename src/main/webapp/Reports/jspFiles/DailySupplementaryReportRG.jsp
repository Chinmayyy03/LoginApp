<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page buffer="none" %>

<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="net.sf.jasperreports.engine.*" %>
<%@ page import="net.sf.jasperreports.engine.export.*" %>
<%@ page import="net.sf.jasperreports.export.*" %>
<%@ page import="net.sf.jasperreports.engine.util.JRLoader" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>

<%@ page import="db.DBConnection" %>

<%
    String action = request.getParameter("action");

    if ("download".equals(action)) {

        String reporttype = request.getParameter("reporttype");
        String branchCode = request.getParameter("branch_code");
        String asOnDate = request.getParameter("as_on_date");

        Connection conn = null;
        Connection summaryConn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // Clear response
            response.reset();
            response.setBufferSize(1024 * 1024);
            
            // Set response headers
            response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0, post-check=0, pre-check=0");
            response.setHeader("Pragma", "no-cache");
            response.setDateHeader("Expires", 0);
            response.setCharacterEncoding("UTF-8");

            // Get database connection from DBConnection class
            conn = DBConnection.getConnection();
            
            // Create a separate connection for summary query
            summaryConn = DBConnection.getConnection();

            // Get reports directory - Fix the path
            String reportsDir = application.getRealPath("/Reports/");
            if (reportsDir == null) {
                // Try alternative path
                reportsDir = application.getRealPath("/") + "Reports/";
            }
            
            if (!reportsDir.endsWith(File.separator)) {
                reportsDir += File.separator;
            }
            
            // Paths for reports
            String mainReportPath = reportsDir + "DailySupplementaryReportRG.jasper";
            String subReportPath = reportsDir + "subReportHeader.jasper";
            
            // Check if files exist
            File mainReportFile = new File(mainReportPath);
            File subReportFile = new File(subReportPath);
            
            if (!mainReportFile.exists()) {
                throw new Exception("Main report file not found at: " + mainReportPath);
            }
            
            if (!subReportFile.exists()) {
                throw new Exception("Subreport file not found at: " + subReportPath);
            }

            // Convert date to Oracle format
            String oracleDate = "";
            if (asOnDate != null && !asOnDate.trim().isEmpty()) {
                try {
                    java.util.Date utilDate = new SimpleDateFormat("yyyy-MM-dd").parse(asOnDate);
                    oracleDate = new SimpleDateFormat("dd-MMM-yyyy", Locale.ENGLISH).format(utilDate).toUpperCase();
                } catch (Exception e) {
                    oracleDate = asOnDate;
                }
            }

            // First query - Get summary totals using separate connection
            String summarySql = "SELECT " +
                        "    NVL(SUM(CREDIT_TOTAL), 0) AS CASH_RECEIPT, " +
                        "    NVL(SUM(DEBIT_TOTAL), 0)  AS CASH_PAYMENT " +
                        "FROM " +
                        "( " +
                        " SELECT  " +
                        "        GLACCOUNT_CODE, " +
                        "        DESCRIPTION, " +
                        "        ACCOUNT_CODE, " +
                        "        NAME, " +
                        "        CHEQUENUMBER, " +
                        "        to_char(CHEQUEDATE,'DD-MM-YY') AS A, " +
                        "        CREDIT_CASH , " +
                        "        CREDIT_TRANSFER, " +
                        "        CREDIT_CLEARING, " +
                        "        (CREDIT_CASH+CREDIT_TRANSFER+CREDIT_CLEARING) AS CREDIT_TOTAL, " +
                        "        DEBIT_CASH, " +
                        "        DEBIT_TRANSFER, " +
                        "        DEBIT_CLEARING, " +
                        "        (DEBIT_CASH+DEBIT_TRANSFER+DEBIT_CLEARING) AS DEBIT_TOTAL, " +
                        "        USER_ID, " +
                        "        OFFICER_ID, " +
                        "        PARTICULAR, " +
                        "        SCROLL_NUMBER   " +
                        " FROM( " +
                        "        SELECT  " +
                        "            DT.GLACCOUNT_CODE, " +
                        "            GA.DESCRIPTION, " +
                        "            DT.ACCOUNT_CODE, " +
                        "            INITCAP(trim(A.NAME)) AS NAME, " +
                        "            DT.CHEQUENUMBER, " +
                        "            DT.CHEQUEDATE, " +
                        "            CASE WHEN DT.TRANSACTIONINDICATOR_CODE='CSCR' THEN DT.AMOUNT ELSE 0 END CREDIT_CASH, " +
                        "            CASE WHEN DT.TRANSACTIONINDICATOR_CODE='TRCR' THEN DT.AMOUNT ELSE 0 END CREDIT_TRANSFER, " +
                        "            CASE WHEN DT.TRANSACTIONINDICATOR_CODE='CLCR' THEN DT.AMOUNT ELSE 0 END CREDIT_CLEARING, " +
                        "            CASE WHEN DT.TRANSACTIONINDICATOR_CODE='CSDR' THEN DT.AMOUNT ELSE 0 END DEBIT_CASH, " +
                        "            CASE WHEN DT.TRANSACTIONINDICATOR_CODE='TRDR' THEN DT.AMOUNT ELSE 0 END DEBIT_TRANSFER, " +
                        "            CASE WHEN DT.TRANSACTIONINDICATOR_CODE='CLDR' THEN DT.AMOUNT ELSE 0 END DEBIT_CLEARING, " +
                        "            DT.USER_ID, " +
                        "            DT.OFFICER_ID, " +
                        "            DT.PARTICULAR, " +
                        "            DT.SCROLL_NUMBER   " +
                        "        FROM TRANSACTION.TRANSACTION_HT_VIEW DT " +
                        "        JOIN HEADOFFICE.GLACCOUNT GA ON DT.GLACCOUNT_CODE = GA.GLACCOUNT_CODE " +
                        "        JOIN ACCOUNT.ACCOUNT A ON DT.ACCOUNT_CODE = A.ACCOUNT_CODE " +
                        "        WHERE DT.BRANCH_CODE = ? " +
                        "        AND DT.TXN_DATE = TO_DATE(?, 'DD-MON-YYYY') " +
                        "        AND DT.TRANIDENTIFICATION_ID NOT IN (31,32) " +
                        "        AND DT.TRANSACTIONSTATUS = 'A' " +
                        " ) " +
                        ")";

            // Execute summary query on separate connection
            pstmt = summaryConn.prepareStatement(summarySql);
            pstmt.setString(1, branchCode);
            pstmt.setString(2, oracleDate);
            rs = pstmt.executeQuery();
            
            double cashReceipt = 0;
            double cashPayment = 0;
            
            if (rs.next()) {
                cashReceipt = rs.getDouble("CASH_RECEIPT");
                cashPayment = rs.getDouble("CASH_PAYMENT");
            }
            
            // Close summary query resources
            rs.close();
            pstmt.close();
            summaryConn.close();
            summaryConn = null;

            // Load compiled subreport
            JasperReport subJasperReport = (JasperReport) JRLoader.loadObject(new File(subReportPath));
            
            // Load compiled main report
            JasperReport jasperReport = (JasperReport) JRLoader.loadObject(new File(mainReportPath));

            Map<String, Object> parameters = new HashMap<>();
            parameters.put("branch_code", branchCode);
            parameters.put("as_on_date", oracleDate);
            parameters.put("report_title", "Daily Supplementary Report");
            parameters.put("SUBREPORT_DIR", reportsDir);
            
            // Add summary totals to parameters
            parameters.put("CASH_RECEIPT", cashReceipt);
            parameters.put("CASH_PAYMENT", cashPayment);
            parameters.put("NET_POSITION", cashReceipt - cashPayment);
            
            // Add user_id parameter from session
            parameters.put("user_id", session.getAttribute("user_id") != null ? 
                          session.getAttribute("user_id") : "admin");
            
            // Add image path if needed
            String imagePath = application.getRealPath("/images/UPSB MONO.png");
            if (imagePath != null) {
                parameters.put("IMAGE_PATH", imagePath);
            }
            
            // Pass the subreport as a compiled object
            parameters.put("subReportHeader.jasper", subJasperReport);

            // Fill report using main connection
            JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, parameters, conn);

            String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date());
            ServletOutputStream outputStream = response.getOutputStream();
            
            if ("pdf".equalsIgnoreCase(reporttype)) {

                response.reset();
                response.setContentType("application/pdf");

                response.setHeader(
                    "Content-Disposition",
                    "inline; filename=\"DailySupplementaryReport_" 
                    + branchCode + "_" + timestamp + ".pdf\""
                );

                JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);
            
            } else if ("xls".equalsIgnoreCase(reporttype)) {
                response.setContentType("application/vnd.ms-excel");
                response.setHeader("Content-Disposition", "attachment; filename=DailySupplementaryReport_" + branchCode + "_" + timestamp + ".xls");
                
                // Create Excel exporter
                JRXlsExporter exporter = new JRXlsExporter();
                
                // Set input
                exporter.setExporterInput(new SimpleExporterInput(jasperPrint));
                
                // Set output
                exporter.setExporterOutput(new SimpleOutputStreamExporterOutput(outputStream));
                
                // Configure export parameters for proper Excel format
                SimpleXlsReportConfiguration configuration = new SimpleXlsReportConfiguration();
                
                // Essential settings for data visibility
                configuration.setOnePagePerSheet(false);
                configuration.setDetectCellType(true);
                configuration.setIgnoreGraphics(false);
                configuration.setCollapseRowSpan(false);
                configuration.setIgnorePageMargins(true);
                configuration.setRemoveEmptySpaceBetweenRows(false);
                configuration.setRemoveEmptySpaceBetweenColumns(false);
                configuration.setWhitePageBackground(true);
                configuration.setWrapText(false);
                configuration.setCellHidden(false);
                configuration.setCellLocked(false);
                configuration.setShowGridLines(true);
                configuration.setFontSizeFixEnabled(true);
                configuration.setMaxRowsPerSheet(1000000);
                configuration.setAutoFitPageHeight(true);
                
                // Force sheet name
                configuration.setSheetNames(new String[]{"Daily Supplementary Report"});
                
                // Apply configuration
                exporter.setConfiguration(configuration);
                
                // Export the report
                exporter.exportReport();
            }
            
            outputStream.flush();
            outputStream.close();
            
            return;
            
        } catch (Exception e) {
            // Show detailed error
            response.reset();
            response.setContentType("text/html;charset=UTF-8");
%>
          
<%
            return;
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (summaryConn != null) summaryConn.close();
                if (conn != null) conn.close();
            } catch (Exception ex) {
                // Log error if needed
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Daily Supplementary Report</title>

    <link rel="stylesheet"
          href="<%=request.getContextPath()%>/Reports/common-report.css?v=10">
</head>

<body>

<div class="report-container">
    <h1 class="report-title">
        Daily Supplementary Report
    </h1>

    <form method="post"
      action="<%=request.getContextPath()%>/Reports/jspFiles/DailySupplementaryReportRG.jsp"
      target="_blank"
      autocomplete="off">


        <input type="hidden" name="action" value="download"/>

        <div class="parameter-section">
            <div class="parameter-group">
                <div class="parameter-label required">Branch Code</div>
                <input type="text" 
                       name="branch_code" 
                       id="branch_code"
                       class="input-field" 
                       value="0002" 
                       required
                       placeholder="Enter branch code (e.g., 0002)">
            </div>

            <div class="parameter-group">
                <div class="parameter-label required">As On Date</div>
                <input type="date" 
                       name="as_on_date" 
                       id="as_on_date"
                       class="input-field" 
                       required>
            </div>
        </div>

        <div class="format-section">
            <div class="parameter-label required">Report Type</div>

            <div class="format-options">
                <div class="format-option">
                    <input type="radio" name="reporttype" value="pdf" checked id="pdfRadio">
                    <label for="pdfRadio">PDF</label>
                </div>

                <div class="format-option">
                    <input type="radio" name="reporttype" value="xls" id="excelRadio">
                    <label for="excelRadio">Excel</label>
                </div>
            </div>
        </div>

        <button type="submit" class="download-button" id="submitBtn">
            Generate Report
        </button>

    </form>
</div>



<script>
    // Set default date to today
    document.addEventListener('DOMContentLoaded', function() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0');
        var yyyy = today.getFullYear();
        
        today = yyyy + '-' + mm + '-' + dd;
        document.getElementById('as_on_date').value = today;
    });
    
    // Form validation and submission handling
    document.getElementById('reportForm').addEventListener('submit', function(e) {
        var branchCode = document.getElementById('branch_code').value;
        var asOnDate = document.getElementById('as_on_date').value;
        
        if (!branchCode || !asOnDate) {
            alert('Please fill all required fields');
            e.preventDefault();
            return false;
        }
        
        // Show loading overlay
        document.getElementById('loadingOverlay').style.display = 'flex';
        
        // Disable submit button
        var submitBtn = document.getElementById('submitBtn');
        submitBtn.disabled = true;
        submitBtn.innerHTML = 'Generating...';
        
        return true;
    });
    
    // Hide loading when page is shown (back button)
    window.addEventListener('pageshow', function(event) {
        document.getElementById('loadingOverlay').style.display = 'none';
        var submitBtn = document.getElementById('submitBtn');
        submitBtn.disabled = false;
        submitBtn.innerHTML = 'Generate Report';
    });
</script>

</body>
</html>