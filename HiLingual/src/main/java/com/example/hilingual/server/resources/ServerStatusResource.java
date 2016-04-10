package com.example.hilingual.server.resources;

import com.example.hilingual.server.api.ServerStatus;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

@Path("/status")
@Produces(MediaType.APPLICATION_JSON)
public class ServerStatusResource {

    @GET
    public ServerStatus getStatus() {
        return new ServerStatus("ok");
    }

}
