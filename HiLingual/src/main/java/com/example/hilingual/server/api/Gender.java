package com.example.hilingual.server.api;

/**
 * Created by joseph on 2/18/16.
 */
public enum Gender {
    MALE(".m"), FEMALE(".f"), NOT_SET("");

    private final String localizationSuffix;

    Gender(String localizationSuffix) {
        this.localizationSuffix = localizationSuffix;
    }

    public String getLocalizationSuffix() {
        return localizationSuffix;
    }
}
