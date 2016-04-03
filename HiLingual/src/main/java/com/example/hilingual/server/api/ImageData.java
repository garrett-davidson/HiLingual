package com.example.hilingual.server.api;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Base64;

public class ImageData {

    private String image;

    public ImageData() {
    }

    public ImageData(String image) {
        this.image = image;
    }

    @JsonProperty
    public String getImage() {
        return image;
    }

    @JsonProperty
    public void setImage(String image) {
        this.image = image;
    }

    public byte[] toBytes() {
        return Base64.getDecoder().decode(image);
    }
}
