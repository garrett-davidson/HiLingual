package com.example.hilingual.server.dao;

        import io.dropwizard.lifecycle.Managed;

        import java.util.Set;

public interface DeviceTokenDAO extends Managed {

    void init();

    void addDeviceToken(long userId, String token);

    void revokeUserDeviceToken(long userId, String token);

    void revokeAllUserDeviceTokens(long userId);

    void truncate();

    Set<String> getUserDeviceTokens(long userId);

}
