package Implementor;

import db_config.GetConnection;
import model.UserPojo;

import java.sql.*;

public class UserImplementor {
    public UserPojo getUserDetails(String portId, String role) throws Exception {
        UserPojo user = null;

        String procedure = "{ CALL get_user_details(?, ?) }";

        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall(procedure)) {

            cs.setString(1, portId);
            cs.setString(2, role);

            boolean hasResult = cs.execute();

            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        user = new UserPojo();
                        user.setPortId(rs.getString("port_id"));
                        user.setRole(role); // fixed to use param, or rs.getString("role") if available
                        user.setLocation(rs.getString("location"));
                        user.setPassword(rs.getString("password")); // ✅ Now password is retrieved
                    }
                }
            }
        }

        return user;
    }

    /**
     * Wraps your edit_profile stored procedure.
     * @return true on success, false if the proc signals no rows or error.
     */
    public boolean editProfile(
        String portId,
        String role,
        String newPwd,
        String newLoc,
        boolean updatePwd,
        boolean updateLoc,
        boolean deleteFlag
    ) throws Exception {

        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{ call edit_profile(?,?,?,?,?,?,?) }")) {

            cs.setString(1, portId);
            cs.setString(2, role);

            if (newPwd != null) cs.setString(3, newPwd);
            else                cs.setNull(3, Types.VARCHAR);

            if (newLoc != null) cs.setString(4, newLoc);
            else                cs.setNull(4, Types.VARCHAR);

            cs.setBoolean(5, updatePwd);
            cs.setBoolean(6, updateLoc);
            cs.setBoolean(7, deleteFlag);

            cs.execute();  // we assume any errors will raise exceptions
            return true;
        }
    }
}
