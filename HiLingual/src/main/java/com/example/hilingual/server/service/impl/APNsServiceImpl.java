/*
 * APNsServiceImpl.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.service.impl;

import com.example.hilingual.server.config.APNsConfig;
import com.example.hilingual.server.config.ServerConfig;
import com.example.hilingual.server.service.APNsService;
import com.google.inject.Inject;
import com.relayrides.pushy.apns.ApnsClient;
import com.relayrides.pushy.apns.ClientNotConnectedException;
import com.relayrides.pushy.apns.PushNotificationResponse;
import com.relayrides.pushy.apns.util.SimpleApnsPushNotification;
import com.relayrides.pushy.apns.util.TokenUtil;
import io.netty.util.concurrent.Future;

import java.io.File;
import java.util.concurrent.ExecutionException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class APNsServiceImpl implements APNsService {

    private static final Logger LOGGER = Logger.getLogger(APNsServiceImpl.class.getName());

    private APNsConfig config;
    private ApnsClient<SimpleApnsPushNotification> client;

    @Inject
    public APNsServiceImpl(ServerConfig config) {
        this.config = config.getApnsConfig();
    }

    @Override
    public void sendNotification(String token, String payload) {
        SimpleApnsPushNotification pushNotif = new SimpleApnsPushNotification(TokenUtil.sanitizeTokenString(token),
                "com.example.hilingual",
                payload);
        Future<PushNotificationResponse<SimpleApnsPushNotification>> future =
                client.sendNotification(pushNotif);
        try {
            try {
                PushNotificationResponse<SimpleApnsPushNotification> response = future.get();
                if (response.isAccepted()) {
                    LOGGER.info("Notification accepted by APNs");
                } else {
                    LOGGER.warning("Notification rejected by APNs: " + response.getRejectionReason());
                    if (response.getTokenInvalidationTimestamp() != null) {
                        LOGGER.warning("Token invalid as of " + response.getTokenInvalidationTimestamp());
                    }
                }
            } catch (ExecutionException e) {
                LOGGER.log(Level.WARNING, "Failed to send notification", e);
                if (e.getCause() instanceof ClientNotConnectedException) {
                    LOGGER.warning("APNs Client was not connected! Awaiting reconnect");
                    client.getReconnectionFuture().await();
                    LOGGER.info("APNs Client reconnected");
                }
            }
        }catch (InterruptedException ie) {
            LOGGER.log(Level.WARNING, "Interrupted while waiting to send notification");
        }
    }

    @Override
    public void start() throws Exception {
        client = new ApnsClient<>(new File(config.getCertFile()), config.getCertPassword());
        Future<Void> connectFuture = client.connect(config.isDeveloper() ?
                ApnsClient.DEVELOPMENT_APNS_HOST :
                ApnsClient.PRODUCTION_APNS_HOST);
        connectFuture.await();
    }

    @Override
    public void stop() throws Exception {
        Future<Void> disconnectFuture = client.disconnect();
        disconnectFuture.await();
    }
}
