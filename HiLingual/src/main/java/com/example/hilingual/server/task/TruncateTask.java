/*
 * TruncateUsersTask.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.task;

import com.example.hilingual.server.dao.*;
import com.google.common.collect.ImmutableMultimap;
import com.google.inject.Inject;
import io.dropwizard.servlets.tasks.Task;

import java.io.PrintWriter;

public class TruncateTask extends Task {

    private final UserDAO userDAO;
    private final FacebookIntegrationDAO facebookIntegrationDAO;
    private final GoogleIntegrationDAO googleIntegrationDAO;
    private final SessionDAO sessionDAO;
    private final ChatMessageDAO chatMessageDAO;
    private final DeviceTokenDAO deviceTokenDAO;
    private final CardDAO cardDAO;

    @Inject
    public TruncateTask(UserDAO userDAO,
                        FacebookIntegrationDAO facebookIntegrationDAO,
                        GoogleIntegrationDAO googleIntegrationDAO,
                        SessionDAO sessionDAO,
                        ChatMessageDAO chatMessageDAO,
                        DeviceTokenDAO deviceTokenDAO,
                        CardDAO cardDAO) {
        super("truncate-databases");
        this.userDAO = userDAO;
        this.facebookIntegrationDAO = facebookIntegrationDAO;
        this.googleIntegrationDAO = googleIntegrationDAO;
        this.sessionDAO = sessionDAO;
        this.chatMessageDAO = chatMessageDAO;
        this.deviceTokenDAO = deviceTokenDAO;
        this.cardDAO = cardDAO;
    }

    @Override
    public void execute(ImmutableMultimap<String, String> parameters, PrintWriter output) throws Exception {
        if (!parameters.get("truncate").contains("1")) {
            output.println("Are you sure you wish to truncate all databases?");
            output.println("WARNING!!! THIS WILL DELETE ALL USER DATA");
            output.println("Only perform this operation in testing");
            output.println("If you wish to continue, reissue the request with truncate=1");
            output.flush();
            return;
        }
        output.println("Truncating user database (1/7)...");
        userDAO.truncate();
        output.println("Truncating Facebook database (2/7)...");
        facebookIntegrationDAO.truncate();
        output.println("Truncating Google database (3/7)...");
        googleIntegrationDAO.truncate();
        output.println("Truncating session database (4/7)...");
        sessionDAO.truncate();
        output.println("Truncating chat database (5/7)...");
        chatMessageDAO.truncate();
        output.println("Truncating device token database (6/7)...");
        deviceTokenDAO.truncate();
        output.println("Truncating card database (7/7)...");
        cardDAO.truncate();

        output.println("Databases truncated. I hope you knew what you were doing.");
    }
}
