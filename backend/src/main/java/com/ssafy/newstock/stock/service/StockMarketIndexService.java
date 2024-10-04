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
import java.time.Duration;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
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

    public void saveStockDataToRedis() {
        // 날짜 형식을 yyyy-MM-dd로 포맷팅
        String formattedDate = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));

        // NASDAQ 데이터 생성
        Map<String, Object> nasdaqData = new HashMap<>();
        nasdaqData.put("name", "NASDAQ");
        nasdaqData.put("ndxCloseToday", 17918.48);
        nasdaqData.put("price_difference", -6.65);
        nasdaqData.put("fluctuation_rate", -0.04);
        nasdaqData.put("date", formattedDate);

        // SPX 데이터 생성
        Map<String, Object> spxData = new HashMap<>();
        spxData.put("name", "SPX");
        spxData.put("spxCloseToday", 5699.94);
        spxData.put("price_difference", -9.60);
        spxData.put("fluctuation_rate", -0.17);
        spxData.put("date", formattedDate);

        // USD/KRW 데이터 생성
        Map<String, Object> usdkrwData = new HashMap<>();
        usdkrwData.put("name", "USD/KRW");
        usdkrwData.put("usdkrwCloseToday", 1333.80);
        usdkrwData.put("price_difference", -2.20);
        usdkrwData.put("fluctuation_rate", -0.16);
        usdkrwData.put("date", formattedDate);

        // 코스피(KOSPI) 데이터 생성
        Map<String, Object> kospiData = new HashMap<>();
        kospiData.put("name", "KOSPI");
        kospiData.put("kospiCloseToday", 2497.21);
        kospiData.put("price_difference", -5.73);
        kospiData.put("fluctuation_rate", -0.23);
        kospiData.put("date", formattedDate);

        // 코스닥(KOSDAQ) 데이터 생성
        Map<String, Object> kosdaqData = new HashMap<>();
        kosdaqData.put("name", "KOSDAQ");
        kosdaqData.put("kosdaqCloseToday", 829.17);
        kosdaqData.put("price_difference", -2.89);
        kosdaqData.put("fluctuation_rate", -0.35);
        kosdaqData.put("date", formattedDate);

        // 데이터를 Redis에 저장
        redisTemplate.opsForValue().set("kospiData", kospiData);
        redisTemplate.opsForValue().set("kosdaqData", kosdaqData);
        redisTemplate.opsForValue().set("nasdaqData", nasdaqData);
        redisTemplate.opsForValue().set("spxData", spxData);
        redisTemplate.opsForValue().set("usdkrwData", usdkrwData);

        log.info("데이터가 Redis에 저장되었습니다.");
    }

    @Scheduled(cron = "0 0 9 * * ?")
    public void storeNASDAQAndExchangeRate() {
        // API 호출
        String TWELVEDATA_API_URL = "https://api.twelvedata.com/time_series?symbol=SPX,NDX,USD/KRW&interval=1day&apikey=" + TWELVEDATA_API_KEY + "&outputsize=2";
        ResponseEntity<String> response = restTemplate.getForEntity(TWELVEDATA_API_URL, String.class);

        // 현재 날짜 가져오기
        LocalDate currentDate = LocalDate.now();

        // 날짜 형식을 yyyyMMdd로 포맷팅
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        String formattedDate = currentDate.format(formatter);

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
            nasdaqData.put("date", formattedDate);

            // Redis 저장
            String nasdaqKey = "nasdaqData";
            redisTemplate.opsForValue().set(nasdaqKey, objectMapper.writeValueAsString(nasdaqData));
            redisTemplate.expire(nasdaqKey, Duration.ofSeconds(-1));
            log.info("NASDAQ data saved to Redis: " + nasdaqKey);

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
            usdkrwData.put("date", formattedDate);

            // Redis에 저장
            String usdkrwKey = "usdkrwData";
            redisTemplate.opsForValue().set(usdkrwKey, objectMapper.writeValueAsString(usdkrwData));
            redisTemplate.expire(usdkrwKey, Duration.ofSeconds(-1));
            log.info("USD/KRW data saved to Redis: " + usdkrwKey);


            // SPX 데이터 가져오기
            JsonNode SpxValues = root.path("SPX").path("values");
            String SpxCloseToday = SpxValues.get(0).path("close").asText(); // 오늘 종가
            String SpxCloseYesterday = SpxValues.get(1).path("close").asText(); // 어제 종가
            double SpxChange = Double.parseDouble(SpxCloseToday) - Double.parseDouble(SpxCloseYesterday);
            double SpxChangePercent = (SpxChange / Double.parseDouble(SpxCloseYesterday)) * 100;

            // 소수점 2자리에서 반올림 처리
            BigDecimal formattedSpxCloseToday = new BigDecimal(SpxCloseToday).setScale(2, RoundingMode.HALF_UP);
            BigDecimal formattedSpxChange = new BigDecimal(SpxChange).setScale(2, RoundingMode.HALF_UP);
            BigDecimal formattedSpxChangePercent = new BigDecimal(SpxChangePercent).setScale(2, RoundingMode.HALF_UP);


            Map<String, Object> spxData = new HashMap<>();
            spxData.put("name", "SPX");
            spxData.put("spxCloseToday", formattedSpxCloseToday);
            spxData.put("spxChange", formattedSpxChange);
            spxData.put("spxChangePercent", formattedSpxChangePercent);
            spxData.put("date", formattedDate);

            // Redis에 저장
            String spxKey = "spxData";
            redisTemplate.opsForValue().set(spxKey, objectMapper.writeValueAsString(spxData));
            redisTemplate.expire(spxKey, Duration.ofSeconds(-1));
            log.info("SPX data saved to Redis: " + spxKey);


        } catch (Exception e) {
            log.error("나스닥, 환율, SPX 데이터 저장 실패");
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
            redisTemplate.expire(kosdaqKey, Duration.ofSeconds(-1));
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
            redisTemplate.expire(kospiKey, Duration.ofSeconds(-1));
            System.out.println("KOSPI data saved to Redis: " + kospiKey);
            log.info("kospi 데이터 저장 성공");

        } catch (Exception e) {
            e.printStackTrace();
            log.error("코스피, 코스닥 데이터 저장 실패");
        }
    }

    public List<Map<String, Object>> getMarketData(){
        List<Map<String, Object>> result = new ArrayList<>();
        try {
            // 데이터를 Object로 먼저 읽어오기
            Map<String, Object> nasdaqData = (Map<String, Object>) redisTemplate.opsForValue().get("nasdaqData");
            Map<String, Object> usdkrwData = (Map<String, Object>) redisTemplate.opsForValue().get("usdkrwData");
            Map<String, Object> kosdaqData = (Map<String, Object>) redisTemplate.opsForValue().get("kosdaqData");
            Map<String, Object> kospiData = (Map<String, Object>) redisTemplate.opsForValue().get("kospiData");
            Map<String, Object> spxData = (Map<String, Object>) redisTemplate.opsForValue().get("spxData");

            // 결과 리스트에 추가
            result.add(nasdaqData);
            result.add(usdkrwData);
            result.add(kosdaqData);
            result.add(kospiData);
            result.add(spxData);
        } catch (ClassCastException e) {
            log.error("ClassCastException 발생: 데이터 형식이 맞지 않습니다.", e);
        } catch (Exception e) {
            throw new RuntimeException("주가 정보 가져오는데 실패하였습니다", e);
        }
        return result;
    }
}
