package com.ssafy.newstock.stock.controller.response;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.Map;

@Getter
@AllArgsConstructor
public class CurrentStockPriceResponse {
    private String stckPrpr; // 주식 현재가
    private String prdyVrss; // 전일 대비
    private String prdyCtrt; // 전일 대비율
    private Map<String, String> askpMap; // 매도 호가, 잔량
    private Map<String, String> bidpMap; // 매수 호가, 잔량
}
