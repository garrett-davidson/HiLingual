package com.example.hilingual.server.resources;

import com.example.hilingual.server.api.*;
import com.example.hilingual.server.config.ServerConfig;
import com.example.hilingual.server.dao.*;
import com.example.hilingual.server.service.APNsService;
import com.example.hilingual.server.service.MsftTranslateService;
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
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Base64;
import java.util.Locale;
import java.util.Random;
import java.util.Set;

import static java.nio.file.StandardOpenOption.CREATE;
import static java.nio.file.StandardOpenOption.TRUNCATE_EXISTING;

@Path("/chat")
@Produces(MediaType.APPLICATION_JSON + "; charset=utf-8")
@Consumes(MediaType.APPLICATION_JSON)
public class ChatResource {


    private final SessionDAO sessionDAO;
    private final UserDAO userDAO;
    private final ChatMessageDAO chatMessageDAO;
    private final APNsService apnsService;
    private final DeviceTokenDAO deviceTokenDAO;
    private final MsftTranslateService translateService;
    private final TranslationCacheDAO translationCacheDAO;
    private final ServerConfig config;
    private final Random random;

    @Inject
    public ChatResource(SessionDAO sessionDAO, UserDAO userDAO, ChatMessageDAO chatMessageDAO,
                        APNsService apnsService, DeviceTokenDAO deviceTokenDAO,
                        MsftTranslateService translateService,
                        TranslationCacheDAO translationCacheDAO, ServerConfig config) {
        this.sessionDAO = sessionDAO;
        this.userDAO = userDAO;
        this.chatMessageDAO = chatMessageDAO;
        this.apnsService = apnsService;
        this.deviceTokenDAO = deviceTokenDAO;
        this.translateService = translateService;
        this.translationCacheDAO = translationCacheDAO;
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
        if (receiverId == requesterId) {
            throw new ForbiddenException("You cannot request a chat with yourself");
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
        requester.getUsersChattedWith().add(receiverId);
        userDAO.updateUser(requester);
        chatMessageDAO.addRequest(requesterId, receiverId);
        sendNotification(receiverId, String.format("%s wants to start a conversation with you!",
                requester.getDisplayName()), NotificationType.REQUEST_RECEIVED);
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
        //  Ignore requests where accepter already accepted requester
        if (accepter.getUsersChattedWith().contains(requesterId)) {
            return;
        }
        //  Check that they were requested
        Set<Long> requests = chatMessageDAO.getRequests(accepterId);
        boolean found = false;
        for (long request : requests) {
            if (request == requesterId) {
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
                accepter.getDisplayName()), NotificationType.REQUEST_ACCEPTED);
    }

    @DELETE
    @Path("/{requester-id}/request")
    public void reject(@HeaderParam("Authorization") String hlat, @PathParam("requester-id") long requesterId) {
        //  Check auth
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long rejecterId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, rejecterId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        User rejecter = userDAO.getUser(rejecterId);
        User requester = userDAO.getUser(requesterId);
        if (requester == null) {
            throw new NotFoundException("No such requester");
        }
        //  Check that they were requested
        Set<Long> requests = chatMessageDAO.getRequests(rejecterId);
        boolean found = false;
        for (long request : requests) {
            if (request == requesterId) {
                found = true;
                break;
            }
        }
        if (!found) {
            throw new NotFoundException("Request " + requesterId + " not found");
        }
        requester.getUsersChattedWith().remove(rejecterId);
        rejecter.getUsersChattedWith().remove(requesterId);
        userDAO.updateUser(requester);
        userDAO.updateUser(rejecter);
        chatMessageDAO.rejectRequest(rejecterId, requesterId);
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
        if (message.getImage() != null) {
            String assetId = new BigInteger(130, random).toString(32);
            java.nio.file.Path outPath = Paths.get(config.getAssetAccessPath(), "image", assetId);
            Files.createDirectories(outPath.getParent());
            Files.write(outPath, message.audioDataToBytes(), CREATE, TRUNCATE_EXISTING);
            URI uri = getImageUrl(senderId, assetId);
            //  New messages only have content field set
            Message ret = chatMessageDAO.newAudioMessage(senderId, receiverId, uri.toASCIIString());
            sendNotification(receiverId, String.format("<LOCALIZE ME>%s sent you a picture.",
                    sender.getDisplayName()), NotificationType.NEW_MESSAGE);
            return ret;
        } else if (message.getAudio() != null) {
            String assetId = new BigInteger(130, random).toString(32);
            java.nio.file.Path outPath = Paths.get(config.getAssetAccessPath(), "audio", assetId);
            Files.createDirectories(outPath.getParent());
            Files.write(outPath, message.audioDataToBytes(), CREATE, TRUNCATE_EXISTING);
            URI uri = getAudioUrl(senderId, assetId);
            //  New messages only have content field set
            Message ret = chatMessageDAO.newAudioMessage(senderId, receiverId, uri.toASCIIString());
            sendNotification(receiverId, String.format("<LOCALIZE ME>%s sent you a voice clip.",
                    sender.getDisplayName()), NotificationType.NEW_MESSAGE);
            return ret;
        } else {
            //  New messages only have content field set
            Message ret = chatMessageDAO.newMessage(senderId, receiverId, message.getContent());
            sendNotification(receiverId, String.format("%s: %s",
                    sender.getDisplayName(), base64Decode(message.getContent())), NotificationType.NEW_MESSAGE);
            return ret;
        }
    }

    private URI getAudioUrl(long userId, String assetId) throws URISyntaxException {
        return new URI(config.getAssetAccessBaseUrl() + "/audio/" + assetId);
    }

    private URI getImageUrl(long userId, String assetId) throws URISyntaxException {
        return new URI(config.getAssetAccessBaseUrl() + "/image/" + assetId);
    }

    @PATCH
    @Path("/{receiver-id}/message/{message-id}")
    public Message editMessage(@HeaderParam("Authorization") String hlat, @PathParam("receiver-id") long receiverId,
                               @PathParam("message-id") long msg,
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
        Message messageToEdit = chatMessageDAO.getMessage(msg);
        if (messageToEdit == null) {
            throw new NotFoundException("Message " + msg + " not found");
        }
        if (messageToEdit.getReceiver() != editorId) {
            throw new ForbiddenException("You cannot edit a message that's not for you");
        }
        //  The received message only has the ID and editData fields set, the rest are 0 or NULL.
        Message editedMessage = chatMessageDAO.editMessage(msg, message.getEditData());
        sendNotification(receiverId, String.format("%s edited: %s",
                editor.getDisplayName(), base64Decode(editedMessage.getEditData())), NotificationType.EDITED_MESSAGE);
        return editedMessage;
    }

    @GET
    @Path("/{receiver-id}/message")
    public Object[] getMessages(@HeaderParam("Authorization") String hlat,
                                @PathParam("receiver-id") long receiverId,
                                @QueryParam("limit") @DefaultValue("50") int limit,
                                @QueryParam("before") @DefaultValue("0") long beforeMsgId,
                                @QueryParam("after") @DefaultValue("0") long afterMsgId,
                                @QueryParam("e") @DefaultValue("false") boolean returnEditsOnly) {
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
        if (beforeMsgId < 0) {
            throw new BadRequestException("Before msg ID cannot be less than 0");
        }
        if (afterMsgId < 0) {
            throw new BadRequestException("After msg ID cannot be less than 0");
        }
        if (limit < 0) {
            throw new BadRequestException("Limit cannot be less than 0");
        }
        if (returnEditsOnly) {
            return chatMessageDAO.getMessageEdits(authUserId, receiverId, beforeMsgId, afterMsgId, limit);
        } else {
            return chatMessageDAO.getMessages(authUserId, receiverId, beforeMsgId, afterMsgId, limit);
        }
    }

    @GET
    @Path("/{receiver-id}/message/{message-id}/translate")
    public TranslationResponse getTranslation(@HeaderParam("Authorization") String hlat,
                                              @PathParam("receiver-id") long receiverId,
                                              @PathParam("message-id") long msgId,
                                              @QueryParam("to") @DefaultValue("en") String toLanguage,
                                              @QueryParam("edit") @DefaultValue("false") boolean translateEdit) {
        String sessionId = SessionDAO.getSessionIdFromHLAT(hlat);
        long authUserId = sessionDAO.getSessionOwner(sessionId);
        if (!sessionDAO.isValidSession(sessionId, authUserId)) {
            throw new NotAuthorizedException("Bad session token");
        }
        Message message = chatMessageDAO.getMessage(msgId);
        if (message == null) {
            throw new NotFoundException("Message " + msgId + " not found");
        }
        if (message.getReceiver() != authUserId && message.getSender() != authUserId) {
            throw new ForbiddenException("You are not in this conversation");
        }
        if (translateEdit && message.getEditData() == null) {
            throw new NotFoundException("Message " + msgId + " has no edit data");
        }
        Locale locale = Locale.forLanguageTag(toLanguage);
        String decoded;
        if (translateEdit) {
            decoded = base64Decode(message.getEditData());
        } else {
            decoded = base64Decode(message.getContent());
        }
        String translated = translationCacheDAO.getCached(locale, decoded);
        if (translated == null) {
            translated = translateService.translate(decoded, locale);
            translationCacheDAO.cache(locale, decoded, translated);
        }
        String encoded = base64Encode(translated);
        return new TranslationResponse(encoded, msgId, translateEdit);
    }

    @DELETE
    @Path("/{receiver-id}")
    public void deleteChat(@HeaderParam("Authorization") String hlat, @PathParam("receiver-id") long receiverId) {
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
        requester.getUsersChattedWith().remove(receiverId);
        receiver.getUsersChattedWith().remove(requesterId);
        userDAO.updateUser(requester);
        userDAO.updateUser(receiver);
    }

    private void sendNotification(long user, String body, NotificationType type) {
        String builtBody = new ApnsPayloadBuilder().
                setAlertTitle("HiLingual Chat").
                setAlertBody(body).
                setSoundFileName("default").
                addCustomProperty("type", type.name()).
                buildWithDefaultMaximumLength();
        Set<String> tokens = deviceTokenDAO.getUserDeviceTokens(user);
        if (tokens == null) {
            return;
        }
        tokens.stream().
                forEach(token -> apnsService.sendNotification(token, builtBody));
    }

    private String base64Decode(String base64) {
        return new String(Base64.getDecoder().decode(base64), StandardCharsets.UTF_8);
    }

    private String base64Encode(String text) {
        return Base64.getEncoder().encodeToString(text.getBytes(StandardCharsets.UTF_8));
    }
}
