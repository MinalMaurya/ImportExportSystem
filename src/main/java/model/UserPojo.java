package model;

public class UserPojo {
	private String portId;
	private String role;
	private String password;
	private String location;

	public String getPassword() { return password; }
	public void setPassword(String password) { this.password = password; }

	public String getLocation() { return location; }
	public void setLocation(String location) { this.location = location; }

	public String getPortId() { return portId; }
	public void setPortId(String portId) { this.portId = portId; }

	public String getRole() { return role; }
	public void setRole(String role) { this.role = role; }

}
