/*
 * UserDAO.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dao;

import com.example.hilingual.server.api.User;
import io.dropwizard.lifecycle.Managed;

public interface UserDAO extends Managed {

    void init();

    User getUser(long userId);

    void updateUser(User newUserData);

    void deleteUser(long userId);

    User createUser();

    User[] findUsers(String query, User invoker);

    User[] findMatches(User invoker);

    void truncate();

    boolean isNameUnique(String name);

}
