<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page trimDirectiveWhitespaces="true" %>

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

String isSupportUser = (String) session.getAttribute("isSupportUser");
String sessionBranchCode = (String) session.getAttribute("branchCode");

if (isSupportUser == null) isSupportUser = "N";
if (sessionBranchCode == null) sessionBranchCode = "";
%>

<%
String action = request.getParameter("action");
String branchCode = request.getParameter("branch_code");

if (branchCode == null || branchCode.trim().isEmpty()) {
    branchCode = sessionBranchCode;
}

/* 🔒 SECURITY */
if (!"Y".equalsIgnoreCase(isSupportUser)) {
    branchCode = sessionBranchCode;
}
String asOnDateUI = request.getParameter("as_on_date");

if (asOnDateUI == null || asOnDateUI.trim().isEmpty()) {
    asOnDateUI = sessionDate;
}

/* =====================================================
   DOWNLOAD SECTION
===================================================== */
if ("download".equals(action)) {
	String userId = (String) session.getAttribute("userId");


    String reporttype = request.getParameter("reporttype");
    Connection conn = null;
    ServletOutputStream outStream = null;

    try {

        response.reset();
        response.setBufferSize(1024 * 1024);
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        /* ===== ORACLE DATE FORMAT ===== */
       String oracleDate = "";

try {
    SimpleDateFormat inFmt  = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat outFmt = new SimpleDateFormat("dd-MMM-yyyy", Locale.ENGLISH);
    oracleDate = outFmt.format(inFmt.parse(asOnDateUI)).toUpperCase();
} catch (Exception e) {
    throw new Exception("Invalid date format");
}

        conn = DBConnection.getConnection();

        /* ===== REPORT PATH (NO HARDCODED PATH) ===== */
        String reportsDir = application.getRealPath("/Reports") + File.separator;
        String mainReportPath = reportsDir + "StandingInstructionRegisterRG.jasper";
        String subReportPath  = reportsDir + "subReportHeader.jasper";

        File mainFile = new File(mainReportPath);
        if (!mainFile.exists()) {
            throw new Exception("Main report not found: " + mainReportPath);
        }

        JasperReport jasperReport =
                (JasperReport) JRLoader.loadObject(mainFile);

        /* ===== PARAMETERS ===== */
        Map<String, Object> parameters = new HashMap<>();
        parameters.put("branch_code", branchCode);
        parameters.put("as_on_date", oracleDate);
        parameters.put("report_title", "Standing Instruction Register Report");
        parameters.put("SUBREPORT_DIR", reportsDir);
        parameters.put("user_id", userId);
        parameters.put("IMAGE_PATH", application.getRealPath("/images/UPSB MONO.png"));


        /* ===== FILL REPORT ===== */
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

        outStream = response.getOutputStream();

        /* ===== EXPORT TYPE ===== */
       /* ===== EXPORT TYPE ===== */

if ("pdf".equalsIgnoreCase(reporttype)) {

    response.reset();

    response.setContentType("application/pdf");

    response.setHeader(
        "Content-Disposition",
        "inline; filename=\"StandingInstructionRegister_" 
        + branchCode + ".pdf\""
    );

    outStream = response.getOutputStream();

    JasperExportManager.exportReportToPdfStream(jasperPrint, outStream);

    outStream.flush();
    outStream.close();

    return;
}
else if ("xls".equalsIgnoreCase(reporttype)) {

    response.reset();

    response.setContentType("application/vnd.ms-excel");

    response.setHeader(
        "Content-Disposition",
        "attachment; filename=\"StandingInstructionRegister_" 
        + branchCode + ".xls\""
    );

    outStream = response.getOutputStream();

    JRXlsExporter exporter = new JRXlsExporter();
    exporter.setParameter(JRXlsExporterParameter.JASPER_PRINT, jasperPrint);
    exporter.setParameter(JRXlsExporterParameter.OUTPUT_STREAM, outStream);

    exporter.exportReport();

    outStream.flush();
    outStream.close();

    return;
}

    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("errorMessage",
                "Error generating report: " + e.getMessage());
    } finally {
        if (outStream != null) try { outStream.close(); } catch (Exception ignored) {}
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }
}
%>
<%
if (!"preview".equals(action) && !"download".equals(action)) {
%>

<!DOCTYPE html>
<html>
<head>
    <title>Standing Instruction Register Report</title>

    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/common-report.css?v=4">
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

    <h1 class="report-title">STANDING INSTRUCTION REGISTER REPORT</h1>

    <form method="post"
          action="<%=request.getContextPath()%>/Reports/jspFiles/StandingInstructionRegisterRG.jsp"
          target="_blank"
          id="reportForm">

<input type="hidden" name="action" value="download"/>
        <div class="parameter-section">

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
            
            <div class="parameter-group">
    <div class="parameter-label">Branch Name</div>
    <input type="text" id="branchName" class="input-field" readonly>
</div>

            <div class="parameter-group">
                <div class="parameter-label">As On Date</div>
                <input type="date"
                       name="as_on_date"
                       class="input-field"
                       required
                       value="<%= sessionDate %>">
            </div>

        </div>

        <div class="format-section">
            <div class="parameter-label">Report Type</div>

            <div class="format-options">
                <div class="format-option">
                    <input type="radio" name="reporttype" value="pdf" checked>
                    <label>PDF</label>
                </div>

                <div class="format-option">
                    <input type="radio" name="reporttype" value="xls">
                    <label>Excel</label>
                </div>
            </div>
        </div>

        <button type="submit"
                class="download-button"
                id="previewBtn">
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

<script>
document.addEventListener('DOMContentLoaded', function() {

    const form = document.getElementById('reportForm');
    const previewBtn = document.getElementById('previewBtn');
    const originalText = previewBtn.innerHTML;

    form.addEventListener('submit', function(e) {

        const branchCode = document.querySelector('input[name="branch_code"]').value.trim();
        const asOnDate = document.querySelector('input[name="as_on_date"]').value.trim();

        if (!branchCode || !asOnDate) {
            alert('Please fill all required fields!');
            e.preventDefault();
            return false;
        }

       
    });

    window.addEventListener('pageshow', function(event) {
        if (event.persisted) {
            previewBtn.disabled = false;
            previewBtn.innerHTML = originalText;
            previewBtn.style.opacity = '1';
        }
    });

});
</script>


</body>
</html>

<%
}
%>
