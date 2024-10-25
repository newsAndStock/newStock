package com.ssafy.newstock.keyword.service;

import com.ssafy.newstock.keyword.domain.PopularWord;
import com.ssafy.newstock.keyword.repository.KeyWordRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class KeyWordService {

    private final KeyWordRepository keyWordRepository;

    public KeyWordService(KeyWordRepository keyWordRepository) {
        this.keyWordRepository = keyWordRepository;
    }

    public List<String> getPopularKeywords(String date) {

        return keyWordRepository.findTop10DistinctWordsByDateOrderByCountDesc(date);
    }
}
