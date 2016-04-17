package com.example.hilingual.server.service;

public interface IdentifierService {

    long generateId(int type);

    default long generateId() {
        return generateId(0);
    }

    int TYPE_USER = 1;
    int TYPE_MESSAGE = 2;
    int TYPE_AUDIO = 3;
    int TYPE_IMAGE = 4;

}
