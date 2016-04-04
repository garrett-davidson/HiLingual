package com.example.hilingual.server.dao.impl;

import com.example.hilingual.server.api.Gender;
import com.example.hilingual.server.api.Message;
import com.example.hilingual.server.api.User;
import com.example.hilingual.server.api.UserChats;
import com.example.hilingual.server.dao.ChatMessageDAO;
import com.example.hilingual.server.dao.impl.annotation.BindMessage;
import com.example.hilingual.server.dao.impl.annotation.BindUser;
import com.example.hilingual.server.dao.impl.annotation.BindUserChats;
import com.google.inject.Inject;
import org.skife.jdbi.v2.DBI;
import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.StatementContext;
import org.skife.jdbi.v2.sqlobject.SqlUpdate;
import org.skife.jdbi.v2.tweak.ResultSetMapper;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.function.Function;
import java.util.logging.Logger;
import java.util.stream.Collectors;


public class ChatMessageDAOImpl implements ChatMessageDAO {

    //  TODO
    private final DBI dbi;
    private Handle handle;
    private static Logger LOGGER = Logger.getLogger(ChatMessageDAOImpl.class.getName());
    private Update u;

    @Inject
    public ChatMessageDAOImpl(DBI dbi) { this.dbi = dbi;}

    @Override
    public void init() {
        u = handle.attach(Update.class);
        handle.execute("CREATE TABLE IF NOT EXISTS hl_chat_messages(" +
                "message_id BIGINT UNIQUE PRIMARY KEY, " +
                "sent_timestamp TIMESTAMP, " +
                "edit_timestamp TIMESTAMP, " +
                "sender_id BIGINT, " +
                "receiver_id BIGINT, " +
                "message VARCHAR(500), " +
                "edited_message VARCHAR(500))");

        handle.execute("CREATE TABLE IF NOT EXISTS hl_chat_pending_requests(" +
                "user_id BIGINT, " +
                "pending_chat_users LONGTEXT)");
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
        Message message = new Message();
        u.insertmessage(message);
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
            Set<Long> pendingChats = uc.getPendingChats();
            pendingChats.add(requester);
            uc.setPendingChats(pendingChats);
            u.updaterequests(uc);
        }
        LOGGER.info("DONE");


        //update the hl_users table for requester
        User user = handle.createQuery("SELECT * FROM hl_users WHERE user_id = :uidq")
                .bind("uidq", String.valueOf(requester))
                .map(new UserMapper())
                .first();

        user.addusersChattedWith(recipient);
        u.updateuser(user);


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
                uc.setPendingChats(pendingset);
                u.updaterequests(uc);
            }
        } else {
            //error
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
    public Message editMessage(long messsageId, String editData) {
        //  Update the specified message with the given editData.
        //  Return the message in full with the edit data
        //  Return null if no such message exists
        return null;
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

    class UserMapper implements ResultSetMapper<User> {

        @Override
        public User map(int index, ResultSet r, StatementContext ctx) throws SQLException {
            User user = new User();
            user.setUserId(r.getLong("user_id"));
            user.setName(r.getString("user_name"));
            user.setDisplayName(r.getString("display_name"));
            user.setBio(r.getString("bio"));
            user.setGender(Gender.valueOf(r.getString("gender")));
            user.setBirthdate(r.getDate("birth_date").getTime());
            user.setImageURL(r.getURL("image_url"));
            String usersChattedWith = r.getString("users_chatted_with");
            user.setUsersChattedWith(stringToSet(usersChattedWith, Long::parseLong));
            String blockedUsers = r.getString("blocked_users");
            user.setBlockedUsers(stringToSet(blockedUsers, Long::parseLong));
            String knownLanguages = r.getString("known_languages");
            user.setKnownLanguages(stringToSet(knownLanguages, Function.identity()));
            String learningLanguages = r.getString("learning_languages");
            user.setLearningLanguages(stringToSet(learningLanguages, Function.identity()));
            user.setProfileSet(r.getBoolean("profile_set"));

            return user;
        }
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

    public static interface Update {
        @SqlUpdate("insert into hl_chat_messages (message_id, sent_timestamp, edit_timestamp, sender_id, receiver_id, message, edited_message) values (:message_id, :sent_timestamp, :edit_timestamp, :sender_id, :receiver_id, :message, :edited_message)")
        void insertmessage(@BindMessage Message message);

        @SqlUpdate("update hl_chat_messages set message_id = :massage_id, sent_timestamp = :sent_timestamp, sender_id = :sender_id, receiver_id = :receiver_id, message = :message, edited_message = :edited_message where message_id = :message_id")
        int updatemessage(@BindMessage Message message);

        @SqlUpdate("update hl_chat_pending_requests set user_id = :user_id, pending_chat_users = :pending_chat_users where user_id = :user_id")
        void updaterequests(@BindUserChats UserChats uc);

        @SqlUpdate("insert into hl_chat_pending_requests (user_id, pending_chat_users) values (:user_id, :pending_chat_users)")
        void insertrequest(@BindUserChats UserChats uc);

        @SqlUpdate("update hl_users set user_name = :user_name, display_name = :display_name, bio = :bio, gender = :gender, birth_date = :birth_date, image_url = :image_url, known_languages = :known_languages, learning_languages = :learning_languages, blocked_users = :blocked_users, users_chatted_with = :users_chatted_with, profile_set = :profile_set where user_id = :user_id")
        int updateuser(@BindUser User user);

        @SqlUpdate("delete from hl_chat_pending_requests where user_id = :user_id")
        void removerequests(@BindUserChats UserChats uc);

    }
}