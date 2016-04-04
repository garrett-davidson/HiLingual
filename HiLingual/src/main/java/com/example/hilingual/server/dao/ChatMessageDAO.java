package com.example.hilingual.server.dao;

import com.example.hilingual.server.api.Message;
import io.dropwizard.lifecycle.Managed;

import java.util.Set;

public interface ChatMessageDAO extends Managed {

    void init();

    Message[] getLatestMessages(long participantA, long participantB, int limit);

    Message[] getLatestMessages(long participantA, long participantB, long beforeMessageId, int limit);

    Message newMessage(long sender, long receiver, String content);

    Message getMessage(long messageId);

    void addRequest(long requester, long recipient);

    void acceptRequest(long accepter, long requester);

    Set<Long> getRequests(long userId);

    Message editMessage(long messsageId, String editData);

    void truncate();

}
