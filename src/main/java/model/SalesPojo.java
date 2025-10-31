package model;

import java.sql.Date;

public class SalesPojo {
    private String productName;
    private int totalUnitsSold;
    private double unitCost;
    private double totalSales;
    private Date lastOrderDate;

    public SalesPojo(String productName, int totalUnitsSold, double unitCost, double totalSales, Date lastOrderDate) {
        this.productName = productName;
        this.totalUnitsSold = totalUnitsSold;
        this.unitCost = unitCost;
        this.totalSales = totalSales;
        this.lastOrderDate = lastOrderDate;
    }

    public String getProductName() {
        return productName;
    }

    public int getTotalUnitsSold() {
        return totalUnitsSold;
    }

    public double getUnitCost() {
        return unitCost;
    }

    public double getTotalSales() {
        return totalSales;
    }

    public Date getLastOrderDate() {
        return lastOrderDate;
    }
}
