/*
 * DummyUserDAO.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dummy;

import com.example.hilingual.server.api.Gender;
import com.example.hilingual.server.api.User;
import com.example.hilingual.server.dao.UserDAO;
import com.google.common.collect.Sets;
import gnu.trove.map.TLongObjectMap;
import gnu.trove.map.hash.TLongObjectHashMap;

import java.time.Instant;
import java.util.Date;
import java.util.Locale;

public class DummyUserDAO implements UserDAO {

    private TLongObjectMap<User> users = new TLongObjectHashMap<>();
    public static final User JOHN_DOE = new User(1, "johndoe", "John Doe", "", Gender.MALE, Date.from(Instant.now()),
            null, Sets.newHashSet(Locale.ENGLISH), Sets.newHashSet(Locale.JAPANESE),
            Sets.newHashSet(), Sets.newHashSet());

    public DummyUserDAO() {
        updateUser(JOHN_DOE);
    }

    @Override
    public User getUser(long userId) {
        return users.get(userId);
    }

    @Override
    public void updateUser(User newUserData) {
        users.put(newUserData.getUuid(), newUserData);
    }

    @Override
    public void deleteUser(long userId) {
        users.remove(userId);
    }

    @Override
    public User createUser() {
        User user = new User(users.size() + 1, "", "", "", Gender.NOT_SET, new Date(1), null,
                Sets.newHashSet(), Sets.newHashSet(),
                Sets.newHashSet(), Sets.newHashSet());
        users.put(user.getUuid(), user);
        return user;
    }
}
