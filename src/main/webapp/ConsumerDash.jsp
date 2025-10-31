<%@ page pageEncoding="UTF-8"
          contentType="text/html; charset=UTF-8"
          language="java"
          import="
            java.util.List,
            java.util.ArrayList,
            java.util.Map,
            java.util.HashMap,
            java.util.Collections,
            java.util.Comparator,
            Operation.OrderOperation,
            Implementor.OrderImp,
            model.OrderPojo,
            Operation.ReportedProductOperations,
            Implementor.ReportedProductImplementor,
            model.ReportedProductPojo,
            Operation.ProductOperations,
            Implementor.ProductImplementor,
            model.Product_pojo
          " %>
<%@ page session="true" %>
<%
  String username = (String) session.getAttribute("username");
  if (username == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  // --- Fetch consumer orders & compute stats ---
  OrderOperation orderOp = new OrderImp();
  List<OrderPojo> orders = orderOp.getOrders(username);
  int totalOrders = orders.size(), newOrders = 0, inTransit = 0;
  for (OrderPojo o : orders) {
    String s = o.getStatus();
    if ("Placed".equalsIgnoreCase(s)) newOrders++;
    if ("Shipped".equalsIgnoreCase(s) || "Out for Delivery".equalsIgnoreCase(s)) inTransit++;
  }

  // --- Fetch reported issues count ---
  ReportedProductOperations repOp = new ReportedProductImplementor();
  int totalIssues = repOp.getConsumerReports(username).size();

  // --- Load all products & compute availability ---
  ProductOperations prodOp = new ProductImplementor();
  List<Product_pojo> allProducts = prodOp.getAllProducts();
  int availableCount = allProducts.size();  // <-- new addon

  // --- Build recommendations (up to 6) ---
  List<Product_pojo> recs = new ArrayList<Product_pojo>();
  if (!orders.isEmpty()) {
    String key = orders.get(0).getProductName().toLowerCase();
    for (Product_pojo p : allProducts) {
      if (recs.size() >= 6) break;
      if (p.getProductName().toLowerCase().contains(key)) recs.add(p);
    }
  }
  for (Product_pojo p : allProducts) {
    if (recs.size() >= 6) break;
    if (!recs.contains(p)) recs.add(p);
  }

  // --- Build top-selling for this consumer (their own purchase counts) ---
  Map<Integer,Integer> salesMap = new HashMap<Integer,Integer>();
  for (OrderPojo o : orders) {
    int pid = o.getProductId();
    int prev = salesMap.containsKey(pid) ? salesMap.get(pid) : 0;
    salesMap.put(pid, prev + o.getQuantity());
  }
  List<Product_pojo> sorted = new ArrayList<Product_pojo>(allProducts);
  Collections.sort(sorted, new Comparator<Product_pojo>() {
    public int compare(Product_pojo a, Product_pojo b) {
      return salesMap.getOrDefault(b.getProductId(),0)
           - salesMap.getOrDefault(a.getProductId(),0);
    }
  });
  List<Product_pojo> topSelling = new ArrayList<Product_pojo>();
  for (Product_pojo p : sorted) {
    if (topSelling.size() >= 5) break;
    if (salesMap.containsKey(p.getProductId())) topSelling.add(p);
  }
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Import Export</title>

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet" />

  <style>
  
    
 .dashboard-widgets .card,
.recommend .card,
.activity .card {
  background: linear-gradient(135deg, #ffffff 0%, #f0f4ff 100%);
  border: none;
  border-radius: 1rem;
  box-shadow: 0 8px 20px rgba(0,0,0,0.05);
  transition: transform .3s, box-shadow .3s;
  overflow: hidden;
  position: relative;
}

.dashboard-widgets .card:hover,
.recommend .card:hover,
.activity .card:hover {
  transform: translateY(-6px);
  box-shadow: 0 12px 30px rgba(0,0,0,0.1);
}

/* Accent left-border on hover */
.dashboard-widgets .card::before,
.recommend .card::before,
.activity .card::before {
  content: '';
  position: absolute;
  top: 0; left: 0;
  width: 4px; height: 100%;
  background: transparent;
  border-top-left-radius: 1rem;
  border-bottom-left-radius: 1rem;
  transition: background .3s;
}
.dashboard-widgets .card:hover::before,
.recommend .card:hover::before,
.activity .card:hover::before {
  background: #1f3c88;
}

/* Icon container */
.dashboard-widgets .stat-icon,
.recommend .card .product-icon,
.activity .card .activity-icon {
  width: 4rem; height: 4rem;
  background: rgba(31,60,136,0.1);
  color: #1f3c88;
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  font-size: 1.75rem;
  margin: 0 auto 1rem;
  transition: background .3s, color .3s;
}
.dashboard-widgets .card:hover .stat-icon,
.recommend .card:hover .product-icon,
.activity .card:hover .activity-icon {
  background: #1f3c88;
  color: #fff;
}

/* Numbers and labels */
.dashboard-widgets .stat-number,
.recommend .card .product-name,
.activity .card .activity-text {
  font-weight: 700;
  color: #1e293b;
}
.dashboard-widgets .stat-number {
  font-size: 2.5rem;
  margin-bottom: .25rem;
}
.dashboard-widgets .stat-label,
.recommend .card .product-price,
.activity .card .activity-time {
  color: #475569;
  text-transform: uppercase;
  font-size: .85rem;
  letter-spacing: .5px;
}

  .recommend .card, .dashboard-widgets .card {
    padding: 1rem;
    font-size: .9rem;
  }
  .recommend .product-name { font-size: 1rem; }
  .recommend .product-price { font-size: .85rem; }
  .top-selling .list-group-item {
    padding: .5rem 1rem;
  }

/* Recent activity list items as cards */
.activity .card {
  margin-bottom: 1rem;
  padding: .75rem 1rem;
}
.activity .card .activity-icon {
  margin: 0;
  width: 2rem; height: 2rem;
  font-size: 1.25rem;
}
.activity .card .activity-text {
  display: inline-block;
  margin-left: .5rem;
  font-size: .95rem;
}
.top-selling .list-group-item {
  transition: background .3s;
}
.top-selling .list-group-item:hover {
  background: rgba(31, 60, 136, 0.05);
}
  </style>
</head>
<body>
  <!-- 1) Header -->
  <jsp:include page="/WEB-INF/fragments/consumer_header.jsp"/>

  <!-- 2) Flex wrapper contains sidebar + content -->
  <div class="main-wrapper" style="display:flex; margin-top:56px;">

    <!-- 3) Sidebar (fixed width via your CSS) -->
    <jsp:include page="/WEB-INF/fragments/consumer_sidebar.jsp"/>

    <!-- 4) Main content area -->
    <div class="main-content" style="flex-grow:1; padding:1rem; margin-left:250px;">
      <div class="container-fluid">
        
        <!-- Title Row -->
        <div class="row mb-4">
          <div class="col">
            <h4 class="m-0">Welcome to the Consumer Dashboard</h4>
          </div>
        </div>

        <!-- Stats cards (exactly like your seller) -->
        <div class="row g-4 mb-5 dashboard-widgets">
         <!-- Available Products -->
<div class="col-sm-6 col-md-3">
  <div class="card text-center p-4 position-relative">
    <div class="stat-icon"><i class="bi bi-box-seam"></i></div>
    <div class="stat-number"><%= availableCount %></div>
    <div class="stat-label">Available Products</div>
    <!-- clicking goes to your product listing -->
    <a href="<%= request.getContextPath() %>/OrderServlet?action=viewProducts"
       class="stretched-link"></a>
  </div>
</div>

          <!-- Orders Placed -->
          <div class="col-sm-6 col-md-3">
            <div class="card text-center p-4 position-relative">
              <div class="stat-icon" >
                <i class="bi bi-journal-plus"></i>
              </div>
              <div class="stat-number"><%= totalOrders %></div>
              <div class="stat-label">Orders Placed</div>
              <a href="<%= request.getContextPath() %>/OrderServlet?action=myOrders"
                 class="stretched-link"></a>
            </div>
          </div>

          <!-- In Transit -->
          <div class="col-sm-6 col-md-3">
            <div class="card text-center p-4 position-relative">
              <div class="stat-icon" ">
                <i class="bi bi-truck"></i>
              </div>
              <div class="stat-number"><%= inTransit %></div>
              <div class="stat-label">In Transit</div>
              <a href="<%= request.getContextPath() %>/OrderServlet?action=myOrders"
                 class="stretched-link"></a>
            </div>
          </div>

          <!-- Issues -->
          <div class="col-sm-6 col-md-3">
            <div class="card text-center p-4 position-relative">
              <div class="stat-icon" >
                <i class="bi bi-exclamation-circle"></i>
              </div>
              <div class="stat-number"><%= totalIssues %></div>
              <div class="stat-label">Issues</div>
              <a href="<%= request.getContextPath() %>/reports?user_type=consumer&port_id=<%= username %>"
                 class="stretched-link"></a>
            </div>
          </div>
        </div>

        
<!-- Recommended + Top Selling side-by-side -->
<div class="row g-4 mb-5 dashboard-widgets">

  <!-- Recommended for You (6 cards) -->
  <div class="col-lg-8">
    <h5 class="mb-3 text-secondary">Recommended for You</h5>
    <div class="recommend row g-3">
      <% for (Product_pojo p : recs) { %>
        <div class="col-md-4">
          <div class="card text-center p-3">
            <div class="product-name"><%= p.getProductName() %></div>
            <div class="product-price">
              ₹<%= String.format("%.2f", p.getPrice()) %>
            </div>
            <a href="<%= request.getContextPath() %>/OrderServlet?action=viewProducts"
           class="stretched-link"></a>
          </div>
        </div>
      <% } %>
      <div class="col-12 text-end">
        <a href="<%= request.getContextPath() %>/OrderServlet?action=viewProducts"
           class="btn btn-sm btn-primary">More</a>
      </div>
    </div>
  </div>

 <%-- Top Selling (card styled like Low-Stock but blue accent) --%>
<div class="col-lg-4 top-selling">
  <div class="card h-100">
    <div class="card-header bg-white border-0">
      <h5 class="mb-0">
        <i class="bi bi-bar-chart-line-fill text-primary me-2"></i>
        Top Selling
      </h5>
    </div>
    <ul class="list-group list-group-flush">
      <% if (topSelling.isEmpty()) { %>
        <li class="list-group-item text-center text-muted">
          No sales yet
        </li>
      <% } else {
           for (Product_pojo p : topSelling) {
             int sold = salesMap.get(p.getProductId());
      %>
        <li class="list-group-item d-flex justify-content-between align-items-center">
          <%= p.getProductName() %>
          <span class="badge bg-primary"><%= sold %> sold</span>
        </li>
      <% } } %>
      <li class="list-group-item text-center">
        <a href="<%= request.getContextPath() %>/OrderServlet?action=viewProducts" class="small">
          View All Products
        </a>
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

<script>
  function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const mainContent = document.querySelector('.main-content');
    const icon = document.getElementById('toggleIcon');

    // Flip collapsed/expanded on the sidebar itself
    sidebar.classList.toggle('sidebar-collapsed');
    sidebar.classList.toggle('sidebar-expanded');

    // Hide/show text happens via the CSS above

    // Shift main content accordingly
    if (sidebar.classList.contains('sidebar-collapsed')) {
      mainContent.style.marginLeft = '80px';
      icon.classList.replace('bi-arrow-left-circle','bi-arrow-right-circle');
    } else {
      mainContent.style.marginLeft = '250px';
      icon.classList.replace('bi-arrow-right-circle','bi-arrow-left-circle');
    }
  }
</script>
</body>
</html>