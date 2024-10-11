package com.ssafy.newstock.news.controller.response;

import com.ssafy.newstock.news.domain.News;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class NewsDetailResponse {
    private String newsId;
    private String title;
    private String press;
    private String createDate;
    private String content;
    private String imageUrl;
    private String category;

    public static NewsDetailResponse from(News news) {
        return new NewsDetailResponse(
                news.getNewsId(),
                news.getTitle(),
                news.getPress(),
                news.getDate(),
                news.getContent(),
                news.getImageUrl(),
                news.getCategory()
        );
    }
}
