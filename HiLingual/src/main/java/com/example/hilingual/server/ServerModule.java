/*
 * ServerModule.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server;

import com.example.hilingual.server.config.ServerConfig;
import com.example.hilingual.server.dao.FacebookIntegrationDAO;
import com.example.hilingual.server.dao.GoogleIntegrationDAO;
import com.example.hilingual.server.dao.SessionDAO;
import com.example.hilingual.server.dao.UserDAO;
import com.example.hilingual.server.dao.impl.FacebookIntegrationDAOImpl;
import com.example.hilingual.server.dummy.DummyFacebookGoogleIntegrationDAO;
import com.example.hilingual.server.dummy.DummySessionDAO;
import com.example.hilingual.server.dummy.DummyUserDAO;
import com.google.inject.AbstractModule;
import com.google.inject.Scopes;
import io.dropwizard.setup.Environment;
import org.skife.jdbi.v2.DBI;
import redis.clients.jedis.JedisPool;

public class ServerModule extends AbstractModule {

    private Environment environment;
    private JedisPool jedisPool;
    private DBI dbi;
    private ServerConfig config;

    public ServerModule(Environment environment, ServerConfig config) {
        this.environment = environment;
        this.config = config;
    }

    @Override
    protected void configure() {
        //  Environment/providers
        bind(ServerConfig.class).
                toInstance(config);
        bind(Environment.class).
                toInstance(environment);
        bind(JedisPool.class).
                toInstance(jedisPool);
        bind(DBI.class).
                toInstance(dbi);

        //  DAOs
        bind(UserDAO.class).
                to(DummyUserDAO.class). //  TODO REPLACE DUMMY
                in(Scopes.SINGLETON);
        bind(SessionDAO.class).
                to(DummySessionDAO.class).  //  TODO REPLACE DUMMY
                in(Scopes.SINGLETON);
        bind(FacebookIntegrationDAO.class).
                to(FacebookIntegrationDAOImpl.class).
                in(Scopes.SINGLETON);
        bind(GoogleIntegrationDAO.class).
                to(DummyFacebookGoogleIntegrationDAO.class).  //  TODO REPLACE DUMMY
                in(Scopes.SINGLETON);
    }


    public void setDBI(DBI dbi) {
        this.dbi = dbi;
    }

    public void setJedisPool(JedisPool jedisPool) {
        this.jedisPool = jedisPool;
    }
}
