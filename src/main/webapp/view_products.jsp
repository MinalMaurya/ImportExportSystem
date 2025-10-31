<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.Product_pojo" %>
<%
    List<Product_pojo> products = (List<Product_pojo>) request.getAttribute("productList");
    if (products == null) products = new java.util.ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Available Products</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link 
  rel="stylesheet" 
  href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css"
/>
<style>

  .main-wrapper {
    display: flex;
    height: calc(100vh - 56px); 
    margin-top: 56px;         
  }


  #sidebar {
    transition: width 0.3s ease;
    overflow-x: visible;   
    position: fixed;
    top: 56px; bottom: 0;
    z-index: 1030;
  }
  #sidebar.sidebar-expanded { width: 250px; }
  #sidebar.sidebar-collapsed { width:  80px; }

  #sidebar .nav-link {
    display: flex;
    align-items: center;
    transition: padding 0.3s ease;
    color: #fff;           
  }
  #sidebar.sidebar-expanded .nav-link {
    padding: 0.75rem 1rem;
  }
  #sidebar.sidebar-collapsed .nav-link {
    justify-content: center;
    padding: 0.75rem 0;
  }


  #sidebar .nav-link i {
    font-size: 1.3rem;
    opacity: 1;
  }


  #sidebar.sidebar-expanded  .sidebar-text { display: inline; }
  #sidebar.sidebar-collapsed .sidebar-text { display: none !important; }


  .main-content {
    margin-left: 250px;  
    transition: margin-left 0.3s ease;
    flex-grow: 1;
    overflow-y: auto;
    padding: 1rem;
  }
  #sidebar.sidebar-collapsed ~ .main-content {
    margin-left: 80px;   
  }


  body {
    background: #f4f7fa;
  }
 .card {
  position: relative;
  background: #ffffff;
  border-radius: 1rem;
  overflow: hidden;
  box-shadow: 0 4px 8px rgba(0,0,0,0.08);
  transition: transform .3s ease, box-shadow .3s ease, background .2s ease;
  display: flex;
  flex-direction: column;
  animation: fadeInUp .6s ease both;
}

.card::before {
  content: "";
  position: absolute;
  top: 0; left: 0;
  width: 100%;
  height: 5px;
  background: #2b2e3e;
}

.card:hover {
  background: #f8f9fa;            
  transform: translateY(-6px) scale(1.01);
  box-shadow: 0 12px 24px rgba(0,0,0,0.12);
}

@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(20px); }
  to   { opacity: 1; transform: translateY(0); }
}

.card-body {
  flex-grow: 1;
  padding: 1rem;
  display: flex;
  flex-direction: column;
}

.card-title {
  font-size: 1.25rem;
  font-weight: 700;
  margin-bottom: .5rem;
  color: #2b2e3e;
}

.card-price {
  font-size: 1.35rem;
  font-weight: 800;
  color: #1f3c88; 
  margin-bottom: .75rem;
}

.card-text {
  color: #555;
  flex-grow: 1;
  margin-bottom: 1rem;
}

.stock {
  font-size: .85rem;
  color: #888;
  margin-top: auto;
}

.order-btn {
  background: #2b2e3e; 
  border: none;
  border-radius: .5rem;
  padding: .4rem .8rem;
  font-weight: 600;
  transition: background .2s ease, transform .2s ease;
}
.order-btn:hover {
  background: #252837; 
  transform: scale(1.03);
}

.swal2-container {
  z-index: 2000;
}
.btn-dark:hover {
  background-color: #1c1f24;
  transform: scale(1.03);
}
</style>
  

</head>
<body>
  <%-- Header with toggle button that calls toggleSidebar() --%>
  <jsp:include page="/WEB-INF/fragments/consumer_header.jsp" />

  <div class="main-wrapper">
    <%-- Sidebar (must have id="sidebar" and get sidebar-expanded / -collapsed toggled by your JS) --%>
    <jsp:include page="/WEB-INF/fragments/consumer_sidebar.jsp"/>

    <%-- Main content area that shifts based on sidebar width --%>
    <div class="main-content p-4">
    <%-- Success / Error toast --%>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<%
  String success = request.getParameter("msg");
  String error   = request.getParameter("err");
  if (success != null || error != null) {
    String icon  = (error != null) ? "error" : "success";
    String title = (error != null) ? "Oops!"  : "Order Placed!";
    String text  = (error != null) ? error    : success;
%>
<script>
  Swal.fire({
    toast: true,
    position: 'top-end',
    icon: '<%=icon%>',
    title: '<%=title%>',
    text: '<%=text%>',
    showConfirmButton: false,
    timer: 2500,
    timerProgressBar: true
  });
</script>
<% } %>
      <h2 class="mb-4 text-center text-primary">Available Products</h2>
      <div class="row g-4">
        <% for (Product_pojo p : products) { %>
          <div class="col-sm-6 col-md-4">
            <div class="card h-100">
              <div class="card-body d-flex flex-column">
                <h5 class="card-title"><%= p.getProductName() %></h5>
                <p class="card-price mb-3">
                  ₹<%= String.format("%.2f", p.getPrice()) %>
                </p>
               <form method="post" action="OrderServlet" class="d-flex gap-2 align-items-center">
  <input type="hidden" name="action" value="addToCart"/>
  <input type="hidden" name="productId" value="<%= p.getProductId() %>"/>
  <input
    type="number"
    name="quantity"
    value="1"
    min="1"
    max="<%= p.getQuantity() %>"
    class="form-control form-control-sm"
    style="width: 5rem;"
    required
  />
  <button type="submit" class="btn btn-success">
    <i class="bi bi-cart-plus-fill"></i> Add to Cart
  </button>
</form>
                <small class="stock">In stock: <%= p.getQuantity() %></small>
              </div>
            </div>
          </div>
        <% } %>
      </div>
    </div>
  </div>
<script>
  function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const icon    = document.getElementById('toggleIcon');

    sidebar.classList.toggle('sidebar-expanded');
    sidebar.classList.toggle('sidebar-collapsed');

    // Flip the icon direction
    if (sidebar.classList.contains('sidebar-collapsed')) {
      icon.classList.replace('bi-arrow-left-circle', 'bi-arrow-right-circle');
    } else {
      icon.classList.replace('bi-arrow-right-circle', 'bi-arrow-left-circle');
    }
  }

  // On page load: ensure correct classes exist
  document.addEventListener('DOMContentLoaded', () => {
    const sidebar = document.getElementById('sidebar');
    if (!sidebar.classList.contains('sidebar-expanded') &&
        !sidebar.classList.contains('sidebar-collapsed')) {
      sidebar.classList.add('sidebar-expanded');
    }
  });
</script>
  <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.min.js"></script>
</body>
</html> 