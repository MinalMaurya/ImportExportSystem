package model;

import Implementor.SellerImp;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class SellerPojo {
    private String portId;
    private String password;
    private String location;
    private String role;

    // Getters and Setters
    public String getPortId() {
        return portId;
    }

    public void setPortId(String portId) {
        this.portId = portId;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    // Register method
    public void registerSeller(SellerPojo pojo, HttpServletResponse resp) {
        new SellerImp().register(pojo, resp);
    }

    // Login method (Corrected)
    public void loginSeller(SellerPojo pojo, HttpServletRequest req, HttpServletResponse resp) {
        new SellerImp().login(pojo, req, resp);
    }
    
}
