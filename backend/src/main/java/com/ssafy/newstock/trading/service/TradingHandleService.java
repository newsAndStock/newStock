package com.ssafy.newstock.trading.service;

import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.service.MemberService;
import com.ssafy.newstock.stock.service.StockService;
import com.ssafy.newstock.trading.controller.response.TradingResponse;
import com.ssafy.newstock.trading.domain.OrderType;
import com.ssafy.newstock.trading.domain.Trading;
import com.ssafy.newstock.trading.repository.TradingRepository;
import org.springframework.security.authentication.AuthenticationCredentialsNotFoundException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

@Service
public class TradingHandleService {


    private final TradingRepository tradingRepository;
    private final StockService stockService;
    private final Set<Long> canceledTrading= Collections.synchronizedSet(new HashSet<>());
    private final MemberService memberService;

    public TradingHandleService(TradingRepository tradingRepository, StockService stockService, MemberService memberService) {
        this.tradingRepository = tradingRepository;
        this.stockService = stockService;
        this.memberService = memberService;
    }

    public List<TradingResponse> getActiveTradings(Long memberId) {

        List<Trading> tradings = tradingRepository.findByMemberIdAndIsCompletedFalse(memberId);

        return makeTradingResponses(tradings);

    }

    public List<TradingResponse> getActiveBuyTradings(Long memberId) {
        List<Trading> tradings = tradingRepository.findByMemberIdAndIsCompletedFalseAndOrderTypeAndIsCanceledFalse(memberId, OrderType.BUY);
        return makeTradingResponses(tradings);

    }

    // 매도중인 거래
    public List<TradingResponse> getActiveSellTradings(Long memberId) {
        List<Trading> tradings = tradingRepository.findByMemberIdAndIsCompletedFalseAndOrderTypeAndIsCanceledFalse(memberId, OrderType.SELL);
        return makeTradingResponses(tradings);
    }

    private List<TradingResponse> makeTradingResponses(List<Trading> tradings) {
        List<TradingResponse> tradingResponses = new ArrayList<>();
        for (Trading trading : tradings) {
            String stockCode = trading.getStockCode();
            String name=stockService.findNameByStockCode(stockCode);
            int bid = trading.getBid();
            int quantity = trading.getQuantity();
            OrderType orderType = trading.getOrderType();
            LocalDateTime orderTime = trading.getOrderTime();
            tradingResponses.add(new TradingResponse(trading.getId(),stockCode, name, quantity, bid, orderType, orderTime));
        }
        return tradingResponses;
    }

    public void removeTrading(Long tradingId, Long memberId) {
        canceledTrading.add(tradingId);
        Trading trading=tradingRepository.findById(tradingId).get();
        if(!trading.getMember().getId().equals(memberId)){
            throw new AuthenticationCredentialsNotFoundException("권한이 없습니다.");
        }
        if(trading.getOrderType().equals(OrderType.BUY)){
            memberService.updateDeposit(memberId, (long) trading.getBid(),OrderType.SELL);
        }
        trading.cancelTrading();
        tradingRepository.save(trading);

    }

    public boolean isCanceled(Long tradingId) {
        return canceledTrading.contains(tradingId);
    }

    public void cancelComplete(Long tradingId) {
        canceledTrading.remove(tradingId);
    }

}
