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
import gnu.trove.map.TObjectLongMap;
import gnu.trove.map.hash.TObjectLongHashMap;

public class DummyFacebookGoogleIntegrationDAO implements FacebookIntegrationDAO, GoogleIntegrationDAO {

    private TObjectLongMap<String> fbAccts;
    private TObjectLongMap<String> googleAccts;

    public DummyFacebookGoogleIntegrationDAO() {
        googleAccts = new TObjectLongHashMap<>();
        fbAccts = new TObjectLongHashMap<>();
        googleAccts.put("0", DummyUserDAO.JOHN_DOE.getUserId());
        fbAccts.put("0", DummyUserDAO.JOHN_DOE.getUserId());
    }

    @Override
    public void init() {
        //  Do nothing
    }

    @Override
    public long getUserIdFromFacebookAccountId(String accountId) {
        return fbAccts.get(accountId);
    }

    @Override
    public void setUserIdForFacebookAccountId(long userId, String accountId) {
        fbAccts.put(accountId, userId);
    }

    @Override
    public boolean isValidGoogleSession(String accountId, String token) {
        return true;
    }

    @Override
    public long getUserIdFromGoogleAccountId(String accountId) {
        return googleAccts.get(accountId);
    }

    @Override
    public void setUserIdForGoogleAccountId(long userId, String accountId) {
        googleAccts.put(accountId, userId);
    }

    @Override
    public void start() throws Exception {

    }

    @Override
    public void stop() throws Exception {

    }
}
