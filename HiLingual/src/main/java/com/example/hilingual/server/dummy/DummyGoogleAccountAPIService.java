/*
 * DummyGoogleAccountAPIService.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dummy;

import com.example.hilingual.server.service.GoogleAccountAPIService;

public class DummyGoogleAccountAPIService implements GoogleAccountAPIService {
    @Override
    public boolean isValidGoogleSession(String accountId, String token) {
        return true;
    }
}
