package com.ssafy.newstock.trading.controller.response;

import com.ssafy.newstock.trading.domain.OrderType;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
public class TradingResponse {
    private String stockCode;
    private int quantity;
    private int bid;
    private OrderType orderType;
    private LocalDateTime orderTime;

    public TradingResponse(String stockCode, int quantity, int bid, OrderType orderType, LocalDateTime orderTime) {
        this.stockCode = stockCode;
        this.quantity = quantity;
        this.bid = bid;
        this.orderType = orderType;
        this.orderTime = orderTime;
    }
}
