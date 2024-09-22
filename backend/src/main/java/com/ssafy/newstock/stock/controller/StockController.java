package com.ssafy.newstock.stock.controller;

import com.ssafy.newstock.stock.controller.response.StockInfoResponse;
import com.ssafy.newstock.stock.service.FetchStockService;
import com.ssafy.newstock.stock.service.StockService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class StockController {
    private final FetchStockService fetchStockService;
    private final StockService stockService;

    @PostMapping("/stocks")
    public void saveStockInfo() {
        fetchStockService.processStockData();
    }

    @GetMapping("/stocks")
    public List<StockInfoResponse> getStockInfo(@RequestParam String stockCode, @RequestParam String period) {
        return stockService.getStockInfo(stockCode, period);
    }
}
