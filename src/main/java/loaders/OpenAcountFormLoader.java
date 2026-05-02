package loaders;

import db.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/loaders/OpenAccountFormLoader")
public class OpenAcountFormLoader extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("branchCode") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write("{\"error\":\"Session expired\"}");
            return;
        }

        response.setContentType("application/json; charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache");
        PrintWriter out = response.getWriter();
        StringBuilder json = new StringBuilder("{");

        try (Connection conn = DBConnection.getConnection()) {

            json.append("\"salutation\":");
            json.append(queryToJsonArray(conn,
                "SELECT SALUTATION_CODE AS val FROM GLOBALCONFIG.SALUTATION ORDER BY SALUTATION_CODE",
                "val", "val"));

            json.append(",\"country\":");
            json.append(queryToJsonArray(conn,
                "SELECT COUNTRY_CODE AS code, NAME AS label FROM GLOBALCONFIG.COUNTRY ORDER BY NAME",
                "code", "label"));

            json.append(",\"state\":");
            json.append(queryToJsonArray(conn,
                "SELECT STATE_CODE AS code, NAME AS label FROM GLOBALCONFIG.STATE ORDER BY NAME",
                "code", "label"));

            json.append(",\"city\":");
            json.append(queryToJsonArray(conn,
                "SELECT CITY_CODE AS code, NAME AS label FROM GLOBALCONFIG.CITY ORDER BY UPPER(NAME)",
                "code", "label"));

            json.append(",\"relation\":");
            json.append(queryToJsonArray(conn,
                "SELECT RELATION_ID AS code, DESCRIPTION AS label FROM GLOBALCONFIG.RELATION ORDER BY RELATION_ID",
                "code", "label"));

            json.append(",\"accountOpCap\":");
            json.append(queryToJsonArray(conn,
                "SELECT ACCOUNTOPERATIONCAPACITY_ID AS code, DESCRIPTION AS label FROM GLOBALCONFIG.ACCOUNTOPERATIONCAPACITY ORDER BY ACCOUNTOPERATIONCAPACITY_ID",
                "code", "label"));

            json.append(",\"minBalance\":");
            json.append(queryToJsonArray(conn,
                "SELECT MINBALANCE_ID AS code, MINBALANCE AS label FROM HEADOFFICE.ACCOUNTMINBALANCE ORDER BY MINBALANCE_ID",
                "code", "label"));

            json.append(",\"securityType\":");
            json.append(queryToJsonArray(conn,
                "SELECT SECURITYTYPE_CODE AS val FROM GLOBALCONFIG.SECURITYTYPE ORDER BY SECURITYTYPE_CODE",
                "val", "val"));

            json.append(",\"socialSection\":");
            json.append(queryToJsonArray(conn,
                "SELECT SOCIALSECTION_ID AS code, DESCRIPTION AS label FROM GLOBALCONFIG.SOCIALSECTION ORDER BY SOCIALSECTION_ID",
                "code", "label"));

            json.append(",\"lbrCode\":");
            json.append(queryToJsonArray(conn,
                "SELECT MIS_ID AS code, DESCRIPTION AS label FROM HEADOFFICE.MIS ORDER BY DESCRIPTION",
                "code", "label"));

            json.append(",\"purpose\":");
            json.append(queryToJsonArray(conn,
                "SELECT PURPOSE_ID AS code, DESCRIPTION AS label FROM HEADOFFICE.PURPOSE ORDER BY DESCRIPTION",
                "code", "label"));

            json.append(",\"classification\":");
            json.append(queryToJsonArray(conn,
                "SELECT CLASSIFICATION_ID AS code, DESCRIPTION AS label FROM HEADOFFICE.CLASSIFICATION ORDER BY DESCRIPTION",
                "code", "label"));

            json.append(",\"modeOfSanction\":");
            json.append(queryToJsonArray(conn,
                "SELECT MODEOFSANCTION_ID AS code, DESCRIPTION AS label FROM HEADOFFICE.MODEOFSANCTION ORDER BY DESCRIPTION",
                "code", "label"));

            json.append(",\"sanctionAuthority\":");
            json.append(queryToJsonArray(conn,
                "SELECT SANCTIONAUTHORITY_ID AS code, DESCRIPTION AS label FROM HEADOFFICE.SANCTIONAUTHORITY ORDER BY DESCRIPTION",
                "code", "label"));

            json.append(",\"industry\":");
            json.append(queryToJsonArray(conn,
                "SELECT INDUSTRY_ID AS code, DESCRIPTION AS label FROM HEADOFFICE.INDUSTRY ORDER BY DESCRIPTION",
                "code", "label"));

        } catch (Exception e) {
            json.append(",\"_error\":\"").append(escapeJson(e.getMessage())).append("\"");
        }

        json.append("}");
        out.print(json.toString());
    }

    private String queryToJsonArray(Connection conn, String sql,
                                    String valueCol, String labelCol)
            throws SQLException {

        StringBuilder arr = new StringBuilder("[");
        boolean first = true;

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                if (!first) arr.append(",");
                first = false;
                String v = nullSafe(rs.getString(valueCol));
                String l = nullSafe(rs.getString(labelCol));
                arr.append("{\"v\":\"").append(escapeJson(v))
                   .append("\",\"l\":\"").append(escapeJson(l))
                   .append("\"}");
            }
        }

        arr.append("]");
        return arr.toString();
    }

    private String nullSafe(String s) {
        return s == null ? "" : s;
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}