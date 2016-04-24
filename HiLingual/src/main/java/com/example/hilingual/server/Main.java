/*
 * Main.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on 2/16/2016
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server;

import com.codahale.metrics.health.HealthCheckRegistry;
import com.example.hilingual.server.config.RedisConfig;
import com.example.hilingual.server.config.ServerConfig;
import com.example.hilingual.server.dao.*;
import com.example.hilingual.server.health.JedisHealthCheck;
import com.example.hilingual.server.resources.*;
import com.example.hilingual.server.service.APNsService;
import com.example.hilingual.server.service.LocalizationService;
import com.example.hilingual.server.service.MsftTranslateService;
import com.example.hilingual.server.service.SlackStatusInformationService;
import com.example.hilingual.server.task.ApnsTestTask;
import com.example.hilingual.server.task.RevokeAllSessionsTask;
import com.example.hilingual.server.task.TruncateTask;
import com.google.inject.Guice;
import com.google.inject.Injector;
import io.dropwizard.Application;
import io.dropwizard.forms.MultiPartBundle;
import io.dropwizard.jdbi.DBIFactory;
import io.dropwizard.jersey.setup.JerseyEnvironment;
import io.dropwizard.lifecycle.setup.LifecycleEnvironment;
import io.dropwizard.setup.AdminEnvironment;
import io.dropwizard.setup.Bootstrap;
import io.dropwizard.setup.Environment;
import org.skife.jdbi.v2.DBI;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

import java.util.logging.Logger;

/**
 * Application server entry point and initialization
 */
public class Main extends Application<ServerConfig> {

    private Injector guice;
    private ServerModule module;
    private JedisPool jedisPool;

    private static final Logger LOGGER = Logger.getLogger(Main.class.getName());

    /**
     * Main appliction entry point. Starts our server application
     * @param args Command line arguments
     * @throws Exception If starting the application fails
     * @see Application#run(String...)
     */
    public static void main(String[] args) throws Exception {
        new Main().run(args);
    }


    @Override
    public void initialize(Bootstrap<ServerConfig> bootstrap) {
        super.initialize(bootstrap);
        bootstrap.addBundle(new MultiPartBundle());
    }

    @Override
    public void run(ServerConfig serverConfig, Environment environment) throws Exception {
        LOGGER.info("Shinar starting");
        //  Redis initialization
        LOGGER.info("Initializing Redis connection pool");
        RedisConfig redisConfig = serverConfig.getRedisConfig();
        jedisPool = new JedisPool(new JedisPoolConfig(),
                redisConfig.getHost(),
                redisConfig.getPort(),
                redisConfig.getTimeout(),
                redisConfig.getPassword());
        //  DBI
        LOGGER.info("Initializing JDBI");
        DBIFactory factory = new DBIFactory();
        DBI jdbi = factory.build(environment,
                serverConfig.getDataSourceFactory(),
                serverConfig.getSqlDbType());
        //  Guice initialization
        LOGGER.info("Configuring injector");
        module = new ServerModule(environment, serverConfig);
        module.setDBI(jdbi);
        module.setJedisPool(jedisPool);
        guice = Guice.createInjector(module);

        //  Health checks
        LOGGER.info("Registering health checks");
        HealthCheckRegistry h = environment.healthChecks();
        h.register("jedis", create(JedisHealthCheck.class));

        //  Resources
        LOGGER.info("Registering resources");
        JerseyEnvironment j = environment.jersey();
        j.register(create(AuthResource.class));
        j.register(create(UserResource.class));
        j.register(create(AssetResource.class));
        j.register(create(ChatResource.class));
        j.register(create(ServerStatusResource.class));

        //  Managed
        LOGGER.info("Creating managed objects");
        LifecycleEnvironment l = environment.lifecycle();
        l.manage(create(FacebookIntegrationDAO.class));
        l.manage(create(GoogleIntegrationDAO.class));
        l.manage(create(SessionDAO.class));
        l.manage(create(UserDAO.class));
        l.manage(create(ChatMessageDAO.class));
        l.manage(create(APNsService.class));
        l.manage(create(MsftTranslateService.class));
        l.manage(create(SlackStatusInformationService.class));
        l.manage(create(LocalizationService.class));
        l.manage(create(CardDAO.class));

        //  Tasks
        LOGGER.info("Registering tasks");
        AdminEnvironment a = environment.admin();
        a.addTask(create(RevokeAllSessionsTask.class));
        a.addTask(create(TruncateTask.class));
        a.addTask(create(ApnsTestTask.class));
    }

    @Override
    public String getName() {
        return "HiLingual-Shinar";
    }

    private <T> T create(Class<T> clazz) {
        return guice.getInstance(clazz);
    }
}
