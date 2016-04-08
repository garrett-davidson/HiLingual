package com.example.hilingual.server.service;

import io.dropwizard.lifecycle.Managed;

import java.util.Locale;

public interface MsftTranslateService extends Managed {

    String translate(String text, Locale from, Locale to);

    default String translate(String text, Locale to) {
        return translate(text, null, to);
    }

}
