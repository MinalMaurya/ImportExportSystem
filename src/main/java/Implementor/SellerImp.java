package Implementor;

import java.io.PrintWriter;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import Operation.SellerOperation;
import db_config.GetConnection;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.SellerPojo;

public class SellerImp implements SellerOperation {

	@Override
	public void register(SellerPojo pojo, HttpServletResponse resp) {
	    try (
	        Connection con = GetConnection.getConnection();
	        CallableStatement cs = con.prepareCall("{ CALL register_user(?, ?, ?, ?) }")
	    ) {
	        cs.setString(1, pojo.getPortId());
	        cs.setString(2, pojo.getPassword());
	        cs.setString(3, pojo.getPassword()); // confirm password
	        cs.setString(4, pojo.getRole());

	        boolean hasResult = cs.execute();

	        if (hasResult) {
	            try (ResultSet rs = cs.getResultSet()) {
	                if (rs.next()) {
	                    String message = rs.getString(1);

	                    if (message.startsWith("register successfully")) {
	                        resp.sendRedirect("login.jsp?success=true");
	                    } else {
	                        //  Since we can't forward without request, fallback to alert
	                        PrintWriter out = resp.getWriter();
	                        out.println("<script>alert('❌ " + message + "'); window.location='registration.jsp';</script>");
	                    }
	                }
	            }
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	        try {
	            PrintWriter out = resp.getWriter();
	            out.println("<script>alert('❌ Internal server error'); window.location='registration.jsp';</script>");
	        } catch (Exception ignored) {}
	    }
	}

    @Override
    public void login(SellerPojo pojo, HttpServletRequest req, HttpServletResponse resp) {
        try (Connection con = GetConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM seller_port WHERE port_id = ? AND password = ?")) {

            ps.setString(1, pojo.getPortId());
            ps.setString(2, pojo.getPassword());

            try (ResultSet rs = ps.executeQuery(); PrintWriter out = resp.getWriter()) {
                if (rs.next()) {
                    String dbRole = rs.getString("role");
                    if (!pojo.getRole().equalsIgnoreCase(dbRole)) {
                        out.println("<script>"
                            + "alert('❌ Role mismatch. You are registered as " + dbRole + "');"
                            + "window.location='login.jsp';"
                            + "</script>");
                    } else {
                        HttpSession session = req.getSession();
                        session.setAttribute("username", rs.getString("port_id"));
                        session.setAttribute("role", dbRole);
                        //  NEW: remember this so Manage-Products works
                        session.setAttribute("seller_port_id", rs.getString("port_id"));

                        resp.sendRedirect("SellerDash.jsp");
                    }
                } else {
                    out.println("<script>"
                        + "alert('❌ Invalid ID or Password.');"
                        + "window.location='login.jsp';"
                        + "</script>");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public String registerAndReturnMessage(SellerPojo pojo) {
        String result = "";
        try (
            Connection con = GetConnection.getConnection();
            CallableStatement cs = con.prepareCall("{ CALL register_user(?, ?, ?, ?) }")
        ) {
            cs.setString(1, pojo.getPortId());
            cs.setString(2, pojo.getPassword());
            cs.setString(3, pojo.getPassword());
            cs.setString(4, pojo.getRole());

            boolean hasResult = cs.execute();
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        result = rs.getString(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result = "Internal error occurred.";
        }
        return result;
    }
    public String loginAndReturnMessage(SellerPojo pojo, HttpServletRequest req) {
        String result = "Invalid Port ID or Password or Role";
        try (
            Connection con = GetConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM seller_port WHERE port_id = ? AND password = ? AND role = ?"
            )
        ) {
            ps.setString(1, pojo.getPortId());
            ps.setString(2, pojo.getPassword());
            ps.setString(3, pojo.getRole());

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                HttpSession session = req.getSession();
                session.setAttribute("username", rs.getString("port_id"));
                session.setAttribute("role", rs.getString("role"));
                session.setAttribute("seller_port_id", rs.getString("port_id"));
                result = "login successful";
            }
        } catch (Exception e) {
            e.printStackTrace();
            result = "Internal server error occurred.";
        }
        return result;
    }
}
