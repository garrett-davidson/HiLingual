package com.example.hilingual.server.dao;

import org.assertj.core.api.Assertions;
import org.junit.*;

import javax.ws.rs.NotAuthorizedException;

public class SessionDAOTest {

    private static final String TOKEN = "testtokenpotato";
    private static final String HLAT_PREFIX = "HLAT ";

    @Test
    public void getSessionIdFromHLAT() throws Exception {
        String valid = HLAT_PREFIX + TOKEN;
        Assertions.assertThat(SessionDAO.getSessionIdFromHLAT(valid)).isEqualTo(TOKEN);
    }

    @Test
    public void getSessionIdFromHLATInvalidPrefix() throws Exception {
        String invalid = "potato " + TOKEN;
        Assertions.assertThatThrownBy(() -> SessionDAO.getSessionIdFromHLAT(invalid)).
                isInstanceOf(NotAuthorizedException.class);
    }

    @Test
    public void getSessionIdFromHLATNull() throws Exception {
        Assertions.assertThatThrownBy(() -> SessionDAO.getSessionIdFromHLAT(null)).
                isInstanceOf(NotAuthorizedException.class);
    }

}
