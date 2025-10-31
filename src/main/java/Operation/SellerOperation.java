package Operation;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.SellerPojo;

public interface SellerOperation {
    void register(SellerPojo pojo, HttpServletResponse resp);
    void login(SellerPojo pojo, HttpServletRequest req, HttpServletResponse resp);
    
}
