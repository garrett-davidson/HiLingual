package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;

public class UserChats {

    private long[] currentChats;
    private long[] pendingChats;

    public UserChats(long[] currentChats, long[] pendingChats) {
        this.currentChats = currentChats;
        this.pendingChats = pendingChats;
    }

    @JsonProperty
    public long[] getCurrentChats() {
        return currentChats;
    }

    @JsonProperty
    public void setCurrentChats(long[] currentChats) {
        this.currentChats = currentChats;
    }

    @JsonProperty
    public long[] getPendingChats() {
        return pendingChats;
    }

    @JsonProperty
    public void setPendingChats(long[] pendingChats) {
        this.pendingChats = pendingChats;
    }
}
