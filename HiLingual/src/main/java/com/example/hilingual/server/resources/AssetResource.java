package com.example.hilingual.server.resources;

import com.example.hilingual.server.api.*;
import com.example.hilingual.server.config.ServerConfig;
import com.example.hilingual.server.dao.SessionDAO;
import com.example.hilingual.server.service.IdentifierService;
import com.google.inject.Inject;
import org.glassfish.jersey.media.multipart.FormDataContentDisposition;
import org.glassfish.jersey.media.multipart.FormDataParam;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigInteger;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.Random;

import static java.nio.file.StandardOpenOption.CREATE;
import static java.nio.file.StandardOpenOption.TRUNCATE_EXISTING;

@Path("/asset")
public class AssetResource {

    private final ServerConfig config;
    private final Random random;
    private final SessionDAO sessionDAO;
    private final IdentifierService identifierService;

    @Inject
    public AssetResource(ServerConfig config, SessionDAO sessionDAO, IdentifierService identifierService) {
        this.config = config;
        this.sessionDAO = sessionDAO;
        this.identifierService = identifierService;

        random = new Random();
        //  Force secure seeding
        byte[] temp = new byte[128];
        random.nextBytes(temp);
    }

    @POST
    @Path("/avatar/{user-id}")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    public ImageData newImage(@HeaderParam("Authorization") String hlat,
                            @PathParam("receiver-id") long receiverId,
                            @FormDataParam("file") InputStream file,
                            @FormDataParam("file") FormDataContentDisposition fileDisposition) throws Exception {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long senderId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, senderId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        String assetId = Long.toUnsignedString(identifierService.generateId(IdentifierService.TYPE_IMAGE));
        java.nio.file.Path outPath = Paths.get(config.getAssetAccessPath(), "image", assetId);
        Files.createDirectories(outPath.getParent());
        try (BufferedOutputStream outputStream =
                     new BufferedOutputStream(Files.newOutputStream(outPath, CREATE, TRUNCATE_EXISTING))) {
            byte[] buf = new byte[8192];
            int len;
            while ((len = file.read(buf)) != -1) {
                outputStream.write(buf, 0, len);
            }
        }
        URI uri = getImageUrl(senderId, assetId);
        return new ImageData(uri.toASCIIString());
    }

    private URI getImageUrl(long userId, String assetId) throws URISyntaxException {
        return new URI(config.getAssetAccessBaseUrl() + "/image/" + assetId);
    }

    private URI getAudioUrl(long userId, String assetId) throws URISyntaxException {
        return new URI(config.getAssetAccessBaseUrl()).
                resolve("audio").
                resolve(Long.toString(userId)).
                resolve(assetId);
    }

    @POST
    @Path("audio/{user-id}")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response uploadAudio(@PathParam("user-id") long userId,
                                @HeaderParam("Authorization") String hlat,
                                AudioData data)
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
        Files.createDirectories(outPath.getParent());
        Files.write(outPath, data.toBytes(), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
        return Response.seeOther(getAudioUrl(userId, assetId)).build();
    }

}
