package com.ssafy.newstock.scrap.controller.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class ScrapResponse {
    private Long scrapId;
    private String newsId;
    private String title;
    private String content;
    private LocalDateTime dateTime;
}
