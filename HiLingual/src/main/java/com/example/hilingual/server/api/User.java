package com.example.hilingual.server.api;
/**
 * Created by joseph on 2/18/16.
 */

import java.net.URL;
import java.util.Date;
import java.util.Locale;
import java.util.Set;

public class User {
    private long uuid;
    private String name;
    private String displayName;
    private String bio;
    private Gender gender;
    private Date birthdate;
    private URL imageURL;
    private Set<Locale> knownlanguages;
    private Set<Locale> learningLanguages;
    private Set<User> blockedUsers;
    private Set<User> usersChattedWith;

    public User(long uuid, String name, String displayName, String bio, Gender gender, Date birthdate,
                URL imageURL, Set<Locale> knownlanguages, Set<Locale> learningLanguages,
                Set<User> blockedUsers, Set<User> usersChattedWith) {
        this.uuid = uuid;
        this.name = name;
        this.displayName = displayName;
        this.bio = bio;
        this.gender = gender;
        this.birthdate = birthdate;
        this.imageURL = imageURL;
        this.knownlanguages = knownlanguages;
        this.learningLanguages = learningLanguages;
        this.blockedUsers = blockedUsers;
        this.usersChattedWith = usersChattedWith;
    }

    public long getUuid() {
        return uuid;
    }

    public String getName() {
        return name;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getBio() {
        return bio;
    }

    public Gender getGender() {
        return gender;
    }

    public Date getBirthdate() {
        return birthdate;
    }

    public URL getImageURL() {
        return imageURL;
    }

    public Set<Locale> getKnownlanguages() {
        return knownlanguages;
    }

    public Set<Locale> getLearningLanguages() {
        return learningLanguages;
    }

    public Set<User> getBlockedUsers() {
        return blockedUsers;
    }

    public Set<User> getUsersChattedWith() {
        return usersChattedWith;
    }

    public void setBirthdate(Date birthdate) {
        this.birthdate = birthdate;
    }

    public void setUuid(long uuid) {
        this.uuid = uuid;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public void setGender(Gender gender) {
        this.gender = gender;
    }

    public void addKnownLanguage(Locale language) {
        knownlanguages.add(language);
    }

    public void removeKnownLanguage(Locale language) {
        knownlanguages.remove(language);
    }

    public void addLearningLanguage(Locale language) {
        learningLanguages.add(language);
    }

    public void removeLearningLanguage(Locale language) {
        learningLanguages.remove(language);
    }

    public void addBlockedUser(User user) {
        blockedUsers.add(user);
    }

    public void removeBlockedUser(User user) {
        blockedUsers.remove(user);
    }

    public void addusersChattedWith(User user) {
        usersChattedWith.add(user);
    }

    public void removeusersChattedWith(User user) {
        usersChattedWith.remove(user);
    }

    public boolean knowsLanguage(Locale locale) {
        return knownlanguages.contains(locale);
    }

    public boolean wantsToLearnLanguage(Locale locale) {
        return learningLanguages.contains(locale);
    }
}

