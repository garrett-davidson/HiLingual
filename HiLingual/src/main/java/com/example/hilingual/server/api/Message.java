package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;

public class Message {

    private long id;
    private long timestamp;
    private String content;
    private String editData;

    public Message(long id, long timestamp, String content, String editData) {
        this.id = id;
        this.timestamp = timestamp;
        this.content = content;
        this.editData = editData;
    }

    public Message(String content) {
        this(0, 0, content, null);
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
}
