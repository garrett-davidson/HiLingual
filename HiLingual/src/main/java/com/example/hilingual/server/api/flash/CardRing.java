package com.example.hilingual.server.api.flash;

import com.fasterxml.jackson.annotation.JsonProperty;

public class CardRing {

    private String name;
    private Card[] ring;

    public CardRing() {
    }

    @JsonProperty
    public String getName() {
        return name;
    }

    @JsonProperty
    public void setName(String name) {
        this.name = name;
    }

    @JsonProperty
    public Card[] getRing() {
        return ring;
    }

    @JsonProperty
    public void setRing(Card[] ring) {
        this.ring = ring;
    }

}
