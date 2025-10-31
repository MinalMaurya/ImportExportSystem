package Operation;

import model.ReportedProductPojo;
import java.util.List;

public interface ReportedProductOperations {
    void addReport(ReportedProductPojo obj) throws Exception;
    List<ReportedProductPojo> getConsumerReports(String consumerId) throws Exception;
    List<ReportedProductPojo> getSellerReports(String sellerId) throws Exception;
    void updateReportIssue(int reportId, String newIssue, String actionTaken) throws Exception;
    void deleteReport(int reportId) throws Exception;
    void updateReportStatus(int reportId, String newStatus, String actionTaken) throws Exception;
}
