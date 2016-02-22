/*
 * GoogleLoginDAO.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dao;

public interface GoogleIntegrationDAO {

    boolean isValidGoogleSession(String accountId, String token);

    long getUserIdFromGoogleAccountId(String accountId);

}
