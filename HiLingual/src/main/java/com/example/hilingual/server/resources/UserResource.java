/*
 * UserResource.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on 2/18/2016
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.resources;

import com.example.hilingual.server.api.User;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.util.UUID;

/**
 * Provides the endpoints for retrieving and managing a user profile.
 * <br/>
 * <b>Endpoint base path:</b> /user/{user-id}
 * <br/>
 * <b>Endpoints:</b>
 *
 */
@Path("/user/{user-id}")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class UserResource {

    @GET
    public User getUser(@PathParam("user-id") String userIdStr) {
        UUID userId;
        try {
            userId = UUID.fromString(userIdStr);
        } catch (IllegalArgumentException e) {
            throw new NotFoundException(userIdStr);
        }

        //  TODO


        throw new NotFoundException(userIdStr);
    }


}
