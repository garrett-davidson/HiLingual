/*
 * APNsConfig.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.config;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.hibernate.validator.constraints.NotEmpty;

public class APNsConfig {

    @NotEmpty
    private String certFile;

    @NotEmpty
    private String certPassword;

    private boolean developer;

    @JsonProperty
    public boolean isDeveloper() {
        return developer;
    }

    @JsonProperty
    public void setDeveloper(boolean developer) {
        this.developer = developer;
    }

    @JsonProperty
    public String getCertFile() {
        return certFile;
    }

    @JsonProperty
    public void setCertFile(String certFile) {
        this.certFile = certFile;
    }

    @JsonProperty
    public String getCertPassword() {
        return certPassword;
    }

    @JsonProperty
    public void setCertPassword(String certPassword) {
        this.certPassword = certPassword;
    }
}
