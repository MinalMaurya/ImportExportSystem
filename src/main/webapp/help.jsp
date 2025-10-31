<%@ page session="true" contentType="text/html; charset=UTF-8" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <title>Help & Support - Import Export</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <style>
    :root {
      --sb-expanded: 250px;
      --sb-collapsed: 80px;
      --nav-height: 50px;
    }

    body {
      background-color: #eef6fa;
      font-family: 'Segoe UI', sans-serif;
      margin: 5;
    }

    .help-container {
      display: flex;
      justify-content: center;
      padding: 70px 20px 30px;
      transition: margin-left 0.3s ease;
    }

    body.sidebar-collapsed .help-container {
      margin-left: var(--sb-collapsed);
    }

    body:not(.sidebar-collapsed) .help-container {
      margin-left: var(--sb-expanded);
    }

    .card-box {
      width: 100%;
      max-width: 950px;
      padding: 40px;
      background: #d9ecf5;
      border-radius: 15px;
      box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
    }

    .card-box h2 {
      color: #007bff;
      font-weight: 600;
      margin-bottom: 25px;
    }

    .help-section {
      margin-bottom: 35px;
    }

    .help-section h4 {
      color: #0056b3;
      margin-bottom: 12px;
    }

    .help-section ul {
      list-style-type: disc;
      padding-left: 25px;
      color: #333;
    }

    .help-section ul li {
      margin-bottom: 10px;
      line-height: 1.6;
    }

    .back-btn {
      text-align: center;
      margin-top: 30px;
    }
  </style>
</head>

<body class="sidebar-collapsed">

<%-- Navbar and Sidebar --%>
<% if ("consumer".equals(role)) { %>
  <jsp:include page="/WEB-INF/fragments/consumer_header.jsp"/>
  <jsp:include page="/WEB-INF/fragments/consumer_sidebar.jsp"/>
<% } else { %>
  <jsp:include page="/WEB-INF/fragments/seller_header.jsp"/>
  <jsp:include page="/WEB-INF/fragments/seller_sidebar.jsp"/>
<% } %>

<!-- Help Content -->
<div class="help-container">
  <div class="card-box">
    <h2><i class="bi bi-question-circle-fill me-2"></i>Help & Support Guide for <%= role.substring(0, 1).toUpperCase() + role.substring(1) %></h2>

    <% if ("consumer".equals(role)) { %>
      <div class="help-section">
        <h4>🛒 1. Browsing Products</h4>
        <ul>
          <li>Navigate to <strong>View Products</strong> from the sidebar.</li>
          <li>Use filters to narrow down your search (by name, category, price).</li>
          <li>Click <strong>Add to Cart</strong> on items you wish to buy.</li>
        </ul>
      </div>

      <div class="help-section">
        <h4>📦 2. Placing Orders</h4>
        <ul>
          <li>Click on the cart icon in the navbar or go to the <strong>Cart</strong> page.</li>
          <li>Adjust quantities if needed and click <strong>Confirm Order</strong>.</li>
          <li>Orders will appear under <strong>My Orders</strong> with current status.</li>
        </ul>
      </div>

      <div class="help-section">
        <h4>🔍 3. Tracking Your Orders</h4>
        <ul>
          <li>Go to <strong>Track Orders</strong> section.</li>
          <li>Enter your Order ID or select from list.</li>
          <li>You'll see a step-by-step status: Requested → Approved → Shipped → Delivered.</li>
        </ul>
      </div>

      <div class="help-section">
        <h4>📝 4. Reporting Product Issues</h4>
        <ul>
          <li>Under <strong>My Orders</strong>, click <strong>Report Issue</strong> if you face problems.</li>
          <li>Provide a description and optional screenshot.</li>
          <li>Track issue progress under <strong>Reported Products</strong>.</li>
        </ul>
      </div>

    <% } else { %>
      <div class="help-section">
        <h4>📦 1. Managing Products</h4>
        <ul>
          <li>Go to <strong>Manage Products</strong>.</li>
          <li>Use <strong>Add Product</strong> to list new items with name, price, stock, and location.</li>
          <li>Edit or Delete products anytime.</li>
        </ul>
      </div>

      <div class="help-section">
        <h4>🛍️ 2. Handling Orders</h4>
        <ul>
          <li>In <strong>View Orders</strong>, you can see customer requests.</li>
          <li>Use dropdowns to update status: Requested → Approved → Shipped → Delivered.</li>
          <li>Use tracking info and notes for each shipment.</li>
        </ul>
      </div>

      <div class="help-section">
        <h4>📊 3. Analyzing Sales</h4>
        <ul>
          <li>Click on <strong>Sales Analysis</strong> in the sidebar.</li>
          <li>Filter results by monthly, yearly, or custom date range.</li>
          <li>View charts of top-selling products, total revenue, and profits.</li>
        </ul>
      </div>

      <div class="help-section">
        <h4>🛠️ 4. Handling Reports</h4>
        <ul>
          <li>Go to <strong>Reported Products</strong> to view consumer complaints.</li>
          <li>Mark issues as resolved or update product info accordingly.</li>
        </ul>
      </div>
    <% } %>

    <div class="back-btn">
      <a href="settings.jsp" class="btn btn-outline-primary">
        <i class="bi bi-arrow-left-circle me-1"></i> Back to Settings
      </a>
    </div>
  </div>
</div>

<!-- Sidebar toggle -->
<script>
  const toggleBtn = document.querySelector('#sidebarToggle');
  toggleBtn?.addEventListener('click', () => {
    document.body.classList.toggle('sidebar-collapsed');
  });
</script>

</body>
</html>