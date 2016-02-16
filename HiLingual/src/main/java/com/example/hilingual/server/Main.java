package com.example.hilingual.server;

import com.example.hilingual.server.config.ServerConfig;
import io.dropwizard.Application;
import io.dropwizard.setup.Bootstrap;
import io.dropwizard.setup.Environment;

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
        //  Nothing yet
    }

    @Override
    public void run(ServerConfig serverConfig, Environment environment) throws Exception {
        //  Nothing yet

    }

    @Override
    public String getName() {
        return "HiLingual-Shinar";
    }
}
