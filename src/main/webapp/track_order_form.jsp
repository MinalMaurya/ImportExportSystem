<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.OrderPojo" %>
<%
  OrderPojo tracked = (OrderPojo) request.getAttribute("trackedOrder");
  String error      = (String)   request.getAttribute("error");
  // (Optional) If you want to show recent orders at bottom:
  List<OrderPojo> recent = (List<OrderPojo>) request.getAttribute("orderList");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Track Order</title>
  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
        rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css"
        rel="stylesheet">
 <link
    href="<%=request.getContextPath()%>/css/sidebar.css"
    rel="stylesheet"
  />
  <style>
    :root {
      --sb-expanded: 250px;
      --sb-collapsed:  80px;
    }
  
    .main-content {
      flex:1;
      margin-left: var(--sb-expanded);
      padding:5rem;
      transition:margin-left .3s;
    }
    #sidebar.sidebar-collapsed ~ .main-content {
      margin-left: var(--sb-collapsed);
    }
    #sidebar.sidebar-collapsed .sidebar-text {
  display: none !important;
}

    /* Search bar */
    .search-bar .form-control {
      border-top-right-radius:0; border-bottom-right-radius:0;
    }
    .search-bar .btn { border-top-left-radius:0; border-bottom-left-radius:0; }

    /* Detail card */
    .detail-card {
      border-radius:1rem;
      box-shadow:0 4px 12px rgba(0,0,0,0.05);
    }

    /* Timeline */
    .timeline {
      display:flex; justify-content:space-between;
      margin-top:4rem;
    }
    .timeline .step {
      text-align:center; flex:1;
    }
    .timeline .step:not(:last-child)::after {
      content:''; display:block;
      height:4px; background:#ddd;
      position:relative; top:-1.5rem; z-index:0;
      margin:0 -50% 0 0;
    }
    .timeline .step.completed i {
      color:#4dabf7;
    }
    .timeline .step.completed .step-label {
      color:#333; font-weight:600;
    }
    .timeline .step i {
      font-size:2rem; color:#bbb; margin-bottom:.5rem;
      z-index:1; position:relative;
    }
    .timeline .step .step-label {
      font-size:.9rem; color:#777;
    }

    /* Recent orders cards */
    .recent-card {
      border-radius:.75rem; overflow:hidden;
      box-shadow:0 2px 8px rgba(0,0,0,0.04);
      margin-bottom:1rem;
    }
  </style>
</head>
<body>

   <jsp:include page="/WEB-INF/fragments/consumer_header.jsp" />

  <div class="main-wrapper">
    <!-- sidebar -->
    <jsp:include page="/WEB-INF/fragments/consumer_sidebar.jsp"/>

    <div class="main-content">
      <h2 class="mb-4">Track Order</h2>

      <!-- Search form -->
      <form method="get" action="OrderServlet" class="search-bar d-flex mb-4">
        <input type="hidden" name="action" value="track"/>
        <input type="number" name="orderId" class="form-control"
               placeholder="Enter your Order ID" required>
        <button class="btn btn-primary">Search</button>
      </form>

      <% 
  String orderParam = request.getParameter("orderId");
%>
<% if (orderParam == null || orderParam.isEmpty()) { %>
  <!-- Shown before any search is performed -->
  <div class="alert alert-secondary text-center">
    🔍 Search by Order ID to get your order status.
  </div>
<% } else if (error != null) { %>
  <!-- Only shown if servlet set an error (e.g. invalid ID) -->
  <div class="alert alert-warning text-dark">
    ⚠️ <%= error %>
  </div>
<% } %>

      <!-- If we have a tracked order, show details & timeline -->
      <% if (tracked != null) { %>
        <div class="card detail-card mb-4">
          <div class="card-body">
            <div class="row">
              <div class="col-md-4"><strong>Order ID:</strong> <%= tracked.getOrderId() %></div>
              <div class="col-md-4"><strong>Product:</strong> <%= tracked.getProductName() %></div>
              <div class="col-md-4"><strong>Qty:</strong> <%= tracked.getQuantity() %></div>
            </div>
            <div class="row mt-2">
              <div class="col-md-4"><strong>Ordered On:</strong> <%= tracked.getOrderDate() %></div>
              <div class="col-md-4"><strong>Total:</strong> ₹<%= tracked.getTotalAmount() %></div>
              <div class="col-md-4"><strong>Status:</strong>
                <span class="badge 
                  <%= tracked.getStatus().equals("Cancelled")    ? "bg-danger" :
                       tracked.getStatus().equals("Delivered")    ? "bg-success" :
                       "bg-info" %>">
                  <%= tracked.getStatus() %>
                </span>
              </div>
            </div>
          </div>
        </div>

        <% if ("Delivered".equals(tracked.getStatus())) { %>
          <div class="alert alert-success text-center">
            <i class="bi bi-check-circle-fill fs-1"></i>
            <h4 class="mt-2">Your order has been delivered!</h4>
          </div>
        <% } else { 
            String st = tracked.getStatus();
            boolean placed = true;
            boolean shipped = "Shipped".equals(st) || "Out for Delivery".equals(st) || "Delivered".equals(st);
            boolean outfd   = "Out for Delivery".equals(st) || "Delivered".equals(st);
            boolean delivered = "Delivered".equals(st);
        %>
        <!-- Simple timeline -->
        <div class="timeline">
          <div class="step <%= placed    ? "completed" : "" %>">
            <i class="bi bi-receipt"></i>
            <div class="step-label">Placed</div>
          </div>
          <div class="step <%= shipped   ? "completed" : "" %>">
            <i class="bi bi-truck"></i>
            <div class="step-label">Shipped</div>
          </div>
          <div class="step <%= outfd     ? "completed" : "" %>">
            <i class="bi bi-box-seam"></i>
            <div class="step-label">Out for Delivery</div>
          </div>
          <div class="step <%= delivered ? "completed" : "" %>">
            <i class="bi bi-door-open"></i>
            <div class="step-label">Delivered</div>
          </div>
        </div>
        <% } %>
      <% } %>

      <!-- Always show recent orders -->
<% if (recent != null && !recent.isEmpty()) { %>
  <h4 class="mt-5 mb-3">Your Recent Orders</h4>
  <% for (OrderPojo o : recent) { %>
    <div class="card recent-card p-3">
      <div class="d-flex justify-content-between">
        <div>
          <i class="bi bi-receipt me-2"></i>
          <strong>#<%= o.getOrderId() %></strong> – <%= o.getProductName()%>
        </div>
        <a href="OrderServlet?action=track&orderId=<%=o.getOrderId()%>"
           class="btn btn-sm btn-outline-primary">
          Track Again
        </a>
      </div>
    </div>
  <% } %>
<% } %>


    </div>
  </div>

  <!-- Bootstrap JS bundle -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    function toggleSidebar(){
      const sb = document.getElementById('sidebar'),
            ic = document.getElementById('toggleIcon');
      sb.classList.toggle('sidebar-collapsed');
      ic.classList.toggle('bi-arrow-left-circle');
      ic.classList.toggle('bi-arrow-right-circle');
    }
    document.addEventListener('DOMContentLoaded',()=>{
      const sb=document.getElementById('sidebar');
      if(!sb.classList.contains('sidebar-collapsed')){
        sb.classList.add('sidebar-expanded');
      }
    });
  </script>
</body>
</html>