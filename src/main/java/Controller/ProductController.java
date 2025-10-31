package Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import Implementor.ProductImplementor;
import model.Product_pojo;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.UUID;

@WebServlet("/ProductController")
public class ProductController extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private ProductImplementor service;

	@Override
	public void init() throws ServletException {
		service = new ProductImplementor();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
	        throws ServletException, IOException {

	    // 1) Ensure seller is logged in
	    HttpSession session = request.getSession(false);
	    String sellerPortId = (session != null)
	        ? (String) session.getAttribute("seller_port_id")
	        : null;
	    if (sellerPortId == null || sellerPortId.isBlank()) {
	        response.sendRedirect("login.jsp?error=Please+login");
	        return;
	    }

	    String action = request.getParameter("action");
	    String msg;

	    try {
	        switch (action.toLowerCase()) {

	            case "add": {
	                Product_pojo p = buildProductFromRequest(request, sellerPortId);
	                boolean success = service.addProduct(p);
	                msg = success
	                    ? "✅ Product added successfully!"
	                    : "❌ Failed to add product.";
	                break;
	            }

	            case "update": {
	            	Product_pojo p = buildProductWithDelta(request, sellerPortId);
	            	p.setProductId(Integer.parseInt(request.getParameter("product_id")));
	            	boolean success = service.updateProduct(p);
	                msg = success
	                    ? "✅ Product updated successfully!"
	                    : "❌ Failed to update product.";
	                break;
	            }

	            case "delete": {
	                int productId = Integer.parseInt(request.getParameter("product_id"));
	                boolean success = service.deleteProduct(productId);
	                msg = success
	                    ? "🗑️ Product deleted successfully!"
	                    : "❌ Failed to delete product.";
	                break;
	            }

	            case "edit-form": {
	                // 3) Forward into JSP so you see both form (pre-filled) + table
	                int productId = Integer.parseInt(request.getParameter("product_id"));
	                Product_pojo editProduct = service.getProductById(productId);

	                request.setAttribute("editProduct", editProduct);
	                request.setAttribute("seller_port_id", sellerPortId);
	                request.setAttribute(
	                    "productList",
	                    service.getAllProductsBySeller(sellerPortId)
	                );
	                request.getRequestDispatcher("List.jsp")
	                       .forward(request, response);
	                return;
	            }

	            default:
	                msg = "⚠️ Unknown action.";
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	        msg = "❌ Error: " + e.getMessage();
	    }

	    // 4) Redirect back to GET, carrying sellerPortId + msg for SweetAlert
	    String url = "ProductController"
	        + "?seller_port_id=" + URLEncoder.encode(sellerPortId, StandardCharsets.UTF_8)
	        + "&msg=" + URLEncoder.encode(msg, StandardCharsets.UTF_8);
	    response.sendRedirect(url);
	}

	// ✅ Builds Product POJO and ensures seller_port_id is valid
	private Product_pojo buildProductFromRequest(HttpServletRequest request, String sellerId) {
		Product_pojo p = new Product_pojo();

		if (sellerId == null || sellerId.trim().isEmpty()) {
			sellerId = "S" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
			System.out.println("🆕 Generated inside builder: " + sellerId);
		}

		p.setSellerPortId(sellerId);
		p.setProductName(request.getParameter("product_name"));

		try {
			p.setQuantity(Integer.parseInt(request.getParameter("quantity")));
		} catch (NumberFormatException e) {
			p.setQuantity(0);
			System.err.println("⚠️ Invalid quantity: " + e.getMessage());
		}

		try {
			p.setPrice(Double.parseDouble(request.getParameter("price")));
		} catch (NumberFormatException e) {
			p.setPrice(0.0);
			System.err.println("⚠️ Invalid price: " + e.getMessage());
		}

		return p;
	}
	/**
	 * Builds a Product POJO for updates by taking the original quantity
	 */
	private Product_pojo buildProductWithDelta(HttpServletRequest req, String sellerId) {
	    Product_pojo p = new Product_pojo();
	    p.setSellerPortId(sellerId);
	    p.setProductName(req.getParameter("product_name"));

	    int original = 0, delta = 0;
	    try {
	        original = Integer.parseInt(req.getParameter("original_quantity"));
	    } catch(Exception ignored) {}
	    try {
	        delta = Integer.parseInt(req.getParameter("quantity_delta"));
	    } catch(Exception ignored) {}

	    p.setQuantity(original + delta);

	    try {
	        p.setPrice(Double.parseDouble(req.getParameter("price")));
	    } catch(Exception ignored) {}

	    return p;
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String sellerPortId = request.getParameter("seller_port_id");

		if (sellerPortId == null || sellerPortId.trim().isEmpty()) {
			HttpSession session = request.getSession(false);
			if (session != null) {
				sellerPortId = (String) session.getAttribute("seller_port_id");
			}
		}

		if (sellerPortId == null || sellerPortId.trim().isEmpty()) {
			sellerPortId = "S001"; // fallback default
		}

		List<Product_pojo> list = service.getAllProductsBySeller(sellerPortId);
		request.setAttribute("productList", list);
		request.setAttribute("seller_port_id", sellerPortId);

		request.getRequestDispatcher("/List.jsp").forward(request, response);
		
	}
}
