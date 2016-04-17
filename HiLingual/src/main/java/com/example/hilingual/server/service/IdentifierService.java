package com.example.hilingual.server.service;

public interface IdentifierService {

    long generateId(int type);

    default long generateId() {
        return generateId(0);
    }

}
