package model;

import java.io.Serializable;

public class Product_pojo implements Serializable {
	private static final long serialVersionUID = 1L;

	private int productId;
	private String sellerPortId;
	private String productName;
	private int quantity;
	private double price;

	public Product_pojo() {
	}

	public Product_pojo(int productId, String sellerPortId, String productName, String description, int quantity,
			double price) {
		this.productId = productId;
		this.sellerPortId = sellerPortId;
		this.productName = productName;
		this.quantity = quantity;
		this.price = price;
	}

	public int getProductId() {
		return productId;
	}

	public void setProductId(int productId) {
		this.productId = productId;
	}

	public String getSellerPortId() {
		return sellerPortId;
	}

	public void setSellerPortId(String sellerPortId) {
		this.sellerPortId = sellerPortId;
	}

	public String getProductName() {
		return productName;
	}

	public void setProductName(String productName) {
		this.productName = productName;
	}

	public int getQuantity() {
		return quantity;
	}

	public void setQuantity(int quantity) {
		this.quantity = quantity;
	}

	public double getPrice() {
		return price;
	}

	public void setPrice(double price) {
		this.price = price;
	}

	@Override
	public String toString() {
		return "Product_pojo{" + "productId=" + productId + ", sellerPortId='" + sellerPortId + '\'' + ", productName='"
				+ productName + '\'' + ", quantity=" + quantity + ", price="
				+ price + '}';
	}
}
