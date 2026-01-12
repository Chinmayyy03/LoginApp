import java.sql.Connection;
import java.sql.DriverManager;

public class OracleUtil {

    private static final String URL =
        "jdbc:oracle:thin:@//localhost:1521/XEPDB1";
    private static final String USER = "YOUR_DB_USER";
    private static final String PASS = "YOUR_DB_PASSWORD";

    static {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws Exception {
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
