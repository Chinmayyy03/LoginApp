package loaders;

import db.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.concurrent.*;

@WebServlet("/loaders/OpenAccountFormLoader")
public class OpenAccountFormLoader extends HttpServlet {

    // ── In-process cache ────────────────────────────────────────────────────
    // Dropdown data almost never changes; cache it for 10 minutes per JVM.
    private volatile String cachedJson      = null;
    private volatile long   cacheExpiresAt  = 0;
    private static final long CACHE_TTL_MS  = 10 * 60 * 1000L; // 10 minutes

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

        // ── HTTP-level cache headers so the browser won't re-request at all ──
        // The ETag is just the expiry epoch; good enough for this use case.
        long now = System.currentTimeMillis();
        String etag = "\"" + (cacheExpiresAt / 1000) + "\"";
        String ifNoneMatch = request.getHeader("If-None-Match");

        response.setContentType("application/json; charset=UTF-8");
        response.setHeader("Cache-Control", "private, max-age=600"); // 10 min browser cache
        response.setHeader("ETag", etag);

        if (etag.equals(ifNoneMatch) && cachedJson != null && now < cacheExpiresAt) {
            response.setStatus(HttpServletResponse.SC_NOT_MODIFIED);
            return;
        }

        // ── Server-side in-memory cache ──────────────────────────────────────
        if (cachedJson != null && now < cacheExpiresAt) {
            response.getWriter().print(cachedJson);
            return;
        }

        // ── Build JSON from DB ───────────────────────────────────────────────
        String json = buildJson();

        // Store in cache
        cachedJson     = json;
        cacheExpiresAt = System.currentTimeMillis() + CACHE_TTL_MS;

        PrintWriter out = response.getWriter();
        out.print(json);
    }

    /** Runs all 14 queries in parallel using a fixed thread pool. */
    private String buildJson() throws IOException {

        // Each entry: [jsonKey, sql, valueCol, labelCol, codeLabel]
        Object[][] queries = {
            { "salutation",       "SELECT SALUTATION_CODE AS val FROM GLOBALCONFIG.SALUTATION ORDER BY SALUTATION_CODE",                                                               "val",  "val",  false },
            { "country",          "SELECT COUNTRY_CODE AS code, NAME AS label FROM GLOBALCONFIG.COUNTRY ORDER BY NAME",                                                                "code", "label",true  },
            { "state",            "SELECT STATE_CODE AS code, NAME AS label FROM GLOBALCONFIG.STATE ORDER BY NAME",                                                                    "code", "label",true  },
            { "city",             "SELECT CITY_CODE AS code, NAME AS label FROM GLOBALCONFIG.CITY ORDER BY UPPER(NAME)",                                                               "code", "label",false },
            { "relation",         "SELECT RELATION_ID AS code, DESCRIPTION AS label FROM GLOBALCONFIG.RELATION ORDER BY RELATION_ID",                                                  "code", "label",false },
            { "accountOpCap",     "SELECT ACCOUNTOPERATIONCAPACITY_ID AS code, DESCRIPTION AS label FROM GLOBALCONFIG.ACCOUNTOPERATIONCAPACITY ORDER BY ACCOUNTOPERATIONCAPACITY_ID", "code", "label",false },
            { "minBalance",       "SELECT MINBALANCE_ID AS code, MINBALANCE AS label FROM HEADOFFICE.ACCOUNTMINBALANCE ORDER BY MINBALANCE_ID",                                        "code", "label",false },
            { "securityType",     "SELECT SECURITYTYPE_CODE AS val FROM GLOBALCONFIG.SECURITYTYPE ORDER BY SECURITYTYPE_CODE",                                                         "val",  "val",  false },
            { "socialSection",    "SELECT SOCIALSECTION_ID AS code, DESCRIPTION AS label FROM GLOBALCONFIG.SOCIALSECTION ORDER BY SOCIALSECTION_ID",                                   "code", "label",false },
            { "lbrCode",          "SELECT MIS_ID AS code, DESCRIPTION AS label FROM HEADOFFICE.MIS ORDER BY DESCRIPTION",                                                             "code", "label",false },
            { "purpose",          "SELECT PURPOSE_ID AS code, DESCRIPTION AS label FROM HEADOFFICE.PURPOSE ORDER BY DESCRIPTION",                                                      "code", "label",false },
            { "classification",   "SELECT CLASSIFICATION_ID AS code, DESCRIPTION AS label FROM HEADOFFICE.CLASSIFICATION ORDER BY DESCRIPTION",                                        "code", "label",false },
            { "modeOfSanction",   "SELECT MODEOFSANCTION_ID AS code, DESCRIPTION AS label FROM HEADOFFICE.MODEOFSANCTION ORDER BY DESCRIPTION",                                       "code", "label",false },
            { "sanctionAuthority","SELECT SANCTIONAUTHORITY_ID AS code, DESCRIPTION AS label FROM HEADOFFICE.SANCTIONAUTHORITY ORDER BY DESCRIPTION",                                 "code", "label",false },
            { "industry",         "SELECT INDUSTRY_ID AS code, DESCRIPTION AS label FROM HEADOFFICE.INDUSTRY ORDER BY DESCRIPTION",                                                   "code", "label",false },
        };

        ExecutorService pool = Executors.newFixedThreadPool(Math.min(queries.length, 8));

        @SuppressWarnings("unchecked")
        Future<String>[] futures = new Future[queries.length];

        for (int i = 0; i < queries.length; i++) {
            final Object[] q = queries[i];
            futures[i] = pool.submit(() -> {
                try (Connection conn = DBConnection.getConnection()) {
                    return queryToJsonArray(conn, (String) q[1], (String) q[2], (String) q[3]);
                } catch (Exception e) {
                    return "[]";
                }
            });
        }

        pool.shutdown();

        StringBuilder json = new StringBuilder("{");
        for (int i = 0; i < queries.length; i++) {
            if (i > 0) json.append(",");
            json.append("\"").append(queries[i][0]).append("\":");
            try {
                json.append(futures[i].get(10, TimeUnit.SECONDS));
            } catch (Exception e) {
                json.append("[]");
            }
        }
        json.append("}");
        return json.toString();
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

    private String nullSafe(String s) { return s == null ? "" : s; }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}