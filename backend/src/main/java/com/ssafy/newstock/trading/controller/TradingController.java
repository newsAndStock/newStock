package com.ssafy.newstock.trading.controller;

import com.ssafy.newstock.auth.supports.JwtTokenProvider;
import com.ssafy.newstock.auth.supports.LoginMember;
import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.service.MemberService;
import com.ssafy.newstock.trading.controller.request.SellRequest;
import com.ssafy.newstock.trading.controller.response.SellResponse;
import com.ssafy.newstock.trading.service.TradingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
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
    private final JwtTokenProvider jwtTokenProvider;
    private final MemberService memberService;


    @Operation(summary = "시장가 판매", description = "시장가로 즉시 판매한다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "202", description = "Sell order accepted",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = SellResponse.class))),
            @ApiResponse(responseCode = "400", description = "Invalid request",
                    content = @Content),
            @ApiResponse(responseCode = "401", description = "Unauthorized",
                    content = @Content)
    })
    @PostMapping("/sell-market")
    public ResponseEntity<SellResponse> sellByMarket(@Valid @RequestBody SellRequest sellRequest,
                                                     @LoginMember Long memberId) {

        Member member = memberService.findById(memberId);
        SellResponse sellResponse = tradingService.sellByMarket(member, sellRequest);

        return ResponseEntity.status(HttpStatus.ACCEPTED).body(sellResponse);
    }



}
