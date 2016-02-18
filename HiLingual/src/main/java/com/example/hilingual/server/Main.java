/*
 * Main.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on 2/16/2016
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server;

import com.bendb.dropwizard.redis.JedisBundle;
import com.bendb.dropwizard.redis.JedisFactory;
import com.example.hilingual.server.config.ServerConfig;
import com.hubspot.dropwizard.guice.GuiceBundle;
import io.dropwizard.Application;
import io.dropwizard.jdbi.DBIFactory;
import io.dropwizard.setup.Bootstrap;
import io.dropwizard.setup.Environment;
import org.skife.jdbi.v2.DBI;

/**
 * Application server entry point and initialization
 */
public class Main extends Application<ServerConfig> {

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
        //  Guice initialization
        GuiceBundle<ServerConfig> guiceBundle = GuiceBundle.<ServerConfig>newBuilder().
                setConfigClass(ServerConfig.class).
                enableAutoConfig(getClass().getPackage().getName()).
                build();
        bootstrap.addBundle(guiceBundle);

        //  Register Jedis bundle
        bootstrap.addBundle(new JedisBundle<ServerConfig>() {
            @Override
            public JedisFactory getJedisFactory(ServerConfig serverConfig) {
                return serverConfig.getRedisFactory();
            }
        });

    }

    @Override
    public void run(ServerConfig serverConfig, Environment environment) throws Exception {
        DBIFactory factory = new DBIFactory();
        DBI jdbi = factory.build(environment,
                serverConfig.getDataSourceFactory(),
                serverConfig.getSqlDbType());
        //  TODO

    }

    @Override
    public String getName() {
        return "HiLingual-Shinar";
    }
}
