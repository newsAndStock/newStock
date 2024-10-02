package com.ssafy.newstock.stock.controller;

import com.ssafy.newstock.auth.supports.LoginMember;
import com.ssafy.newstock.stock.controller.response.MinuteStockInfoResponse;
import com.ssafy.newstock.stock.controller.response.StockHoldingsResponse;
import com.ssafy.newstock.stock.controller.response.StockInfoResponse;
import com.ssafy.newstock.stock.service.FetchStockService;
import com.ssafy.newstock.stock.service.StockService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

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

    @GetMapping("/stocks/daily")
    public List<MinuteStockInfoResponse> getDailyStockInfo(@RequestParam String stockCode) {
        return stockService.getDailyStockInfo(stockCode);
    }

    @GetMapping("/stocks/{stockCode}/holdings")
    public StockHoldingsResponse getMemberStockHoldings(@LoginMember Long memberId, @PathVariable String stockCode) {
        return stockService.getMemberStockHoldings(memberId, stockCode);
    }
}
