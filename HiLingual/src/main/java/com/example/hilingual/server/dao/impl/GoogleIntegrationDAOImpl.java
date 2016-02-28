/*
 * GoogleIntegrationDAOImpl.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dao.impl;

import com.example.hilingual.server.dao.GoogleIntegrationDAO;
import com.google.inject.Inject;
import org.skife.jdbi.v2.DBI;
import org.skife.jdbi.v2.Handle;

import java.util.logging.Logger;

public class GoogleIntegrationDAOImpl implements GoogleIntegrationDAO {

    private final DBI dbi;
    private Handle handle;

    private static Logger LOGGER = Logger.getLogger(GoogleIntegrationDAOImpl.class.getName());

    @Inject
    public GoogleIntegrationDAOImpl(DBI dbi) {
        this.dbi = dbi;
    }

    @Override
    public void init() {
        handle.execute("CREATE TABLE IF NOT EXISTS hl_google_data(" +
                "user_id BIGINT UNIQUE PRIMARY KEY, " +
                "account_id VARCHAR(255), " +
                "token VARCHAR(255))");
    }

    @Override
    public long getUserIdFromGoogleAccountId(String accountId) {
        return handle.createQuery("SELECT user_id FROM hl_google_data WHERE account_id = :aid").
                bind("aid", accountId).
                first(long.class);
    }

    @Override
    public void setUserIdForGoogleAccountId(long userId, String accountId) {
        handle.update("INSERT INTO hl_google_data (user_id, account_id) VALUES (?, ?)",
                accountId, userId);
    }

    @Override
    public String getGoogleToken(long userId) {
        return handle.createQuery("SELECT token FROM hl_google_data WHERE user_id = :uid").
                bind("uid", userId).
                first(String.class);
    }

    @Override
    public void setGoogleToken(long userId, String token) {
        handle.execute("UPDATE hl_google_data SET token=? WHERE user_id=?", token, userId);
    }

    @Override
    public void truncate() {
        handle.execute("TRUNCATE hl_google_data");
    }

    @Override
    public void start() throws Exception {
        LOGGER.info("Opening DBI handle");
        handle = dbi.open();
        LOGGER.info("Init DAO");
        init();
    }

    @Override
    public void stop() throws Exception {
        handle.close();
    }
}
