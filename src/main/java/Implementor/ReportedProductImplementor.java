package Implementor;

import Operation.ReportedProductOperations;
import db_config.GetConnection;
import model.ReportedProductPojo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReportedProductImplementor implements ReportedProductOperations {

	@Override
	public void addReport(ReportedProductPojo obj) throws Exception {
	  String sql = """
	    INSERT INTO reported_products
	      (product_id, consumer_port_id, seller_port_id, issue_type, status, action_taken, report_date)
	    VALUES (?,?,?,?,?,?,NOW())
	  """;
	  try (Connection con = GetConnection.getConnection();
	       PreparedStatement ps = con.prepareStatement(sql)) {
	    ps.setInt   (1, obj.getProductId());
	    ps.setString(2, obj.getConsumerPortId());
	    ps.setString(3, obj.getSellerPortId());
	    ps.setString(4, obj.getIssueType());
	    ps.setString(5, obj.getStatus());
	    ps.setString(6, obj.getActionTaken());   // ← include the computed value
	    ps.executeUpdate();
	  }
	}

	@Override
	public List<ReportedProductPojo> getConsumerReports(String consumerPort) throws Exception {
	    List<ReportedProductPojo> list = new ArrayList<>();
	    String sql = """
	        SELECT rp.report_id, rp.product_id, p.product_name, rp.seller_port_id,
	               rp.issue_type, rp.status, rp.action_taken, rp.report_date
	        FROM reported_products rp
	        JOIN products p ON rp.product_id = p.product_id
	        WHERE rp.consumer_port_id = ?
	    """;

	    try (Connection con = GetConnection.getConnection();
	         PreparedStatement ps = con.prepareStatement(sql)) {
	        ps.setString(1, consumerPort);
	        try (ResultSet rs = ps.executeQuery()) {
	            while (rs.next()) {
	                ReportedProductPojo r = new ReportedProductPojo();
	                r.setReportId(rs.getInt("report_id"));
	                r.setProductId(rs.getInt("product_id"));
	                r.setProductName(rs.getString("product_name")); // ✅ Important
	                r.setSellerPortId(rs.getString("seller_port_id"));
	                r.setIssueType(rs.getString("issue_type"));
	                r.setStatus(rs.getString("status"));
	                r.setActionTaken(rs.getString("action_taken"));
	                r.setReportDate(rs.getTimestamp("report_date"));
	                list.add(r);
	            }
	        }
	    }
	    return list;
	}

    @Override
    public List<ReportedProductPojo> getSellerReports(String sellerPort) throws Exception {
        List<ReportedProductPojo> list = new ArrayList<>();
        String sql = """
            SELECT report_id, product_id, consumer_port_id, issue_type, status, action_taken, report_date
              FROM reported_products
             WHERE seller_port_id = ?
        """;
        try (Connection con = GetConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, sellerPort);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ReportedProductPojo r = new ReportedProductPojo();
                    r.setReportId(rs.getInt("report_id"));
                    r.setProductId(rs.getInt("product_id"));
                    r.setConsumerPortId(rs.getString("consumer_port_id"));
                    r.setIssueType(rs.getString("issue_type"));
                    r.setStatus(rs.getString("status"));
                    r.setActionTaken(rs.getString("action_taken"));
                    r.setReportDate(rs.getTimestamp("report_date"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    public void updateReportIssue(int reportId, String issueType, String actionTaken) {
        String sql = "UPDATE reported_products SET issue_type = ?, action_taken = ? WHERE report_id = ?";

        try (Connection con = GetConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, issueType);
            ps.setString(2, actionTaken);
            ps.setInt(3, reportId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteReport(int reportId) throws Exception {
        String sql = "DELETE FROM reported_products WHERE report_id = ?";
        try (Connection con = GetConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, reportId);
            ps.executeUpdate();
        }
    }

    @Override
    public void updateReportStatus(int reportId, String newStatus, String actionTaken) throws Exception {
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{ call update_report_status(?,?,?) }")) {
            cs.setInt   (1, reportId);
            cs.setString(2, newStatus);
            cs.setString(3, actionTaken);
            cs.executeUpdate();
        }
    }
}
