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
import org.skife.jdbi.v2.tweak.ResultSetMapper;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.Date;
import java.util.logging.Logger;

public class UserDAOImpl implements UserDAO {


    private final DBI dbi;
    private Handle handle;

    private static Logger LOGGER = Logger.getLogger(UserDAOImpl.class.getName());

    @Inject
    public UserDAOImpl(DBI dbi) {
        this.dbi = dbi;
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
        String name = newUserData.getName();
        String displayName = newUserData.getDisplayName();
        String bio = newUserData.getBio();
        String gender = newUserData.getGender().name();
        Date birthDate = newUserData.getBirthdate();
        String imageURL = newUserData.getImageURL().toString();
        String knownLanguages = Arrays.toString(newUserData.getKnownLanguages().toArray());
        String learningLanguages = Arrays.toString(newUserData.getLearningLanguages().toArray());
        String blockedUsers = Arrays.toString(newUserData.getBlockedUsers().toArray());
        String usersChattedWith = Arrays.toString(newUserData.getUsersChattedWith().toArray());
    }

    @Override
    public void deleteUser(long userId) {
        //  TODO Joey - set the CHANGEME_USER_ID_COLUMN_NAME to the column name you use
        handle.execute("DELETE FROM hl_users WHERE CHANGEME_USER_ID_COLUMN_NAME = ?", userId);
    }

    @Override
    public User createUser() {
        User user = new User();
        //  TODO Joey - create new row and set the userId (Story 1.14)
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
}
