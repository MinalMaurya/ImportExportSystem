<%@ page session="true" contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.OrderPojo,java.text.SimpleDateFormat" %>
<%
  // security guard
  String role = (String) session.getAttribute("role");
  if (!"seller".equals(role)) {
    response.sendRedirect("login.jsp");
    return;
  }
  List<OrderPojo> orders = (List<OrderPojo>) request.getAttribute("orders");
  SimpleDateFormat dateOnly = new SimpleDateFormat("dd-MM-yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Seller – View Orders</title>

  <!-- Bootstrap + icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/>

  <style>
:root {
  --sb-expanded-width: 250px;
  --sb-collapsed-width:  80px;
}
#sidebar {
  transition: width .3s ease;
}
.sidebar-text {
  transition: opacity .2s ease;
}
#sidebar.sidebar-collapsed .sidebar-text {
  opacity: 0;
}
#sidebar.sidebar-expanded  .sidebar-text {
  opacity: 1;
}

body.sidebar-collapsed .main-content {
  margin-left: var(--sb-collapsed-width) !important;
}

    body {
      font-family: 'Nunito', sans-serif;
      background: #f4f7fa;
      overflow-x: hidden;
    }
.main-content {
  transition: margin-left .3s ease;
  margin-left: var(--sb-expanded-width);
  padding: 1.5rem;
  margin-top: 56px;
}

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
  background-color: #fffbcc !important;
  border-color:     #fff7a6 !important;
  color:            #000   !important;
}

.orders-table .badge-status.bg-info {
  background-color: #dceeff !important;
  border-color:     #bddcff !important;
  color:            #000   !important;
}

.orders-table .badge-status.bg-warning {
  background-color: #fff9b2 !important;
  border-color:     #fff48c !important;
  color:            #000   !important;
}

.orders-table .badge-status.bg-danger {
  background-color: #ffdddd !important;
  border-color:     #ffbdbd !important;
  color:            #000   !important;
}
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
  background-color: #e6f4ea; 
  color: #1f5233;            
  border: 1px solid #c3e6cb;
  transition: background-color .2s ease;
}
.orders-table td form .btn:hover {
  background-color: #d4edda;
}
  </style>
</head>
<body>

  <!-- header + sidebar -->
  <jsp:include page="/WEB-INF/fragments/seller_header.jsp"/>
  <jsp:include page="/WEB-INF/fragments/seller_sidebar.jsp"/>
  
  <div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
    <h2 class="fw-bold mb-0">Your Orders</h2>
    <div>
      <!-- Back to Dashboard -->
      <a href="SellerDash.jsp" class="btn btn-dashboard me-2">
        <i class="bi bi-arrow-left-circle"></i> Dashboard
      </a>
      <!-- Go to Product Management -->
      <a href="ProductController?seller_port_id=<%= session.getAttribute("seller_port_id") %>"
         class="btn btn-dashboard">
        <i class="bi bi-box-seam"></i> Products
      </a>
    </div>
  </div>

    <table class="orders-table">
      <thead>
        <tr>
          <th>Order ID</th>
          <th>Consumer</th>
          <th>location</th>
          <th>Product</th>
          <th>Qty</th>
          <th>Ordered On</th>
          <th>Total</th>
          <th>Status</th>
          <th class="text-center">Action</th>
        </tr>
      </thead>
      <tbody>
  <% if (orders != null && !orders.isEmpty()) {
       for (OrderPojo o : orders) {
         String status = o.getStatus();
  %>
    <tr>
      <td><%= o.getOrderId() %></td>
      <td><%= o.getConsumerPortId() %></td>
      <td><%= o.getConsumerLocation() %></td>
      <td><%= o.getProductName() %></td>
      <td><%= o.getQuantity() %></td>
      <td><%= dateOnly.format(o.getOrderDate()) %></td>
      <td>₹<%= o.getTotalAmount() %></td>
      <td>
        <span class="badge-status
          <%= "Cancelled".equals(status)       ? "bg-danger"
             : "Delivered".equals(status)       ? "bg-success"
             : "Out for Delivery".equals(status)? "bg-warning text-dark"
             : "Shipped".equals(status)         ? "bg-info text-white"
             : "bg-secondary text-white"
          %>">
          <%= status %>
        </span>
      </td>
      <td class="text-center">
        <% if ("Cancelled".equals(status)) { %>
          <!-- Already cancelled → no updates allowed -->
          <button class="btn btn-sm btn-secondary" disabled>
            <i class="bi bi-x-circle me-1"></i>Cancelled
          </button>
        <% } else { %>
      <form method="post"
      action="<%= request.getContextPath() %>/OrderServlet"
      class="d-flex align-items-center justify-content-center m-0">
  <input type="hidden" name="action"  value="updateOrderStatus"/>
  <input type="hidden" name="orderId" value="<%= o.getOrderId() %>"/>

  <select name="newStatus"
          class="form-select form-select-sm me-2"
          required>
    <option value="" disabled selected>Change…</option>
    <option value="shipped">Shipped</option>
    <option value="out for delivery">Out for Delivery</option>
    <option value="delivered">Delivered</option>
  </select>

  <button type="submit" class="btn btn-sm btn-primary">
    Update
  </button>
</form>
 

        <% } %>
      </td>
    </tr>
  <%   }
     } else { %>
    <tr>
      <td colspan="8" class="text-center py-4 text-muted">
        No orders found.
      </td>
    </tr>
  <% } %>
</tbody>
    </table>
  </div>

  <!-- Bootstrap JS, then our sidebar‐toggle hook -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
  function toggleSidebar() {
    const sb       = document.getElementById('sidebar'),
          main     = document.querySelector('.main-content'),
          labels   = sb.querySelectorAll('.sidebar-text'),
          icon     = document.getElementById('toggleIcon');

    // Are we collapsed now?
    const isCollapsed = sb.style.width === '80px';

    // Toggle width
    sb.style.width = isCollapsed ? '250px' : '80px';
    // Shift main content
    main.style.marginLeft = sb.style.width;

    // Show or hide the labels
    labels.forEach(el => el.style.display = isCollapsed ? 'inline' : 'none');

    // Flip the toggle‐icon
    icon.classList.toggle('bi-arrow-left-circle',  !isCollapsed);
    icon.classList.toggle('bi-arrow-right-circle', isCollapsed);
  }

  // On page load, initialize to expanded
  document.addEventListener('DOMContentLoaded', () => {
    const sb   = document.getElementById('sidebar'),
          main = document.querySelector('.main-content'),
          labels = sb.querySelectorAll('.sidebar-text'),
          icon = document.getElementById('toggleIcon');

    sb.style.width       = '250px';
    main.style.marginLeft= '250px';
    labels.forEach(el => el.style.display = 'inline');
    icon.classList.add('bi-arrow-left-circle');
  });
</script>
</body>
</html>