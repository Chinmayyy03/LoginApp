import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/getMasters")
public class GetMastersServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        try (Connection con = OracleUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT DESCRIPTION, TABLE_NAME FROM GLOBALCONFIG.MASTERS ORDER BY SR_NUMBER");
             ResultSet rs = ps.executeQuery()) {

            out.print("[");
            boolean first = true;

            while (rs.next()) {
                if (!first) out.print(",");
                out.print("{\"DESCRIPTION\":\"" + rs.getString("DESCRIPTION") +
                          "\",\"TABLE_NAME\":\"" + rs.getString("TABLE_NAME") + "\"}");
                first = false;
            }

            out.print("]");

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            out.print("[]");
        }
    }
}
