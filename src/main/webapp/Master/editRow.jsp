
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="formAction"
       value="${pageContext.request.contextPath}/${mode eq 'ADD' ? 'insertRow' : 'updateRow'}"/>

<!DOCTYPE html>
<html>
<head>
<title>
    <c:choose>
        <c:when test="${mode eq 'ADD'}">Add ${table}</c:when>
        <c:otherwise>Edit ${table}</c:otherwise>
    </c:choose>
</title>

<style>
body {
    background-color: #e8e4fc;
    font-family: Arial, sans-serif;
    margin: 20px;
    color: #333;
}

.edit-container {
    max-width: 1400px;
    margin: auto;
}

.edit-container h2 {
    font-size: 22px;
    color: #373279;
    margin-bottom: 20px;
}

.form-columns {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 20px 30px;
}

.form-group {
    display: flex;
    flex-direction: column;
}

.form-group label {
    font-size: 13px;
    font-weight: bold;
    margin-bottom: 5px;
    color: #373279;
}

.form-group input {
    padding: 8px 10px;
    border: 1px solid #888;
    border-radius: 4px;
    font-size: 13px;
}

.form-group input[readonly] {
    background: #f0f0f0;
    cursor: not-allowed;
}

.form-actions {
    display: flex;
    justify-content: center;
    gap: 15px;
    margin-top: 30px;
    padding-top: 20px;
    border-top: 1px solid #ddd;
}

.form-actions button {
    background: #373279;
    color: #fff;
    padding: 10px 25px;
    border-radius: 6px;
    font-weight: bold;
    border: none;
    cursor: pointer;
}

.form-actions a {
    padding: 10px 25px;
    border-radius: 6px;
    text-decoration: none;
    border: 1px solid #373279;
    color: #373279;
}
</style>
</head>

<body>

<div class="edit-container">

<h2>
<c:choose>
    <c:when test="${mode eq 'ADD'}">Add New ${table}</c:when>
    <c:otherwise>Edit ${table}</c:otherwise>
</c:choose>
</h2>

<form action="${formAction}" method="post">

<input type="hidden" name="schema" value="${schema}">
<input type="hidden" name="table" value="${table}">

<div class="form-columns">

<c:set var="total" value="${fn:length(columns)}"/>
<c:set var="perCol" value="${total div 3}"/>

<!-- COLUMN 1 -->
<div>
<c:forEach var="col" items="${columns}" varStatus="s">
<c:if test="${s.index lt perCol}">
<div class="form-group">
<label>${col}</label>

<c:choose>
    <c:when test="${col eq primaryKey}">
        <c:choose>
            <c:when test="${mode eq 'EDIT'}">
                <input type="text" value="${row[col]}" readonly>
                <input type="hidden" name="${primaryKey}" value="${row[col]}">
            </c:when>
            <c:otherwise>
                <input type="text" name="${primaryKey}">
            </c:otherwise>
        </c:choose>
    </c:when>
    <c:otherwise>
        <input type="text" name="${col}" value="${row[col]}">
    </c:otherwise>
</c:choose>

</div>
</c:if>
</c:forEach>
</div>

<!-- COLUMN 2 -->
<div>
<c:forEach var="col" items="${columns}" varStatus="s">
<c:if test="${s.index ge perCol and s.index lt (perCol * 2)}">
<div class="form-group">
<label>${col}</label>

<c:choose>
    <c:when test="${col eq primaryKey}">
        <input type="text" value="${row[col]}" readonly>
        <input type="hidden" name="${primaryKey}" value="${row[col]}">
    </c:when>
    <c:otherwise>
        <input type="text" name="${col}" value="${row[col]}">
    </c:otherwise>
</c:choose>

</div>
</c:if>
</c:forEach>
</div>

<!-- COLUMN 3 -->
<div>
<c:forEach var="col" items="${columns}" varStatus="s">
<c:if test="${s.index ge (perCol * 2)}">
<div class="form-group">
<label>${col}</label>

<c:choose>
    <c:when test="${col eq primaryKey}">
        <input type="text" value="${row[col]}" readonly>
        <input type="hidden" name="${primaryKey}" value="${row[col]}">
    </c:when>
    <c:otherwise>
        <input type="text" name="${col}" value="${row[col]}">
    </c:otherwise>
</c:choose>

</div>
</c:if>
</c:forEach>
</div>

</div>

<div class="form-actions">
<button type="submit">
<c:choose>
    <c:when test="${mode eq 'ADD'}">Add</c:when>
    <c:otherwise>Update</c:otherwise>
</c:choose>
</button>

<a href="${pageContext.request.contextPath}/masters?schema=${schema}&table=${table}">
Cancel
</a>
</div>

</form>
</div>

</body>
</html>
