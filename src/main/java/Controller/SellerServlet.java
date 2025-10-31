package Controller;

import Operation.OrderOperation;
import Implementor.OrderImp;
import Implementor.SellerImp;
import model.OrderPojo;
import model.SellerPojo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/SellerServlet")
public class SellerServlet extends HttpServlet {
    private final OrderOperation orderOp = new OrderImp();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        HttpSession session = req.getSession(false);

        // 1) Make sure they’re logged in as a seller
        String role         = (session != null) ? (String) session.getAttribute("role")      : null;
        String sellerPortId = (session != null) ? (String) session.getAttribute("username")  : null;
        if (!"seller".equals(role) || sellerPortId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        if ("viewSellerOrders".equals(action)) {
            try {
                // 3) Fetch all orders for this seller
                List<OrderPojo> orders = orderOp.getOrdersBySeller(sellerPortId);
                req.setAttribute("orders", orders);

                // 4) Forward into the JSP (adjust path to where your JSP actually lives)
                req.getRequestDispatcher("/seller_orders.jsp")
                   .forward(req, resp);

            } catch (Exception e) {
                throw new ServletException(e);
            }

        } else {
        	req.getRequestDispatcher("/SellerDash.jsp").forward(req, resp);
        }
    }
    // 4) Retain your existing POST for register/login
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
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

            SellerPojo pojo = new SellerPojo();
            pojo.setPortId(portId);
            pojo.setPassword(password);
            pojo.setRole(role);

            SellerImp imp = new SellerImp();
            String message = imp.registerAndReturnMessage(pojo);

            if (message.startsWith("register successfully")) {
                resp.sendRedirect("login.jsp?success=true");
            } else {
                req.setAttribute("errorMessage", "❌ " + message);
                req.getRequestDispatcher("registration.jsp").forward(req, resp);
            }
        } else if ("login".equalsIgnoreCase(action)) {
            String portId   = req.getParameter("port_id");
            String password = req.getParameter("password");
            String role     = req.getParameter("role");

            SellerPojo pojo = new SellerPojo();
            pojo.setPortId(portId);
            pojo.setPassword(password);
            pojo.setRole(role);
            SellerImp imp = new SellerImp();
            String message = imp.loginAndReturnMessage(pojo, req);

            if (message.equals("login successful")) {
            	resp.sendRedirect(req.getContextPath() + "/SellerDash.jsp");
            } else {
                req.setAttribute("loginError", "❌ " + message);
                req.getRequestDispatcher("login.jsp").forward(req, resp);
            }

        } else {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
        }
    }
}
