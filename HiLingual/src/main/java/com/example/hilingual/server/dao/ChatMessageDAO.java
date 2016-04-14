package com.example.hilingual.server.dao;

import com.example.hilingual.server.api.Message;
import com.example.hilingual.server.api.MessageEdit;
import io.dropwizard.lifecycle.Managed;

import java.util.Set;

public interface ChatMessageDAO extends Managed {

    void init();

    default Message[] getLatestMessages(long participantA, long participantB, int limit) {
        return getMessages(participantA, participantB, 0L, 0L, limit);
    }

    default Message[] getLatestMessages(long participantA, long participantB, long beforeMessageId, int limit) {
        return getMessages(participantA, participantB, beforeMessageId, 0, limit);
    }

    Message[] getMessages(long participantA, long participantB, long beforeMessageId, long afterMessageId, int limit);

    MessageEdit[] getMessageEdits(long participantA, long participantB, long beforeMessageId, long afterMessageId, int limit);

    default Message newMessage(long sender, long receiver, String content) {
        return newMessage(sender, receiver, content, "", "");
    }

    default Message newAudioMessage(long sender, long receiver, String audioUrl) {
        return newMessage(sender, receiver, "", audioUrl, "");
    }

    default Message newImageMessage(long sender, long receiver, String imageUrl) {
        return newMessage(sender, receiver, "", "", imageUrl);
    }

    Message newMessage(long sender, long receiver, String content, String audioUrl, String imageUrl);

    Message getMessage(long messageId);

    void addRequest(long requester, long recipient);

    void acceptRequest(long accepter, long requester);

    void rejectRequest(long rejecter, long requester);

    Set<Long> getRequests(long userId);

    Message editMessage(long messsageId, String editData);

    void truncate();

}
