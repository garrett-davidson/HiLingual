package com.example.hilingual.server.api;
/**
 * Created by joseph on 2/18/16.
 */

import com.example.hilingual.server.api.Gender;

import java.net.URL;
import java.util.ArrayList;
import java.util.Date;

public class User {
    private String UUID;
    private String name;
    private String displayName;
    private String bio;
    private Gender gender;
    private Date birthdate;
    private URL imageURL;
    private ArrayList<Language> knownlanguages;
    private ArrayList<Language> learningLanguages;
    private ArrayList<User> blockedUsers;
    private ArrayList<User> usersChattedWith;

    public User(String UUID, String name, String displayName, String bio, Gender gender, Date birthdate,
                URL imageURL, ArrayList<Language> knownlanguages, ArrayList<Language> learningLanguages,
                ArrayList<User> blockedUsers, ArrayList<User> usersChattedWith) {
        this.UUID = UUID;
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

    public String getUUID() {
        return UUID;
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

    public ArrayList<Language> getKnownlanguages() {
        return knownlanguages;
    }

    public ArrayList<Language> getLearningLanguages() {
        return learningLanguages;
    }

    public ArrayList<User> getBlockedUsers() {
        return blockedUsers;
    }

    public ArrayList<User> getUsersChattedWith() {
        return usersChattedWith;
    }

    public void setBirthdate(Date birthdate) {
        this.birthdate = birthdate;
    }

    public void setUUID(String UUID) {
        this.UUID = UUID;
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

    public void addKnownLanguage(Language language) {
        knownlanguages.add(language);
    }

    public void removeKnownLanguage(Language language) {
        knownlanguages.remove(knownlanguages.indexOf(language));
    }

    public void addLearningLanguage(Language language) {
        learningLanguages.add(language);
    }

    public void removeLearningLanguage(Language language) {
        learningLanguages.remove(learningLanguages.indexOf(language));
    }

    public void addBlockedUser(User user) {
        blockedUsers.add(user);
    }

    public void removeBlockedUser(User user) {
        blockedUsers.remove(blockedUsers.indexOf(user));
    }

    public void addusersChattedWith(User user) {
        usersChattedWith.add(user);
    }

    public void removeusersChattedWith(User user) {
        usersChattedWith.remove(usersChattedWith.indexOf(user));
    }
}

