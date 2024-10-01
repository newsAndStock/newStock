package com.ssafy.newstock.news.controller.response;

import com.ssafy.newstock.news.domain.News;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class NewsRecentResponse {
    private String newsId;
    private String title;
    private String imageUrl;

    public static NewsRecentResponse from(News news) {
        return new NewsRecentResponse(news.getNewsId(), news.getTitle(), news.getImageUrl());
    }
}
