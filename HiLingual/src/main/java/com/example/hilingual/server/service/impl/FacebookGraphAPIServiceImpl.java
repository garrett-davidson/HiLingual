/*
 * FacebookAPIServiceImpl.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.service.impl;

import com.example.hilingual.server.config.ServerConfig;
import com.example.hilingual.server.service.FacebookGraphAPIService;
import com.google.inject.Inject;
import com.mashape.unirest.http.HttpResponse;
import com.mashape.unirest.http.JsonNode;
import com.mashape.unirest.http.Unirest;
import com.mashape.unirest.http.exceptions.UnirestException;
import org.apache.http.protocol.HTTP;
import org.json.JSONObject;

import javax.ws.rs.InternalServerErrorException;
import javax.ws.rs.core.MediaType;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class FacebookGraphAPIServiceImpl implements FacebookGraphAPIService {

    private static Logger LOGGER = Logger.getLogger(FacebookGraphAPIServiceImpl.class.getName());

    private ServerConfig config;

    @Inject
    public FacebookGraphAPIServiceImpl(ServerConfig config) {
        this.config = config;
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
}
