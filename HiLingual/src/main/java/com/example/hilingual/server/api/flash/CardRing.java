package com.example.hilingual.server.api.flash;

import com.fasterxml.jackson.annotation.JsonProperty;

public class CardRing {

    private String name;
    private Card[] flashcards;

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
    public Card[] getFlashcards() {
        return flashcards;
    }

    @JsonProperty
    public void setFlashcards(Card[] flashcards) {
        this.flashcards = flashcards;
    }

}
