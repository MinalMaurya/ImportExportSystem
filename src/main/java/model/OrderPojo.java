package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class OrderPojo implements Serializable {
    private static final long serialVersionUID = 1L;

    private int         orderId;
    private String      consumerPortId;
    private String consumerLocation;
    private String      sellerPortId;
    private int         productId;
    private String      productName;
    private int         quantity;
    private Timestamp   orderDate;
    private BigDecimal  totalAmount;
    private String      status;

    // --- getters / setters ---
    public int getOrderId()                     { return orderId; }
    public void setOrderId(int orderId)         { this.orderId = orderId; }

    public String getConsumerPortId()                    { return consumerPortId; }
    public void setConsumerPortId(String consumerPortId) { this.consumerPortId = consumerPortId; }

    public String getSellerPortId()                  { return sellerPortId; }
    public void setSellerPortId(String sellerPortId) { this.sellerPortId = sellerPortId; }

    public int getProductId()                  { return productId; }
    public void setProductId(int productId)    { this.productId = productId; }

    public String getProductName()                 { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public int getQuantity()                  { return quantity; }
    public void setQuantity(int quantity)     { this.quantity = quantity; }

    public Timestamp getOrderDate()               { return orderDate; }
    public void setOrderDate(Timestamp orderDate){ this.orderDate = orderDate; }

    public BigDecimal getTotalAmount()              { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmt) { this.totalAmount = totalAmt; }

    public String getStatus()                  { return status; }
    public void setStatus(String status)      { this.status = status; }

    public String getConsumerLocation() {
        return consumerLocation;
    }
    public void setConsumerLocation(String consumerLocation) {
        this.consumerLocation = consumerLocation;
    }
}
