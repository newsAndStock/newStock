package com.ssafy.newstock.stock.controller.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.Map;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class FavoriteStockResponse {
    private String stockCode;
    private String name;
    private String market;
    private String industry;
    private Map<String, String> info;
}
