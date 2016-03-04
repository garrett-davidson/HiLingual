/*
 * BindUser.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dao.impl.annotation;

import com.example.hilingual.server.api.User;
import org.skife.jdbi.v2.SQLStatement;
import org.skife.jdbi.v2.sqlobject.Binder;
import org.skife.jdbi.v2.sqlobject.BinderFactory;
import org.skife.jdbi.v2.sqlobject.BindingAnnotation;

import java.lang.annotation.*;
import java.util.Date;
import java.util.function.Function;

import static com.example.hilingual.server.dao.impl.UserDAOImpl.setToString;

@BindingAnnotation(BindUser.BindUserFactory.class)
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.PARAMETER})
public @interface BindUser {

    public static class BindUserFactory implements BinderFactory {

        @Override
        public Binder build(Annotation annotation) {
            return new Binder<BindUser, User>() {
                @Override
                public void bind(SQLStatement<?> q, BindUser bind, User arg) {
                    q.bind("user_id", arg.getUserId());
                    q.bind("user_name", arg.getName());
                    q.bind("display_name", arg.getDisplayName());
                    q.bind("bio", arg.getBio());
                    q.bind("gender", arg.getGender());
                    q.bind("birth_date", new Date(arg.getBirthdate()));
                    q.bind("image_url", arg.getImageURL());
                    q.bind("known_languages", setToString(arg.getKnownLanguages(), Function.identity()));
                    q.bind("learning_languages", setToString(arg.getLearningLanguages(), Function.identity()));
                    q.bind("blocked_users", setToString(arg.getBlockedUsers(), l -> Long.toString(l)));
                    q.bind("users_chatted_with", setToString(arg.getUsersChattedWith(), l -> Long.toString(l)));
                    q.bind("profile_set", arg.isProfileSet());
                }
            };
        }
    }

}
