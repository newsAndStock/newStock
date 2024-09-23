package com.ssafy.newstock.trading.controller;

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
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class TradingController {

    private final TradingService tradingService;
    private final MemberService memberService;



    @PostMapping("/sell-market")
    public ResponseEntity<SellResponse> sellByMarket(@Valid @RequestBody SellRequest sellRequest,
                                                     @RequestHeader("Authorization") String token) {


        Member member = memberService.findById(1L);
        SellResponse sellResponse = tradingService.sellByMarket(member, sellRequest);

        return ResponseEntity.status(HttpStatus.ACCEPTED).body(sellResponse);
    }




}
