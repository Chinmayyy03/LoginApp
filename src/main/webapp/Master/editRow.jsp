<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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
    <style>
        /* Include all the CSS from your second file here */
        /* =========================
           EDIT / ADD PAGE – GLOBAL
        ========================= */
        body {
            background-color: #e8e4fc; /* soft violet */
            font-family: Arial, sans-serif;
            margin: 20px;
            padding: 0;
            color: #333;
        }

        /* =========================
           MAIN CONTAINER
        ========================= */
        .edit-container {
            width: 100%;
            max-width: 1400px;
            margin: 0 auto;
            background: transparent;
            padding: 0;
            border-radius: 0;
            border: none;
            box-shadow: none;
        }

        /* =========================
           HEADER
        ========================= */
        .edit-container h2 {
            margin: 0 0 24px 0;
            font-size: 22px;
            font-weight: bold;
            letter-spacing: 1px;
            color: #373279;
            border-bottom: none;
            padding-bottom: 0;
        }

        /* =========================
           SUCCESS MESSAGE
        ========================= */
        .success-box {
            background: #e7f7e7;
            border: 1px solid #4CAF50;
            color: #2e7d32;
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 4px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .success-box::before {
            content: "✓";
            font-weight: bold;
            font-size: 16px;
        }

        /* =========================
           THREE-COLUMN LAYOUT
        ========================= */
        .form-columns {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px 30px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            margin-bottom: 15px;
        }

        .form-group label {
            font-size: 13px;
            font-weight: bold;
            color: #373279;
            margin-bottom: 5px;
        }

        .form-group input[type="text"],
        .form-group input[type="date"],
        .form-group input[type="email"],
        .form-group input[type="number"],
        .form-group select,
        .form-group textarea {
            padding: 8px 10px;
            font-size: 13px;
            border: 1px solid #888;
            border-radius: 4px;
            width: 100%;
            box-sizing: border-box;
        }

        .form-group input[readonly] {
            background: #f0f0f0;
            cursor: not-allowed;
            color: #666;
        }

        /* =========================
           FORM ACTIONS
        ========================= */
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
            color: white;
            padding: 10px 25px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: bold;
            border: none;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        .form-actions button:hover {
            background: #2b0d73;
        }

        .form-actions a.back-btn {
            padding: 10px 25px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: bold;
            text-decoration: none;
            border: 1px solid #373279;
            color: #373279;
            background: white;
            display: flex;
            align-items: center;
            gap: 5px;
            transition: all 0.3s ease;
        }

        .form-actions a.back-btn:hover {
            background: #e8e4fc;
            border-color: #2b0d73;
            color: #2b0d73;
        }

        .form-actions a.back-btn::before {
            content: "←";
            font-size: 16px;
        }

        /* =========================
           ERROR BOX
        ========================= */
        .error-box {
            background: #ffe5e5;
            border: 1px solid #ff4d4d;
            color: #b30000;
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 4px;
            font-weight: 600;
        }

        /* =========================
           RESPONSIVE DESIGN
        ========================= */
        @media (max-width: 1024px) {
            .form-columns {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            .form-columns {
                grid-template-columns: 1fr;
                gap: 15px;
            }
            
            body {
                margin: 10px;
            }
            
            .form-actions {
                flex-direction: column;
                align-items: center;
            }
            
            .form-actions button,
            .form-actions a.back-btn {
                width: 100%;
                max-width: 300px;
                text-align: center;
            }
        }
    </style>
    
    <!-- JavaScript for success message -->
    <script>
        function showSuccessMessage() {
            const successBox = document.querySelector('.success-box');
            if (successBox) {
                // Auto-hide after 5 seconds
                setTimeout(() => {
                    successBox.style.opacity = '0';
                    successBox.style.transition = 'opacity 0.5s ease';
                    setTimeout(() => {
                        successBox.style.display = 'none';
                    }, 500);
                }, 5000);
            }
        }
        
        document.addEventListener('DOMContentLoaded', function() {
            showSuccessMessage();
            
            // Add confirmation for back button
            const backBtn = document.querySelector('.back-btn');
            if (backBtn) {
                backBtn.addEventListener('click', function(e) {
                    if (document.querySelector('form').checkValidity()) {
                        const confirmBack = confirm('You have unsaved changes. Are you sure you want to go back?');
                        if (!confirmBack) {
                            e.preventDefault();
                        }
                    }
                });
            }
        });
    </script>
</head>

<body>

<div class="edit-container">

    <h2>
        <c:choose>
            <c:when test="${mode == 'ADD'}">Add New ${table}</c:when>
            <c:otherwise>Edit ${table}</c:otherwise>
        </c:choose>
    </h2>
    
    <!-- Success Message -->
    <c:if test="${not empty successMessage}">
        <div class="success-box" id="successMessage">
            ${successMessage}
        </div>
    </c:if>
    
    <!-- Error Message -->
    <c:if test="${not empty errorMessage}">
        <div class="error-box">
            ${errorMessage}
        </div>
    </c:if>

    <!-- FORM -->
<form action="<%= request.getContextPath() %>/updateRow" method="post">
    <input type="hidden" name="schema" value="${schema}">
    <input type="hidden" name="table" value="${table}">


        <!-- THREE-COLUMN LAYOUT -->
        <div class="form-columns">
            <c:set var="totalColumns" value="${fn:length(columns)}" />
            <c:set var="thirdCount" value="${totalColumns / 3}" />
            <c:set var="thirdCountInt" value="${fn:substringBefore(thirdCount, '.')}" />
            
            <!-- Calculate dynamic column distribution -->
            <c:set var="remaining" value="${totalColumns}" />
            <c:set var="col1Count" value="${thirdCountInt}" />
            <c:set var="col2Count" value="${thirdCountInt}" />
            <c:set var="col3Count" value="${totalColumns - (col1Count + col2Count)}" />
            
            <!-- COLUMN 1 -->
            <div>
                <c:forEach var="col" items="${columns}" varStatus="status">
                    <c:if test="${status.index < col1Count}">
                        <div class="form-group">
                            <label>${col}</label>
                            <c:choose>
                                <c:when test="${col == primaryKey}">
                                    <input type="text" value="${row[col]}" readonly>
                                    <input type="hidden" name="${primaryKey}" value="${row[col]}">
                                </c:when>
                                <c:otherwise>
                                    <input type="text" name="${col}" value="${row[col]}" 
                                           <c:if test="${mode != 'ADD' and col == primaryKey}">readonly</c:if>>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
            
            <!-- COLUMN 2 -->
            <div>
                <c:forEach var="col" items="${columns}" varStatus="status">
                    <c:if test="${status.index >= col1Count and status.index < (col1Count + col2Count)}">
                        <div class="form-group">
                            <label>${col}</label>
                            <c:choose>
                                <c:when test="${col == primaryKey}">
                                    <input type="text" value="${row[col]}" readonly>
                                    <input type="hidden" name="${primaryKey}" value="${row[col]}">
                                </c:when>
                                <c:otherwise>
                                    <input type="text" name="${col}" value="${row[col]}" 
                                           <c:if test="${mode != 'ADD' and col == primaryKey}">readonly</c:if>>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
            
            <!-- COLUMN 3 -->
            <div>
                <c:forEach var="col" items="${columns}" varStatus="status">
                    <c:if test="${status.index >= (col1Count + col2Count)}">
                        <div class="form-group">
                            <label>${col}</label>
                            <c:choose>
                                <c:when test="${col == primaryKey}">
                                    <input type="text" value="${row[col]}" readonly>
                                    <input type="hidden" name="${primaryKey}" value="${row[col]}">
                                </c:when>
                                <c:otherwise>
                                    <input type="text" name="${col}" value="${row[col]}" 
                                           <c:if test="${mode != 'ADD' and col == primaryKey}">readonly</c:if>>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </div>

<!-- ACTIONS -->
<div class="form-actions">

    <!-- SUBMIT -->
    <button type="submit">
        <c:choose>
            <c:when test="${mode == 'ADD'}">Add ${table}</c:when>
            <c:otherwise>Update ${table}</c:otherwise>
        </c:choose>
    </button>

    <!-- CANCEL / BACK -->
  <a href="${pageContext.request.contextPath}/masters?schema=${schema}&table=${table}"
   class="back-btn">
    Cancel
</a>



</div>
    </form>
</div>
</body>
</html> 
