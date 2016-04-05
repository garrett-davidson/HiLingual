package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Locale;

public class TranslationResponse {

    private String translatedContent;
    private long parentMessageId;

    public TranslationResponse() {
    }

    public TranslationResponse(Locale to, String translatedContent, long parentMessageId) {
        this.translatedContent = translatedContent;
        this.parentMessageId = parentMessageId;
    }

    @JsonProperty
    public String getTranslatedContent() {
        return translatedContent;
    }

    @JsonProperty
    public void setTranslatedContent(String translatedContent) {
        this.translatedContent = translatedContent;
    }

    @JsonProperty
    public long getParentMessageId() {
        return parentMessageId;
    }

    @JsonProperty
    public void setParentMessageId(long parentMessageId) {
        this.parentMessageId = parentMessageId;
    }
}
