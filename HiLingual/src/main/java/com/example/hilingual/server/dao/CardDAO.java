package com.example.hilingual.server.dao;

import com.example.hilingual.server.api.flash.CardRing;
import io.dropwizard.lifecycle.Managed;

public interface CardDAO extends Managed {

    CardRing[] getCards(long userId);

    void setCards(CardRing[] rings, long userId);

    void truncate();

}
