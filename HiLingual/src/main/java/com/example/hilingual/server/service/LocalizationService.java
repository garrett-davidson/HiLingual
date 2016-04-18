package com.example.hilingual.server.service;

import com.example.hilingual.server.api.Gender;
import io.dropwizard.lifecycle.Managed;

import java.util.Locale;

public interface LocalizationService extends Managed {

    String localize(String key, Locale locale, Gender gender);

    default String localize(String key, Locale locale) {
        return localize(key, locale, Gender.NOT_SET);
    }

    default String localize(String key, long userId) {
        return localize(key, getUserLocale(userId));
    }

    default String localize(String key, long userId, Gender gender) {
        return localize(key, getUserLocale(userId), gender);
    }

    Locale getUserLocale(long userId);

    void setUserLocale(long userId, Locale locale);

}
