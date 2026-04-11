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

    String reportType = request.getParameter("reporttype");
    String branchCode = request.getParameter("branch_code");
    String productCode = request.getParameter("product_code");
    String asOnDate = request.getParameter("as_on_date");
    String singleAll = request.getParameter("single_all");

    if (branchCode == null || branchCode.trim().isEmpty()) {
        branchCode = sessionBranchCode;
    }

    if (!"Y".equalsIgnoreCase(isSupportUser)) {
        branchCode = sessionBranchCode;
    }

    Connection conn = null;

    try {

        response.reset();
        response.setBufferSize(1024 * 1024);

        conn = DBConnection.getConnection();

        /* 🔥 PRODUCT RANGE (same as servlet) */
        String fromProduct = "";
        String toProduct = "";

        if ("A".equals(singleAll)) {
            fromProduct = "000";
            toProduct = "999";
        } else {
            fromProduct = productCode;
            toProduct = productCode;
        }

        /* 🔥 GOLD LOAN CHECK */
        String isGLParam = request.getParameter("cbDocs");

boolean isGL = "glagaindep".equalsIgnoreCase(isGLParam);


        /* 🔥 DATE FORMAT */
        String oracleDate = new SimpleDateFormat("dd-MMM-yyyy", Locale.ENGLISH)
                .format(new SimpleDateFormat("yyyy-MM-dd").parse(asOnDate))
                .toUpperCase();

        /* 🔥 REPORT NAME (same as servlet logic) */
        String jasperFile = "";

        if (isGL) {
            jasperFile = "CityWiseOverdueReportPGD.jasper";
        } else {
            jasperFile = "CityWiseOverdueReport.jasper";
        }
        
        out.println("<h3>Jasper File = " + jasperFile + "</h3>");

        String jasperPath =
                application.getRealPath("/Reports/" + jasperFile);

        JasperReport jr =
                (JasperReport) JRLoader.loadObject(new File(jasperPath));

        /* 🔥 PARAMETERS (important) */
        Map<String, Object> param = new HashMap<>();

        param.put("branch_code", branchCode);
        param.put("from_product", fromProduct);
        param.put("to_product", toProduct);
        param.put("as_on_date", oracleDate);
        /* ✅ USER ID (FIXED) */
        String userId = (String) session.getAttribute("userId");
        param.put("user_id", userId);

        param.put(JRParameter.REPORT_CONNECTION, conn);

        JasperPrint jp =
                JasperFillManager.fillReport(jr, param, conn);

        if (jp.getPages().isEmpty()) {

            response.reset();
            response.setContentType("text/html");

            out.println("<h2 style='color:red;text-align:center;margin-top:50px;'>");
            out.println("No Records Found!");
            out.println("</h2>");

            return;
        }

        /* 🔥 EXPORT */

        if ("pdf".equalsIgnoreCase(reportType)) {

            response.setContentType("application/pdf");

            response.setHeader("Content-Disposition",
                    "inline; filename=\"OverdueReport.pdf\"");

            JasperExportManager.exportReportToPdfStream(
                    jp, response.getOutputStream());
        }

        else if ("xls".equalsIgnoreCase(reportType)) {

            response.setContentType("application/vnd.ms-excel");

            JRXlsExporter exporter = new JRXlsExporter();

            exporter.setParameter(
                    JRXlsExporterParameter.JASPER_PRINT, jp);

            exporter.setParameter(
                    JRXlsExporterParameter.OUTPUT_STREAM,
                    response.getOutputStream());

            exporter.exportReport();
        }

        return;

    } catch (Exception e) {

        e.printStackTrace();

        String msg = e.getMessage();
        if (msg != null && msg.contains("ORA-")) {
            msg = msg.substring(msg.indexOf("ORA-"));
        }

        session.setAttribute("errorMessage", "Error = " + msg);

        response.sendRedirect("OverdueReportCityWise.jsp");
        return;

    } finally {

        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
}
%>

<!DOCTYPE html>
<html>
<head>

<title>Overdue Report City Wise</title>

<link rel="stylesheet" href="<%=request.getContextPath()%>/css/common-report.css?v=4">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/lookup.css">

<script>
var contextPath = "<%=request.getContextPath()%>";
</script>

<script src="<%=request.getContextPath()%>/js/lookup.js"></script>

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

<%
String errorMessage = (String)session.getAttribute("errorMessage");
if(errorMessage != null){
%>
<div class="error-message"><%=errorMessage%></div>
<%
session.removeAttribute("errorMessage");
}
%>

<h1 class="report-title">
OVERDUE REPORT CITY WISE
</h1>

<form method="post"
action="<%=request.getContextPath()%>/Reports/jspFiles/OverdueReportCityWise.jsp"
target="_blank"
autocomplete="off">

<input type="hidden" name="action" value="download"/>

<div class="parameter-section">

<!-- 🔹 Branch Code -->
<div class="parameter-group">
<div class="parameter-label">Branch Code</div>

<div class="input-box">
<input type="text"
name="branch_code"
id="branch_code"
class="input-field"
value="<%= sessionBranchCode %>"
<%= !"Y".equalsIgnoreCase(isSupportUser.trim()) ? "readonly" : "" %>
required>

<% if ("Y".equalsIgnoreCase(isSupportUser.trim())) { %>
<button type="button"
class="icon-btn"
onclick="openLookup('branch')">…</button>
<% } %>

</div>
</div>

<!-- 🔹 Branch Name -->
<div class="parameter-group">
<div class="parameter-label">Branch Name</div>
<input type="text" id="branchName" class="input-field" readonly>
</div>

<!-- 🔹 Product Code + Radio -->
<div class="parameter-group">

<div class="parameter-label">Product Code</div>

<div class="input-box">
<input type="text"
name="product_code"
id="product_code"
class="input-field"
placeholder="Enter Product Code">

<button type="button"
class="icon-btn"
onclick="openLookup('product')">…</button>
</div>

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

<!-- 🔹 Date -->
<div class="parameter-group">
<div class="parameter-label">As On Date</div>

<input type="date"
name="as_on_date"
class="input-field"
value="<%=sessionDate%>"  
required>
</div>

<!-- 🔹 Checkbox -->
<div class="parameter-group">
<label>
<input type="checkbox" name="cbDocs" value="glagaindep">
Gold Loan Against Deposit
</label>
</div>

</div>

<!-- 🔹 Report Type -->
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

<!-- 🔹 LOOKUP POPUP -->
<div id="lookupModal" class="modal">
<div class="modal-content">
<button onclick="closeLookup()" style="float:right;">✖</button>
<div id="lookupTable"></div>
</div>
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
        productField.value = "";
        productField.disabled = true;
        productField.readOnly = true;
    }
}

window.onload = function(){
    toggleProduct();
}

</script>

</body>
</html>