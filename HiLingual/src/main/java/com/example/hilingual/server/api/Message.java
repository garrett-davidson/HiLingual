package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Base64;

public class Message {

    private long id;
    private long sentTimestamp;
    private long editTimestamp;
    private long sender;
    private long receiver;
    private String content;
    private String audio;
    private String audioUrl;

    private String editData;

    public Message(long id, long sentTimestamp, long editTimestamp, long sender, long receiver, String content, String audio, String editData) {
        this.id = id;
        this.sentTimestamp = sentTimestamp;
        this.editTimestamp = editTimestamp;
        this.sender = sender;
        this.receiver = receiver;
        this.content = content;
        this.audio = audio;
        this.editData = editData;
    }

    public Message(String content, long sender, long receiver) {
        this(0, 0, 0, sender, receiver, content, null, null);
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
    public long getSentTimestamp() {
        return sentTimestamp;
    }

    @JsonProperty
    public void setSentTimestamp(long sentTimestamp) { this.sentTimestamp = sentTimestamp;}

    @JsonProperty
    public long getEditTimestamp() { return editTimestamp; }

    @JsonProperty
    public void setEditTimestamp(long editTimestamp) { this.editTimestamp = editTimestamp; }

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

    @JsonProperty
    public String getAudio() {
        return audio;
    }

    @JsonProperty
    public void setAudio(String audio) {
        this.audio = audio;
    }

    public byte[] audioDataToBytes() {
        return Base64.getDecoder().decode(audio);
    }
}
