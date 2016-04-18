package com.example.hilingual.server.dao.impl;

import com.example.hilingual.server.dao.TranslationCacheDAO;
import com.google.inject.Inject;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

public class TranslationCacheDAOImpl implements TranslationCacheDAO {

    public static final int EXPIRY_TIME = (int) TimeUnit.MINUTES.toSeconds(30);
    private static String HL_CACHE_BASE = "hl:cache:translation.";

    private JedisPool pool;

    @Inject
    public TranslationCacheDAOImpl(JedisPool pool) {
        this.pool = pool;
    }

    @Override
    public String getCached(Locale target, String source) {
        String key = key(target, hash(source));
        Jedis jedis = pool.getResource();
        try {
            String s = jedis.get(key);
            if (s != null) {
                jedis.expire(key, EXPIRY_TIME);
            }
            return s;
        } finally {
            pool.returnResourceObject(jedis);
        }
    }

    @Override
    public void cache(Locale target, String source, String result) {
        Jedis jedis = pool.getResource();
        String key = key(target, hash(source));
        try {
            jedis.set(key, result);
            jedis.expire(key, EXPIRY_TIME);
        } finally {
            pool.returnResourceObject(jedis);
        }
    }

    private String key(Locale locale, String hash) {
        return HL_CACHE_BASE + locale.toLanguageTag() + "." + hash;
    }

    private String hash(String s) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-1");
            digest.reset();
            byte[] data = digest.digest(s.getBytes(StandardCharsets.UTF_8));
            StringBuilder builder = new StringBuilder();
            for (byte b : data) {
                builder.append(String.format("%02X", b));
            }
            return builder.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("should never happen, all platforms must impl SHA-1");
        }
    }
}
