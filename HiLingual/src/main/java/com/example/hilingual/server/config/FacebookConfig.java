/*
 * FacebookConfig.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.config;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.hibernate.validator.constraints.NotEmpty;

public class FacebookConfig {

    @NotEmpty
    private String id;

    @NotEmpty
    private String secret;

    @JsonProperty
    public String getId() {
        return id;
    }

    @JsonProperty
    public void setId(String id) {
        this.id = id;
    }

    @JsonProperty
    public String getSecret() {
        return secret;
    }

    @JsonProperty
    public void setSecret(String secret) {
        this.secret = secret;
    }
}
