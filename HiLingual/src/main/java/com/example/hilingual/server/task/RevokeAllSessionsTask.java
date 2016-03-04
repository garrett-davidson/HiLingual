/*
 * ClearSessionsTask.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.task;

import com.example.hilingual.server.dao.SessionDAO;
import com.google.common.collect.ImmutableMultimap;
import com.google.inject.Inject;
import io.dropwizard.servlets.tasks.Task;

import java.io.PrintWriter;

public class RevokeAllSessionsTask extends Task {

    private SessionDAO sessionDAO;

    @Inject
    public RevokeAllSessionsTask(SessionDAO sessionDAO) {
        super("revoke-all-sessions");
        this.sessionDAO = sessionDAO;
    }

    @Override
    public void execute(ImmutableMultimap<String, String> parameters, PrintWriter output) throws Exception {
        output.write("Revoking active sessions...\n");
        output.flush();
        int del = sessionDAO.revokeAllSessions();
        output.write(String.format("Revoked %,d sessions\n", del));
        output.flush();
    }
}
