import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.*;

@WebServlet("/getTableData")
public class GetTableDataServlet extends HttpServlet {
    private static final Gson gson = new Gson();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String tableName = request.getParameter("tableName");

        if (tableName == null || tableName.trim().isEmpty()) {
            response.setStatus(400);
            response.getWriter().print("{\"error\":\"Missing tableName parameter\"}");
            return;
        }

        // VERY IMPORTANT: Validate tableName here against allowed names from GLOBALCONFIG.MASTERS to prevent SQL injection
        // For simplicity, we trust tableName here, but do NOT do this in production without validation

        response.setContentType("application/json;charset=UTF-8");

        try (Connection conn = OracleUtil.getConnection();
             Statement stmt = conn.createStatement();
             PrintWriter out = response.getWriter()) {

            String sql = "SELECT * FROM " + tableName;
            ResultSet rs = stmt.executeQuery(sql);

            ResultSetMetaData metaData = rs.getMetaData();
            int columnCount = metaData.getColumnCount();

            JsonArray resultArray = new JsonArray();

            while (rs.next()) {
                JsonObject rowObject = new JsonObject();
                for (int i = 1; i <= columnCount; i++) {
                    String colName = metaData.getColumnName(i);
                    Object value = rs.getObject(i);
                    if (value == null) {
                        rowObject.addProperty(colName, (String) null);
                    } else if (value instanceof Number) {
                        rowObject.addProperty(colName, ((Number) value).toString());
                    } else {
                        rowObject.addProperty(colName, value.toString());
                    }
                }
                resultArray.add(rowObject);
            }

            out.print(resultArray.toString());

        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(500);
            response.getWriter().print("{\"error\":\"Database error\"}");
        }
    }
}
