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
import com.example.hilingual.server.dao.SessionDAO;
import com.example.hilingual.server.dao.UserDAO;
import com.google.inject.Inject;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;

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

    private final SessionDAO sessionDAO;
    private final UserDAO userDAO;


    @Inject
    public UserResource(SessionDAO sessionDAO, UserDAO userDAO) {
        this.sessionDAO = sessionDAO;
        this.userDAO = userDAO;
    }

    @GET
    public User getUser(@PathParam("user-id") long userId) {
        //  TODO check auth header

        //  Find the user
        User user = userDAO.getUser(userId);
        if (user != null) {
            return user;
        }
        throw new NotFoundException();
    }


}
