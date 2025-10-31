package Controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import model.SalesPojo;

@WebServlet("/ExportSalesCsvServlet")
public class ExportSalesCsvServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Retrieve list from request scope (it must be set via servlet forward before export)
        List<SalesPojo> salesList = (List<SalesPojo>) request.getAttribute("salesList");

        // Fallback if list is null (due to redirect): fetch from session (safer)
        if (salesList == null) {
            salesList = (List<SalesPojo>) request.getSession().getAttribute("salesList");
        }

        if (salesList == null || salesList.isEmpty()) {
            response.setContentType("text/plain");
            response.getWriter().println("No sales data available to export.");
            return;
        }

        // Set headers for CSV download
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"Sales_Report.csv\"");
        PrintWriter out = response.getWriter();

        // Write CSV header
        out.println("Product Name,Units Sold,Unit Cost,Total Sales,Last Ordered");

        // Write rows
        for (SalesPojo pojo : salesList) {
            out.printf("\"%s\",%d,%.2f,%.2f,%s\n",
                    pojo.getProductName(),
                    pojo.getTotalUnitsSold(),
                    pojo.getUnitCost(),
                    pojo.getTotalSales(),
                    pojo.getLastOrderDate());
        }

        out.flush();
        out.close();
    }
}
