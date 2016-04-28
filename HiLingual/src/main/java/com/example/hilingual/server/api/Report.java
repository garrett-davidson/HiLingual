package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;

import javax.validation.constraints.NotNull;

public class Report {

    @NotNull
    private String reason;

    private long reportedUserId;

    private long reportedByUserId;

    public Report() {
    }

    @JsonProperty
    public String getReason() {
        return reason;
    }

    @JsonProperty
    public void setReason(String reason) {
        this.reason = reason;
    }

    @JsonProperty
    public long getReportedUserId() {
        return reportedUserId;
    }

    @JsonProperty
    public void setReportedUserId(long reportedUserId) {
        this.reportedUserId = reportedUserId;
    }

    @JsonProperty
    public long getReportedByUserId() {
        return reportedByUserId;
    }

    @JsonProperty
    public void setReportedByUserId(long reportedByUserId) {
        this.reportedByUserId = reportedByUserId;
    }

    @Override
    public String toString() {
        return "Report{" +
                "reason='" + reason + '\'' +
                ", reportedUserId=" + reportedUserId +
                ", reportedByUserId=" + reportedByUserId +
                '}';
    }
}
