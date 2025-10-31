<%@ page session="true" contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.CartPojo" %>
<%
  String consumer = (String) session.getAttribute("username");
  if (consumer == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }

  List<CartPojo> cartList = (List<CartPojo>) request.getAttribute("cartList");
  if (cartList == null) cartList = new java.util.ArrayList<>();

  String updated = request.getParameter("updated");
  String confirmed = request.getParameter("confirmed");
  String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>My Cart - Import Export</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/>
  <link href="<%=request.getContextPath()%>/css/sidebar.css" rel="stylesheet"/>
  <style>
    :root {
      --sb-expanded: 250px;
      --sb-collapsed: 80px;
    }
    body {
      font-family: 'Segoe UI', sans-serif;
    }
    .main-content {
      flex-grow: 1;
      margin-left: var(--sb-expanded);
      padding: 2rem;
      margin-top: 56px;
      transition: margin-left 0.3s ease;
    }
    .sidebar-collapsed + .main-content {
      margin-left: var(--sb-collapsed);
    }
    #sidebar.sidebar-collapsed .sidebar-text {
  display: none !important;
}
  </style>
</head>
<body>

  <%-- Header --%>
  <jsp:include page="/WEB-INF/fragments/consumer_header.jsp" />

  <div class="d-flex">
    <%-- Sidebar --%>
    <jsp:include page="/WEB-INF/fragments/consumer_sidebar.jsp" />

    <%-- Main Content --%>
    <main id="mainContent" class="main-content">
      <h2 class="mb-4">🛒 Items in Your Cart</h2>

      <%-- Alerts --%>
      <% if ("true".equals(updated)) { %>
        <div class="alert alert-success">✅ Quantity updated.</div>
      <% } else if ("single".equals(confirmed)) { %>
        <div class="alert alert-success">✅ Item confirmed.</div>
      <% } else if ("all".equals(confirmed)) { %>
        <div class="alert alert-success">✅ All items confirmed.</div>
      <% } else if (error != null) { %>
        <div class="alert alert-danger"><%= error.replace("+", " ") %></div>
      <% } %>

      <% if (cartList.isEmpty()) { %>
        <div class="alert alert-info">No items in your cart.</div>
      <% } else { %>
        <table class="table table-bordered table-hover align-middle">
          <thead class="table-dark text-center">
            <tr>
              <th>#</th>
              <th>Product ID</th>
              <th>Product Name</th>
              <th>Quantity</th>
              <th>Unit Price</th>
              <th>Total</th>
              <th>Added On</th>
              <th>Update</th>
              <th>Delete</th>
              <th>Confirm</th>
            </tr>
          </thead>
          <tbody class="text-center">
            <%
              int index = 1;
              for (CartPojo item : cartList) {
            %>
            <tr>
              <td><%= index++ %></td>
              <td><%= item.getProductId() %></td>
              <td><%= item.getProductName() %></td>
              <td>
                <form method="post" action="<%= request.getContextPath() %>/OrderServlet" class="d-flex justify-content-center">
                  <input type="hidden" name="action" value="updateCartItem"/>
                  <input type="hidden" name="cartId" value="<%= item.getCartId() %>"/>
                  <input type="number" name="quantity" value="<%= item.getQuantity() %>" min="1" class="form-control form-control-sm w-75" required/>
              </td>
              <td>₹<%= item.getPrice() %></td>
              <td>₹<%= item.getPrice() * item.getQuantity() %></td>
              <td><%= item.getAddedOn() %></td>
              <td>
                <button type="submit" class="btn btn-sm btn-primary">Update</button>
                </form>
              </td>
              <td>
                <form method="post" action="<%= request.getContextPath() %>/OrderServlet">
                  <input type="hidden" name="action" value="deleteCartItem"/>
                  <input type="hidden" name="cartId" value="<%= item.getCartId() %>"/>
                  <button type="submit" class="btn btn-sm btn-danger">🗑</button>
                </form>
              </td>
              <td>
                <form method="post" action="<%= request.getContextPath() %>/OrderServlet">
                  <input type="hidden" name="action" value="confirmSingleCartItem"/>
                  <input type="hidden" name="cartId" value="<%= item.getCartId() %>"/>
                  <button type="submit" class="btn btn-sm btn-success">✅</button>
                </form>
              </td>
            </tr>
            <% } %>
          </tbody>
        </table>

        <form action="<%= request.getContextPath() %>/OrderServlet" method="post">
          <input type="hidden" name="action" value="confirmCartOrder"/>
          <button type="submit" class="btn btn-success">✅ Confirm All Orders</button>
        </form>
      <% } %>

      <a href="<%= request.getContextPath() %>/OrderServlet?action=viewProducts" class="btn btn-secondary mt-3">← Continue Shopping</a>
    </main>
  </div>

  <!-- Bootstrap JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    function toggleSidebar(){
      const sb = document.getElementById('sidebar'),
            ic = document.getElementById('toggleIcon'),
            mc = document.getElementById('mainContent');

      sb.classList.toggle('sidebar-collapsed');
      ic.classList.toggle('bi-arrow-left-circle');
      ic.classList.toggle('bi-arrow-right-circle');

      // ✅ Sync main-content margin
      if(sb.classList.contains('sidebar-collapsed')){
        mc.style.marginLeft = 'var(--sb-collapsed)';
      } else {
        mc.style.marginLeft = 'var(--sb-expanded)';
      }
    }

    // Default on page load
    document.addEventListener('DOMContentLoaded', () => {
      const sb = document.getElementById('sidebar'),
            mc = document.getElementById('mainContent');

      if (!sb.classList.contains('sidebar-collapsed')) {
        sb.classList.add('sidebar-expanded');
        mc.style.marginLeft = 'var(--sb-expanded)';
      } else {
        mc.style.marginLeft = 'var(--sb-collapsed)';
      }
    });
  </script>
</body>
</html>