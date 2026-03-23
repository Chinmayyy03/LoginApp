package loaders;

import db.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/loaders/AddCustomerDataLoader")
public class AddCustomerDataLoader extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Session guard ──────────────────────────────────────────────
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

        StringBuilder json = new StringBuilder();
        json.append("{");

        // ── Single connection for ALL queries ──────────────────────────
        try (Connection conn = DBConnection.getConnection()) {

            // 1. Salutation
            json.append("\"salutation\":");
            json.append(queryToJsonArray(conn,
                "SELECT SALUTATION_CODE AS val FROM GLOBALCONFIG.SALUTATION ORDER BY SALUTATION_CODE",
                "val", "val"));

            // 2. Relation with Guardian
            json.append(",\"relation\":");
            json.append(queryToJsonArray(conn,
                "SELECT DESCRIPTION AS val FROM GLOBALCONFIG.RELATION ORDER BY RELATION_ID",
                "val", "val"));

            // 3. Religion Code
            json.append(",\"religion\":");
            json.append(queryToJsonArray(conn,
                "SELECT RELIGION_CODE AS val FROM GLOBALCONFIG.RELIGIONCASTE ORDER BY RELIGION_CODE",
                "val", "val"));

            // 4. Caste Code
            json.append(",\"caste\":");
            json.append(queryToJsonArray(conn,
                "SELECT CASTE_CODE AS val FROM GLOBALCONFIG.RELIGIONCASTE ORDER BY CASTE_CODE",
                "val", "val"));

            // 5. Category Code
            json.append(",\"category\":");
            json.append(queryToJsonArray(conn,
                "SELECT CATEGORY_CODE AS val FROM GLOBALCONFIG.CATEGORY ORDER BY CATEGORY_CODE",
                "val", "val"));

            // 6. Constitution Code
            json.append(",\"constitution\":");
            json.append(queryToJsonArray(conn,
                "SELECT CONSTITUTION_CODE AS val FROM GLOBALCONFIG.CONSTITUTION ORDER BY CONSTITUTION_CODE",
                "val", "val"));

            // 7. Occupation Code
            json.append(",\"occupation\":");
            json.append(queryToJsonArray(conn,
                "SELECT DESCRIPTION AS val FROM GLOBALCONFIG.OCCUPATION ORDER BY OCCUPATION_ID",
                "val", "val"));

            // 8. Residence Type
            json.append(",\"residenceType\":");
            json.append(queryToJsonArray(conn,
                "SELECT DESCRIPTION AS val FROM GLOBALCONFIG.RESIDENCETYPE ORDER BY RESIDENCETYPE_ID",
                "val", "val"));

            // 9. Country  (value = code, label = name)
            json.append(",\"country\":");
            json.append(queryToJsonArray(conn,
                "SELECT COUNTRY_CODE AS code, NAME AS label FROM GLOBALCONFIG.COUNTRY ORDER BY NAME",
                "code", "label"));

            // 10. State  (value = code, label = name)
            json.append(",\"state\":");
            json.append(queryToJsonArray(conn,
                "SELECT STATE_CODE AS code, NAME AS label FROM GLOBALCONFIG.STATE ORDER BY NAME",
                "code", "label"));

            // 11. City
            json.append(",\"city\":");
            json.append(queryToJsonArray(conn,
                "SELECT NAME AS val FROM GLOBALCONFIG.CITY ORDER BY UPPER(NAME)",
                "val", "val"));

        } catch (Exception e) {
            // Append error note — partial data already written is still usable
            json.append(",\"_error\":\"").append(escapeJson(e.getMessage())).append("\"");
        }

        json.append("}");
        out.print(json.toString());
    }

    // ──────────────────────────────────────────────────────────────────
    // Runs a SELECT and returns a JSON array of {v, l} objects.
    // valueCol = the column to use as <option value="">
    // labelCol = the column to use as <option> display text
    // (pass same column name for both when value == label)
    // ──────────────────────────────────────────────────────────────────
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