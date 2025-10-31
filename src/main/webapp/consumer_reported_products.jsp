<%@ page session="true" contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.ReportedProductPojo,java.net.URLEncoder" %>
<%
  // ensure login
  String consumer = (String) session.getAttribute("username");
  if (consumer == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  @SuppressWarnings("unchecked")
  List<ReportedProductPojo> reports =
      (List<ReportedProductPojo>) request.getAttribute("reportList");
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Your Reports</title>
  <link 
    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" 
    rel="stylesheet"/>
  <link 
    href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" 
    rel="stylesheet"/>
  <style>
    /* Sidebar + content flex container */
    .main-wrapper { display: flex; min-height: calc(100vh - 56px); }

    :root {
      --sb-expanded: 250px;
      --sb-collapsed:  80px;
    }
    
    .main-content {
      flex: 1;
      margin-top: 56px;
      margin-left: var(--sb-expanded);
      padding: 2rem;
      transition: margin-left .3s ease;
      background: #f8f9fa;
    }
    #sidebar.sidebar-collapsed ~ .main-content {
      margin-left: var(--sb-collapsed);
    }

    /* Card tweaks */
    .reports-card {
      border: none;
      box-shadow: 0 2px 6px rgba(0,0,0,0.1);
    }
    .reports-card .card-header {
      background: #fff;
      border-bottom: 1px solid #dee2e6;
    }
    .toggle-btn {
      font-size: 1.25rem;
      background: transparent;
      border: none;
    }
    .table-responsive {
  overflow-x: auto;
}

/* custom table */
.table-custom {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.05);
  border-radius: 0.5rem;
  overflow: hidden;
}

/* header */
.table-custom thead {
  background: #2c3e50;
}
.table-custom thead th {
  color: #fff;
  font-weight: 500;
  padding: 1rem;
  text-align: left;
  border-bottom: 2px solid #34495e;
}

/* body rows */
.table-custom tbody tr:nth-child(even) {
  background: #f8f9fa;
}
.table-custom tbody tr:hover {
  background: #e9f1fb;
}

/* cells */
.table-custom td,
.table-custom th {
  padding: 0.75rem 1rem;
  vertical-align: middle;
  border-top: 1px solid #ecf0f1;
}

/* rounded corners on first/last columns */
.table-custom tbody tr:first-child td:first-child,
.table-custom tbody tr:last-child td:first-child {
  border-radius: 0.5rem 0 0 0.5rem;
}
.table-custom tbody tr:first-child td:last-child,
.table-custom tbody tr:last-child td:last-child {
  border-radius: 0 0.5rem 0.5rem 0;
}
  </style>
</head>

<body class="bg-light">
  <jsp:include page="/WEB-INF/fragments/consumer_header.jsp"/>

  <div class="main-wrapper">
    <jsp:include page="/WEB-INF/fragments/consumer_sidebar.jsp"/>

    <div class="main-content">
      <div class="container-fluid">
        <div class="card reports-card">
          <div class="card-header d-flex justify-content-between align-items-center">
            <h4 class="mb-0">Your Submitted Reports</h4>
            <a href="<%= request.getContextPath() %>/ConsumerDash.jsp" 
   class="btn btn-outline-dark btn-sm">
   <i class="bi bi-arrow-left-circle"></i> Back to Dashboard
</a>
          </div>
          <div class="card-body">
            <div class="table-responsive">
              <table class="table table-striped table-hover align-middle mb-0">
                <thead class="table-light">
                  <tr>
                    <th scope="col" class="text-center">SNo.</th>
                    <th scope="col" class="text-center">Report ID</th>
                    <th scope="col" class="text-center">Product ID</th>
                    <th scope="col">Product Name</th>
                    <th scope="col">Issue</th>
                    <th scope="col">Status</th>
                    <th scope="col">Action Taken</th>
                    <th scope="col">Reported On</th>
                    <th scope="col">Action</th>
                  </tr>
                </thead>
                <tbody>
                  <%
                    if (reports != null && !reports.isEmpty()) {
                      int idx = 1;
                      for (ReportedProductPojo r : reports) {
                  %>
                  <tr>
                    <td class="text-center"><%= idx++ %></td>
                    <td class="text-center"><%= r.getReportId() %></td>
                    <td class="text-center"><%= r.getProductId() %></td>
                    <td><%= r.getProductName() %></td>
                    <td><%= r.getIssueType() %></td>
                    <td>
                      <%
                        String status = r.getStatus().toLowerCase();
                        String badgeClass = "bg-secondary";
                        if ("pending".equals(status)) badgeClass = "bg-warning text-dark";
                        else if ("in progress".equals(status)) badgeClass = "bg-info text-dark";
                        else if ("resolved".equals(status)) badgeClass = "bg-success";
                      %>
                      <span class="badge <%= badgeClass %> text-capitalize">
                        <%= r.getStatus() %>
                      </span>
                    </td>
                    <td><%= r.getActionTaken() != null ? r.getActionTaken() : "—" %></td>
                    <td><%= r.getReportDate() %></td>
                    <td class="text-nowrap">
  <% if (!"solved".equalsIgnoreCase(r.getStatus())) { %> 
    <a href="report_product_form.jsp?report_id=<%= r.getReportId() %>
        &product_id=<%= r.getProductId() %>
        &product_name=<%= URLEncoder.encode(r.getProductName(), "UTF-8") %>
        &issue_type=<%= r.getIssueType() %>
        &seller_port_id=<%= r.getSellerPortId() %>
        &order_id=<%= r.getOrderId() %>"
      class="btn btn-sm btn-outline-primary">
      <i class="bi bi-pencil-square"></i> Edit
    </a>
  <% } else { %>
    <button class="btn btn-sm btn-secondary" disabled>
      <i class="bi bi-pencil-square"></i> Edit
    </button>
  <% } %>

  <form action="reports" method="post" style="display:inline;" 
        onsubmit="return confirm('Are you sure you want to delete this report?');">
    <input type="hidden" name="action" value="delete" />
    <input type="hidden" name="report_id" value="<%= r.getReportId() %>" />
    <button type="submit" class="btn btn-sm btn-outline-danger">
      <i class="bi bi-trash"></i> Delete
    </button>
  </form>
</td>
                  </tr>
                  <%
                      }
                    } else {
                  %>
                  <tr>
                    <td colspan="9" class="text-center py-4 text-muted">
                      No reports found.
                    </td>
                  </tr>
                  <%
                    }
                  %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script 
    src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js">
  </script>
  <script>
  function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const icon = document.getElementById('toggleIcon');

    sidebar.classList.toggle('sidebar-expanded');
    sidebar.classList.toggle('sidebar-collapsed');

    if (sidebar.classList.contains('sidebar-collapsed')) {
      icon.classList.replace('bi-arrow-left-circle', 'bi-arrow-right-circle');
    } else {
      icon.classList.replace('bi-arrow-right-circle', 'bi-arrow-left-circle');
    }
  }

  document.addEventListener('DOMContentLoaded', () => {
    const sidebar = document.getElementById('sidebar');
    if (!sidebar.classList.contains('sidebar-expanded') &&
        !sidebar.classList.contains('sidebar-collapsed')) {
      sidebar.classList.add('sidebar-expanded');
    }
  });
</script>
</body>
</html>