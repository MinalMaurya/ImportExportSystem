<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // so we can inject the context path into our JS below
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Login – Import Export</title>
  <link
    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
    rel="stylesheet"
  >
<style>
    body {
      background: linear-gradient(to right, #eef2f3, #dfe4ea);
      font-family: 'Segoe UI', sans-serif;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 30px;
    }
    .card-container {
      display: flex;
      flex-wrap: wrap;
      background-color: #fff;
      box-shadow: 0 0 25px rgba(0,0,0,0.05);
      border-radius: 15px;
      overflow: hidden;
      max-width: 960px;
      width: 100%;
    }
    .welcome-section {
      background-color: #f8f9fa;
      padding: 40px;
      flex: 1 1 50%;
      border-right: 1px solid #dee2e6;
    }
    .form-section {
      padding: 40px;
      flex: 1 1 50%;
    }
    h2 {
      font-weight: 600;
      color: #333;
    }
    .feature-list i {
      color: #6c757d;
      margin-right: 10px;
    }
    .form-control, .form-select {
      border-radius: 8px;
    }
    .btn-primary {
      border-radius: 8px;
      background-color: #5a6268;
      border: none;
    }
    .btn-primary:hover {
      background-color: #444c53;
    }
    @media (max-width: 768px) {
      .card-container {
        flex-direction: column;
      }
      .welcome-section {
        border-right: none;
        border-bottom: 1px solid #dee2e6;
      }
    }
  </style>
</head>
<body>
<div class="card-container">
  <!-- Welcome Section (same as registration) -->
  <div class="welcome-section">
    <h2 class="mb-3">Welcome to Import Export Portal</h2>
    <p class="text-muted mb-4">
      Manage your port operations with secure role-based access. Whether you're a consumer or seller, register and start managing your products and orders today.
    </p>
    <ul class="list-unstyled feature-list mb-4">
      <li><i class="fas fa-user-tag"></i> Role-Based User Access</li>
      <li><i class="fas fa-box-open"></i> Order Management</li>
      <li><i class="fas fa-chart-line"></i> Sales & Order Reports</li>
    </ul>
    <p class="text-muted mb-0">Don't have an account?
      <a href="registration.jsp" class="text-decoration-none fw-bold text-primary">Register here</a>
    </p>
  </div>

  <!-- Login Form Section -->
  <div class="form-section">
    <h3 class="mb-4 text-center">User Login</h3>

    <% String success = request.getParameter("success");
     if ("true".equals(success)) { %>
     <div class="alert alert-success text-center">✅ Registration successful. Please login.</div>
  <% } %>

  <% String loginMsg = (String) request.getAttribute("loginError");
     if (loginMsg != null) { %>
     <div class="alert alert-danger text-center mb-3"><%= loginMsg %></div>
  <% } %>

    <form id="loginForm" method="post">
      <input type="hidden" name="action" value="login">

      <div class="mb-3">
        <label for="role" class="form-label">Select Role</label>
        <select class="form-select" id="role" name="role" required>
          <option value="">-- Select Role --</option>
          <option value="consumer">Consumer</option>
          <option value="seller">Seller</option>
        </select>
      </div>

      <div class="mb-3">
        <label for="portId" class="form-label">Port ID</label>
        <input type="text" class="form-control" id="portId" name="port_id" required>
      </div>

      <div class="mb-3">
        <label for="password" class="form-label">Password</label>
        <input type="password" class="form-control" id="password" name="password" required>
      </div>

      <button type="submit" class="btn btn-primary w-100">Login</button>
    </form>
  </div>
</div>

<script>
  document.getElementById("loginForm").addEventListener("submit", function(e) {
    const role = document.getElementById("role").value;
    if (role === "consumer") {
      this.action = "ConsumerServlet";
    } else if (role === "seller") {
      this.action = "SellerServlet";
    } else {
      e.preventDefault();
      alert("❌ Please select a valid role.");
    }
  });
</script>
</body>
</html>