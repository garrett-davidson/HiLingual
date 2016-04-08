package com.example.hilingual.server.config;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.hibernate.validator.constraints.NotEmpty;

public class MsftTranslateConfig {

    @NotEmpty
    private String clientId;

    @NotEmpty
    private String clientSecret;

    public MsftTranslateConfig() {
    }

    public MsftTranslateConfig(String clientId, String clientSecret) {
        this.clientId = clientId;
        this.clientSecret = clientSecret;
    }

    @JsonProperty
    public String getClientId() {
        return clientId;
    }

    @JsonProperty
    public void setClientId(String clientId) {
        this.clientId = clientId;
    }

    @JsonProperty
    public String getClientSecret() {
        return clientSecret;
    }

    @JsonProperty
    public void setClientSecret(String clientSecret) {
        this.clientSecret = clientSecret;
    }
}
