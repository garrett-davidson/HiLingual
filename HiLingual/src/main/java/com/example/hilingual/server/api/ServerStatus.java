package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;

public class ServerStatus {

    public String status;

    public ServerStatus(String ping) {
        this.status = ping;
    }

    public ServerStatus() {
    }

    @JsonProperty
    public String getStatus() {
        return status;
    }

    @JsonProperty
    public void setStatus(String status) {
        this.status = status;
    }
}
