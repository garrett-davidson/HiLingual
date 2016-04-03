package com.example.hilingual.server.dao.impl;

import com.example.hilingual.server.api.Message;
import com.example.hilingual.server.dao.ChatMessageDAO;
import com.google.inject.Inject;
import org.skife.jdbi.v2.DBI;
import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.StatementContext;
import org.skife.jdbi.v2.tweak.ResultSetMapper;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Logger;

public class ChatMessageDAOImpl implements ChatMessageDAO {

    //  TODO
    private final DBI dbi;
    private Handle handle;
    private static Logger LOGGER = Logger.getLogger(ChatMessageDAOImpl.class.getName());

    @Inject
    public ChatMessageDAOImpl(DBI dbi) { this.dbi = dbi;}

    @Override
    public void init() {
        handle.execute("CREATE TABLE IF NOT EXISTS chat_messages(" +
                "message_id BIGINT UNIQUE PRIMARY KEY, " +
                "sent_timestamp TIMESTAMP, " +
                "edit_timestamp TIMESTAMP, " +
                "sender_id BIGINT, " +
                "receiver_id BIGINT, " +
                "message VARCHAR(500), " +
                "edited_message VARCHAR(500))");
    }

    @Override
    public Message[] getLatestMessages(long participantA, long participantB, int limit) {
        //  Convenience method
        return getLatestMessages(participantA, participantB, 0, limit);
    }

    @Override
    public Message[] getLatestMessages(long participantA, long participantB, long beforeMessageId, int limit) {
        //  Get the n=limit messages before beforeMessageId between A and B
        //  if beforeMessageId is 0, then we get the most recent n=limit messages.
        return new Message[0];
    }

    @Override
    public Message newMessage(long sender, long receiver, String content) {
        //  Create a new message from sender to receiver with the given content, timestamp of now, and no edit data
        //  and return it after giving it a unique ID
        return null;
    }

    @Override
    public Message getMessage(long messageId) {
        //  Get a specific message, or null if it does not exist
        return null;
    }

    @Override
    public void addRequest(long requester, long recipient) {
        //  Add a chat request from requester to recipient
    }

    @Override
    public void acceptRequest(long accepter, long requester) {
        //  Accept a chat request to accepter from requester

    }

    @Override
    public long[] getRequests(long userId) {
        //  Get pending requests
        return new long[0];
    }

    @Override
    public Message editMessage(long messsageId, String editData) {
        //  Update the specified message with the given editData.
        //  Return the message in full with the edit data
        //  Return null if no such message exists
        return null;
    }

    @Override
    public void truncate() {
        //  Truncate message and request tables

    }

    @Override
    public void start() throws Exception {
        LOGGER.info("Opening DBI handle");
        handle = dbi.open();
        LOGGER.info("Init DAO");
        init();
    }

    @Override
    public void stop() throws Exception {

    }

    class MessageMapper implements ResultSetMapper<Message> {

        @Override
        public Message map(int index, ResultSet r, StatementContext ctx) throws SQLException {
            Message message = new Message();
            message.setId(r.getLong("message_id"));
            message.setSentTimestamp(r.getDate("sent_date").getTime());
            message.setEditTimestamp(r.getDate("edit_date").getTime());
            message.setSender(r.getLong("sender_id"));
            message.setReceiver(r.getLong("receiver_id"));
            message.setContent(r.getString("message"));
            message.setEditData(r.getString("edited_message"));

            return message;
        }




    }



}
