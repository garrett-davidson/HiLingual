/*
 * UserDAOImpl.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dao.impl;

import com.example.hilingual.server.api.Gender;
import com.example.hilingual.server.api.User;
import com.example.hilingual.server.dao.UserDAO;
import com.example.hilingual.server.dao.impl.annotation.BindUser;
import com.google.inject.Inject;
import org.skife.jdbi.v2.DBI;
import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.StatementContext;
import org.skife.jdbi.v2.sqlobject.Bind;
import org.skife.jdbi.v2.sqlobject.SqlQuery;
import org.skife.jdbi.v2.sqlobject.SqlUpdate;
import org.skife.jdbi.v2.tweak.ResultSetMapper;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.function.Function;
import java.util.logging.Logger;
import java.util.stream.Collectors;

public class UserDAOImpl implements UserDAO {


    private final DBI dbi;
    private Handle handle;
    private Update u;

    private static Logger LOGGER = Logger.getLogger(UserDAOImpl.class.getName());

    @Inject
    public UserDAOImpl(DBI dbi) {
        this.dbi = dbi;
    }

    @Override
    public void init() {
        u = handle.attach(Update.class);
        handle.execute("CREATE TABLE IF NOT EXISTS hl_users(" +
                "user_id BIGINT UNIQUE PRIMARY KEY AUTO_INCREMENT, " +
                "user_name TINYTEXT, " +
                "display_name TINYTEXT, " +
                "bio TEXT, " +
                "gender TEXT, " +
                "birth_date DATE, " +
                "image_url LONGTEXT, " +
                "known_languages LONGTEXT, " +
                "learning_languages LONGTEXT, " +
                "blocked_users LONGTEXT, " +
                "users_chatted_with LONGTEXT, " +
                "profile_set TINYINT)");
    }

    @Override
    public User getUser(long userId) {
        return handle.createQuery("SELECT * FROM hl_users WHERE user_id = :uid").
                bind("uid", userId).
                map(new UserMapper()).
                first();
    }

    @Override
    public void updateUser(User newUserData) {
        u.update(newUserData);
    }

    @Override
    public void deleteUser(long userId) {
        u.deleteByName(userId);
    }

    @Override
    public User createUser() {
        User user = new User();
        u.insert(user);
        int lastId = u.getLastInsertId();
        user.setUserId(lastId);
        updateUser(user);
        return user;
    }

    @Override
    public User[] findUsers(String query, User invoker) {
        User[] results;
        List<User> usersList;
        /*
        if (query.startsWith("RNAME:")) { //if the search query is by real/display name
            //create query to search for users where real/dipslay name is like query. use UserMapper
            usersList = handle.createQuery("SELECT * FROM hl_users WHERE display_name LIKE :rname")
                    .bind("rname", query.substring(6))
                    .map(new UserMapper())
                    .list();
        } else
        if (query.startsWith("UNAME:")) { //if the seach query is by username */

            //create query to search for users where user name is like query. use UserMapper
        usersList = handle.createQuery("SELECT * FROM hl_users WHERE user_name LIKE :uname")
                    .bind("uname", query.substring(6))
                    .map(new UserMapper())
                    .list();
        /*} else {
            //if the query has invalid format return empty array
            results = new User[0];
            return results;
        }
        */
        //convert the List to Array and return
        results = new User[usersList.size()];
        results = usersList.toArray(results);
        return results;
    }

    @Override
    public void truncate() {
        handle.execute("TRUNCATE hl_users");
    }

    @Override
    public void start() throws Exception {
        handle = dbi.open();
        init();
    }

    @Override
    public void stop() throws Exception {
        handle.close();
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
            user.setBirthdate(r.getDate("birth_date"));
            user.setImageURL(r.getURL("image_url"));
            String usersChattedWith = r.getString("users_chatted_with");
            user.setUsersChattedWith(stringToSet(usersChattedWith, Long::parseLong));
            String blockedUsers = r.getString("blocked_users");
            user.setBlockedUsers(stringToSet(blockedUsers, Long::parseLong));
            String knownLanguages = r.getString("known_languages");
            user.setKnownLanguages(stringToSet(knownLanguages, Locale::forLanguageTag));
            String learningLanguages = r.getString("learning_languages");
            user.setLearningLanguages(stringToSet(learningLanguages, Locale::forLanguageTag));
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

        @SqlUpdate("insert into hl_users (user_id, user_name, display_name, bio, gender, birth_date, image_url, known_languages, learning_languages, blocked_users, users_chatted_with, profile_set) values (:user_id, :user_name, :display_name, :bio, :gender, :birth_date, :image_url, :known_languages, :learning_languages, :blocked_users, :users_chatted_with, :profile_set)")
        void insert(@BindUser User user);

        @SqlUpdate("update hl_users set user_name = :user_name, display_name = :display_name, bio = :bio, gender = :gender, birth_date = :birth_date, image_url = :image_url, known_languages = :known_languages, learning_languages = :learning_languages, blocked_users = :blocked_users, users_chatted_with = :users_chatted_with, profile_set = :profile_set where user_id = :user_id")
        int update(@BindUser User user);

        @SqlUpdate("delete from hl_users where id = :user_id")
        void deleteByName(@Bind long id);

        @SqlQuery("SELECT LAST_INSERT_ID()")
        int getLastInsertId();
    }
}
