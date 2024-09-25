package com.ssafy.newstock.trading.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.ssafy.newstock.auth.supports.LoginMember;
import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.service.MemberService;
import com.ssafy.newstock.trading.controller.request.SellRequest;
import com.ssafy.newstock.trading.controller.response.SellResponse;
import com.ssafy.newstock.trading.service.TradingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class TradingController {

    private final TradingService tradingService;
    private final MemberService memberService;



    @PostMapping("/sell-market")
    public ResponseEntity<SellResponse> sellByMarket(@Valid @RequestBody SellRequest sellRequest,
                                                     @LoginMember Long memberId) {

        Member member = memberService.findById(memberId);
        SellResponse sellResponse = tradingService.sellByMarket(member, sellRequest);

        return ResponseEntity.status(HttpStatus.CREATED).body(sellResponse);
    }

    @PostMapping("/sell-limit")
    public ResponseEntity<Void> sellByLimit(@Valid @RequestBody SellRequest sellRequest,
                                         @LoginMember Long memberId){
        Member member = memberService.findById(memberId);
        try {
            tradingService.sellByLimit(member, sellRequest);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }

        return ResponseEntity.status(HttpStatus.CREATED).build();
    }







}
