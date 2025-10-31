package Implementor;

import Operation.OrderOperation;
import db_config.GetConnection;
import model.CartPojo;
import model.OrderPojo;
import model.Product_pojo;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderImp implements OrderOperation {  

  @Override
  public List<Product_pojo> getAllProducts() throws Exception {
    List<Product_pojo> list = new ArrayList<>();
    try (Connection c = GetConnection.getConnection();
         CallableStatement cs = c.prepareCall("{ call list_products() }");
         ResultSet rs = cs.executeQuery()) {
      while (rs.next()) {
        Product_pojo p = new Product_pojo();
        p.setProductId(    rs.getInt("product_id"));
        p.setSellerPortId( rs.getString("seller_port_id"));
        p.setProductName(  rs.getString("product_name"));
        p.setQuantity(     rs.getInt("quantity"));
        p.setPrice(        rs.getDouble("price"));
        list.add(p);
      }
    }
    return list;
  }

  @Override
  public boolean placeOrder(OrderPojo order) throws Exception {
      String insertSql = """
        INSERT INTO orders
          (consumer_port_id, seller_port_id, product_id, quantity, order_date, total_amount)
        VALUES (?,?,?,?,NOW(),?)
      """;

      String updateSql = """
        UPDATE products
        SET quantity = quantity - ?
        WHERE product_id = ?
          AND quantity >= ?
      """;

      try (Connection con = GetConnection.getConnection()) {
        //  Begin transaction
        con.setAutoCommit(false);

        //  Insert order
        try (PreparedStatement psInsert = con.prepareStatement(insertSql)) {
          psInsert.setString(1, order.getConsumerPortId());
          psInsert.setString(2, order.getSellerPortId());
          psInsert.setInt   (3, order.getProductId());
          psInsert.setInt   (4, order.getQuantity());
          psInsert.setBigDecimal(5, order.getTotalAmount());

          int inserted = psInsert.executeUpdate();
          if (inserted != 1) {
            con.rollback();
            return false;
          }
        }

        //  Decrement stock
        try (PreparedStatement psUpdate = con.prepareStatement(updateSql)) {
          psUpdate.setInt(1, order.getQuantity());
          psUpdate.setInt(2, order.getProductId());
          psUpdate.setInt(3, order.getQuantity());

          int updated = psUpdate.executeUpdate();
          if (updated != 1) {
            // either product not found or insufficient stock
            con.rollback();
            throw new SQLException("Insufficient stock or invalid product.");
          }
        }

        //  Commit both changes
        con.commit();
        return true;

      } catch (Exception e) {
        throw e;
      }
  }

  @Override
  public List<OrderPojo> getOrders(String consumerPortId) throws Exception {
      String sql =
        "SELECT\n" +
        "  o.order_id,\n" +
        "  o.consumer_port_id,\n" +
        "  o.seller_port_id,\n" +
        "  o.product_id,\n" +
        "  p.product_name,\n" +
        "  o.quantity,\n" +
        "  o.order_date,\n" +
        "  o.total_amount,\n" +
        "  CASE\n" +
        "    WHEN o.cancelled THEN 'Cancelled'\n" +
        "    WHEN o.delivered THEN 'Delivered'\n" +
        "    WHEN o.out_for_delivery THEN 'Out for Delivery'\n" +
        "    WHEN o.shipped THEN 'Shipped'\n" +
        "    ELSE 'Placed'\n" +
        "  END AS status\n" +                // ← no trailing comma here
        "FROM orders o\n" +
        "JOIN products p ON o.product_id = p.product_id\n" +
        "WHERE o.consumer_port_id = ?\n" +
        "ORDER BY o.order_date DESC";

      List<OrderPojo> list = new ArrayList<>();
      try (Connection con = GetConnection.getConnection();
           PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setString(1, consumerPortId);
        try (ResultSet rs = ps.executeQuery()) {
          while (rs.next()) {
            OrderPojo o = new OrderPojo();
            o.setOrderId(rs.getInt("order_id"));
            o.setConsumerPortId(rs.getString("consumer_port_id"));
            o.setSellerPortId(rs.getString("seller_port_id"));
            o.setProductId(rs.getInt("product_id"));
            o.setProductName(rs.getString("product_name"));
            o.setQuantity(rs.getInt("quantity"));
            o.setOrderDate(rs.getTimestamp("order_date"));
            o.setTotalAmount(rs.getBigDecimal("total_amount"));
            o.setStatus(rs.getString("status"));
            list.add(o);
          }
        }
      }
      return list;
  }

  @Override
  public boolean cancelOrder(int orderId) throws Exception {
      String selectSql    = "SELECT shipped, delivered, product_id, quantity FROM orders WHERE order_id = ?";
      String updateOrder  = "UPDATE orders SET cancelled=TRUE WHERE order_id=? AND cancelled=FALSE AND shipped=FALSE AND delivered=FALSE";
      String updateStock  = "UPDATE products SET quantity = quantity + ? WHERE product_id = ?";

      try (Connection con = GetConnection.getConnection()) {
          con.setAutoCommit(false);
          //  Read the current shipped/delivered flags + qty
          try (PreparedStatement ps = con.prepareStatement(selectSql)) {
              ps.setInt(1, orderId);
              try (ResultSet rs = ps.executeQuery()) {
                  if (!rs.next()) {
                      con.rollback();
                      return false;      // no such order
                  }
                  boolean shipped   = rs.getBoolean("shipped");
                  boolean delivered = rs.getBoolean("delivered");
                  int     pid       = rs.getInt("product_id");
                  int     qty       = rs.getInt("quantity");

                  if (shipped || delivered) {
                      // can't cancel once shipped/delivered
                      con.rollback();
                      return false;
                  }

                  //  Mark the order cancelled
                  try (PreparedStatement psUpd = con.prepareStatement(updateOrder)) {
                      psUpd.setInt(1, orderId);
                      int rows = psUpd.executeUpdate();
                      if (rows != 1) {
                          con.rollback();
                          return false;
                      }
                  }

                  //  Restore the stock
                  try (PreparedStatement psStock = con.prepareStatement(updateStock)) {
                      psStock.setInt(1, qty);
                      psStock.setInt(2, pid);
                      psStock.executeUpdate();
                  }

                  con.commit();
                  return true;
              }
          } catch (Exception e) {
              con.rollback();
              throw e;
          }
      }
  }

  @Override
  public boolean submitReview(int orderId, String review) throws Exception {
    try (Connection con = GetConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
           "UPDATE orders SET review=?, delivered=TRUE WHERE order_id=?"
         )) {
      ps.setString(1, review);
      ps.setInt   (2, orderId);
      return ps.executeUpdate() > 0;
    }
  }

  @Override
  public OrderPojo trackOrder(String consumerPortId, int orderId) throws Exception {
      String sql = """
        SELECT
          o.order_id,
          o.consumer_port_id,
          o.seller_port_id,
          o.product_id,
          p.product_name,
          o.quantity,
          o.order_date,
          o.total_amount,
          o.cancelled,
          o.shipped,
          o.out_for_delivery,
          o.delivered
        FROM orders o
        JOIN products p ON o.product_id = p.product_id
        WHERE o.order_id = ?
          AND o.consumer_port_id = ?
      """;

      try (Connection con = GetConnection.getConnection();
           PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, orderId);
        ps.setString(2, consumerPortId);
        try (ResultSet rs = ps.executeQuery()) {
          if (!rs.next()) return null;
          OrderPojo o = new OrderPojo();
          o.setOrderId(rs.getInt("order_id"));
          o.setConsumerPortId(rs.getString("consumer_port_id"));
          o.setSellerPortId(rs.getString("seller_port_id"));
          o.setProductId(rs.getInt("product_id"));
          o.setProductName(rs.getString("product_name"));
          o.setQuantity(rs.getInt("quantity"));
          o.setOrderDate(rs.getTimestamp("order_date"));
          o.setTotalAmount(rs.getBigDecimal("total_amount"));
          // derive a single status
          if (rs.getBoolean("cancelled"))      o.setStatus("Cancelled");
          else if (rs.getBoolean("delivered")) o.setStatus("Delivered");
          else if (rs.getBoolean("out_for_delivery")) o.setStatus("Out for Delivery");
          else if (rs.getBoolean("shipped"))   o.setStatus("Shipped");
          else                                  o.setStatus("Placed");
          return o;
        }
      }
  }
  @Override
  public List<OrderPojo> getOrdersBySeller(String sellerPortId) throws Exception {
	  String sql =
			  "SELECT " +
			  "  o.order_id, o.consumer_port_id, cp.location AS consumer_location, " +
			  "  o.product_id, p.product_name, o.quantity, o.order_date, o.total_amount, " +
			  "  CASE " +
			  "    WHEN o.cancelled THEN 'Cancelled' " +
			  "    WHEN o.delivered THEN 'Delivered' " +
			  "    WHEN o.out_for_delivery THEN 'Out for Delivery' " +
			  "    WHEN o.shipped THEN 'Shipped' " +
			  "    ELSE 'Placed' " +
			  "  END AS status " +
			  "FROM orders o " +
			  "JOIN products p ON o.product_id = p.product_id " +
			  "JOIN consumer_port cp ON o.consumer_port_id = cp.port_id " +
			  "WHERE o.seller_port_id = ? " +
			  "ORDER BY o.order_date DESC";

      List<OrderPojo> list = new ArrayList<>();
      try (Connection con = GetConnection.getConnection();
           PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, sellerPortId);
        try (ResultSet rs = ps.executeQuery()) {
          while (rs.next()) {
            OrderPojo o = new OrderPojo();
            o.setOrderId(      rs.getInt("order_id"));
            o.setConsumerPortId(rs.getString("consumer_port_id"));
            o.setConsumerLocation(rs.getString("consumer_location"));
            o.setProductId(    rs.getInt("product_id"));
            o.setProductName(  rs.getString("product_name"));
            o.setQuantity(     rs.getInt("quantity"));
            o.setOrderDate(    rs.getTimestamp("order_date"));
            o.setTotalAmount(  rs.getBigDecimal("total_amount"));
            o.setStatus(       rs.getString("status"));
            list.add(o);
          }
        }
      }
      return list;
  }
  @Override
  public boolean updateOrderStatus(int orderId, String newStatus) throws Exception {
      try ( Connection con = GetConnection.getConnection();
            CallableStatement cs = con.prepareCall("{ call update_order_status(?,?) }") ) {
          cs.setInt(1, orderId);
          cs.setString(2, newStatus);
          cs.execute();
          return true;
      }
  }
  @Override
  public Product_pojo getProductDetails(int productId) {
      String query = "SELECT product_id, product_name, price, quantity FROM products WHERE product_id = ?";
      try (Connection con = GetConnection.getConnection();
           PreparedStatement ps = con.prepareStatement(query)) {

          ps.setInt(1, productId);
          ResultSet rs = ps.executeQuery();
          if (rs.next()) {
              Product_pojo p = new Product_pojo();
              p.setProductId(rs.getInt("product_id"));
              p.setProductName(rs.getString("product_name"));
              p.setPrice(rs.getDouble("price"));
              p.setQuantity(rs.getInt("quantity"));
              return p;
          }

      } catch (SQLException e) {
          e.printStackTrace();
      }
      return null;
  }
  @Override
  public boolean placeOrder(int productId, String consumerPortId, int quantity, double price, String location) {
      String queryFetchSeller = "SELECT seller_port_id, quantity FROM products WHERE product_id = ?";
      String queryInsertOrder = "INSERT INTO orders (product_id, consumer_port_id, seller_port_id, quantity, total_amount, order_date) VALUES (?, ?, ?, ?, ?, CURDATE())";
      String queryUpdateStock = "UPDATE products SET quantity = quantity - ? WHERE product_id = ?";

      try (Connection con = GetConnection.getConnection()) {
          con.setAutoCommit(false);

          String sellerPortId = null;
          int stock = 0;

          try (PreparedStatement ps1 = con.prepareStatement(queryFetchSeller)) {
              ps1.setInt(1, productId);
              ResultSet rs = ps1.executeQuery();
              if (rs.next()) {
                  sellerPortId = rs.getString("seller_port_id");
                  stock = rs.getInt("quantity");
              } else {
                  return false;
              }
          }

          if (quantity > stock || quantity <= 0) {
              return false;
          }

          try (PreparedStatement ps2 = con.prepareStatement(queryInsertOrder)) {
              ps2.setInt(1, productId);
              ps2.setString(2, consumerPortId);
              ps2.setString(3, sellerPortId);
              ps2.setInt(4, quantity);
              ps2.setDouble(5, price * quantity);
              ps2.executeUpdate();
          }

          try (PreparedStatement ps3 = con.prepareStatement(queryUpdateStock)) {
              ps3.setInt(1, quantity);
              ps3.setInt(2, productId);
              ps3.executeUpdate();
          }

          con.commit();
          return true;

      } catch (Exception e) {
          e.printStackTrace();
          return false;
      }
  }
  @Override
  public List<CartPojo> getCartItems(String consumerId) {
      List<CartPojo> cartItems = new ArrayList<>();
      String query = """
          SELECT c.cart_id, c.consumer_port_id, c.product_id, p.product_name,
                 p.price, c.quantity, (p.price * c.quantity) AS total, c.added_on
          FROM cart c
          JOIN products p ON c.product_id = p.product_id
          WHERE c.consumer_port_id = ?
          ORDER BY c.added_on DESC
      """;

      try (Connection con = GetConnection.getConnection();
           PreparedStatement ps = con.prepareStatement(query)) {

          ps.setString(1, consumerId);
          ResultSet rs = ps.executeQuery();

          while (rs.next()) {
              CartPojo item = new CartPojo();
              item.setCartId(rs.getInt("cart_id"));
              item.setConsumerId(rs.getString("consumer_port_id"));
              item.setProductId(rs.getInt("product_id"));
              item.setProductName(rs.getString("product_name"));
              item.setPrice(rs.getDouble("price"));
              item.setQuantity(rs.getInt("quantity"));
              item.setTotal(rs.getDouble("total"));
              item.setAddedOn(rs.getTimestamp("added_on"));

              cartItems.add(item);
          }
      } catch (SQLException e) {
          e.printStackTrace();
      }

      return cartItems;
  }
  @Override
  public boolean deleteCartItem(int cartId) {
      String query = "DELETE FROM cart WHERE cart_id = ?";
      try (Connection con = GetConnection.getConnection();
           PreparedStatement ps = con.prepareStatement(query)) {

          ps.setInt(1, cartId);
          return ps.executeUpdate() > 0;

      } catch (SQLException e) {
          e.printStackTrace();
          return false;
      }
  }
  @Override
  public boolean updateCartItem(int cartId, int quantity) throws Exception {
      String sql = "UPDATE cart SET quantity = ? WHERE cart_id = ?";
      try (Connection con = GetConnection.getConnection();
           PreparedStatement ps = con.prepareStatement(sql)) {
          ps.setInt(1, quantity);
          ps.setInt(2, cartId);
          return ps.executeUpdate() == 1;
      }
  }

 
  @Override
  public boolean confirmSingleCartItem(int cartId, String consumer) throws Exception {
      String insert = """
          insert into orders (consumer_port_id, seller_port_id, product_id, quantity, total_amount, order_date)
          select c.consumer_port_id, p.seller_port_id, c.product_id, c.quantity, (c.quantity * p.price), now()
          from cart c
          join products p on c.product_id = p.product_id
          where c.cart_id = ?
      """;

      String delete = "delete from cart where cart_id = ?";

      try (Connection con = GetConnection.getConnection()) {
          con.setAutoCommit(false);

          try (PreparedStatement pi = con.prepareStatement(insert);
               PreparedStatement pd = con.prepareStatement(delete)) {

              pi.setInt(1, cartId);
              if (pi.executeUpdate() != 1) {
                  con.rollback();
                  return false;
              }

              pd.setInt(1, cartId);
              pd.executeUpdate();

              con.commit();
              return true;
          }
      }
  }
  @Override
  public boolean confirmAllCartItems(String consumer) throws Exception {
      String insert = """
          insert into orders (consumer_port_id, seller_port_id, product_id, quantity, total_amount, order_date)
          select c.consumer_port_id, p.seller_port_id, c.product_id, c.quantity, (c.quantity * p.price), now()
          from cart c
          join products p on c.product_id = p.product_id
          where c.consumer_port_id = ?
      """;

      String delete = "delete from cart where consumer_port_id = ?";

      try (Connection con = GetConnection.getConnection()) {
          con.setAutoCommit(false);

          try (PreparedStatement pi = con.prepareStatement(insert);
               PreparedStatement pd = con.prepareStatement(delete)) {

              pi.setString(1, consumer);
              int inserted = pi.executeUpdate();

              if (inserted == 0) {
                  con.rollback();
                  return false;
              }

              pd.setString(1, consumer);
              pd.executeUpdate();

              con.commit();
              return true;
          }
      }
  }
}
