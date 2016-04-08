package com.example.hilingual.server.service.impl.msfttranslate;

import com.example.hilingual.server.config.MsftTranslateConfig;
import com.example.hilingual.server.config.ServerConfig;
import com.example.hilingual.server.service.MsftTranslateService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.net.HttpHeaders;
import com.google.inject.Inject;
import com.mashape.unirest.http.HttpResponse;
import com.mashape.unirest.http.Unirest;
import com.mashape.unirest.http.exceptions.UnirestException;
import org.json.JSONObject;
import org.json.XML;


import javax.ws.rs.core.MediaType;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

public class MsftTranslateServiceImpl implements MsftTranslateService {

    private static final Logger LOGGER = Logger.getLogger(MsftTranslateServiceImpl.class.getName());

    private long tokenExpiryTime = 0;
    private TokenRequestResponse token;
    private MsftTranslateConfig config;

    @Inject
    public MsftTranslateServiceImpl(ServerConfig serverConfig) {
        config = serverConfig.getMsftTranslateConfig();
    }

    @Override
    public String translate(String text, Locale from, Locale to) {
        try {
            Map<String, Object> queryParams = new HashMap<>();
            queryParams.put("appid", "");   //  Required, but leave empty if Authorization header is used
            queryParams.put("text", text);
            if (from != null) {
                queryParams.put("from", from.toLanguageTag());
            }
            queryParams.put("to", to.toLanguageTag());
            queryParams.put("contentType", "text/plain");
            queryParams.put("category", "general");
            HttpResponse<String> ret = Unirest.get("http://api.microsofttranslator.com/V2/Http.svc/Translate").
                    header(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON).
                    queryString(queryParams).
                    header("Authorization", getAuthHeaderValue()).
                    asString();
            String body = ret.getBody();
            JSONObject jso = XML.toJSONObject(body);
            if (jso.has("string")) {
                return jso.getJSONObject("string").getString("content");
            }
            System.out.println("Translation Error: " + body);
            return "T/N ERROR";
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public void start() throws Exception {
        //  Bootstrap & validate
        getAuthHeaderValue();
    }

    @Override
    public void stop() throws Exception {

    }

    private String getAuthHeaderValue() throws IOException {
        if (System.currentTimeMillis() >= tokenExpiryTime || token == null) {
            LOGGER.info("Refreshing MsftTranslate token");
            token = getToken(new TokenRequest(config.getClientId(), config.getClientSecret(),
                    "http://api.microsofttranslator.com/", "client_credentials"));
            //  End it 5 seconds early to give us buffer time
            tokenExpiryTime = System.currentTimeMillis() + TimeUnit.SECONDS.toMillis(token.getExpiresIn() - 5);
            LOGGER.info("Refreshed MsftTranslate token, will expire in " + token.getExpiresIn() + "s");
        }
        return "Bearer " + token.getAccessToken();
    }

    private TokenRequestResponse getToken(TokenRequest request) throws IOException {
        String urlStr = "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13/";
        String charset = StandardCharsets.UTF_8.name();
        HttpResponse<String> ret;
        try {
            ret = Unirest.post(urlStr).
                    header("Content-Type", "application/x-www-form-urlencoded; charset=" + charset).
                    header("Accept-Charset", charset).
                    body(request.toBodyString()).
                    asString();
            if (ret.getStatus() != 200) {
                throw new IOException("Recieved non 200 response: " + ret.getStatus() + ": " + ret.getStatusText());
            }
        } catch (UnirestException e) {
            throw new IOException(e);
        }
        ObjectMapper mapper = new ObjectMapper();
        return mapper.readValue(ret.getBody(), TokenRequestResponse.class);
    }
}
