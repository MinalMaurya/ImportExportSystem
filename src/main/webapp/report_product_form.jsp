<!-- File: report_product_form.jsp -->
<%@ page session="true" contentType="text/html;charset=UTF-8" language="java" %>
<%
  String consumerPort = (String) session.getAttribute("username");
  if (consumerPort == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }

  String orderId      = request.getParameter("order_id");
  String prodId       = request.getParameter("product_id");
  String productName  = request.getParameter("product_name");
  String sellerPortId = request.getParameter("seller_port_id");
  String reportId = request.getParameter("report_id");
  boolean isEdit = reportId != null && !reportId.trim().isEmpty();

  String issueType = request.getParameter("issue_type");
 
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>Report a Product Issue</title>
  <link
    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
    rel="stylesheet"/>
     <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/>
     <link
    href="<%=request.getContextPath()%>/css/sidebar.css"
    rel="stylesheet"
  />
  <style>
  
  /* Main content shift */
  .main-content {
    margin-left: var(--sb-expanded);
    transition: margin-left 0.3s ease;
  }
  #sidebar.sidebar-collapsed ~ .main-content {
    margin-left: var(--sb-collapsed);
  }
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }
  body {
    font-family: 'Nunito', sans-serif;
    background: linear-gradient(135deg, #f4f7fa, #e2e8f0);
    overflow-x: hidden;
  }

  /* Navbar */
  .navbar {
    background: rgba(255,255,255,0.8);
    backdrop-filter: blur(6px);
    z-index: 1040;
  }

  /* Sidebar layout */
  .main-wrapper {
    display: flex;
    margin-top: 56px; /* height of navbar */
  }
  
  /* Main content shifting */
  .main-content {
    flex: 1;
    margin-left: var(--sb-expanded);
    padding: 2rem;
    transition: margin-left 0.3s ease;
  }
  

  /* Report card styling */
  .report-card {
    max-width: 600px;
    margin: 3rem auto;
    padding: 2rem;
    border-radius: 1rem;
    background: rgba(255,255,255,0.8);
    backdrop-filter: blur(8px);
    box-shadow: 0 8px 32px rgba(0,0,0,0.1);
  }

  /* Submit button */
  .btn-submit {
    background: #15aabf;
    color: #fff;
    padding: 0.6rem 1.4rem;
    border: none;
    border-radius: 0.5rem;
    font-weight: 600;
    transition: background 0.2s, transform 0.2s;
  }
  .btn-submit:hover {
    background: #1f3c88;
    transform: translateY(-2px);
  }
</style>
</head>
<body>
  <jsp:include page="/WEB-INF/fragments/consumer_header.jsp"/>
  <div class="main-wrapper">
    <!-- Sidebar -->
    <div id="sidebar" class="sidebar-expanded">
      <jsp:include page="/WEB-INF/fragments/consumer_sidebar.jsp"/>
    </div>
    

<!-- Content -->
<div class="main-content">
  <div class="report-card">
    <h2 class="mb-4 text-center text-primary">Report a Product Issue</h2>
    <form action="<%= request.getContextPath() %>/reports" method="post">
      <input type="hidden" name="action" value="<%= isEdit ? "update" : "add" %>"/>

      <% if (isEdit) { %>
        <input type="hidden" name="report_id" value="<%= reportId %>"/>
        <input type="hidden" name="order_id" value="<%= orderId %>"/>
        <input type="hidden" name="product_name" value="<%= productName %>"/>
      <% } %>

      <input type="hidden" name="consumer_port_id" value="<%= consumerPort %>"/>
      <input type="hidden" name="seller_port_id" value="<%= sellerPortId %>"/>
      <input type="hidden" name="product_id" value="<%= prodId %>"/>

     <% if (isEdit) { %>
  <input type="hidden" name="report_id" value="<%= reportId %>"/>
  <input type="hidden" name="order_id" value="<%= orderId %>"/>
  <input type="hidden" name="product_name" value="<%= productName %>"/>

  <div class="mb-3">
    <label class="form-label">Report ID</label>
    <input type="text" class="form-control" value="<%= reportId %>" readonly />
  </div>

  <div class="mb-3">
    <label class="form-label">Product Name</label>
    <input type="text" class="form-control" value="<%= productName %>" readonly />
  </div>
<% } else { %>
  <div class="mb-3">
    <label class="form-label">Order ID</label>
    <input type="text"
           name="order_id"
           class="form-control"
           value="<%= orderId != null ? orderId : "" %>"
           placeholder="Enter your order ID"
           required />
  </div>

  <div class="mb-3">
    <label class="form-label">Product Name</label>
    <input type="text"
           name="product_name"
           class="form-control"
           value="<%= productName != null ? productName : "" %>"
           placeholder="Enter the product name"
           required />
  </div>
<% } %>

      <!-- Issue Type selector -->
      <div class="mb-4">
        <label for="issueType" class="form-label">Issue Type</label>
        <select id="issueType" name="issue_type" class="form-select" required>
          <option value="" disabled <%= (issueType == null || issueType.isEmpty()) ? "selected" : "" %>>— select —</option>
          <option value="damaged" <%= "damaged".equals(issueType) ? "selected" : "" %>>Damaged</option>
          <option value="wrong_product" <%= "wrong_product".equals(issueType) ? "selected" : "" %>>Wrong Product</option>
          <option value="delay" <%= "delay".equals(issueType) ? "selected" : "" %>>Delay</option>
          <option value="still_not_received" <%= "still_not_received".equals(issueType) ? "selected" : "" %>>Still Not Received</option>
          <option value="missing" <%= "missing".equals(issueType) ? "selected" : "" %>>Missing</option>
        </select>
      </div>

      <div class="text-center">
        <button type="submit" class="btn-submit">
          <i class="bi bi-flag-fill me-1"></i> Submit Report
        </button>
      </div>
    </form>
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
</script>
</body>
</html>