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
import com.example.hilingual.server.dao.FacebookIntegrationDAO;
import com.example.hilingual.server.dao.GoogleIntegrationDAO;
import com.example.hilingual.server.dao.SessionDAO;
import com.google.inject.Inject;

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
 */
@Path("/auth")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class AuthResource {

    private final SessionDAO sessionDAO;
    private final FacebookIntegrationDAO facebookIntegrationDAO;
    private final GoogleIntegrationDAO googleIntegrationDAO;

    @Inject
    public AuthResource(SessionDAO sessionDAO,
                        FacebookIntegrationDAO facebookIntegrationDAO,
                        GoogleIntegrationDAO googleIntegrationDAO) {
        this.sessionDAO = sessionDAO;
        this.facebookIntegrationDAO = facebookIntegrationDAO;
        this.googleIntegrationDAO = googleIntegrationDAO;
    }

    @POST
    @Path("login")
    public AuthenticationResponse logIn(@Valid AuthenticationRequest body) {
        boolean ok;
        long userId = 0;
        String authorityAccountId = body.getAuthorityAccountId();
        String authorityToken = body.getAuthorityToken();
        switch (body.getAuthority()) {
            case FACEBOOK:
                ok = facebookIntegrationDAO.
                        isValidFacebookSession(authorityAccountId, authorityToken);
                if (ok) {
                    userId = facebookIntegrationDAO.getUserIdFromFacebookAccountId(authorityAccountId);
                }
                break;
            case GOOGLE:
                ok = googleIntegrationDAO.
                        isValidGoogleSession(authorityAccountId, authorityToken);
                if (ok) {
                    userId = googleIntegrationDAO.getUserIdFromGoogleAccountId(authorityAccountId);
                }
                break;
            default:
                throw new BadRequestException();
        }
        if (!ok) {
            throw new ClientErrorException(Response.Status.UNAUTHORIZED);
        }
        String sessionId = sessionDAO.newSession(userId);
        return new AuthenticationResponse(userId, sessionId);
    }


    @POST
    @Path("logout/{user-id}")
    public Response logOut(@HeaderParam("Authorization") String sessionToken,
                           @PathParam("user-id") long userId) {
        sessionDAO.revokeSession(sessionToken, userId);
        return Response.noContent().build();
    }


}
