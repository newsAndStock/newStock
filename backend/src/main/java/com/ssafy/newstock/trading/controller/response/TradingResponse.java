package com.ssafy.newstock.trading.controller.response;

import com.ssafy.newstock.trading.domain.OrderType;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
public class TradingResponse {
    private Long id;
    private String stockCode;
    private String name;
    private int quantity;
    private int bid;
    private OrderType orderType;
    private LocalDateTime orderTime;

    public TradingResponse(Long id,String stockCode, String name, int quantity, int bid, OrderType orderType, LocalDateTime orderTime) {
        this.id = id;
        this.stockCode = stockCode;
        this.name = name;
        this.quantity = quantity;
        this.bid = bid;
        this.orderType = orderType;
        this.orderTime = orderTime;
    }
}
