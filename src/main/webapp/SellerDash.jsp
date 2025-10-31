<%@ page pageEncoding="UTF-8"
         contentType="text/html; charset=UTF-8"
         session="true"
         language="java"
         import="
           java.util.List,
           java.util.ArrayList,
           java.math.BigDecimal,
           Operation.ProductOperations,
           Implementor.ProductImplementor,
           model.Product_pojo,
           Operation.OrderOperation,
           Implementor.OrderImp,
           model.OrderPojo,
           Operation.ReportedProductOperations,
           Implementor.ReportedProductImplementor,
           model.ReportedProductPojo
         " %>
<%
  // 1) Guard: only sellers may see this page
  String role     = (String) session.getAttribute("role");
  String username = (String) session.getAttribute("username");
  if (!"seller".equals(role) || username == null) {
      response.sendRedirect(request.getContextPath() + "/login.jsp");
      return;
  }

  // --- Fetch total products for this seller ---
  ProductOperations prodOp = new ProductImplementor();
  List<Product_pojo> products = prodOp.getAllProductsBySeller(username);
  int totalProducts = products.size();

//--- Fetch total orders & compute total sales (only delivered orders) ---
OrderOperation orderOp = new OrderImp();
List<OrderPojo> orders = orderOp.getOrdersBySeller(username);
int totalOrders = orders.size();
BigDecimal totalSales = BigDecimal.ZERO;
for (OrderPojo o : orders) {
   if ("Delivered".equalsIgnoreCase(o.getStatus())) {
       totalSales = totalSales.add(o.getTotalAmount());
   }
}
  // --- Fetch reported products count ---
  ReportedProductOperations reportOp = new ReportedProductImplementor();
  List<ReportedProductPojo> reports = reportOp.getSellerReports(username);
  int reportedCount = reports.size();

  // --- Build list of new (Placed) orders, limit to 5 ---
  List<OrderPojo> newOrdersList = new ArrayList<OrderPojo>();
  for (OrderPojo o : orders) {
      if ("Placed".equalsIgnoreCase(o.getStatus())) {
          newOrdersList.add(o);
      }
  }
  if (newOrdersList.size() > 5) {
      newOrdersList = newOrdersList.subList(0, 5);
  }

  // --- Build low-stock list (<=10) ---
  List<Product_pojo> lowStockList = new ArrayList<Product_pojo>();
  for (Product_pojo p : products) {
      if (p.getQuantity() <= 10) {
          lowStockList.add(p);
      }
  }
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Seller Dashboard</title>

  <!-- Bootstrap CSS & Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/>

  <!-- Sidebar & Dashboard CSS -->
  <link href="<%= request.getContextPath() %>/css/sidebar.css" rel="stylesheet"/>
  <style>
  
    /* Stats & Cards */
    .stats-row .card,
    .recent-orders .card,
    .low-stock .card {
      position: relative;
      border: none; border-radius: 1rem; overflow: hidden;
      box-shadow: 0 4px 12px rgba(0,0,0,0.05);
      background: linear-gradient(135deg,#fff 0%,#f0f4ff 100%);
      transition: transform .3s, box-shadow .3s;
    }
    .stats-row .card:hover,
    .recent-orders .card:hover,
    .low-stock .card:hover {
      transform: translateY(-6px);
      box-shadow: 0 12px 24px rgba(0,0,0,0.1);
    }
    .stats-row .card::before,
    .recent-orders .card::before,
    .low-stock .card::before {
      content: ''; position: absolute; top:0; left:0;
      width:4px; height:100%; background:transparent;
      transition: background .3s;
    }
    .stats-row .card:hover::before { background:#1f3c88; }
    /* low-stock uses red stripe on hover */
    .low-stock .card:hover::before { background:#ef4444; }

    /* Icon circle */
    .stats-row .card-body .bi {
      width:3.5rem; height:3.5rem; font-size:1.75rem;
      display:flex;align-items:center;justify-content:center;
      background:rgba(31,60,136,0.1);border-radius:50%;
      margin:0 auto .75rem;transition:background .3s;
    }
    .stats-row .card:hover .bi { background:#1f3c88; color:#fff; }

    /* Recent orders header */
    .recent-orders .card-header,
    .low-stock .card-header {
      background:linear-gradient(135deg,#fff 0%,#f0f4ff 100%);
      border-bottom:none; font-weight:600;
    }
    .recent-orders table tbody tr:hover {
      background:rgba(31,60,136,0.05);
    }
    .low-stock .list-group-item {
      border:none; display:flex;justify-content:space-between;
      padding:.75rem 1rem;transition:background .3s;
    }
    .low-stock .list-group-item:hover { background:rgba(239,68,68,0.05); }
    .low-stock .badge { font-weight:600; }
  </style>
</head>
<body>

  <!-- Header & Sidebar -->
  <jsp:include page="/WEB-INF/fragments/seller_header.jsp"/>
  <jsp:include page="/WEB-INF/fragments/seller_sidebar.jsp"/>

  <!-- Main Content -->
  <div class="main-content" style="margin-left:250px; padding:1rem; margin-top:56px;">
    <div class="container-fluid py-4">

      <!-- Top stats cards -->
      <div class="row stats-row gy-4 mb-5">
        <!-- Total Products -->
        <div class="col-6 col-md-3">
          <div class="card text-center p-3 position-relative">
            <div class="card-body">
              <i class="bi bi-box-seam text-primary"></i>
              <h4><%= totalProducts %></h4>
              <p class="text-muted small text-uppercase">Total Products</p>
              <a href="<%= request.getContextPath() %>/ProductController?seller_port_id=<%= username %>"
                 class="stretched-link"></a>
            </div>
          </div>
        </div>
        <!-- Total Orders -->
        <div class="col-6 col-md-3">
          <div class="card text-center p-3 position-relative">
            <div class="card-body">
              <i class="bi bi-cart text-success"></i>
              <h4><%= totalOrders %></h4>
              <p class="text-muted small text-uppercase">Total Orders</p>
              <a href="<%= request.getContextPath() %>/OrderServlet?action=viewSellerOrders"
                 class="stretched-link"></a>
            </div>
          </div>
        </div>
        <!-- Total Sales -->
        <div class="col-6 col-md-3">
          <div class="card text-center p-3 position-relative">
            <div class="card-body">
              <i class="bi bi-currency-rupee text-warning"></i>
              <h4>₹<%= totalSales %></h4>
              <p class="text-muted small text-uppercase">Total Sales</p>
              <a href="<%= request.getContextPath() %>/OrderServlet?action=viewSellerOrders"
                 class="stretched-link"></a>
            </div>
          </div>
        </div>
        <!-- Reported Products -->
        <div class="col-6 col-md-3">
          <div class="card text-center p-3 position-relative">
            <div class="card-body">
              <i class="bi bi-flag-fill text-danger"></i>
              <h4><%= reportedCount %></h4>
              <p class="text-muted small text-uppercase">Reported Products</p>
              <a href="<%= request.getContextPath() %>/reports?user_type=seller&port_id=<%= username %>"
                 class="stretched-link"></a>
            </div>
          </div>
        </div>
      </div>

      <!-- New Orders & Low-Stock Panels -->
      <div class="row gy-4">
        <!-- New Orders (latest 5) -->
        <div class="col-lg-8 recent-orders">
          <div class="card h-100">
            <div class="card-header bg-white border-0">
              <h5 class="mb-0"><i class="bi bi-bell-fill text-info me-2"></i>New Orders</h5>
            </div>
            <div class="table-responsive">
              <table class="table mb-0">
                <thead class="table-light">
                  <tr><th>Order ID</th><th>Product</th><th>Qty</th><th>Amount</th></tr>
                </thead>
                <tbody>
                  <%
                    if (newOrdersList.isEmpty()) {
                  %>
                  <tr>
                    <td colspan="4" class="text-center text-muted">No new orders found</td>
                  </tr>
                  <%
                    } else {
                      for (OrderPojo o : newOrdersList) {
                  %>
                  <tr>
                    <td>#ORD-<%= o.getOrderId() %></td>
                    <td><%= o.getProductName() %></td>
                    <td><%= o.getQuantity() %></td>
                    <td>₹<%= o.getTotalAmount() %></td>
                  </tr>
                  <%
                      }
                    }
                  %>
                </tbody>
              </table>
            </div>
            <div class="card-footer text-end bg-white border-0">
              <a href="<%= request.getContextPath() %>/OrderServlet?action=viewSellerOrders"
                 class="btn btn-sm btn-primary">View More</a>
            </div>
          </div>
        </div>
        <!-- Low-Stock Alerts -->
        <div class="col-lg-4 low-stock">
          <div class="card h-100">
            <div class="card-header">
              <h5><i class="bi bi-exclamation-triangle-fill text-danger me-2"></i>Low Stock</h5>
            </div>
            <ul class="list-group list-group-flush">
              <%
                if (lowStockList.isEmpty()) {
              %>
              <li class="list-group-item text-center text-muted">No low-stock products</li>
              <%
                } else {
                  for (Product_pojo p : lowStockList) {
                    int qty = p.getQuantity();
                    String badgeCls = (qty <= 5) ? "bg-danger" : "bg-warning";
              %>
              <li class="list-group-item d-flex justify-content-between align-items-center">
                <span><%= p.getProductName() %></span>
                <span class="badge <%= badgeCls %>"><%= qty %> left</span>
              </li>
              <%
                  }
                }
              %>
              <li class="list-group-item text-center">
                <a href="<%= request.getContextPath() %>/ProductController?seller_port_id=<%= username %>"
                   class="small">Manage Products</a>
              </li>
            </ul>
          </div>
        </div>
      </div>

    </div>
  </div>

  <!-- Bootstrap JS -->
  <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.min.js"></script>
</body>
</html>