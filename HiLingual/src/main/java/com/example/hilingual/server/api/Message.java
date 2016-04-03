package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.hibernate.validator.constraints.NotEmpty;

public class Message {

    private long id;
    private long timestamp;
    private long sender;
    private long receiver;
    @NotEmpty
    private String content;
    private String editData;

    public Message(long id, long timestamp, long sender, long receiver, String content, String editData) {
        this.id = id;
        this.timestamp = timestamp;
        this.sender = sender;
        this.receiver = receiver;
        this.content = content;
        this.editData = editData;
    }

    public Message(String content, long sender, long receiver) {
        this(0, 0, sender, receiver, content, null);
    }

    public Message() {
    }

    @JsonProperty
    public long getId() {
        return id;
    }

    @JsonProperty
    public void setId(long id) {
        this.id = id;
    }

    @JsonProperty
    public long getTimestamp() {
        return timestamp;
    }

    @JsonProperty
    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }

    @JsonProperty
    public String getContent() {
        return content;
    }

    @JsonProperty
    public void setContent(String content) {
        this.content = content;
    }

    @JsonProperty
    public String getEditData() {
        return editData;
    }

    @JsonProperty
    public void setEditData(String editData) {
        this.editData = editData;
    }

    @JsonProperty
    public long getSender() {
        return sender;
    }

    @JsonProperty
    public void setSender(long sender) {
        this.sender = sender;
    }

    @JsonProperty
    public long getReceiver() {
        return receiver;
    }

    @JsonProperty
    public void setReceiver(long receiver) {
        this.receiver = receiver;
    }
}
