/*
 * DummyFacebookGoogleIntegrationDAO.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dummy;

import com.example.hilingual.server.dao.FacebookIntegrationDAO;
import com.example.hilingual.server.dao.GoogleIntegrationDAO;

public class DummyFacebookGoogleIntegrationDAO implements FacebookIntegrationDAO, GoogleIntegrationDAO {
    @Override
    public boolean isValidFacebookSession(String accountId, String token) {
        return true;
    }

    @Override
    public long getUserIdFromFacebookAccountId(String accountId) {
        return DummyUserDAO.JOHN_DOE.getUuid();
    }

    @Override
    public boolean isValidGoogleSession(String accountId, String token) {
        return true;
    }

    @Override
    public long getUserIdFromGoogleAccountId(String accountId) {
        return DummyUserDAO.JOHN_DOE.getUuid();
    }
}
