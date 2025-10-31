<%@ page session="true" contentType="text/html;charset=UTF-8" import="model.UserPojo" %>
<%
UserPojo user = (UserPojo) request.getAttribute("user");
if (user == null) {
    response.sendRedirect(request.getContextPath() + "/ProfileServlet");
    return;
}

String sessionUsername = (String) session.getAttribute("username");
String sessionRole     = (String) session.getAttribute("role");
String sessionLocation = (String) session.getAttribute("location");

String portId   = user.getPortId() != null ? user.getPortId() : "";
String role     = user.getRole()   != null ? user.getRole()   : "";
String location = user.getLocation()!= null ? user.getLocation() : "";
String password = user.getPassword()!= null ? user.getPassword() : "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>My Profile</title>
  <!-- Bootstrap CSS & Icons -->
  <link
    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
    rel="stylesheet"
  />
  <link
    href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css"
    rel="stylesheet"
  />

  <style>
    .profile-card {
      max-width: 600px;
      margin: 5rem auto;
      border-radius: 1rem;
      box-shadow: 0 4px 20px rgba(0,0,0,0.05);
      background: #fff;
      padding: 5rem;
    }
    .profile-card h2 {
      margin-bottom: 1.5rem;
      font-weight: 600;
      color: #1f3c88;
    }
    .profile-card .form-label {
      font-weight: 500;
      color: #475569;
    }
    .main-content { padding: 1.5rem; }
  </style>
</head>
<body>
  <%-- Header/Nav based on role --%>
  <% if ("consumer".equals(role)) { %>
    <jsp:include page="/WEB-INF/fragments/consumer_header.jsp"/>
  <% } else { %>
    <jsp:include page="/WEB-INF/fragments/seller_header.jsp"/>
  <% } %>

  <div class="d-flex">
    <%-- Sidebar --%>
    <% if ("consumer".equals(role)) { %>
      <jsp:include page="/WEB-INF/fragments/consumer_sidebar.jsp"/>
    <% } else { %>
      <jsp:include page="/WEB-INF/fragments/seller_sidebar.jsp"/>
    <% } %>

    <%-- Main content --%>
    <div class="main-content flex-grow-1">
      <div class="profile-card">
        <h2 class="text-center">My Profile</h2>

        <div class="mb-3">
          <label class="form-label">Port ID</label>
          <input type="text" class="form-control" value="<%= portId %>" readonly>
        </div>

       <div class="mb-3">
  <label class="form-label" for="pwdField">Password</label>
  <div class="input-group">
    <input type="password"
           id="pwdField"
           class="form-control"
           value="<%= password %>"
           readonly
           oncopy="return false">
    <button type="button"
            class="btn btn-outline-secondary"
            onclick="togglePwd(this)">
      <i class="bi bi-eye"></i>
    </button>
  </div>
  <small class="text-muted">Click the eye to show/hide</small>
</div>

<div class="mb-3">
  <label class="form-label">Location</label>
  <input type="text"
         class="form-control"
         value="<%= (location != null) ? location : "" %>"
         readonly>
</div>

        <div class="mb-4">
          <label class="form-label">Role</label>
          <input type="text"
                 class="form-control"
                 value="<%= role.substring(0,1).toUpperCase()+role.substring(1) %>"
                 readonly>
        </div>

        <div class="text-center">
          <!-- new -->
<a href="<%= request.getContextPath() %>/ProfileServlet?action=edit" 
   class="btn btn-primary px-4">
  <i class="bi bi-pencil-square me-1"></i>
  Edit Profile
</a>
  <a href="<%= "consumer".equals(role)
              ? request.getContextPath() + "/ConsumerDash.jsp"
              : request.getContextPath() + "/SellerDash.jsp" %>"
     class="btn btn-outline-secondary px-4">
    <i class="bi bi-arrow-left me-1"></i> Back
  </a>

  
</div>
      </div>
    </div>
  </div>

  <!-- Bootstrap JS bundle -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
  function togglePwd(btn) {
    const fld = document.getElementById('pwdField');
    if (fld.type === 'password') {
      fld.type = 'text';
      btn.innerHTML = '<i class="bi bi-eye-slash"></i>';
    } else {
      fld.type = 'password';
      btn.innerHTML = '<i class="bi bi-eye"></i>';
    }
  }

  function confirmDelete() {
    return confirm("Are you sure you want to delete your profile? This action cannot be undone.");
  }
</script>
</body>
</html>