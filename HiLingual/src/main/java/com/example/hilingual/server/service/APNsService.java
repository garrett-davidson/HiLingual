/*
 * APNsService.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.service;

import io.dropwizard.lifecycle.Managed;

public interface APNsService extends Managed {

    void sendNotification(String token, String payload);

}
