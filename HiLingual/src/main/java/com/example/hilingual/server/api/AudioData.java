package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Base64;

public class AudioData {

    private String audio;

    public AudioData() {
    }

    public AudioData(String audio) {
        this.audio = audio;
    }

    @JsonProperty
    public String getAudio() {
        return audio;
    }

    @JsonProperty
    public void setAudio(String audio) {
        this.audio = audio;
    }

    public byte[] toBytes() {
        return Base64.getDecoder().decode(audio);
    }
}
