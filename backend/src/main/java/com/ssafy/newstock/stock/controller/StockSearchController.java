package com.ssafy.newstock.stock.controller;

import com.ssafy.newstock.auth.supports.LoginMember;
import com.ssafy.newstock.stock.controller.request.SearchKeywordRequest;
import com.ssafy.newstock.stock.controller.response.TopVolumeResponse;
import com.ssafy.newstock.stock.domain.Stock;
import com.ssafy.newstock.stock.domain.StockRecentSearchWord;
import com.ssafy.newstock.stock.service.StockSearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class StockSearchController {
    private final StockSearchService stockSearchService;

    @PostMapping("/recent-stock-keyword")
    public void addRecentKeyword(@RequestBody SearchKeywordRequest request){
        stockSearchService.addSearchKeyword(request.getMemberId(), request.getKeyword());
    }

    @GetMapping("/recent-stock-keyword")
    public List<StockRecentSearchWord> getRecentSearchWord(@LoginMember Long memberId){
        return stockSearchService.getRecentSearchKeyword(memberId);
    }

    @DeleteMapping("/recent-stock-keyword/{searchId}")
    public void deleteRecentKeyword(@PathVariable Long searchId){
        stockSearchService.deleteRecentSearchWord(searchId);
    }

    @GetMapping("/top-volume")
    public List<TopVolumeResponse> getTopVolume(){
        return stockSearchService.getTopVolume();
    }

    @GetMapping("stock-search")
    public List<Stock> getTopVolume(@RequestParam String keyword){
        return stockSearchService.searchStock(keyword);
    }
}
