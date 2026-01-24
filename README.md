# CBS Banking System 

A Java-based web application for bank core banking system (CBS) management. Built using Java Servlets, JSP, and Oracle Database.

## 📋 Features

-----

## 🛠️ Technologies Used

- **Backend**: Java 21, Servlets
- **Frontend**: JSP (JavaServer Pages)
- **Database**: Oracle Database (Oracle 11g XE)
- **Server**: Apache Tomcat 9.0
- **Build Tool**: Eclipse IDE
- **JDBC Driver**: Oracle JDBC Driver

## 📦 Prerequisites

Before running this application, ensure you have the following installed:

- Java Development Kit (JDK) 21 or higher
- Apache Tomcat 9.0
- Oracle Database 11g XE or higher
- Eclipse IDE for Java EE Developers (recommended)
- Oracle JDBC Driver (ojdbc jar file)

## 🔧 Installation

### 1. Clone the Repository
```bash
git clone <your-repository-url>
cd LoginApp
```

### 2. Database Setup

1. Start your Oracle Database instance
2. Create necessary database tables for user authentication and loan details
3. Update database credentials in `src/main/java/db/DBConnection.java`:

```java
private static final String URL = "jdbc:oracle:thin:@<your-host>:<port>:<sid>";
private static final String USER = "<your-username>";
private static final String PASSWORD = "<your-password>";
```

**⚠️ Security Note**: The current configuration has hardcoded credentials. For production, use environment variables or secure configuration management.

### 3. Add Oracle JDBC Driver

1. Download the Oracle JDBC driver (ojdbc8.jar or ojdbc11.jar)
2. Add it to your project's `WEB-INF/lib` directory or configure it in your build path

### 4. Import into Eclipse

1. Open Eclipse IDE
2. File → Import → Existing Projects into Workspace
3. Select the project directory
4. Click Finish

### 5. Configure Tomcat

1. In Eclipse, go to Servers view
2. Add Apache Tomcat 9.0 server
3. Add the project to the server

## 🚀 Usage

1. Start the Tomcat server from Eclipse
2. Access the application at: `http://localhost:8080/LoginApp/`
3. You will be redirected to the login page (`login.jsp`)
4. Enter your credentials and sign in
5. After successful authentication, access loan details and other features

## ⚙️ Configuration

### Session Management
- Default session timeout: 30 minutes
- Configured in `web.xml`

### Error Handling
- **404 Error**: Redirects to `error404.jsp`
- **500 Error**: Redirects to `error500.jsp`

## 🔒 Security Recommendations

For production deployment, consider implementing:

1. **Password Encryption**: Hash passwords using BCrypt or similar
2. **Environment Variables**: Store database credentials securely
3. **HTTPS**: Use SSL/TLS for encrypted communication
4. **SQL Injection Prevention**: Use PreparedStatements
5. **Session Security**: Implement CSRF protection
6. **Input Validation**: Validate all user inputs

## 🐛 Troubleshooting

### Common Issues

**Database Connection Failed**
- Verify Oracle Database is running
- Check connection parameters in `DBConnection.java`
- Ensure Oracle JDBC driver is properly added to classpath

**404 Error on Startup**
- Verify Tomcat is running
- Check context path is set to `/LoginApp`
- Ensure `login.jsp` exists in `src/main/webapp/`

**ClassNotFoundException for Oracle Driver**
- Add `ojdbc.jar` to `WEB-INF/lib` directory
- Rebuild the project

## 👥 Authors

Chinmay Ghevade , 
Aditya Suryawanshi

## 📧 Contact

For questions or support, please contact - ghevadechinmay@gmail.com, adityasuryawanshi5749@gmail.com
