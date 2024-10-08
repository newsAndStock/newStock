package com.ssafy.newstock.stock.controller.response;

import lombok.Getter;
import lombok.NoArgsConstructor;

import java.text.NumberFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Locale;

@Getter
@NoArgsConstructor
public class StockDetailResponse {
    // 종목정보 / 주식기본조회
    private String marketIdCode;           // 시장 구분
    private String industryCodeName;       // 업종
    private String listingDate;            // 상장일
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

    // 종목정보 / 국내주식 재무비율
    private String PER;
    private String EPS;
    private String PBR;
    private String BPS;
    private String ROE;
    private String ROA;

    public StockDetailResponse(String marketIdCode, String industryCodeName, String listingDate,String capital,
                               String listedStockCount, String salesRevenue, String netIncome, String marketCap,
                               String previousClosePrice, String high250Price, String low250Price, String yearlyHighPrice,
                               String yearlyLowPrice, String dividendAmount, String dividendYield, String PER, String EPS,
                               String PBR, String BPS, String ROE, String ROA) {
        this.marketIdCode = marketIdCode;
        this.industryCodeName = industryCodeName;
        this.listingDate = formatDate(listingDate, DateTimeFormatter.ofPattern("yyyyMMdd"), DateTimeFormatter.ofPattern("yyyy/MM/dd"));
        this.capital = formatNumber(capital);
        this.listedStockCount = formatNumber(listedStockCount);
        this.salesRevenue = formatNumber(salesRevenue);
        this.netIncome = formatNumber(netIncome);
        this.marketCap = formatNumber(marketCap);
        this.previousClosePrice = formatNumber(previousClosePrice);
        this.high250Price = formatNumber(high250Price);
        this.low250Price = formatNumber(low250Price);
        this.yearlyHighPrice = formatNumber(yearlyHighPrice);
        this.yearlyLowPrice = formatNumber(yearlyLowPrice);
        this.dividendAmount = formatNumber(dividendAmount);
        this.dividendYield = formatNumber(dividendYield);
        this.PER = formatNumber(PER);
        this.EPS = formatNumber(EPS);
        this.PBR = formatNumber(PBR);
        this.BPS = formatNumber(BPS);
        this.ROE = formatNumber(ROE);
        this.ROA = formatNumber(ROA);
    }

    private String formatNumber(String value) {
        try {
            return NumberFormat.getInstance(Locale.US).format(Double.parseDouble(value));
        } catch (NumberFormatException e) {
            return value;
        }
    }

    private String formatDate(String dateString, DateTimeFormatter inputFormatter, DateTimeFormatter outputFormatter) {
        try {
            return LocalDate.parse(dateString, inputFormatter).format(outputFormatter);
        } catch (DateTimeParseException e) {
            return "-";
        }
    }
}
