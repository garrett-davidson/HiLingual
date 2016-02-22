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
import java.util.Collections;
import java.util.Date;
import java.util.Locale;

public class DummyUserDAO implements UserDAO {

    private TLongObjectMap<User> users = new TLongObjectHashMap<>();

    public DummyUserDAO() {
        User johnDoe = new User(1, "johndoe", "John Doe", "", Gender.MALE, Date.from(Instant.now()),
                null, Sets.newHashSet(Locale.ENGLISH), Sets.newHashSet(Locale.JAPANESE),
                Collections.emptySet(), Collections.emptySet());
        updateUser(johnDoe);
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
}
