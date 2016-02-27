/*
 * FacebookIntegrationDAOImpl.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dao.impl;

import com.example.hilingual.server.config.ServerConfig;
import com.example.hilingual.server.dao.FacebookIntegrationDAO;
import com.google.inject.Inject;
import com.mashape.unirest.http.HttpResponse;
import com.mashape.unirest.http.JsonNode;
import com.mashape.unirest.http.Unirest;
import com.mashape.unirest.http.exceptions.UnirestException;
import io.dropwizard.lifecycle.Managed;
import org.apache.http.protocol.HTTP;
import org.json.JSONObject;
import org.skife.jdbi.v2.DBI;
import org.skife.jdbi.v2.Handle;

import javax.ws.rs.InternalServerErrorException;
import javax.ws.rs.core.MediaType;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class FacebookIntegrationDAOImpl implements FacebookIntegrationDAO, Managed {

    private final DBI dbi;
    private ServerConfig config;
    private Handle handle;

    private static Logger LOGGER = Logger.getLogger(FacebookIntegrationDAOImpl.class.getName());

    @Inject
    public FacebookIntegrationDAOImpl(DBI dbi, ServerConfig config) {
        this.dbi = dbi;
        this.config = config;
    }

    @Override
    public void init() {
        handle.execute("CREATE TABLE IF NOT EXISTS hl_facebook_data(" +
                "user_id BIGINT UNIQUE PRIMARY KEY," +
                " account_id VARCHAR(255))");
    }

    @Override
    public boolean isValidFacebookSession(String accountId, String token) {
        Map<String, Object> queryParams = new LinkedHashMap<>();
        queryParams.put("input_token", token);
        queryParams.put("access_token",
                config.getFacebookConfig().getId() + "|" + config.getFacebookConfig().getSecret());
        try {
            HttpResponse<JsonNode> response = Unirest.get("https://graph.facebook.com/debug_token").
                    header(HTTP.CONTENT_TYPE, MediaType.APPLICATION_JSON).
                    queryString(queryParams).
                    asJson();
            if (response.getStatus() != 200) {
                throw new UnirestException("Facebook returned non-200 response code " + response.getStatus() +
                        ", " + response.getStatusText());
            }
            JSONObject val = response.getBody().getObject();
            return val.getBoolean("is_valid") &&    //  Whether or not the token is valid
                    config.getFacebookConfig().getId().equals(val.getString("app_id")) &&   //  If this is our app
                    accountId.equals(val.getString("user_id")); //  If this is our user
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to contact Facebook", e);
            throw new InternalServerErrorException("Failed to contact Facebook", e);
        }
    }

    @Override
    public long getUserIdFromFacebookAccountId(String accountId) {
        return handle.createQuery("SELECT user_id FROM hl_facebook_data WHERE account_id = :aid").
                bind("aid", accountId).
                first(long.class);
    }

    @Override
    public void setUserIdForFacebookAccountId(long userId, String accountId) {
        handle.update("INSERT INTO hl_facebook_data (user_id, account_id) VALUES (?, ?)",
                accountId, userId);
    }

    @Override
    public void start() throws Exception {
        handle = dbi.open();
        init();
    }

    @Override
    public void stop() throws Exception {
        handle.close();
    }
}
