package model;

import java.sql.Timestamp;

public class CartPojo {
    private int cartId;
    private String consumerId;
    private int productId;
    private String productName;
    private double price;
    private int quantity;
    private double total;
    private Timestamp addedOn;

    // Getters & Setters
    public int getCartId() {
        return cartId;
    }
    public void setCartId(int cartId) {
        this.cartId = cartId;
    }

    public String getConsumerId() {
        return consumerId;
    }
    public void setConsumerId(String consumerId) {
        this.consumerId = consumerId;
    }

    public int getProductId() {
        return productId;
    }
    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }
    public void setProductName(String productName) {
        this.productName = productName;
    }

    public double getPrice() {
        return price;
    }
    public void setPrice(double price) {
        this.price = price;
    }

    public int getQuantity() {
        return quantity;
    }
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getTotal() {
        return total;
    }
    public void setTotal(double total) {
        this.total = total;
    }

public Timestamp getAddedOn() {
    return addedOn;
}

public void setAddedOn(Timestamp addedOn) {
    this.addedOn = addedOn;
}
}
