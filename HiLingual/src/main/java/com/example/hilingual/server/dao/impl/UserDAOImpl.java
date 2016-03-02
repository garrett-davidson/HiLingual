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
import com.sun.tools.internal.xjc.Language;
import org.apache.commons.codec.language.bm.Languages;
import org.skife.jdbi.v2.DBI;
import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.StatementContext;
import org.skife.jdbi.v2.sqlobject.Bind;
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
                "user_id BIGINT, " +
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
        u.update(new DbUser(newUserData));
    }

    @Override
    public void deleteUser(long userId) {
        u.deleteByName(userId);
    }

    @Override
    public User createUser() {
        User user = new User();
        u.insert(new DbUser(user));
        return user;
    }

    @Override
    public User[] findUsers(String query, User invoker) {
        User[] results = null;
        String sql_query;
        List<Map<String, Object>> queryReturn;
        if (query.startsWith("RNAME:")) {
            //  TODO Nate - implement search based on real name (Story 4.2)
            sql_query = "SELECT * FROM hl_users WHERE display_name LIKE '%" + query.substring(6) + "%'";
            queryReturn = handle.select(sql_query);


        } else if (query.startsWith("UNAME:")) {
            //  TODO Nate - implement search based on username (Story 4.3)
            sql_query = "SELECT * FROM hl_users WHERE user_name LIKE '%" + query.substring(6) + "%'";
            queryReturn = handle.select(sql_query);

        } else {
            results = new User[0];
            return results;
        }

        results = new User[queryReturn.size()];

        for (int i = 0; i < queryReturn.size(); i++) {
            //create a DbUser with the strings from the databse
            DbUser temp_db_user = new DbUser(
                    (String)queryReturn.get(i).get("user_id"),
                    (String)queryReturn.get(i).get("user_name"),
                    (String)queryReturn.get(i).get("display_name"),
                    (String)queryReturn.get(i).get("bio"),
                    (String)queryReturn.get(i).get("gender"),
                    (String)queryReturn.get(i).get("birth_date"),
                    (String)queryReturn.get(i).get("image_url"),
                    (String)queryReturn.get(i).get("known_languages"),
                    (String)queryReturn.get(i).get("learning_languages"),
                    (String)queryReturn.get(i).get("blocked_users"),
                    (String)queryReturn.get(i).get("users_chatted_with"),
                    (String)queryReturn.get(i).get("profile_set"));

            results[i] = temp_db_user.toUser(); //convert the DbUser to a User and add it to results array
        }



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

    private <T> String setToString(Set<T> set, Function<T, String> toStringer) {
        return set.stream().
                map(toStringer).
                collect(Collectors.joining(","));
    }

    private <T> Set<T> stringToSet(String input, Function<String, T> fromStringer) {
        Set<T> set = new HashSet<>();
        StringTokenizer tokenizer = new StringTokenizer(input, ",");
        while (tokenizer.hasMoreTokens()) {
            T t = fromStringer.apply(tokenizer.nextToken());
            set.add(t);
        }
        return set;
    }

    public static interface Update
    {
//        @SqlUpdate("CREATE TABLE IF NOT EXISTS hl_users(user_id BIGINT, user_name TINYTEXT, display_name TINYTEXT,bio TEXT, gender TEXT, birth_date DATE, image_url LONGTEXT, known_languages LONGTEXT, learning_languages LONGTEXT, blocked_users LONGTEXT, users_chatted_with LONGTEXT, profile_set TINYINT")
//        void createTable();

        @SqlUpdate("insert into hl_users (user_id, user_name, display_name, bio, gender, birth_date, image_url, known_languages, learning_lanuages, blocked_users, users_chatted_with, profile_set) values (:user_id, :user_name, :display_name, :bio, :gender, :birth_date, :image_url, :known_languages, :learning_lanuages, :blocked_users, :users_chatted_with)")
        void insert(@BindUser DbUser dbUser);

        @SqlUpdate("update hl_users set user_name = :user_name, display_name = :display_name, bio = :bio, gender = :gender, birth_date = :birth_date, image_url = :image_url, known_languages = :known_languages, learning_lanuages = :learning_lanuages, blocked_users = :blocked_users, users_chatted_with = :users_chatted_with where user_id = :user_id")
        int update(@BindUser DbUser user);

        @SqlUpdate("delete from hl_users where id = :user_id")
        void deleteByName(@Bind long id);
    }
}
