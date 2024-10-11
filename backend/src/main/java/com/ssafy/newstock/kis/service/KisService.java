package com.ssafy.newstock.kis.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.newstock.kis.domain.ProdToken;
import com.ssafy.newstock.kis.domain.ProdToken2;
import com.ssafy.newstock.kis.repository.ProdTokenRepository;
import com.ssafy.newstock.kis.repository.ProdTokenRepository2;
import com.ssafy.newstock.trading.domain.OrderType;
import jakarta.annotation.PostConstruct;
import lombok.Getter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.socket.WebSocketMessage;
import org.springframework.web.reactive.socket.client.ReactorNettyWebSocketClient;
import reactor.core.publisher.Mono;
import reactor.util.retry.Retry;

import java.net.URI;
import java.time.Duration;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Queue;

@EnableScheduling
@Service
@Getter
public class KisService {

    private static final Logger log = LoggerFactory.getLogger(KisService.class);
    private String token;
    private String token2;

    @Value("${kis.prod-appkey}")
    private String appKey;

    @Value("${kis.prod-appsecret}")
    private String appSecret;

    @Value("${kis.prod-appkey2}")
    private String appKey2;

    @Value("${kis.prod-appsecret2}")
    private String appSecret2;

    private final WebClient webClient;
    private final ProdTokenRepository prodTokenRepository;
    private final ProdTokenRepository2 prodTokenRepository2;

    public KisService(WebClient webClient, ProdTokenRepository prodTokenRepository, ProdTokenRepository2 prodTokenRepository2) {

        this.webClient = webClient;
        this.prodTokenRepository=prodTokenRepository;
        this.prodTokenRepository2 = prodTokenRepository2;
    }


    @PostConstruct
    public void initToken() {
        // 서버가 시작될 때 DB에서 토큰 불러오기
        Optional<ProdToken> prodTokens = prodTokenRepository.findLatest();
        // 최신 토큰의 값 가져오기
        prodTokens.ifPresent(prodToken -> token = prodToken.getValue());

        Optional<ProdToken2> prodToken2 = prodTokenRepository2.findLatest();
        prodToken2.ifPresent(value -> token2 = value.getValue());
        System.out.println(prodTokens);
        System.out.println(prodToken2);
    }

    @Scheduled(cron = "0 0 0 * * *")
    private void getProdToken() {
        String url = "/oauth2/tokenP";
        Map<String, String> requestBody = new HashMap<>();
        requestBody.put("grant_type", "client_credentials");
        requestBody.put("appkey", appKey);
        requestBody.put("appsecret", appSecret);

        try {
            String jsonResponse = webClient
                    .post()
                    .uri(url)
                    .bodyValue(requestBody)
                    .retrieve()
                    .onStatus(
                            status -> status.is4xxClientError() || status.is5xxServerError(),
                            clientResponse -> {
                                return clientResponse.createException()
                                        .flatMap(error -> Mono.error(new RuntimeException("Error occurred while calling the API: " + error.getMessage())));
                            }
                    )
                    .bodyToMono(String.class)
                    .timeout(Duration.ofSeconds(10)) // 타임아웃 설정
                    .retryWhen(Retry.fixedDelay(10, Duration.ofSeconds(5)))
                    .block();

            token = parseResponseToken(jsonResponse, "access_token");
            log.info("token: {}, 발급일: {}", token, LocalDate.now());
            prodTokenRepository.save(new ProdToken(token,LocalDate.now()));

        } catch (Exception e) {
            // 예외 발생 시 로그 출력 또는 알림 전송
            System.err.println("Failed to retrieve token at scheduled time: " + e.getMessage());
            // 예외가 발생해도 서버가 중단되지 않도록 조치
        }
    }
    @Scheduled(cron = "0 1 0 * * *")
    private void getProdToken2() {
        String url = "/oauth2/tokenP";
        Map<String, String> requestBody = new HashMap<>();
        requestBody.put("grant_type", "client_credentials");
        requestBody.put("appkey", appKey2);
        requestBody.put("appsecret", appSecret2);

        try {
            String jsonResponse = webClient
                    .post()
                    .uri(url)
                    .bodyValue(requestBody)
                    .retrieve()
                    .onStatus(
                            status -> status.is4xxClientError() || status.is5xxServerError(),
                            clientResponse -> {
                                return clientResponse.createException()
                                        .flatMap(error -> Mono.error(new RuntimeException("Error occurred while calling the API: " + error.getMessage())));
                            }
                    )
                    .bodyToMono(String.class)
                    .timeout(Duration.ofSeconds(10)) // 타임아웃 설정
                    .retryWhen(Retry.fixedDelay(10, Duration.ofSeconds(5)))
                    .block();

            token = parseResponseToken(jsonResponse, "access_token");
            log.info("token2: {}, 발급일: {}", token, LocalDate.now());
            prodTokenRepository2.save(new ProdToken2(token,LocalDate.now()));

        } catch (Exception e) {
            // 예외 발생 시 로그 출력 또는 알림 전송
            System.err.println("Failed to retrieve token at scheduled time: " + e.getMessage());
            // 예외가 발생해도 서버가 중단되지 않도록 조치
        }
    }

    private String parseResponseToken(String jsonResponse, String target) {
        ObjectMapper objectMapper = new ObjectMapper();

        try {
            JsonNode rootNode = objectMapper.readTree(jsonResponse);
            return rootNode.path(target).asText(null);
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse JSON response", e);
        }
    }

    private String parseResponse(String jsonResponse, String target) {
        ObjectMapper objectMapper = new ObjectMapper();

        try {
            JsonNode rootNode = objectMapper.readTree(jsonResponse);
            JsonNode outputNode = rootNode.path("output");
            return outputNode.path(target).asText(null);
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse JSON response", e);
        }
    }

    //주식현재가 시세
    public String getCurrentStockPrice(String stockCode) {

        String url = "/uapi/domestic-stock/v1/quotations/inquire-price";


        String jsonResponse= webClient
                .get()
                .uri(uriBuilder -> uriBuilder
                        .path(url)
                        .queryParam("fid_cond_mrkt_div_code", "J")
                        .queryParam("fid_input_iscd", stockCode)
                        .build())
                .header("authorization", "Bearer " + token2)
                .header("appkey", appKey2)
                .header("appsecret", appSecret2)
                .header("tr_id", "FHKST01010100")
                .retrieve()
                .bodyToMono(String.class)
                .timeout(Duration.ofMillis(800)) // 타임아웃 설정
                .retryWhen(Retry.fixedDelay(5, Duration.ofMillis(800)))
                .block();

        return parseResponse(jsonResponse,"stck_prpr");
    }

    //주식 현재 호가&잔량
    public int getCurrentRemainAboutPrice(String stockCode, int price, OrderType orderType) throws JsonProcessingException {
        String url="/uapi/domestic-stock/v1/quotations/inquire-asking-price-exp-ccn";

        String jsonResponse= webClient
                .get()
                .uri(uriBuilder -> uriBuilder
                        .path(url)
                        .queryParam("fid_cond_mrkt_div_code", "J")
                        .queryParam("fid_input_iscd", stockCode)
                        .build())
                .header("authorization", "Bearer " + token2)
                .header("appkey", appKey2)
                .header("appsecret", appSecret2)
                .header("tr_id", "FHKST01010200")
                .retrieve()
                .bodyToMono(String.class)
                .timeout(Duration.ofMillis(800)) // 타임아웃 설정
                .retryWhen(Retry.fixedDelay(5, Duration.ofMillis(800)))
                .block();

        return getQuantity(jsonResponse,orderType,price);

    }

    public int getQuantity(String jsonString, OrderType orderType, int price) throws JsonProcessingException {
        ObjectMapper objectMapper = new ObjectMapper();
        JsonNode rootNode = objectMapper.readTree(jsonString);

        JsonNode output1 = rootNode.path("output1");

        if (orderType.equals(OrderType.SELL)) {
            for (int i = 1; i <= 10; i++) {
                String askpKey = "askp" + i;
                if (output1.has(askpKey) && output1.get(askpKey).asInt() == price) {
                    // 해당하는 askp_rsqn+숫자의 값을 반환
                    String askpRsqnKey = "askp_rsqn" + i;
                    return output1.get(askpRsqnKey).asInt();
                }
            }
        } else if (orderType.equals(OrderType.BUY)) {
            for (int i = 1; i <= 10; i++) {
                String bidpKey = "bidp" + i;
                if (output1.has(bidpKey) && output1.get(bidpKey).asInt() == price) {
                    String bidpRsqnKey = "bidp_rsqn" + i;
                    return output1.get(bidpRsqnKey).asInt();
                }
            }
        }

        // price를 찾지 못한 경우 예외 처리 또는 기본값 반환
        return 0;
    }




}
