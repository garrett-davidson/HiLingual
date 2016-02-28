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

public class GoogleIntegrationDAOImpl implements GoogleIntegrationDAO {
    @Override
    public void init() {

    }

    @Override
    public long getUserIdFromGoogleAccountId(String accountId) {
        return 0;
    }

    @Override
    public void setUserIdForGoogleAccountId(long userId, String accountId) {

    }

    @Override
    public String getGoogleToken(long userId) {
        return null;
    }

    @Override
    public void setGoogleToken(long userId, String token) {

    }

    @Override
    public void start() throws Exception {

    }

    @Override
    public void stop() throws Exception {

    }
}
