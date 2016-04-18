package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Locale;

public class LocaleSetting {

    private String locale;

    public LocaleSetting(String locale) {
        this.locale = locale;
    }

    public LocaleSetting() {
    }

    public LocaleSetting(Locale locale) {
        setLocale(locale);
    }

    @JsonProperty
    public String getLocale() {
        return locale;
    }

    @JsonProperty
    public void setLocale(String locale) {
        this.locale = locale;
    }

    public Locale getAsLocale() {
        return Locale.forLanguageTag(locale);
    }

    public void setLocale(Locale locale) {
        this.locale = locale.toLanguageTag();
    }
}
