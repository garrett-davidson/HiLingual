/*
 * BindUser.java
 * HiLingual - HiLingual
 *
 * Created by nateohlson on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dao.impl.annotation;

import com.example.hilingual.server.api.UserChats;
import org.skife.jdbi.v2.SQLStatement;
import org.skife.jdbi.v2.sqlobject.Binder;
import org.skife.jdbi.v2.sqlobject.BinderFactory;
import org.skife.jdbi.v2.sqlobject.BindingAnnotation;

import static com.example.hilingual.server.dao.impl.ChatMessageDAOImpl.setToString;

import java.lang.annotation.*;
import java.util.function.Function;


@BindingAnnotation(BindUser.BindUserFactory.class)
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.PARAMETER})
public @interface BindUserChats {
    public static class BindUserChatsFactory implements BinderFactory {

        @Override
        public Binder build(Annotation annotation) {
            return new Binder<BindUserChats, UserChats>() {
                @Override
                public void bind(SQLStatement<?> q, BindUserChats bind, UserChats uc) {
                    ///where to bind
                    q.bind("user_id", uc.getUserId());
                    q.bind("pending_chat_users", setToString(uc.getPendingChats(), l -> Long.toString(l)));
                }
            };
        }
    }



}
