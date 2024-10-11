package com.ssafy.newstock.trading.domain;

import com.ssafy.newstock.kis.domain.TradeItem;
import com.ssafy.newstock.trading.service.TradingHandleService;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

import java.util.HashMap;
import java.util.Map;
import java.util.Queue;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.PriorityBlockingQueue;

@Getter
public class TradeQueue {


    private final Map<String, Queue<TradeItem>> buyQueue=new ConcurrentHashMap<>();
    private final Map<String, Queue<TradeItem>> sellQueue=new ConcurrentHashMap<>();
    private static TradeQueue instance=new TradeQueue();


    public static TradeQueue getInstance() {
        return instance;
    }

    public void addSell(String stockCode, TradeItem tradeItem) {
        if(!sellQueue.containsKey(stockCode)) {
            sellQueue.put(stockCode, new PriorityBlockingQueue<>());
            buyQueue.put(stockCode, new PriorityBlockingQueue<>());
        }
        sellQueue.get(stockCode).add(tradeItem);
    }

    public void addBuy(String stockCode, TradeItem tradeItem) {
        if(!buyQueue.containsKey(stockCode)) {
            buyQueue.put(stockCode, new PriorityBlockingQueue<>());
            sellQueue.put(stockCode, new PriorityBlockingQueue<>());
        }
        buyQueue.get(stockCode).add(tradeItem);
    }


}
