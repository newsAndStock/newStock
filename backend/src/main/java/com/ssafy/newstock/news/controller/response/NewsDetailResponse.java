package com.ssafy.newstock.news.controller.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class NewsDetailResponse {
    private String newsId;
    private String title;
    private String content;
    private String createDate;
    private String press;
    private String imageUrl;
}
