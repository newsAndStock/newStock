package com.ssafy.newstock.memberstocks.controller.response;

import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class AssetInfoResponse {

    private String nickname;
    private Long totalPrice;
    private Long deposit;
    private Long profitAndLoss;
    private String ROI;
    private Long rank;
    private String rankSaveTime;


    public AssetInfoResponse(String nickname,Long totalPrice,Long deposit, Long profitAndLoss, String ROI, Long rank,String rankSaveTime){
        this.nickname=nickname;
        this.totalPrice=totalPrice;
        this.deposit=deposit;
        this.profitAndLoss=profitAndLoss;
        this.ROI=ROI;
        this.rank=rank;
        this.rankSaveTime=rankSaveTime;
    }
}
