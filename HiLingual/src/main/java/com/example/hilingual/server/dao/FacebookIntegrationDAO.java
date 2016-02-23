/*
 * FacebookDAO.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dao;

public interface FacebookIntegrationDAO {

    boolean isValidFacebookSession(String accountId, String token);

    long getUserIdFromFacebookAccountId(String accountId);

    void setUserIdForFacebookAccountId(long userId, String accountId);

}
