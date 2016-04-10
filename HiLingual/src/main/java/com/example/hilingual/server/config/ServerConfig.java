/*
 * ServerConfig.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on 2/16/2016
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.config;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.dropwizard.Configuration;
import io.dropwizard.db.DataSourceFactory;
import org.hibernate.validator.constraints.NotEmpty;

import javax.validation.Valid;
import javax.validation.constraints.NotNull;

public class ServerConfig extends Configuration {

    @Valid
    @NotNull
    private DataSourceFactory database = new DataSourceFactory();

    @NotEmpty
    private String sqlDbType;

    @Valid
    @NotNull
    private RedisConfig redisConfig;

    @Valid
    private FacebookConfig facebookConfig;

    @Valid
    private APNsConfig apnsConfig;

    @NotEmpty
    private String assetAccessBaseUrl;

    @NotEmpty
    private String assetAccessPath;

    @Valid
    private MsftTranslateConfig msftTranslateConfig;

    @NotEmpty
    private String slackIncomingWebhookUrl;

    @JsonProperty("sqlDb")
    public DataSourceFactory getDataSourceFactory() {
        return database;
    }

    @JsonProperty("sqlDb")
    public void setDataSourceFactory(DataSourceFactory factory) {
        this.database = factory;
    }

    @JsonProperty("sqlDbType")
    public String getSqlDbType() {
        return sqlDbType;
    }

    @JsonProperty("sqlDbType")
    public void setSqlDbType(String sqlDbType) {
        this.sqlDbType = sqlDbType;
    }


    @JsonProperty("redis")
    public RedisConfig getRedisConfig() {
        return redisConfig;
    }

    @JsonProperty("redis")
    public void setRedisConfig(RedisConfig redisConfig) {
        this.redisConfig = redisConfig;
    }


    @JsonProperty("facebook")
    public FacebookConfig getFacebookConfig() {
        return facebookConfig;
    }

    @JsonProperty("facebook")
    public void setFacebookConfig(FacebookConfig facebookConfig) {
        this.facebookConfig = facebookConfig;
    }

    @JsonProperty("apns")
    public APNsConfig getApnsConfig() {
        return apnsConfig;
    }

    @JsonProperty("apns")
    public void setApnsConfig(APNsConfig apnsConfig) {
        this.apnsConfig = apnsConfig;
    }

    @JsonProperty
    public String getAssetAccessBaseUrl() {
        return assetAccessBaseUrl;
    }

    @JsonProperty
    public void setAssetAccessBaseUrl(String assetAccessBaseUrl) {
        this.assetAccessBaseUrl = assetAccessBaseUrl;
    }

    @JsonProperty
    public String getAssetAccessPath() {
        return assetAccessPath;
    }

    @JsonProperty
    public void setAssetAccessPath(String assetAccessPath) {
        this.assetAccessPath = assetAccessPath;
    }

    @JsonProperty("msftTranslate")
    public MsftTranslateConfig getMsftTranslateConfig() {
        return msftTranslateConfig;
    }

    @JsonProperty("msftTranslate")
    public void setMsftTranslateConfig(MsftTranslateConfig msftTranslateConfig) {
        this.msftTranslateConfig = msftTranslateConfig;
    }

    @JsonProperty
    public String getSlackIncomingWebhookUrl() {
        return slackIncomingWebhookUrl;
    }

    @JsonProperty
    public void setSlackIncomingWebhookUrl(String slackIncomingWebhookUrl) {
        this.slackIncomingWebhookUrl = slackIncomingWebhookUrl;
    }
}
