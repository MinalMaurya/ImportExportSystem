package Implementor;

import db_config.GetConnection;
import model.Product_pojo;
import Operation.ProductOperations;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class ProductImplementor implements ProductOperations {

    @Override
    public boolean addProduct(Product_pojo pojo) {
        String sellerId = pojo.getSellerPortId();
        if (sellerId == null || sellerId.isBlank()) {
            sellerId = "S" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            pojo.setSellerPortId(sellerId);
        }

        String checkSellerSql  = "SELECT 1 FROM seller_port WHERE port_id = ?";
        String insertSellerSql = "INSERT INTO seller_port (port_id, password, location, role) VALUES (?, 'default123', 'AutoLocation', 'seller')";
        String procAddProduct  = "{ CALL add_product(?, ?, ?, ?) }";

        try (Connection con = GetConnection.getConnection()) {
            if (con == null) return false;

            // ensure seller exists
            try (PreparedStatement ps = con.prepareStatement(checkSellerSql)) {
                ps.setString(1, sellerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        try (PreparedStatement ins = con.prepareStatement(insertSellerSql)) {
                            ins.setString(1, sellerId);
                            ins.executeUpdate();
                        }
                    }
                }
            }

            // call add_product stored proc
            try (CallableStatement cs = con.prepareCall(procAddProduct)) {
                cs.setString(1, sellerId);
                cs.setString(2, pojo.getProductName());
                cs.setInt(3, pojo.getQuantity());
                cs.setDouble(4, pojo.getPrice());
                cs.execute();
                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateProduct(Product_pojo pojo) {
        String procUpdate = "{ CALL update_product(?, ?, ?, ?) }";

        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall(procUpdate)) {

            // 1) product_id
            cs.setInt(1, pojo.getProductId());
            // 2) product_name
            cs.setString(2, pojo.getProductName());
            // 3) quantity
            cs.setInt(3, pojo.getQuantity());
            // 4) price
            cs.setDouble(4, pojo.getPrice());

            cs.execute();        // just execute the proc
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    @Override
    public boolean deleteProduct(int productId) {
        String procDelete = "{ CALL delete_product(?) }";

        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall(procDelete)) {

            if (con == null) return false;

            cs.setInt(1, productId);
            cs.execute();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Product_pojo getProductById(int productId) {
        String sql = "SELECT * FROM products WHERE product_id = ?";
        try (Connection con = GetConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            if (con == null) return null;

            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product_pojo p = new Product_pojo();
                    p.setProductId(rs.getInt("product_id"));
                    p.setSellerPortId(rs.getString("seller_port_id"));
                    p.setProductName(rs.getString("product_name"));
                    p.setQuantity(rs.getInt("quantity"));
                    p.setPrice(rs.getDouble("price"));
                    return p;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    @Override
    public List<Product_pojo> getAllProducts() throws Exception {
        List<Product_pojo> list = new ArrayList<>();

        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{ CALL list_products() }");
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
    public List<Product_pojo> getAllProductsBySeller(String sellerPortId) {
        List<Product_pojo> list = new ArrayList<>();
        String procList = "{ CALL list_products_by_seller(?) }";

        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall(procList)) {

            if (con == null) return list;

            cs.setString(1, sellerPortId);
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    Product_pojo p = new Product_pojo();
                    p.setProductId(rs.getInt("product_id"));
                    p.setSellerPortId(rs.getString("seller_port_id"));
                    p.setProductName(rs.getString("product_name"));
                    p.setQuantity(rs.getInt("quantity"));
                    p.setPrice(rs.getDouble("price"));
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
}
