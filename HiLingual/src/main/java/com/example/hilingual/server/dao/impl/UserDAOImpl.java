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
        //  TODO Joey - Set up the schema for the user table (Story 1.11)
        handle.execute("CREATE TABLE IF NOT EXISTS hl_users(/* TODO */)");
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
        //  TODO Joey - update row columns with new data (Story 1.14)

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
