/*
 * GoogleAccountAPIService.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.service;

public interface GoogleAccountAPIService {

    boolean isValidGoogleSession(String accountId, String token);

}
