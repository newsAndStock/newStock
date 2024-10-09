package com.ssafy.newstock.trading.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.ssafy.newstock.auth.supports.LoginMember;
import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.service.MemberService;
import com.ssafy.newstock.notification.service.NotificationService;
import com.ssafy.newstock.trading.controller.request.TradeRequest;
import com.ssafy.newstock.trading.controller.response.TradeResponse;
import com.ssafy.newstock.trading.controller.response.TradingResponse;
import com.ssafy.newstock.trading.domain.Trading;
import com.ssafy.newstock.trading.service.TradingHandleService;
import com.ssafy.newstock.trading.service.TradingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.Parameter;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class TradingController {

    private final TradingService tradingService;
    private final MemberService memberService;
    private final TradingHandleService tradingHandleService;

    @Autowired
    private final NotificationService notificationService;


    @PostMapping("/sell-market")
    public ResponseEntity<TradeResponse> sellByMarket(@Valid @RequestBody TradeRequest sellRequest,
                                                      @LoginMember Long memberId) {

        Member member = memberService.findById(memberId);
        TradeResponse sellResponse = tradingService.sellByMarket(member, sellRequest);

        return ResponseEntity.status(HttpStatus.CREATED).body(sellResponse);
    }

    @PostMapping("/sell-limit")
    public ResponseEntity<Void> sellByLimit(@Valid @RequestBody TradeRequest sellRequest,
                                         @LoginMember Long memberId){
        Member member = memberService.findById(memberId);
        try {
            tradingService.sellByLimit(member, sellRequest);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }

        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @PostMapping("/buy-market")
    @Operation(summary = "Buy Stocks by Market",
            description = "주식을 시장가로 즉시 매수한다. ")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "거래 성공"),
            @ApiResponse(responseCode = "400", description = "거래 실패"),
            @ApiResponse(responseCode = "404", description = "Member not found or stock not available"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public ResponseEntity<TradeResponse> buyByMarket(
            @Parameter(description = "stockCode, quantity, orderTime 을 포함해야 한다.", required = true)
            @Valid @RequestBody TradeRequest buyRequest,
                                                      @LoginMember Long memberId) {

        Member member = memberService.findById(memberId);
        TradeResponse buyResponse = tradingService.buyByMarket(member, buyRequest);

        return ResponseEntity.status(HttpStatus.CREATED).body(buyResponse);
    }

    @PostMapping("/buy-limit")
    public ResponseEntity<Void> buyByLimit(@Valid @RequestBody TradeRequest buyRequest,
                                           @LoginMember Long memberId) {
        Member member = memberService.findById(memberId);
        try {
            tradingService.buyByLimit(member, buyRequest);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
        return ResponseEntity.status(HttpStatus.CREATED).build();

    }

    @GetMapping("/tradings")
    public ResponseEntity<List<TradingResponse>> getTrading(@LoginMember Long memberId) {
        List<TradingResponse> tradings=tradingHandleService.getActiveTradings(memberId);
        return ResponseEntity.status(HttpStatus.OK).body(tradings);
    }

    @GetMapping("/buy-tradings")
    public ResponseEntity<List<TradingResponse>> getTradingBuy(@LoginMember Long memberId) {
        List<TradingResponse> tradings=tradingHandleService.getActiveBuyTradings(memberId);
        return ResponseEntity.status(HttpStatus.OK).body(tradings);
    }

    @GetMapping("/sell-tradings")
    public ResponseEntity<List<TradingResponse>> getTradingSell(@LoginMember Long memberId) {
        List<TradingResponse> tradings=tradingHandleService.getActiveSellTradings(memberId);
        return ResponseEntity.status(HttpStatus.OK).body(tradings);
    }

    @DeleteMapping("/trading")
    public ResponseEntity<Void> deleteTrading(@RequestBody Map<String, Long> requestBody, @LoginMember Long memberId) {
        Long tradingId = requestBody.get("tradingId");
        tradingHandleService.removeTrading(tradingId,memberId);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }

    @DeleteMapping("/admin/clear-tradings")
    public ResponseEntity<Void> clearTrading() {
        tradingHandleService.clearAllTrading();
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }









}
