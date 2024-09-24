package com.ssafy.newstock.stock.controller.request;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class SearchKeywordRequest {
    private Long memberId;
    private String keyword;
}
