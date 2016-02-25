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
import io.dropwizard.jersey.PATCH;

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
@Path("/user")
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
    @Path("{user-id}")
    public User getUser(@PathParam("user-id") long userId, @HeaderParam("Authorization") String hlat) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        //  Find the user
        User user = userDAO.getUser(userId);
        if (user != null) {
            //  Skip scrubbing if its ourselves
            if (user.getUuid() != authUserId) {
                //  TODO Determine how much info needs to be scrubbed and scrub it
            }
            return user;
        }
        throw new NotFoundException();
    }

    @PATCH
    @Path("{user-id}")
    public User updateUser(@PathParam("user-id") long userId, User user, @HeaderParam("Authorization") String hlat) {
        //  Request body user ID must match the ID of the user we wish to update
        if (userId != user.getUuid()) {
            throw new ForbiddenException();
        }
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        //  Prevent users from editing other users
        if (userId != authUserId) {
            throw new ForbiddenException();
        }
        User storedUser = userDAO.getUser(userId);
        //  If we are first time registering, we allow setting stuff like name, username, DoB, gender
        if (!storedUser.isProfileSet()) {
            try {
                //  TODO Verify that these are valid

                storedUser.setName(user.getName());
                storedUser.setGender(user.getGender());
                storedUser.setDisplayName(user.getDisplayName());
                storedUser.setBirthdate(user.getBirthdate());
                //  Lock the fields
                storedUser.setProfileSet(true);
            } catch (NullPointerException npe) {
                //  Missing fields
                throw new BadRequestException("Initial registration fields must be set");
            }
        }
        //  Update non-null editable fields
        if (user.getBio() != null) {
            storedUser.setBio(user.getBio());
        }
        if (user.getBlockedUsers() != null) {
            storedUser.getBlockedUsers().clear();
            storedUser.getBlockedUsers().addAll(user.getBlockedUsers());
        }
        if (user.getKnownLanguages() != null) {
            storedUser.getKnownLanguages().clear();
            storedUser.getKnownLanguages().addAll(user.getKnownLanguages());
        }
        if (user.getImageURL() != null) {
            storedUser.setImageURL(user.getImageURL());
        }
        if (user.getName() != null) {
            storedUser.setName(user.getName());
        }
        userDAO.updateUser(storedUser);
        return storedUser;
    }


    @GET
    @Path("search")
    public User[] searchUsers(@QueryParam("query") String query, @HeaderParam("Authorization") String hlat) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        User invoker = userDAO.getUser(authUserId);
        //  TODO Validate/sanitize query
        return userDAO.findUsers(query, invoker);
    }
}
