<%@ page session="true" contentType="text/html; charset=UTF-8" %>
<%
  String ctx         = request.getContextPath();
  String servletPath = request.getServletPath();
  String action      = request.getParameter("action");
  String sellerId    = (String) session.getAttribute("seller_port_id");
%>
<div id="sidebar" class="sidebar-expanded">
  <ul class="nav nav-pills flex-column mb-0 px-3 py-4">
    <li class="nav-item mb-2">
      <a
        href="<%=ctx%>/SellerServlet"
        class="nav-link <%= servletPath.equals("/SellerServlet") && action==null ? "active" : "" %>"
      >
        <i class="bi bi-speedometer2"></i>
        <span class="sidebar-text">Dashboard</span>
      </a>
    </li>
    <li class="nav-item mb-2">
      <a
        href="<%=ctx%>/ProductController"
        class="nav-link <%= servletPath.startsWith("/ProductController") ? "active" : "" %>"
      >
        <i class="bi bi-box-seam"></i>
        <span class="sidebar-text">Manage Products</span>
      </a>
    </li>
   <li class="nav-item mb-2">
  <a
    href="<%=ctx%>/SellerServlet?action=viewSellerOrders"
    class="nav-link no-highlight"
  >
    <i class="bi bi-card-list"></i>
    <span class="sidebar-text">View Orders</span>
  </a>
</li>
    <li class="nav-item mb-2">
      <a
        href="<%=ctx%>/reports?user_type=seller&amp;port_id=<%=sellerId%>"
        class="nav-link <%= servletPath.equals("/reports") ? "active" : "" %>"
      >
        <i class="bi bi-flag-fill"></i>
        <span class="sidebar-text">Handle Reports</span>
      </a>
    </li>
    <li class="nav-item">
  <a class="nav-link <% if (request.getRequestURI().contains("sales_analysis.jsp")) { %>active<% } %>"
     href="<%=request.getContextPath()%>/SalesAnalysisServlet">
    <i class="bi bi-bar-chart-line me-2"></i>
    <span class="sidebar-text">Sales Analysis</span>
  </a>
</li>
  </ul>
  
  <div class="px-3 pb-4">
    <a
      href="<%=ctx%>/settings.jsp"
      class="nav-link <%= servletPath.equals("/settings.jsp") ? "active" : "" %>"
    >
      <i class="bi bi-gear-fill me-2"></i>
      <span class="sidebar-text">Settings</span>
    </a>
  </div>
</div>