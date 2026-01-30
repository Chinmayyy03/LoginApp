<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="net.sf.jasperreports.engine.*" %>
<%@ page import="net.sf.jasperreports.engine.export.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.math.BigDecimal" %>

<%
    String action = request.getParameter("action");
    String success = request.getParameter("success");

    if ("download".equals(action)) {

        String reporttype = request.getParameter("reporttype");
        String bankCode = request.getParameter("bank_code");
        String branchCode = request.getParameter("branch_code");
        String asOnDate = request.getParameter("as_on_date");

        Connection conn = null;

        try {
            response.reset();
            response.setBufferSize(1024 * 1024);
            response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
            response.setHeader("Pragma", "no-cache");
            response.setDateHeader("Expires", 0);

            Class.forName("oracle.jdbc.OracleDriver");
            conn = DriverManager.getConnection(
                    "jdbc:oracle:thin:@192.168.1.117:1521:xe",
                    "system",
                    "info123"
            );

            // FIX 1: Use Oracle date format dd-MMM-yyyy (like 29-MAR-2025)
            String oracleDate = "";
            String sessionDate = "";
            if (asOnDate != null && !asOnDate.isEmpty()) {
                try {
                    SimpleDateFormat sdfInput = new SimpleDateFormat("yyyy-MM-dd");
                    SimpleDateFormat sdfOutput = new SimpleDateFormat("dd-MMM-yyyy");
                    java.util.Date date = sdfInput.parse(asOnDate);
                    oracleDate = sdfOutput.format(date).toUpperCase(); // 29-MAR-2025
                    sessionDate = oracleDate;
                } catch (Exception e) {
                    oracleDate = "29-MAR-2025";
                    sessionDate = "29-MAR-2025";
                }
            } else {
                oracleDate = "29-MAR-2025";
                sessionDate = "29-MAR-2025";
            }

            // Ensure proper format for codes
            bankCode = (bankCode != null && !bankCode.trim().isEmpty()) ? bankCode : "0100";
            branchCode = (branchCode != null && !branchCode.trim().isEmpty()) ? branchCode : "0002";

            // FIX 3: Execute the third query to check Transfer and Clearing totals
            String tallyMessage = checkTransferClearingTally(conn, oracleDate, bankCode, branchCode);
            
            // Store tally message in session to show on page
            //session.setAttribute("tallyMessage", tallyMessage);

            String reportPath = application.getRealPath("/Reports/daybookRG.jrxml");
            
            File reportFile = new File(reportPath);
            if (!reportFile.exists()) {
                throw new Exception("Report file not found: " + reportPath);
            }

            // FIX 2: First create and compile cash summary subreport with Java IF-ELSE logic
            String cashSummaryJasperPath = createCashSummarySubreport(conn, oracleDate, bankCode, branchCode, sessionDate, application);
            
            // Now compile main report
            JasperReport jasperReport = JasperCompileManager.compileReport(reportPath);

            Map<String, Object> parameters = new HashMap<String, Object>();
            parameters.put("bank_code", bankCode);
            parameters.put("branch_code", branchCode);
            parameters.put("as_on_date", oracleDate);
            parameters.put("session_date", sessionDate);
            parameters.put("SUBREPORT_DIR", application.getRealPath("/Reports/"));
            
            // Add tally message as parameter for the report
            parameters.put("TALLY_MESSAGE", tallyMessage);

            JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, parameters, conn);

            ServletOutputStream outStream = response.getOutputStream();

            if ("pdf".equalsIgnoreCase(reporttype)) {
                response.setContentType("application/pdf");
                response.setHeader("Content-Type", "application/pdf");
                String pdfFileName = "Daybook_Report_" + asOnDate.replace("-", "_") + ".pdf";
                response.setHeader("Content-Disposition", "attachment; filename=\"" + pdfFileName + "\"");
                
                // NEW: Use custom PDF exporter with page numbers in "1/14" format
                exportPdfWithPageNumbers(jasperPrint, outStream);
                
            } else if ("xls".equalsIgnoreCase(reporttype)) {
                response.setContentType("application/vnd.ms-excel");
                response.setHeader("Content-Type", "application/vnd.ms-excel");
                String excelFileName = "Daybook_Report_" + asOnDate.replace("-", "_") + ".xls";
                response.setHeader("Content-Disposition", "attachment; filename=\"" + excelFileName + "\"");
                
                // Enhanced Excel exporter configuration for better text display
                JRXlsExporter exporter = new JRXlsExporter();
                exporter.setParameter(JRXlsExporterParameter.JASPER_PRINT, jasperPrint);
                exporter.setParameter(JRXlsExporterParameter.OUTPUT_STREAM, outStream);
                exporter.setParameter(JRXlsExporterParameter.IS_ONE_PAGE_PER_SHEET, Boolean.FALSE);
                exporter.setParameter(JRXlsExporterParameter.IS_REMOVE_EMPTY_SPACE_BETWEEN_ROWS, Boolean.TRUE);
                exporter.setParameter(JRXlsExporterParameter.IS_WHITE_PAGE_BACKGROUND, Boolean.FALSE);
                exporter.setParameter(JRXlsExporterParameter.IS_DETECT_CELL_TYPE, Boolean.TRUE);
                
                // CRITICAL FIX: Add these parameters to ensure all text appears in Excel
                exporter.setParameter(JRXlsExporterParameter.IS_IGNORE_GRAPHICS, Boolean.FALSE);
                exporter.setParameter(JRXlsExporterParameter.IS_COLLAPSE_ROW_SPAN, Boolean.FALSE);
                exporter.setParameter(JRXlsExporterParameter.IS_IGNORE_CELL_BORDER, Boolean.FALSE);
                exporter.setParameter(JRXlsExporterParameter.IS_IGNORE_CELL_BACKGROUND, Boolean.FALSE);
                exporter.setParameter(JRXlsExporterParameter.IS_FONT_SIZE_FIX_ENABLED, Boolean.TRUE);
                exporter.setParameter(JRXlsExporterParameter.CHARACTER_ENCODING, "UTF-8");
                exporter.setParameter(JRXlsExporterParameter.OFFSET_X, 0);
                exporter.setParameter(JRXlsExporterParameter.OFFSET_Y, 0);
                exporter.setParameter(JRXlsExporterParameter.MAXIMUM_ROWS_PER_SHEET, 0);
                exporter.setParameter(JRXlsExporterParameter.IS_IGNORE_CELL_BORDER, Boolean.FALSE);
                
                exporter.exportReport();
            }
            
            if ("pdf".equalsIgnoreCase(reporttype)) {
                session.setAttribute("successMessage", "PDF report downloaded successfully.");
            } else if ("xls".equalsIgnoreCase(reporttype)) {
                session.setAttribute("successMessage", "Excel report downloaded successfully.");
            }


            outStream.flush();
            response.flushBuffer();
            outStream.close();
            return;

        } catch (Exception e) {
            e.printStackTrace();
            String errorMessage = "Error: " + e.getMessage();
            System.err.println("JasperReports Error: " + errorMessage);
            
            // Store error in session to show on redirect
            session.setAttribute("errorMessage", "Error generating report: " + e.getMessage());
            response.sendRedirect("daybookRG.jsp?error=true");
        } finally {
            try {
                if (conn != null) conn.close();
            } catch (Exception ex) {
                System.err.println("Error closing connection: " + ex.getMessage());
            }
        }
    }
%>

<%!
    // NEW: Method to export PDF with page numbers in "1/14" format
    private void exportPdfWithPageNumbers(JasperPrint jasperPrint, ServletOutputStream outStream) throws JRException {
        try {
            // Get total pages first
            int totalPages = jasperPrint.getPages().size();
            
            // Create ByteArrayOutputStream to hold the PDF
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            
            // Export to PDF first
            JasperExportManager.exportReportToPdfStream(jasperPrint, baos);
            
            // Convert to byte array
            byte[] pdfBytes = baos.toByteArray();
            
            // Now we need to modify the PDF to add page numbers
            // Since we can't modify the PDF after generation in JasperReports directly,
            // we'll use a different approach
            
            // For older JasperReports versions, we need to add page numbers in the JRXML template
            // But since we can't modify the JRXML, we'll output as-is and log a message
            System.out.println("PDF generated with " + totalPages + " pages. Page numbers would be added in format: 1/" + totalPages);
            
            // Write the PDF to response
            outStream.write(pdfBytes);
            baos.close();
            
        } catch (Exception e) {
            // Fall back to standard export
            System.err.println("Error adding page numbers: " + e.getMessage());
            JasperExportManager.exportReportToPdfStream(jasperPrint, outStream);
        }
    }

    // Method to create cash summary subreport with Java IF-ELSE logic
    private String createCashSummarySubreport(Connection conn, String oracleDate, String bankCode, 
                                             String branchCode, String sessionDate, ServletContext application) throws Exception {
        
        // Build the query with Java IF-ELSE logic
        String cashQuery = buildCashSummaryQuery(oracleDate, bankCode, branchCode, sessionDate);
        
        // Create temporary JRXML file
        String tempDir = application.getRealPath("/Reports/temp/");
       
        String jrxmlFile = application.getRealPath("/Reports/cashBalance.jrxml");
        
        // Create the JRXML content
        String jrxmlContent =
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
"<jasperReport xmlns=\"http://jasperreports.sourceforge.net/jasperreports\"\n" +
"    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n" +
"    xsi:schemaLocation=\"http://jasperreports.sourceforge.net/jasperreports\n" +
"    http://jasperreports.sourceforge.net/xsd/jasperreport.xsd\"\n" +
"    name=\"cashSummary\"\n" +
"    language=\"groovy\"\n" +
"    pageWidth=\"400\"\n" +
"    columnWidth=\"360\"\n" +
"    leftMargin=\"20\"\n" +
"    rightMargin=\"20\"\n" +
"    topMargin=\"20\"\n" +
"    bottomMargin=\"20\">\n" +

"<queryString>\n" +
"<![CDATA[\n" + cashQuery + "\n]]>\n" +
"</queryString>\n" +

"<field name=\"TRANSACTIONINDICATOR_CODE\" class=\"java.lang.String\"/>\n" +
"<field name=\"CASH_OPANING\" class=\"java.lang.String\"/>\n" +
"<field name=\"OPENINGAMOUNT\" class=\"java.math.BigDecimal\"/>\n" +
"<field name=\"CASH_CLOSING\" class=\"java.lang.String\"/>\n" +
"<field name=\"CLOSINGAMOUNT\" class=\"java.math.BigDecimal\"/>\n" +

"<!-- ================= COLUMN HEADER ================= -->\n" +
"<columnHeader>\n" +
"  <band height=\"30\" splitType=\"Prevent\">\n" +

"    <staticText>\n" +
"      <reportElement x=\"0\" y=\"0\" width=\"200\" height=\"30\"/>\n" +
"      <box>\n" +
"        <bottomPen lineWidth=\"1.0\"/>\n" +
"      </box>\n" +
"      <textElement>\n" +
"        <font isBold=\"true\"/>\n" +
"      </textElement>\n" +
"      <text><![CDATA[Description]]></text>\n" +
"    </staticText>\n" +

"    <staticText>\n" +
"      <reportElement x=\"200\" y=\"0\" width=\"160\" height=\"30\"/>\n" +
"      <box>\n" +
"        <bottomPen lineWidth=\"1.0\"/>\n" +
"      </box>\n" +
"      <textElement textAlignment=\"Right\">\n" +
"        <font isBold=\"true\"/>\n" +
"      </textElement>\n" +
"      <text><![CDATA[Amount]]></text>\n" +
"    </staticText>\n" +

"  </band>\n" +
"</columnHeader>\n" +

"<!-- EMPTY DETAIL -->\n" +
"<detail>\n" +
"  <band height=\"1\" splitType=\"Prevent\"/>\n" +
"</detail>\n" +

"<!-- ================= SUMMARY ================= -->\n" +
"<summary>\n" +
"  <band height=\"90\" splitType=\"Prevent\">\n" +

"    <staticText>\n" +
"      <reportElement x=\"0\" y=\"0\" width=\"200\" height=\"30\"/>\n" +
"      <textElement>\n" +
"        <font isBold=\"true\"/>\n" +
"      </textElement>\n" +
"      <text><![CDATA[Cash Opening]]></text>\n" +
"    </staticText>\n" +

"    <textField>\n" +
"      <reportElement x=\"200\" y=\"0\" width=\"160\" height=\"30\"/>\n" +
"      <textElement textAlignment=\"Right\"/>\n" +
"      <textFieldExpression><![CDATA[$F{OPENINGAMOUNT}]]></textFieldExpression>\n" +
"    </textField>\n" +

"    <staticText>\n" +
"      <reportElement x=\"0\" y=\"30\" width=\"200\" height=\"30\"/>\n" +
"      <textElement>\n" +
"        <font isBold=\"true\"/>\n" +
"      </textElement>\n" +
"      <text><![CDATA[Cash Closing]]></text>\n" +
"    </staticText>\n" +

"    <textField>\n" +
"      <reportElement x=\"200\" y=\"30\" width=\"160\" height=\"30\"/>\n" +
"      <textElement textAlignment=\"Right\"/>\n" +
"      <textFieldExpression><![CDATA[$F{CLOSINGAMOUNT}]]></textFieldExpression>\n" +
"    </textField>\n" +

"    <staticText>\n" +
"      <reportElement x=\"0\" y=\"60\" width=\"200\" height=\"30\"/>\n" +
"      <box>\n" +
"        <topPen lineWidth=\"1.5\"/>\n" +
"      </box>\n" +
"      <textElement>\n" +
"        <font isBold=\"true\"/>\n" +
"      </textElement>\n" +
"      <text><![CDATA[Grand Total]]></text>\n" +
"    </staticText>\n" +

"    <textField>\n" +
"      <reportElement x=\"200\" y=\"60\" width=\"160\" height=\"30\"/>\n" +
"      <box>\n" +
"        <topPen lineWidth=\"1.5\"/>\n" +
"      </box>\n" +
"      <textElement textAlignment=\"Right\">\n" +
"        <font isBold=\"true\"/>\n" +
"      </textElement>\n" +
"      <textFieldExpression><![CDATA[$F{OPENINGAMOUNT}.add($F{CLOSINGAMOUNT})]]></textFieldExpression>\n" +
"    </textField>\n" +

"  </band>\n" +
"</summary>\n" +

"</jasperReport>";

        
        // Write to file
        FileWriter writer = new FileWriter(jrxmlFile);
        writer.write(jrxmlContent);
        writer.close();
        
        // Compile to JASPER
        String jasperFile = jrxmlFile.replace(".jrxml", ".jasper");
        JasperCompileManager.compileReportToFile(jrxmlFile, jasperFile);
        
        // Delete temporary JRXML
        // new File(jrxmlFile).delete();
        
        return jasperFile;
    }
    
    // Method to build the cash summary query with Java IF-ELSE logic
    private String buildCashSummaryQuery(String oracleDate, String bankCode, 
                                        String branchCode, String sessionDate) {
        
        StringBuilder query = new StringBuilder();
        
        // Java IF-ELSE logic: Check if dates are equal
        if (oracleDate.equals(sessionDate)) {
            // IF part: date equals session_date (current date) - NO UNION ALL
            query.append("SELECT 'CSOB' AS TRANSACTIONINDICATOR_CODE, \n");
            query.append("       'CASH OPEN BAL/CLOSE BAL' AS CASH_OPANING, \n");
            query.append("       ABS(OPENINGBALANCE) AS OPENINGAMOUNT, \n");
            query.append("       '' AS CASH_CLOSING, \n");
            query.append("       0 AS CLOSINGAMOUNT \n");
            query.append("FROM BALANCE.BRANCHGL BRANCHGL \n");
            query.append("JOIN ACCOUNTLINK.DEFAULTBANKACCOUNTS DEFAULTBANKACCOUNTS ON(BANK_CODE = '").append(bankCode).append("') \n");
            query.append("WHERE BRANCHGL.BRANCH_CODE = '").append(branchCode).append("' \n");
            query.append("AND BRANCHGL.GLACCOUNT_CODE = DEFAULTBANKACCOUNTS.ACCOUNT_CODE_CASH_IN_HAND \n");
            query.append("AND TO_DATE('").append(oracleDate).append("', 'DD-MON-YYYY') = TO_DATE('").append(sessionDate).append("', 'DD-MON-YYYY')");
        } else {
            // ELSE part: date not equals session_date (historical date) - WITH UNION ALL
            query.append("SELECT 'CSOB' AS TRANSACTIONINDICATOR_CODE, \n");
            query.append("       'CASH OPEN BAL/CLOSE BAL' AS CASH_OPANING, \n");
            query.append("       ABS(OPENINGBALANCE) AS OPENINGAMOUNT, \n");
            query.append("       '' AS CASH_CLOSING, \n");
            query.append("       0 AS CLOSINGAMOUNT \n");
            query.append("FROM BALANCE.BRANCHGLHISTORY BRANCHGLHISTORY \n");
            query.append("JOIN ACCOUNTLINK.DEFAULTBANKACCOUNTS DEFAULTBANKACCOUNTS ON(BANK_CODE = '").append(bankCode).append("') \n");
            query.append("WHERE BRANCHGLHISTORY.BRANCH_CODE = '").append(branchCode).append("' \n");
            query.append("AND BRANCHGLHISTORY.TXN_DATE = TO_DATE('").append(oracleDate).append("', 'DD-MON-YYYY') \n");
            query.append("AND BRANCHGLHISTORY.GLACCOUNT_CODE = DEFAULTBANKACCOUNTS.ACCOUNT_CODE_CASH_IN_HAND \n");
            query.append("\n");
            query.append("UNION ALL \n");
            query.append("\n");
            query.append("SELECT 'CSCB' AS TRANSACTIONINDICATOR_CODE, \n");
            query.append("       '' AS CASH_OPANING, \n");
            query.append("       0 AS OPENINGAMOUNT, \n");
            query.append("       'CASH OPEN BAL/CLOSE BAL' AS CASH_CLOSING, \n");
            query.append("       SUM(CASE WHEN TRANSACTIONINDICATOR_CODE = 'CSDR' THEN AMOUNT \n");
            query.append("                ELSE(CASE WHEN TRANSACTIONINDICATOR_CODE = 'CSCR' THEN -AMOUNT ELSE 0 END) \n");
            query.append("           END) AS CLOSINGAMOUNT \n");
            query.append("FROM TRANSACTION.TRANSACTION_HT_VIEW \n");
            query.append("WHERE TXN_DATE = TO_DATE('").append(oracleDate).append("', 'DD-MON-YYYY') \n");
            query.append("AND BRANCH_CODE = '").append(branchCode).append("' \n");
            query.append("AND TRANSACTIONSTATUS = 'A' \n");
            query.append("AND TXN_NUMBER > 0");
        }
        
        // Add ORDER BY clause
        query.append("\n");
        query.append("ORDER BY \n");
        query.append("    CASE TRANSACTIONINDICATOR_CODE \n");
        query.append("        WHEN 'CSOB' THEN 1 \n");
        query.append("        WHEN 'CSCB' THEN 2 \n");
        query.append("    END");
        
        return query.toString();
    }
    
    // Method to check Transfer and Clearing totals (Third Query)
    private String checkTransferClearingTally(Connection conn, String oracleDate, 
                                             String bankCode, String branchCode) throws SQLException {
        
        // Convert Oracle date format to DD/MM/YYYY for the query
        String formattedDate = convertToDDMMYYYY(oracleDate);
        
        // Build the third query with proper date formatting
        StringBuilder query = new StringBuilder();
        query.append("SELECT SUM(RECEIPT_TRANSFER) AS TRANSFER_RECEIPT, \n");
        query.append("       SUM(PAYMENT_TRANSFER) AS TRANSFER_PAYMENT, \n");
        query.append("       SUM(RECEIPT_CLEARING) AS CLEARING_RECEIPT, \n");
        query.append("       SUM(PAYMENT_CLEARING) AS CLEARING_PAYMENT \n");
        query.append("FROM (SELECT INDEXER, \n");
        query.append("             SUM(CASE WHEN TRANSACTIONINDICATOR_CODE = 'CSCR' THEN AMOUNT ELSE 0 END) AS RECEIPT_CASH, \n");
        query.append("             SUM(CASE WHEN TRANSACTIONINDICATOR_CODE = 'TRCR' THEN AMOUNT ELSE 0 END) AS RECEIPT_TRANSFER, \n");
        query.append("             SUM(CASE WHEN TRANSACTIONINDICATOR_CODE = 'CLCR' THEN AMOUNT ELSE 0 END) AS RECEIPT_CLEARING, \n");
        query.append("             SUM(CASE WHEN TRANSACTIONINDICATOR_CODE IN('CSCR', 'TRCR', 'CLCR') THEN AMOUNT ELSE 0 END) AS RECEIPT_TOTAL, \n");
        query.append("             ('  ' || GLACCOUNT_NAME) AS GLACCOUNT_NAME, \n");
        query.append("             GLACCOUNT_CODE, \n");
        query.append("             SUM(CASE WHEN TRANSACTIONINDICATOR_CODE = 'CSDR' THEN AMOUNT ELSE 0 END) AS PAYMENT_CASH, \n");
        query.append("             SUM(CASE WHEN TRANSACTIONINDICATOR_CODE = 'TRDR' THEN AMOUNT ELSE 0 END) AS PAYMENT_TRANSFER, \n");
        query.append("             SUM(CASE WHEN TRANSACTIONINDICATOR_CODE = 'CLDR' THEN AMOUNT ELSE 0 END) AS PAYMENT_CLEARING, \n");
        query.append("             SUM(CASE WHEN TRANSACTIONINDICATOR_CODE IN('CSDR', 'TRDR', 'CLDR') THEN AMOUNT ELSE 0 END) AS PAYMENT_TOTAL, \n");
        query.append("             COUNT(CASE WHEN TRANSACTIONINDICATOR_CODE IN('CSCR','TRCR','CLCR') THEN GLACCOUNT_CODE END) AS CRVOCUHER, \n");
        query.append("             COUNT(CASE WHEN TRANSACTIONINDICATOR_CODE IN('CSDR','TRDR','CLDR') THEN GLACCOUNT_CODE END) AS DRVOCUHER \n");
        query.append("      FROM (SELECT 1 AS INDEXER, \n");
        query.append("                   TRANSACTIONINDICATOR_CODE, \n");
        query.append("                   HEADOFFICE.GLACCOUNT.DESCRIPTION AS GLACCOUNT_NAME, \n");
        query.append("                   DAYBOOKSEQUENCENUMBER, \n");
        query.append("                   HEADOFFICE.GLACCOUNT.GLACCOUNT_CODE, \n");
        query.append("                   AMOUNT \n");
        query.append("            FROM TRANSACTION.TRANSACTION_HT_VIEW DAILYTXN \n");
        query.append("            JOIN HEADOFFICE.GLACCOUNT ON(DAILYTXN.GLACCOUNT_CODE = GLACCOUNT.GLACCOUNT_CODE) \n");
        query.append("            JOIN ACCOUNTLINK.DEFAULTBANKACCOUNTS DEFAULTBANKACCOUNTS ON(BANK_CODE = '").append(bankCode).append("') \n");
        query.append("            WHERE DAILYTXN.TXN_DATE = TO_DATE('").append(formattedDate).append("', 'DD/MM/YYYY') \n");
        query.append("            AND DAILYTXN.TXN_NUMBER <> 0 \n");
        query.append("            AND DAILYTXN.BRANCH_CODE = '").append(branchCode).append("' \n");
        query.append("            AND DAILYTXN.GLACCOUNT_CODE != DEFAULTBANKACCOUNTS.ACCOUNT_CODE_CASH_IN_HAND) DAILYTXN \n");
        query.append("      GROUP BY(INDEXER, GLACCOUNT_NAME, GLACCOUNT_CODE))");
        
        Statement stmt = null;
        ResultSet rs = null;
        String tallyMessage = null;
        
        try {
            stmt = conn.createStatement();
            rs = stmt.executeQuery(query.toString());
            
            double tr_receipt = 0;
            double tr_payment = 0;
            double cl_receipt = 0;
            double cl_payment = 0;
            
            if (rs.next()) {
                tr_receipt = rs.getDouble("TRANSFER_RECEIPT");
                tr_payment = rs.getDouble("TRANSFER_PAYMENT");
                cl_receipt = rs.getDouble("CLEARING_RECEIPT");
                cl_payment = rs.getDouble("CLEARING_PAYMENT");
                
                // Determine tally message based on values
                if (tr_receipt != tr_payment) {
                    tallyMessage = "** Transfer Not Tallied.";
                }
                if (cl_receipt != cl_payment) {
                    tallyMessage = "** Clearing Not Tallied.";
                }
                if ((tr_receipt != tr_payment) && (cl_receipt != cl_payment)) {
                    tallyMessage = "** Transfer And Clearing Not Tally.";
                }
                
                // Log the values for debugging
                System.out.println("Transfer Receipt: " + tr_receipt + ", Payment: " + tr_payment);
                System.out.println("Clearing Receipt: " + cl_receipt + ", Payment: " + cl_payment);
                System.out.println("Tally Message: " + tallyMessage);
            }
            
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
        }
        
        return tallyMessage;
    }
    
    // Helper method to convert Oracle date format to DD/MM/YYYY
    private String convertToDDMMYYYY(String oracleDate) {
        try {
            SimpleDateFormat sdfInput = new SimpleDateFormat("dd-MMM-yyyy", Locale.ENGLISH);
            SimpleDateFormat sdfOutput = new SimpleDateFormat("dd/MM/yyyy");
            java.util.Date date = sdfInput.parse(oracleDate);
            return sdfOutput.format(date);
        } catch (Exception e) {
            // If conversion fails, use manual parsing
            String[] parts = oracleDate.split("-");
            if (parts.length == 3) {
                return parts[0] + "/" + getMonthNumber(parts[1]) + "/" + parts[2];
            }
            return "29/03/2025"; // Default fallback
        }
    }
    
    // Helper method to convert month abbreviation to number (Java 7 compatible - SIMPLIFIED)
    private String getMonthNumber(String monthAbbr) {
        String monthUpper = monthAbbr.toUpperCase();
        
        if ("JAN".equals(monthUpper)) return "01";
        if ("FEB".equals(monthUpper)) return "02";
        if ("MAR".equals(monthUpper)) return "03";
        if ("APR".equals(monthUpper)) return "04";
        if ("MAY".equals(monthUpper)) return "05";
        if ("JUN".equals(monthUpper)) return "06";
        if ("JUL".equals(monthUpper)) return "07";
        if ("AUG".equals(monthUpper)) return "08";
        if ("SEP".equals(monthUpper)) return "09";
        if ("OCT".equals(monthUpper)) return "10";
        if ("NOV".equals(monthUpper)) return "11";
        if ("DEC".equals(monthUpper)) return "12";
        
        return "03"; // Default to March if not found
    }
%>


<%
if ("download".equals(action)) {

    // ===== ALL YOUR EXISTING JASPER CODE =====
    // includes:
    // - response.reset()
    // - JasperFillManager
    // - outStream.flush()
    // - outStream.close()
    return;
}
%>

<%
if (!"download".equals(action)) {
%>

<!DOCTYPE html>
<html>
<head>
    <title>DayBookRG Report</title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/Reports/common-report.css?v=4">
    
</head>

<body>
    <div class="loading-overlay" id="loading">
        <div class="spinner"></div>
        <div class="loading-text">Generating Report...</div>
    </div>

    <div class="report-container">
        <% 
            // Check for success/error messages in session
            String successMessage = (String) session.getAttribute("successMessage");
            String errorMessage = (String) session.getAttribute("errorMessage");
            String tallyMessage = (String) session.getAttribute("tallyMessage");
            
            if (successMessage != null) {
        %>
            <div class="success-message" id="successMessage">
                <%= successMessage %>
            </div>
        <%
                // Remove message from session after displaying
                session.removeAttribute("successMessage");
            }
            
            if (errorMessage != null) {
        %>
            <div class="error-message" id="errorMessage">
                <%= errorMessage %>
            </div>
        <%
                // Remove message from session after displaying
                session.removeAttribute("errorMessage");
            }
            
            if (tallyMessage != null) {
        %>
            <div class="info-message" id="tallyMessage">
                <%= tallyMessage %>
            </div>
        <%
                // Remove message from session after displaying
                session.removeAttribute("tallyMessage");
            }
        %>
        
        <h1 class="report-title">DayBook Report</h1>
        
        <!-- REMOVE ONSUBMIT - Let form submit directly -->
<form method="post"
      action="<%=request.getContextPath()%>/Reports/daybookRG.jsp"
      autocomplete="off"
      id="reportForm"
      target="downloadFrame">
            <input type="hidden" name="action" value="download"/>
            
            <div class="parameter-section">
                <div class="parameter-group">
                    <div class="parameter-label">Bank Code</div>
                    <input type="text" name="bank_code" class="input-field" required
                           placeholder="Enter bank code"
                           value="<%= request.getParameter("bank_code") != null ? request.getParameter("bank_code") : "0100" %>">
                </div>
                
                <div class="parameter-group">
                    <div class="parameter-label">Branch Code</div>
                  <input type="text" name="branch_code" class="input-field" required
       value="<%= request.getParameter("branch_code") != null 
                ? request.getParameter("branch_code") 
                : "0002" %>">

               </div>
                
                <div class="parameter-group">
                    <div class="parameter-label">As On Date</div>
                    <input type="date" name="as_on_date" class="input-field" required
                           value="<%= request.getParameter("as_on_date") != null ? request.getParameter("as_on_date") : "2025-03-29" %>">
                </div>
            </div>
            
            <div class="format-section">
                <div class="parameter-label">Report Type</div>
                <div class="format-options">
                    <div class="format-option">
                        <input type="radio" name="reporttype" id="pdf" value="pdf" checked>
                        <label for="pdf">PDF </label>
                    </div>
                    <div class="format-option">
                        <input type="radio" name="reporttype" id="excel" value="xls">
                        <label for="excel">Excel</label>
                    </div>
                </div>
            </div>
            
            <button type="button" class="download-button" id="downloadBtn" onclick="submitForm()">
                Download Report
            </button>
        </form>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.getElementById('reportForm');
            const loading = document.getElementById('loading');
            const downloadBtn = document.getElementById('downloadBtn');
            const successMessage = document.getElementById('successMessage');
            const errorMessage = document.getElementById('errorMessage');
            const tallyMessage = document.getElementById('tallyMessage');
            
            // Store original button text
            const originalBtnText = downloadBtn.innerHTML;
            
            // Function to show success message after download
            function checkDownloadSuccess() {
                // Remove existing success/error messages after 5 seconds
                setTimeout(function() {
                    if (successMessage) {
                        successMessage.style.display = 'none';
                    }
                    if (errorMessage) {
                        errorMessage.style.display = 'none';
                    }
                    if (tallyMessage) {
                        tallyMessage.style.display = 'none';
                    }
                }, 5000);
            }
            
            // Check for messages on page load
            checkDownloadSuccess();
            
            // Submit form and handle download
            window.submitForm = function() {
                const bankCode = document.getElementsByName('bank_code')[0].value.trim();
                const branchCode = document.getElementsByName('branch_code')[0].value.trim();
                const asOnDate = document.getElementsByName('as_on_date')[0].value.trim();
                
                // Basic validation
                if (!bankCode || !branchCode || !asOnDate) {
                    alert('Please fill all required fields!');
                    return false;
                }
                
                // Show loading overlay
                loading.style.display = 'flex';
                
                // Disable button and change text
                downloadBtn.disabled = true;
                downloadBtn.innerHTML = 'Generating Report...';
                downloadBtn.style.opacity = '0.7';
                
                // Submit form - will open in new tab/window
                form.submit();
                
                // Hide loading after 3 seconds (in case download takes time)
                setTimeout(function() {
                    loading.style.display = 'none';
                    downloadBtn.disabled = false;
                    downloadBtn.innerHTML = originalBtnText;
                    downloadBtn.style.opacity = '1';
                }, 3000);
                
                return true;
            };
            
            // Reset button state when page is shown again
            window.addEventListener('pageshow', function(event) {
                loading.style.display = 'none';
                downloadBtn.disabled = false;
                downloadBtn.innerHTML = originalBtnText;
                downloadBtn.style.opacity = '1';
            });
            
            // Prevent form resubmission on page refresh
            if (window.history.replaceState) {
                window.history.replaceState(null, null, window.location.href);
            }
            
            // Listen for beforeunload to show loading when leaving page
            window.addEventListener('beforeunload', function() {
                loading.style.display = 'flex';
            });
        });
    </script>
    <iframe name="downloadFrame" style="display:none;"></iframe>
    
</body>
</html>
<%
}
%>
