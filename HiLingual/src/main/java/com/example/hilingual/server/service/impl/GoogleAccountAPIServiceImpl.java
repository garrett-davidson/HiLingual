/*
 * GoogleAccountAPIServiceImpl.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.service.impl;

import com.example.hilingual.server.service.GoogleAccountAPIService;
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

public class GoogleAccountAPIServiceImpl implements GoogleAccountAPIService {

    private static Logger LOGGER = Logger.getLogger(GoogleAccountAPIServiceImpl.class.getName());

    @Override
    public boolean isValidGoogleSession(String accountId, String token) {
        Map<String, Object> queryParams = new LinkedHashMap<>();
        queryParams.put("id_token", token);
        try {
            HttpResponse<JsonNode> response = Unirest.get("https://www.googleapis.com/oauth2/v3/tokeninfo").
                    header(HTTP.CONTENT_TYPE, MediaType.APPLICATION_JSON).
                    queryString(queryParams).
                    asJson();
            if (response.getStatus() != 200) {
                LOGGER.info("Google returned non-200 response code " + response.getStatus() +
                        ", " + response.getStatusText());
                throw new UnirestException("Google returned non-200 response code " + response.getStatus() +
                        ", " + response.getStatusText());

            }
            JSONObject val = response.getBody().getObject();
            if (val.has("error")) {
                LOGGER.info("Error: " + val.getString("error") + ", " +
                        val.getString("error_description"));
                throw new UnirestException("Error: " + val.getString("error") + ", " +
                        val.getString("error_description"));
            }
            return val.getString("sub").equals(accountId);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to contact Google", e);
            throw new InternalServerErrorException("Failed to contact Google", e);
        }
    }
}
