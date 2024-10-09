package com.ssafy.newstock.trading.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.ssafy.newstock.kis.domain.TradeItem;
import com.ssafy.newstock.kis.service.KisService;
import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.service.MemberService;
import com.ssafy.newstock.stock.service.StockService;
import com.ssafy.newstock.trading.controller.response.TradingResponse;
import com.ssafy.newstock.trading.domain.OrderType;
import com.ssafy.newstock.trading.domain.TradeQueue;
import com.ssafy.newstock.trading.domain.Trading;
import com.ssafy.newstock.trading.repository.TradingRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.authentication.AuthenticationCredentialsNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CompletableFuture;

@Service
public class TradingHandleService {


    private static final Logger log = LoggerFactory.getLogger(TradingHandleService.class);
    private final TradingRepository tradingRepository;
    private final StockService stockService;
    private final Set<Long> canceledTrading= Collections.synchronizedSet(new HashSet<>());
    private final MemberService memberService;
    private final TradeQueue tradeQueue=TradeQueue.getInstance();
    private final KisService kisService;

    public TradingHandleService(TradingRepository tradingRepository, StockService stockService, MemberService memberService, KisService kisService) {
        this.tradingRepository = tradingRepository;
        this.stockService = stockService;
        this.memberService = memberService;
        this.kisService = kisService;
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

    @Transactional
    @Scheduled(cron = "0 0 16 * * *")
    public void clearAllTrading() {
        log.info("<장 마감, 모든 거래 취소>");
        for(Queue<TradeItem> queue:tradeQueue.getBuyQueue().values()) {
            while(!queue.isEmpty()) {
                TradeItem tradeItem = queue.poll();
                removeTrading(tradeItem.getTrading().getId(), tradeItem.getMember().getId());
                log.info("tradingId:{} 거래삭제",tradeItem.getTrading().getId());
            }
        }

        for(Queue<TradeItem> queue:tradeQueue.getSellQueue().values()) {
            while(!queue.isEmpty()) {
                TradeItem tradeItem = queue.poll();
                removeTrading(tradeItem.getTrading().getId(), tradeItem.getMember().getId());
                log.info("tradingId:{} 거래삭제",tradeItem.getTrading().getId());
            }
        }
    }


}
