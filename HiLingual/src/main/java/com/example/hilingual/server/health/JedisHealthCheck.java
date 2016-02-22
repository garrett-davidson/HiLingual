/*
 * JedisHealthCheck.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on 2/22/16
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.health;

import com.codahale.metrics.health.HealthCheck;
import com.google.inject.Inject;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

public class JedisHealthCheck extends HealthCheck {

    private final JedisPool jedisPool;

    @Inject
    public JedisHealthCheck(JedisPool jedisPool) {
        this.jedisPool = jedisPool;
    }

    @Override
    protected Result check() throws Exception {
        if (jedisPool.isClosed()) {
            return Result.unhealthy("Jedis pool was closed");
        }
        try (Jedis jedis = jedisPool.getResource()) {
            String resp = jedis.ping();
            if (!"PONG".equals(resp)) {
                return Result.unhealthy("Redis server did not respond to PING");
            }
        }
        return Result.healthy();
    }
}
