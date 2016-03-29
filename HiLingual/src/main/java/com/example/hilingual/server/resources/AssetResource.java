package com.example.hilingual.server.resources;

import com.example.hilingual.server.config.ServerConfig;
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

    @Inject
    public AssetResource(ServerConfig config) {
        this.config = config;

        random = new Random();
        //  Force secure seeding
        byte[] temp = new byte[128];
        random.nextBytes(temp);
    }

    @GET
    @Path("image/{asset-id}")
    public Response getImage(@PathParam("asset-id") String assetId) throws URISyntaxException {
        //  Redirect them to our "CDN"
        return Response.temporaryRedirect(new URI(config.getAssetAccessBaseUrl()).
                resolve("images").
                resolve(assetId)).build();
    }

    @POST
    @Path("image")
    @Consumes(MediaType.APPLICATION_OCTET_STREAM)
    public Response uploadImage(InputStream data) throws URISyntaxException, IOException {
        String assetId = new BigInteger(130, random).toString(32);
        java.nio.file.Path outPath = Paths.get(config.getAssetAccessPath(), "images", assetId);
        Files.copy(data, outPath, StandardCopyOption.REPLACE_EXISTING);
        return Response.seeOther(new URI(config.getAssetAccessBaseUrl()).
                resolve("images").
                resolve(assetId)).build();
    }

    @GET
    @Path("audio/{asset-id}")
    public Response getAudio(@PathParam("asset-id") String assetId) throws URISyntaxException {
        //  Redirect them to our "CDN"
        return Response.temporaryRedirect(new URI(config.getAssetAccessBaseUrl()).
                resolve("audio").
                resolve(assetId)).build();
    }

    @POST
    @Path("audio")
    @Consumes(MediaType.APPLICATION_OCTET_STREAM)
    public Response uploadAudio(InputStream data) throws URISyntaxException, IOException {
        String assetId = new BigInteger(130, random).toString(32);
        java.nio.file.Path outPath = Paths.get(config.getAssetAccessPath(), "audio", assetId);
        Files.copy(data, outPath, StandardCopyOption.REPLACE_EXISTING);
        return Response.seeOther(new URI(config.getAssetAccessBaseUrl()).
                resolve("audio").
                resolve(assetId)).build();
    }

}
