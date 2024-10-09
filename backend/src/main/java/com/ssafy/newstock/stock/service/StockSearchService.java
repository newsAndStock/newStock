package com.ssafy.newstock.stock.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.newstock.common.util.WebClientUtil;
import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.repository.MemberRepository;
import com.ssafy.newstock.news.controller.response.NewsSearchResponse;
import com.ssafy.newstock.news.repository.NewsRepositoryQuerydsl;
import com.ssafy.newstock.stock.controller.response.CacheEntry;
import com.ssafy.newstock.stock.controller.response.MarketDataResponse;
import com.ssafy.newstock.stock.controller.response.StockRankingResponse;
import com.ssafy.newstock.stock.domain.Stock;
import com.ssafy.newstock.stock.domain.StockRecentSearchWord;
import com.ssafy.newstock.stock.repository.StockRecentSearchWordRepository;
import com.ssafy.newstock.stock.repository.StockRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class StockSearchService {
    private final StockRecentSearchWordRepository recentSearchWordRepository;
    private final MemberRepository memberRepository;
    private final ObjectMapper objectMapper;
    private final WebClientUtil webClientUtil;
    private final StockRepository stockRepository;
    private final RedisTemplate<String, Object> redisTemplate;
    private final NewsRepositoryQuerydsl newsRepositoryQuerydsl;
    private final Map<String, CacheEntry> cache = new HashMap<>();
    private final long cacheDuration = 10 * 60 * 1000; // 캐시 유지 시간 10분

    //최근 검색어 추가
    @Transactional
    public void addSearchKeyword(Long memberId, String keyword) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("해당 회원이 존재하지 않습니다."));

        // 해당 멤버의 동일 키워드가 있는지 확인
        StockRecentSearchWord existingSearchWord = recentSearchWordRepository.findByMemberAndKeyword(member, keyword);

        if (existingSearchWord != null) {
            // 이미 존재하는 키워드의 날짜를 업데이트
            existingSearchWord.updateSearchDate();
            recentSearchWordRepository.save(existingSearchWord);
        } else {
            // 새로운 검색어 추가
            StockRecentSearchWord newSearchWord = new StockRecentSearchWord(keyword, new Date(), member);
            recentSearchWordRepository.save(newSearchWord);
        }
    }

    //최근 검색어 조회
    public List<StockRecentSearchWord> getRecentSearchKeyword(Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("해당 회원이 존재하지 않습니다."));
        return recentSearchWordRepository.findByMemberOrderByDateDesc(member);
    }

    //최근 검색어 삭제
    @Transactional
    public void deleteRecentSearchWord(Long searchId) {
        recentSearchWordRepository.deleteById(searchId);
    }

    //거래량 상위 5
    public List<StockRankingResponse> getTopVolume() {
        String url = "/uapi/domestic-stock/v1/quotations/volume-rank";

        Map<String, String> queryParams = Map.ofEntries(
                new AbstractMap.SimpleEntry<>("fid_cond_mrkt_div_code", "J"),
                new AbstractMap.SimpleEntry<>("fid_cond_scr_div_code", "20171"),
                new AbstractMap.SimpleEntry<>("fid_input_iscd", "0000"),
                new AbstractMap.SimpleEntry<>("fid_div_cls_code", "0"),
                new AbstractMap.SimpleEntry<>("fid_blng_cls_code", "0"),
                new AbstractMap.SimpleEntry<>("fid_trgt_cls_code", "111111111"),
                new AbstractMap.SimpleEntry<>("fid_trgt_exls_cls_code", "0000000000"),
                new AbstractMap.SimpleEntry<>("fid_input_price_1", "0"),
                new AbstractMap.SimpleEntry<>("fid_input_price_2", "0"),
                new AbstractMap.SimpleEntry<>("fid_vol_cnt", "0"),
                new AbstractMap.SimpleEntry<>("fid_input_date_1", "0")
        );

        Map<String, String> headers = Map.ofEntries(
                new AbstractMap.SimpleEntry<>("tr_id", "FHPST01710000")
        );

        try {
            log.info("거래량 상위 5개 주식 데이터 요청");
            String response = webClientUtil.sendRequest(url, queryParams, headers);
            return parseTop5VolumeStocks(response);
        } catch (Exception e) {
            throw new RuntimeException("거래량 상위 5개 주식 데이터 가져오기 실패", e);
        }
    }

    //하락률
    public List<StockRankingResponse> getBottomChangeRate() {
        String url = "/uapi/domestic-stock/v1/ranking/exp-trans-updown";

        Map<String, String> queryParams = Map.ofEntries(
                new AbstractMap.SimpleEntry<>("fid_cond_mrkt_div_code", "J"), // 주식 시장 분류 코드
                new AbstractMap.SimpleEntry<>("fid_cond_scr_div_code", "20182"), // 화면 분류 코드
                new AbstractMap.SimpleEntry<>("fid_input_iscd", "0000"), // 종목 코드 전체
                new AbstractMap.SimpleEntry<>("fid_div_cls_code", "0"), // 상승율 순위 정렬
                new AbstractMap.SimpleEntry<>("fid_aply_rang_prc_1", "0"), // 전체 입력 수
                new AbstractMap.SimpleEntry<>("fid_vol_cnt", "0"), // 종가 대비 상승율 순위 정렬
                new AbstractMap.SimpleEntry<>("fid_pbmn", "0"), // 가격 전체
                new AbstractMap.SimpleEntry<>("fid_blng_cls_code", "0"), // 가격 전체
                new AbstractMap.SimpleEntry<>("fid_mkop_cls_code", "0"), // 거래량 전체
                new AbstractMap.SimpleEntry<>("fid_rank_sort_cls_code", "3") // 대상 전체
        );

        // 헤더에 등락률 관련 ID 추가
        Map<String, String> headers = Map.ofEntries(
                new AbstractMap.SimpleEntry<>("tr_id", "FHPST01820000")  // 등락률 관련 tr_id 값
        );
        try {
            log.info("등락률 하위 5개 주식 데이터 요청");
            String response = webClientUtil.sendRequest(url, queryParams, headers);
            return parseChangeReverseRanking(response);
        } catch (Exception e) {
            throw new RuntimeException("등락률 하위 5개 주식 데이터 가져오기 실패", e);
        }
    }


    // 등락률 순위 5개 종목
    public List<StockRankingResponse> getTopChangeRate() {
        String url = "/uapi/domestic-stock/v1/ranking/exp-trans-updown";

        Map<String, String> queryParams = Map.ofEntries(
                new AbstractMap.SimpleEntry<>("fid_cond_mrkt_div_code", "J"), // 주식 시장 분류 코드
                new AbstractMap.SimpleEntry<>("fid_cond_scr_div_code", "20182"), // 화면 분류 코드
                new AbstractMap.SimpleEntry<>("fid_input_iscd", "0000"), // 종목 코드 전체
                new AbstractMap.SimpleEntry<>("fid_div_cls_code", "0"), // 상승율 순위 정렬
                new AbstractMap.SimpleEntry<>("fid_aply_rang_prc_1", "0"), // 전체 입력 수
                new AbstractMap.SimpleEntry<>("fid_vol_cnt", "0"), // 종가 대비 상승율 순위 정렬
                new AbstractMap.SimpleEntry<>("fid_pbmn", "0"), // 가격 전체
                new AbstractMap.SimpleEntry<>("fid_blng_cls_code", "0"), // 가격 전체
                new AbstractMap.SimpleEntry<>("fid_mkop_cls_code", "0"), // 거래량 전체
                new AbstractMap.SimpleEntry<>("fid_rank_sort_cls_code", "0") // 대상 전체
        );

        // 헤더에 등락률 관련 ID 추가
        Map<String, String> headers = Map.ofEntries(
                new AbstractMap.SimpleEntry<>("tr_id", "FHPST01820000")  // 등락률 관련 tr_id 값
        );
        try {
            log.info("등락률 상위 5개 주식 데이터 요청");
            String response = webClientUtil.sendRequest(url, queryParams, headers);
            return parseChangeRanking(response);
        } catch (Exception e) {
            throw new RuntimeException("등락률 상위 5개 주식 데이터 가져오기 실패", e);
        }
    }

    // 시가총액 순위 5개 종목
    public List<StockRankingResponse> getCapitalization() {
        String url = "/uapi/domestic-stock/v1/ranking/market-cap";

        Map<String, String> queryParams = Map.ofEntries(
                new AbstractMap.SimpleEntry<>("fid_input_price_2", "0"), // 입력 가격2 (~ 가격)
                new AbstractMap.SimpleEntry<>("fid_cond_mrkt_div_code", "J"), // 조건 시장 분류 코드 (주식 J)
                new AbstractMap.SimpleEntry<>("fid_cond_scr_div_code", "20174"), // 조건 화면 분류 코드
                new AbstractMap.SimpleEntry<>("fid_div_cls_code", "0"), // 분류 구분 코드 (0: 전체, 1: 보통주, 2: 우선주)
                new AbstractMap.SimpleEntry<>("fid_input_iscd", "0000"), // 입력 종목코드 (0000: 전체, 0001: 거래소, 1001: 코스닥, 2001: 코스피200)
                new AbstractMap.SimpleEntry<>("fid_trgt_cls_code", "0"), // 대상 구분 코드 (0: 전체)
                new AbstractMap.SimpleEntry<>("fid_trgt_exls_cls_code", "0"), // 대상 제외 구분 코드 (0: 전체)
                new AbstractMap.SimpleEntry<>("fid_input_price_1", "0"), // 입력 가격1 (가격 ~)
                new AbstractMap.SimpleEntry<>("fid_vol_cnt", "0") // 거래량 수 (거래량 ~)
        );


        // 헤더에 등락률 관련 ID 추가
        Map<String, String> headers = Map.ofEntries(
                new AbstractMap.SimpleEntry<>("tr_id", "FHPST01740000")  // 등락률 관련 tr_id 값
        );
        try {
            log.info("시가총액 상위 5개 주식 데이터 요청");
            String response = webClientUtil.sendRequest(url, queryParams, headers);
            return parseTop5VolumeStocks(response);
        } catch (Exception e) {
            throw new RuntimeException("시가총액 상위 5개 주식 데이터 가져오기 실패", e);
        }
    }

    //거래량 상위 5개 주식 추출
    private List<StockRankingResponse> parseTop5VolumeStocks(String response) {
        List<StockRankingResponse> top5Stocks = new ArrayList<>();

        try {
            JsonNode root = objectMapper.readTree(response);
            JsonNode output = root.get("output");
            if (output == null || !output.isArray() || output.isEmpty()) {
                throw new RuntimeException("output 필드가 없거나 비어있습니다.");
            }

            // 거래량 상위 주식 중 "선물", "인버스"가 포함된 주식을 제외하고 상위 5개 데이터를 가져옴
            for (int i = 0; i < output.size() && top5Stocks.size() < 5; i++) {
                JsonNode stockData = output.get(i);
                String stockName = stockData.get("hts_kor_isnm").asText();

                // "선물" 또는 "인버스"가 포함된 주식명은 제외
                if (stockName.contains("선물") || stockName.contains("인버스")) {
                    continue;
                }

                String stockCode = stockData.get("mksc_shrn_iscd").asText();
                String currentPrice = stockData.get("stck_prpr").asText();
                String priceChangeAmount = stockData.get("prdy_vrss").asText(); // 전일 대비 가격
                String priceChangeRate = stockData.get("prdy_ctrt").asText(); // 전일 대비 퍼센트
                String priceChangeSign = stockData.get("prdy_vrss_sign").asText(); // 전일 대비 부호
                top5Stocks.add(new StockRankingResponse(stockName, stockCode, currentPrice, priceChangeRate, priceChangeAmount, priceChangeSign));
            }
        } catch (Exception e) {
            throw new RuntimeException("거래량 상위 5개 주식 데이터 파싱 실패", e);
        }

        return top5Stocks;
    }

    //등락률 상위 5개 추출
    public List<StockRankingResponse> parseChangeRanking(String response) {
        List<StockRankingResponse> top5Stocks = new ArrayList<>();
        try {
            JsonNode root = objectMapper.readTree(response);
            JsonNode output = root.get("output");
            if (output == null || !output.isArray() || output.isEmpty()) {
                throw new RuntimeException("output 필드가 없거나 비어있습니다.");
            }

            for (int i = 0, validStockCount = 0; i < output.size() && validStockCount < 5; i++) {
                JsonNode stockData = output.get(i);
                String stockName = stockData.get("hts_kor_isnm").asText();

                // "선물" 또는 "인버스"가 이름에 포함된 종목은 제외
                if (stockName.contains("선물") || stockName.contains("인버스")) {
                    continue;
                }

                validStockCount++;

                // 필드 추출 및 변수 이름에 맞게 할당
                String stockCode = stockData.get("stck_shrn_iscd").asText();
                String currentPrice = stockData.get("stck_prpr").asText();
                String priceChangeAmount = stockData.get("prdy_vrss").asText(); // 가격 변화 값
                String priceChangeRate = stockData.get("prdy_ctrt").asText();  // 가격 변화율
                String priceChangeSign = stockData.get("prdy_vrss_sign").asText();

                // 객체 추가
                top5Stocks.add(new StockRankingResponse(stockName, stockCode, currentPrice, priceChangeAmount, priceChangeRate, priceChangeSign));
            }
            return top5Stocks;
        } catch (Exception e) {
            throw new RuntimeException("등락률 상위 5개 주식 데이터 파싱 실패", e);
        }
    }

    //등락률 하락순
    public List<StockRankingResponse> parseChangeReverseRanking(String response) {
        List<StockRankingResponse> top5Stocks = new ArrayList<>();
        try {
            JsonNode root = objectMapper.readTree(response);
            JsonNode output = root.get("output");
            if (output == null || !output.isArray() || output.isEmpty()) {
                throw new RuntimeException("output 필드가 없거나 비어있습니다.");
            }

            for (int i = 0, validStockCount = 0; i < output.size() && validStockCount < 5; i++) {
                JsonNode stockData = output.get(i);
                String stockName = stockData.get("hts_kor_isnm").asText();

                // "선물" 또는 "인버스"가 이름에 포함된 종목은 제외
                if (stockName.contains("선물") || stockName.contains("인버스")) {
                    continue;
                }

                validStockCount++;

                // 필드 추출 및 변수 이름에 맞게 할당
                String stockCode = stockData.get("stck_shrn_iscd").asText();
                String currentPrice = stockData.get("stck_prpr").asText();
                String priceChangeAmount = stockData.get("prdy_vrss").asText(); // 가격 변화 값
                String priceChangeRate = stockData.get("prdy_ctrt").asText();  // 가격 변화율
                String priceChangeSign = stockData.get("prdy_vrss_sign").asText();

                // 객체 추가
                top5Stocks.add(new StockRankingResponse(stockName, stockCode, currentPrice, priceChangeRate, priceChangeAmount, priceChangeSign));
            }
            return top5Stocks;
        } catch (Exception e) {
            throw new RuntimeException("등락률 상위 5개 주식 데이터 파싱 실패", e);
        }
    }

    //Redis 저장
    @Scheduled(fixedRate = 3600000)
    public void saveRanking() {
        List<StockRankingResponse> topVolume = getTopVolume();
        try {
            Thread.sleep(1000);  // 1초 지연
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();  // 인터럽트 처리
            log.error("스레드가 중단되었습니다.", e);
        }
        List<StockRankingResponse> topChangeRate = getTopChangeRate();

        try {
            Thread.sleep(1000);  // 1초 지연
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();  // 인터럽트 처리
            log.error("스레드가 중단되었습니다.", e);
        }

        List<StockRankingResponse> bottomChangeRate = getBottomChangeRate();

        try {
            Thread.sleep(1000);  // 1초 지연
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();  // 인터럽트 처리
            log.error("스레드가 중단되었습니다.", e);
        }

        List<StockRankingResponse> topCapitalizationRate = getCapitalization();

        redisTemplate.opsForValue().set("topVolumeStocks", topVolume);
        log.info("거래량 상위 5개 주식이 Redis에 업데이트되었습니다.");
        redisTemplate.opsForValue().set("topChangeStocks", topChangeRate);
        log.info("등락률 상위 5개 주식이 Redis에 업데이트되었습니다.");
        redisTemplate.opsForValue().set("bottomChangeStocks", bottomChangeRate);
        log.info("등락률 하위 5개 주식이 Redis에 업데이트되었습니다.");
        redisTemplate.opsForValue().set("topCapitalizationStocks", topCapitalizationRate);
        log.info("시가총액 하위 5개 주식이 Redis에 업데이트되었습니다.");
    }

    //거래량 순위 가져오기
    public List<StockRankingResponse> getTopVolumeStocksFromRedis() {
        return (List<StockRankingResponse>) redisTemplate.opsForValue().get("topVolumeStocks");
    }

    //등락률 순위 가져오기
    public List<StockRankingResponse> getTopChangeStocksFromRedis() {
        return (List<StockRankingResponse>) redisTemplate.opsForValue().get("topChangeStocks");
    }

    //등락률 하위 순위 가져오기
    public List<StockRankingResponse> getBottomChangeStocksFromRedis() {
        return (List<StockRankingResponse>) redisTemplate.opsForValue().get("bottomChangeStocks");
    }

    //시가 총액 순위 가져오기
    public List<StockRankingResponse> getCapitalizationStocksFromRedis() {
        return (List<StockRankingResponse>) redisTemplate.opsForValue().get("topCapitalizationStocks");
    }

    //주식 검색
    public List<Stock> searchStock(String keyword) {
        return stockRepository.findByNameContaining(keyword);
    }

    //필요없는 문자열 제거
    public String removeStockTypeSuffix(String stockName) {
        // 정규식으로 '보통주', '우선주', 숫자(1,2 등)을 제거
        return stockName.replaceAll("(\\d?우선주|보통주|\\s*\\(.*\\))", "").trim();
    }

    //주식으로 뉴스 검색
    //관심종목 + 관련 뉴스 조회
    public List<NewsSearchResponse> searchNewsForStock(String stockCode) {
        Stock stock = stockRepository.findByStockCode(stockCode)
                .orElseThrow(() -> new IllegalArgumentException("주식이 존재하지 않습니다."));

        String stockName = removeStockTypeSuffix(stock.getName());
        List<NewsSearchResponse> newsResponses = newsRepositoryQuerydsl.searchNewsTitleOrKeyword(stockName);

        return newsResponses;
    }

    public List<MarketDataResponse> getMarketData() {
        String[] marketNames = {
                "KOSPI", "KOSDAQ", "NASDAQ", "S&P 500", "항생지수", "닛케이지수", "다우존스", "유로스톡스50", "USD", "JPY(yen)"
        };

        String[] marketUrls = {
                "https://finance.yahoo.com/quote/%5EKS11/",
                "https://finance.yahoo.com/quote/%5EKQ11/",
                "https://finance.yahoo.com/quote/NQ=F/",
                "https://finance.yahoo.com/quote/%5EGSPC/",
                "https://finance.yahoo.com/quote/%5EHSI/",
                "https://finance.yahoo.com/quote/%5EN225/",
                "https://finance.yahoo.com/quote/%5EDJI/",
                "https://finance.yahoo.com/quote/%5ESTOXX50E/",
                "https://finance.yahoo.com/quote/KRW%3DX/",
                "https://finance.yahoo.com/quote/JPY=X/"
        };

        String priceSelector = "#nimbus-app > section > section > section > article > section.container.yf-1s1umie > div.bottom.yf-1s1umie > div.price.yf-1s1umie > section > div > section > div.container.yf-1tejb6 > fin-streamer.livePrice.yf-1tejb6 > span";
        String diffSelector = "#nimbus-app > section > section > section > article > section.container.yf-1s1umie > div.bottom.yf-1s1umie > div.price.yf-1s1umie > section > div > section > div.container.yf-1tejb6 > fin-streamer:nth-child(2) > span";
        String rateSelector = "#nimbus-app > section > section > section > article > section.container.yf-1s1umie > div.bottom.yf-1s1umie > div.price.yf-1s1umie > section > div > section > div.container.yf-1tejb6 > fin-streamer:nth-child(3) > span";

        List<CompletableFuture<MarketDataResponse>> futures = new ArrayList<>();

        for (int i = 0; i < marketUrls.length; i++) {
            String marketName = marketNames[i];
            String url = marketUrls[i];
            CompletableFuture<MarketDataResponse> future = CompletableFuture.supplyAsync(() -> {
                try {
                    // 먼저 캐시에서 가져오기
                    return getFromCacheOrFetch(marketName, url, priceSelector, diffSelector, rateSelector);
                } catch (Exception e) {
                    e.printStackTrace();
                    return null;
                }
            });
            futures.add(future);
        }

        // 비동기
        List<MarketDataResponse> marketDataList = futures.stream()
                .map(CompletableFuture::join)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        return marketDataList;
    }

    // 캐시에서 데이터 확인
    private MarketDataResponse getFromCacheOrFetch(String marketName, String url, String priceSelector, String diffSelector, String rateSelector) throws Exception {
        CacheEntry cachedEntry = cache.get(marketName);
        if (cachedEntry != null && isCacheValid(cachedEntry.getTimestamp())) {
            return cachedEntry.getData();
        }
        MarketDataResponse freshData = fetchMarketData(marketName, url, priceSelector, diffSelector, rateSelector);
        cache.put(marketName, new CacheEntry(freshData, Instant.now().toEpochMilli()));

        return freshData;
    }

    private boolean isCacheValid(long cacheTimestamp) {
        long currentTime = Instant.now().toEpochMilli();
        return (currentTime - cacheTimestamp) < cacheDuration;
    }

    // 데이터 크롤링
    private MarketDataResponse fetchMarketData(String marketName, String url, String priceSelector, String diffSelector, String rateSelector) throws Exception {
        Document document = Jsoup.connect(url).get();
        String price = document.select(priceSelector).text();
        String difference = document.select(diffSelector).text();
        String rate = document.select(rateSelector).text();
        return new MarketDataResponse(marketName, price, difference, rate);
    }
}
