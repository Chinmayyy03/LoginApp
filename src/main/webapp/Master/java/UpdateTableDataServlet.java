import com.google.gson.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.BufferedReader;
import java.io.IOException;
import java.sql.*;
import java.util.Map;

@WebServlet("/updateTableData")
public class UpdateTableDataServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        StringBuilder sb = new StringBuilder();
        try(BufferedReader reader = request.getReader()) {
            String line;
            while((line = reader.readLine()) != null) sb.append(line);
        }
        JsonObject json = JsonParser.parseString(sb.toString()).getAsJsonObject();
        String tableName = json.get("tableName").getAsString();
        JsonArray data = json.getAsJsonArray("data");

        response.setContentType("application/json;charset=UTF-8");
        try (Connection conn = OracleUtil.getConnection()) {
            conn.setAutoCommit(false);
            for (JsonElement elem : data) {
                JsonObject row = elem.getAsJsonObject();

                // Must have an ID column or PK, adjust here accordingly
                if (!row.has("ID")) {
                    response.setStatus(400);
                    response.getWriter().print("{\"error\":\"Row missing ID column\"}");
                    return;
                }

                int id = row.get("ID").getAsInt();

                StringBuilder sql = new StringBuilder("UPDATE " + tableName + " SET ");
                int count = 0;
                for (Map.Entry<String, JsonElement> entry : row.entrySet()) {
                    String col = entry.getKey();
                    if (!col.equalsIgnoreCase("ID")) {
                        if (count > 0) sql.append(", ");
                        sql.append(col).append(" = ?");
                        count++;
                    }
                }
                sql.append(" WHERE ID = ?");

                try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                    int idx = 1;
                    for (Map.Entry<String, JsonElement> entry : row.entrySet()) {
                        String col = entry.getKey();
                        if (!col.equalsIgnoreCase("ID")) {
                            String val = entry.getValue().isJsonNull() ? null : entry.getValue().getAsString();
                            ps.setString(idx++, val);
                        }
                    }
                    ps.setInt(idx, id);
                    ps.executeUpdate();
                }
            }
            conn.commit();
            response.getWriter().print("{\"success\":true}");
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(500);
            response.getWriter().print("{\"error\":\"Database update error\"}");
        }
    }
}
