<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page import="java.util.List"%>
<%@ page import="model.Product_pojo"%>

<%
    // Determine whether we're editing or adding
    Product_pojo editProduct = (Product_pojo) request.getAttribute("editProduct");
    String formAction = (editProduct != null) ? "update" : "add";

    // Fetch sellerPortId from request or session, else redirect to login
    String sellerId = (String) request.getAttribute("seller_port_id");
    if (sellerId == null || sellerId.trim().isEmpty()) {
        sellerId = (String) session.getAttribute("seller_port_id");
        if (sellerId == null || sellerId.trim().isEmpty()) {
            response.sendRedirect("login.jsp?error=Session expired. Please login again.");
            return;
        }
    }

    // Load products list and count
    List<Product_pojo> products = (List<Product_pojo>) request.getAttribute("productList");
    int totalProducts = (products != null) ? products.size() : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Seller Product Panel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/> 
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        /* sidebar widths */
.sidebar-expanded  { width:250px !important; }
.sidebar-collapsed { width: 80px !important; }
/* hide text when collapsed */
.sidebar-collapsed .sidebar-text { display: none !important; }
/* main‐content shift */
.main-content         { transition: margin-left .3s ease; }
.ml-250               { margin-left:250px !important; }
.ml-80                { margin-left: 80px !important; }
/* Wrap your <table> in <table class="table-custom">… */
.table-custom {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  border: 1px solid #dee2e6;
  border-radius: .5rem;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  background: #fff;
  font-family: 'Nunito', sans-serif;
}

.table-custom thead {
  background: #f1f3f5;
}

.table-custom thead th {
  padding: .75rem 1rem;
  color: #495057;
  font-weight: 600;
  text-transform: uppercase;
  border-bottom: 2px solid #dee2e6;
}

.table-custom tbody tr {
  transition: background .2s ease;
  cursor: default;
}

.table-custom tbody tr:nth-child(even) {
  background: #fafbfc;
}

.table-custom tbody tr:hover {
  background: #e9ecef;
}

.table-custom td {
  padding: .75rem 1rem;
  vertical-align: middle;
  border-bottom: 1px solid #dee2e6;
  color: #343a40;
}

.table-custom tbody tr:last-child td {
  border-bottom: none;
}

/* Center the action buttons column */
.table-custom td.actions {
  text-align: center;
}
.btn-dashboard {
  background-color: #2b2e3e;
  border-color:  #2b2e3e;
  color:          #fff;
  margin-top:     .27rem; /* align with heading */
}
.btn-dashboard:hover {
  background-color: #232531;
  border-color:     #232531;
}
    </style>

</head>
<body>
<jsp:include page="/WEB-INF/fragments/seller_header.jsp"/>
  <jsp:include page="/WEB-INF/fragments/seller_sidebar.jsp"/>
<div class="main-content ml-250" style="margin-top:56px; padding:2rem;">
   <div class="d-flex justify-content-between align-items-center mb-4">
    <h2 class="fw-bold">Product Management</h2>
    <!-- Dashboard button -->
    <a href="SellerDash.jsp" class="btn btn-outline-primary">
        <i class="bi bi-arrow-left-circle"></i> Dashboard
    </a>
</div>

    <div class="alert alert-light d-flex justify-content-between align-items-center ">
        <div><strong>📦 Total Products:</strong> <%= totalProducts %></div>
    </div>

    <%-- SweetAlert feedback --%>
    <%
        String msg = request.getParameter("msg");
        if (msg != null) {
            String icon = msg.contains("deleted") ? "error"
                        : msg.contains("updated") ? "info"
                        : (msg.contains("Failed") || msg.contains("Error")) ? "warning"
                        : "success";
            String title = msg.contains("deleted") ? "Deleted!"
                         : msg.contains("updated") ? "Updated!"
                         : (msg.contains("Failed") || msg.contains("Error")) ? "Oops!"
                         : "Success!";
    %>
    <script>
        Swal.fire({
            toast: true,
            position: 'top-end',
            icon: '<%= icon %>',
            title: '<%= title %>',
            text: "<%= msg %>",
            showConfirmButton: false,
            timer: 2000
        });
    </script>
    <% } %>

    <!-- Product Form -->
    <div class="form-section p-4 mb-5 border rounded">
        <form method="post" action="ProductController" id="form-product">
            <input type="hidden" name="action" value="<%= formAction %>">
            <input type="hidden" name="seller_port_id" value="<%= sellerId %>">
            <% if (editProduct != null) { %>
                <input type="hidden" name="product_id" value="<%= editProduct.getProductId() %>">
            <% } %>

            <div class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Product Name</label>
                    <input type="text" name="product_name" class="form-control" required
                        value="<%= (editProduct != null) ? editProduct.getProductName() : "" %>">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Price (₹)</label>
                    <input type="number" name="price" class="form-control" required
                        value="<%= (editProduct != null) ? editProduct.getPrice() : "" %>">
                </div>
                <div class="col-md-2">
    <label class="form-label">
        <%= (editProduct != null) ? "Quantity Change (±)" : "Quantity" %>
    </label>
  <% if (editProduct != null) { %>
  <!-- preserve original for server logic -->
  <input 
      type="hidden" 
      name="original_quantity" 
      value="<%= editProduct.getQuantity() %>" 
  />
  <!-- initial value = current stock; placeholder = example -->
  <input 
      type="number" 
      name="quantity_delta" 
      class="form-control" 
      required 
      value="<%= editProduct.getQuantity() %>" 
      placeholder="e.g. +5 or -3" 
  />
<% } else { %>
  <!-- normal add-mode quantity -->
  <input 
      type="number" 
      name="quantity" 
      class="form-control" 
      required 
  />
<% } %>
</div>
                <div class="col-md-2 d-grid align-items-end">
                    <button class="btn btn-<%= (editProduct != null) ? "primary" : "success" %>" type="submit">
                        <i class="fa <%= (editProduct != null) ? "fa-save" : "fa-plus-circle" %>"></i>
                        <%= (editProduct != null) ? "Update" : "Add" %>
                    </button>
                </div>
            </div>
        </form>
    </div>

    <!-- Products Table -->
    <div class="table-responsive">
        <table class="table orders-table">
            <thead class="table-light">
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Price (₹)</th>
                    <th>Quantity</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (products != null && !products.isEmpty()) {
                       for (Product_pojo p : products) { %>
                <tr>
                    <td><%= p.getProductId() %></td>
                    <td><%= p.getProductName() %></td>
                    <td><%= p.getPrice() %></td>
                    <td><%= p.getQuantity() %></td>
                    <td>
                        <form method="post" action="ProductController" style="display:inline">
                            <input type="hidden" name="action" value="edit-form">
                            <input type="hidden" name="product_id" value="<%= p.getProductId() %>">
                            <input type="hidden" name="seller_port_id" value="<%= sellerId %>">
                            <button class="btn btn-outline-primary btn-sm me-1">
                                <i class="fa fa-pen"></i> Edit
                            </button>
                        </form>
                        <form method="post" action="ProductController" style="display:inline">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="product_id" value="<%= p.getProductId() %>">
                            <input type="hidden" name="seller_port_id" value="<%= sellerId %>">
                            <button class="btn btn-outline-danger btn-sm" onclick="return confirm('Delete this product?');">
                                <i class="fa fa-trash"></i> Delete
                            </button>
                        </form>
                    </td>
                </tr>
                <%   }
                   } else { %>
                <tr>
                    <td colspan="6" class="text-center">No products found. Add some to get started!</td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<a href="#form-product" class="btn btn-success btn-lg rounded-circle shadow floating-btn">
    <i class="fa fa-plus"></i>
</a>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
  function toggleSidebar() {
    const sb   = document.getElementById('sidebar'),
          inner= document.getElementById('sidebarInner'),
          icon = document.getElementById('toggleIcon'),
          main = document.querySelector('.main-content');

    sb.classList.toggle('sidebar-expanded');
    sb.classList.toggle('sidebar-collapsed');
    main.classList.toggle('ml-250');
    main.classList.toggle('ml-80');
    icon.classList.toggle('bi-arrow-left-circle');
    icon.classList.toggle('bi-arrow-right-circle');
  }
</script>
</body>
</html>