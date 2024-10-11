package com.ssafy.newstock.stock.controller.response;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class StockHoldingsResponse {
    private String stockName;
    private Long holdingsCount;
}
