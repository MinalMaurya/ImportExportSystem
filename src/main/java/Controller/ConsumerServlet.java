package Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import model.ConsumerPojo;
import Implementor.ConsumerImp;

import java.io.IOException;

@WebServlet("/ConsumerServlet")
public class ConsumerServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("register".equalsIgnoreCase(action)) {
            String portId = req.getParameter("port_id");
            String password = req.getParameter("password");
            String confirmPassword = req.getParameter("confirm_password");
            String role = req.getParameter("role");

            if (!password.equals(confirmPassword)) {
                req.setAttribute("errorMessage", "❌ Passwords do not match");
                req.getRequestDispatcher("registration.jsp").forward(req, resp);
                return;
            }

            ConsumerPojo pojo = new ConsumerPojo();
            pojo.setPortId(portId);
            pojo.setPassword(password);
            pojo.setRole(role);

            ConsumerImp imp = new ConsumerImp();
            String message = imp.registerAndReturnMessage(pojo); 

            if (message.startsWith("register successfully")) {
                resp.sendRedirect("login.jsp?success=true");
            } else {
                req.setAttribute("errorMessage", "❌ " + message);
                req.getRequestDispatcher("registration.jsp").forward(req, resp);
            }
        }

        if ("login".equalsIgnoreCase(action)) {
            String portId = req.getParameter("port_id");
            String password = req.getParameter("password");
            String role = req.getParameter("role");

            ConsumerPojo pojo = new ConsumerPojo();
            pojo.setPortId(portId);
            pojo.setPassword(password);
            pojo.setRole(role);

            ConsumerImp imp = new ConsumerImp();
            String message = imp.loginAndReturnMessage(pojo, req);

            if (message.equals("login successful")) {
                resp.sendRedirect(req.getContextPath() + "/ConsumerDash.jsp");
            } else {
                req.setAttribute("loginError", "❌ " + message);
                req.getRequestDispatcher("login.jsp").forward(req, resp);
            }
        }
}
}
