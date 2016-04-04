package com.example.hilingual.server.resources;

import com.example.hilingual.server.api.Message;
import com.example.hilingual.server.api.User;
import com.example.hilingual.server.api.UserChats;
import com.example.hilingual.server.config.ServerConfig;
import com.example.hilingual.server.dao.ChatMessageDAO;
import com.example.hilingual.server.dao.DeviceTokenDAO;
import com.example.hilingual.server.dao.SessionDAO;
import com.example.hilingual.server.dao.UserDAO;
import com.example.hilingual.server.service.APNsService;
import com.google.inject.Inject;
import com.relayrides.pushy.apns.util.ApnsPayloadBuilder;
import io.dropwizard.jersey.PATCH;

import javax.validation.Valid;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.io.IOException;
import java.math.BigInteger;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Random;
import java.util.Set;

import static java.nio.file.StandardOpenOption.CREATE;
import static java.nio.file.StandardOpenOption.TRUNCATE_EXISTING;

@Path("/chat")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ChatResource {


    private final SessionDAO sessionDAO;
    private final UserDAO userDAO;
    private final ChatMessageDAO chatMessageDAO;
    private final APNsService apnsService;
    private final DeviceTokenDAO deviceTokenDAO;
    private final ServerConfig config;
    private final Random random;

    @Inject
    public ChatResource(SessionDAO sessionDAO, UserDAO userDAO, ChatMessageDAO chatMessageDAO,
                        APNsService apnsService, DeviceTokenDAO deviceTokenDAO, ServerConfig config) {
        this.sessionDAO = sessionDAO;
        this.userDAO = userDAO;
        this.chatMessageDAO = chatMessageDAO;
        this.apnsService = apnsService;
        this.deviceTokenDAO = deviceTokenDAO;
        this.config = config;


        random = new Random();
        //  Force secure seeding
        byte[] temp = new byte[128];
        random.nextBytes(temp);
    }

    //  TODO

    @GET
    @Path("/me")
    public UserChats getChats(@HeaderParam("Authorization") String hlat) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        User user = userDAO.getUser(authUserId);
        if (user == null) {
            throw new NotFoundException("This session is not associated with any user account");
        }

        Set<Long> chats = user.getUsersChattedWith();
        Set<Long> pending = chatMessageDAO.getRequests(user.getUserId());
        return new UserChats(user.getUserId(), chats, pending);
    }

    @POST
    @Path("/{receiver-id}")
    public void request(@HeaderParam("Authorization") String hlat, @PathParam("receiver-id") long receiverId) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long requesterId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, requesterId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        User requester = userDAO.getUser(requesterId);
        User receiver = userDAO.getUser(receiverId);
        if (receiver == null) {
            throw new NotFoundException("No such receiverId");
        }
        //  Ignore requests that already exist
        Set<Long> req = chatMessageDAO.getRequests(receiverId);
        for (long l : req) {
            if (l == requesterId) {
                return;
            }
        }
        //  Ignore requests with users that you already have a conversation with
        if (receiver.getUsersChattedWith().contains(requesterId)) {
            return;
        }
        chatMessageDAO.addRequest(requesterId, receiverId);
        sendNotification(receiverId, String.format("<LOCALIZE ME> %s wants to start a conversation with you!",
                requester.getDisplayName()));
    }

    @POST
    @Path("/{requester-id}/accept")
    public void accept(@HeaderParam("Authorization") String hlat, @PathParam("requester-id") long requesterId) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long accepterId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, accepterId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        User accepter = userDAO.getUser(accepterId);
        User requester = userDAO.getUser(requesterId);
        if (requester == null) {
            throw new NotFoundException("No such requester");
        }
        //  Ignore requests that already exist
        if (requester.getUsersChattedWith().contains(accepterId)) {
            return;
        }
        //  Check that they were requested
        Set<Long> requests = chatMessageDAO.getRequests(requesterId);
        boolean found = false;
        for (long request : requests) {
            if (request == accepterId) {
                found = true;
                break;
            }
        }
        if (!found) {
            throw new NotFoundException("Request " + requesterId + " not found");
        }
        accepter.getUsersChattedWith().add(requesterId);
        requester.getUsersChattedWith().add(accepterId);
        chatMessageDAO.acceptRequest(accepterId, requesterId);
        userDAO.updateUser(accepter);
        userDAO.updateUser(requester);
        sendNotification(requesterId, String.format("<LOCALIZE ME>%s has accepted your conversation request.",
                accepter.getDisplayName()));
    }


    @POST
    @Path("/{receiver-id}/message")
    public Message newMessage(@HeaderParam("Authorization") String hlat, @PathParam("receiver-id") long receiverId,
                              @Valid Message message) throws IOException, URISyntaxException {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long senderId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, senderId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        User sender = userDAO.getUser(senderId);
        User reciever = userDAO.getUser(receiverId);
        if (reciever == null) {
            throw new NotFoundException("No such receiver");
        }
        if (!sender.getUsersChattedWith().contains(receiverId)) {
            throw new ForbiddenException("This user is not a conversation partner");
        }
        if (message.getAudio() != null) {
            String assetId = new BigInteger(130, random).toString(32);
            java.nio.file.Path outPath = Paths.get(config.getAssetAccessPath(), "audio", assetId);
            Files.createDirectories(outPath.getParent());
            Files.write(outPath, message.audioDataToBytes(), CREATE, TRUNCATE_EXISTING);
            URI uri = getAudioUrl(senderId, assetId);
            //  New messages only have content field set
            Message ret = chatMessageDAO.newMessage(senderId, receiverId, uri.toASCIIString());
            sendNotification(receiverId, String.format("<LOCALIZE ME><TODO SHOW CONTENT>%s sent you a voice clip.",
                    sender.getDisplayName()));
            return ret;
        } else {
            //  New messages only have content field set
            Message ret = chatMessageDAO.newMessage(senderId, receiverId, message.getContent());
            sendNotification(receiverId, String.format("<LOCALIZE ME><TODO SHOW CONTENT>%s sent you a message.",
                    sender.getDisplayName()));
            return ret;
        }
    }

    private URI getAudioUrl(long userId, String assetId) throws URISyntaxException {
        return new URI(config.getAssetAccessBaseUrl()).
                resolve("audio").
                resolve(Long.toString(userId)).
                resolve(assetId);
    }

    @PATCH
    @Path("/{receiver-id}/message/{message-id}")
    public Message editMessage(@HeaderParam("Authorization") String hlat, @PathParam("receiver-id") long receiverId,
                               @PathParam("messasge-id") long msg,
                               Message message) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long editorId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, editorId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        User editor = userDAO.getUser(editorId);
        User receiver = userDAO.getUser(receiverId);
        if (receiver == null) {
            throw new NotFoundException("No such receiver");
        }
        long messageIdToEdit = message.getId();
        Message messageToEdit = chatMessageDAO.getMessage(messageIdToEdit);
        if (messageToEdit == null) {
            throw new NotFoundException("Message " + messageIdToEdit + " not found");
        }
        //  These are backwards because the editor of a message edits the message the sender sent (aka not your own)
        if (messageToEdit.getSender() != receiverId) {
            throw new ForbiddenException("You cannot edit your own message");
        }
        if (messageToEdit.getReceiver() != editorId) {
            throw new ForbiddenException("You cannot edit a message that's not for you");
        }
        //  The received message only has the ID and editData fields set, the rest are 0 or NULL.
        Message editedMessage = chatMessageDAO.editMessage(messageIdToEdit, message.getEditData());
        sendNotification(receiverId, String.format("<LOCALIZE ME><TODO SHOW CONTENT>%s edited a message.",
                editor.getDisplayName()));
        return editedMessage;
    }

    @GET
    @Path("/{receiver-id}/message")
    public Message[] getMessages(@HeaderParam("Authorization") String hlat,
                                 @PathParam("receiver-id") long receiverId,
                                 @QueryParam("limit") @DefaultValue("50") int limit,
                                 @QueryParam("before") @DefaultValue("0") long beforeMsgId) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        User me = userDAO.getUser(authUserId);
        if (!me.getUsersChattedWith().contains(receiverId)) {
            throw new NotFoundException("Conversation not found");
        }
        Message[] messages = chatMessageDAO.getLatestMessages(authUserId, receiverId, beforeMsgId, limit);
        return messages;
    }

    private void sendNotification(long user, String body) {
        String builtBody = new ApnsPayloadBuilder().
                setAlertTitle("HiLingual Chat").
                setAlertBody(body).
                buildWithDefaultMaximumLength();
        Set<String> tokens = deviceTokenDAO.getUserDeviceTokens(user);
        if (tokens == null) {
            return;
        }
        tokens.stream().
                forEach(token -> apnsService.sendNotification(token, builtBody));
    }

}
