package com.example.hilingual.server.service.impl;

import com.example.hilingual.server.service.LocalizationService;
import com.google.inject.Inject;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

import java.util.*;

public class LocalizationServiceImpl implements LocalizationService {

    private static final String HL_LOCALE_KEY_FORMAT = "hl:user:%s:locale";
    private final JedisPool pool;
    private Map<Locale, ResourceBundle> bundles = new HashMap<>();
    private ResourceBundle defaultLocale;

    @Inject
    public LocalizationServiceImpl(JedisPool pool) {
        this.pool = pool;
    }

    @Override
    public String localize(String key, Locale locale) {
        ResourceBundle bundle;
        if (locale == null) {
            bundle = defaultLocale;
        } else {
            bundle = bundles.get(locale);
            if (bundle == null) {
                try {
                    //  Try loading a bundle
                    ResourceBundle candidate =
                            ResourceBundle.getBundle("com.example.hilingual.server.localization.locale", locale);
                    bundle = candidate;
                    bundles.put(locale, candidate);
                } catch (MissingResourceException mre) {
                    bundle = defaultLocale;
                }
            }
        }
        try {
            return bundle.getString(key);
        } catch (MissingResourceException mre) {
            return key;
        }
    }

    @Override
    public Locale getUserLocale(long userId) {
        Jedis jedis = pool.getResource();
        try {
            String s = jedis.get(String.format(HL_LOCALE_KEY_FORMAT, userId));
            if (s == null) {
                return Locale.ENGLISH;
            } else {
                return Locale.forLanguageTag(s);
            }
        } finally {
            pool.returnResourceObject(jedis);
        }
    }

    @Override
    public void setUserLocale(long userId, Locale locale) {
        Jedis jedis = pool.getResource();
        try {
            jedis.set(String.format(HL_LOCALE_KEY_FORMAT, userId), locale.toLanguageTag());
        } finally {
            pool.returnResourceObject(jedis);
        }
    }

    @Override
    public void start() throws Exception {
        defaultLocale = ResourceBundle.getBundle("com.example.hilingual.server.localization.locale");
    }

    @Override
    public void stop() throws Exception {

    }
}
