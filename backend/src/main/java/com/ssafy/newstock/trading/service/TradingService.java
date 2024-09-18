package com.ssafy.newstock.trading.service;

import com.ssafy.newstock.kis.service.KisService;
import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.trading.controller.request.SellRequest;
import com.ssafy.newstock.trading.controller.response.SellResponse;
import com.ssafy.newstock.trading.domain.TradeType;
import com.ssafy.newstock.trading.domain.Trading;
import com.ssafy.newstock.trading.repository.TradingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class TradingService {

    private final TradingRepository tradingRepository;
    private final KisService kisService;

    //시장가 거래는 거래 즉시 완료됨.
    public SellResponse sellByMarket(Member member, SellRequest sellRequest) {

        Trading trading = sellRequest.toEntity(member, TradeType.MARKET);
        System.out.println(getStockPrPr(sellRequest.getStockCode()));
        trading.confirmBid(getStockPrPr(sellRequest.getStockCode()));
        trading.tradeComplete(LocalDateTime.now());
        tradingRepository.save(trading);

        return new SellResponse(trading.getBid(), trading.getOrderCompleteTime(), trading.getQuantity(), trading.getBid() * trading.getQuantity());
    }

    private int getStockPrPr(String stockCode) {
        return Integer.parseInt(kisService.getCurrentStockPrice(stockCode));
    }
}
