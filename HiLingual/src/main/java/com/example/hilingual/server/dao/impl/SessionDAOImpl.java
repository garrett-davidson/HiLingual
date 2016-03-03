/*
 * SessionDAOImpl.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dao.impl;

import com.example.hilingual.server.dao.SessionDAO;
import com.google.inject.Inject;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.Transaction;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.Set;
import java.util.concurrent.atomic.LongAdder;
import java.util.logging.Logger;

public class SessionDAOImpl implements SessionDAO {

    private static Logger LOGGER = Logger.getLogger(SessionDAOImpl.class.getName());

    public static final String HL_SESSIONS_USER_SCOPE = "hl:sessions:user:";
    public static final String HL_SESSIONS_SESSION_SCOPE = "hl:sessions:session:";
    public static final String HL_SESSIONS_USERS_KEY = "hl:sessions:users";
    private Jedis jedis;
    private Random random;

    @Inject
    public SessionDAOImpl(Jedis jedis) {
        this.jedis = jedis;
    }


    @Override
    public void init() {
        random = new Random();
        //  Force secure seeding
        byte[] temp = new byte[128];
        random.nextBytes(temp);
    }

    @Override
    public boolean isValidSession(String sessionId, long userId) {
        if (userId == -1) {
            return false;
        }
        return jedis.sismember(userIdKey(userId), sessionId);
    }

    @Override
    public void revokeSession(String sessionId, long userId) {
        String key = userIdKey(userId);
        Transaction t = jedis.multi();
        t.srem(key, sessionId);
        t.srem(HL_SESSIONS_USERS_KEY, longStr(userId));
        t.exec();
        if (jedis.scard(key) == 0) {
            revokeAllSessionsForUser(userId);
        }
    }

    @Override
    public int revokeAllSessions() {
        Set<String> sessionedUsers = jedis.smembers(HL_SESSIONS_USERS_KEY);
        LongAdder adder = new LongAdder();
        sessionedUsers.stream().
                mapToLong(Long::parseLong).
                forEach(u -> adder.add(revokeAllSessionsForUser(u)));
        return (int) adder.sum();
    }

    @Override
    public int revokeAllSessionsForUser(long userId) {
        String key = userIdKey(userId);
        List<String> sessions = getAllSessionsForUser(userId);
        Transaction t = jedis.multi();
        t.del(key);
        sessions.stream().
                map(this::sessionKey).
                forEach(t::del);
        t.srem(HL_SESSIONS_USERS_KEY, longStr(userId));
        t.exec();
        return sessions.size();
    }

    @Override
    public String newSession(long userId) {
        String sid = new BigInteger(130, random).toString(32);
        String userIdStr = longStr(userId);
        Transaction t = jedis.multi();
        t.sadd(userIdKey(userId), sid);
        t.set(sessionKey(sid), userIdStr);
        t.sadd(HL_SESSIONS_USERS_KEY, userIdStr);
        t.exec();
        return sid;
    }

    @Override
    public List<String> getAllSessionsForUser(long userId) {
        return new ArrayList<>(jedis.smembers(userIdKey(userId)));
    }

    @Override
    public long getSessionOwner(String sessionId) {
        try {
            return Long.parseLong(jedis.get(sessionKey(sessionId)));
        } catch (NumberFormatException e) {
            return -1;
        }
    }


    @Override
    public void start() throws Exception {
        LOGGER.info("Init DAO");
        init();
    }

    @Override
    public void stop() throws Exception {

    }

    private String longStr(long l) {
        return Long.toString(l);
    }

    private String userIdKey(long userId) {
        return userIdKey(longStr(userId));
    }

    private String userIdKey(String userId) {
        return HL_SESSIONS_USER_SCOPE + userId;
    }

    private String sessionKey(String session) {
        return HL_SESSIONS_SESSION_SCOPE + session;
    }
}
