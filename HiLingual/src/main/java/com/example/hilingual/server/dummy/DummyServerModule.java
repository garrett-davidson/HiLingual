/*
 * DummyServerModule.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dummy;

import com.example.hilingual.server.ServerModule;
import com.example.hilingual.server.config.ServerConfig;
import com.example.hilingual.server.dao.FacebookIntegrationDAO;
import com.example.hilingual.server.dao.GoogleIntegrationDAO;
import com.example.hilingual.server.dao.SessionDAO;
import com.example.hilingual.server.dao.UserDAO;
import com.example.hilingual.server.dao.impl.SessionDAOImpl;
import com.example.hilingual.server.service.FacebookGraphAPIService;
import com.example.hilingual.server.service.GoogleAccountAPIService;
import com.google.inject.Scopes;
import io.dropwizard.setup.Environment;
import org.skife.jdbi.v2.DBI;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

public class DummyServerModule extends ServerModule {

    public DummyServerModule(Environment environment, ServerConfig config) {
        super(environment, config);
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
        bind(Jedis.class).
                toProvider(jedisPool::getResource);
        bind(DBI.class).
                toInstance(dbi);

        //  DAOs
        bind(UserDAO.class).
                to(DummyUserDAO.class).
                in(Scopes.SINGLETON);
        bind(SessionDAO.class).
                to(SessionDAOImpl.class).
                in(Scopes.SINGLETON);
        bind(FacebookIntegrationDAO.class).
                to(DummyFacebookGoogleIntegrationDAO.class).
                in(Scopes.SINGLETON);
        bind(GoogleIntegrationDAO.class).
                to(DummyFacebookGoogleIntegrationDAO.class).
                in(Scopes.SINGLETON);

        //  Services
        bind(FacebookGraphAPIService.class).
                to(DummyFacebookGraphAPIService.class).
                in(Scopes.SINGLETON);
        bind(GoogleAccountAPIService.class).
                to(DummyGoogleAccountAPIService.class).
                in(Scopes.SINGLETON);
    }

}
