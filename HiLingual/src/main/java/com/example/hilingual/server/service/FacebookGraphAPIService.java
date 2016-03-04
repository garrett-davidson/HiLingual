/*
 * FacebookAPIService.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.service;

public interface FacebookGraphAPIService {

    boolean isValidFacebookSession(String accountId, String token);

}
