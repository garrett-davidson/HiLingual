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
import com.example.hilingual.server.dao.*;
import com.example.hilingual.server.dao.impl.*;
import com.example.hilingual.server.service.*;
import com.example.hilingual.server.service.impl.*;
import com.example.hilingual.server.service.impl.msfttranslate.MsftTranslateServiceImpl;
import com.google.inject.AbstractModule;
import com.google.inject.Scopes;
import io.dropwizard.setup.Environment;
import org.skife.jdbi.v2.DBI;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

public class ServerModule extends AbstractModule {

    protected Environment environment;
    protected JedisPool jedisPool;
    protected DBI dbi;
    protected ServerConfig config;

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
        bind(Jedis.class).
                toProvider(jedisPool::getResource);
        bind(DBI.class).
                toInstance(dbi);

        //  DAOs
        bind(UserDAO.class).
                to(UserDAOImpl.class).
                in(Scopes.SINGLETON);
        bind(SessionDAO.class).
                to(SessionDAOImpl.class).
                in(Scopes.SINGLETON);
        bind(FacebookIntegrationDAO.class).
                to(FacebookIntegrationDAOImpl.class).
                in(Scopes.SINGLETON);
        bind(GoogleIntegrationDAO.class).
                to(GoogleIntegrationDAOImpl.class).
                in(Scopes.SINGLETON);
        bind(DeviceTokenDAO.class).
                to(DeviceTokenDAOImpl.class).
                in(Scopes.SINGLETON);
        bind(ChatMessageDAO.class).
                to(ChatMessageDAOImpl.class).
                in(Scopes.SINGLETON);
        bind(TranslationCacheDAO.class).
                to(TranslationCacheDAOImpl.class).
                in(Scopes.SINGLETON);

        //  Services
        bind(FacebookGraphAPIService.class).
                to(FacebookGraphAPIServiceImpl.class).
                in(Scopes.SINGLETON);
        bind(GoogleAccountAPIService.class).
                to(GoogleAccountAPIServiceImpl.class).
                in(Scopes.SINGLETON);
        bind(APNsService.class).
                to(APNsServiceImpl.class).
                in(Scopes.SINGLETON);
        bind(MsftTranslateService.class).
                to(MsftTranslateServiceImpl.class).
                in(Scopes.SINGLETON);
        bind(SlackStatusInformationService.class).
                to(SlackStatusInformationServiceImpl.class).
                in(Scopes.SINGLETON);
        bind(IdentifierService.class).
                to(IdentifierServiceImpl.class).
                in(Scopes.SINGLETON);
        bind(LocalizationService.class).
                to(LocalizationServiceImpl.class).
                in(Scopes.SINGLETON);
    }


    public void setDBI(DBI dbi) {
        this.dbi = dbi;
    }

    public void setJedisPool(JedisPool jedisPool) {
        this.jedisPool = jedisPool;
    }
}
