package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Set;

public class UserChats {

    private long userId;
    private Set<Long> currentChats;
    private Set<Long> pendingChats;

    public UserChats(long userId, Set<Long> currentChats, Set<Long> pendingChats) {
        this.userId = userId;
        this.currentChats = currentChats;
        this.pendingChats = pendingChats;
    }
    public UserChats() {
    }

    @JsonProperty
    public long getUserId() {
        return userId;
    }

    @JsonProperty
    public void setUserId(long userId) {
        this.userId = userId;
    }

    @JsonProperty
    public Set<Long> getCurrentChats() {
        return currentChats;
    }

    @JsonProperty
    public void setCurrentChats(Set<Long> currentChats) {
        this.currentChats = currentChats;
    }

    @JsonProperty
    public Set<Long> getPendingChats() {
        return pendingChats;
    }

    @JsonProperty
    public void setPendingChats(Set<Long> pendingChats) {
        this.pendingChats = pendingChats;
    }


}