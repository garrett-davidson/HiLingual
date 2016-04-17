package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;

public class AuthResponse {

    private String sessionToken;
    private User user;

    public AuthResponse() {
    }

    public AuthResponse(String sessionToken, User user) {
        this.sessionToken = sessionToken;
        this.user = user;
    }

    @JsonProperty
    public String getSessionToken() {
        return sessionToken;
    }

    @JsonProperty
    public void setSessionToken(String sessionToken) {
        this.sessionToken = sessionToken;
    }

    @JsonProperty
    public User getUser() {
        return user;
    }

    @JsonProperty
    public void setUser(User user) {
        this.user = user;
    }
}
