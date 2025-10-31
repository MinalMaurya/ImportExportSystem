<%@ page session="true" contentType="text/html; charset=UTF-8" language="java" %>
<%
  String pageTitle = (String) request.getAttribute("pageTitle");
  if (pageTitle == null) pageTitle = "Import Export";
  String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title><%= pageTitle %></title>

  <!-- Bootstrap CSS -->
  <link
    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
    rel="stylesheet"
  />

  <!-- Sidebar CSS -->
  <link
    href="<%=request.getContextPath()%>/css/sidebar.css"
    rel="stylesheet"
  />

  <!-- Bootstrap Icons -->
  <link
    href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css"
    rel="stylesheet"
  />
</head>
<body class="sidebar-expanded">

  <!-- Navbar -->
  <nav class="navbar navbar-expand-sm navbar-light bg-light fixed-top">
    <div class="container-fluid d-flex align-items-center">
      <button class="btn toggle-btn me-2" onclick="toggleSidebar()">
        <i class="bi bi-arrow-left-circle text-dark" id="toggleIcon"></i>
      </button>
      <a class="navbar-brand m-0" href="<%=request.getContextPath()%>/SellerDash.jsp">
        Import Export
      </a>
      <ul class="navbar-nav ms-auto d-flex align-items-center">
        <li class="nav-item me-3">
          <a class="nav-link" href="<%=request.getContextPath()%>/faq.jsp">
            <i class="bi bi-question-circle me-1"></i> FAQ
          </a>
        </li>
        <li class="nav-item dropdown">
          <a
            class="nav-link dropdown-toggle d-flex align-items-center"
            href="#" id="profileDropdown" data-bs-toggle="dropdown"
          >
            
            <span class="fw-bold"><%= username %></span>
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
  function toggleSidebar(){
    const sb   = document.getElementById('sidebar'),
          icon = document.getElementById('toggleIcon');
    sb.classList.toggle('sidebar-collapsed');
    sb.classList.toggle('sidebar-expanded');
    icon.classList.toggle('bi-arrow-left-circle');
    icon.classList.toggle('bi-arrow-right-circle');
  }
  document.addEventListener('DOMContentLoaded',()=>{
    document.getElementById('sidebar').classList.add('sidebar-expanded');
  });
</script>