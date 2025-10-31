package Operation;

import model.Product_pojo;
import java.util.List;

public interface ProductOperations {
	boolean addProduct(Product_pojo pojo);

	boolean updateProduct(Product_pojo pojo);

	Product_pojo getProductById(int productId);

	boolean deleteProduct(int productId);

	List<Product_pojo> getAllProductsBySeller(String sellerPortId);
	List<Product_pojo> getAllProducts() throws Exception;
}
