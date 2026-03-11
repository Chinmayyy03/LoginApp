<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page buffer="none" %>

<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%@ page import="net.sf.jasperreports.engine.*" %>
<%@ page import="net.sf.jasperreports.engine.export.*" %>
<%@ page import="net.sf.jasperreports.engine.util.JRLoader" %>

<%@ page import="db.DBConnection" %>

<%
String action = request.getParameter("action");

if ("download".equals(action)) {

    String reporttype  = request.getParameter("reporttype");
    String branchCode  = request.getParameter("branch_code");
    String asOnDate    = request.getParameter("as_on_date");
    String productCode = request.getParameter("product_code");
    String singleAll   = request.getParameter("single_all");

    if(productCode == null) productCode="";
    productCode = productCode.trim();

    /* VALIDATION */

    if("S".equals(singleAll) && productCode.equals("")){
        out.println("<h3 style='color:red'>Please enter Product Code</h3>");
        return;
    }

    /* DATE FORMAT */

    String oracleDateStr="";

    if(asOnDate!=null && !asOnDate.trim().equals("")){

        java.util.Date d =
            new SimpleDateFormat("yyyy-MM-dd").parse(asOnDate);

        oracleDateStr =
            new SimpleDateFormat("dd-MMM-yyyy",Locale.ENGLISH)
            .format(d).toUpperCase();
    }

    Connection conn=null;

    try{

        response.reset();
        response.setBufferSize(1024*1024);

        conn = DBConnection.getConnection();

        /* REPORT */

        String jasperPath =
            application.getRealPath("/Reports/DepositMatureButNotPaidRG.jasper");

        JasperReport jasperReport =
            (JasperReport)JRLoader.loadObject(new File(jasperPath));

        /* PARAMETERS */

        Map<String,Object> parameters = new HashMap<>();

        parameters.put("branch_code",branchCode);
        parameters.put("as_on_date",oracleDateStr);
        parameters.put("to_date",oracleDateStr);
        parameters.put("report_title","DEPOSIT MATURE BUT NOT PAID");

        parameters.put("SUBREPORT_DIR",
            application.getRealPath("/Reports/"));

        parameters.put("IMAGE_PATH",
            application.getRealPath("/images/UPSB MONO.png"));

        parameters.put(JRParameter.REPORT_CONNECTION,conn);

        /* SQL */

        String sql =
        "SELECT ROWNUM AS SRNO, A.* " +
        "FROM ( SELECT B.ACCOUNT_CODE ,SUBSTR(B.ACCOUNT_CODE,5,3) AS PRODUCT_CODE,K.DESCRIPTION ,B.AMOUNTINMATUREDDEPOSIT, " +
        "INITCAP(A.NAME) AS NAME ,B.INTERESTRATE ,B.DEPOSITAMOUNT, " +
        "B.UNITOFPERIOD, B.PERIODOFDEPOSIT, TO_CHAR(B.MATURITYDATE,'DD/MM/YYYY') AS B, " +
        "B.PROCESSFOR_MATURITY,TO_CHAR(A.DATEACCOUNTOPEN,'DD/MM/YYYY') AS A ,C.LEDGERBALANCE, " +
        "(select MAX(txn_date) from transaction.dailytxn " +
        "where account_code=B.ACCOUNT_CODE and upper(particular) NOT like '%INTEREST%' " +
        "and substr(transactionindicator_code,3,2)='CR') INT_DATE " +
        "FROM ACCOUNT.ACCOUNTDEPOSIT B,ACCOUNT.ACCOUNT A,BALANCE.ACCOUNT C,HEADOFFICE.PRODUCT K " +
        "WHERE B.ACCOUNT_CODE=A.ACCOUNT_CODE " +
        "AND B.ACCOUNT_CODE=C.ACCOUNT_CODE " +
        "AND SUBSTR(B.ACCOUNT_CODE,5,3)=K.PRODUCT_CODE " +
        "AND SUBSTR(B.ACCOUNT_CODE,1,4)=? " +
        "AND B.MATURITYDATE <= TO_DATE(?,'DD-MON-YYYY') ";

        if("S".equals(singleAll)){
            sql += " AND SUBSTR(B.ACCOUNT_CODE,5,3)=? ";
        }

        sql += " ORDER BY B.ACCOUNT_CODE )A";

        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1,branchCode);
        ps.setString(2,oracleDateStr);

        if("S".equals(singleAll)){
            ps.setString(3,productCode);
        }

        ResultSet rs = ps.executeQuery();

        JRResultSetDataSource jrds =
            new JRResultSetDataSource(rs);

        JasperPrint jasperPrint =
            JasperFillManager.fillReport(jasperReport,parameters,jrds);

        /* EXPORT */

        if("pdf".equalsIgnoreCase(reporttype)){

            response.setContentType("application/pdf");

            response.setHeader("Content-Disposition",
                "inline; filename=\"DepositMatureButNotPaid.pdf\"");

            ServletOutputStream outStream =
                response.getOutputStream();

            JasperExportManager.exportReportToPdfStream(
                jasperPrint,outStream);

            outStream.flush();
            outStream.close();

            return;
        }

        else if("xls".equalsIgnoreCase(reporttype)){

            response.setContentType("application/vnd.ms-excel");

            response.setHeader("Content-Disposition",
                "attachment; filename=\"DepositMatureButNotPaid.xls\"");

            ServletOutputStream outStream =
                response.getOutputStream();

            JRXlsExporter exporter = new JRXlsExporter();

            exporter.setParameter(
                JRXlsExporterParameter.JASPER_PRINT,
                jasperPrint);

            exporter.setParameter(
                JRXlsExporterParameter.OUTPUT_STREAM,
                outStream);

            exporter.exportReport();

            outStream.flush();
            outStream.close();

            return;
        }

    }catch(Exception e){

        out.println("<h3 style='color:red'>Error Generating Report</h3>");
        e.printStackTrace(new PrintWriter(out));

    }finally{

        if(conn!=null){
            try{conn.close();}catch(Exception ex){}
        }
    }
}
%>

<!DOCTYPE html>
<html>
<head>

<title>Deposit Mature But Not Paid</title>

<link rel="stylesheet"
href="<%=request.getContextPath()%>/css/common-report.css?v=4">

<style>
.radio-container{
    margin-top:8px;
    display:flex;
    gap:40px;
}

.input-field:disabled{
    background-color:#e0e0e0;
    color:#666;
    cursor:not-allowed;
}
</style>

</head>

<body>

<div class="report-container">

<h1 class="report-title">
DEPOSIT MATURE BUT NOT PAID
</h1>

<form method="post"
      action="<%=request.getContextPath()%>/Reports/jspFiles/DepositMatureButNotPaidRG.jsp"
      target="_blank"
      autocomplete="off">

<input type="hidden" name="action" value="download"/>

<div class="parameter-section">

<!-- Branch Code -->
<div class="parameter-group">
<div class="parameter-label">Branch Code</div>

<input type="text"
       name="branch_code"
       class="input-field"
       value="0002"
       required>
</div>


<!-- Product Code -->
<div class="parameter-group">

<div class="parameter-label">Product Code</div>

<input type="text"
       name="product_code"
       class="input-field"
       placeholder="Enter Product Code">

<div class="radio-container">

<label>
<input type="radio"
       name="single_all"
       value="S"
       onclick="toggleProduct()"
       checked>
Single
</label>

<label>
<input type="radio"
       name="single_all"
       value="A"
       onclick="toggleProduct()">
All
</label>

</div>

</div>


<!-- As On Date -->
<div class="parameter-group">

<div class="parameter-label">As On Date</div>

<input type="date"
       name="as_on_date"
       class="input-field"
       value="2009-12-09"
       required>
       
</div>

</div>


<div class="format-section">

<div class="parameter-label">Report Type</div>

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


<button type="submit" class="download-button">
Generate Report
</button>

</form>

</div>


<script>

function toggleProduct(){

    var single =
        document.querySelector('input[name="single_all"][value="S"]').checked;

    var productField =
        document.querySelector('input[name="product_code"]');

    if(single){

        productField.disabled = false;
        productField.readOnly = false;

    }else{

        productField.value="";
        productField.disabled = true;
        productField.readOnly = true;

    }
}

window.onload=function(){
    toggleProduct();
}

</script>

</body>
</html>