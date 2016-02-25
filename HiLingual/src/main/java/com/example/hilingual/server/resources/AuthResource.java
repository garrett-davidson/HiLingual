/*
 * AuthResource.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on 2/18/2016
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.resources;

import com.example.hilingual.server.api.AuthenticationRequest;
import com.example.hilingual.server.api.AuthenticationResponse;
import com.example.hilingual.server.api.User;
import com.example.hilingual.server.dao.FacebookIntegrationDAO;
import com.example.hilingual.server.dao.GoogleIntegrationDAO;
import com.example.hilingual.server.dao.SessionDAO;
import com.example.hilingual.server.dao.UserDAO;
import com.google.inject.Inject;

import javax.validation.Valid;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.function.BiConsumer;
import java.util.function.BiPredicate;
import java.util.function.ToLongFunction;

/**
 * Provides the endpoints for logging in/out of the service.
 * <br/>
 * <b>Endpoint base path:</b> /auth
 * <br/>
 * <b>Endpoints:</b>
 */
@Path("/auth")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class AuthResource {

    private final SessionDAO sessionDAO;
    private final UserDAO userDAO;
    private final FacebookIntegrationDAO facebookIntegrationDAO;
    private final GoogleIntegrationDAO googleIntegrationDAO;

    @Inject
    public AuthResource(SessionDAO sessionDAO,
                        UserDAO userDAO,
                        FacebookIntegrationDAO facebookIntegrationDAO,
                        GoogleIntegrationDAO googleIntegrationDAO) {
        this.sessionDAO = sessionDAO;
        this.userDAO = userDAO;
        this.facebookIntegrationDAO = facebookIntegrationDAO;
        this.googleIntegrationDAO = googleIntegrationDAO;
    }

    @POST
    @Path("login")
    public AuthenticationResponse logIn(@Valid AuthenticationRequest body) {
        String authorityAccountId = body.getAuthorityAccountId();
        String authorityToken = body.getAuthorityToken();
        BiPredicate<String, String> sessionCheck;
        ToLongFunction<String> getUserIdFromAuthorityAccountId;
        switch (body.getAuthority()) {
            case FACEBOOK:
                sessionCheck = facebookIntegrationDAO::isValidFacebookSession;
                getUserIdFromAuthorityAccountId = facebookIntegrationDAO::getUserIdFromFacebookAccountId;
                break;
            case GOOGLE:
                sessionCheck = googleIntegrationDAO::isValidGoogleSession;
                getUserIdFromAuthorityAccountId = googleIntegrationDAO::getUserIdFromGoogleAccountId;
                break;
            default:
                throw new BadRequestException();
        }
        if (!sessionCheck.test(authorityAccountId, authorityToken)) {
            throw new ClientErrorException(Response.Status.UNAUTHORIZED);
        }
        long userId = getUserIdFromAuthorityAccountId.applyAsLong(authorityAccountId);
        if (userId == 0) {
            throw new NotFoundException();
        }
        String sessionId = sessionDAO.newSession(userId);
        return new AuthenticationResponse(userId, sessionId);
    }


    @POST
    @Path("logout/{user-id}")
    public Response logOut(@HeaderParam("Authorization") String hlat,
                           @PathParam("user-id") long userId) {
        sessionDAO.revokeSession(SessionDAO.getSessionIdFromHLAT(hlat), userId);
        return Response.noContent().build();
    }

    @POST
    @Path("register")
    public AuthenticationResponse register(@Valid AuthenticationRequest body) {
        String authorityAccountId = body.getAuthorityAccountId();
        String authorityToken = body.getAuthorityToken();
        BiPredicate<String, String> sessionCheck;
        BiConsumer<Long, String> assignUserIdToAccount;
        switch (body.getAuthority()) {
            case FACEBOOK:
                sessionCheck = facebookIntegrationDAO::isValidFacebookSession;
                assignUserIdToAccount = facebookIntegrationDAO::setUserIdForFacebookAccountId;
                break;
            case GOOGLE:
                sessionCheck = googleIntegrationDAO::isValidGoogleSession;
                assignUserIdToAccount = googleIntegrationDAO::setUserIdForGoogleAccountId;
                break;
            default:
                throw new BadRequestException();
        }
        if (!sessionCheck.test(authorityAccountId, authorityToken)) {
            throw new ClientErrorException(Response.Status.UNAUTHORIZED);
        }
        User user = userDAO.createUser();
        long userId = user.getUuid();
        assignUserIdToAccount.accept(userId, authorityAccountId);
        String sessionId = sessionDAO.newSession(userId);
        return new AuthenticationResponse(userId, sessionId);
    }


}
