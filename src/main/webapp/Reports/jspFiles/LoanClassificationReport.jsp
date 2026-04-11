<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page buffer="none" %>

<%@ page import="java.sql.*,java.util.*,java.io.*,java.text.*" %>
<%@ page import="net.sf.jasperreports.engine.*" %>
<%@ page import="net.sf.jasperreports.engine.export.*" %>
<%@ page import="net.sf.jasperreports.engine.util.JRLoader" %>
<%@ page import="db.DBConnection" %>

<%
String isSupportUser = (String) session.getAttribute("isSupportUser");
String sessionBranchCode = (String) session.getAttribute("branchCode");
String userId = (String) session.getAttribute("userId");

if (isSupportUser == null) isSupportUser = "N";
if (sessionBranchCode == null) sessionBranchCode = "";
%>

<%
String action = request.getParameter("action");

if ("download".equals(action)) {

    String reporttype = request.getParameter("reporttype");
    String reportName = request.getParameter("report_name");
    String branchCode = request.getParameter("branch_code");
    String asOnDate   = request.getParameter("as_on_date");

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
        conn.setAutoCommit(false);

        /* ================= INSERT LOGIC ================= */

        String condition = "";

        if("0000".equals(branchCode)){
            condition = " BETWEEN '" + request.getParameter("from_br") +
                        "' AND '" + request.getParameter("to_br") + "' ";
        }else{
            condition = " = '" + branchCode + "' ";
        }

        /* DELETE */
        String sqlDelete =
        "DELETE FROM TEMP.LOANCLASS WHERE BRANCH_CODE " + condition;

        Statement stmtDel = conn.createStatement();
        stmtDel.execute(sqlDelete);
        stmtDel.close();

        /* SELECT (MAIN DATA) */
        String sqlSelect =
        "SELECT AA.ACCOUNT_CODE, NVL(AA.NAME,'A') NAME, " +
        "AL.LIMITAMOUNT, AL.AREA_CODE, AL.SUBAREA_CODE, " +
        "AL.PERIODOFLOAN, AL.SANCTIONAMOUNT " +
        "FROM ACCOUNT.ACCOUNT AA, ACCOUNT.ACCOUNTLOAN AL " +
        "WHERE AA.ACCOUNT_CODE = AL.ACCOUNT_CODE " +
        "AND SUBSTR(AA.ACCOUNT_CODE,1,4) " + condition;

        PreparedStatement ps = conn.prepareStatement(sqlSelect);
        ResultSet rs = ps.executeQuery();

        Statement insertStmt = conn.createStatement();

        while(rs.next()){

            String accountCode = rs.getString("ACCOUNT_CODE");
            String name = rs.getString("NAME");
            name = name.replace("'", " ");

            double limit = rs.getDouble("LIMITAMOUNT");

            String insertSql =
            "INSERT INTO TEMP.LOANCLASS (BRANCH_CODE, ACCOUNT_CODE, NAME, LIMITAMOUNT) VALUES (" +
            "'" + branchCode + "'," +
            "'" + accountCode + "'," +
            "'" + name + "'," +
            limit + ")";

            insertStmt.execute(insertSql);
        }

        rs.close();
        ps.close();
        insertStmt.close();

        conn.commit();

        /* ================= JASPER ================= */

        String jasperFile = "";

        if("main".equals(reportName)){
            jasperFile = "LoanClassificationReport.jasper";
        }
        else if("interest".equals(reportName)){
            jasperFile = "LoanClassificationReport (int. rate).jasper";
        }
        else if("overdue".equals(reportName)){
            jasperFile = "LoanClassificationReport (LoanOverdue).jasper";
        }

        String jasperPath =
        application.getRealPath("/Reports/" + jasperFile);

        JasperReport jr =
        (JasperReport) JRLoader.loadObject(new File(jasperPath));

        Map<String,Object> param = new HashMap<>();

        param.put("branch_code", branchCode);
        param.put("as_on_date", asOnDate);
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

        /* EXPORT */

        if ("pdf".equalsIgnoreCase(reporttype)) {

            response.setContentType("application/pdf");

            response.setHeader("Content-Disposition",
            "inline; filename=\"LoanClassification.pdf\"");

            JasperExportManager.exportReportToPdfStream(
                jp, response.getOutputStream());
        }

        else if ("xls".equalsIgnoreCase(reporttype)) {

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

    } catch(Exception e){

        e.printStackTrace();

        session.setAttribute("errorMessage",
            "Error = " + e.getMessage());

        response.sendRedirect("LoanClassificationReport.jsp");
        return;

    } finally {

        if(conn!=null){
            try{conn.close();}catch(Exception ex){}
        }
    }
}
%>

<!DOCTYPE html>
<html>
<head>

<title>Loan Classification Report</title>

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
LOAN CLASSIFICATION REPORT
</h1>

<form method="post"
action="<%=request.getContextPath()%>/Reports/jspFiles/LoanClassificationReport.jsp"
target="_blank">

<input type="hidden" name="action" value="download"/>

<div class="parameter-section">

<!-- BRANCH -->
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
<button type="button" class="icon-btn"
onclick="openLookup('branch')">…</button>
<% } %>
</div>
</div>

<div class="parameter-group">
<div class="parameter-label">Branch Name</div>
<input type="text" id="branchName" class="input-field" readonly>
</div>

<!-- DATE -->
<div class="parameter-group">
<div class="parameter-label">As On Date</div>

<input type="date"
name="as_on_date"
class="input-field"
required>
</div>

</div>

<!-- REPORT TYPE -->
<div class="parameter-section">

<div class="parameter-group">
<div class="parameter-label">Report</div>

<select name="report_name" class="input-field">
<option value="main">Main Report</option>
<option value="interest">Interest Rate</option>
<option value="overdue">Loan Overdue</option>
</select>

</div>

</div>

<div class="format-section">

<div class="parameter-label">Report Type</div>

<div class="format-options">

<div class="format-option">
<input type="radio" name="reporttype" value="pdf" checked> PDF
</div>

<div class="format-option">
<input type="radio" name="reporttype" value="xls"> Excel
</div>

</div>

</div>

<button type="submit" class="download-button">
Generate Report
</button>

</form>

</div>

<!-- LOOKUP MODAL -->
<div id="lookupModal" class="modal">
<div class="modal-content">
<button onclick="closeLookup()" style="float:right;">✖</button>
<div id="lookupTable"></div>
</div>
</div>

</body>
</html>