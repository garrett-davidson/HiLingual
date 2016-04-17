package com.example.hilingual.server.service.impl;

import org.assertj.core.api.Assertions;
import org.junit.*;

public class IdentifierServiceImplTest {
    @Test
    public void generateId() throws Exception {
        IdentifierServiceImpl identifierService = new IdentifierServiceImpl();
        long id1 = identifierService.generateId();
        Thread.sleep(500);
        long id2 = identifierService.generateId();
        Assertions.assertThat(id2).isGreaterThan(id1);
    }

    @Test
    public void generateId2() throws Exception {
        IdentifierServiceImpl identifierService = new IdentifierServiceImpl();
        long id1 = identifierService.generateId(100);
        long id2 = identifierService.generateId(0);
        Assertions.assertThat(id2).isGreaterThan(id1);
    }

    @Test
    public void generateId3() throws Exception {
        IdentifierServiceImpl identifierService = new IdentifierServiceImpl();
        long id1 = identifierService.generateId();
        long id2 = identifierService.generateId();
        Assertions.assertThat(id2).isGreaterThan(id1);
    }
}
