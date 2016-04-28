/*
 * UserResource.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on 2/18/2016
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.resources;

import com.example.hilingual.server.api.LocaleSetting;
import com.example.hilingual.server.api.Report;
import com.example.hilingual.server.api.User;
import com.example.hilingual.server.api.flash.CardRing;
import com.example.hilingual.server.dao.CardDAO;
import com.example.hilingual.server.dao.SessionDAO;
import com.example.hilingual.server.dao.UserDAO;
import com.example.hilingual.server.service.LocalizationService;
import com.example.hilingual.server.service.SlackStatusInformationService;
import com.google.inject.Inject;
import io.dropwizard.jersey.PATCH;

import javax.validation.Valid;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;

/**
 * Provides the endpoints for retrieving and managing a user profile.
 * <br/>
 * <b>Endpoint base path:</b> /user/{user-id}
 * <br/>
 * <b>Endpoints:</b>
 */
@Path("/user")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class UserResource {

    private final SessionDAO sessionDAO;
    private final UserDAO userDAO;
    private final CardDAO cardDAO;
    private final LocalizationService localizationService;
    private final SlackStatusInformationService slackStatusInformationService;


    @Inject
    public UserResource(SessionDAO sessionDAO,
                        UserDAO userDAO,
                        CardDAO cardDAO,
                        LocalizationService localizationService,
                        SlackStatusInformationService slackStatusInformationService) {
        this.sessionDAO = sessionDAO;
        this.userDAO = userDAO;
        this.cardDAO = cardDAO;
        this.localizationService = localizationService;
        this.slackStatusInformationService = slackStatusInformationService;
    }

    @GET
    @Path("me")
    public User getSelf(@HeaderParam("Authorization") String hlat) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        User user = userDAO.getUser(authUserId);
        if (user != null) {
            return user;
        }
        throw new NotFoundException();
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
            //  If the user has blocked the requester, deny
            if (user.isUserBlocked(authUserId)) {
                throw new ForbiddenException("Blocked");
            }
            //  Skip scrubbing if its ourselves
            if (user.getUserId() != authUserId) {
                //  TODO Determine how much info needs to be scrubbed and scrub it
            }
            return user;
        }
        throw new NotFoundException();
    }

    @GET
    @Path("me/cards")
    public CardRing[] getCards(@HeaderParam("Authorization") String hlat) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        return cardDAO.getCards(authUserId);
    }

    @PUT
    @Path("me/cards")
    public CardRing[] putCards(@HeaderParam("Authorization") String hlat,
                               CardRing[] rings) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        cardDAO.setCards(rings, authUserId);
        return cardDAO.getCards(authUserId);
    }

    @PATCH
    @Path("{user-id}")
    public User updateUser(@PathParam("user-id") long userId, @Valid User user,
                           @HeaderParam("Authorization") String hlat) {
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
                storedUser.setBirthdate(user.getBirthdate());
                //  Lock the fields
                storedUser.setProfileSet(true);
            } catch (NullPointerException npe) {
                //  Missing fields
                throw new BadRequestException("Initial registration fields must be set");
            }
        }
        //  Update non-null editable fields
        if (user.getDisplayName() != null) {
            //  Check if unique
            if (userDAO.isNameUnique(user.getDisplayName())) {
                storedUser.setDisplayName(user.getDisplayName());
            }
        }
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
        if (user.getLearningLanguages() != null) {
            storedUser.getLearningLanguages().clear();
            storedUser.getLearningLanguages().addAll(user.getLearningLanguages());
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
    @Path("names")
    @Produces(MediaType.TEXT_PLAIN)
    public String checkDisplayNameAvailability(@QueryParam("name") String name,
                                               @HeaderParam("Authorization") String hlat) {
        return Boolean.toString(userDAO.isNameUnique(name));
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

    @GET
    @Path("match")
    public User[] getMatches(@HeaderParam("Authorization") String hlat) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        User invoker = userDAO.getUser(authUserId);
        if (invoker == null) {
            throw new InternalServerErrorException("Cannot find session");
        }
        return userDAO.findMatches(invoker);
    }

    @GET
    @Path("me/locale")
    public LocaleSetting getLocale(@HeaderParam("Authorization") String hlat) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        return new LocaleSetting(localizationService.getUserLocale(authUserId));
    }

    @POST
    @Path("me/locale")
    public void setLocale(@HeaderParam("Authorization") String hlat, LocaleSetting body) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        localizationService.setUserLocale(authUserId, body.getAsLocale());
    }

    @POST
    @Path("{user-id}/block")
    public User blockUser(@PathParam("user-id") long userId, @HeaderParam("Authorization") String hlat) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        User user = userDAO.getUser(authUserId);
        User blocked = userDAO.getUser(userId);
        if (blocked == null) {
            throw new NotFoundException("Cannot find user " + userId);
        }
        user.addBlockedUser(blocked);
        userDAO.updateUser(user);
        return user;
    }

    @DELETE
    @Path("{user-id}/block")
    public User unblockUser(@PathParam("user-id") long userId, @HeaderParam("Authorization") String hlat) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        User user = userDAO.getUser(authUserId);
        User blocked = userDAO.getUser(userId);
        if (blocked == null) {
            throw new NotFoundException("Cannot find user " + userId);
        }
        user.removeBlockedUser(blocked);
        userDAO.updateUser(user);
        return user;
    }

    @POST
    @Path("{user-id}/block")
    public void reportUser(@PathParam("user-id") long userId, @HeaderParam("Authorization") String hlat, @Valid Report report) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        User user = userDAO.getUser(authUserId);
        User reported = userDAO.getUser(userId);
        if (reported == null) {
            throw new NotFoundException("Cannot find user " + userId);
        }
        report.setReportedUserId(reported.getUserId());
        report.setReportedByUserId(user.getUserId());
        //  Send to slack!
        slackStatusInformationService.sendMessage("Reported: " + report.toString());
    }
}
