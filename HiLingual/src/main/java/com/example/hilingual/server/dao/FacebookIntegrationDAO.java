/*
 * FacebookDAO.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dao;

import io.dropwizard.lifecycle.Managed;

public interface FacebookIntegrationDAO extends Managed {

    void init();

    long getUserIdFromFacebookAccountId(String accountId);

    void setUserIdForFacebookAccountId(long userId, String accountId);

}
