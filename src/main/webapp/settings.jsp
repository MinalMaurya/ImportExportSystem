<%@ page session="true" contentType="text/html;charset=UTF-8" language="java" %>
<%
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    String theme = (String) session.getAttribute("theme");
    if (theme == null) theme = "light";

    if (username == null || role == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Settings - Import Export</title>

  <!-- Theme Based CSS -->
  <link href="<%=request.getContextPath()%>/css/<%= theme %>.css" rel="stylesheet" />

  <!-- Bootstrap -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

  <style>
    :root {
      --sb-expanded-width: 250px;
      --sb-collapsed-width: 80px;
    }

    #sidebar {
      position: fixed;
      top: 56px;
      bottom: 0;
      left: 0;
      width: var(--sb-expanded-width);
      background-color: #343a40;
      transition: width 0.3s ease;
      z-index: 1020;
    }

    #sidebar.sidebar-collapsed {
      width: var(--sb-collapsed-width);
    }

    body.sidebar-collapsed .form-container {
      margin-left: var(--sb-collapsed-width);
    }

    .form-container {
      margin-left: var(--sb-expanded-width);
      transition: margin-left 0.3s ease;
      padding: 5rem;
    }

    .settings-card {
      background: white;
      border-radius: 12px;
      padding: 2rem;
      box-shadow: 0 0 10px rgba(0,0,0,0.08);
    }

    .setting-option {
      display: block;
      width: 100%;
      background-color: #3498db;
      color: white;
      border: none;
      padding: 15px;
      margin-bottom: 15px;
      border-radius: 5px;
      font-size: 16px;
      text-align: left;
      cursor: pointer;
      transition: background-color 0.3s ease;
    }

    .setting-option:hover {
      background-color: #2980b9;
    }

    .delete-button {
      background-color: #e74c3c;
    }

    .delete-button:hover {
      background-color: #c0392b;
    }
  </style>
</head>

<body id="body">

<!-- Navbar include based on role -->
<% if ("consumer".equals(role)) { %>
  <jsp:include page="/WEB-INF/fragments/consumer_header.jsp" />
<% } else { %>
  <jsp:include page="/WEB-INF/fragments/seller_header.jsp" />
<% } %>

<!-- Sidebar include based on role -->
<% if ("consumer".equals(role)) { %>
  <jsp:include page="/WEB-INF/fragments/consumer_sidebar.jsp" />
<% } else { %>
  <jsp:include page="/WEB-INF/fragments/seller_sidebar.jsp" />
<% } %>

<!-- Settings Section -->
<div class="form-container">
  <div class="container">
    <div class="settings-card">
      <h2 class="mb-4"><i class="bi bi-gear me-2"></i> Settings</h2>

      <!-- Login and Security (My Profile Page) -->
     <form action="<%=request.getContextPath()%>/ProfileServlet?action=view" method="get">
        <button class="setting-option"><i class="bi bi-shield-lock me-2"></i> Login and Security</button>
      </form>

      <!-- About this App -->
      <form action="<%=request.getContextPath()%>/about.jsp" method="get">
        <button class="setting-option"><i class="bi bi-info-circle me-2"></i> About This App</button>
      </form>

      <!-- Contact Us -->
      <form action="<%=request.getContextPath()%>/contact.jsp" method="get">
        <button class="setting-option"><i class="bi bi-telephone me-2"></i> Contact Us</button>
      </form>

      <!-- Help Us -->
      <form action="<%=request.getContextPath()%>/help.jsp" method="get">
        <button class="setting-option"><i class="bi bi-question-circle me-2"></i> Help Us</button>
      </form>

      <!-- Delete Account -->
      <form action="<%=request.getContextPath()%>/ProfileServlet" method="post" onsubmit="return confirm('Are you sure you want to delete your account permanently?');">
        <input type="hidden" name="action" value="deleteAccount"/>
        <input type="hidden" name="username" value="<%= username %>"/>
        <input type="hidden" name="role" value="<%= role %>"/>
        <button type="submit" class="setting-option delete-button">
          <i class="bi bi-trash3 me-2"></i> Delete My Account
        </button>
         <a href="<%= "consumer".equals(role)
              ? request.getContextPath() + "/ConsumerDash.jsp"
              : request.getContextPath() + "/SellerDash.jsp" %>"
     class="btn btn-outline-secondary px-4">
    <i class="bi bi-arrow-left me-1"></i> Back
  </a>
      </form>

    </div>
  </div>
</div>

</body>
</html>