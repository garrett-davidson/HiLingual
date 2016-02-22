/*
 * DummySessionDAO.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dummy;

import com.example.hilingual.server.dao.SessionDAO;
import com.google.common.collect.Lists;

import java.util.List;

public class DummySessionDAO implements SessionDAO {

    public static final String DUMMYSESSION = "dummysession";

    @Override
    public boolean isValidSession(String sessionId, long userId) {
        return DUMMYSESSION.equals(sessionId);
    }

    @Override
    public void revokeSession(String sessionId) {

    }

    @Override
    public int revokeAllSessions() {
        return 0;
    }

    @Override
    public int revokeAllSessionsForUser(long userId) {
        return 0;
    }

    @Override
    public String newSession(long userId) {
        return DUMMYSESSION;
    }

    @Override
    public List<String> getAllSessionsForUser(long userId) {
        return Lists.newArrayList(DUMMYSESSION);
    }

    @Override
    public void start() throws Exception {

    }

    @Override
    public void stop() throws Exception {

    }
}
