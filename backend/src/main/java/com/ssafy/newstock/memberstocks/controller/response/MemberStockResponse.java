package com.ssafy.newstock.memberstocks.controller.response;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class MemberStockResponse {

    private String stockCode;
    private String name;
    private Long currentPrice;
    private Long userPrice;
    private Long quantity;
    private Long profitAndLoss;

    @Builder
    public MemberStockResponse(String stockCode, String name,Long currentPrice, Long userPrice, Long quantity, Long profitAndLoss){
        this.stockCode=stockCode;
        this.name=name;
        this.currentPrice=currentPrice;
        this.userPrice=userPrice;
        this.quantity=quantity;
        this.profitAndLoss=profitAndLoss;
    }
}
