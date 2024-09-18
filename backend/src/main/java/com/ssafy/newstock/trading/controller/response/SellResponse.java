package com.ssafy.newstock.trading.controller.response;


import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
public class SellResponse {

    private int bid;

    private LocalDateTime orderCompleteTime;

    private int quantity;

    private int totalPrice;

    public SellResponse(int bid, LocalDateTime orderCompleteTime, int quantity, int totalPrice) {
        this.bid = bid;
        this.orderCompleteTime = orderCompleteTime;
        this.quantity = quantity;
        this.totalPrice = totalPrice;
    }
}
