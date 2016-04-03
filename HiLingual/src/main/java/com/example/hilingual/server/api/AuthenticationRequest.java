/*
 * AuthenticationRequest.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.hibernate.validator.constraints.NotEmpty;

import javax.validation.constraints.NotNull;

public class AuthenticationRequest {

    @NotNull
    private Authority authority;

    @NotEmpty
    private String authorityAccountId;

    @NotEmpty
    private String authorityToken;

    private String deviceToken;

    @JsonProperty
    public AuthenticationRequest.Authority getAuthority() {
        return authority;
    }

    @JsonProperty
    public void setAuthority(Authority authority) {
        this.authority = authority;
    }

    @JsonProperty
    public String getAuthorityAccountId() {
        return authorityAccountId;
    }

    @JsonProperty
    public void setAuthorityAccountId(String authorityAccountId) {
        this.authorityAccountId = authorityAccountId;
    }

    @JsonProperty
    public String getAuthorityToken() {
        return authorityToken;
    }

    @JsonProperty
    public void setAuthorityToken(String authorityToken) {
        this.authorityToken = authorityToken;
    }

    @JsonProperty
    public String getDeviceToken() {
        return deviceToken;
    }

    @JsonProperty
    public void setDeviceToken(String deviceToken) {
        this.deviceToken = deviceToken;
    }

    public enum Authority {
        FACEBOOK,
        GOOGLE
    }
}
