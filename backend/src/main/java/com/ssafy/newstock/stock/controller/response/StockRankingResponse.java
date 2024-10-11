package com.ssafy.newstock.stock.controller.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class StockRankingResponse implements Comparable<StockRankingResponse> {
    private String stockName;  // 한글 종목명
    private String stockCode;  // 종목 코드
    private String currentPrice;
    private String priceChangeRate; // 변동 비율
    private String priceChangeAmount; //변동 가격
    private String priceChangeSign; //변동 여부

    @Override
    public int compareTo(StockRankingResponse o) {
        return (int)(Double.parseDouble(this.priceChangeRate) - Double.parseDouble(o.priceChangeRate));
    }
}
