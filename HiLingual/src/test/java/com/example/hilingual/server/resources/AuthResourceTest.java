package com.example.hilingual.server.resources;

import com.example.hilingual.server.api.AuthenticationRequest;
import com.example.hilingual.server.api.AuthenticationResponse;
import com.example.hilingual.server.api.Gender;
import com.example.hilingual.server.api.User;
import com.example.hilingual.server.dao.*;
import com.example.hilingual.server.service.FacebookGraphAPIService;
import com.example.hilingual.server.service.GoogleAccountAPIService;
import com.google.common.net.HttpHeaders;
import io.dropwizard.testing.junit.ResourceTestRule;
import org.assertj.core.api.Assertions;
import org.junit.*;

import javax.ws.rs.client.Entity;
import javax.ws.rs.core.MediaType;
import java.util.HashSet;

import static org.mockito.Matchers.anyLong;
import static org.mockito.Matchers.eq;
import static org.mockito.Mockito.*;

public class AuthResourceTest {

    private static final long USER_ID_FROM_FB = 12;
    private static final long USER_ID_FROM_GO = 22;
    private static final long USER_ID_NEW = 42;

    private static final String VALID_AUTHORITY_ACCOUNT_ID = "testauthorityaccountid";
    private static final String INVALID_AUTHORITY_ACCOUNT_ID = "badtestauthorityaccountid";
    private static final String VALID_AUTHORITY_TOKEN = "valid";
    private static final String INVALID_AUTHORITY_TOKEN = "invalid";
    private static final String SESSION_TOKEN = "testsessiontoken";
    private static final String DEVICE_TOKEN = "devicetoken";

    private static final User newUser = new User(
            USER_ID_NEW, "Joe", "jjoe", "potato", Gender.MALE, 30000L, null,
            new HashSet<>(), new HashSet<>(), new HashSet<>(), new HashSet<>(), false
    );

    private static SessionDAO sessionDAO = mock(SessionDAO.class);
    private static UserDAO userDAO = mock(UserDAO.class);
    private static FacebookIntegrationDAO facebookIntegrationDAO = mock(FacebookIntegrationDAO.class);
    private static GoogleIntegrationDAO googleIntegrationDAO = mock(GoogleIntegrationDAO.class);
    private static FacebookGraphAPIService fbApiService = mock(FacebookGraphAPIService.class);
    private static GoogleAccountAPIService googleApiService = mock(GoogleAccountAPIService.class);
    private static DeviceTokenDAO tokenDAO = mock(DeviceTokenDAO.class);

    @ClassRule
    public static final ResourceTestRule resources = ResourceTestRule.builder().
            addResource(new AuthResource(sessionDAO, userDAO, facebookIntegrationDAO,  googleIntegrationDAO,
                    fbApiService, googleApiService,  tokenDAO)).
            build();


    @Before
    public void setUp() throws Exception {
        when(fbApiService.isValidFacebookSession(eq(VALID_AUTHORITY_ACCOUNT_ID), eq(VALID_AUTHORITY_TOKEN))).
                thenReturn(true);
        when(fbApiService.isValidFacebookSession(eq(INVALID_AUTHORITY_ACCOUNT_ID), eq(VALID_AUTHORITY_TOKEN))).
                thenReturn(false);
        when(fbApiService.isValidFacebookSession(eq(INVALID_AUTHORITY_ACCOUNT_ID), eq(INVALID_AUTHORITY_TOKEN))).
                thenReturn(false);
        when(fbApiService.isValidFacebookSession(eq(VALID_AUTHORITY_ACCOUNT_ID), eq(INVALID_AUTHORITY_TOKEN))).
                thenReturn(false);

        when(googleApiService.isValidGoogleSession(eq(VALID_AUTHORITY_ACCOUNT_ID), eq(VALID_AUTHORITY_TOKEN))).
                thenReturn(true);
        when(googleApiService.isValidGoogleSession(eq(INVALID_AUTHORITY_ACCOUNT_ID), eq(VALID_AUTHORITY_TOKEN))).
                thenReturn(false);
        when(googleApiService.isValidGoogleSession(eq(INVALID_AUTHORITY_ACCOUNT_ID), eq(INVALID_AUTHORITY_TOKEN))).
                thenReturn(false);
        when(googleApiService.isValidGoogleSession(eq(VALID_AUTHORITY_ACCOUNT_ID), eq(INVALID_AUTHORITY_TOKEN))).
                thenReturn(false);

        when(sessionDAO.newSession(anyLong())).thenReturn(SESSION_TOKEN);

        when(userDAO.createUser()).thenReturn(newUser);
    }

    @After
    public void tearDown() throws Exception {
        reset(sessionDAO, userDAO, facebookIntegrationDAO, googleIntegrationDAO,
                fbApiService, googleApiService, tokenDAO);
    }

    @Test
    public void testLoginValidationNullFields() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/login").request().
                post(Entity.json(new AuthenticationRequest(
                        null,
                        null,
                        null,
                        null))).getStatus()).isEqualTo(422);
    }

    @Test
    public void testLoginValidationEmptyFields() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/login").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.FACEBOOK,
                        "",
                        "",
                        null))).getStatus()).isEqualTo(422);
    }

    @Test
    public void testLoginValidationEmptyRequest() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/login").request().
                post(Entity.entity("", MediaType.APPLICATION_JSON_TYPE)).getStatus()).isEqualTo(422);
    }

    @Test
    public void testFacebookLogIn() throws Exception {
        when(facebookIntegrationDAO.getUserIdFromFacebookAccountId(eq(VALID_AUTHORITY_ACCOUNT_ID))).
                thenReturn(USER_ID_FROM_FB);
        AuthenticationResponse expected = new AuthenticationResponse(USER_ID_FROM_FB, SESSION_TOKEN);
        Assertions.assertThat(resources.client().target("/auth/login").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.FACEBOOK,
                        VALID_AUTHORITY_ACCOUNT_ID,
                        VALID_AUTHORITY_TOKEN,
                        DEVICE_TOKEN)), AuthenticationResponse.class)).
                isEqualToComparingFieldByField(expected);
        verify(fbApiService).isValidFacebookSession(VALID_AUTHORITY_ACCOUNT_ID, VALID_AUTHORITY_TOKEN);
        verify(facebookIntegrationDAO).setFacebookToken(USER_ID_FROM_FB, VALID_AUTHORITY_TOKEN);
        verify(tokenDAO).addDeviceToken(USER_ID_FROM_FB, DEVICE_TOKEN);
    }

    @Test
    public void testFacebookLogInBadAcctId() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/login").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.FACEBOOK,
                        INVALID_AUTHORITY_ACCOUNT_ID,
                        VALID_AUTHORITY_TOKEN,
                        DEVICE_TOKEN))).getStatus()).isEqualTo(401);
    }

    @Test
    public void testFacebookLogInBadToken() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/login").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.FACEBOOK,
                        VALID_AUTHORITY_ACCOUNT_ID,
                        INVALID_AUTHORITY_TOKEN,
                        DEVICE_TOKEN))).getStatus()).isEqualTo(401);
    }

    @Test
    public void testFacebookLogInBadAcctIdToken() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/login").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.FACEBOOK,
                        INVALID_AUTHORITY_ACCOUNT_ID,
                        INVALID_AUTHORITY_TOKEN,
                        DEVICE_TOKEN))).getStatus()).isEqualTo(401);
    }

    @Test
    public void testGoogleLogIn() throws Exception {
        when(googleIntegrationDAO.getUserIdFromGoogleAccountId(eq(VALID_AUTHORITY_ACCOUNT_ID))).
                thenReturn(USER_ID_FROM_GO);
        AuthenticationResponse expected = new AuthenticationResponse(USER_ID_FROM_GO, SESSION_TOKEN);
        Assertions.assertThat(resources.client().target("/auth/login").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.GOOGLE,
                        VALID_AUTHORITY_ACCOUNT_ID,
                        VALID_AUTHORITY_TOKEN,
                        DEVICE_TOKEN)), AuthenticationResponse.class)).
                isEqualToComparingFieldByField(expected);
        verify(googleApiService).isValidGoogleSession(VALID_AUTHORITY_ACCOUNT_ID, VALID_AUTHORITY_TOKEN);
        verify(googleIntegrationDAO).setGoogleToken(USER_ID_FROM_GO, VALID_AUTHORITY_TOKEN);
        verify(tokenDAO).addDeviceToken(USER_ID_FROM_GO, DEVICE_TOKEN);
    }

    @Test
    public void testGoogleLogInBadAcctId() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/login").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.GOOGLE,
                        INVALID_AUTHORITY_ACCOUNT_ID,
                        VALID_AUTHORITY_TOKEN,
                        DEVICE_TOKEN))).getStatus()).isEqualTo(401);
    }

    @Test
    public void testGoogleLogInBadToken() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/login").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.GOOGLE,
                        VALID_AUTHORITY_ACCOUNT_ID,
                        INVALID_AUTHORITY_TOKEN,
                        DEVICE_TOKEN))).getStatus()).isEqualTo(401);
    }

    @Test
    public void testGoogleLogInBadAcctIdToken() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/login").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.GOOGLE,
                        INVALID_AUTHORITY_ACCOUNT_ID,
                        INVALID_AUTHORITY_TOKEN,
                        DEVICE_TOKEN))).getStatus()).isEqualTo(401);
    }


    @Test
    public void testRegisterValidationNullFields() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/register").request().
                post(Entity.json(new AuthenticationRequest(
                        null,
                        null,
                        null,
                        null))).getStatus()).isEqualTo(422);
    }

    @Test
    public void testRegisterValidationEmptyFields() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/register").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.FACEBOOK,
                        "",
                        "",
                        null))).getStatus()).isEqualTo(422);
    }

    @Test
    public void testRegisterValidationEmptyRequest() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/register").request().
                post(Entity.entity("", MediaType.APPLICATION_JSON_TYPE)).getStatus()).isEqualTo(422);
    }

    @Test
    public void testFacebookRegister() throws Exception {
        when(facebookIntegrationDAO.getUserIdFromFacebookAccountId(eq(VALID_AUTHORITY_ACCOUNT_ID))).
                thenReturn(0L);
        AuthenticationResponse expected = new AuthenticationResponse(newUser.getUserId(), SESSION_TOKEN);
        Assertions.assertThat(resources.client().target("/auth/register").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.FACEBOOK,
                        VALID_AUTHORITY_ACCOUNT_ID,
                        VALID_AUTHORITY_TOKEN,
                        DEVICE_TOKEN)), AuthenticationResponse.class)).
                isEqualToComparingFieldByField(expected);
        verify(fbApiService).isValidFacebookSession(VALID_AUTHORITY_ACCOUNT_ID, VALID_AUTHORITY_TOKEN);
        verify(facebookIntegrationDAO).setFacebookToken(newUser.getUserId(), VALID_AUTHORITY_TOKEN);
        verify(facebookIntegrationDAO).setUserIdForFacebookAccountId(newUser.getUserId(), VALID_AUTHORITY_ACCOUNT_ID);
        verify(tokenDAO).addDeviceToken(newUser.getUserId(), DEVICE_TOKEN);
        verify(userDAO).createUser();
    }

    @Test
    public void testFacebookRegisterBadAcctId() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/register").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.FACEBOOK,
                        INVALID_AUTHORITY_ACCOUNT_ID,
                        VALID_AUTHORITY_TOKEN,
                        DEVICE_TOKEN))).getStatus()).isEqualTo(401);
    }

    @Test
    public void testFacebookRegisterBadToken() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/register").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.FACEBOOK,
                        VALID_AUTHORITY_ACCOUNT_ID,
                        INVALID_AUTHORITY_TOKEN,
                        DEVICE_TOKEN))).getStatus()).isEqualTo(401);
    }

    @Test
    public void testFacebookRegisterBadAcctIdToken() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/register").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.FACEBOOK,
                        INVALID_AUTHORITY_ACCOUNT_ID,
                        INVALID_AUTHORITY_TOKEN,
                        DEVICE_TOKEN))).getStatus()).isEqualTo(401);
    }

    @Test
    public void testGoogleRegister() throws Exception {
        when(googleIntegrationDAO.getUserIdFromGoogleAccountId(eq(VALID_AUTHORITY_ACCOUNT_ID))).
                thenReturn(0L);
        AuthenticationResponse expected = new AuthenticationResponse(USER_ID_NEW, SESSION_TOKEN);
        Assertions.assertThat(resources.client().target("/auth/register").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.GOOGLE,
                        VALID_AUTHORITY_ACCOUNT_ID,
                        VALID_AUTHORITY_TOKEN,
                        DEVICE_TOKEN)), AuthenticationResponse.class)).
                isEqualToComparingFieldByField(expected);
        verify(googleApiService).isValidGoogleSession(VALID_AUTHORITY_ACCOUNT_ID, VALID_AUTHORITY_TOKEN);
        verify(googleIntegrationDAO).setGoogleToken(newUser.getUserId(), VALID_AUTHORITY_TOKEN);
        verify(googleIntegrationDAO).setUserIdForGoogleAccountId(newUser.getUserId(), VALID_AUTHORITY_ACCOUNT_ID);
        verify(tokenDAO).addDeviceToken(newUser.getUserId(), DEVICE_TOKEN);
        verify(userDAO).createUser();
    }

    @Test
    public void testGoogleRegisterBadAcctId() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/register").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.GOOGLE,
                        INVALID_AUTHORITY_ACCOUNT_ID,
                        VALID_AUTHORITY_TOKEN,
                        DEVICE_TOKEN))).getStatus()).isEqualTo(401);
    }

    @Test
    public void testGoogleRegisterBadToken() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/register").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.GOOGLE,
                        VALID_AUTHORITY_ACCOUNT_ID,
                        INVALID_AUTHORITY_TOKEN,
                        DEVICE_TOKEN))).getStatus()).isEqualTo(401);
    }

    @Test
    public void testGoogleRegisterBadAcctIdToken() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/register").request().
                post(Entity.json(new AuthenticationRequest(
                        AuthenticationRequest.Authority.GOOGLE,
                        INVALID_AUTHORITY_ACCOUNT_ID,
                        INVALID_AUTHORITY_TOKEN,
                        DEVICE_TOKEN))).getStatus()).isEqualTo(401);
    }

    @Test
    public void testLogout() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/12/logout").request().
                header(HttpHeaders.AUTHORIZATION, "HLAT " + SESSION_TOKEN).
                post(null).getStatus()).isEqualTo(204);
        verify(sessionDAO).revokeSession(SESSION_TOKEN, 12);
    }

    @Test
    public void testLogoutWithToken() throws Exception {
        Assertions.assertThat(resources.client().target("/auth/12/logout").
                queryParam("device-token", DEVICE_TOKEN).
                request().
                header(HttpHeaders.AUTHORIZATION, "HLAT " + SESSION_TOKEN).
                post(null).getStatus()).isEqualTo(204);
        verify(sessionDAO).revokeSession(SESSION_TOKEN, 12);
        verify(tokenDAO).revokeUserDeviceToken(12, DEVICE_TOKEN);
    }
}
