package com.ssafy.newstock.memberstocks.controller.response;

import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class AssetInfoResponse {

    private Long totalPrice;
    private Long deposit;
    private Long profitAndLoss;
    private String ROI;

    public AssetInfoResponse(Long totalPrice,Long deposit, Long profitAndLoss, String ROI){
        this.totalPrice=totalPrice;
        this.deposit=deposit;
        this.profitAndLoss=profitAndLoss;
        this.ROI=ROI;
    }
}
