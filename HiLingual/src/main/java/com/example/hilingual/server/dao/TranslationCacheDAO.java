package com.example.hilingual.server.dao;

import java.util.Locale;

public interface TranslationCacheDAO {

    String getCached(Locale target, String source);

    void cache(Locale target, String source, String result);

}
