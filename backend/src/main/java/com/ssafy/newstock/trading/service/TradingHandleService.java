package com.ssafy.newstock.trading.service;

import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.trading.controller.response.TradingResponse;
import com.ssafy.newstock.trading.domain.OrderType;
import com.ssafy.newstock.trading.domain.Trading;
import com.ssafy.newstock.trading.repository.TradingRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class TradingHandleService {


    private final TradingRepository tradingRepository;

    public TradingHandleService(TradingRepository tradingRepository) {
        this.tradingRepository = tradingRepository;
    }

    public List<TradingResponse> getActiveTradings(Long memberId) {

        List<Trading> tradings = tradingRepository.findByMemberIdAndIsCompletedFalse(memberId);

        return makeTradingResponses(tradings);

    }

    public List<TradingResponse> getActiveBuyTradings(Long memberId) {
        List<Trading> tradings = tradingRepository.findByMemberIdAndIsCompletedFalseAndOrderType(memberId, OrderType.BUY);
        return makeTradingResponses(tradings);

    }

    // 매도중인 거래
    public List<TradingResponse> getActiveSellTradings(Long memberId) {
        List<Trading> tradings = tradingRepository.findByMemberIdAndIsCompletedFalseAndTradeType(memberId, OrderType.SELL);
        return makeTradingResponses(tradings);
    }

    private List<TradingResponse> makeTradingResponses(List<Trading> tradings) {
        List<TradingResponse> tradingResponses = new ArrayList<>();
        for (Trading trading : tradings) {
            String stockCode = trading.getStockCode();
            int bid = trading.getBid();
            int quantity = trading.getQuantity();
            OrderType orderType = trading.getOrderType();
            LocalDateTime orderTime = trading.getOrderTime();
            tradingResponses.add(new TradingResponse(stockCode, quantity, bid, orderType, orderTime));
        }
        return tradingResponses;
    }

}
