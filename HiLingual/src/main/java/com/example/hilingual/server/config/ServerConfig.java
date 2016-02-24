/*
 * ServerConfig.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on 2/16/2016
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.config;

import com.bendb.dropwizard.redis.JedisFactory;
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
    private JedisFactory redis = new JedisFactory();

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
    public JedisFactory getRedisFactory() {
        return redis;
    }

    @JsonProperty("redis")
    public void setRedisFactory(JedisFactory factory) {
        this.redis = factory;
    }
}
