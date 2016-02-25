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

import javax.ws.rs.NotAuthorizedException;
import java.util.List;

/**
 * Manages user sessions
 */
public interface SessionDAO extends Managed {

    void init();

    /**
     * Checks if the given sessionId is valid for the given user. A given user
     * can have more than one session at a time.
     * @param sessionId The sessionId to check
     * @param userId The userId to check the sessionId against
     * @return true if the session is valid for the given user, false otherwise
     */
    boolean isValidSession(String sessionId, long userId);

    /**
     * Revokes the provided session
     * @param sessionId The session to revoke
     * @Param userId The userId of the sessionId to revoke
     */
    void revokeSession(String sessionId, long userId);

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
    int revokeAllSessionsForUser(long userId);

    /**]
     * Generates a new sessionId for the given user. A given user can have
     * more than one session at a time.
     * @param userId The userId to generate a new sessionId for
     * @return The generated sessionId
     */
    String newSession(long userId);

    /**
     * Gets all the sessionIds that belong to the given userId
     * @param userId The userId of the sessionIds to get
     * @return A list of sessionIds belonging to the userId
     */
    List<String> getAllSessionsForUser(long userId);

    /**
     * Gets the userId to which this session belongs to
     * @param sessionId The sessionId to look up
     * @return The userId that owns the given session
     */
    long getSessionOwner(String sessionId);

    static String getSessionIdFromHLAT(String hlat) {
        if (hlat == null) {
            throw new NotAuthorizedException("Missing session token");
        }
        if (hlat.startsWith("HLAT ")) {
            return hlat.substring("HLAT ".length());
        }
        throw new NotAuthorizedException("Bad session token");
    }
}
