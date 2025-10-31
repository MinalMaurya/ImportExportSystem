package Controller;

import Implementor.ReportedProductImplementor;
import model.ReportedProductPojo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;
import java.util.Locale;

@WebServlet("/reports")
public class ReportedProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ReportedProductImplementor impl = new ReportedProductImplementor();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action   = req.getParameter("action");
        String userType = req.getParameter("user_type");
        String port     = req.getParameter("port_id");

        if ("add".equalsIgnoreCase(action)) {
            
            req.getRequestDispatcher("/report_product_form.jsp")
               .forward(req, resp);
            return;
        }

        try {
            List<ReportedProductPojo> list;
            String targetJsp;
            if ("consumer".equalsIgnoreCase(userType)) {
                list = impl.getConsumerReports(port);
                targetJsp = "/consumer_reported_products.jsp";
            } else if ("seller".equalsIgnoreCase(userType)) {
                list = impl.getSellerReports(port);
                targetJsp = "/seller_reported_products.jsp";
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown user_type: " + userType);
                return;
            }

            req.setAttribute("reportList", list);
            req.getRequestDispatcher(targetJsp).forward(req, resp);

        } catch (Exception e) {
            throw new ServletException("Error loading reports for " + userType + "/" + port, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession(false);
        String username = session != null
                        ? (String) session.getAttribute("username")
                        : null;

        if (username == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        try {
            switch (action.toLowerCase(Locale.ROOT)) {
            case "add" -> {
                String issue = req.getParameter("issue_type");
                String actionTaken;
                switch (issue) {
                    case "damaged"            -> actionTaken = "replacement";
                    case "wrong_product"      -> actionTaken = "resend";
                    case "delay"              -> actionTaken = "compensation";
                    case "still_not_received" -> actionTaken = "refund";
                    case "missing"            -> actionTaken = "resend";
                    default                   -> actionTaken = "pending";
                }

                ReportedProductPojo toAdd = new ReportedProductPojo();
                toAdd.setProductId(Integer.parseInt(req.getParameter("product_id").trim()));
                toAdd.setConsumerPortId(req.getParameter("consumer_port_id"));
                toAdd.setSellerPortId(req.getParameter("seller_port_id"));
                toAdd.setIssueType(req.getParameter("issue_type"));
                toAdd.setStatus("pending");
                toAdd.setActionTaken(actionTaken);

                impl.addReport(toAdd);

                resp.sendRedirect(req.getContextPath()
                    + "/reports?user_type=consumer&port_id=" + username);
            }
                case "updatestatus" -> {
                    // 1) read the two hidden parameters: report_id and action_taken
                    int reportId       = Integer.parseInt(req.getParameter("report_id"));
                    String newStatus   = req.getParameter("status");         // should be "solved"
                    String actionTaken = req.getParameter("action_taken");  // your computed value

                    // 2) call the stored proc (or DAO) that updates both
                    impl.updateReportStatus(reportId, newStatus, actionTaken);

                    // 3) reload the seller’s own list
                    List<ReportedProductPojo> list = impl.getSellerReports((String)session.getAttribute("username"));
                    req.setAttribute("reportList", list);
                    req.getRequestDispatcher("/seller_reported_products.jsp")
                       .forward(req, resp);
                }

                case "update" -> {
                	int editId = Integer.parseInt(req.getParameter("report_id").trim());
                    String issue = req.getParameter("issue_type");

                    // calculate new action_taken
                    String newAction;
                    switch (issue) {
                        case "damaged"            -> newAction = "replacement";
                        case "wrong_product"      -> newAction = "resend";
                        case "delay"              -> newAction = "compensation";
                        case "still_not_received" -> newAction = "refund";
                        case "missing"            -> newAction = "resend";
                        default                   -> newAction = "pending";
                    }

                    // call update method with both issue and action
                    impl.updateReportIssue(editId, issue, newAction);

                    List<ReportedProductPojo> list = impl.getConsumerReports(username);
                    req.setAttribute("reportList", list);
                    req.getRequestDispatcher("/consumer_reported_products.jsp")
                       .forward(req, resp);
                }

                case "delete" -> {
                	int deleteId = Integer.parseInt(req.getParameter("report_id").trim());
                    impl.deleteReport(deleteId);

                    List<ReportedProductPojo> list = impl.getConsumerReports(username);
                    req.setAttribute("reportList", list);
                    req.getRequestDispatcher("/consumer_reported_products.jsp")
                       .forward(req, resp);
                }

                default -> {
                    // fallback: show consumer’s list
                    List<ReportedProductPojo> list = impl.getConsumerReports(username);
                    req.setAttribute("reportList", list);
                    req.getRequestDispatcher("/consumer_reported_products.jsp")
                       .forward(req, resp);
                }
            }
        } catch (Exception e) {
            throw new ServletException("Error handling reports POST for user " + username, e);
        }
    }
}
