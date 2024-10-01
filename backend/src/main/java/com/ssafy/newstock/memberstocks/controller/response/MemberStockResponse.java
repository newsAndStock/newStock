package com.ssafy.newstock.memberstocks.controller.response;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class MemberStockResponse {

    private Long currentPrice;
    private Long userPrice;
    private Long quantity;
    private Long profitAndLoss;

    @Builder
    public MemberStockResponse(Long currentPrice, Long userPrice, Long quantity, Long profitAndLoss){
        this.currentPrice=currentPrice;
        this.userPrice=userPrice;
        this.quantity=quantity;
        this.profitAndLoss=profitAndLoss;
    }
}
