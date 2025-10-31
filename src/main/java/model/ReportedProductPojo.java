package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class ReportedProductPojo implements Serializable {
    private static final long serialVersionUID = 1L;

    private int       reportId;
    private int       productId;
    private String    consumerPortId;
    private String    sellerPortId;
    private String    issueType;
    private String    status;
    private String    actionTaken;
    private Timestamp reportDate;
    private String productName;
    private int orderId;

    public int getReportId()                   { return reportId; }
    public void setReportId(int reportId)      { this.reportId = reportId; }

    public int getProductId()                  { return productId; }
    public void setProductId(int productId)    { this.productId = productId; }

    public String getConsumerPortId()                  { return consumerPortId; }
    public void setConsumerPortId(String consumerPortId){ this.consumerPortId = consumerPortId; }

    public String getSellerPortId()                { return sellerPortId; }
    public void setSellerPortId(String sellerPortId){ this.sellerPortId = sellerPortId; }

    public String getIssueType()                  { return issueType; }
    public void setIssueType(String issueType)    { this.issueType = issueType; }

    public String getStatus()                     { return status; }
    public void setStatus(String status)          { this.status = status; }

    public String getActionTaken()                { return actionTaken; }
    public void setActionTaken(String actionTaken){ this.actionTaken = actionTaken; }

    public Timestamp getReportDate()              { return reportDate; }
    public void setReportDate(Timestamp reportDate){ this.reportDate = reportDate; }
    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }
    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }
}
