#HiLingual API Server (Shinar)

This is the backend application server that drives HiLingual, using DropWizard.

The project is managed via [Maven](https://maven.apache.org/), consult your IDE 
docs to learn how to use your IDE's Maven integration. Alternatively, use `mvn`
from the command line.

Required environment (necessary to run):

 - JRE v1.8.0_72 or newer (x64 version preferred)

Additional software (necessary to do work):

 - Redis v3.0.7
 - MySQL Community Server v5.7.11
 - nginx/Apache for HTTPS termination (for production only)

A default configuration is provided in [default-config.yml](default-config.yml), 
copy it into the application's running directory and edit it to fit your local 
environment.

##Running the Server
You may either run it directly from the `target/` directory (be warned that 
this directory is deleted if `mvn clean` is run) or copy it into its own 
directory elsewhere. Place your configuration file in the same directory. 
Run `java -jar Shinar-1.0-SNAPSHOT.jar server <configuration_file>`. You 
should be able to access the server at `localhost:8080` and the admin panel 
at `localhost:8081`, unless otherwise changed in your configuration.
Hit CTRL-C to stop the server.
