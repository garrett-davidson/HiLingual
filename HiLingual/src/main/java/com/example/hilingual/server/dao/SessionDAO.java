/*
 * SessionDAO.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on 2/18/2016
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dao;

import io.dropwizard.lifecycle.Managed;

import java.util.List;
import java.util.UUID;

/**
 * Manages user sessions
 */
public interface SessionDAO extends Managed {

    /**
     * Checks if the given sessionId is valid for the given user. A given user
     * can have more than one session at a time.
     * @param sessionId The sessionId to check
     * @param userId The userId to check the sessionId against
     * @return true if the session is valid for the given user, false otherwise
     */
    boolean isValidSession(String sessionId, UUID userId);

    /**
     * Revokes the provided session
     * @param sessionId The session to revoke
     */
    void revokeSession(String sessionId);

    /**
     * Revokes all sessions
     * @return The number of sessions revoked
     */
    int revokeAllSessions();

    /**
     * Revokes all sessions that belong to the given userId
     * @param userId The userId whose sessions are to be revoked
     * @return The number of sessions revoked
     */
    int revokeAllSessionsForUser(UUID userId);

    /**]
     * Generates a new sessionId for the given user. A given user can have
     * more than one session at a time.
     * @param userId The userId to generate a new sessionId for
     * @return The generated sessionId
     */
    String newSession(UUID userId);

    /**
     * Gets all the sessionIds that belong to the given userId
     * @param userId The userId of the sessionIds to get
     * @return A list of sessionIds belonging to the userId
     */
    List<String> getAllSessionsForUser(UUID userId);

}
