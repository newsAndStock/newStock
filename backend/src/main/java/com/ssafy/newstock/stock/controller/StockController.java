package com.ssafy.newstock.stock.controller;

import com.ssafy.newstock.stock.service.StockService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class StockController {
    private final StockService stockService;

    @PostMapping("/stocks")
    public void saveStockInfo() {
        stockService.processStockData();
    }
}
