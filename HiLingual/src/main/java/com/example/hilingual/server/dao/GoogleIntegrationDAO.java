/*
 * GoogleLoginDAO.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dao;

import io.dropwizard.lifecycle.Managed;

public interface GoogleIntegrationDAO extends Managed {

    void init();

    boolean isValidGoogleSession(String accountId, String token);

    long getUserIdFromGoogleAccountId(String accountId);

    void setUserIdForGoogleAccountId(long userId, String accountId);

    String getGoogleToken(long userId);

    void setGoogleToken(long userId, String token);
}
