<%@ page contentType="text/html; charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*, db.DBConnection" %>
<%
    /* ────────────────────────────────────────────
       HANDLE ACTION REQUEST (AUTHORIZE / REJECT)
    ──────────────────────────────────────────── */
    String action = request.getParameter("action");

    if ("AUTHORIZE".equalsIgnoreCase(action) || "REJECT".equalsIgnoreCase(action)) {

        String sessionCheck = (String) session.getAttribute("branchCode");
        if (sessionCheck == null) {
            response.setContentType("text/plain;charset=UTF-8");
            out.clear();
            out.print("Session expired. Please login again.");
            return;
        }

        String memberNo  = request.getParameter("memberNumber");
        String certNo    = request.getParameter("certNumber");
        String newStatus = "AUTHORIZE".equalsIgnoreCase(action) ? "A" : "R";

        String officerId = (String) session.getAttribute("userId");
        if (officerId == null) officerId = (String) session.getAttribute("USER_ID");
        if (officerId == null) officerId = (String) session.getAttribute("username");
        if (officerId == null) officerId = (String) session.getAttribute("loginId");

        Connection connA         = null;
        PreparedStatement pstmtA = null;

        try {
            connA = DBConnection.getConnection();
            connA.setAutoCommit(false);

            String sqlU =
                "UPDATE SHARES.CERTIFICATE_MASTER " +
                "SET STATUS = ?, OFFICER_ID = ? " +
                "WHERE MEMBER_NUMBER = ? AND CERTIFICATE_NUMBER = ? AND STATUS = 'E'";

            pstmtA = connA.prepareStatement(sqlU);
            pstmtA.setString(1, newStatus);
            pstmtA.setString(2, officerId);
            pstmtA.setLong(3, Long.parseLong(memberNo.trim()));
            pstmtA.setLong(4, Long.parseLong(certNo.trim()));

            int updatedRows = pstmtA.executeUpdate();
            connA.commit();

            response.setContentType("text/plain;charset=UTF-8");
            out.clear();
            if (updatedRows > 0) {
                out.print("AUTHORIZE".equalsIgnoreCase(action)
                    ? "Share holder authorized successfully."
                    : "Share holder rejected successfully.");
            } else {
                out.print("No record updated. It may have already been processed.");
            }
        } catch (Exception e) {
            if (connA != null) try { connA.rollback(); } catch (Exception ex) {}
            response.setContentType("text/plain;charset=UTF-8");
            out.clear();
            out.print("Error: " + e.getClass().getName() + ": " + e.getMessage());
        } finally {
            if (pstmtA != null) try { pstmtA.close(); } catch (Exception ex) {}
            if (connA  != null) try { connA.close();  } catch (Exception ex) {}
        }
        return;
    }

    /* ────────────────────────────────────────────
       NORMAL PAGE LOAD
    ──────────────────────────────────────────── */
    String branchCode  = request.getParameter("branchCode");
    String accountCode = request.getParameter("accountCode");

    String sessionBranch = (String) session.getAttribute("branchCode");
    if (sessionBranch == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    /* ── 1. Share Holder Details ── */
    String accountName    = "";
    String branchCol      = "";
    String issueDate      = "";
    String customerId     = "";
    String memberNumber   = "";
    String certNumber     = "";
    String faceValue      = "";
    String numberOfShares = "";
    String totalAmount    = "";
    String errorMsg       = "";
    String fromNumber     = "";
    String toNumber       = "";
    boolean dataFound     = false;

    Connection conn         = null;
    PreparedStatement pstmt = null;
    ResultSet rs            = null;

    try {
        conn = DBConnection.getConnection();

        String sql =
            "SELECT cm.BR_CODE, " +
            "       cm.ACCOUNT_NUMBER, " +
            "       FN_GET_ACCOUNT_NAME(cm.ACCOUNT_NUMBER) AS ACCOUNT_NAME, " +
            "       cm.ISSUE_DATE, " +
            "       cm.CUSTOMER_ID, " +
            "       cm.MEMBER_NUMBER, " +
            "       cm.CERTIFICATE_NUMBER, " +
            "       cm.FACE_VALUE, " +
            "       cm.NUMBEROF_SHARES, " +
            "       cm.TOTAL_SHARESAMOUNT, " +
            "       cm.FROM_NUMBER, " +
            "       cm.TO_NUMBER " +
            "FROM SHARES.CERTIFICATE_MASTER cm " +
            "WHERE cm.ACCOUNT_NUMBER = ? AND cm.STATUS = 'E'";

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, accountCode);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            dataFound      = true;
            accountName    = rs.getString("ACCOUNT_NAME")       != null ? rs.getString("ACCOUNT_NAME")       : "";
            branchCol      = rs.getString("BR_CODE")            != null ? rs.getString("BR_CODE")            : "";
            customerId     = rs.getString("CUSTOMER_ID")        != null ? rs.getString("CUSTOMER_ID")        : "";
            memberNumber   = rs.getString("MEMBER_NUMBER")      != null ? rs.getString("MEMBER_NUMBER")      : "";
            certNumber     = rs.getString("CERTIFICATE_NUMBER") != null ? rs.getString("CERTIFICATE_NUMBER") : "";
            faceValue      = rs.getString("FACE_VALUE")         != null ? rs.getString("FACE_VALUE")         : "";
            numberOfShares = rs.getString("NUMBEROF_SHARES")    != null ? rs.getString("NUMBEROF_SHARES")    : "";
            totalAmount    = rs.getString("TOTAL_SHARESAMOUNT") != null ? rs.getString("TOTAL_SHARESAMOUNT") : "";
            fromNumber     = rs.getString("FROM_NUMBER")        != null ? rs.getString("FROM_NUMBER")        : "";
            toNumber       = rs.getString("TO_NUMBER")          != null ? rs.getString("TO_NUMBER")          : "";

            java.sql.Date issueDateRaw = rs.getDate("ISSUE_DATE");
            if (issueDateRaw != null) {
                issueDate = new java.text.SimpleDateFormat("dd-MMM-yyyy").format(issueDateRaw);
            }
        }

    } catch (Exception e) {
        errorMsg = e.getClass().getName() + ": " + e.getMessage();
    } finally {
        if (rs    != null) try { rs.close();    } catch (Exception ex) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception ex) {}
        if (conn  != null) try { conn.close();  } catch (Exception ex) {}
    }

    /* ── 2. Transfer / Cash Details ── */
    java.util.List<String[]> transferList = new java.util.ArrayList<>();
    String transferErrorMsg = "";
    boolean isCash          = false;
    String  cashAmount      = "";

    if (dataFound && accountCode != null && !accountCode.trim().isEmpty()) {
        Connection connT         = null;
        PreparedStatement pstmtT = null;
        ResultSet rsT            = null;
        try {
            connT = DBConnection.getConnection();

            /* ── First check if this is a CASH (CSCR) transaction ── */
            String sqlCheck =
                "SELECT t.TRANSACTIONINDICATOR_CODE, t.AMOUNT " +
                "FROM TRANSACTION.DAILYSCROLL t " +
                "WHERE t.FORACCOUNT_CODE = ? " +
                "  AND t.TRANSACTIONINDICATOR_CODE = 'CSCR' " +
                "  AND ROWNUM = 1";

            pstmtT = connT.prepareStatement(sqlCheck);
            pstmtT.setString(1, accountCode);
            rsT = pstmtT.executeQuery();

            if (rsT.next()) {
                isCash     = true;
                cashAmount = rsT.getString("AMOUNT") != null ? rsT.getString("AMOUNT") : "";
            }
            rsT.close();
            pstmtT.close();

            /* ── If not cash, fetch TRDR debit accounts ── */
            if (!isCash) {
                String sqlT =
                    "SELECT t.ACCOUNT_CODE, " +
                    "       FN_GET_ACCOUNT_NAME(t.ACCOUNT_CODE) AS ACCOUNT_NAME, " +
                    "       t.AMOUNT " +
                    "FROM TRANSACTION.DAILYSCROLL t " +
                    "WHERE t.TRANSACTIONINDICATOR_CODE = 'TRDR' " +
                    "  AND t.FORACCOUNT_CODE = ?";

                pstmtT = connT.prepareStatement(sqlT);
                pstmtT.setString(1, accountCode);
                rsT = pstmtT.executeQuery();

                while (rsT.next()) {
                    String[] row = new String[3];
                    row[0] = rsT.getString("ACCOUNT_CODE")  != null ? rsT.getString("ACCOUNT_CODE")  : "";
                    row[1] = rsT.getString("ACCOUNT_NAME")  != null ? rsT.getString("ACCOUNT_NAME")  : "";
                    row[2] = rsT.getString("AMOUNT")        != null ? rsT.getString("AMOUNT")        : "";
                    transferList.add(row);
                }
            }

        } catch (Exception e) {
            transferErrorMsg = e.getClass().getName() + ": " + e.getMessage();
        } finally {
            if (rsT    != null) try { rsT.close();    } catch (Exception ex) {}
            if (pstmtT != null) try { pstmtT.close(); } catch (Exception ex) {}
            if (connT  != null) try { connT.close();  } catch (Exception ex) {}
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Shares Authorization</title>
<style>
:root {
    --bg-lavender:  #E6E6FA;
    --navy-blue:    #2b0d73;
    --border-color: #B8B8E6;
    --readonly-bg:  #E0E0E0;
}
* { box-sizing: border-box; margin: 0; padding: 0; }
body {
    font-family: Arial, sans-serif;
    background-color: var(--bg-lavender);
    padding: 20px 20px 60px 20px;
}
.container { max-width: 1400px; margin: auto; }
h2 {
    text-align: center;
    color: var(--navy-blue);
    font-weight: 700;
    font-size: 26px;
    margin-bottom: 25px;
}
fieldset {
    border: 1.5px solid var(--border-color);
    border-radius: 8px;
    margin-bottom: 22px;
    padding: 18px;
    overflow: visible;
}
legend {
    color: var(--navy-blue);
    font-weight: bold;
    font-size: 15px;
    padding: 0 10px;
    background-color: var(--bg-lavender);
}
.grid-row {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 15px;
    margin-bottom: 15px;
    align-items: end;
}
.grid-row:last-child { margin-bottom: 0; }
.form-group { width: 100%; }
.form-group label {
    display: block;
    font-size: 13px;
    font-weight: bold;
    color: var(--navy-blue);
    margin-bottom: 4px;
}
.form-group input {
    width: 100%;
    padding: 7px;
    border: 1px solid var(--border-color);
    border-radius: 4px;
    font-size: 13px;
    background-color: var(--readonly-bg);
    box-sizing: border-box;
}
.error-box {
    background: #fff0f0;
    border: 1px solid #f5b8b8;
    border-radius: 6px;
    padding: 14px 18px;
    color: #c0392b;
    font-size: 14px;
    margin-bottom: 18px;
    word-break: break-word;
}

/* ── Transfer Accounts ── */
.transfer-row {
    display: grid;
    grid-template-columns: 40px 2fr 4fr 1fr;
    gap: 15px;
    align-items: end;
    margin-bottom: 20px;
    padding-bottom: 20px;
    border-bottom: 1px dashed var(--border-color);
}
.transfer-row:last-child {
    border-bottom: none;
    margin-bottom: 0;
    padding-bottom: 0;
}
.sr-number {
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 15px;
    font-weight: 700;
    color: var(--navy-blue);
    padding-bottom: 4px;
}

.btn-row-back {
    text-align: center;
    margin-top: 20px;
    margin-bottom: 14px;
}
.btn-row-actions {
    text-align: center;
    display: flex;
    justify-content: center;
    gap: 16px;
    flex-wrap: wrap;
}
.btn {
    padding: 10px 30px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 15px;
    font-weight: bold;
    color: white;
    min-width: 140px;
    transition: transform 0.1s, opacity 0.15s;
}
.btn:hover  { opacity: 0.9; transform: translateY(-1px); }
.btn:active { transform: translateY(0); }
.btn-back      { background: #373279; }
.btn-authorize { background: linear-gradient(45deg, #28a745, #34ce57); }
.btn-reject    { background: linear-gradient(45deg, #dc3545, #e74c3c); }

/* ── Modal ── */
.modal-overlay {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.45);
    z-index: 999;
    justify-content: center;
    align-items: center;
}
.modal-overlay.active { display: flex; }
.modal-box {
    background: #ffffff;
    border-radius: 20px;
    padding: 48px 44px 40px 44px;
    max-width: 520px;
    width: 92%;
    text-align: center;
    box-shadow: 0 8px 40px rgba(0,0,0,0.18);
}
.modal-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    font-size: 26px;
    font-weight: 700;
    color: #2b0d73;
    margin-bottom: 22px;
}
.modal-icon .icon-symbol { font-size: 28px; }
.modal-box.authorize .icon-symbol { color: #28a745; }
.modal-box.reject    .icon-symbol { color: #dc3545; }
.modal-box p {
    font-size: 15px;
    color: #444;
    margin-bottom: 6px;
    line-height: 1.6;
}
.modal-box p span { font-weight: 700; color: #2b0d73; }
.modal-btn-row {
    display: flex;
    justify-content: center;
    gap: 18px;
    margin-top: 32px;
}
.modal-cancel {
    padding: 11px 36px;
    border: none;
    border-radius: 8px;
    background: #e0e0e0;
    color: #333;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s;
}
.modal-cancel:hover { background: #cacaca; }
.modal-confirm-auth {
    padding: 11px 36px;
    border: none;
    border-radius: 8px;
    background: #28a745;
    color: #fff;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s;
}
.modal-confirm-auth:hover { background: #218838; }
.modal-confirm-reject {
    padding: 11px 36px;
    border: none;
    border-radius: 8px;
    background: #dc3545;
    color: #fff;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s;
}
.modal-confirm-reject:hover { background: #c82333; }
</style>
</head>
<body>
<div class="container">

    <h2>Shares Authorization</h2>

    <% if (!errorMsg.isEmpty()) { %>
        <div class="error-box"><strong>Database Error:</strong> <%=errorMsg%></div>
    <% } else if (!dataFound) { %>
        <div class="error-box">No pending record found for Account: <%=accountCode%></div>
    <% } else { %>

        <!-- ══ SHARE HOLDER DETAILS ══ -->
        <fieldset>
            <legend>Share Holder Details</legend>
            <div class="grid-row">
                <div class="form-group">
                    <label>Account Number</label>
                    <input type="text" value="<%=accountCode != null ? accountCode : ""%>" readonly>
                </div>
                <div class="form-group">
                    <label>Account Name</label>
                    <input type="text" value="<%=accountName%>" readonly>
                </div>
                <div class="form-group">
                    <label>Branch Code</label>
                    <input type="text" value="<%=branchCol%>" readonly>
                </div>
                <div class="form-group">
                    <label>Issue Date</label>
                    <input type="text" value="<%=issueDate%>" readonly>
                </div>
            </div>
            <div class="grid-row">
                <div class="form-group">
                    <label>Customer ID</label>
                    <input type="text" value="<%=customerId%>" readonly>
                </div>
            </div>
        </fieldset>

        <!-- ══ TRANSFER / CASH ACCOUNTS ══ -->
        <fieldset>
            <legend>Transfer Accounts Details</legend>

            <% if (!transferErrorMsg.isEmpty()) { %>
                <div class="error-box"><strong>Error loading transfer details:</strong> <%=transferErrorMsg%></div>

            <% } else if (isCash) { %>
                <!-- CASH MODE: show only By Cash + Cash Amount -->
                <div class="grid-row">
                    <div class="form-group">
                        <label>Mode</label>
                        <input type="text" value="By Cash" readonly>
                    </div>
                    <div class="form-group">
                        <label>Cash Amount</label>
                        <input type="text" value="<%=cashAmount%>" readonly style="text-align:left;">
                    </div>
                </div>

            <% } else if (transferList.isEmpty()) { %>
                <p style="color:#888; font-size:13px; font-style:italic;">No transfer accounts found.</p>

            <% } else {
                   int srNo = 1;
                   for (String[] row : transferList) { %>
                <!-- TRANSFER MODE: show each debit account -->
                <div class="transfer-row">
                    <div class="sr-number"><%=srNo++%></div>
                    <div class="form-group">
                        <label>Account Code</label>
                        <input type="text" value="<%=row[0]%>" readonly>
                    </div>
                    <div class="form-group">
                        <label>Account Name</label>
                        <input type="text" value="<%=row[1]%>" readonly>
                    </div>
                    <div class="form-group">
                        <label>Amount</label>
                        <input type="text" value="<%=row[2]%>" readonly style="text-align:left;">
                    </div>
                </div>
            <%  } %>
            <% } %>
        </fieldset>

        <!-- ══ SHARE DETAILS ══ -->
        <fieldset>
            <legend>Share Details</legend>
            <div class="grid-row">
                <div class="form-group">
                    <label>Member Number</label>
                    <input type="text" value="<%=memberNumber%>" readonly>
                </div>
                <div class="form-group">
                    <label>Certificate Number</label>
                    <input type="text" value="<%=certNumber%>" readonly>
                </div>
                <div class="form-group">
                    <label>Form Number Range</label>
                    <input type="text" value="<%=fromNumber%> - <%=toNumber%>" readonly>
                </div>
                <div class="form-group">
                    <label>Face Value</label>
                    <input type="text" value="<%=faceValue%>" readonly>
                </div>
            </div>
            <div class="grid-row">
                <div class="form-group">
                    <label>Number of Shares</label>
                    <input type="text" value="<%=numberOfShares%>" readonly>
                </div>
                <div class="form-group">
                    <label>Total Shares Amount</label>
                    <input type="text" value="<%=totalAmount%>" readonly>
                </div>
            </div>
        </fieldset>

    <% } %>

    <div class="btn-row-back">
        <button class="btn btn-back" onclick="goBackToList()">&#8592; Back to List</button>
    </div>
    <% if (dataFound) { %>
    <div class="btn-row-actions">
        <button class="btn btn-authorize" onclick="handleAuthorize()">&#10004; Authorize</button>
        <button class="btn btn-reject"    onclick="handleReject()">&#10008; Reject</button>
    </div>
    <% } %>

    <!-- Authorize Modal -->
    <div class="modal-overlay" id="authorizeModal">
        <div class="modal-box authorize">
            <div class="modal-icon">
                <span class="icon-symbol">&#10003;</span>
                Confirm Authorization
            </div>
            <p>Are you sure you want to <strong>authorize</strong> this share holder?</p>
            <p>Certificate No : <span><%=certNumber%></span></p>
            <div class="modal-btn-row">
                <button class="modal-cancel" onclick="closeModal('authorizeModal')">Cancel</button>
                <button class="modal-confirm-auth" onclick="confirmAuthorize()">Yes, Authorize</button>
            </div>
        </div>
    </div>

    <!-- Reject Modal -->
    <div class="modal-overlay" id="rejectModal">
        <div class="modal-box reject">
            <div class="modal-icon">
                <span class="icon-symbol">&#10007;</span>
                Confirm Rejection
            </div>
            <p>Are you sure you want to <strong>reject</strong> this share holder?</p>
            <p>Certificate No : <span><%=certNumber%></span></p>
            <div class="modal-btn-row">
                <button class="modal-cancel" onclick="closeModal('rejectModal')">Cancel</button>
                <button class="modal-confirm-reject" onclick="confirmReject()">Yes, Reject</button>
            </div>
        </div>
    </div>

</div>

<input type="hidden" id="hiddenMemberNumber" value="<%=memberNumber%>">
<input type="hidden" id="hiddenCertNumber"   value="<%=certNumber%>">

<script>
    var MEMBER_NUMBER = document.getElementById("hiddenMemberNumber").value;
    var CERT_NUMBER   = document.getElementById("hiddenCertNumber").value;
    var ACTION_URL    = "<%=request.getContextPath()%>/Authorization/authViewShares.jsp";

    function goBackToList() {
        if (window.parent && window.parent.document) {
            var iframe = window.parent.document.getElementById("contentFrame");
            if (iframe) {
                iframe.src = "Authorization/authorizationPendingShares.jsp";
                if (window.parent.updateParentBreadcrumb) {
                    window.parent.updateParentBreadcrumb("Authorization > Pending Shares");
                }
                return;
            }
        }
        window.location.href = "authorizationPendingShares.jsp";
    }

    function handleAuthorize() {
        document.getElementById("authorizeModal").classList.add("active");
    }
    function handleReject() {
        document.getElementById("rejectModal").classList.add("active");
    }
    function closeModal(id) {
        document.getElementById(id).classList.remove("active");
    }
    function confirmAuthorize() {
        closeModal("authorizeModal");
        fetch(ACTION_URL, {
            method : "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body   : "action=AUTHORIZE"
                   + "&memberNumber=" + encodeURIComponent(MEMBER_NUMBER)
                   + "&certNumber="   + encodeURIComponent(CERT_NUMBER)
        })
        .then(function() { goBackToList(); })
        .catch(function() { goBackToList(); });
    }
    function confirmReject() {
        closeModal("rejectModal");
        fetch(ACTION_URL, {
            method : "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body   : "action=REJECT"
                   + "&memberNumber=" + encodeURIComponent(MEMBER_NUMBER)
                   + "&certNumber="   + encodeURIComponent(CERT_NUMBER)
        })
        .then(function() { goBackToList(); })
        .catch(function() { goBackToList(); });
    }
</script>
</body>
</html>
