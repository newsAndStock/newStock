package com.ssafy.newstock.memberstocks.controller;

import com.ssafy.newstock.auth.supports.LoginMember;
import com.ssafy.newstock.memberstocks.controller.response.AssetInfoResponse;
import com.ssafy.newstock.memberstocks.controller.response.MemberStockResponse;
import com.ssafy.newstock.memberstocks.service.MemberStocksService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
public class MemberStocksController {

    private final MemberStocksService memberStocksService;

    public MemberStocksController(MemberStocksService memberStocksService){
        this.memberStocksService=memberStocksService;
    }

    @GetMapping("/member-summary")
    public ResponseEntity<AssetInfoResponse> memberStocksInfo(@LoginMember Long memberId){

        AssetInfoResponse assetInfoResponse=memberStocksService.getMemberAssetInfo(memberId);
        return ResponseEntity.status(HttpStatus.OK).body(assetInfoResponse);

    }

    @GetMapping("/stocks-held")
    public ResponseEntity<List<MemberStockResponse>> memberStocksHeld(@LoginMember Long memberId){
        List<MemberStockResponse> stocksHeld=memberStocksService.getMemberStocks(memberId);
        return ResponseEntity.status(HttpStatus.OK).body(stocksHeld);
    }

    @GetMapping("/member/averagePrice")
    public ResponseEntity<Map<String,Long>> memberStocksAveragePrice(@LoginMember Long memberId, @RequestParam String stockCode){
        Map<String,Long> result=new HashMap<>();
        Long averagePrice=memberStocksService.findAveragePriceByStockCodeMemberId(memberId, stockCode);
        result.put("averagePrice",averagePrice);
        return ResponseEntity.status(HttpStatus.OK).body(result);
    }
}
