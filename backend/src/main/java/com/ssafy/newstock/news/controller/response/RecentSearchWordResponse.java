package com.ssafy.newstock.news.controller.response;

import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class RecentSearchWordResponse {

    private Long id;
    private String word;

    public RecentSearchWordResponse(Long id, String word) {
        this.id = id;
        this.word = word;
    }
}
