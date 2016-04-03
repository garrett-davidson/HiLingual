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
import com.example.hilingual.server.dao.*;
import com.example.hilingual.server.service.FacebookGraphAPIService;
import com.example.hilingual.server.service.GoogleAccountAPIService;
import com.google.common.base.Strings;
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
    private final FacebookGraphAPIService fbApiService;
    private final GoogleAccountAPIService googleApiService;
    private final DeviceTokenDAO tokenDAO;

    @Inject
    public AuthResource(SessionDAO sessionDAO,
                        UserDAO userDAO,
                        FacebookIntegrationDAO facebookIntegrationDAO,
                        GoogleIntegrationDAO googleIntegrationDAO,
                        FacebookGraphAPIService fbApiService,
                        GoogleAccountAPIService googleApiService,
                        DeviceTokenDAO tokenDAO) {
        this.sessionDAO = sessionDAO;
        this.userDAO = userDAO;
        this.facebookIntegrationDAO = facebookIntegrationDAO;
        this.googleIntegrationDAO = googleIntegrationDAO;
        this.fbApiService = fbApiService;
        this.googleApiService = googleApiService;
        this.tokenDAO = tokenDAO;
    }

    @POST
    @Path("login")
    public AuthenticationResponse logIn(@Valid AuthenticationRequest body) {
        String authorityAccountId = body.getAuthorityAccountId();
        String authorityToken = body.getAuthorityToken();
        BiPredicate<String, String> sessionCheck;
        ToLongFunction<String> getUserIdFromAuthorityAccountId;
        BiConsumer<Long, String> tokenSetter;
        switch (body.getAuthority()) {
            case FACEBOOK:
                sessionCheck = fbApiService::isValidFacebookSession;
                getUserIdFromAuthorityAccountId = facebookIntegrationDAO::getUserIdFromFacebookAccountId;
                tokenSetter = facebookIntegrationDAO::setFacebookToken;
                break;
            case GOOGLE:
                sessionCheck = googleApiService::isValidGoogleSession;
                getUserIdFromAuthorityAccountId = googleIntegrationDAO::getUserIdFromGoogleAccountId;
                tokenSetter = googleIntegrationDAO::setGoogleToken;
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
        tokenSetter.accept(userId, authorityToken);
        if (!Strings.isNullOrEmpty(body.getDeviceToken())) {
            tokenDAO.addDeviceToken(userId, body.getDeviceToken());
        }
        String sessionId = sessionDAO.newSession(userId);
        return new AuthenticationResponse(userId, sessionId);
    }


    @POST
    @Path("{user-id}/logout")
    public Response logOut(@HeaderParam("Authorization") String hlat,
                           @PathParam("user-id") long userId,
                           @QueryParam("device-token") @DefaultValue("") String deviceToken) {
        sessionDAO.revokeSession(SessionDAO.getSessionIdFromHLAT(hlat), userId);
        if (!Strings.isNullOrEmpty(deviceToken)) {
            tokenDAO.revokeUserDeviceToken(userId, deviceToken);
        }
        return Response.noContent().build();
    }

    @POST
    @Path("register")
    public AuthenticationResponse register(@Valid AuthenticationRequest body) {
        String authorityAccountId = body.getAuthorityAccountId();
        String authorityToken = body.getAuthorityToken();
        BiPredicate<String, String> sessionCheck;
        BiConsumer<Long, String> assignUserIdToAccount;
        ToLongFunction<String> getUserIdFromAuthorityAccountId;
        BiConsumer<Long, String> tokenSetter;
        switch (body.getAuthority()) {
            case FACEBOOK:
                sessionCheck = fbApiService::isValidFacebookSession;
                getUserIdFromAuthorityAccountId = facebookIntegrationDAO::getUserIdFromFacebookAccountId;
                assignUserIdToAccount = facebookIntegrationDAO::setUserIdForFacebookAccountId;
                tokenSetter = facebookIntegrationDAO::setFacebookToken;
                break;
            case GOOGLE:
                sessionCheck = googleApiService::isValidGoogleSession;
                getUserIdFromAuthorityAccountId = googleIntegrationDAO::getUserIdFromGoogleAccountId;
                assignUserIdToAccount = googleIntegrationDAO::setUserIdForGoogleAccountId;
                tokenSetter = googleIntegrationDAO::setGoogleToken;
                break;
            default:
                throw new BadRequestException();
        }
        if (!sessionCheck.test(authorityAccountId, authorityToken)) {
            throw new ClientErrorException(Response.Status.UNAUTHORIZED);
        }
        if (getUserIdFromAuthorityAccountId.applyAsLong(authorityAccountId) != 0) {
            throw new ForbiddenException("Account is already associated with a Hilingual account");
        }
        User user = userDAO.createUser();
        long userId = user.getUserId();
        assignUserIdToAccount.accept(userId, authorityAccountId);
        tokenSetter.accept(userId, authorityToken);
        String sessionId = sessionDAO.newSession(userId);
        return new AuthenticationResponse(userId, sessionId);
    }


}
