<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true"%>

<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%@ page import="net.sf.jasperreports.engine.*"%>
<%@ page import="net.sf.jasperreports.engine.export.*"%>
<%@ page import="net.sf.jasperreports.engine.util.JRLoader"%>
<%@ page import="net.sf.jasperreports.export.*"%>

<%@ page import="db.DBConnection"%>

<%
String action = request.getParameter("action");

if ("download".equals(action)) {

    String reporttype = request.getParameter("reporttype");
    String branchCode = request.getParameter("branch_code");
    String asOnDate   = request.getParameter("as_on_date");

    Connection conn = null;

    try {

        response.reset();
        response.setHeader("Cache-Control","no-store, no-cache");
        response.setHeader("Pragma","no-cache");
        response.setDateHeader("Expires",0);

        conn = DBConnection.getConnection();

        /* ======================
           DATE FORMAT
        ====================== */

        String oracleDate;

        if(asOnDate!=null && !asOnDate.trim().equals("")){

            java.util.Date utilDate =
            new SimpleDateFormat("yyyy-MM-dd").parse(asOnDate);

            oracleDate =
            new SimpleDateFormat("dd-MMM-yyyy",Locale.ENGLISH)
            .format(utilDate).toUpperCase();

        }else{

            oracleDate =
            new SimpleDateFormat("dd-MMM-yyyy",Locale.ENGLISH)
            .format(new java.util.Date()).toUpperCase();
        }


        /* ======================
           CALCULATE TOTAL CREDIT/DEBIT
        ====================== */

        double totalCredit = 0;
        double totalDebit  = 0;

        PreparedStatement psTotals = conn.prepareStatement(
        "SELECT " +
        "SUM(CASE WHEN TRANSACTIONINDICATOR_CODE='TRCR' THEN AMOUNT ELSE 0 END) TOTALCREDIT, " +
        "SUM(CASE WHEN TRANSACTIONINDICATOR_CODE='TRDR' THEN AMOUNT ELSE 0 END) TOTALDEBIT " +
        "FROM TRANSACTION.TRANSACTION_HT_VIEW " +
        "WHERE BRANCH_CODE=? AND TXN_DATE=? " +
        "AND TRANSACTIONINDICATOR_CODE IN ('TRCR','TRDR')");

        psTotals.setString(1, branchCode);
        psTotals.setString(2, oracleDate);

        ResultSet rsTotals = psTotals.executeQuery();

        if(rsTotals.next()){
            totalCredit = rsTotals.getDouble("TOTALCREDIT");
            totalDebit  = rsTotals.getDouble("TOTALDEBIT");
        }

        rsTotals.close();
        psTotals.close();


        /* ======================
           GET OPENING BALANCE
        ====================== */

        double openingBalance = 0;

        PreparedStatement psOpen = conn.prepareStatement(
        "SELECT OPENINGBALANCE FROM BALANCE.BRANCHGLHISTORY " +
        "WHERE BRANCH_CODE=? AND TXN_DATE=?");

        psOpen.setString(1,branchCode);
        psOpen.setString(2,oracleDate);

        ResultSet rsOpen = psOpen.executeQuery();

        if(rsOpen.next()){
            openingBalance = Math.abs(rsOpen.getDouble("OPENINGBALANCE"));
        }

        rsOpen.close();
        psOpen.close();


        /* ======================
           CLOSING BALANCE
        ====================== */

        double closingBalance =
        openingBalance + totalCredit - totalDebit;


        /* ======================
           LOAD JASPER
        ====================== */

        String jasperPath =
        application.getRealPath("/Reports/RecPay.jasper");

        File jasperFile = new File(jasperPath);

        if(!jasperFile.exists()){
            throw new RuntimeException(
            "Jasper file not found : " + jasperPath);
        }

        JasperReport jasperReport =
        (JasperReport) JRLoader.loadObject(jasperFile);


        /* ======================
           PARAMETERS
        ====================== */

        Map<String,Object> parameters =
        new HashMap<String,Object>();

        parameters.put("branch_code",branchCode);
        parameters.put("as_on_date",oracleDate);
        parameters.put("TOTALCREDIT",totalCredit);
        parameters.put("TOTALDEBIT",totalDebit);
        parameters.put("OPENINGBALANCE",openingBalance);
        parameters.put("CLOSINGBALANCE",closingBalance);

        parameters.put("report_title",
        "CASH RECEIPT AND PAYMENT");

        parameters.put("SUBREPORT_DIR",
        application.getRealPath("/Reports/"));

        parameters.put("user_id",
        session.getAttribute("user_id"));

        parameters.put("IMAGE_PATH",
        application.getRealPath("/images/UPSB MONO.png"));


        /* ======================
           FILL REPORT
        ====================== */

        JasperPrint jasperPrint =
        JasperFillManager.fillReport(
        jasperReport,
        parameters,
        conn);


        /* ======================
           EXPORT PDF
        ====================== */

        if("pdf".equalsIgnoreCase(reporttype)){

            response.setContentType("application/pdf");

            response.setHeader(
            "Content-Disposition",
            "inline; filename=CashReceiptPayment.pdf");

            ServletOutputStream outStream =
            response.getOutputStream();

            JasperExportManager
            .exportReportToPdfStream(
            jasperPrint,outStream);

            outStream.flush();
            outStream.close();
            return;
        }


        /* ======================
           EXPORT EXCEL
        ====================== */

        else if("xls".equalsIgnoreCase(reporttype)){

            response.setContentType(
            "application/vnd.ms-excel");

            response.setHeader(
            "Content-Disposition",
            "attachment; filename=CashReceiptPayment.xls");

            ServletOutputStream outStream =
            response.getOutputStream();

            JRXlsExporter exporter =
            new JRXlsExporter();

            exporter.setExporterInput(
            new SimpleExporterInput(jasperPrint));

            exporter.setExporterOutput(
            new SimpleOutputStreamExporterOutput(outStream));

            SimpleXlsReportConfiguration xlsConfig =
            new SimpleXlsReportConfiguration();

            xlsConfig.setDetectCellType(true);

            exporter.setConfiguration(xlsConfig);

            exporter.exportReport();

            outStream.flush();
            outStream.close();
            return;
        }

    }
    catch(Exception e){

        out.println("<h2 style='color:red'>Error Generating Report</h2>");
        out.println("<pre>");
        e.printStackTrace(new PrintWriter(out));
        out.println("</pre>");
    }
    finally{

        if(conn!=null){
            try{conn.close();}catch(Exception ex){}
        }
    }
}
%>


<!DOCTYPE html>
<html>
<head>

<title>CASH RECEIPT AND PAYMENT</title>

<link rel="stylesheet"
href="<%=request.getContextPath()%>/Reports/common-report.css">

</head>

<body>

<div class="report-container">

<h1 class="report-title">
CASH RECEIPT AND PAYMENT
</h1>

<form method="post"
action="<%=request.getContextPath()%>/Reports/jspFiles/RecPay.jsp"
target="_blank">

<input type="hidden"
name="action"
value="download">

<div class="parameter-section">

<div class="parameter-group">
<div class="parameter-label">Branch Code</div>

<input type="text"
name="branch_code"
class="input-field"
value="0001"
required>
</div>

<div class="parameter-group">
<div class="parameter-label">As On Date</div>

<input type="date"
name="as_on_date"
class="input-field"
required>
</div>

</div>

<div class="format-section">

<div class="parameter-label">
Report Type
</div>

<div class="format-options">

<div class="format-option">
<input type="radio"
name="reporttype"
value="pdf"
checked> PDF
</div>

<div class="format-option">
<input type="radio"
name="reporttype"
value="xls"> Excel
</div>

</div>

</div>

<button type="submit"
class="download-button">
Generate Report
</button>

</form>

</div>

</body>
</html>