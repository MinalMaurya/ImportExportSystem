<%@ page session="true" contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
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
    <title>About & FAQ - Import Export</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <link href="<%=request.getContextPath()%>/css/sidebar.css" rel="stylesheet"/>
    <style>
        :root {
            --sidebar-width: 250px;
            --sidebar-collapsed-width: 80px;
        }

       .main-centered-container {
    display: flex;
    justify-content: center;
    padding: 40px 20px 20px;
    margin-left: var(--sidebar-width);
    margin-top: 60px; /* Prevent overlap with fixed navbar */
    transition: all 0.3s ease;
}
        body.sidebar-collapsed .main-centered-container {
            margin-left: var(--sidebar-collapsed-width);
        }
       .about-faq-container {
  background-color: #eaf4ff; /* soft light blue */
  padding: 30px;
  border-radius: 10px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  max-width: 1000px;
  width: 100%;
}

        .content-box {
            max-width: 900px;
            width: 100%;
            background-color: #fff;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.05);
        }

        .faq-item {
            background: #f9f9f9;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
    <!-- Header and Sidebar -->
    <% if ("seller".equals(role)) { %>
        <jsp:include page="/WEB-INF/fragments/seller_header.jsp"/>
        <jsp:include page="/WEB-INF/fragments/seller_sidebar.jsp"/>
    <% } else { %>
        <jsp:include page="/WEB-INF/fragments/consumer_header.jsp"/>
        <jsp:include page="/WEB-INF/fragments/consumer_sidebar.jsp"/>
    <% } %>

    <!-- Main Content -->
    <div class="main-centered-container">
        <div class="content-box">
            <h2><i class="bi bi-info-circle-fill text-primary me-2"></i> About This Application</h2>
            <p><strong>Import Export</strong> is a robust and secure e-commerce management platform built to simplify the global trade of goods and services. It bridges the gap between consumers and sellers through seamless digital interaction and automation.</p>
            <p>Our mission is to provide a user-friendly, scalable, and secure platform that empowers users to manage their operations effectively. Whether you’re an importer, exporter, vendor, or buyer — our tools are designed to serve all.</p>

            <ul>
                <li>🔐 <strong>Secure Login & Role-based Access:</strong> Role-authenticated access ensures user data privacy and system security.</li>
                <li>🛍️ <strong>Product Listing & Inventory Management:</strong> Easily add, manage, and monitor your entire catalog.</li>
                <li>📦 <strong>Real-Time Order Tracking:</strong> Get updates on every stage of your orders instantly.</li>
                <li>📊 <strong>Sales & Analytics:</strong> Monitor performance with detailed sales, stock, and revenue dashboards.</li>
                <li>📧 <strong>Customer Support & Product Reporting:</strong> Raise and handle product concerns with timely seller communication.</li>
            </ul>

            <h3 class="mt-5"><i class="bi bi-question-circle-fill text-primary me-2"></i> Frequently Asked Questions</h3>

            <div class="faq-item">
                <strong>Q. What is this Import Export System?</strong>
                <p>Ans. This is a web portal designed to manage and automate the entire process of import and export, including registration, product listing, order management, shipment tracking, and sales analysis.</p>
            </div>

            <div class="faq-item">
                <strong>Q. Who can use the system?</strong>
                <p>Ans. Exporters, importers, and customs agents can register and manage their operations using this platform.</p>
            </div>

            <div class="faq-item">
                <strong>Q. Is it safe to use the system?</strong>
                <p>Ans. Yes, we use secure role-based login and encrypted communication to ensure safety and data privacy.</p>
            </div>

            <div class="text-center mt-4">
                <a href="settings.jsp" class="btn btn-outline-primary">
                    <i class="bi bi-arrow-left-circle"></i> Back to Settings
                </a>
            </div>
        </div>
    </div>
</body>
</html>