<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.OrderPojo,java.net.URLEncoder,java.text.SimpleDateFormat" %>
<%
    // Retrieved by OrderServlet under "orderList"
    List<OrderPojo> orders = (List<OrderPojo>) request.getAttribute("orderList");
    if (orders == null) {
        orders = new java.util.ArrayList<>();
    }
    SimpleDateFormat dateOnly = new SimpleDateFormat("dd-MM-yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>My Orders</title>

  <!-- Bootstrap CSS + Icons -->
  <link
    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
    rel="stylesheet"
  >
   <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/>

  <!-- ======= EMBEDDED STYLES ======= -->
  <style>
   :root {
  --sb-expanded: 250px;
  --sb-collapsed:  80px;
}
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}
body {
  background: #eef2f7;
  font-family: 'Nunito', sans-serif;
  color: #333;
  overflow-x: hidden;
}
/* Wrapper under the fixed header */
.main-wrapper {
  display: flex;
  width: 100%;
  margin-top: 56px;
}
/* Sidebar */
#sidebar {
  position: fixed;
  top: 56px;
  bottom: 0;
  width: var(--sb-expanded);
  background: #2c3e50;
  transition: width .3s ease;
  overflow-x: visible;
  z-index: 1030;
}
#sidebar.sidebar-collapsed {
  width: var(--sb-collapsed);
}
/* Main content, shifts with sidebar */
.main-content {
  flex: 1;
  margin-left: var(--sb-expanded);
  padding: 1.5rem;
  transition: margin-left .3s ease;
}
#sidebar.sidebar-collapsed ~ .main-content {
  margin-left: var(--sb-collapsed);
}

/* Badges */
.badge {
  font-size: .85rem;
  font-weight: 600;
  border-radius: .5rem;
  padding: .4em .75em;
  color: #000 !important;
}
.badge-placed {
  background: #ffe8a1;
}
.badge-shipped {
    background: #ffe8a1;
}
.badge-out {
    background: #ffe8a1;
}
.badge-delivered {
  background: #d3f9d8;
}
.badge-cancelled {
  background: #ffdada;
}

/* Buttons */
.btn {
  font-weight: 600;
  border-radius: .5rem;
  padding: .5rem .75rem;
  transition: transform .2s, box-shadow .2s;
}
.btn-info {
  background-color: #e8f4ff !important;  /* very pale blue */
  color: #084298;
  border: 1px solid #c4ddff;
}
.btn-info:hover {
  background-color: #d0e4ff !important;
}

/* even lighter “Cancel” button */
.btn-warning {
  background-color: #fffde6 !important;  /* very pale yellow */
  color: #664d03;
  border: 1px solid #fff4a3;
}
.btn-warning:hover {
  background-color: #fff9cc !important;
}

/* even lighter “Report Issue” button */
.btn-danger {
  background-color: #fff2f2 !important;  /* very pale red */
  color: #842029;
  border: 1px solid #f9d6d6;
}
.btn-danger:hover {
  background-color: #fce6e6 !important;
}
/* “View Products” button */
.btn-view-products {
  display: inline-flex;
  align-items: center;
  gap: .5rem;
  background-color: #d1e7dd;
  color: #0f5132;
  border: 1px solid #a3cfbb;
  border-radius: .5rem;
  padding: .6rem 1.2rem;
  margin-top: 1.5rem;
  transition: background .2s, transform .2s;
}
.btn-view-products:hover {
  background-color: #bcd0c7;
}

/* base icon-button */
.btn-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 2.4rem;
  height: 2.4rem;
  border-radius: .5rem;
  margin-right: .5rem;
  transition: background .2s, color .2s;
}

/* TRACK: pale-blue box, blue icon */
.btn-icon.track {
  background: #d0e2ff;
  border: 1px solid #93c5fd;
  color:      #1e3a8a;
}
.btn-icon.track:hover {
  background: #b8c9ff;
}

/* REPORT: pale-red box, red icon */
.btn-icon.report {
  background: #ffe2e2;
  border: 1px solid #f5a3a3;
  color:      #991b1b;
}
.btn-icon.report:hover {
  background: #ffcccc;
}

/* CANCEL: pale-yellow box, orange icon */
.btn-icon.cancel {
  background: #fff9db;
  border: 1px solid #ffeea3;
  color:      #92400e;
}
.btn-icon.cancel:hover {
  background: #fff2b8;
}
   /* ------------ Table styling ------------ */
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
  background: linear-gradient(135deg, #2c3e50  90%) !important;
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

  <!-- include your fixed header (with the toggle button) -->
  <jsp:include page="/WEB-INF/fragments/consumer_header.jsp"/>

  <div class="main-wrapper">
    <!-- include your sidebar (must have id="sidebar") -->
    <jsp:include page="/WEB-INF/fragments/consumer_sidebar.jsp"/>

    <!-- this is the part that shifts left/right -->
    <div class="main-content">
      <h2 class="mb-4">My Orders</h2>
      <table class="orders-table">
        <thead >
          <tr>
            <th>Order ID</th>
            <th>Product</th>
            <th>Qty</th>
            <th>Ordered On</th>
            <th>Status</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
  <% for (OrderPojo o : orders) {
       String status = o.getStatus();

    	     // ← Define oid, prodName, sellerId _here_:
    	     String oid      = String.valueOf(o.getOrderId());
    	     String prodName = URLEncoder.encode(o.getProductName(), "UTF-8");
    	     String sellerId = o.getSellerPortId();

  %>
    <tr>
      <td data-label="Order ID"><%= o.getOrderId() %></td>
      <td data-label="Product"><%= o.getProductName() %></td>
      <td data-label="Qty"><%= o.getQuantity() %></td>
      <td data-label="Ordered On"><%= dateOnly.format(o.getOrderDate()) %></td>
      <td data-label="Status">
        <% String st = status.toLowerCase(); %>
        <span class="badge badge-<%= st %>"><%= status %></span>
      </td>
      <td data-label="Action">
  <%
    String statusVal         = o.getStatus();
    boolean placed    = "Placed".equalsIgnoreCase(st);
    boolean shipped   = "Shipped".equalsIgnoreCase(st) 
                     || "Out for Delivery".equalsIgnoreCase(st);
    boolean delivered = "Delivered".equalsIgnoreCase(st);
    boolean cancelled = "Cancelled".equalsIgnoreCase(st);

    String baseReport = "reports?user_type=consumer"
                      + "&amp;port_id=" + session.getAttribute("username")
                      + "&amp;order_id=" + oid
                      + "&amp;product_id=" + o.getProductId();

                      String reportHref = request.getContextPath()
                          + "/report_product_form.jsp"
                          + "?order_id="     + oid
                          + "&product_id="   + o.getProductId()
                          + "&product_name=" + prodName
                          + "&seller_port_id=" + sellerId;
                      %>
  <% if (placed) { %>
    <!-- Placed: Track + Report + Cancel -->
    <a href="OrderServlet?action=track&orderId=<%=oid%>" class="btn-icon track" title="Track">
      <i class="bi bi-truck"></i>
    </a>
  <a
  href="<%=request.getContextPath()%>/report_product_form.jsp?order_id=<%=oid%>&product_id=<%=o.getProductId()%>&product_name=<%=prodName%>&seller_port_id=<%=sellerId%>"
  class="btn-icon report"
  title="Report">
  <i class="bi bi-flag-fill"></i>
</a>
    <form method="post" action="OrderServlet" style="display:inline">
      <input type="hidden" name="action"  value="cancelOrder"/>
      <input type="hidden" name="orderId" value="<%=oid%>"/>
      <button class="btn-icon cancel" title="Cancel">
        <i class="bi bi-x-circle"></i>
      </button>
    </form>

  <% } else if (shipped) { %>
    <!-- Shipped/Out for Delivery: Track + Report -->
    <a href="OrderServlet?action=track&orderId=<%=oid%>" class="btn-icon track" title="Track">
      <i class="bi bi-truck"></i>
    </a>
    <a href="<%=reportHref%>" class="btn-icon report" title="Report">
        <i class="bi bi-flag-fill"></i>
      </a>

  <% } else if (delivered) { %>
    <!-- Delivered: Report only -->
    <a href="<%=reportHref%>" class="btn-icon report" title="Report">
        <i class="bi bi-flag-fill"></i>
      </a>

  <% } else if (cancelled) { %>
    <!-- Cancelled: disabled Track only -->
    <button class="btn-icon track" disabled title="Track">
      <i class="bi bi-truck"></i>
    </button>
  <% } %>
</td>
    </tr>
  <% } %>
</tbody>
      </table>

     <div class="text-center mt-4">
  <a href="OrderServlet?action=viewProducts"
     class="btn-view-products">
    <i class="bi bi-box"></i> View Products
  </a>
</div>
    </div>
  </div>

  <!-- Bootstrap bundle = Popper + JS (for dropdowns) -->
  <script
    src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"
  ></script>
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