package com.example.hilingual.server.dao.impl;

import com.example.hilingual.server.api.flash.CardRing;
import com.example.hilingual.server.dao.CardDAO;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.inject.Inject;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.Transaction;

import java.util.Set;

public class CardDAOImpl implements CardDAO {

    private static final String HL_CARDS_KEY_PREFIX = "hl:cards:";
    private static final String HL_CARDS_KEY_FMT = HL_CARDS_KEY_PREFIX + "%s";

    private JedisPool pool;
    private Gson gson;

    @Inject
    public CardDAOImpl(JedisPool pool) {
        this.pool = pool;
        gson = new GsonBuilder().create();
    }

    @Override
    public CardRing[] getCards(long userId) {
        Jedis jedis = pool.getResource();
        try {
            String json = jedis.get(key(userId));
            if (json == null) {
                return new CardRing[0];
            }
            return gson.fromJson(json, CardRing[].class);
        } finally {
            pool.returnResourceObject(jedis);
        }
    }

    @Override
    public void setCards(CardRing[] rings, long userId) {
        Jedis jedis = pool.getResource();
        try {
            String json = gson.toJson(rings);
            jedis.set(key(userId), json);
        } finally {
            pool.returnResourceObject(jedis);
        }
    }

    @Override
    public void truncate() {
        Jedis jedis = pool.getResource();
        try {
            Set<String> keys = jedis.keys(HL_CARDS_KEY_PREFIX + "*");
            Transaction t = jedis.multi();
            keys.forEach(t::del);
            t.exec();
        } finally {
            pool.returnResourceObject(jedis);
        }
    }

    private String key(long userId) {
        return String.format(HL_CARDS_KEY_FMT, Long.toUnsignedString(userId));
    }

    @Override
    public void start() throws Exception {

    }

    @Override
    public void stop() throws Exception {

    }
}
