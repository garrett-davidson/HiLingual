package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;

public class ChatAck {

    private long lastAckedMessage;
    private long lastPartnerAckedMessage;

    public ChatAck() {
    }

    public ChatAck(long lastAckedMessage, long lastPartnerAckedMessage) {
        this.lastAckedMessage = lastAckedMessage;
        this.lastPartnerAckedMessage = lastPartnerAckedMessage;
    }

    @JsonProperty
    public long getLastAckedMessage() {
        return lastAckedMessage;
    }

    @JsonProperty
    public void setLastAckedMessage(long lastAckedMessage) {
        this.lastAckedMessage = lastAckedMessage;
    }

    @JsonProperty
    public long getLastPartnerAckedMessage() {
        return lastPartnerAckedMessage;
    }

    @JsonProperty
    public void setLastPartnerAckedMessage(long lastPartnerAckedMessage) {
        this.lastPartnerAckedMessage = lastPartnerAckedMessage;
    }
}
