package com.example.hilingual.server.service.impl.msfttranslate;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public class TokenRequest {

    private String clientId;
    private String clientSecret;
    private String scope;
    private String grantType;

    public TokenRequest(String clientId, String clientSecret, String scope, String grantType) {
        this.clientId = clientId;
        this.clientSecret = clientSecret;
        this.scope = scope;
        this.grantType = grantType;
    }

    public TokenRequest() {
    }

    public String getClientId() {
        return clientId;
    }

    public void setClientId(String clientId) {
        this.clientId = clientId;
    }

    public String getClientSecret() {
        return clientSecret;
    }

    public void setClientSecret(String clientSecret) {
        this.clientSecret = clientSecret;
    }

    public String getScope() {
        return scope;
    }

    public void setScope(String scope) {
        this.scope = scope;
    }

    public String getGrantType() {
        return grantType;
    }

    public void setGrantType(String grantType) {
        this.grantType = grantType;
    }

    public String toBodyString() throws UnsupportedEncodingException {
        return String.format("grant_type=%s&scope=%s&client_id=%s&client_secret=%s",
                grantType, scope,
                URLEncoder.encode(clientId, StandardCharsets.UTF_8.name()),
                URLEncoder.encode(clientSecret, StandardCharsets.UTF_8.name()));
    }
}
