<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" import="java.util.*" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String dashboardPage = "consumer".equalsIgnoreCase(role) ? "ConsumerDash.jsp" : "SellerDash.jsp";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>FAQs - Import Export System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        :root {
            --sb-expanded: 250px;
            --sb-collapsed: 80px;
        }

        body {
            font-family: 'Segoe UI', sans-serif;
            background-color: #f0f2f5;
        }
.faq-container {
    display: flex;
    justify-content: center;
    padding: 40px 20px 40px 20px;
    margin-top: 70px; /* fixes overlap with navbar */
    transition: margin-left 0.3s ease;
}

        body.sidebar-collapsed .faq-container {
            margin-left: var(--sb-collapsed);
        }

        body:not(.sidebar-collapsed) .faq-container {
            margin-left: var(--sb-expanded);
        }

        .card-box {
            width: 100%;
            max-width: 900px;
            padding: 40px;
            background: #ffffff;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
        }

        .card-box h2 {
            color: #007bff;
            font-weight: 600;
        }

        .faq-box {
            margin-bottom: 20px;
            padding: 20px;
            background-color: #f8f9fa;
            border-left: 5px solid #007bff;
            border-radius: 10px;
        }

        .question {
            font-weight: bold;
            color: #2c3e50;
        }

        .answer {
            margin-top: 8px;
            color: #555;
        }

        .back-btn {
            text-align: center;
            margin-top: 30px;
        }

        .btn-outline-primary {
            padding: 10px 20px;
            font-weight: 500;
        }
    </style>
</head>
<body class="sidebar-collapsed">

<%-- Include Header and Sidebar Fragments --%>
<% if ("consumer".equalsIgnoreCase(role)) { %>
    <jsp:include page="/WEB-INF/fragments/consumer_header.jsp"/>
    <jsp:include page="/WEB-INF/fragments/consumer_sidebar.jsp"/>
<% } else { %>
    <jsp:include page="/WEB-INF/fragments/seller_header.jsp"/>
    <jsp:include page="/WEB-INF/fragments/seller_sidebar.jsp"/>
<% } %>

<div class="faq-container">
    <div class="card-box">
        <h2><i class="bi bi-question-circle-fill me-2"></i>Frequently Asked Questions</h2>
        <%
            String[][] faqs = {
                {"What is this Import Export System?", "This is a web portal designed to manage and automate the entire process of import and export, including registration, product listing, order management, shipment tracking, and documentation."},
                {"Who can register on this system?", "Importers, exporters, transporters, and customs agents can register and manage their operations using this platform."},
                {"Is it necessary to register to use the system?", "Yes, only registered users can access the dashboard, manage orders, and track shipments."},
                {"How do I register as an importer/exporter?", "Click on the 'Register' button on the homepage, choose your role, and fill in your personal and business details."},
                {"I forgot my password. What should I do?", "Use the 'Forgot Password' option on the login page to reset your password using your registered email."},
                {"How can I add my products for export?", "Go to your exporter dashboard, click on 'Add Product,' and fill in all product details like name, category, quantity, and price."},
                {"How can I track the status of my order?", "Go to the 'My Orders' section in your dashboard. You can view statuses like 'Requested,' 'Approved,' 'Shipped,' 'Delivered.'"},
                {"How is shipment handled in this system?", "The exporter selects a transporter. Shipment status is updated in real-time."},
                {"Are customs clearances managed through this system?", "Yes. Customs agents can log in, verify documents, and approve shipments digitally."},
                {"Is my data safe on this platform?", "Yes, we use secure protocols and encrypt sensitive business data for protection."}
            };
            for (int i = 0; i < faqs.length; i++) {
        %>
            <div class="faq-box">
                <div class="question">Q. <%= faqs[i][0] %></div>
                <div class="answer">Ans. <%= faqs[i][1] %></div>
            </div>
        <%
            }
        %>

        <div class="back-btn">
            <a href="<%= dashboardPage %>" class="btn btn-outline-primary">
                <i class="bi bi-arrow-left-circle me-1"></i> Back to Dashboard
            </a>
        </div>
    </div>
</div>

<script>
    const toggleBtn = document.querySelector('#sidebarToggle');
    toggleBtn?.addEventListener('click', () => {
        document.body.classList.toggle('sidebar-collapsed');
    });
</script>
</body>
</html>
