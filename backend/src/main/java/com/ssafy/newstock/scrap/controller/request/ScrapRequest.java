package com.ssafy.newstock.scrap.controller.request;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class ScrapRequest {
    private Long scrapId;
    private String content;
}
