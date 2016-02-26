package com.example.hilingual.server.api;
/**
 * Created by joseph on 2/18/16.
 */

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.net.URL;
import java.util.Date;
import java.util.Locale;
import java.util.Set;

public class User {
    private long userId;
    private String name;
    private String displayName;
    private String bio;
    private Gender gender;
    private Date birthdate;
    private URL imageURL;
    private Set<Locale> knownLanguages;
    private Set<Locale> learningLanguages;
    private Set<User> blockedUsers;
    private Set<User> usersChattedWith;
    private boolean profileSet;

    public User(long userId, String name, String displayName, String bio, Gender gender, Date birthdate,
                URL imageURL, Set<Locale> knownLanguages, Set<Locale> learningLanguages,
                Set<User> blockedUsers, Set<User> usersChattedWith, boolean profileSet) {
        this.userId = userId;
        this.name = name;
        this.displayName = displayName;
        this.bio = bio;
        this.gender = gender;
        this.birthdate = birthdate;
        this.imageURL = imageURL;
        this.knownLanguages = knownLanguages;
        this.learningLanguages = learningLanguages;
        this.blockedUsers = blockedUsers;
        this.usersChattedWith = usersChattedWith;
        this.profileSet = profileSet;
    }

    @JsonProperty
    public long getUserId() {
        return userId;
    }

    @JsonProperty
    public String getName() {
        return name;
    }

    @JsonProperty
    public String getDisplayName() {
        return displayName;
    }

    @JsonProperty
    public String getBio() {
        return bio;
    }

    @JsonProperty
    public Gender getGender() {
        return gender;
    }

    @JsonProperty
    public Date getBirthdate() {
        return birthdate;
    }

    @JsonProperty
    public URL getImageURL() {
        return imageURL;
    }

    @JsonProperty
    public Set<Locale> getKnownLanguages() {
        return knownLanguages;
    }

    @JsonProperty
    public Set<Locale> getLearningLanguages() {
        return learningLanguages;
    }

    @JsonProperty
    public Set<User> getBlockedUsers() {
        return blockedUsers;
    }

    @JsonProperty
    public Set<User> getUsersChattedWith() {
        return usersChattedWith;
    }

    @JsonProperty
    public void setBirthdate(Date birthdate) {
        this.birthdate = birthdate;
    }

    @JsonProperty
    public void setUserId(long userId) {
        this.userId = userId;
    }

    @JsonProperty
    public void setName(String name) {
        this.name = name;
    }

    @JsonProperty
    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    @JsonProperty
    public void setBio(String bio) {
        this.bio = bio;
    }

    @JsonProperty
    public void setGender(Gender gender) {
        this.gender = gender;
    }

    @JsonProperty
    public void setImageURL(URL imageURL) {
        this.imageURL = imageURL;
    }

    @JsonIgnore
    public boolean isProfileSet() {
        return profileSet;
    }

    @JsonIgnore
    public void setProfileSet(boolean profileSet) {
        this.profileSet = profileSet;
    }

    @JsonIgnore
    public void addKnownLanguage(Locale language) {
        knownLanguages.add(language);
    }

    @JsonIgnore
    public void removeKnownLanguage(Locale language) {
        knownLanguages.remove(language);
    }

    @JsonIgnore
    public void addLearningLanguage(Locale language) {
        learningLanguages.add(language);
    }

    @JsonIgnore
    public void removeLearningLanguage(Locale language) {
        learningLanguages.remove(language);
    }

    @JsonIgnore
    public void addBlockedUser(User user) {
        blockedUsers.add(user);
    }

    @JsonIgnore
    public void removeBlockedUser(User user) {
        blockedUsers.remove(user);
    }

    @JsonIgnore
    public void addusersChattedWith(User user) {
        usersChattedWith.add(user);
    }

    @JsonIgnore
    public void removeusersChattedWith(User user) {
        usersChattedWith.remove(user);
    }

    @JsonIgnore
    public boolean knowsLanguage(Locale locale) {
        return knownLanguages.contains(locale);
    }

    @JsonIgnore
    public boolean wantsToLearnLanguage(Locale locale) {
        return learningLanguages.contains(locale);
    }
}

