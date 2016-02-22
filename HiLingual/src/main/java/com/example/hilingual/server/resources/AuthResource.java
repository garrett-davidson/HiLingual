/*
 * AuthResource.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on 2/18/2016
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.resources;

import com.example.hilingual.server.api.AuthenticatedUser;
import com.example.hilingual.server.api.AuthenticationRequest;

import javax.validation.Valid;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

/**
 * Provides the endpoints for logging in/out of the service.
 * <br/>
 * <b>Endpoint base path:</b> /auth
 * <br/>
 * <b>Endpoints:</b>
 *
 */
@Path("/auth")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class AuthResource {

    @POST
    @Path("login")
    public AuthenticatedUser logIn(@Valid AuthenticationRequest body) {

        throw new ServerErrorException(Response.Status.NOT_IMPLEMENTED);
    }


    @POST
    @Path("user/{user-id}/logout")
    public Response logOut(@HeaderParam("Authorization") String sessionToken,
                           @PathParam("user-id") long userId) {

        return Response.noContent().build();
    }


}
