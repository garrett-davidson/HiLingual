package com.example.hilingual.server.api;
/**
 * Created by joseph on 2/18/16.
 */

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.*;

public class User {
    private long userId;
    private String name;
    private String displayName;
    private String bio;
    private Gender gender;
    private Date birthdate;
    private URL imageURL;
    private Set<String> knownLanguages;
    private Set<String> learningLanguages;
    private Set<Long> blockedUsers;
    private Set<Long> usersChattedWith;
    private boolean profileSet;

    public User() {
        name = "";
        displayName = "";
        bio = "";
        gender = Gender.NOT_SET;
        birthdate = new Date(0);
        imageURL = url("http://gethilingual.com/assets/noavatar.png");
        knownLanguages = new HashSet<>();
        learningLanguages = new HashSet<>();
        blockedUsers = new HashSet<>();
        usersChattedWith = new HashSet<>();
        profileSet = false;
    }

    public User(long userId, String name, String displayName, String bio, Gender gender, Date birthdate,
                URL imageURL, Set<String> knownLanguages, Set<String> learningLanguages,
                Set<Long> blockedUsers, Set<Long> usersChattedWith, boolean profileSet) {
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
    public Set<String> getKnownLanguages() {
        return knownLanguages;
    }

    @JsonProperty
    public Set<String> getLearningLanguages() {
        return learningLanguages;
    }

    @JsonProperty
    public Set<Long> getBlockedUsers() {
        return blockedUsers;
    }

    @JsonProperty
    public Set<Long> getUsersChattedWith() {
        return usersChattedWith;
    }

    @JsonProperty
    public void setKnownLanguages(Set<String> knownLanguages) {
        this.knownLanguages = knownLanguages;
    }

    @JsonProperty
    public void setLearningLanguages(Set<String> learningLanguages) {
        this.learningLanguages = learningLanguages;
    }

    @JsonProperty
    public void setBlockedUsers(Set<Long> blockedUsers) {
        this.blockedUsers = blockedUsers;
    }

    @JsonProperty
    public void setUsersChattedWith(Set<Long> usersChattedWith) {
        this.usersChattedWith = usersChattedWith;
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
    public void addKnownLanguage(String language) {
        knownLanguages.add(language);
    }

    @JsonIgnore
    public void removeKnownLanguage(String language) {
        knownLanguages.remove(language);
    }

    @JsonIgnore
    public void addLearningLanguage(String language) {
        learningLanguages.add(language);
    }

    @JsonIgnore
    public void removeLearningLanguage(String language) {
        learningLanguages.remove(language);
    }

    @JsonIgnore
    public void addBlockedUser(User user) {
        blockedUsers.add(user.getUserId());
    }

    @JsonIgnore
    public void addBlockedUser(long user) {
        blockedUsers.add(user);
    }

    @JsonIgnore
    public void removeBlockedUser(User user) {
        blockedUsers.remove(user.getUserId());
    }

    @JsonIgnore
    public void removeBlockedUser(long user) {
        blockedUsers.remove(user);
    }

    @JsonIgnore
    public void addusersChattedWith(User user) {
        usersChattedWith.add(user.getUserId());
    }

    @JsonIgnore
    public void addusersChattedWith(long user) {
        usersChattedWith.add(user);
    }

    @JsonIgnore
    public void removeusersChattedWith(User user) {
        usersChattedWith.remove(user.getUserId());
    }

    @JsonIgnore
    public void removeusersChattedWith(long user) {
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


    private static URL url(String url) {
        try {
            return new URL(url);
        } catch (MalformedURLException e) {
            throw new RuntimeException(url);
        }
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        User user = (User) o;
        return userId == user.userId;
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId);
    }
}

