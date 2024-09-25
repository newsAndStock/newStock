package com.ssafy.newstock.kis.service;

import com.ssafy.newstock.kis.domain.SocketItem;
import com.ssafy.newstock.kis.domain.TradeItem;
import com.ssafy.newstock.trading.domain.TradeQueue;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.socket.WebSocketMessage;
import org.springframework.web.reactive.socket.WebSocketSession;
import org.springframework.web.reactive.socket.client.ReactorNettyWebSocketClient;
import reactor.core.publisher.Mono;


import java.net.URI;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Queue;
import java.util.concurrent.CompletableFuture;

@Service
public class KisServiceSocket {

    private static final Logger log = LoggerFactory.getLogger(KisServiceSocket.class);
    private final ReactorNettyWebSocketClient webSocketClient = new ReactorNettyWebSocketClient();
    private final int CURRENT_PRICE_SOCKET_MOUNT = 46;
    private WebSocketSession session;
    private TradeQueue tradeQueue=TradeQueue.getInstance();

    public void connectWebsocket(Runnable onConnected) {
        URI url = URI.create("ws://ops.koreainvestment.com:21000");

        webSocketClient.execute(url, session -> {
            this.session = session;

            // 서버로부터 메시지를 받음
            Mono<Void> input = session.receive()
                    .map(WebSocketMessage::getPayloadAsText)
                    .doOnNext(
                            message->{
                                CompletableFuture.runAsync(()->{
                                    String type =getType(message);
                                    System.out.println("type: "+type);
                                    if(type.equals("H0STCNT0")){
                                        realTimePrice(message);
                                    }
                                });

                                })
                    .then();
            onConnected.run();

            return input;
        }).subscribe(); // 블로킹 호출로 WebSocket 연결 유지
    }


    public void sendMessage(String stockCode, String trType) {
        if(session ==null || !session.isOpen()) {
            System.out.println("웹소켓 연결");
            connectWebsocket(() -> {
                String approvalKey = "9c3c1a5b-54ef-44df-a1fa-e59dab398053";
                String payload = createMessage(approvalKey, stockCode, trType);
                session.send(Mono.just(session.textMessage(payload))).subscribe();
            });
        }
        if (session != null && session.isOpen()) {
            String approvalKey = "9c3c1a5b-54ef-44df-a1fa-e59dab398053";
            String payload = createMessage(approvalKey, stockCode, trType);
            session.send(Mono.just(session.textMessage(payload))).subscribe();
        } else {
            log.warn("WebSocket session is not open or has not been initialized.");
        }
    }

    private void realTimePrice(String message){

            try {
                String stockCode=getStockCode(message);
                dealTrade(message,stockCode);

                Queue<TradeItem> sellItems=tradeQueue.getSellQueue().get(stockCode);
                Queue<TradeItem> buyItems=tradeQueue.getBuyQueue().get(stockCode);
                synchronized (sellItems) {
                    log.info("<{}> 매수 대기인원: {}", stockCode, sellItems.size());
                }

                synchronized (buyItems) {
                    log.info("<{}> 매도 대기인원: {}", stockCode, buyItems.size());
                }

                // 종료 조건 확인
                if (sellItems.isEmpty() && buyItems.isEmpty()) {
                    log.info("<{}> 커넥션 종료", stockCode);
                    sendMessage(stockCode,"2");
                }
            } catch (Exception e) {
                e.printStackTrace(); // 예외 발생 시 출력
            }

    }



    private String createMessage(String approvalKey, String trKey, String trType) {
        return "{\n" +
                "    \"header\": {\n" +
                "        \"approval_key\": \"" + approvalKey + "\",\n" +
                "        \"custtype\": \"P\",\n" +
                "        \"tr_type\": \"" + trType + "\",\n" +
                "        \"content-type\": \"utf-8\"\n" +
                "    },\n" +
                "    \"body\": {\n" +
                "        \"input\": {\n" +
                "            \"tr_id\": \"H0STCNT0\",\n" +
                "            \"tr_key\": \"" + trKey + "\"\n" +
                "        }\n" +
                "    }\n" +
                "}";
    }


    private void dealTrade(String message,String stockCode) throws Exception {

        List<SocketItem> socketItems=parseSocketMessage(message);
        Queue<TradeItem> sellItems=tradeQueue.getSellQueue().get(stockCode);
        Queue<TradeItem> buyItems=tradeQueue.getBuyQueue().get(stockCode);

        log.info("<{}> 제일 우선순위 거래의 잔량: {}",stockCode, sellItems.peek().getRemaining());

        for(SocketItem socketItem: socketItems){
            log.info("<{}> 거래타입: {}, 거래량: {}",stockCode,socketItem.getType(),socketItem.getMount());
            //1이 매수, 5가 매도
            if(socketItem.getType()==1){
                if(sellItems.isEmpty())continue;
                if(socketItem.getPrice()>=sellItems.peek().getBid()){
                    sellItems.peek().trade(socketItem.getMount());
                    if(sellItems.peek().getRemaining()>0)continue;
                    TradeItem complete=sellItems.poll();
                    log.info("<{}> [{}]님 매도거래완료", stockCode, complete.getMember().getNickname());

                }
            } else if (socketItem.getType()==5) {
                if(buyItems.isEmpty())continue;
                if(socketItem.getPrice()==buyItems.peek().getBid()){
                    buyItems.peek().trade(socketItem.getMount());
                    if(buyItems.peek().getRemaining()>0)continue;
                    TradeItem complete=buyItems.poll();
                    log.info("<{}> [{}]님 매수거래완료", stockCode, complete.getMember().getNickname());

                }
            }
        }
    }

    private String getType(String message){
        String[] fields = message.split("\\|");
        return fields[1];
    }

    private String getStockCode(String message){
        String[] fields = message.split("[\\|\\^]");
        return fields[3];
    }

    private List<SocketItem> parseSocketMessage(String message) {


        String[] fields = message.split("\\|");
        if(fields.length==1){
            return Collections.emptyList();
        }
        int dataCount = Integer.parseInt(fields[2]);

        List<String[]> dataList = new ArrayList<>();

        String[] stockDetails = new String[CURRENT_PRICE_SOCKET_MOUNT * dataCount];
        // 데이터 개수만큼 반복해서 데이터 추출
        for (int i = 0; i < dataCount; i++) {
            // 반복된 데이터의 시작 인덱스 계산
            int startIndex = 3;

            // 데이터를 '^'로 분리하여 리스트에 저장
            stockDetails = fields[startIndex].split("\\^");

        }

        List<SocketItem> socketItems = new ArrayList<>();

        for (int i = 0; i < dataCount; i++) {
            int price = Integer.parseInt(stockDetails[2 + CURRENT_PRICE_SOCKET_MOUNT * i]);
            int mount = Integer.parseInt(stockDetails[12 + CURRENT_PRICE_SOCKET_MOUNT * i]);
            int type = Integer.parseInt(stockDetails[21 + CURRENT_PRICE_SOCKET_MOUNT * i]);
            socketItems.add(new SocketItem(price,mount,type));
        }

        return socketItems;
    }
}
