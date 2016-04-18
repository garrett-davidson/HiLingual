package com.example.hilingual.server.resources;

import com.example.hilingual.server.api.Gender;
import com.example.hilingual.server.api.User;
import com.example.hilingual.server.dao.SessionDAO;
import com.example.hilingual.server.dao.UserDAO;
import com.example.hilingual.server.service.LocalizationService;
import com.google.common.net.HttpHeaders;
import io.dropwizard.testing.junit.ResourceTestRule;
import org.assertj.core.api.Assertions;
import org.assertj.core.api.Condition;
import org.junit.*;

import javax.ws.rs.client.Entity;
import java.util.HashSet;

import static org.mockito.Matchers.eq;
import static org.mockito.Mockito.*;

public class UserResourceTest {

    public static final long FRANKIE_ID = 22;
    private static final String JIMMY_TOKEN = "jimmystoken";
    private static final String JIMMY_HLAT = "HLAT " + JIMMY_TOKEN;
    private static final String FRANKIE_TOKEN = "frankiestoken";
    private static final String FRANKIE_HLAT = "HLAT " + FRANKIE_TOKEN;
    private static final long JIMMY_ID = 12;
    public static final String SEARCH_QUERY = "potato";
    private static SessionDAO sessionDAO = mock(SessionDAO.class);
    private static UserDAO userDAO = mock(UserDAO.class);
    private static LocalizationService localizationService = mock(LocalizationService.class);
    @ClassRule
    public static final ResourceTestRule resources = ResourceTestRule.builder().
            addResource(new UserResource(sessionDAO, userDAO, localizationService)).
            build();
    private static User JIMMY = new User(JIMMY_ID, "Jimmy", "jjim", "potato", Gender.MALE, 2000, null,
            new HashSet<>(), new HashSet<>(), new HashSet<>(), new HashSet<>(), true);
    private static User FRANKIE = new User(FRANKIE_ID, "Frankie", "ffrank", "carrot", Gender.MALE, 4000, null,
            new HashSet<>(), new HashSet<>(), new HashSet<>(), new HashSet<>(), true);

    @Before
    public void setUp() throws Exception {
        when(sessionDAO.getSessionOwner(eq(JIMMY_TOKEN))).thenReturn(JIMMY_ID);
        when(sessionDAO.getSessionOwner(eq(FRANKIE_TOKEN))).thenReturn(FRANKIE_ID);
        when(sessionDAO.isValidSession(eq(FRANKIE_TOKEN), eq(FRANKIE_ID))).thenReturn(true);
        when(sessionDAO.isValidSession(eq(JIMMY_TOKEN), eq(JIMMY_ID))).thenReturn(true);

        when(userDAO.getUser(eq(JIMMY_ID))).thenReturn(JIMMY);
        when(userDAO.getUser(eq(FRANKIE_ID))).thenReturn(FRANKIE);
        when(userDAO.findUsers(eq(SEARCH_QUERY), eq(FRANKIE))).thenReturn(new User[] {JIMMY});
        when(userDAO.findMatches(eq(FRANKIE))).thenReturn(new User[] {JIMMY});
    }

    @Test
    public void testGetMe() throws Exception {
        Assertions.assertThat(resources.client().target("/user/me").
                request().
                header(HttpHeaders.AUTHORIZATION, JIMMY_HLAT).
                get(User.class)).isEqualTo(JIMMY);
    }

    @Test
    public void testGetUser() throws Exception {
        Assertions.assertThat(resources.client().target("/user/" + FRANKIE_ID).
                request().
                header(HttpHeaders.AUTHORIZATION, JIMMY_HLAT).
                get(User.class)).isEqualTo(FRANKIE);
    }

    @Test
    public void testUpdateUser() throws Exception {
        User update = new User();
        update.setBio("canada");
        update.setName("potatoooo");
        Assertions.assertThat(resources.client().target("/user/" + FRANKIE_ID).
                request().
                header(HttpHeaders.AUTHORIZATION, FRANKIE_HLAT).
                method("PATCH", Entity.json(update), User.class)).isEqualTo(FRANKIE);
        verify(userDAO).updateUser(FRANKIE);
    }

    @Test
    public void testSearch() throws Exception {
        Assertions.assertThat(resources.client().target("/user/search").
                queryParam("query", SEARCH_QUERY).
                request().
                header(HttpHeaders.AUTHORIZATION, FRANKIE_HLAT).
                get(User[].class)).is(new Condition<User[]>() {
            @Override
            public boolean matches(User[] users) {
                return JIMMY.equals(users[0]);
            }
        });
        verify(userDAO).findUsers(SEARCH_QUERY, FRANKIE);
    }

    @Test
    public void testFindMatches() throws Exception {
        Assertions.assertThat(resources.client().target("/user/match").
                queryParam("query", SEARCH_QUERY).
                request().
                header(HttpHeaders.AUTHORIZATION, FRANKIE_HLAT).
                get(User[].class)).is(new Condition<User[]>() {
            @Override
            public boolean matches(User[] users) {
                return JIMMY.equals(users[0]);
            }
        });
        verify(userDAO).findMatches(FRANKIE);
    }

    @After
    public void tearDown() throws Exception {
        reset(sessionDAO, userDAO);
    }
}
