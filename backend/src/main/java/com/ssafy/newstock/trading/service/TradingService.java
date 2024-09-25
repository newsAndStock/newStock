package com.ssafy.newstock.trading.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.ssafy.newstock.kis.service.KisService;
import com.ssafy.newstock.kis.service.KisServiceSocket;
import com.ssafy.newstock.kis.domain.TradeItem;
import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.trading.controller.request.SellRequest;
import com.ssafy.newstock.trading.controller.response.SellResponse;
import com.ssafy.newstock.trading.domain.OrderType;
import com.ssafy.newstock.trading.domain.TradeQueue;
import com.ssafy.newstock.trading.domain.TradeType;
import com.ssafy.newstock.trading.domain.Trading;
import com.ssafy.newstock.trading.repository.TradingRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.Queue;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Slf4j
@Service
@RequiredArgsConstructor
public class TradingService {

    private final TradingRepository tradingRepository;
    private final KisService kisService;
    private final KisServiceSocket kisServiceSocket;
    private final ExecutorService executorService = Executors.newFixedThreadPool(2);
    private final TradeQueue tradeQueue=TradeQueue.getInstance();

    //시장가 거래는 거래 즉시 완료됨.
    public SellResponse sellByMarket(Member member, SellRequest sellRequest) {

        Trading trading = sellRequest.toEntity(member, TradeType.MARKET);
        trading.confirmBid(getStockPrPr(sellRequest.getStockCode()));
        trading.tradeComplete(LocalDateTime.now());
        tradingRepository.save(trading);

        return new SellResponse(trading.getBid(), trading.getOrderCompleteTime(), trading.getQuantity(), trading.getBid() * trading.getQuantity());
    }

    private int getStockPrPr(String stockCode) {
        return Integer.parseInt(kisService.getCurrentStockPrice(stockCode));
    }


    public boolean sellByLimit(Member member, SellRequest sellRequest) throws JsonProcessingException {

        Trading trading = sellRequest.toEntity(member, TradeType.LIMIT);

        int marketPrice=getStockPrPr(sellRequest.getStockCode());
        //현재 시장가보다 싸게 올릴수는 없다.
        if(marketPrice>trading.getBid()){
            trading.confirmBid(marketPrice);
        }

        log.info("<{}> trading price:{}",sellRequest.getStockCode(),trading.getBid());


        int remain=kisService.getCurrentRemainAboutPrice(sellRequest.getStockCode(),trading.getBid(), OrderType.SELL);
        System.out.println("remain:"+remain);
        TradeItem tradeItem=new TradeItem(member,trading.getBid(),trading.getQuantity(),remain,trading.getOrderTime());

        tradeQueue.addSell(sellRequest.getStockCode(),tradeItem);
        CompletableFuture<Void> future = processWebSocket(sellRequest.getStockCode());

        return true;
    }

    private CompletableFuture<Void> processWebSocket(String stockCode) {

        return CompletableFuture.runAsync(() -> {
            kisServiceSocket.sendMessage(stockCode,"1");
        }, executorService);
    }
}
