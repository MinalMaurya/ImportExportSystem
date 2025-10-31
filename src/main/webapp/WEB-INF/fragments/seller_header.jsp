<%@ page session="true" contentType="text/html;charset=UTF-8" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String ctx = request.getContextPath();
%>
 <link
    href="<%=request.getContextPath()%>/css/sidebar.css"
    rel="stylesheet"
  />
  
<nav class="navbar navbar-expand-sm navbar-light bg-light fixed-top">
  <div class="container-fluid d-flex align-items-center">
    <!-- Sidebar toggle -->
    <button class="btn toggle-btn me-2 " onclick="toggleSidebar()">
      <i class="bi bi-arrow-left-circle text-dark" id="toggleIcon"></i>
    </button>

    <!-- Brand -->
   <!-- seller_header.jsp -->
<a class="navbar-brand" href="<%=ctx%>/SellerServlet">Import Export</a>

    <!-- FAQ + Profile -->
    <ul class="navbar-nav ms-auto d-flex align-items-center">
      <li class="nav-item me-3">
        <a class="nav-link d-flex align-items-center" href="<%=request.getContextPath()%>/faq.jsp">
          <i class="bi bi-question-circle me-1"></i> FAQ
        </a>
      </li>
      <li class="nav-item dropdown">
        <a class="nav-link d-flex align-items-center" href="#" id="profileDropdown" data-bs-toggle="dropdown">
          
          <span class="fw-bold"><%=username%></span>
        </a>
        <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="profileDropdown">
        
         <li><a class="dropdown-item" href="<%= request.getContextPath() %>/ProfileServlet">My Profile</a></li>
          <li><hr class="dropdown-divider"/></li>
          <li><a class="dropdown-item" href="<%=request.getContextPath()%>/LogoutServlet">Logout</a></li>
        </ul>
      </li>
    </ul>
  </div>
</nav>
<script>
  function toggleSidebar() {
    const sidebar     = document.getElementById('sidebar');
    const mainContent = document.querySelector('.main-content');
    const icon        = document.getElementById('toggleIcon');

    // Toggle the expanded/collapsed classes
    sidebar.classList.toggle('sidebar-expanded');
    sidebar.classList.toggle('sidebar-collapsed');

    // Adjust main-content margin to match
    if (sidebar.classList.contains('sidebar-collapsed')) {
      mainContent.style.marginLeft = '80px';
      icon.classList.replace('bi-arrow-left-circle', 'bi-arrow-right-circle');
    } else {
      mainContent.style.marginLeft = '250px';
      icon.classList.replace('bi-arrow-right-circle', 'bi-arrow-left-circle');
    }
  }
</script>