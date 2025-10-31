<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Registration - Import Export</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
 <style>
    body {
      margin: 0;
      padding: 0;
      height: 100vh;
      font-family: 'Segoe UI', sans-serif;
      background: linear-gradient(to right, #e0e0e0, #f8f8f8);
      display: flex;
      align-items: center;
      justify-content: center;
      color: #333;
    }

    .container-box {
      background: white;
      border-radius: 15px;
      box-shadow: 0 8px 30px rgba(0, 0, 0, 0.1);
      width: 90%;
      max-width: 1000px;
      display: flex;
      overflow: hidden;
      flex-wrap: wrap;
    }

    .welcome-section, .form-section {
      flex: 1 1 500px;
      padding: 40px;
    }

    .welcome-section {
      background: #f1f1f1;
      display: flex;
      flex-direction: column;
      justify-content: center;
    }

    .welcome-section h1 {
      font-size: 2.5rem;
      margin-bottom: 20px;
      font-weight: 600;
      color: #444;
    }

    .welcome-section p {
      font-size: 1.1rem;
      margin-bottom: 30px;
      color: #666;
    }

    .feature {
      display: flex;
      align-items: center;
      margin-bottom: 15px;
      font-size: 0.95rem;
      color: #555;
    }

    .feature i {
      margin-right: 10px;
      font-size: 1.2rem;
      color: #888;
    }

    .form-section h2 {
      color: #333;
      margin-bottom: 25px;
      text-align: center;
      font-size: 2rem;
    }

    .form-control, .form-select {
      border-radius: 8px;
      padding: 10px 15px;
      margin-bottom: 15px;
      border: 1px solid #ccc;
    }

    .form-section button[type="submit"] {
      width: 100%;
      border-radius: 8px;
      padding: 12px;
      font-weight: bold;
      border: none;
      background-color: #5a6268;
      color: #fff;
      transition: 0.3s;
    }

    .form-section button:hover {
      background-color: #444;
    }

    .error-message {
      color: #d9534f;
      font-size: 14px;
    }

    @media (max-width: 768px) {
      .container-box {
        flex-direction: column;
        border-radius: 10px;
      }

      .welcome-section, .form-section {
        padding: 30px 20px;
      }
    }
  </style>
</head>
<body>
  <div class="container-box animate_animated animate_fadeIn">
    <!-- Welcome Section -->
    <div class="welcome-section">
      <h1>Welcome to Import Export Portal</h1>
      <p>Manage your port operations with secure role-based access. Whether you're a consumer or seller, register and start managing your products and orders today.</p>

      <div class="feature"><i class="fas fa-user-tag"></i> Role-Based User Access</div>
      <div class="feature"><i class="fas fa-box-open"></i> Order Management</div>
      <div class="feature"><i class="fas fa-chart-line"></i> Sales & Order Reports</div>

      <div class="mt-4">
        <p>Already registered? <a href="login.jsp" class="fw-bold text-decoration-none">Login here</a></p>
      </div>
    </div>

    <!-- Registration Section -->
    <div class="form-section">
      <h2>User Registration</h2>
      <% String msg = (String) request.getAttribute("errorMessage");
   if (msg != null) { %>
   <div class="alert alert-danger text-center mb-3"><%= msg %></div>
<% } %>
      <form id="registerForm" method="post">
        <input type="hidden" name="action" value="register">

        <div class="mb-3">
          <label for="role" class="form-label">Select Role</label>
          <select id="role" name="role" class="form-select" required>
            <option value="">-- Choose Role --</option>
            <option value="consumer">Consumer</option>
            <option value="seller">Seller</option>
          </select>
        </div>

        <div class="mb-3">
          <label for="portId" class="form-label">Port ID</label>
          <input type="text" id="portId" name="port_id" class="form-control" required>
        </div>

        <div class="mb-3">
          <label for="password" class="form-label">Password</label>
          <input type="password" id="password" name="password" class="form-control" required>
        </div>

        <div class="mb-3">
          <label for="confirmPassword" class="form-label">Confirm Password</label>
          <input type="password" id="confirmPassword" name="confirm_password" class="form-control" required>
          <span id="passwordError" class="error-message"></span>
        </div>

        <button type="submit">Register</button>
      </form>
    </div>
  </div>

  <!-- JS -->
  <script>
  const password = document.getElementById("password");
  const confirm = document.getElementById("confirmPassword");
  const errorText = document.getElementById("passwordError");
  const form = document.getElementById("registerForm");

  function validatePasswordMatch() {
    if (password.value !== confirm.value) {
      errorText.innerText = "❌ Passwords do not match!";
      return false;
    } else {
      errorText.innerText = "";
      return true;
    }
  }

  // Live check while typing
  confirm.addEventListener("input", validatePasswordMatch);

  // Final check before form submit
  form.addEventListener("submit", function (e) {
    const role = document.getElementById("role").value;
    const isMatch = validatePasswordMatch();

    if (!isMatch || role === "") {
      e.preventDefault(); // Stop form submission
      if (role === "") {
        alert("❌ Please select a role.");
      }
      return;
    }

    // ✅ Set form action dynamically
    if (role === "consumer") {
      this.action = "ConsumerServlet";
    } else if (role === "seller") {
      this.action = "SellerServlet";
    }
  });
</script>
</body>
</html>