<%@ page contentType="text/html;charset=UTF-8" session="true" language="java" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Contact Us – Import Export</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/sidebar.css">
  <style>
    :root {
      --sidebar-expanded: 250px;
      --sidebar-collapsed: 80px;
    }

    body {
      margin: 0;
      padding: 0;
      font-family: 'Segoe UI', sans-serif;
      background-color: #f2f6fc;
    }

    .main-wrapper {
      display: flex;
    }

    .content {
      margin-top: 56px; /* navbar height */
      flex: 1;
      padding: 40px;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: calc(100vh - 56px);
      margin-left: var(--sidebar-expanded);
      transition: margin-left 0.3s ease;
    }

    #sidebar.sidebar-collapsed ~ .content {
      margin-left: var(--sidebar-collapsed);
    }

    .contact-container {
      background-color: #eaf4ff;
      padding: 40px;
      border-radius: 10px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
      max-width: 700px;
      width: 100%;
    }

    h2 {
      color: #007bff;
    }
  </style>
</head>
<body class="<%= session.getAttribute("sidebar") != null ? session.getAttribute("sidebar") : "" %>">

  <%-- Role-based Header & Sidebar --%>
  <% if ("seller".equals(role)) { %>
    <jsp:include page="/WEB-INF/fragments/seller_header.jsp"/>
    <jsp:include page="/WEB-INF/fragments/seller_sidebar.jsp"/>
  <% } else { %>
    <jsp:include page="/WEB-INF/fragments/consumer_header.jsp"/>
    <jsp:include page="/WEB-INF/fragments/consumer_sidebar.jsp"/>
  <% } %>

  <div class="main-wrapper">
    <div class="content">
      <div class="contact-container">
        <h2><i class="bi bi-envelope-paper-heart"></i> Contact Us</h2>
        <p>Have a question, feedback, or suggestion? We'd love to hear from you!</p>
        <ul class="list-group list-group-flush">
          <li class="list-group-item"><i class="bi bi-geo-alt-fill"></i> Address: ImportExport Inc., Mumbai, India</li>
          <li class="list-group-item"><i class="bi bi-telephone-fill"></i> Phone: +91-9876543210</li>
          <li class="list-group-item"><i class="bi bi-envelope-fill"></i> Email: support@importexport.com</li>
        </ul>
        <div class="text-center mt-4">
                <a href="settings.jsp" class="btn btn-outline-primary">
                    <i class="bi bi-arrow-left-circle"></i> Back to Settings
                </a>
            </div>
      </div>
      
    </div>
  </div>
</body>
</html>