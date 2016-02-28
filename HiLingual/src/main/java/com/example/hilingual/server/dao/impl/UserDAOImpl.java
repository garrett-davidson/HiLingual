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
import com.google.inject.Inject;
import org.skife.jdbi.v2.DBI;
import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.StatementContext;
import org.skife.jdbi.v2.Update;
import org.skife.jdbi.v2.sqlobject.Bind;
import org.skife.jdbi.v2.sqlobject.BindBean;
import org.skife.jdbi.v2.sqlobject.SqlUpdate;
import org.skife.jdbi.v2.tweak.ResultSetMapper;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.Date;
import java.util.logging.Logger;

public class UserDAOImpl implements UserDAO {


    private final DBI dbi;
    private Handle handle;
    private Update u;

    private static Logger LOGGER = Logger.getLogger(UserDAOImpl.class.getName());

    @Inject
    public UserDAOImpl(DBI dbi) {
        this.dbi = dbi;
        Update u = handle.attach(Update.class);
    }

    @Override
    public void init() {
        handle.execute("CREATE TABLE IF NOT EXISTS hl_users(user_id BIGINT, user_name TINYTEXT, display_name TINYTEXT,bio TEXT, gender TEXT, birth_date DATE, image_url LONGTEXT, known_languages LONGTEXT, learning_languages LONGTEXT, blocked_users LONGTEXT, users_chatted_with LONGTEXT, profile_set TINYINT");
    }

    @Override
    public User getUser(long userId) {
        return handle.createQuery("SELECT * FROM hl_users WHERE userId = :uid").
                bind("uid", userId).
                map(new UserMapper()).
                first();
    }

    @Override
    public void updateUser(User newUserData) {
        long userId = newUserData.getUserId();
        Date birthDate = newUserData.getBirthdate();
        DbUser dbUser = new DbUser(newUserData);
        String[] newUserStrings = getUserData(dbUser);
        u.update(new DbUser(userId, newUserStrings[0], newUserStrings[1], newUserStrings[2], newUserStrings[3], birthDate, newUserStrings[4], newUserStrings[5], newUserStrings[6], newUserStrings[7], newUserStrings[8], newUserStrings[9]).toUser());
   }

    @Override
    public void deleteUser(long userId) {
        u.deleteByName(Long.toString(userId));
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
        if (query.startsWith("RNAME:")) {
            //  TODO Nate - implement search based on real name (Story 4.2)

        } else if (query.startsWith("UNAME:")) {
            //  TODO Nate - implement search based on username (Story 4.3)

        } else {
            results = new User[0];
        }
        return results;
    }

    @Override
    public void truncate() {
        handle.execute("TRUNCATE hl_users");
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
        handle.close();
    }
    //Takes users and returns all the Strings of data in an array for quick access.
    private String[] getUserData(DbUser newUserData) {
        String[] data = new String[9];
        data[0] = newUserData.getName();
        data[1] = newUserData.getDisplayName();
        data[2] = newUserData.getBio();
        data[3] = newUserData.getGender();
        data[4] = newUserData.getImageURL().toString();
        data[5] = newUserData.getKnownLanguages();
        data[6] = newUserData.getLearningLanguages();
        data[7] = newUserData.getBlockedUsers();
        data[8] = newUserData.getUsersChattedWith();
        return data;
    }
    class UserMapper implements ResultSetMapper<User> {

        @Override
        public User map(int index, ResultSet r, StatementContext ctx) throws SQLException {
            User user = new User();
            //  TODO Joey - populate User fields from result
            user.setUserId(r.getLong("CHANGEME_COLUMN_NAME"));
            user.setName(r.getString("CHANGEME_COLUMN_NAME"));
            user.setDisplayName(r.getString("CHANGEME_COLUMN_NAME"));
            user.setBio(r.getString("CHANGEME_COLUMN_NAME"));
            user.setGender(Gender.valueOf(r.getString("CHANGEME_COLUMN_NAME")));
            //  etc

            return user;
        }
    }

    public static interface Update
    {
        @SqlUpdate("CREATE TABLE IF NOT EXISTS hl_users(user_id BIGINT, user_name TINYTEXT, display_name TINYTEXT,bio TEXT, gender TEXT, birth_date DATE, image_url LONGTEXT, known_languages LONGTEXT, learning_languages LONGTEXT, blocked_users LONGTEXT, users_chatted_with LONGTEXT, profile_set TINYINT")
        void createTable();

        @SqlUpdate("insert into hl_users (user_id, user_name, display_name, bio, gender, birth_date, image_url, known_languages, learning_lanuages, blocked_users, users_chatted_with, profile_set) values (:user_id, :user_name, :display_name, :bio, :gender, :birth_date, :image_url, :known_languages, :learning_lanuages, :blocked_users, :users_chatted_with)")
        void insert(@BindBean DbUser dbUser);

        @SqlUpdate("update hl_users set user_name = :user_name, display_name = :display_name, bio = :bio, gender = :gender, birth_date = :birth_date, image_url = :image_url, known_languages = :known_languages, learning_lanuages = :learning_lanuages, blocked_users = :blocked_users, users_chatted_with = :users_chatted_with where user_id = :user_id")
        int update(@BindBean User user);

        @SqlUpdate("delete from hl_users where id = :user_id")
        void deleteByName(@Bind String id);
    }
}
