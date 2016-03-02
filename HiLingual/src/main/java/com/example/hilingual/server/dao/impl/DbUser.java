package com.example.hilingual.server.dao.impl; /**
 * Created by joseph on 2/18/16.
 */

import com.example.hilingual.server.api.Gender;
import com.example.hilingual.server.api.User;

import java.net.URL;
import java.text.SimpleDateFormat;
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
        knownLanguages = knownLanguages.substring(1, knownLanguages.length()-1); //remove the beginning and end brackets from string leaving csv format
        learningLanguages = Arrays.toString(user.getLearningLanguages().toArray());
        learningLanguages = learningLanguages.substring(1, learningLanguages.length()-1);//remove...
        blockedUsers = Arrays.toString(user.getBlockedUsers().toArray());
        blockedUsers = blockedUsers.substring(1, blockedUsers.length()-1); // remove
        usersChattedWith = Arrays.toString(user.getUsersChattedWith().toArray());
        usersChattedWith = usersChattedWith.substring(1, usersChattedWith.length()-1); //remove
        if(user.isProfileSet())
            profileSet = "TRUE";
        else
            profileSet = "FALSE";
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
        Long tempUserId this.userId;
        String tempUserName = this.name;
        String tempDisplayName = this.displayName;
        String tempBio = this.bio;
        Gender tempGender;
        if (this.gender.equals("male")) {
            tempGender = Gender.MALE;

        } else if (this.gender.equals("female")) {
            tempGender = Gender.FEMALE;
        } else {
            tempGender = Gender.NOT_SET;
        }
        SimpleDateFormat formatter = new SimpleDateFormat("ddMMyyyy");
        Date tempBirthdate = formatter.parse(this.birthdate);
        URL tempImageURL = new URL(this.imageURL);

        //split the string of known languages with regex ',' because language locale strings are csv
        String[] splitKnownLanguageLocales = this.knownLanguages.split(",");
        Set<Locale> tempKnownLanguages = new HashSet<>();
        for (int i = 0; i < splitKnownLanguageLocales.length; i++) {
            tempKnownLanguages.add(new Locale(splitKnownLanguageLocales[i])); //add each locale to set
        }
        //learning langugages
        String[] splitLearningLanguageLocales = this.learningLanguages.split(",");
        Set<Locale> tempLearningLanguages = new HashSet<>();
        for (int i = 0; i < splitLearningLanguageLocales.length; i++) {
            tempLearningLanguages.add(new Locale(splitLearningLanguageLocales[i])); //add each locale to set
        }
        //blocked users
        String[] splitBlockedUsers = this.blockedUsers.split(".");
        Set<Long> tempBlockedUsers = new HashSet<>();
        for (int i = 0; i < splitBlockedUsers.length; i++) {
            tempBlockedUsers.add(Long.parseLong(splitBlockedUsers[i]));
        }
        //users chatted with
        String[] splitUsersChattedWith = this.usersChattedWith.split(".");
        Set<Long> tempUsersChattedWith = new HashSet<>();
        for (int i = 0; i < splitUsersChattedWith.length; i++) {
            tempUsersChattedWith.add(Long.parseLong(splitUsersChattedWith[i]));
        }

        Boolean tempProfileSet;
        if (this.profileSet.equals("true")) {
            tempProfileSet = Boolean.TRUE;
        } else if (this.profileSet.equals("true")) {
            tempProfileSet = Boolean.FALSE;
        } else {
            //something is fucked
        }

        User returnUser = new User(tempUserId,
                tempUserName,
                tempDisplayName,
                tempBio,
                tempGender,
                tempBirthdate,
                tempImageURL,
                tempKnownLanguages,
                tempLearningLanguages,
                tempBlockedUsers,
                tempUsersChattedWith,
                tempProfileSet);



        return returnUser;
    }
}

