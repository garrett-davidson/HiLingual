package com.example.hilingual.server.service.impl;

import com.example.hilingual.server.service.IdentifierService;

import java.util.concurrent.atomic.AtomicInteger;

public class IdentifierServiceImpl implements IdentifierService {

    private final AtomicInteger sequenceNumber = new AtomicInteger(0);

    @Override
    public long generateId(int type) {
        int seq = sequenceNumber.getAndIncrement();
        //  IDs consist of, from highest bits to lowest:
        //  48 bit timestamp (millis since UNIX epoch)
        //  8 bit sequence number
        //  8 bit typeId
        long ret = System.currentTimeMillis() << 16;
        ret |= (seq & 0xFF) << 8;
        ret |= type & 0xFF;
        return ret;
    }
}
