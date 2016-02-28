/*
 * DummyFacebookGraphAPIService.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dummy;

import com.example.hilingual.server.service.FacebookGraphAPIService;

public class DummyFacebookGraphAPIService implements FacebookGraphAPIService {
    @Override
    public boolean isValidFacebookSession(String accountId, String token) {
        return true;
    }
}
