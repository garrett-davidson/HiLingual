/*
 * ApnsTestTask.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.task;

import com.example.hilingual.server.service.APNsService;
import com.google.common.collect.ImmutableMultimap;
import com.google.inject.Inject;
import com.relayrides.pushy.apns.util.ApnsPayloadBuilder;
import io.dropwizard.servlets.tasks.Task;

import java.io.PrintWriter;
import java.util.Optional;

public class ApnsTestTask extends Task {

    private APNsService service;

    @Inject
    public ApnsTestTask(APNsService service) {
        super("apns-test");
        this.service = service;
    }

    @Override
    public void execute(ImmutableMultimap<String, String> parameters, PrintWriter output) throws Exception {
        String message = parameters.get("message").stream().findFirst().orElse("It worked!");
        Optional<String> token = parameters.get("token").stream().findFirst();
        if (!token.isPresent()) {
            output.println("Please provide your device token as a query parameter ?token=TOKEN");
            return;
        }
        service.sendNotification(token.get(), new ApnsPayloadBuilder().
                setAlertTitle("HiLingual").
                setAlertBody(message).buildWithDefaultMaximumLength());
        output.println("Did it work");
    }
}
