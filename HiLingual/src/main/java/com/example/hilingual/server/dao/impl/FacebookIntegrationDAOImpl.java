/*
 * FacebookIntegrationDAOImpl.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dao.impl;

import com.example.hilingual.server.dao.FacebookIntegrationDAO;
import com.google.inject.Inject;
import io.dropwizard.lifecycle.Managed;
import org.skife.jdbi.v2.DBI;
import org.skife.jdbi.v2.Handle;

import java.util.logging.Logger;

public class FacebookIntegrationDAOImpl implements FacebookIntegrationDAO, Managed {

    private final DBI dbi;
    private Handle handle;

    private static Logger LOGGER = Logger.getLogger(FacebookIntegrationDAOImpl.class.getName());

    @Inject
    public FacebookIntegrationDAOImpl(DBI dbi) {
        this.dbi = dbi;
    }

    @Override
    public void init() {
        handle.execute("CREATE TABLE IF NOT EXISTS hl_facebook_data(" +
                "user_id BIGINT UNIQUE PRIMARY KEY," +
                " account_id VARCHAR(255))");
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
