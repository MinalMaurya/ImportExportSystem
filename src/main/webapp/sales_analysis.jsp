<%@ page contentType="text/html;charset=UTF-8" language="java" session="true" %>
<%@ page import="java.util.*, model.SalesPojo" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<SalesPojo> salesList = (List<SalesPojo>) request.getAttribute("salesList");
    List<SalesPojo> top5 = (List<SalesPojo>) request.getAttribute("top5");

    double totalSales = (double) request.getAttribute("totalSales");
    int totalUnits = (int) request.getAttribute("totalUnits");
    double profitLoss = (double) request.getAttribute("profitLoss");

    String fromDate = (String) request.getAttribute("fromDate");
    String toDate = (String) request.getAttribute("toDate");
    String selected = (String) request.getAttribute("period");
    int selectedYear = 0;
    if (fromDate != null && fromDate.length() >= 4) {
        selectedYear = Integer.parseInt(fromDate.substring(0, 4));
    }
    int currentYear = java.time.Year.now().getValue();
    int startYear = currentYear - 10;  // show 10 years before
    int endYear = currentYear + 5; 
    List<String> chartLabels = new ArrayList<>();
    List<Double> chartValues = new ArrayList<>();

    for (SalesPojo sp : salesList) {
        chartLabels.add(sp.getProductName()); // or sp.getOrderDate() for trend
        chartValues.add(sp.getTotalSales());
    }
    String period = (String) request.getAttribute("period");
    request.setAttribute("chartLabels", chartLabels);
    request.setAttribute("chartValues", chartValues);
    request.setAttribute("period", period);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Sales Analysis</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/>
    
    <link href="css/sidebar.css" rel="stylesheet"/>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
       <style>
    main {
        margin-left: var(--sb-expanded);
        transition: margin-left 0.3s ease;
    }
    #sidebar.sidebar-collapsed + main {
        margin-left: var(--sb-collapsed);
    }
    .main-content {
        transition: margin-left 0.3s ease;
        padding-top: 88px; /* <-- fixes overlap with navbar */
    }
    .highlight-card {
        background: #f8f9fa;
        border-radius: 10px;
        box-shadow: 0 0 10px rgba(0,0,0,0.1);
        padding: 4rem;
        text-align: center;
    }
    /* Sales Stats Cards */
.stats-row .card {
  position: relative;
  border: none;
  border-radius: 1rem;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  background: linear-gradient(135deg, #fff 0%, #f0f4ff 100%);
  transition: transform 0.3s, box-shadow 0.3s;
}
.stats-row .card:hover {
  transform: translateY(-6px);
  box-shadow: 0 12px 24px rgba(0, 0, 0, 0.1);
}
.stats-row .card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 4px;
  height: 100%;
  background: transparent;
  transition: background 0.3s;
}
.stats-row .card:hover::before {
  background: #1f3c88;
}

/* Card Icons */
.stats-row .card-body .bi {
  width: 3.5rem;
  height: 3.5rem;
  font-size: 1.75rem;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(31, 60, 136, 0.1);
  border-radius: 50%;
  margin: 0 auto 0.75rem;
  transition: background 0.3s, color 0.3s;
}
.stats-row .card:hover .bi {
  background: #1f3c88;
  color: #fff;
}

/* Heading + Value */
.stats-row h6 {
  font-weight: 600;
  color: #333;
}
.stats-row h5 {
  font-weight: 700;
  color: #1f3c88;
}
    </style>
</head>
   <body class="sidebar-expanded"> <%-- Default expanded --%>

  <!-- Fixed Navbar -->
  <jsp:include page="/WEB-INF/fragments/seller_header.jsp"/>

  <!-- Flex container -->
  <div class="d-flex">
    <jsp:include page="/WEB-INF/fragments/seller_sidebar.jsp"/>
   

    <!-- Main Content -->
    <div class="main-content container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="m-0">📊 Sales Analysis</h2>
    
    <a href="ExportSalesCsvServlet?period=<%=period%>
      <% if ("monthly".equals(period)) { %>
        &fromMonth=<%= request.getParameter("fromMonth") %>&toMonth=<%= request.getParameter("toMonth") %>
      <% } else if ("yearly".equals(period)) { %>
        &year=<%= request.getParameter("year") %>
      <% } else if ("custom".equals(period)) { %>
        &fromDate=<%= request.getParameter("fromDate") %>&toDate=<%= request.getParameter("toDate") %>
      <% } %>" 
      class="btn btn-success">
      ⬇ Download CSV
    </a>
   </div>
        <!-- Dropdown Period Filter -->
        <!-- Dropdown Period Filter -->
<form action="SalesAnalysisServlet" method="get" class="row g-3 mb-4" id="filterForm">
  <div class="col-md-3">
    <select name="period" class="form-select" id="periodSelect" onchange="toggleDateFields()">
      <option value="last7" <%= "last7".equals(selected) ? "selected" : "" %>>Last 7 Days</option>
      <option value="monthly" <%= "monthly".equals(selected) ? "selected" : "" %>>Monthly</option>
      <option value="yearly" <%= "yearly".equals(selected) ? "selected" : "" %>>Yearly</option>
      <option value="custom" <%= "custom".equals(selected) ? "selected" : "" %>>Custom</option>
    </select>
  </div>

  <!-- Monthly Month Selector -->
  <div class="col-md-3" id="monthlyFields" style="display: none;">
    <label>Select Month Range</label>
    <div class="d-flex gap-2">
       <select name="fromMonth" class="form-select">
      <option value="">From</option>
      <% for (int i = 1; i <= 12; i++) { %>
        <option value="<%= i %>"><%= new java.text.DateFormatSymbols().getMonths()[i-1] %></option>
      <% } %>
    </select>
    <select name="toMonth" class="form-select">
      <option value="">To</option>
      <% for (int i = 1; i <= 12; i++) { %>
        <option value="<%= i %>"><%= new java.text.DateFormatSymbols().getMonths()[i-1] %></option>
      <% } %>
    </select>
    </div>
  </div>

  <!-- Yearly Year Selector -->
  <div class="col-md-3" id="yearlyFields" style="display: none;">
    <label>Select Year</label>
    <select name="year" class="form-select" onchange="this.form.submit()">
    <% for (int y = startYear; y <= endYear; y++) { %>
        <option value="<%= y %>" <%= (y == selectedYear ? "selected" : "") %>>
            <%= y %>
        </option>
    <% } %>
</select>
  </div>

  <!-- Custom Date Range -->
  <div class="col-md-3" id="customFields" style="display: none;">
    <label>From</label>
    <input type="date" name="fromDate" value="<%= fromDate %>" class="form-control"/>
  </div>
  <div class="col-md-3" id="customToDate" style="display: none;">
    <label>To</label>
    <input type="date" name="toDate" value="<%= toDate %>" class="form-control"/>
  </div>

  <div class="col-md-2 align-self-end">
    <button class="btn btn-primary w-100">Apply</button>
  </div>
  <div>
</form>

  <!-- Metric Cards using .stats-row styling -->
<div class="row stats-row mb-4">
  <div class="col-md-3">
    <div class="card text-center">
      <div class="card-body">
        <i class="bi bi-currency-rupee"></i>
        <h6 class="mt-2">Total Sales</h6>
        <h5 class="fw-bold">₹<%= String.format("%.2f", totalSales) %></h5>
      </div>
    </div>
  </div>

  <div class="col-md-3">
    <div class="card text-center">
      <div class="card-body">
        <i class="bi bi-box-seam"></i>
        <h6 class="mt-2">Total Units Sold</h6>
        <h5 class="fw-bold"><%= totalUnits %></h5>
      </div>
    </div>
  </div>

  <div class="col-md-3">
    <div class="card text-center">
      <div class="card-body">
        <i class="bi bi-graph-up-arrow"></i>
        <h6 class="mt-2">Avg Order Value</h6>
        <h5 class="fw-bold">₹<%= totalUnits > 0 ? String.format("%.2f", totalSales / totalUnits) : "0.00" %></h5>
      </div>
    </div>
  </div>

  <div class="col-md-3">
    <div class="card text-center">
      <div class="card-body">
        <i class="bi bi-calendar-range"></i>
        <h6 class="mt-2">Date Range</h6>
        <h6 class="fw-semibold"><small><%= fromDate %> → <%= toDate %></small></h6>
      </div>
    </div>
  </div>
</div>
<div class="card mb-4">
  <div class="card-header bg-info text-white">📈 Sales Overview</div>
  <div class="card-body">
    <canvas id="salesChart" height="100"></canvas>
  </div>
</div>
        <!-- Top Products Table -->
        <div class="card mb-4">
            <div class="card-header bg-primary text-white">Top 5 Products</div>
            <div class="table-responsive">
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                        <tr>
                            <th>#</th>
                            <th>Product</th>
                            <th>Units Sold</th>
                            <th>Unit Cost</th>
                            <th>Total Sales</th>
                            <th>Last Ordered</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (top5 != null && !top5.isEmpty()) {
                            int i = 1;
                            for (SalesPojo sp : top5) { %>
                        <tr>
                            <td><%= i++ %></td>
                            <td><%= sp.getProductName() %></td>
                            <td><%= sp.getTotalUnitsSold() %></td>
                            <td>₹<%= String.format("%.2f", sp.getUnitCost()) %></td>
                            <td>₹<%= String.format("%.2f", sp.getTotalSales()) %></td>
                            <td><%= sp.getLastOrderDate() %></td>
                        </tr>
                        <% } } else { %>
                        <tr><td colspan="6" class="text-center text-muted">No data available.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <script>
      const sidebar = document.querySelector("#sidebar");
      const main = document.querySelector("main");
      const observer = new MutationObserver(() => {
          if (sidebar.classList.contains("sidebar-collapsed")) {
              main.style.marginLeft = getComputedStyle(document.documentElement).getPropertyValue('--sb-collapsed');
          } else {
              main.style.marginLeft = getComputedStyle(document.documentElement).getPropertyValue('--sb-expanded');
          }
      });
      observer.observe(sidebar, { attributes: true });
      function toggleDateFields() {
    	  const period = document.getElementById("periodSelect").value;

    	  document.getElementById("monthlyFields").style.display = (period === "monthly") ? "block" : "none";
    	  document.getElementById("yearlyFields").style.display = (period === "yearly") ? "block" : "none";
    	  document.getElementById("customFields").style.display = (period === "custom") ? "block" : "none";
    	  document.getElementById("customToDate").style.display = (period === "custom") ? "block" : "none";
    	}

    	// Trigger on load
    	document.addEventListener("DOMContentLoaded", toggleDateFields);
    </script>
    <script>
  const chartLabels = [
    <% for (int i = 0; i < salesList.size(); i++) { %>
      "<%= salesList.get(i).getProductName() %>"<%= (i < salesList.size() - 1) ? "," : "" %>
    <% } %>
  ];

  const chartValues = [
    <% for (int i = 0; i < salesList.size(); i++) { %>
      <%= salesList.get(i).getTotalSales() %><%= (i < salesList.size() - 1) ? "," : "" %>
    <% } %>
  ];

  const ctx = document.getElementById('salesChart').getContext('2d');
  const salesChart = new Chart(ctx, {
    type: 'bar', // Change to 'line' if you want trend view
    data: {
      labels: chartLabels,
      datasets: [{
        label: 'Total Sales (₹)',
        data: chartValues,
        backgroundColor: 'rgba(31, 60, 136, 0.6)',
        borderColor: 'rgba(31, 60, 136, 1)',
        borderWidth: 1,
        hoverBackgroundColor: '#1f3c88',
        hoverBorderColor: '#1f3c88'
      }]
    },
    options: {
      responsive: true,
      scales: {
        y: {
          beginAtZero: true,
          title: {
            display: true,
            text: 'Sales in ₹'
          }
        },
        x: {
          title: {
            display: true,
            text: 'Products'
          }
        }
      },
      plugins: {
        legend: {
          display: false
        },
        tooltip: {
          callbacks: {
            label: (context) => `₹${context.parsed.y.toFixed(2)}`
          }
        }
      }
    }
  });
</script>
<script>
  function downloadCSV() {
    const labels = <%= new com.google.gson.Gson().toJson(chartLabels) %>;
    const values = <%= new com.google.gson.Gson().toJson(chartValues) %>;

    if (!labels || labels.length === 0) {
      alert("No sales data to download.");
      return;
    }

    let csvContent = "Product Name,Total Sales (₹)\n";

    for (let i = 0; i < labels.length; i++) {
      csvContent += `"${labels[i]}",${values[i]}\n`;
    }

    // Create file and trigger download
    const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");

    const period = document.getElementById("periodSelect").value;
    const fileName = "Sales_" + period + "_" + new Date().toISOString().split("T")[0] + ".csv";

    link.setAttribute("href", url);
    link.setAttribute("download", fileName);
    link.style.visibility = "hidden";
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }
</script>
</body>
</html>