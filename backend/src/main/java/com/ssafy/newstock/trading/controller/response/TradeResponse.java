package com.ssafy.newstock.trading.controller.response;


import com.ssafy.newstock.trading.domain.OrderType;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
public class TradeResponse {

    private int bid;

    private LocalDateTime orderCompleteTime;

    private int quantity;

    private int totalPrice;

    private OrderType orderType;

    public TradeResponse(OrderType orderType, int bid, LocalDateTime orderCompleteTime, int quantity, int totalPrice) {
        this.orderType = orderType;
        this.bid = bid;
        this.orderCompleteTime = orderCompleteTime;
        this.quantity = quantity;
        this.totalPrice = totalPrice;
    }
}
