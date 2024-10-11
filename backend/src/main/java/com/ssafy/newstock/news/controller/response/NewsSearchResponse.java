package com.ssafy.newstock.news.controller.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class NewsSearchResponse {
    private String newsId;
    private String category;
    private String title;
    private String date;
    private String content;
    private String press;
    private String imageUrl;
    private List<String> keywords; // 키워드만 가져오고 싶을 때 사용
}
