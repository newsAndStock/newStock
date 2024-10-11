package com.ssafy.newstock.stock.controller.response;

import com.ssafy.newstock.stock.domain.StockInfo;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class StockInfoResponse {
    private Long stockInfoId;
    private String date;
    private String highestPrice;
    private String lowestPrice;
    private String openingPrice;
    private String closingPrice;
    private Long volume;

    public static StockInfoResponse from(StockInfo stockInfo) {
        return new StockInfoResponse(stockInfo.getId(), stockInfo.getDate(), stockInfo.getHighestPrice(), stockInfo.getLowestPrice(),
                stockInfo.getOpeningPrice(), stockInfo.getClosingPrice(), stockInfo.getVolume());
    }
}
