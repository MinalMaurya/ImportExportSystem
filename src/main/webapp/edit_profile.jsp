<%@ page session="true" contentType="text/html; charset=UTF-8"%>
<%@ page import="model.UserPojo"%>
<%
String role = (String) session.getAttribute("role");
if (role == null) {
	response.sendRedirect("login.jsp");
	return;
}

UserPojo user = (UserPojo) request.getAttribute("user");
String portId = (user != null) ? user.getPortId() : (String) session.getAttribute("username");
String location = (user != null) ? user.getLocation() : (String) session.getAttribute("location");

String dashboardUrl = "consumer".equals(role)
		? request.getContextPath() + "/ConsumerDash.jsp"
		: request.getContextPath() + "/SellerDash.jsp";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Edit Profile - Import Export</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
  <link href="<%= request.getContextPath() %>/css/sidebar.css" rel="stylesheet"/>
  <style>
   body {
  font-family: 'Segoe UI', sans-serif;
  margin: 0;
  padding: 0;
  background: #f4f6f9;
  height: 100vh;
}

.main-content {
  margin-left: 250px;
  display: flex;
  justify-content: center;
  align-items: center;
  height: calc(100vh - 56px); /* leave space for navbar */
  padding: 30px;
}

.edit-profile-card {
  background-color: #fff;
  padding: 2rem;
  border-radius: 16px;
  box-shadow: 0 0 30px rgba(0, 0, 0, 0.08);
  width: 100%;
  max-width: 540px;
  margin-top: 30px; /* optional, if you want slight manual push */
}

.edit-profile-card h2 {
  text-align: center;
  margin-bottom: 1.8rem;
  color: #1f3c88;
  font-weight: 600;
}

.form-label {
  font-weight: 500;
  color: #374151;
}

.form-control {
  border-radius: 8px;
}

.form-control:focus {
  box-shadow: 0 0 0 0.15rem rgba(31, 60, 136, 0.2);
  border-color: #1f3c88;
}
  </style>
</head>
<body>
  <%-- Fixed top navbar (role-based) --%>
<%
  if ("consumer".equals(role)) {
%>
  <jsp:include page="/WEB-INF/fragments/consumer_header.jsp"/>
<%
  } else {
%>
  <jsp:include page="/WEB-INF/fragments/seller_header.jsp"/>
<%
  }
%>
 <%
  if ("consumer".equals(role)) {
%>
    <jsp:include page="/WEB-INF/fragments/consumer_sidebar.jsp"/>
<%
  } else {
%>
    <jsp:include page="/WEB-INF/fragments/seller_sidebar.jsp"/>
<%
  }
%>

  <%-- Main content with margin to the left of sidebar --%>
  <div class="main-content">
    <div class="edit-profile-card">
      <h2><i class="bi bi-pencil-square me-2"></i>Edit Profile</h2>

      <% String msg = (String) request.getAttribute("msg");
         String error = (String) request.getAttribute("error");
         if (msg != null) { %>
           <div class="alert alert-success"><i class="bi bi-check-circle me-2"></i><%= msg %></div>
      <% } else if (error != null) { %>
           <div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= error %></div>
      <% } %>

      <form method="post" action="<%= request.getContextPath() %>/ProfileServlet">
        <input type="hidden" name="action" value="updateProfile" />

        <div class="mb-3">
          <label class="form-label">Port ID</label>
          <input type="text" name="port_id" class="form-control bg-light" value="<%= portId %>" readonly />
        </div>

        <div class="mb-3">
          <label class="form-label">Location</label>
          <input type="text" name="location" class="form-control" value="<%= location %>" required />
        </div>

        <div class="mb-3">
          <label class="form-label">New Password</label>
          <input type="password" name="new_password" id="newPassword" class="form-control" placeholder="Enter new password" />
        </div>

        <div class="mb-3">
          <label class="form-label">Confirm Password</label>
          <input type="password" name="confirm_password" id="confirmPassword" class="form-control" placeholder="Re-enter new password" />
          <small id="passwordHelp" class="text-danger"></small>
        </div>

        <!-- ✅ Update Profile -->
  <button type="submit" class="btn btn-primary px-4">
    <i class="bi bi-save me-1"></i> Update
  </button>

  <!-- ✅ Back to My Profile -->
  <a href="<%= request.getContextPath() %>/ProfileServlet" class="btn btn-outline-secondary">
    <i class="bi bi-arrow-left me-1"></i> Back
  </a>

  <!-- ✅ Delete Profile -->
  <form method="post"
        action="<%= request.getContextPath() %>/ProfileServlet"
        onsubmit="return confirmDelete();"
        class="d-inline">
    <input type="hidden" name="action" value="deleteAccount" />
    <button type="submit" class="btn btn-danger px-4">
      <i class="bi bi-trash me-1"></i> Delete Profile
    </button>
  </form>

      </form>
    </div>
  </div>

 <script>
  function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const icon = document.getElementById('toggleIcon');

    sidebar.classList.toggle('sidebar-expanded');
    sidebar.classList.toggle('sidebar-collapsed');

    if (sidebar.classList.contains('sidebar-collapsed')) {
      icon.classList.replace('bi-arrow-left-circle', 'bi-arrow-right-circle');
    } else {
      icon.classList.replace('bi-arrow-right-circle', 'bi-arrow-left-circle');
    }
  }

  document.addEventListener('DOMContentLoaded', () => {
    const sidebar = document.getElementById('sidebar');
    if (!sidebar.classList.contains('sidebar-expanded') &&
        !sidebar.classList.contains('sidebar-collapsed')) {
      sidebar.classList.add('sidebar-expanded');
    }
  });
</script>
  
</body>
</html>