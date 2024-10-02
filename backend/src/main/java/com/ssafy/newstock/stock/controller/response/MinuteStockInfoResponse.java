package com.ssafy.newstock.stock.controller.response;

import com.ssafy.newstock.stock.domain.MinuteStockInfo;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class MinuteStockInfoResponse {
    private String time;
    private String openingPrice;
    private String closingPrice;
    private String highestPrice;
    private String lowestPrice;
    private Long volume;

    public static MinuteStockInfoResponse from(MinuteStockInfo minuteStockInfo) {
        return new MinuteStockInfoResponse(
                formatTime(minuteStockInfo.getTime()), minuteStockInfo.getOpeningPrice(), minuteStockInfo.getClosingPrice(),
                minuteStockInfo.getHighestPrice(), minuteStockInfo.getLowestPrice(), minuteStockInfo.getVolume()
        );
    }

    private static String formatTime(String time) {
        String hour = time.substring(0, 2);
        String minute = time.substring(2, 4);
        return hour + ":" + minute;
    }
}
