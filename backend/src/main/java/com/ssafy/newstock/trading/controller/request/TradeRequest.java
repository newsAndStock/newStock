package com.ssafy.newstock.trading.controller.request;

import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.trading.domain.OrderType;
import com.ssafy.newstock.trading.domain.TradeType;
import com.ssafy.newstock.trading.domain.Trading;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
public class TradeRequest {

    @NotBlank(message = "종목은 필수")
    private String stockCode;

    private int bid;

    @NotNull(message = "수량은 필수")
    private int quantity;

    private LocalDateTime orderTime;

    public Trading toEntity(Member member, OrderType orderType, TradeType tradeType) {
        return new Trading(stockCode, quantity, bid, orderType, orderTime, member, tradeType);
    }


}
