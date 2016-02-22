/*
 * RedisConfig.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on 2/22/16
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.config;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.hibernate.validator.constraints.NotEmpty;

import javax.validation.constraints.Min;

public class RedisConfig {

    @NotEmpty
    private String host;
    @Min(value = 1)
    private int port;

    private String password;
    @Min(value = 1)
    private int timeout;

    public RedisConfig() {
    }

    @JsonProperty
    public String getHost() {
        return host;
    }

    @JsonProperty
    public void setHost(String host) {
        this.host = host;
    }

    @JsonProperty
    public int getPort() {
        return port;
    }

    @JsonProperty
    public void setPort(int port) {
        this.port = port;
    }

    @JsonProperty
    public String getPassword() {
        return password;
    }

    @JsonProperty
    public void setPassword(String password) {
        this.password = password;
    }

    @JsonProperty
    public int getTimeout() {
        return timeout;
    }

    @JsonProperty
    public void setTimeout(int timeout) {
        this.timeout = timeout;
    }
}
