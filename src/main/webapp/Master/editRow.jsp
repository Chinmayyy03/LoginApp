<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <title>
        <c:choose>
            <c:when test="${mode == 'ADD'}">Add ${table}</c:when>
            <c:otherwise>Edit ${table}</c:otherwise>
        </c:choose>
    </title>

    <!-- CSS -->
    <link rel="stylesheet" href="Master/css/editRow.css">
</head>

<body>

<div class="edit-container">

    <h2>
        <c:choose>
            <c:when test="${mode == 'ADD'}">Add New ${table}</c:when>
            <c:otherwise>Edit ${table}</c:otherwise>
        </c:choose>
    </h2>
    
     <c:if test="${not empty errorMessage}">
    	<div class="error-box">
        	${errorMessage}
    	</div>
	</c:if>

    <!-- FORM -->
    <form action="${pageContext.request.contextPath}/updateRow"
          method="post">

        <!-- DYNAMIC FIELDS -->
        <c:forEach var="col" items="${columns}">
            <div class="form-row">
                <label>${col}</label>

                <!-- PRIMARY KEY -->
                <c:if test="${col == primaryKey}">
                    <!-- Visible readonly -->
                    <input type="text"
                           value="${row[col]}"
                           readonly>

                    <!-- HIDDEN FIELD (CRITICAL) -->
                    <input type="hidden"
                           name="${primaryKey}"
                           value="${row[col]}">
                </c:if>

                <!-- OTHER COLUMNS -->
                <c:if test="${col != primaryKey}">
                    <input type="text"
                           name="${col}"
                           value="${row[col]}">
                </c:if>
            </div>
        </c:forEach>

        <!-- META -->
        <input type="hidden" name="table" value="${table}">

        <!-- ACTIONS -->
        <div class="form-actions">
            <button type="submit">Update</button>
            <a href="${pageContext.request.contextPath}/masters">Cancel</a>
        </div>

    </form>

</div>

</body>
</html>
