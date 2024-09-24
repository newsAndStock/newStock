package com.ssafy.newstock.stock.controller.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class TopVolumeResponse {
    private String stockName;  // 한글 종목명
    private String stockCode;  // 종목 코드
}
