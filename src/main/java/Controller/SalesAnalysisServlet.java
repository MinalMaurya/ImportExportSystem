package Controller;

import Implementor.SalesOperationsImpl;
import model.SalesPojo;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.*;

@WebServlet("/SalesAnalysisServlet")
public class SalesAnalysisServlet extends HttpServlet {
    private final SalesOperationsImpl ops = new SalesOperationsImpl();
    private final DateTimeFormatter   fmt = DateTimeFormatter.ISO_LOCAL_DATE;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String sellerId = session != null
                        ? (String) session.getAttribute("seller_port_id")
                        : null;
        if (sellerId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // 1) Figure date range
        String period = Optional.ofNullable(req.getParameter("period")).orElse("last7");
        LocalDate today = LocalDate.now(), from, to = today;

        switch (period) {
        case "monthly" -> {
            int fromMonth = Integer.parseInt(req.getParameter("fromMonth"));
            int toMonth   = Integer.parseInt(req.getParameter("toMonth"));
            int currentYear = LocalDate.now().getYear(); // You can also use a year param

            from = LocalDate.of(currentYear, fromMonth, 1);
            to   = LocalDate.of(currentYear, toMonth, 1).withDayOfMonth(
                       LocalDate.of(currentYear, toMonth, 1).lengthOfMonth());
        }
        case "yearly" -> {
            int year = Integer.parseInt(req.getParameter("year"));
            from = LocalDate.of(year, 1, 1);
            to   = LocalDate.of(year, 12, 31);
        }
        case "custom" -> {
            from = LocalDate.parse(req.getParameter("fromDate"), fmt);
            to   = LocalDate.parse(req.getParameter("toDate"), fmt);
        }
        default -> from = today.minusDays(7);
      }

        // 2) Fetch data
        List<SalesPojo> allSales = ops.getSalesReport(
            sellerId, period, from.toString(), to.toString()
        );
        System.out.println("▶ Session seller_port_id: " + sellerId);
        System.out.println("▶ From date: " + from + " | To date: " + to);
        System.out.println("▶ Sales fetched: " + allSales.size());

        // 3) Metrics
        double totalSales = allSales.stream()
                                    .mapToDouble(SalesPojo::getTotalSales)
                                    .sum();
        int    totalUnits = allSales.stream()
                                    .mapToInt(SalesPojo::getTotalUnitsSold)
                                    .sum();
        double totalCost  = allSales.stream()
                                    .mapToDouble(sp ->
                                        sp.getUnitCost() * sp.getTotalUnitsSold())
                                    .sum();
        double profitLoss = totalSales - totalCost;

        // Top/Bottom 5
        List<SalesPojo> top5 = allSales.stream()
            .sorted(Comparator.comparingInt(SalesPojo::getTotalUnitsSold).reversed())
            .limit(10).toList();
        List<SalesPojo> bot5 = allSales.stream()
            .sorted(Comparator.comparingInt(SalesPojo::getTotalUnitsSold))
            .limit(10).toList();
        System.out.println("▶︎ SalesAnalysisServlet fetched " + allSales.size() + " rows for " + sellerId);
        // 4) Forward
        req.setAttribute("salesList",  allSales);
        req.getSession().setAttribute("salesList", allSales);
        req.setAttribute("totalSales", totalSales);
        req.setAttribute("totalUnits", totalUnits);
        req.setAttribute("profitLoss", profitLoss);
        req.setAttribute("top5",       top5);
        req.setAttribute("bot5",       bot5);
        req.setAttribute("fromDate",   from.toString());
        req.setAttribute("toDate",     to.toString());
        req.setAttribute("period",     period);

        req.getRequestDispatcher("/sales_analysis.jsp")
        .forward(req, resp);
    }
}
