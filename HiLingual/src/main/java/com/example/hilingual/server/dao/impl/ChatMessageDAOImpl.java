package com.example.hilingual.server.dao.impl;

import com.example.hilingual.server.api.Message;
import com.example.hilingual.server.dao.ChatMessageDAO;

public class ChatMessageDAOImpl implements ChatMessageDAO {

    //  TODO


    @Override
    public void init() {

    }

    @Override
    public Message[] getLatestMessages(long participantA, long participantB, int limit) {
        return new Message[0];
    }

    @Override
    public Message[] getLatestMessages(long participantA, long participantB, long beforeMessageId, int limit) {
        return new Message[0];
    }

    @Override
    public void addMessage(Message message) {

    }

    @Override
    public void truncate() {

    }

    @Override
    public void start() throws Exception {
        init();
    }

    @Override
    public void stop() throws Exception {

    }
}
