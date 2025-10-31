<%@ page session="true" contentType="text/html; charset=UTF-8" language="java" %>
<%
  String ctx         = request.getContextPath();
  String uri         = request.getRequestURI().substring(ctx.length());
  String user        = (String) session.getAttribute("username");
  String action      = request.getParameter("action");
%>

<div id="sidebar" class="sidebar-expanded">
  <div id="sidebarInner">

    <ul class="nav nav-pills flex-column mb-0 px-3 py-4">
      <!-- Dashboard -->
      <li class="nav-item mb-2">
        <a href="<%=ctx%>/ConsumerDash.jsp"
           class="nav-link no-highlight <%= uri.equals("/ConsumerDash.jsp") ? "active" : "" %>">
          <i class="bi bi-speedometer2"></i>
          <span class="sidebar-text">Dashboard</span>
        </a>
      </li>

      <!-- View Products -->
<li class="nav-item mb-2">
  <a href="<%=ctx%>/OrderServlet?action=viewProducts"
     class="nav-link no-highlight <%= request.getQueryString() != null && request.getQueryString().contains("action=viewProducts") ? "active" : "" %>">
    <i class="bi bi-box-seam"></i>
    <span class="sidebar-text">View Products</span>
  </a>
</li>
<li class="nav-item mb-2">
  <a href="<%=ctx%>/OrderServlet?action=viewCart"
     class="nav-link no-highlight <%= request.getQueryString() != null && request.getQueryString().contains("action=viewCart") ? "active" : "" %>">
    <i class="bi bi-cart4"></i>
    <span class="sidebar-text">My Cart</span>
  </a>
</li>

      <!-- My Orders -->
      <li class="nav-item mb-2">
        <a href="<%=ctx%>/OrderServlet?action=myOrders"
           class="nav-link no-highlight <%= (uri.contains("/OrderServlet") && "myOrders".equals(action)) ? "active" : "" %>">
          <i class="bi bi-card-list"></i>
          <span class="sidebar-text">My Orders</span>
        </a>
      </li>
      <!-- Track Order -->
<li class="nav-item mb-2">
  <a href="<%=ctx%>/OrderServlet?action=track"
     class="nav-link no-highlight <%= request.getQueryString() != null && request.getQueryString().contains("action=track") ? "active" : "" %>">
    <i class="bi bi-truck"></i>
    <span class="sidebar-text">Track Order</span>
  </a>
</li>

      <!-- Report Issues -->
      <li class="nav-item mb-2">
        <a href="<%=ctx%>/reports?user_type=consumer&amp;port_id=<%=user%>"
           class="nav-link no-highlight <%= uri.startsWith("/reports") ? "active" : "" %>">
          <i class="bi bi-flag-fill"></i>
          <span class="sidebar-text">Report Issues</span>
        </a>
      </li>


    <!-- Settings -->
    <li class="nav-item mt-auto">
    <a href="<%=ctx%>/settings.jsp"
       class="nav-link <%= uri.equals("/settings.jsp") ? "active" : "" %>">
      <i class="bi bi-gear-fill"></i>
      <span class="sidebar-text">Settings</span>
    </a>
  </li>
  </ul>
  </div>
</div>