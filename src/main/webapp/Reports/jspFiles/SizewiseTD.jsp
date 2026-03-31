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
Object obj = session.getAttribute("workingDate");

String sessionDate = "";

if (obj != null) {
    if (obj instanceof java.sql.Date) {
        sessionDate = new java.text.SimpleDateFormat("yyyy-MM-dd")
                .format((java.sql.Date) obj);
    } else {
        sessionDate = obj.toString();
    }
}

if (sessionDate == null || sessionDate.isEmpty()) {
    sessionDate = new java.text.SimpleDateFormat("yyyy-MM-dd")
            .format(new java.util.Date());
}
%>

<%
String isSupportUser = (String) session.getAttribute("isSupportUser");
String sessionBranchCode = (String) session.getAttribute("branchCode");

if (isSupportUser == null) isSupportUser = "N";
if (sessionBranchCode == null) sessionBranchCode = "";
%>

<%

String action = request.getParameter("action");

if ("download".equals(action)) {

    String reportType  = request.getParameter("reporttype");
    String reportName  = request.getParameter("report_name");

    String branchCode = request.getParameter("branch_code");

    if (branchCode == null || branchCode.trim().isEmpty()) {
        branchCode = sessionBranchCode;
    }

    /* 🔒 SECURITY */
    if (!"Y".equalsIgnoreCase(isSupportUser)) {
        branchCode = sessionBranchCode;
    }
    String branchCodeTo = request.getParameter("branch_code_to");

    if (branchCodeTo == null || branchCodeTo.trim().isEmpty()) {
        branchCodeTo = sessionBranchCode;
    }

    /* 🔒 SECURITY */
    if (!"Y".equalsIgnoreCase(isSupportUser)) {
        branchCodeTo = sessionBranchCode;
    }
    String prCodeFr    = request.getParameter("pr_code_fr");
    String prCodeTo    = request.getParameter("pr_code_to");
    String asOnDate    = request.getParameter("as_on_date");

    Connection conn = null;

    try {

        response.reset();
        response.setBufferSize(1024 * 1024);

        conn = DBConnection.getConnection();
        
        String bankName = "";
        String branchName = "";
        String branchAddress = "";
        String cityCode = "";
        String bankCode = "";

        Statement st = conn.createStatement();

        /* GET BANK CODE */
        ResultSet rsBankCode = st.executeQuery(
        "SELECT BANK_CODE FROM GLOBALCONFIG.UNIVERSALPARAMETER");

        if(rsBankCode.next()){
            bankCode = rsBankCode.getString("BANK_CODE");
        }
        rsBankCode.close();

        /* GET BANK NAME */
        ResultSet rsBank = st.executeQuery(
        "SELECT NAME FROM GLOBALCONFIG.BANK WHERE BANK_CODE='"+bankCode+"'");

        if(rsBank.next()){
            bankName = rsBank.getString("NAME");
        }
        rsBank.close();

        /* GET BRANCH DETAILS */

        ResultSet rsBranch = st.executeQuery(
        "SELECT NAME, ADDRESS1, CITY_CODE FROM HEADOFFICE.BRANCH WHERE BRANCH_CODE='"+branchCode+"'");

        if(rsBranch.next()){
            branchName = rsBranch.getString("NAME");
            branchAddress = rsBranch.getString("ADDRESS1");
            cityCode = rsBranch.getString("CITY_CODE");
        }

        rsBranch.close();
        st.close();
        
        /* DATE FORMAT */
        String oracleDateStr;

        if (asOnDate != null && !asOnDate.trim().isEmpty()) {

            java.util.Date utilDate =
                    new SimpleDateFormat("yyyy-MM-dd").parse(asOnDate);

            oracleDateStr =
                    new SimpleDateFormat("dd-MMM-yyyy", Locale.ENGLISH)
                            .format(utilDate).toUpperCase();

        } else {

            oracleDateStr =
                    new SimpleDateFormat("dd-MMM-yyyy", Locale.ENGLISH)
                            .format(new java.util.Date()).toUpperCase();
        }
        
         /* SELECT REPORT FILE */

        String jasperFileName = "";

        if("summary".equals(reportName)){
            jasperFileName = "SizewiseTD.jasper";
        }
        else if("details".equals(reportName)){
            jasperFileName = "SizewisrTD(Detail).jasper";
        }
        else if("details1".equals(reportName)){
            jasperFileName = "SizewiseTD(Details1).jasper";
        }
        else if("customer".equals(reportName)){
            jasperFileName = "SizewiseTD(customer wise).jasper";
        }

        String jasperPath =
                application.getRealPath("/Reports/" + jasperFileName);

        JasperReport jasperReport =
                (JasperReport) JRLoader.loadObject(new File(jasperPath));

        /* PARAMETERS */

        Map<String,Object> parameters = new HashMap<>();

        parameters.put("branch_code", branchCode);
        parameters.put("report_title","SIZE WISE TERM DEPOSIT");
        parameters.put("branch_code_to", branchCodeTo);
        parameters.put("pr_code_fr", prCodeFr);
        parameters.put("pr_code_to", prCodeTo);
        parameters.put("as_on_date", oracleDateStr);
        parameters.put("BANK_NAME", bankName);
        parameters.put("BRANCH_NAME", branchName);
        parameters.put("BRANCH_ADDRESS", branchAddress);
        parameters.put("CITY_CODE", cityCode);

        parameters.put("SUBREPORT_DIR",
                application.getRealPath("/Reports/"));

        /* ✅ USER ID (FIXED) */
        String userId = (String) session.getAttribute("userId");
        parameters.put("user_id", userId);

        parameters.put("IMAGE_PATH",
                application.getRealPath("/images/UPSB MONO.png"));

        JasperPrint jasperPrint =
                JasperFillManager.fillReport(jasperReport, parameters, conn);
        
        if (jasperPrint.getPages().isEmpty()) {

            response.reset();
            response.setContentType("text/html");

            out.println("<h2 style='color:red;text-align:center;margin-top:50px;'>");
            out.println("No Records Found!");
            out.println("</h2>");

            return;
        }

        /* EXPORT */

        if ("pdf".equalsIgnoreCase(reportType)) {

            response.setContentType("application/pdf");
            response.setHeader(
                    "Content-Disposition",
                    "inline; filename=\"SizewiseTD_Report.pdf\"");

            ServletOutputStream outStream = response.getOutputStream();

            JasperExportManager.exportReportToPdfStream(jasperPrint, outStream);

            outStream.flush();
            outStream.close();
            return;
        }

        else if ("xls".equalsIgnoreCase(reportType)) {

            response.setContentType("application/vnd.ms-excel");
            response.setHeader(
                    "Content-Disposition",
                    "attachment; filename=\"SizewiseTD_Report.xls\"");

            ServletOutputStream outStream = response.getOutputStream();

            JRXlsExporter exporter = new JRXlsExporter();
            exporter.setParameter(JRXlsExporterParameter.JASPER_PRINT, jasperPrint);
            exporter.setParameter(JRXlsExporterParameter.OUTPUT_STREAM, outStream);
            exporter.exportReport();

            outStream.flush();
            outStream.close();
            return;
        }

    } catch(Exception e){

        out.println("<h2 style='color:red'>Report Error</h2>");
        e.printStackTrace(new PrintWriter(out));

    } finally {

        if(conn!=null) try{conn.close();}catch(Exception ex){}
    }
}

%>

<!DOCTYPE html>
<html>

<head>

<title>SIZEWISE TERM DEPOSIT REPORT</title>

<link rel="stylesheet" href="<%=request.getContextPath()%>/css/common-report.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/lookup.css">

<script>
var contextPath = "<%=request.getContextPath()%>";
</script>

<script src="<%=request.getContextPath()%>/js/lookup.js"></script>

<style>
.input-box { display:flex; gap:10px; }

.icon-btn {
    background:#2D2B80;
    color:white;
    border:none;
    width:40px;
    border-radius:8px;
    cursor:pointer;
}

.modal {
    display:none;
    position:fixed;
    top:0; left:0;
    width:100%; height:100%;
    background:rgba(0,0,0,0.5);
    justify-content:center;
    align-items:center;
}

.modal-content {
    background:#f5f5f5;
    width:80%;
    max-height:85%;
    padding:20px;
    border-radius:8px;
}
</style>

</head>

<body>

<div class="report-container">

<h1 class="report-title">
SIZEWISE TERM DEPOSIT REPORT
</h1>

<form method="post"
action="<%=request.getContextPath()%>/Reports/jspFiles/SizewiseTD.jsp"
target="_blank"
autocomplete="off">

<input type="hidden" name="action" value="download"/>

<!-- Branch Code Section -->

<div class="parameter-section">

<div class="parameter-group">
<div class="parameter-label">From Branch Code</div>
<div class="input-box">
<input type="text"
name="branch_code"
id="branch_code"
class="input-field"
value="<%=sessionBranchCode%>"
<%= !"Y".equalsIgnoreCase(isSupportUser.trim()) ? "readonly" : "" %>
required>

<% if ("Y".equalsIgnoreCase(isSupportUser.trim())) { %>
<button type="button"
class="icon-btn"
onclick="openLookup('branch')">…</button>
<% } %>
</div>
</div>

<div class="parameter-group">
<div class="parameter-label">To Branch Code</div>
<div class="input-box">
<input type="text"
name="branch_code_to"
id="branch_code_to"
class="input-field"
value="<%=sessionBranchCode%>"
<%= !"Y".equalsIgnoreCase(isSupportUser.trim()) ? "readonly" : "" %>
required>

<% if ("Y".equalsIgnoreCase(isSupportUser.trim())) { %>
<button type="button"
class="icon-btn"
onclick="openLookup('branch')">…</button>
<% } %>
</div>
</div>

</div>

<!-- Product Code Section -->

<div class="parameter-section">

<div class="parameter-group">
<div class="parameter-label">From Product Code</div>
<div class="input-box">
<input type="text"
name="pr_code_fr"
id="product_code"
class="input-field"
required>

<button type="button"
class="icon-btn"
onclick="openLookup('product')">…</button>
</div>
</div>

<div class="parameter-group">
<div class="parameter-label">To Product Code</div>
<div class="input-box">
<input type="text"
name="pr_code_to"
class="input-field"
required>

<button type="button"
class="icon-btn"
onclick="openLookup('product')">…</button>
</div>
</div>

</div>

<!-- As On Date + Report Dropdown (Side By Side) -->

<div class="parameter-section">

<div class="parameter-group">
<div class="parameter-label">As On Date</div>
<input type="date"
name="as_on_date"
class="input-field"
value="<%=sessionDate%>" 
required>
</div>

<div class="parameter-group">
<div class="parameter-label">Report</div>

<select name="report_name"
class="input-field">

<option value="summary">Summary Report</option>
<option value="details">Details Report</option>
<option value="details1">Details1 Report</option>
<option value="customer">Customer Wise Report</option>

</select>

</div>

</div>

<!-- Report Type -->

<div class="format-section">

<div class="parameter-label">
Report Type
</div>

<div class="format-options">

<div class="format-option">
<input type="radio"
name="reporttype"
value="pdf"
checked>
PDF
</div>

<div class="format-option">
<input type="radio"
name="reporttype"
value="xls">
Excel
</div>

</div>

</div>

<!-- Generate Button -->

<button type="submit"
class="download-button">

Generate Report

</button>

</form>

</div>

<div id="lookupModal" class="modal">
    <div class="modal-content">
        <button onclick="closeLookup()" style="float:right;">✖</button>
        <div id="lookupTable"></div>
    </div>
</div>

</body>

</html>