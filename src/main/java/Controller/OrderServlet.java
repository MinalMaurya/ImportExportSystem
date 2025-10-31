package Controller;

import Operation.OrderOperation;
import Operation.ProductOperations;
import db_config.GetConnection;
import Implementor.OrderImp;
import Implementor.ProductImplementor;
import model.CartPojo;
import model.OrderPojo;
import model.Product_pojo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.util.List;

@WebServlet("/OrderServlet")
public class OrderServlet extends HttpServlet {
    private final OrderOperation   orderOp   = new OrderImp();
    private final ProductOperations productOp = new ProductImplementor();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");

        try {
            if ("viewProducts".equals(action)) {
                // show all products to consumer
                List<Product_pojo> products = productOp.getAllProducts();
                req.setAttribute("productList", products);
                req.getRequestDispatcher("/view_products.jsp")
                   .forward(req, resp);

            } else if ("myOrders".equals(action) && username != null) {
                // consumer’s order history
                List<OrderPojo> orders = orderOp.getOrders(username);
                req.setAttribute("orderList", orders);
                req.getRequestDispatcher("/my_orders.jsp")
                   .forward(req, resp);

            }  else if ("track".equals(action)) {
                if (username != null) {
                	
                	
                    String oidParam = req.getParameter("orderId");
                    String searchParam = req.getParameter("search");
                    OrderPojo tracked = null;

                    // fetch recent orders first
                    List<OrderPojo> allOrders = orderOp.getOrders(username);
                    req.setAttribute("orderList", allOrders);

                    if (oidParam != null) {
                        try {
                            int oid = Integer.parseInt(oidParam);
                            tracked = orderOp.trackOrder(username, oid);
                            if (tracked != null) {
                                req.setAttribute("trackedOrder", tracked);
                            } else {
                                req.setAttribute("error", "No such order found for your account.");
                            }
                        } catch (NumberFormatException e) {
                            req.setAttribute("error", "Invalid Order ID format.");
                        }
                    }

                    // search filter (optional)
                    if (searchParam != null && !searchParam.trim().isEmpty()) {
                        String searchTerm = searchParam.trim().toLowerCase();
                        List<OrderPojo> matched = allOrders.stream()
                            .filter(o -> String.valueOf(o.getOrderId()).contains(searchTerm) ||
                                         o.getProductName().toLowerCase().contains(searchTerm))
                            .toList();
                        if (!matched.isEmpty()) {
                            req.setAttribute("filteredOrders", matched);
                        } else {
                            req.setAttribute("searchNotFound", true);
                        }
                    }
                }

                req.getRequestDispatcher("/track_order_form.jsp").forward(req, resp);
            }else if ("viewSellerOrders".equals(action) && "seller".equals(role)) {
                // seller’s order list & status‐update UI
                List<OrderPojo> orders = orderOp.getOrdersBySeller(username);
                req.setAttribute("orders", orders);
                req.getRequestDispatcher("/seller_orders.jsp")
                   .forward(req, resp);

            }else if ("addToCart".equals(action)) {
                String productIdStr = req.getParameter("productId");

                if (productIdStr != null) {
                    int productId = Integer.parseInt(productIdStr);
                    Product_pojo product = orderOp.getProductDetails(productId);

                    if (product != null) {
                        // Add product to cart in DB or session logic (not needed here since POST handles it)
                        // Instead, redirect to the product view page with a success flag
                        resp.sendRedirect(req.getContextPath() + "/OrderServlet?action=viewProducts&added=true");
                        return;
                    }
                }

                resp.sendRedirect(req.getContextPath() + "/ConsumerServlet?action=viewProducts");
            }
                
            else if ("viewCart".equals(action) && username != null) {
                List<CartPojo> cartItems = orderOp.getCartItems(username);
                req.setAttribute("cartList", cartItems);
                req.getRequestDispatcher("/view_cart.jsp").forward(req, resp);
            }else {
                // fallback → consumer dashboard
                resp.sendRedirect(req.getContextPath() + "/ConsumerDash.jsp");
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }


    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        HttpSession session = req.getSession(false);
        String consumerPortId = (session != null) ? (String) session.getAttribute("username") : null;

        if (consumerPortId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        try {
            switch (action) {
                case "placeOrder" -> {
                    int productId = Integer.parseInt(req.getParameter("productId"));
                    int qty = Integer.parseInt(req.getParameter("quantity"));

                    Product_pojo prod = productOp.getProductById(productId);
                    BigDecimal total = BigDecimal.valueOf(prod.getPrice()).multiply(BigDecimal.valueOf(qty));

                    OrderPojo order = new OrderPojo();
                    order.setConsumerPortId(consumerPortId);
                    order.setSellerPortId(prod.getSellerPortId());
                    order.setProductId(productId);
                    order.setQuantity(qty);
                    order.setTotalAmount(total);

                    boolean success = orderOp.placeOrder(order);
                    String target = req.getContextPath() + "/OrderServlet?action=myOrders";
                    target += success ? "&success=true" : "&error=Could+not+place+order";
                    resp.sendRedirect(target);
                }

                case "cancelOrder" -> {
                    int oid = Integer.parseInt(req.getParameter("orderId"));
                    orderOp.cancelOrder(oid);
                    resp.sendRedirect(req.getContextPath() + "/OrderServlet?action=myOrders&cancelled=true");
                }

                case "updateOrderStatus" -> {
                    int oid = Integer.parseInt(req.getParameter("orderId"));
                    String newStatus = req.getParameter("newStatus");
                    boolean success = orderOp.updateOrderStatus(oid, newStatus);

                    String target = req.getContextPath() + "/OrderServlet?action=viewSellerOrders";
                    target += success ? "&status=updated" : "&error=Status+update+failed";
                    resp.sendRedirect(target);
                }

                case "addToCart" -> {
                    int productId = Integer.parseInt(req.getParameter("productId"));
                    int quantity = Integer.parseInt(req.getParameter("quantity"));

                    try (Connection con = GetConnection.getConnection();
                         CallableStatement cs = con.prepareCall("{call add_to_cart(?, ?, ?)}")) {
                        cs.setString(1, consumerPortId);
                        cs.setInt(2, productId);
                        cs.setInt(3, quantity);
                        cs.execute();
                    }

                    resp.sendRedirect(req.getContextPath() + "/OrderServlet?action=viewCart&added=true");
                }

                case "deleteCartItem" -> {
                    int cartId = Integer.parseInt(req.getParameter("cartId"));
                    boolean deleted = orderOp.deleteCartItem(cartId);
                    resp.sendRedirect(req.getContextPath() + "/OrderServlet?action=viewCart" +
                            (deleted ? "&deleted=true" : "&error=Could+not+delete+item"));
                }

                case "updateCartItem" -> {
                    int cartId = Integer.parseInt(req.getParameter("cartId"));
                    int quantity = Integer.parseInt(req.getParameter("quantity"));

                    boolean success = orderOp.updateCartItem(cartId, quantity);

                    if (success) {
                        resp.sendRedirect(req.getContextPath() + "/OrderServlet?action=viewCart&success=true");
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/OrderServlet?action=viewCart&error=Update+failed");
                    }
                }

                case "confirmSingleCartItem" -> {
                    int cartId = Integer.parseInt(req.getParameter("cartId"));

                    boolean success = orderOp.confirmSingleCartItem(cartId, consumerPortId);

                    if (success) {
                        resp.sendRedirect(req.getContextPath() + "/OrderServlet?action=myOrders&success=true");
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/OrderServlet?action=viewCart&error=Order+confirmation+failed");
                    }
                }

                case "confirmCartOrder" -> {
                    boolean ok = orderOp.confirmAllCartItems(consumerPortId);
                    String suffix = ok ? "&confirmed=all" : "&error=Cart+confirm+failed";
                    resp.sendRedirect(req.getContextPath() + "/OrderServlet?action=viewCart" + suffix);
                }

                default -> {
                    // Action is either missing or invalid
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
                }
            }
        } catch (NumberFormatException ex) {
            req.setAttribute("error", "Invalid input format.");
            doGet(req, resp);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }
    }
