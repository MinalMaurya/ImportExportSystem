package Operation;

import java.util.List;

import model.SalesPojo;

public interface SalesOperations {
    List<SalesPojo> getSalesReport(String sellerId, String period, String fromDate, String toDate);
}
