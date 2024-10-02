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
public class NewsResponse {
    private String newsId;
    private String title;
    private String date;
    private String press;
    private String imageUrl;

    public static NewsResponse from(News news) {
        return new NewsResponse(news.getNewsId(), news.getTitle(), news.getDate(), news.getPress(), news.getImageUrl());
    }
}
