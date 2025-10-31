package Operation;

import java.util.List;

import model.CartPojo;
import model.OrderPojo;
import model.Product_pojo;

public interface OrderOperation {
    List<Product_pojo> getAllProducts() throws Exception;
    boolean placeOrder(OrderPojo order) throws Exception;
    List<OrderPojo> getOrders(String consumerPortId) throws Exception;
    boolean cancelOrder(int orderId) throws Exception;
    boolean submitReview(int orderId, String review) throws Exception;
    OrderPojo trackOrder(String consumerPortId, int orderId) throws Exception;
    List<OrderPojo> getOrdersBySeller(String sellerPortId) throws Exception;
    boolean updateOrderStatus(int orderId, String newStatus) throws Exception;
    Product_pojo getProductDetails(int productId);
    boolean placeOrder(int productId, String consumerPortId, int quantity, double price, String location);
    List<CartPojo> getCartItems(String consumerId) throws Exception;
    boolean deleteCartItem(int cartId);
    boolean updateCartItem(int cartId, int quantity) throws Exception;

    boolean confirmSingleCartItem(int cartId, String consumerPortId) throws Exception;

    boolean confirmAllCartItems(String consumerPortId) throws Exception;
}
