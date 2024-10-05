package com.ssafy.newstock.stock.controller.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class StockDetailResponse {
    // 종목정보 / 주식기본조회
    private String marketIdCode;           // 시장 구분
    private String industryCodeName;       // 업종
    private String listingDate;            // 상장일
    private String settlementMonth;        // 결산월
    private String capital;                // 자본금
    private String listedStockCount;       // 상장주식수

    // 종목정보 / 국내주식 손익계산서
    private String salesRevenue;           // 매출액
    private String netIncome;              // 당기순이익

    // 기본시세 / 주식현재가 시세
    private String marketCap;              // 시가총액
    private String previousClosePrice;     // 전일종가
    private String high250Price;           // 250일고가
    private String low250Price;            // 250일저가
    private String yearlyHighPrice;        // 연중고가
    private String yearlyLowPrice;         // 연중저가

    // 종목정보 / 예탁원정보(배당일정)
    private String dividendAmount;         // 배당금
    private String dividendYield;          // 배당수익률
}
