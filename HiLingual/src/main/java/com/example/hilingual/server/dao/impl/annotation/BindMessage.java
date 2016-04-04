/*
 * BindUser.java
 * HiLingual - HiLingual
 *
 * Created by nateohlson on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */


package com.example.hilingual.server.dao.impl.annotation;


import com.example.hilingual.server.api.Message;
import org.skife.jdbi.v2.SQLStatement;
import org.skife.jdbi.v2.sqlobject.Binder;
import org.skife.jdbi.v2.sqlobject.BinderFactory;
import org.skife.jdbi.v2.sqlobject.BindingAnnotation;

import java.lang.annotation.*;
import java.sql.JDBCType;
import java.sql.Timestamp;


@BindingAnnotation(BindMessage.BindMessageFactory.class)
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.PARAMETER})
public @interface BindMessage {
    public static class BindMessageFactory implements BinderFactory {


        @Override
        public Binder build(Annotation annotation) {
            return new Binder<BindMessage, Message>() {
                @Override
                public void bind(SQLStatement<?> q, BindMessage bind, Message arg) {

                    q.bind("message_id", arg.getId());
                    Long  sentts =  arg.getSentTimestamp();
                    System.out.println("Send Timestamp: " + sentts);
                    if (sentts == 0) {
                        q.bindNull("sent_timestamp", JDBCType.TIMESTAMP.getVendorTypeNumber());
                    } else {
                        q.bind("sent_timestamp", new Timestamp(arg.getSentTimestamp()));
                    }
                    Long  editts =  arg.getEditTimestamp();
                    System.out.println("Edit timestamp: " + editts);
                    if (editts == 0) {
                        q.bindNull("edit_timestamp", JDBCType.TIMESTAMP.getVendorTypeNumber());
                    } else {
                        q.bind("edit_timestamp", new Timestamp(arg.getEditTimestamp()));
                    }
                    q.bind("sender_id", arg.getSender());
                    q.bind("receiver_id", arg.getReceiver());
                    q.bind("message", arg.getContent());
                    q.bind("edited_message", arg.getEditData());

                }
            };
        }


    }
}
