package com.example.hilingual.server.dao;

import com.example.hilingual.server.api.Message;
import io.dropwizard.lifecycle.Managed;

public interface ChatMessageDAO extends Managed {

    void init();

    Message[] getLatestMessages(long participantA, long participantB, int limit);

    Message[] getLatestMessages(long participantA, long participantB, long beforeMessageId, int limit);

    void addMessage(Message message);

    void addRequest(long requester, long recipient);

    void acceptRequest(long accepter, long requester);

    long[] getRequests(long userId);

    void truncate();

}
