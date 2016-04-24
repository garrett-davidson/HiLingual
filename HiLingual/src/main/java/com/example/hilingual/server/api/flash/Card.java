package com.example.hilingual.server.api.flash;

import com.fasterxml.jackson.annotation.JsonProperty;

public class Card {

    private String front;
    private String back;

    public Card() {
    }

    @JsonProperty
    public String getBack() {
        return back;
    }

    @JsonProperty
    public void setBack(String back) {
        this.back = back;
    }

    @JsonProperty
    public String getFront() {
        return front;
    }

    @JsonProperty
    public void setFront(String front) {
        this.front = front;
    }
}
