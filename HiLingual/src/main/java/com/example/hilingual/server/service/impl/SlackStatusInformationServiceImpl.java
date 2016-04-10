package com.example.hilingual.server.service.impl;

import com.example.hilingual.server.config.ServerConfig;
import com.example.hilingual.server.service.SlackStatusInformationService;
import com.google.inject.Inject;
import com.mashape.unirest.http.JsonNode;
import com.mashape.unirest.http.Unirest;
import com.mashape.unirest.http.exceptions.UnirestException;
import org.json.JSONObject;

import java.util.logging.Level;
import java.util.logging.Logger;

public class SlackStatusInformationServiceImpl implements SlackStatusInformationService {

    private static final Logger LOGGER = Logger.getLogger(SlackStatusInformationServiceImpl.class.getName());

    private final ServerConfig config;

    @Inject
    public SlackStatusInformationServiceImpl(ServerConfig config) {
        this.config = config;
    }

    @Override
    public void start() throws Exception {
        try {
            JSONObject req = new JSONObject();
            req.put("text", "Server is starting");
            Unirest.post(config.getSlackIncomingWebhookUrl()).
                    body(new JsonNode(req.toString())).
                    asString();
        } catch (UnirestException e) {
            LOGGER.log(Level.WARNING, "Unable to notify slack of server start", e);
        }
    }

    @Override
    public void stop() throws Exception {
        try {
            JSONObject req = new JSONObject();
            req.put("text", "Server is stopping");
            Unirest.post(config.getSlackIncomingWebhookUrl()).
                    body(new JsonNode(req.toString())).
                    asString();
        } catch (UnirestException e) {
            LOGGER.log(Level.WARNING, "Unable to notify slack of server stop", e);
        }
    }
}
