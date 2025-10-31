package model;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class ConsumerPojo {
    private String portId;
    private String password;
    private String location;
    private String role;

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

    public void registerConsumer(ConsumerPojo pojo, jakarta.servlet.http.HttpServletResponse resp) {
        new Implementor.ConsumerImp().register(pojo, resp);
    }

    public void loginConsumer(ConsumerPojo pojo, HttpServletRequest req, HttpServletResponse resp) {
        new Implementor.ConsumerImp().login(pojo, req, resp);
    }
}
