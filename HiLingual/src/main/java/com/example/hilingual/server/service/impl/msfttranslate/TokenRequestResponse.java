package com.example.hilingual.server.service.impl.msfttranslate;

import com.fasterxml.jackson.annotation.JsonProperty;

public class TokenRequestResponse {

    private String accessToken;
    private String tokenType;
    private int expiresIn;
    private String scope;

    public TokenRequestResponse(String accessToken, String tokenType, int expiresIn, String scope) {
        this.accessToken = accessToken;
        this.tokenType = tokenType;
        this.expiresIn = expiresIn;
        this.scope = scope;
    }

    public TokenRequestResponse() {
    }

    @JsonProperty("access_token")
    public String getAccessToken() {
        return accessToken;
    }

    @JsonProperty("access_token")
    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    @JsonProperty("token_type")
    public String getTokenType() {
        return tokenType;
    }

    @JsonProperty("token_type")
    public void setTokenType(String tokenType) {
        this.tokenType = tokenType;
    }

    @JsonProperty("expires_in")
    public int getExpiresIn() {
        return expiresIn;
    }

    @JsonProperty("expires_in")
    public void setExpiresIn(int expiresIn) {
        this.expiresIn = expiresIn;
    }

    @JsonProperty
    public String getScope() {
        return scope;
    }

    @JsonProperty
    public void setScope(String scope) {
        this.scope = scope;
    }
}
