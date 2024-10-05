package com.ssafy.newstock.stock.controller;

import com.ssafy.newstock.auth.supports.LoginMember;
import com.ssafy.newstock.news.controller.response.NewsSearchResponse;
import com.ssafy.newstock.stock.controller.request.SearchKeywordRequest;
import com.ssafy.newstock.stock.controller.response.StockRankingResponse;
import com.ssafy.newstock.stock.domain.Stock;
import com.ssafy.newstock.stock.domain.StockRecentSearchWord;
import com.ssafy.newstock.stock.service.StockMarketIndexService;
import com.ssafy.newstock.stock.service.StockSearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@RestController
@RequiredArgsConstructor
public class StockSearchController {
    private final StockSearchService stockSearchService;
    private final StockMarketIndexService stockMarketIndexService;

    @PostMapping("/recent-stock-keyword")
    public void addRecentKeyword(@RequestBody SearchKeywordRequest request, @LoginMember Long memberId) {
        stockSearchService.addSearchKeyword(memberId, request.getKeyword());
    }

    @GetMapping("/recent-stock-keyword")
    public List<StockRecentSearchWord> getRecentSearchWord(@LoginMember Long memberId){
        return stockSearchService.getRecentSearchKeyword(memberId);
    }

    @DeleteMapping("/recent-stock-keyword/{searchId}")
    public void deleteRecentKeyword(@PathVariable Long searchId){
        stockSearchService.deleteRecentSearchWord(searchId);
    }

    @GetMapping("/stock-ranking")
    public ResponseEntity<?> getTopVolume(@RequestParam String category){
        List<StockRankingResponse> topVolume = null;
        if(Objects.equals(category, "topvolume")){
            topVolume = stockSearchService.getTopVolumeStocksFromRedis();
            return ResponseEntity.ok(topVolume);
        }else if(Objects.equals(category, "topchangestocks")){
            topVolume = stockSearchService.getTopChangeStocksFromRedis();
            return ResponseEntity.ok(topVolume);
        }else if(Objects.equals(category, "bottomchangestocks")){
            topVolume = stockSearchService.getBottomChangeStocksFromRedis();
            return ResponseEntity.ok(topVolume);
        }else if (Objects.equals(category, "topcapitalizationstocks")){
            topVolume = stockSearchService.getCapitalizationStocksFromRedis();
            return ResponseEntity.ok(topVolume);
        } else{
            return ResponseEntity.badRequest().body("카테고리가 잘못되었습니다.");
        }
    }

    @GetMapping("/market-data")
    public ResponseEntity<?> getMarketData(){
        List<Map<String, Object>> marketData = stockMarketIndexService.getMarketData();
        return ResponseEntity.ok(marketData);
    }

    @GetMapping("/stock-search")
    public ResponseEntity<?> getStockSearch(@RequestParam String keyword){
        List<Stock> stocks = stockSearchService.searchStock(keyword);
        if(stocks.isEmpty()){
            return ResponseEntity.ok("검색 결과가 없습니다.");
        }
        return ResponseEntity.ok(stocks);
    }

    @GetMapping("/store-market-data")
    public ResponseEntity<?> getStoreMarketData(){
        stockMarketIndexService.saveStockDataToRedis();
        return ResponseEntity.ok("저장 완료");
    }

    @GetMapping("/stock-news-search")
    public ResponseEntity<?> getNewsSearch(@RequestParam String stockCode){
        Map<String, List<NewsSearchResponse>> stringListMap = stockSearchService.searchNewsForStock(stockCode);
        return ResponseEntity.ok(stringListMap);
    }
}
