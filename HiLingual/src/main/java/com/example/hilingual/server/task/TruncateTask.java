/*
 * TruncateUsersTask.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.task;

import com.example.hilingual.server.dao.FacebookIntegrationDAO;
import com.example.hilingual.server.dao.GoogleIntegrationDAO;
import com.example.hilingual.server.dao.SessionDAO;
import com.example.hilingual.server.dao.UserDAO;
import com.google.common.collect.ImmutableMultimap;
import com.google.inject.Inject;
import io.dropwizard.servlets.tasks.Task;

import java.io.PrintWriter;

public class TruncateTask extends Task {

    private final UserDAO userDAO;
    private final FacebookIntegrationDAO facebookIntegrationDAO;
    private final GoogleIntegrationDAO googleIntegrationDAO;
    private final SessionDAO sessionDAO;

    @Inject
    public TruncateTask(UserDAO userDAO,
                        FacebookIntegrationDAO facebookIntegrationDAO,
                        GoogleIntegrationDAO googleIntegrationDAO,
                        SessionDAO sessionDAO) {
        super("truncate-databases");
        this.userDAO = userDAO;
        this.facebookIntegrationDAO = facebookIntegrationDAO;
        this.googleIntegrationDAO = googleIntegrationDAO;
        this.sessionDAO = sessionDAO;
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
        output.println("Truncating user database (1/4)...");
        userDAO.truncate();
        output.println("Truncating Facebook database (2/4)...");
        facebookIntegrationDAO.truncate();
        output.println("Truncating Google database (3/4)...");
        googleIntegrationDAO.truncate();
        output.println("Truncating session database (4/4)...");
        sessionDAO.truncate();
        output.println("Databases truncated. I hope you knew what you were doing.");
    }
}
