/*
 * BindUser.java
 * HiLingual - HiLingual
 *
 * Created by Vincent Zhang on
 *
 * Copyright © 2016 Team3. All rights reserved.
 */

package com.example.hilingual.server.dao.impl.annotation;

import org.skife.jdbi.v2.sqlobject.Binder;
import org.skife.jdbi.v2.sqlobject.BinderFactory;
import org.skife.jdbi.v2.sqlobject.BindingAnnotation;

import java.lang.annotation.*;

@BindingAnnotation(BindUser.BindUserFactory.class)
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.PARAMETER})
public @interface BindUser {

    public static class BindUserFactory implements BinderFactory {

        @Override
        public Binder build(Annotation annotation) {
            return (q, bind, arg) -> {
                //  TODO
            };
        }
    }

}
