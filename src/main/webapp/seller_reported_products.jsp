<%@ page session="true" contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.ReportedProductPojo" %>
<%
  // guard: only sellers may view
  String role = (String) session.getAttribute("role");
  if (!"seller".equals(role)) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  List<ReportedProductPojo> reports =
      (List<ReportedProductPojo>) request.getAttribute("reportList");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Handle Reports</title>

  <!-- Bootstrap CSS & Icons -->
  <link
    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
    rel="stylesheet"/>
  <link
    href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css"
    rel="stylesheet"/>

  <style>
    :root {
      --sb-expanded: 250px;
      --sb-collapsed:  80px;
    }
    body {
      font-family: 'Nunito', sans-serif;
      background: #f4f7fa;
      overflow-x: hidden;
    }

    /* Sidebar */
    #sidebar {
      position: fixed;
      top: 56px; bottom: 0;
      width: var(--sb-expanded);
      background: #2c3e50;
      transition: width .3s ease;
      overflow-x: hidden;
      z-index: 1030;
    }
    #sidebar.sidebar-collapsed { width: var(--sb-collapsed); }

    #sidebar .nav-link {
      color: #ecf0f1;
      padding: .75rem 1rem;
      display: flex;
      align-items: center;
      transition: padding .3s;
    }
    #sidebar.sidebar-collapsed .nav-link {
      justify-content: center;
      padding: .75rem 0;
    }
    #sidebar .nav-link i { font-size: 1.3rem; }
    #sidebar .sidebar-text { margin-left: .5rem; }
    #sidebar.sidebar-collapsed .sidebar-text { display: none !important; }

    /* Main wrapper/shift */
    .main-wrapper { display: flex; }
    .main-content {
      flex: 1;
      margin-left: var(--sb-expanded);
      padding: 3rem;
      margin-top: 56px;
      transition: margin-left .3s ease;
    }
    #sidebar.sidebar-collapsed ~ .main-content {
      margin-left: var(--sb-collapsed);
    }

    @keyframes fadeIn { to { opacity: 1; } }
    /* dropdown hover glow */
    .form-select:hover {
      box-shadow: 0 0 8px rgba(31,60,136,0.2);
      transition: box-shadow .2s ease;
    }

    /* button ripple */
    .btn-mark-solved {
      position: relative;
      overflow: hidden;
    }
    .btn-mark-solved:active::after {
      content: "";
      position: absolute;
      width: 100%; height: 100%;
      background: rgba(255,255,255,0.3);
      top: 0; left: 0;
      animation: ripple .4s ease-out;
    }
    @keyframes ripple { to { opacity: 0; } }

    /* small controls */
    .form-select-sm { font-size: .85rem; }
    .btn-mark-solved { font-size: .85rem; padding: .3rem .75rem; }
    .orders-table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  background: #fff;
  border-radius: .75rem;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}
.orders-table thead {
  /* Example gradient from deep slate to teal */
  background: linear-gradient(135deg, #2c3e50  90%);
}
.orders-table thead th {
  color: #fff;
  text-transform: uppercase;
  font-weight: 600;
  padding: 1rem;
  border: none;
}
.orders-table tbody tr {
  transition: background .3s ease, transform .2s ease;
  cursor: pointer;
}
.orders-table tbody tr:hover {
  background: rgba(92,124,250,0.1);
  transform: translateY(-1px);
}
.orders-table td {
  padding: .9rem 1rem;
  vertical-align: middle;
  border-bottom: 1px solid #f0f0f0;
}
.orders-table tbody tr:last-child td {
  border-bottom: none;
}
.orders-table .badge-status.bg-success {
  /* light green, a bit deeper */
  background-color: #dff7df !important;  
  border-color:     #bce6bd !important;
  color:            #000   !important;
}

.orders-table .badge-status.bg-secondary {
  /* light yellow (instead of gray), a bit deeper */
  background-color: #fffbcc !important;
  border-color:     #fff7a6 !important;
  color:            #000   !important;
}

.orders-table .badge-status.bg-info {
  /* light blue, a bit deeper */
  background-color: #dceeff !important;
  border-color:     #bddcff !important;
  color:            #000   !important;
}

.orders-table .badge-status.bg-warning {
  /* pale lemon, a bit deeper */
  background-color: #fff9b2 !important;
  border-color:     #fff48c !important;
  color:            #000   !important;
}

.orders-table .badge-status.bg-danger {
  /* pale rose, a bit deeper */
  background-color: #ffdddd !important;
  border-color:     #ffbdbd !important;
  color:            #000   !important;
}
/* ------------ Form & Button styling ------------ */
.orders-table td form {
  display: flex;
  justify-content: center;
  align-items: center;
  margin: 0;
}
.orders-table td form .form-select {
  width: auto;
  min-width: 100px;
  padding: 0.375rem 0.75rem;
  font-size: 0.85rem;
  line-height: 1.5;
  border: 1px solid #dee2e6;
  border-radius: 0.375rem;
  background-color: #fff;
  transition: border-color .15s ease-in-out, box-shadow .15s ease-in-out;
}
.orders-table td form .btn {
  padding: 0.375rem 0.75rem;
  font-size: 0.85rem;
  line-height: 1.5;
  margin-left: 0.5rem;
  border-radius: 0.375rem;
  background-color: #e6f4ea; /* very light green */
  color: #1f5233;            /* dark contrast text */
  border: 1px solid #c3e6cb; /* matching light border */
  transition: background-color .2s ease;
}
.orders-table td form .btn:hover {
  background-color: #d4edda; /* slightly deeper on hover */
}
  </style>
</head>
<body>

  <!-- fixed top navbar -->
  <jsp:include page="/WEB-INF/fragments/seller_header.jsp"/>

  <div class="main-wrapper">
    <!-- sidebar -->
    <jsp:include page="/WEB-INF/fragments/seller_sidebar.jsp"/>

    <!-- page content -->
    <div class="main-content">
      <div class="d-flex justify-content-between align-items-center mb-4">
    <h2 class="fw-bold mb-0">
      <i class="bi bi-flag-fill me-2"></i>Reports Received
    </h2>
    <div>
      <!-- Back to Dashboard -->
      <a href="SellerDash.jsp" class="btn btn-dashboard me-2">
        <i class="bi bi-arrow-left-circle"></i> Dashboard
      </a>
      <!-- Go to Product Management -->
      
    </div>
  </div>
      <div class="card shadow-sm">
        <div class="card-header bg-white border-0">
          <h5 class="mb-0"><i class="bi bi-file-earmark-text-fill me-2"></i>All Reports</h5>
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class=" orders-table mb-0">
              <thead class="table-light">
                <tr>
                  <th>Report ID</th>
                  <th>Product ID</th>
                  <th>Consumer ID</th>
                  <th>Issue</th>
                  <th>Status</th>
                  <th>Action Taken</th>
                  <th>Mark Solved</th>
                  <th>Date</th>
                </tr>
              </thead>
              <tbody>
                <% if (reports != null && !reports.isEmpty()) {
                     for (ReportedProductPojo r : reports) { %>
                <tr>
                  <td><%= r.getReportId() %></td>
                  <td><%= r.getProductId() %></td>
                  <td><%= r.getConsumerPortId() %></td>
                  <td><%= r.getIssueType() %></td>
                  <td>
                    <span class="badge
                      <%= "solved".equals(r.getStatus())  ? "bg-success text-white"
                         : "pending".equals(r.getStatus()) ? "bg-warning text-dark"
                         : "bg-secondary text-white" %>">
                      <%= r.getStatus() %>
                    </span>
                  </td>

                  <form method="post" action="<%=request.getContextPath()%>/reports" class="d-flex align-items-center">
                   <input type="hidden" name="action" value="updatestatus"/>
                    <input type="hidden" name="report_id" value="<%= r.getReportId() %>"/>
                    <input type="hidden" name="action_taken" value="<%= r.getActionTaken() %>"/>

                      <td><%= r.getActionTaken() %></td>

                    <td>
                      <button type="submit"
                              name="status" value="solved"
                              class="btn btn-sm btn-success btn-mark-solved"
                              <%= "solved".equals(r.getStatus()) ? "disabled" : "" %>>
                        <i class="bi bi-check2-circle me-1"></i>Mark Solved
                      </button>
                    </td>
                  </form>

                  <td><%= r.getReportDate() %></td>
                </tr>
                <%   }
                   } else { %>
                <tr>
                  <td colspan="8" class="text-center py-4">No reports found.</td>
                </tr>
                <% } %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div><!-- /.main-content -->
  </div><!-- /.main-wrapper -->

  <!-- Bootstrap JS + toggle -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    function toggleSidebar(){
      const sb   = document.getElementById('sidebar'),
            icon = document.getElementById('toggleIcon');
      sb.classList.toggle('sidebar-collapsed');
      sb.classList.toggle('sidebar-expanded');
      icon.classList.toggle('bi-arrow-left-circle');
      icon.classList.toggle('bi-arrow-right-circle');
    }
  </script>
</body>
</html>