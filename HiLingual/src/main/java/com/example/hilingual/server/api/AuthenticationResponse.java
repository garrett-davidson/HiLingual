/*
 * AuthenticatedUser.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;

public class AuthenticationResponse {

    private long userId;

    private String sessionId;


    public AuthenticationResponse() {
    }

    public AuthenticationResponse(long userId, String sessionId) {
        this.userId = userId;
        this.sessionId = sessionId;
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
    public String getSessionId() {
        return sessionId;
    }

    @JsonProperty
    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }
}
