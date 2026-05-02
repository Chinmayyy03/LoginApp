<%@ page import="java.sql.*, db.DBConnection" %> 
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("branchCode") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String branchCode = (String) sess.getAttribute("branchCode");

    // ── AJAX search mode: returns JSON ────────────────────────────────────────
    String searchParam = request.getParameter("search");
    boolean isAjax = (searchParam != null);

    if (isAjax) {
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache");

        String excludeRaw   = request.getParameter("excludeCustomerIds");
        String search       = searchParam.trim();
        String pageStr      = request.getParameter("page");
        int    page         = (pageStr != null && !pageStr.isEmpty()) ? Integer.parseInt(pageStr) : 1;
        int    pageSize     = 50;
        int    offset       = (page - 1) * pageSize;

        // Build exclusion clause
        String[] exIds = (excludeRaw != null && !excludeRaw.trim().isEmpty())
                         ? excludeRaw.split(",") : new String[0];
        StringBuilder excl = new StringBuilder();
        if (exIds.length > 0) {
            excl.append(" AND CUSTOMER_ID NOT IN (");
            for (int i = 0; i < exIds.length; i++) {
                excl.append("?");
                if (i < exIds.length - 1) excl.append(",");
            }
            excl.append(")");
        }

        // Search clause — empty search returns first N rows
        String searchClause = search.isEmpty() ? "" : " AND (UPPER(CUSTOMER_ID) LIKE ? OR UPPER(CUSTOMER_NAME) LIKE ?)";

        // Oracle-compatible pagination (works on 11g+)
        String sql =
            "SELECT CUSTOMER_ID, CUSTOMER_NAME, CATEGORY_CODE, RISK_CATEGORY, TOTAL_COUNT " +
            "FROM ( " +
            "  SELECT CUSTOMER_ID, CUSTOMER_NAME, CATEGORY_CODE, RISK_CATEGORY, " +
            "         COUNT(*) OVER () AS TOTAL_COUNT, ROWNUM AS RN " +
            "  FROM ( " +
            "    SELECT CUSTOMER_ID, CUSTOMER_NAME, CATEGORY_CODE, RISK_CATEGORY " +
            "    FROM CUSTOMERS " +
            "    WHERE BRANCH_CODE = ? AND STATUS = 'A'" +
            excl +
            searchClause +
            "    ORDER BY CUSTOMER_ID " +
            "  ) " +
            "  WHERE ROWNUM <= ? " +
            ") WHERE RN > ?";

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();
            ps  = con.prepareStatement(sql);

            int idx = 1;
            ps.setString(idx++, branchCode);

            for (String id : exIds) ps.setString(idx++, id.trim());

            if (!search.isEmpty()) {
                String like = "%" + search.toUpperCase() + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, like);
            }

            ps.setInt(idx++, offset + pageSize); // ROWNUM <=
            ps.setInt(idx++, offset);            // RN >

            rs = ps.executeQuery();

            StringBuilder sb = new StringBuilder("{\"rows\":[");
            boolean first = true;
            int totalCount = 0;

            while (rs.next()) {
                if (totalCount == 0) totalCount = rs.getInt("TOTAL_COUNT");
                if (!first) sb.append(",");
                first = false;

                String cid   = escJs(rs.getString("CUSTOMER_ID"));
                String cname = escJs(rs.getString("CUSTOMER_NAME"));
                String cat   = escJs(rs.getString("CATEGORY_CODE"));
                String risk  = escJs(rs.getString("RISK_CATEGORY"));

                sb.append("[\"").append(cid).append("\",\"")
                  .append(cname).append("\",\"")
                  .append(cat).append("\",\"")
                  .append(risk).append("\"]");
            }

            sb.append("],\"total\":").append(totalCount)
              .append(",\"page\":").append(page)
              .append(",\"pageSize\":").append(pageSize)
              .append("}");

            out.print(sb.toString());

        } catch (Exception e) {
            out.print("{\"error\":\"" + escJs(e.getMessage()) + "\",\"rows\":[],\"total\":0}");
            e.printStackTrace();
        } finally {
            try { if (rs  != null) rs.close();  } catch (Exception ex) {}
            try { if (ps  != null) ps.close();  } catch (Exception ex) {}
            try { if (con != null) con.close(); } catch (Exception ex) {}
        }
        return; // ← JSON response done, skip HTML below
    }

    // ── HTML scaffold mode (initial load, no data) ────────────────────────────
    String excludeCustomerIds = request.getParameter("excludeCustomerIds");
    if (excludeCustomerIds == null) excludeCustomerIds = "";
%>

<style>
.ck-wrap { font-family: Arial, sans-serif; }
.ck-title { font-size: 18px; font-weight: bold; color: #373279; margin-bottom: 10px; }
.ck-search { display:flex; align-items:center; gap:8px; margin-bottom:8px; }
.ck-search input {
    flex:1; padding:8px 12px; border:1px solid #ccc;
    border-radius:6px; font-size:14px; outline:none;
}
.ck-search input:focus { border-color:#373279; box-shadow:0 0 0 2px rgba(55,50,121,0.15); }
.ck-meta { font-size:13px; color:#666; margin-bottom:6px; }
.ck-table-wrap { max-height:420px; overflow-y:auto; border:1px solid #ddd; border-radius:6px; }
table.ck { width:100%; border-collapse:collapse; }
table.ck thead th {
    background:#373279; color:#fff; padding:10px 12px;
    text-align:left; position:sticky; top:0; z-index:1; font-size:13px;
}
table.ck tbody tr { cursor:pointer; border-bottom:1px solid #eee; }
table.ck tbody tr:hover { background:#eef; }
table.ck tbody td { padding:9px 12px; font-size:13px; }
.ck-empty { text-align:center; color:#888; padding:30px; }
.ck-pager { display:flex; justify-content:space-between; align-items:center;
            padding:6px 8px; font-size:13px; color:#555; }
.ck-pager button {
    padding:4px 14px; border:1px solid #ccc; border-radius:4px;
    background:#fff; cursor:pointer; font-size:13px;
}
.ck-pager button:disabled { opacity:.4; cursor:default; }
.ck-pager button:not(:disabled):hover { background:#f0eeff; border-color:#373279; }
.ck-spinner { text-align:center; padding:20px; color:#888; }
</style>

<div class="ck-wrap">
  <div class="ck-title">🔍 Select Customer</div>

  <div class="ck-search">
    <input type="text" id="ckSearch" placeholder="Search by ID or Name…" autocomplete="off">
  </div>

  <div class="ck-meta">
    Showing <strong id="ckShowing">…</strong> of <strong id="ckTotal">…</strong> customers
  </div>

  <div class="ck-table-wrap" id="ckTableWrap">
    <table class="ck" id="ckTable">
      <thead>
        <tr>
          <th>Customer ID</th>
          <th>Customer Name</th>
          <th>Category Code</th>
          <th>Risk Category</th>
        </tr>
      </thead>
      <tbody id="ckBody">
        <tr><td colspan="4" class="ck-spinner">Loading…</td></tr>
      </tbody>
    </table>
  </div>

  <div class="ck-pager">
    <button id="ckPrev" onclick="ckChangePage(-1)" disabled>◀ Prev</button>
    <span id="ckPageInfo">Page 1</span>
    <button id="ckNext" onclick="ckChangePage(1)">Next ▶</button>
  </div>
</div>

<script>
(function () {
    // ── config ────────────────────────────────────────────────────────────────
    var BASE_URL    = 'lookupForCustomerId.jsp';
    var EXCLUDE_IDS = '<%= excludeCustomerIds.replace("'", "\\'") %>';
    var PAGE_SIZE   = 50;

    var currentPage  = 1;
    var totalRecords = 0;
    var searchTimer  = null;
    var currentSearch = '';

    // ── fetch one page ────────────────────────────────────────────────────────
    function fetchPage(page, search) {
        var body = document.getElementById('ckBody');
        body.innerHTML = '<tr><td colspan="4" class="ck-spinner">Loading…</td></tr>';

        var url = BASE_URL + '?search=' + encodeURIComponent(search) +
                  '&page=' + page +
                  (EXCLUDE_IDS ? '&excludeCustomerIds=' + encodeURIComponent(EXCLUDE_IDS) : '');

        fetch(url)
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.error) {
                    body.innerHTML = '<tr><td colspan="4" class="ck-empty">Error: ' + data.error + '</td></tr>';
                    return;
                }
                totalRecords = data.total;
                currentPage  = data.page;
                render(data.rows);
                updateMeta();
            })
            .catch(function(err) {
                body.innerHTML = '<tr><td colspan="4" class="ck-empty">Failed to load. Please try again.</td></tr>';
            });
    }

    // ── render rows ───────────────────────────────────────────────────────────
    function render(rows) {
        var body = document.getElementById('ckBody');
        if (!rows.length) {
            body.innerHTML = '<tr><td colspan="4" class="ck-empty">No customers found.</td></tr>';
            return;
        }
        // Build HTML in one shot → single DOM write
        var html = '';
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            var cid   = escHtml(r[0]);
            var cname = escHtml(r[1]);
            var cat   = escHtml(r[2]);
            var risk  = escHtml(r[3]);
            // Pass data as JS-safe attributes
            html += '<tr onclick="ckSelect(' +
                        JSON.stringify(r[0]) + ',' +
                        JSON.stringify(r[1]) + ',' +
                        JSON.stringify(r[2]) + ',' +
                        JSON.stringify(r[3]) +
                    ')">' +
                    '<td>' + cid   + '</td>' +
                    '<td>' + cname + '</td>' +
                    '<td>' + cat   + '</td>' +
                    '<td>' + risk  + '</td>' +
                    '</tr>';
        }
        body.innerHTML = html;
    }

    // ── pagination metadata ───────────────────────────────────────────────────
    function updateMeta() {
        var start = (currentPage - 1) * PAGE_SIZE + 1;
        var end   = Math.min(currentPage * PAGE_SIZE, totalRecords);
        document.getElementById('ckShowing').textContent  = totalRecords ? start + '–' + end : '0';
        document.getElementById('ckTotal').textContent    = totalRecords;
        document.getElementById('ckPageInfo').textContent = 'Page ' + currentPage;
        document.getElementById('ckPrev').disabled = (currentPage <= 1);
        document.getElementById('ckNext').disabled = (currentPage * PAGE_SIZE >= totalRecords);
    }

    // ── search with 250 ms debounce ───────────────────────────────────────────
    document.getElementById('ckSearch').addEventListener('input', function () {
        clearTimeout(searchTimer);
        var val = this.value.trim();
        searchTimer = setTimeout(function () {
            currentSearch = val;
            currentPage   = 1;
            fetchPage(1, val);
        }, 250);
    });

    // ── page navigation ───────────────────────────────────────────────────────
    window.ckChangePage = function (delta) {
        var newPage = currentPage + delta;
        if (newPage < 1 || newPage * PAGE_SIZE - PAGE_SIZE >= totalRecords) return;
        fetchPage(newPage, currentSearch);
    };

    // ── row click → delegate to parent ───────────────────────────────────────
    window.ckSelect = function (id, name, cat, risk) {
        if (window.parent && window.parent.setCustomerData) {
            window.parent.setCustomerData(id, name, cat, risk);
        } else if (window.setCustomerData) {
            window.setCustomerData(id, name, cat, risk);
        }
    };

    // ── HTML escape helper ────────────────────────────────────────────────────
    function escHtml(s) {
        return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;')
                              .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    // ── initial load ──────────────────────────────────────────────────────────
    fetchPage(1, '');
    document.getElementById('ckSearch').focus();
})();
</script>

<%!
private String escJs(String s) {
    if (s == null) return "";
    return s.replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\r", "")
            .replace("\n", "");
}
%>
