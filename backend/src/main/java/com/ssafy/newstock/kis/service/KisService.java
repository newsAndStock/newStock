package com.ssafy.newstock.kis.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.newstock.kis.domain.ProdToken;
import com.ssafy.newstock.kis.repository.ProdTokenRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import reactor.util.retry.Retry;

import java.time.Duration;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@EnableScheduling
@Service
public class KisService {

    private String token;

    @Value("${kis.prod-appkey}")
    private String appKey;

    @Value("${kis.prod-appsecret}")
    private String appSecret;

    private final WebClient webClient;
    private final ProdTokenRepository prodTokenRepository;

    public KisService(WebClient webClient, ProdTokenRepository prodTokenRepository) {

        this.webClient = webClient;
        this.prodTokenRepository=prodTokenRepository;
    }

    @PostConstruct
    public void initToken() {
        // 서버가 시작될 때 DB에서 토큰 불러오기
        Optional<ProdToken> prodToken = prodTokenRepository.findLatest();
        prodToken.ifPresent(value -> token = value.getValue());
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
                    .retryWhen(Retry.fixedDelay(3, Duration.ofSeconds(5)))
                    .block();


            token = parseResponse(jsonResponse, "access_token");
            prodTokenRepository.save(new ProdToken(token,LocalDate.now()));

        } catch (Exception e) {
            // 예외 발생 시 로그 출력 또는 알림 전송
            System.err.println("Failed to retrieve token at scheduled time: " + e.getMessage());
            // 예외가 발생해도 서버가 중단되지 않도록 조치
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
                .header("authorization", "Bearer " + token)
                .header("appkey", appKey)
                .header("appsecret", appSecret)
                .header("tr_id", "FHKST01010100")
                .retrieve()
                .bodyToMono(String.class)
                .block();

        return parseResponse(jsonResponse,"stck_prpr");
    }
}
