package com.example.hilingual.server.dao.impl;

import com.example.hilingual.server.dao.DeviceTokenDAO;
import com.google.inject.Inject;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.Transaction;

import java.util.Set;
import java.util.logging.Logger;

public class DeviceTokenDAOImpl implements DeviceTokenDAO {

    private static Logger LOGGER = Logger.getLogger(DeviceTokenDAOImpl.class.getName());

    public static final String HL_DEVICE_TOKEN_USER_SCOPE = "hl:devicetokens:user:";
    public static final String HL_DEVICE_TOKEN_USERS_KEY = "hl:devicetokens:users";
    private JedisPool pool;

    @Inject
    public DeviceTokenDAOImpl(JedisPool pool) {
        this.pool = pool;
    }

    @Override
    public void init() {

    }

    @Override
    public void addDeviceToken(long userId, String token) {
        Jedis jedis = pool.getResource();
        try {
            String key = userIdKey(userId);
            Transaction t = jedis.multi();
            t.sadd(key, token);
            t.sadd(HL_DEVICE_TOKEN_USERS_KEY, longStr(userId));
            t.exec();
        } finally {
            pool.returnResourceObject(jedis);
        }
    }

    @Override
    public void revokeUserDeviceToken(long userId, String token) {
        Jedis jedis = pool.getResource();
        try {
            String key = userIdKey(userId);
            jedis.srem(key, token);
            if (jedis.scard(key) == 0) {
                revokeAllUserDeviceTokens(userId);
            }
        } finally {
            pool.returnResourceObject(jedis);
        }
    }

    @Override
    public int revokeAllUserDeviceTokens(long userId) {
        Jedis jedis = pool.getResource();
        try {
            String key = userIdKey(userId);
            int ret = jedis.scard(key).intValue();
            Transaction t = jedis.multi();
            t.del(key);
            t.srem(HL_DEVICE_TOKEN_USERS_KEY, longStr(userId));
            return ret;
        } finally {
            pool.returnResourceObject(jedis);
        }
    }

    @Override
    public void truncate() {
        Jedis jedis = pool.getResource();
        try {
            Set<String> vals = jedis.smembers(HL_DEVICE_TOKEN_USERS_KEY);
            Transaction t = jedis.multi();
            vals.stream().
                    map(this::userIdKey).
                    forEach(t::del);
            t.del(HL_DEVICE_TOKEN_USERS_KEY);
            t.exec();
        } finally {
            pool.returnResourceObject(jedis);
        }
    }

    @Override
    public Set<String> getUserDeviceTokens(long userId) {
        Jedis jedis = pool.getResource();
        try {
            return jedis.smembers(userIdKey(userId));
        } finally {
            pool.returnResourceObject(jedis);
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
        return HL_DEVICE_TOKEN_USER_SCOPE + userId;
    }
}
