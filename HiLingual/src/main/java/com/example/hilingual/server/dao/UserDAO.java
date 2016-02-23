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

public interface UserDAO {

    User getUser(long userId);

    void updateUser(User newUserData);

    void deleteUser(long userId);

    User createUser();

}
