package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;

public class TranslationResponse {

    private String translatedContent;
    private long parentMessageId;
    private boolean edit;

    public TranslationResponse() {
    }

    public TranslationResponse(String translatedContent, long parentMessageId, boolean edit) {
        this.translatedContent = translatedContent;
        this.parentMessageId = parentMessageId;
        this.edit = edit;
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

    @JsonProperty
    public boolean isEdit() {
        return edit;
    }

    @JsonProperty
    public void setEdit(boolean edit) {
        this.edit = edit;
    }
}
