package com.ssafy.newstock.trading.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.ssafy.newstock.kis.service.KisService;
import com.ssafy.newstock.kis.domain.TradeItem;
import com.ssafy.newstock.kis.service.KisServiceSocket;
import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.service.MemberService;
import com.ssafy.newstock.memberstocks.domain.MemberStock;
import com.ssafy.newstock.memberstocks.service.MemberStocksService;
import com.ssafy.newstock.notification.service.NotificationService;
import com.ssafy.newstock.trading.controller.request.TradeRequest;
import com.ssafy.newstock.trading.controller.response.TradeResponse;
import com.ssafy.newstock.trading.domain.OrderType;
import com.ssafy.newstock.trading.domain.TradeQueue;
import com.ssafy.newstock.trading.domain.TradeType;
import com.ssafy.newstock.trading.domain.Trading;
import com.ssafy.newstock.trading.repository.TradingRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Slf4j
@Service
@RequiredArgsConstructor
public class TradingService {

    private final TradingRepository tradingRepository;
    private final KisService kisService;
    //private final ExecutorService executorService = Executors.newFixedThreadPool(2);
    private final TradeQueue tradeQueue=TradeQueue.getInstance();
    private final MemberStocksService memberStocksService;
    private final MemberService memberService;
    private final KisServiceSocket kisServiceSocket;
    private final NotificationService notificationService;

    @PostConstruct
    private void init() throws JsonProcessingException {
        reStartServer();
    }

    //시장가 거래는 거래 즉시 완료됨.
    @Transactional
    public TradeResponse sellByMarket(Member member, TradeRequest sellRequest) {

        sellPossible(member, sellRequest);
        Trading trading = sellRequest.toEntity(member, OrderType.SELL, TradeType.MARKET);
        trading.confirmBid(getStockPrPr(sellRequest.getStockCode()));
        trading.tradeComplete(LocalDateTime.now());
        memberStocksService.sellComplete(member.getId(),sellRequest.getStockCode(),sellRequest.getQuantity(),trading.getBid());
        memberService.updateDeposit(member.getId(),(long)(trading.getBid() * trading.getQuantity()),OrderType.SELL);
        tradingRepository.save(trading);

        CompletableFuture<Void> future=sendTradeMessage(member.getId(),sellRequest.getStockCode(), (long) sellRequest.getQuantity(),OrderType.SELL,trading.getBid());

        return new TradeResponse(OrderType.SELL, trading.getBid(), trading.getOrderCompleteTime(), trading.getQuantity(), trading.getBid() * trading.getQuantity());
    }

    private int getStockPrPr(String stockCode) {
        return Integer.parseInt(kisService.getCurrentStockPrice(stockCode));
    }

    private CompletableFuture<Void> sendTradeMessage(Long receiverId, String stockCode, Long quantity, OrderType orderType, Integer price){
        return CompletableFuture.runAsync(() -> {
            notificationService.send(receiverId,stockCode,quantity,orderType,price);
        });
    }

    private void checkHoldings(Member member, TradeRequest sellRequest){
        long holdings=memberStocksService.getHoldingsByMemberAndStockCode(member.getId(),sellRequest.getStockCode());
        if(holdings<sellRequest.getQuantity()){
            throw new IllegalArgumentException("Holdings not enough");
        }
    }

    @Transactional
    public boolean sellByLimit(Member member, TradeRequest sellRequest) throws JsonProcessingException {

        sellPossible(member, sellRequest);
        Trading trading = sellRequest.toEntity(member, OrderType.SELL, TradeType.LIMIT);

        int marketPrice=getStockPrPr(sellRequest.getStockCode());
        //현재 시장가보다 싸게 올릴수는 없다.
        if(marketPrice>trading.getBid()){
            trading.confirmBid(marketPrice);
        }
        tradingRepository.save(trading);

        log.info("<{}> trading price:{}",sellRequest.getStockCode(),trading.getBid());


        int remain=kisService.getCurrentRemainAboutPrice(sellRequest.getStockCode(),trading.getBid(), OrderType.SELL);

        TradeItem tradeItem=new TradeItem(member,trading.getBid(),trading.getQuantity(),remain,trading.getOrderTime(),trading);

        tradeQueue.addSell(sellRequest.getStockCode(),tradeItem);
        CompletableFuture<Void> future = processWebSocket(sellRequest.getStockCode());
        return true;
    }

    private CompletableFuture<Void> processWebSocket(String stockCode) {

        return CompletableFuture.runAsync(() -> {
            kisServiceSocket.sendMessage(stockCode,"1");
        });
    }


    @Transactional
    public TradeResponse buyByMarket(Member member, TradeRequest buyRequest) {

        if(!buyPossible(member,buyRequest)){
            throw new IllegalArgumentException("Buy not possible(Insufficient account balance)");
        }

        Trading trading = buyRequest.toEntity(member, OrderType.BUY, TradeType.MARKET);
        trading.confirmBid(getStockPrPr(buyRequest.getStockCode()));
        trading.tradeComplete(LocalDateTime.now());
        memberStocksService.buyComplete(member.getId(),buyRequest.getStockCode(),buyRequest.getQuantity(),trading.getBid());
        memberService.updateDeposit(member.getId(),(long)(trading.getBid() * trading.getQuantity()),OrderType.BUY);
        tradingRepository.save(trading);
        notificationService.send(member.getId(),buyRequest.getStockCode(), (long) buyRequest.getQuantity(),OrderType.BUY,trading.getBid());
        return new TradeResponse(OrderType.BUY, trading.getBid(), trading.getOrderCompleteTime(), trading.getQuantity(), trading.getBid() * trading.getQuantity());
    }

    @Transactional
    public void buyByLimit(Member member, TradeRequest buyRequest) throws JsonProcessingException {
        if(!buyPossible(member,buyRequest)){
            throw new IllegalArgumentException("Buy not possible(Insufficient account balance)");
        }

        Trading trading = buyRequest.toEntity(member, OrderType.BUY, TradeType.LIMIT);

        int marketPrice=getStockPrPr(buyRequest.getStockCode());
        //현재 시장가보다 비싸게 살 수는 없다.
        if(marketPrice<trading.getBid()){
            trading.confirmBid(marketPrice);
        }
        tradingRepository.save(trading);
        memberService.updateDeposit(member.getId(), (long) trading.getBid(), OrderType.BUY);
        log.info("<{}> trading price:{}",buyRequest.getStockCode(),trading.getBid());


        int remain=kisService.getCurrentRemainAboutPrice(buyRequest.getStockCode(),trading.getBid(), OrderType.BUY);

        TradeItem tradeItem=new TradeItem(member,trading.getBid(),trading.getQuantity(),remain,trading.getOrderTime(),trading);

        tradeQueue.addBuy(buyRequest.getStockCode(),tradeItem);
        CompletableFuture<Void> future = processWebSocket(buyRequest.getStockCode());


    }

    private boolean buyPossible(Member member, TradeRequest buyRequest) {

        Long deposit=member.getDeposit();

        return (long) buyRequest.getQuantity() *buyRequest.getBid()<=deposit;
    }

    public Trading findById(Long id){
        return tradingRepository.findById(id).orElse(null);
    }

    @Transactional
    public void save(Trading trading){
        tradingRepository.save(trading);
    }

    private void sellPossible(Member member, TradeRequest sellRequest) {
        List<Trading> sellTradings=tradingRepository.findByMemberIdAndStockCodeAndOrderCompleteTimeIsNull(member.getId(), sellRequest.getStockCode());
        int sellQuantity=sellRequest.getQuantity();
        Optional<MemberStock> memberStock=memberStocksService.findByMemberStockByMember_IdAndStockCode(member.getId(), sellRequest.getStockCode());
        if(memberStock.isEmpty()){
            throw new IllegalArgumentException("Sell not possible(해당 보유 주식이 없습니다.)");
        }
        int memberHavingQuantity= (int) memberStock.get().getHoldings();
        int sellTradingsQuantity=0;
        for(Trading trading:sellTradings){
            sellTradingsQuantity+=trading.getQuantity();
        }
        if(sellQuantity>memberHavingQuantity-sellTradingsQuantity){
            throw new IllegalArgumentException("거래할 수 있는 보유주식이 없습니다.(또는 이미 거래중인 주식입니다)");
        }


    }

    private void reStartServer() throws JsonProcessingException {
        List<Trading> tradings = tradingRepository.findByIsCompletedFalseAndIsCanceledFalse();

        for(Trading trading:tradings) {
            log.info("{} 사용자의 {}({}) 거래 재가동",trading.getMember().getNickname(),trading.getStockCode(),trading.getOrderType());
            if(trading.getOrderType().equals(OrderType.SELL)){
                int remain=kisService.getCurrentRemainAboutPrice(trading.getStockCode(),trading.getBid(), OrderType.SELL);
                TradeItem tradeItem=new TradeItem(trading.getMember(),trading.getBid(),trading.getQuantity(),remain,trading.getOrderTime(),trading);
                tradeQueue.addSell(trading.getStockCode(),tradeItem);
                CompletableFuture<Void> future = processWebSocket(trading.getStockCode());
            }else{
                int remain=kisService.getCurrentRemainAboutPrice(trading.getStockCode(),trading.getBid(), OrderType.BUY);
                TradeItem tradeItem=new TradeItem(trading.getMember(),trading.getBid(),trading.getQuantity(),remain,trading.getOrderTime(),trading);
                tradeQueue.addBuy(trading.getStockCode(),tradeItem);
                CompletableFuture<Void> future = processWebSocket(trading.getStockCode());
            }
        }
    }



}
