package Controller;

import Implementor.UserImplementor;
import model.UserPojo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/ProfileServlet")
public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserImplementor impl = new UserImplementor();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String port = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");
        String action = req.getParameter("action");

        try {
            // ✅ Existing line
            UserPojo user = impl.getUserDetails(port, role);

            // ✅ INSERT THIS BLOCK HERE
            if (user == null) {
                user = new UserPojo();
                user.setPortId(port);
                user.setRole(role);
            }
            req.setAttribute("user", user);
            // ✅ END INSERTION

            // (optional) update location in session
            if (user.getLocation() != null) {
                session.setAttribute("location", user.getLocation());
            }

            if ("edit".equalsIgnoreCase(action)) {
                req.getRequestDispatcher("/edit_profile.jsp").forward(req, resp);
            } else {
                req.getRequestDispatcher("/profile.jsp").forward(req, resp);
            }

        } catch (Exception e) {
            req.setAttribute("error", "Could not load profile: " + e.getMessage());
            req.getRequestDispatcher("/profile.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String port = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");
        String action = req.getParameter("action");

        try {
            if ("updateProfile".equals(action)) {
                String newPwd = req.getParameter("new_password");
                String confirm = req.getParameter("confirm_password");
                String newLoc = req.getParameter("location");

                if (newPwd != null && !newPwd.isBlank() && (confirm == null || !newPwd.equals(confirm))) {
                    req.setAttribute("error", "New password and confirm password do not match.");
                } else {
                    boolean updatePwd = newPwd != null && !newPwd.isBlank();
                    boolean updateLoc = newLoc != null && !newLoc.isBlank();

                    boolean ok = impl.editProfile(
                        port, role,
                        updatePwd ? newPwd : null,
                        updateLoc ? newLoc : null,
                        updatePwd, updateLoc,
                        false
                    );

                    if (ok) {
                        if (updateLoc) session.setAttribute("location", newLoc);
                        req.setAttribute("msg", "Profile updated successfully.");
                    } else {
                        req.setAttribute("error", "Could not update profile.");
                    }
                }

                UserPojo user = impl.getUserDetails(port, role);
                req.setAttribute("user", user);
                if (user != null && user.getLocation() != null) {
                    session.setAttribute("location", user.getLocation());
                }

                req.getRequestDispatcher("/edit_profile.jsp").forward(req, resp);
                return;
            }

            if ("deleteAccount".equals(action)) {
                boolean ok = impl.editProfile(port, role, null, null, false, false, true);
                if (ok) {
                    session.invalidate();
                    resp.sendRedirect(req.getContextPath() + "/login.jsp");
                } else {
                    req.setAttribute("error", "Could not delete account.");
                    UserPojo user = impl.getUserDetails(port, role);
                    req.setAttribute("user", user);
                    req.getRequestDispatcher("/edit_profile.jsp").forward(req, resp);
                }
                return;
            }

            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
        } catch (Exception e) {
            throw new ServletException("Error processing profile", e);
        }
    }
}
