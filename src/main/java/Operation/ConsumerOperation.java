package Operation;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.ConsumerPojo;

public interface ConsumerOperation {
    void register(ConsumerPojo pojo, HttpServletResponse resp);
    void login(ConsumerPojo pojo, HttpServletRequest req, HttpServletResponse resp);
}
