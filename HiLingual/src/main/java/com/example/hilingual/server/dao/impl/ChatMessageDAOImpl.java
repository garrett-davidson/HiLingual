package com.example.hilingual.server.dao.impl;

import com.example.hilingual.server.api.Message;
import com.example.hilingual.server.api.MessageEdit;
import com.example.hilingual.server.api.UserChats;
import com.example.hilingual.server.dao.ChatMessageDAO;
import com.example.hilingual.server.dao.impl.annotation.BindMessage;
import com.example.hilingual.server.dao.impl.annotation.BindUserChats;
import com.google.inject.Inject;
import org.skife.jdbi.v2.DBI;
import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.StatementContext;
import org.skife.jdbi.v2.sqlobject.SqlQuery;
import org.skife.jdbi.v2.sqlobject.SqlUpdate;
import org.skife.jdbi.v2.tweak.ResultSetMapper;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.StringTokenizer;
import java.util.function.Function;
import java.util.logging.Logger;
import java.util.stream.Collectors;


public class ChatMessageDAOImpl implements ChatMessageDAO {

    private static Logger LOGGER = Logger.getLogger(ChatMessageDAOImpl.class.getName());
    //  TODO
    private final DBI dbi;
    private Handle handle;
    private Update u;

    @Inject
    public ChatMessageDAOImpl(DBI dbi) {
        this.dbi = dbi;
    }

    public static <T> String setToString(Set<T> set, Function<T, String> toStringer) {
        return set.stream().
                map(toStringer).
                collect(Collectors.joining(","));
    }

    public static <T> Set<T> stringToSet(String input, Function<String, T> fromStringer) {
        Set<T> set = new HashSet<>();
        StringTokenizer tokenizer = new StringTokenizer(input, ",");
        while (tokenizer.hasMoreTokens()) {
            T t = fromStringer.apply(tokenizer.nextToken());
            set.add(t);
        }
        return set;
    }

    @Override
    public void init() {
        u = handle.attach(Update.class);
        handle.execute("CREATE TABLE IF NOT EXISTS hl_chat_messages(" +
                "message_id BIGINT UNIQUE PRIMARY KEY AUTO_INCREMENT, " +
                "sent_timestamp TIMESTAMP, " +
                "edit_timestamp TIMESTAMP, " +
                "sender_id BIGINT, " +
                "receiver_id BIGINT, " +
                "message VARCHAR(500), " +
                "edited_message VARCHAR(500), " +
                "audio VARCHAR(500), " +
                "image VARCHAR(500)");

        handle.execute("CREATE TABLE IF NOT EXISTS hl_chat_pending_requests(" +
                "user_id BIGINT, " +
                "pending_chat_users LONGTEXT)");
    }

    @Override
    public Message[] getMessages(long participantA, long participantB,
                                 long beforeMessageId, long afterMessageId, int limit) {
        //  Internally remap beforeMessageId being null (0) to max value so the condition will always be true
        if (beforeMessageId == 0) {
            beforeMessageId = Long.MAX_VALUE;
        }
        //  afterMessageId being null (0) works out well since the condition will always hold true
        List<Message> returnedMessages = handle.createQuery("SELECT * FROM hl_chat_messages where " +
                "((receiver_id = :receiver_id AND sender_id = :sender_id) " +
                "OR (receiver_id = :sender_id AND sender_id = :receiver_id)) " +
                "AND ((message_id < :before) AND (message_id > :after)) LIMIT :limit")
                .bind("num", limit)
                .bind("receiver_id", participantA)
                .bind("sender_id", participantB)
                .bind("before", beforeMessageId)
                .bind("after", afterMessageId)
                .bind("limit", limit)
                .map(new MessageMapper()).
                        list();
        Message[] msgs = new Message[returnedMessages.size()];
        return returnedMessages.toArray(msgs);
    }

    @Override
    public MessageEdit[] getMessageEdits(long participantA, long participantB, long beforeMessageId, long afterMessageId, int limit) {
        //  Internally remap beforeMessageId being null (0) to max value so the condition will always be true
        if (beforeMessageId == 0) {
            beforeMessageId = Long.MAX_VALUE;
        }
        //  afterMessageId being null (0) works out well since the condition will always hold true
        List<MessageEdit> returnedMessages = handle.createQuery("SELECT edited_message,message_id FROM hl_chat_messages where " +
                "((receiver_id = :receiver_id AND sender_id = :sender_id) " +
                "OR (receiver_id = :sender_id AND sender_id = :receiver_id)) " +
                "AND ((message_id < :before) AND (message_id > :after)) AND (edited_message IS NOT NULL) LIMIT :limit")
                .bind("num", limit)
                .bind("receiver_id", participantA)
                .bind("sender_id", participantB)
                .bind("before", beforeMessageId)
                .bind("after", afterMessageId)
                .bind("limit", limit)
                .map(new MessageEditMapper()).
                        list();
        MessageEdit[] msgs = new MessageEdit[returnedMessages.size()];
        return returnedMessages.toArray(msgs);
    }

    @Override
    public Message newMessage(long sender, long receiver, String content, String audioUrl, String imageUrl) {
        //  Create a new message from sender to receiver with the given content, timestamp of now, and no edit data
        //  and return it after giving it a unique ID
        Message message = new Message();
        message.setContent(content);
        message.setAudio(audioUrl);
        message.setImage(imageUrl);
        message.setSender(sender);
        message.setReceiver(receiver);
        message.setSentTimestamp(System.currentTimeMillis());
        message.setEditTimestamp(0);
        u.insertmessage(message);
        int maxid = u.getLastMessageId();
        message.setId(maxid);
        return message;
    }

    @Override
    public Message getMessage(long messageId) {
        //  Get a specific message, or null if it does not exist
        return handle.createQuery("SELECT * FROM hl_chat_messages where message_id = :message_id")
                .bind("message_id", messageId)
                .map(new MessageMapper())
                .first();
    }

    @Override
    public void addRequest(long requester, long recipient) {
        //  Add a chat request from requester to recipient
        //update the hl_chat_pending_requests table for recipient
        UserChats uc = handle.createQuery("SELECT * FROM hl_chat_pending_requests WHERE user_id = :uidp")
                .bind("uidp", String.valueOf(recipient))
                .map(new RequestsMapper())
                .first();

        if (uc == null) {
            Set<Long> tempSet = new HashSet<Long>();
            tempSet.add(requester);
            UserChats newentry = new UserChats(recipient, new HashSet<Long>(), tempSet);
            u.insertrequest(newentry);
        } else {
            uc.getPendingChats().add(requester);
            u.updaterequests(uc);
        }
    }

    @Override
    public void acceptRequest(long accepter, long requester) {
        //  Accept a chat request to accepter from requester
        UserChats uc = handle.createQuery("SELECT * FROM hl_chat_pending_requests WHERE user_id = :uid")
                .bind("uid", String.valueOf(accepter))
                .map(new RequestsMapper())
                .first();
        if (uc != null) {
            Set<Long> pendingset = uc.getPendingChats();
            pendingset.remove(requester);
            if (pendingset.isEmpty()) {
                u.removerequests(uc);
            } else {
                u.updaterequests(uc);
            }
        } else {
            //error
            LOGGER.warning("Missing accepter " + accepter);
        }
    }

    @Override
    public void rejectRequest(long rejecter, long requester) {
        UserChats uc = handle.createQuery("SELECT * FROM hl_chat_pending_requests WHERE user_id = :uid")
                .bind("uid", String.valueOf(rejecter))
                .map(new RequestsMapper())
                .first();
        if (uc != null) {
            Set<Long> pendingset = uc.getPendingChats();
            pendingset.remove(requester);
            if (pendingset.isEmpty()) {
                u.removerequests(uc);
            } else {
                u.updaterequests(uc);
            }
        } else {
            //error
            LOGGER.warning("Missing rejector " + rejecter);
        }
    }

    @Override
    public Set<Long> getRequests(long userId) {
        //  Get pending requests
        UserChats uc = handle.createQuery("SELECT * FROM hl_chat_pending_requests WHERE user_id = :uid")
                .bind("uid", String.valueOf(userId))
                .map(new RequestsMapper())
                .first();
        if (uc == null) {
            return new HashSet<Long>();
        }
        return uc.getPendingChats();
    }

    @Override
    public Message editMessage(long messageId, String editData) {
        //  Update the specified message with the given editData.
        //  Return the message in full with the edit data
        //  Return null if no such message exists
        Message mess = handle.createQuery("SELECT * FROM hl_chat_messages where message_id = :message_id")
                .bind("message_id", messageId)
                .map(new MessageMapper())
                .first();

        mess.setEditData(editData);
        mess.setEditTimestamp(System.currentTimeMillis());
        u.updatemessage(mess);

        return mess;
    }

    @Override
    public void truncate() {
        //  Truncate message and request tables
        handle.execute("TRUNCATE hl_chat_messages");
        handle.execute("TRUNCATE hl_chat_pending_requests");
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

    public static interface Update {
        @SqlUpdate("insert into hl_chat_messages (sent_timestamp, edit_timestamp, sender_id, receiver_id, message, edited_message, audio, image) values (:sent_timestamp, :edit_timestamp, :sender_id, :receiver_id, :message, :edited_message, :audio, :image)")
        void insertmessage(@BindMessage Message message);

        @SqlUpdate("update hl_chat_messages set message_id = :message_id, sent_timestamp = :sent_timestamp, edit_timestamp = :edit_timestamp, sender_id = :sender_id, receiver_id = :receiver_id, message = :message, edited_message = :edited_message, audio = :audio, image = :image where message_id = :message_id")
        int updatemessage(@BindMessage Message message);

        @SqlUpdate("update hl_chat_pending_requests set user_id = :user_id, pending_chat_users = :pending_chat_users where user_id = :user_id")
        void updaterequests(@BindUserChats UserChats uc);

        @SqlUpdate("insert into hl_chat_pending_requests (user_id, pending_chat_users) values (:user_id, :pending_chat_users)")
        void insertrequest(@BindUserChats UserChats uc);

        @SqlUpdate("delete from hl_chat_pending_requests where user_id = :user_id")
        void removerequests(@BindUserChats UserChats uc);

        @SqlQuery("SELECT LAST_INSERT_ID()")
        int getLastMessageId();

    }

    class MessageMapper implements ResultSetMapper<Message> {

        @Override
        public Message map(int index, ResultSet r, StatementContext ctx) throws SQLException {
            Message message = new Message();
            message.setId(r.getLong("message_id"));
            message.setSentTimestamp(r.getTimestamp("sent_timestamp").getTime());
            message.setEditTimestamp(r.getTimestamp("edit_timestamp").getTime());
            message.setSender(r.getLong("sender_id"));
            message.setReceiver(r.getLong("receiver_id"));
            message.setContent(r.getString("message"));
            message.setEditData(r.getString("edited_message"));
            message.setAudio(r.getString("audio"));
            message.setImage(r.getString("image"));
            return message;
        }
    }

    class MessageEditMapper implements ResultSetMapper<MessageEdit> {

        @Override
        public MessageEdit map(int index, ResultSet r, StatementContext ctx) throws SQLException {
            MessageEdit edit = new MessageEdit();
            edit.setEditData(r.getString("edited_message"));
            edit.setId(r.getLong("message_id"));
            return edit;
        }
    }

    class RequestsMapper implements ResultSetMapper<UserChats> {
        @Override
        public UserChats map(int index, ResultSet r, StatementContext ctx) throws SQLException {
            UserChats uc = new UserChats();
            uc.setUserId(r.getLong("user_id"));
            String pendingChats = r.getString("pending_chat_users");
            uc.setPendingChats(stringToSet(pendingChats, Long::parseLong));
            return uc;
        }
    }
}
