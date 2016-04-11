package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;

public class MessageEdit {

    private long id;
    private String editData;

    public MessageEdit() {
    }

    public MessageEdit(long id, String editData) {
        this.id = id;
        this.editData = editData;
    }

    @JsonProperty
    public long getId() {
        return id;
    }

    @JsonProperty
    public void setId(long id) {
        this.id = id;
    }

    @JsonProperty
    public String getEditData() {
        return editData;
    }

    @JsonProperty
    public void setEditData(String editData) {
        this.editData = editData;
    }
}
