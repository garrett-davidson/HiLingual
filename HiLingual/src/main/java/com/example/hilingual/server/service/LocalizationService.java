package com.example.hilingual.server.service;

import io.dropwizard.lifecycle.Managed;

import java.util.Locale;

public interface LocalizationService extends Managed {

    String localize(String key, Locale locale);

    default String localize(String key, long userId) {
        return localize(key, getUserLocale(userId));
    }

    Locale getUserLocale(long userId);

    void setUserLocale(long userId, Locale locale);

}
