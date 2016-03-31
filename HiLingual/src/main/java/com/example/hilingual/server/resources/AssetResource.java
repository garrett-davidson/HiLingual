package com.example.hilingual.server.resources;

import com.example.hilingual.server.config.ServerConfig;
import com.example.hilingual.server.dao.SessionDAO;
import com.google.inject.Inject;

import javax.ws.rs.*;
import javax.ws.rs.Path;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigInteger;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.file.*;
import java.util.Random;

@Path("/asset")
public class AssetResource {

    private final ServerConfig config;
    private final Random random;
    private final SessionDAO sessionDAO;

    @Inject
    public AssetResource(ServerConfig config, SessionDAO sessionDAO) {
        this.config = config;
        this.sessionDAO = sessionDAO;

        random = new Random();
        //  Force secure seeding
        byte[] temp = new byte[128];
        random.nextBytes(temp);
    }

    @GET
    @Path("avatar/{user-id}/{asset-id}")
    public Response getImage(@PathParam("user-id") long userId, @PathParam("asset-id") String assetId)
            throws URISyntaxException {
        //  Redirect them to our "CDN"
        return Response.temporaryRedirect(getImageUrl(userId, assetId)).build();
    }

    @POST
    @Path("avatar/{user-id}")
    @Consumes(MediaType.APPLICATION_OCTET_STREAM)
    public Response uploadImage(@PathParam("user-id") long userId,
                                @HeaderParam("Authorization") String hlat,
                                InputStream data)
            throws URISyntaxException, IOException {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        if (userId != authUserId) {
            throw new ForbiddenException("You are not allowed to upload an avatar to another user's account");
        }
        String assetId = new BigInteger(130, random).toString(32);
        java.nio.file.Path outPath = Paths.get(config.getAssetAccessPath(),
                "images", Long.toString(userId), assetId + ".png");
        Files.copy(data, outPath, StandardCopyOption.REPLACE_EXISTING);
        return Response.seeOther(getImageUrl(userId, assetId)).build();
    }

    private URI getImageUrl(long userId, String assetId) throws URISyntaxException {
        return new URI(config.getAssetAccessBaseUrl()).
                resolve("images").
                resolve(Long.toString(userId)).
                resolve(assetId + ".png");
    }

    @GET
    @Path("audio/{user-id}/{asset-id}")
    public Response getAudio(@PathParam("user-id") long userId, @PathParam("asset-id") String assetId)
            throws URISyntaxException {
        //  Redirect them to our "CDN"
        return Response.temporaryRedirect(getAudioUrl(userId, assetId)).build();
    }

    private URI getAudioUrl(long userId, String assetId) throws URISyntaxException {
        return new URI(config.getAssetAccessBaseUrl()).
                resolve("audio").
                resolve(Long.toString(userId)).
                resolve(assetId);
    }

    @POST
    @Path("audio/{user-id}")
    @Consumes(MediaType.APPLICATION_OCTET_STREAM)
    public Response uploadAudio(@PathParam("user-id") long userId,
                                @HeaderParam("Authorization") String hlat,
                                InputStream data)
            throws URISyntaxException, IOException {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        if (userId != authUserId) {
            throw new ForbiddenException("You are not allowed to upload an audio clip to another user's account");
        }
        String assetId = new BigInteger(130, random).toString(32);
        java.nio.file.Path outPath = Paths.get(config.getAssetAccessPath(), "audio", assetId);
        Files.copy(data, outPath, StandardCopyOption.REPLACE_EXISTING);
        return Response.seeOther(getAudioUrl(userId, assetId)).build();
    }

}
