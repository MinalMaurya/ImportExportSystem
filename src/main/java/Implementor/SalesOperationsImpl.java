package Implementor;

import java.sql.*;
import java.sql.Date;
import java.util.*;
import db_config.GetConnection;
import model.SalesPojo;
import Operation.SalesOperations;

public class SalesOperationsImpl implements SalesOperations {
    @Override
    public List<SalesPojo> getSalesReport(String sellerId, String period, String fromDate, String toDate) {
        List<SalesPojo> sales = new ArrayList<>();
        String proc = period.equalsIgnoreCase("monthly")
                   ? "{ call get_seller_sales_monthly_with_dates(?, ?, ?) }"
                   : "{ call get_seller_sales_yearly_with_dates(?, ?, ?) }";
        try (Connection conn = GetConnection.getConnection();
             CallableStatement cs = conn.prepareCall(proc)) {

            cs.setString(1, sellerId);
            cs.setDate(2, Date.valueOf(fromDate));
            cs.setDate(3, Date.valueOf(toDate));

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    sales.add(new SalesPojo(
                        rs.getString("product_name"),
                        rs.getInt("total_units_sold"),
                        rs.getDouble("unit_cost"),
                        rs.getDouble("total_sales"),
                        rs.getDate("last_order_date")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return sales;
    }
}
