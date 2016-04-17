package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Objects;

public class Chat {

    private long receiver;
    private ChatAck ack;
    private long lastReceivedMessage;

    public Chat() {
    }

    public Chat(ChatAck acks, long lastReceivedMessage, long receiver) {
        this.ack = acks;
        this.lastReceivedMessage = lastReceivedMessage;
        this.receiver = receiver;
    }

    @JsonProperty
    public ChatAck getAck() {
        return ack;
    }

    @JsonProperty
    public void setAck(ChatAck ack) {
        this.ack = ack;
    }

    @JsonProperty
    public long getLastReceivedMessage() {
        return lastReceivedMessage;
    }

    @JsonProperty
    public void setLastReceivedMessage(long lastReceivedMessage) {
        this.lastReceivedMessage = lastReceivedMessage;
    }

    @JsonProperty
    public long getReceiver() {
        return receiver;
    }

    @JsonProperty
    public void setReceiver(long receiver) {
        this.receiver = receiver;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        Chat chat = (Chat) o;
        return receiver == chat.receiver;
    }

    @Override
    public int hashCode() {
        return Objects.hash(receiver);
    }
}
