package com.ssafy.newstock.stock.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.client.utils.URIBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URI;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

//주가지수
@Service
@RequiredArgsConstructor
@Slf4j
public class StockMarketIndexService {
    @Value("${twelvedata.api.key}")
    private String TWELVEDATA_API_KEY;
    @Value("${marketindex.api.key}")
    private String KOSPI_KOSDAQ_API_KEY;
    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    private final RedisTemplate<String, Object> redisTemplate;

    @Scheduled(cron = "0 0 9 * * ?")
    public void storeNASDAQAndExchangeRate() {
        // API 호출
        String TWELVEDATA_API_URL = "https://api.twelvedata.com/time_series?symbol=NDX,USD/KRW&interval=1day&apikey=" + TWELVEDATA_API_KEY + "&outputsize=2";
        ResponseEntity<String> response = restTemplate.getForEntity(TWELVEDATA_API_URL, String.class);
        try {
            // JSON 파싱
            JsonNode root = objectMapper.readTree(response.getBody());

            // NASDAQ (NDX) 데이터 가져오기
            JsonNode ndxValues = root.path("NDX").path("values");
            String ndxCloseToday = ndxValues.get(0).path("close").asText(); // 오늘 종가
            String ndxCloseYesterday = ndxValues.get(1).path("close").asText(); // 어제 종가
            double ndxChange = Double.parseDouble(ndxCloseToday) - Double.parseDouble(ndxCloseYesterday);
            double ndxChangePercent = (ndxChange / Double.parseDouble(ndxCloseYesterday)) * 100;

            // 소수점 2자리에서 반올림 처리
            BigDecimal formattedNdxCloseToday = new BigDecimal(ndxCloseToday).setScale(2, RoundingMode.HALF_UP);
            BigDecimal formattedNdxChange = new BigDecimal(ndxChange).setScale(2, RoundingMode.HALF_UP);
            BigDecimal formattedNdxChangePercent = new BigDecimal(ndxChangePercent).setScale(2, RoundingMode.HALF_UP);

            Map<String, Object> nasdaqData = new HashMap<>();
            nasdaqData.put("name", "NASDAQ");
            nasdaqData.put("ndxCloseToday", formattedNdxCloseToday);
            nasdaqData.put("ndxChange", formattedNdxChange);
            nasdaqData.put("ndxChangePercent", formattedNdxChangePercent);

            // Redis 저장
            String nasdaqKey = "nasdaqData";
            redisTemplate.opsForValue().set(nasdaqKey, objectMapper.writeValueAsString(nasdaqData));
            System.out.println("NASDAQ data saved to Redis: " + nasdaqKey);

            // USD/KRW 데이터 가져오기
            JsonNode usdkrwValues = root.path("USD/KRW").path("values");
            String usdkrwCloseToday = usdkrwValues.get(0).path("close").asText(); // 오늘 종가
            String usdkrwCloseYesterday = usdkrwValues.get(1).path("close").asText(); // 어제 종가
            double usdkrwChange = Double.parseDouble(usdkrwCloseToday) - Double.parseDouble(usdkrwCloseYesterday);
            double usdkrwChangePercent = (usdkrwChange / Double.parseDouble(usdkrwCloseYesterday)) * 100;

            // 소수점 2자리에서 반올림 처리
            BigDecimal formattedUsdkrwCloseToday = new BigDecimal(usdkrwCloseToday).setScale(2, RoundingMode.HALF_UP);
            BigDecimal formattedUsdkrwChange = new BigDecimal(usdkrwChange).setScale(2, RoundingMode.HALF_UP);
            BigDecimal formattedUsdkrwChangePercent = new BigDecimal(usdkrwChangePercent).setScale(2, RoundingMode.HALF_UP);


            Map<String, Object> usdkrwData = new HashMap<>();
            usdkrwData.put("name", "USD/KRW");
            usdkrwData.put("usdkrwCloseToday", formattedUsdkrwCloseToday);
            usdkrwData.put("usdkrwChange", formattedUsdkrwChange);
            usdkrwData.put("usdkrwChangePercent", formattedUsdkrwChangePercent);

            // Redis에 저장
            String usdkrwKey = "usdkrwData";
            redisTemplate.opsForValue().set(usdkrwKey, objectMapper.writeValueAsString(usdkrwData));
            System.out.println("USD/KRW data saved to Redis: " + usdkrwKey);


        } catch (Exception e) {
            log.error("나스닥, 환율 데이터 저장 실패");
        }
    }

    // 1시간마다 스케줄링 작업 실행
    @Scheduled(cron = "0 0 9 * * ?")
    public void storeKospiAndKosdaqData() {
        String kosdaqUrl = "https://apis.data.go.kr/1160100/service/GetMarketIndexInfoService/getStockMarketIndex";
        String kospiUrl = "https://apis.data.go.kr/1160100/service/GetMarketIndexInfoService/getStockMarketIndex";
        try {
            // 코스닥 저장
            // 코스닥 URI 생성
            URI kosdaqUri = new URIBuilder(kosdaqUrl)
                    .addParameter("serviceKey", KOSPI_KOSDAQ_API_KEY)  // 환경 변수에서 가져온 API 키
                    .addParameter("resultType", "json")
                    .addParameter("numOfRows", "2")
                    .addParameter("idxNm", "코스닥")
                    .build();

            // 코스피 URI 생성
            URI kospiUri = new URIBuilder(kospiUrl)
                    .addParameter("serviceKey", KOSPI_KOSDAQ_API_KEY)
                    .addParameter("resultType", "json")
                    .addParameter("numOfRows", "2")
                    .addParameter("idxNm", "코스피")
                    .build();

            ResponseEntity<String> responseKosdaq = restTemplate.getForEntity(kosdaqUri, String.class);

            JsonNode kosdaqRoot = objectMapper.readTree(responseKosdaq.getBody());
            JsonNode kosdaqItems = kosdaqRoot.path("response").path("body").path("items").path("item").get(0);


            Map<String, Object> kosdaqData = new HashMap<>();
            kosdaqData.put("name", "KOSDAQ");
            kosdaqData.put("date", kosdaqItems.path("basDt").asText());
            kosdaqData.put("kosdaqCloseToday", kosdaqItems.path("clpr").asText());
            kosdaqData.put("price_difference", kosdaqItems.path("vs").asText());
            kosdaqData.put("fluctuation_rate", kosdaqItems.path("fltRt").asText());

            String kosdaqKey = "kosdaqData";
            redisTemplate.opsForValue().set(kosdaqKey, objectMapper.writeValueAsString(kosdaqData));
            System.out.println("KOSDAQ data saved to Redis: " + kosdaqKey);
            log.info("kosdaq 데이터 저장 성공");

            // 코스피 저장
            ResponseEntity<String> responseKospi = restTemplate.getForEntity(kospiUri, String.class);
            JsonNode kospiRoot = objectMapper.readTree(responseKospi.getBody());
            JsonNode kospiItems = kospiRoot.path("response").path("body").path("items").path("item").get(0);

            Map<String, Object> kospiData = new HashMap<>();
            kospiData.put("name", "KOSPI");
            kospiData.put("date", kospiItems.path("basDt").asText());
            kospiData.put("kospiCloseToday", kospiItems.path("clpr").asText());
            kospiData.put("price_difference", kospiItems.path("vs").asText());
            kospiData.put("fluctuation_rate", kospiItems.path("fltRt").asText());

            String kospiKey = "kospiData";
            redisTemplate.opsForValue().set(kospiKey, objectMapper.writeValueAsString(kospiData));
            System.out.println("KOSPI data saved to Redis: " + kospiKey);
            log.info("kospi 데이터 저장 성공");

        } catch (Exception e) {
            e.printStackTrace();
            log.error("코스피, 코스닥 데이터 저장 실패");
        }
    }

    public List<Map<String, String>> getMarketData(){
        List<Map<String, String>> result = new ArrayList<>();
        try {
            String nasdaqDataJson = (String) redisTemplate.opsForValue().get("nasdaqData");
            String usdkrwDataJson = (String) redisTemplate.opsForValue().get("usdkrwData");
            String kosdaqDataJson = (String) redisTemplate.opsForValue().get("kosdaqData");
            String kospiDataJson = (String) redisTemplate.opsForValue().get("kospiData");

            Map<String, String> nasdaqData = objectMapper.readValue(nasdaqDataJson, new TypeReference<Map<String, String>>() {});
            Map<String, String> usdkrwData = objectMapper.readValue(usdkrwDataJson, new TypeReference<Map<String, String>>() {});
            Map<String, String> kosdaqData = objectMapper.readValue(kosdaqDataJson, new TypeReference<Map<String, String>>() {});
            Map<String, String> kospiData = objectMapper.readValue(kospiDataJson, new TypeReference<Map<String, String>>() {});

            result.add(nasdaqData);
            result.add(usdkrwData);
            result.add(kosdaqData);
            result.add(kospiData);
        } catch (Exception e) {
            throw new RuntimeException("주가 정보 가져오는데 실패하였습니다");
        }
        return result;
    }
}
