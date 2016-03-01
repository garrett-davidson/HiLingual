package com.example.hilingual.server.dao.impl; /**
 * Created by joseph on 2/18/16.
 */

import com.example.hilingual.server.api.User;
import java.util.*;

public class DbUser {
    private long userId;
    private Date birthdate;
    private String name;
    private String displayName;
    private String bio;
    private String gender;
    private String imageURL;
    private String knownLanguages;
    private String learningLanguages;
    private String blockedUsers;
    private String usersChattedWith;
    private String profileSet;
//dbusermmj
    public DbUser(User user) {
        name = user.getName();
        displayName = user.getDisplayName();
        bio = user.getBio();
        gender = user.getGender().name();
        birthdate = user.getBirthdate();
        imageURL = user.getImageURL().toString();
        knownLanguages = Arrays.toString(user.getKnownLanguages().toArray());
        learningLanguages = Arrays.toString(user.getLearningLanguages().toArray());
        blockedUsers = Arrays.toString(user.getBlockedUsers().toArray());
        usersChattedWith = Arrays.toString(user.getUsersChattedWith().toArray());
        if(user.isProfileSet())
            profileSet = "true";
        else
            profileSet = "false";
    }

    public DbUser(long userId, String name, String displayName, String bio, String gender, Date birthdate,
                  String imageURL, String knownLanguages, String learningLanguages,
                  String blockedUsers, String usersChattedWith, String profileSet) {
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

    public long getUserId() {
        return userId;
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

    public String getGender() {
        return gender;
    }

    public Date getBirthdate() {
        return birthdate;
    }

    public String getImageURL() {
        return imageURL;
    }

    public String getKnownLanguages() {
        return knownLanguages;
    }

    public String getLearningLanguages() {
        return learningLanguages;
    }

    public String getBlockedUsers() {
        return blockedUsers;
    }

    public String getUsersChattedWith() {
        return usersChattedWith;
    }

    public void setKnownLanguages(String knownLanguages) {
        this.knownLanguages = knownLanguages;
    }

    public void setLearningLanguages(String learningLanguages) {
        this.learningLanguages = learningLanguages;
    }

    public void setBlockedUsers(String blockedUsers) {
        this.blockedUsers = blockedUsers;
    }

    public void setUsersChattedWith(String usersChattedWith) {
        this.usersChattedWith = usersChattedWith;
    }

    public void setBirthdate(Date birthdate) {
        this.birthdate = birthdate;
    }

    public void setUserId(long userId) {
        this.userId = userId;
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

    public void setGender(String gender) {
        this.gender = gender;
    }

    public void setImageURL(String imageURL) {
        this.imageURL = imageURL;
    }
    public String isProfileSet() {
        return profileSet;
    }

    public void setProfileSet(String profileSet) {
        this.profileSet = profileSet;
    }

    public User toUser() {
        return null;
    }
}

