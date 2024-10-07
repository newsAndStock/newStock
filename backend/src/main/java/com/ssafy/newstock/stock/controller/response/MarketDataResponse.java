package com.ssafy.newstock.stock.controller.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class MarketDataResponse {
    String kospi;
    String kospiPrice;
    String kospiDifference;
    String kospiState;
    String kosdaq;
    String kosdaqPrice;
    String kosdaqDifference;
    String kosdaqState;
    String nasdaq;
    String nasdaqPrice;
    String nasdaqDifference;
    String nasdaqState;
    String sp500;
    String sp500Price;
    String sp500Difference;
    String sp500State;
    String rate;
    String ratePrice;
    String rateDifference;
    String rateState;
    String Date;
}
