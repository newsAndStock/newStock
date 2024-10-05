package com.ssafy.newstock.stock.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.newstock.common.util.WebClientUtil;
import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.repository.MemberRepository;
import com.ssafy.newstock.news.controller.response.NewsSearchResponse;
import com.ssafy.newstock.news.repository.NewsRepositoryQuerydsl;
import com.ssafy.newstock.stock.controller.response.StockRankingResponse;
import com.ssafy.newstock.stock.domain.FavoriteStock;
import com.ssafy.newstock.stock.domain.Stock;
import com.ssafy.newstock.stock.domain.StockRecentSearchWord;
import com.ssafy.newstock.stock.repository.StockRecentSearchWordRepository;
import com.ssafy.newstock.stock.repository.StockRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
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

        try{
            log.info("거래량 상위 5개 주식 데이터 요청");
            String response = webClientUtil.sendRequest(url, queryParams, headers);
            return parseTop5VolumeStocks(response);
        }catch (Exception e){
            throw new RuntimeException("거래량 상위 5개 주식 데이터 가져오기 실패", e);
        }
    }

    // 등락률 순위 5개 종목
    public List<StockRankingResponse> getTopChangeRate(boolean flag){
        String url = "/uapi/domestic-stock/v1/ranking/fluctuation";

        Map<String, String> queryParams = Map.ofEntries(
                new AbstractMap.SimpleEntry<>("fid_rsfl_rate2", "0"), // 전체 비율
                new AbstractMap.SimpleEntry<>("fid_cond_mrkt_div_code", "J"), // 주식 시장 분류 코드
                new AbstractMap.SimpleEntry<>("fid_cond_scr_div_code", "20170"), // 화면 분류 코드
                new AbstractMap.SimpleEntry<>("fid_input_iscd", "0000"), // 종목 코드 전체
                new AbstractMap.SimpleEntry<>("fid_rank_sort_cls_code", "0"), // 상승율 순위 정렬
                new AbstractMap.SimpleEntry<>("fid_input_cnt_1", "0"), // 전체 입력 수
                new AbstractMap.SimpleEntry<>("fid_prc_cls_code", "1"), // 종가 대비 상승율 순위 정렬
                new AbstractMap.SimpleEntry<>("fid_input_price_1", "0"), // 가격 전체
                new AbstractMap.SimpleEntry<>("fid_input_price_2", "0"), // 가격 전체
                new AbstractMap.SimpleEntry<>("fid_vol_cnt", "0"), // 거래량 전체
                new AbstractMap.SimpleEntry<>("fid_trgt_cls_code", "0"), // 대상 전체
                new AbstractMap.SimpleEntry<>("fid_trgt_exls_cls_code", "0"), // 제외 대상 전체
                new AbstractMap.SimpleEntry<>("fid_div_cls_code", "0"), // 분류 전체
                new AbstractMap.SimpleEntry<>("fid_rsfl_rate1", "0") // 비율 전체
        );

        // 헤더에 등락률 관련 ID 추가
        Map<String, String> headers = Map.ofEntries(
                new AbstractMap.SimpleEntry<>("tr_id", "FHPST01700000")  // 등락률 관련 tr_id 값
        );
        try {
            log.info("등락률 상위 5개 주식 데이터 요청");
            String response = webClientUtil.sendRequest(url, queryParams, headers);
            if(flag){
                return parseChangeRanking(response);
            }else{
                return parseChangeReverseRanking(response);
            }
        } catch (Exception e) {
            throw new RuntimeException("등락률 상위 5개 주식 데이터 가져오기 실패", e);
        }
    }

    // 시가총액 순위 5개 종목
    public List<StockRankingResponse> getCapitalization(){
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
            for (int i = 0, validStockCount = 0; i < output.size() && validStockCount < 5; i++) {
                JsonNode stockData = output.get(i);
                String stockName = stockData.get("hts_kor_isnm").asText();

                // "선물" 또는 "인버스"가 포함된 주식명은 제외
                if (stockName.contains("선물") || stockName.contains("인버스")) {
                    continue;
                }

                // 유효한 주식만 카운트
                validStockCount++;

                String stockCode = stockData.get("mksc_shrn_iscd").asText();
                String currentPrice = stockData.get("stck_prpr").asText();
                String priceChangeAmount = stockData.get("prdy_vrss").asText(); // 전일 대비 가격
                String priceChangeRate = stockData.get("prdy_ctrt").asText(); // 전일 대비 퍼센트
                String priceChangeSign = stockData.get("prdy_vrss_sign").asText(); // 전일 대비 부호
                top5Stocks.add(new StockRankingResponse(stockName, stockCode, currentPrice, priceChangeAmount, priceChangeRate, priceChangeSign));
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

                if (stockName.contains("선물") || stockName.contains("인버스")) {
                    continue;
                }

                validStockCount++;

                String stockCode = stockData.get("stck_shrn_iscd").asText();
                String currentPrice = stockData.get("stck_prpr").asText();
                String priceChangeAmount = stockData.get("prdy_vrss").asText();
                String priceChangeRate = stockData.get("prdy_ctrt").asText();
                String priceChangeSign = stockData.get("prdy_vrss_sign").asText();
                top5Stocks.add(new StockRankingResponse(stockName, stockCode, currentPrice, priceChangeAmount, priceChangeRate, priceChangeSign));
            }
        } catch (Exception e) {
            throw new RuntimeException("등락률 상위 5개 주식 데이터 파싱 실패", e);
        }

        return top5Stocks;
    }

    //등락률 하위 5개 추출
    public List<StockRankingResponse> parseChangeReverseRanking(String response) {
        List<StockRankingResponse> allStocks = new ArrayList<>();
        try {
            JsonNode root = objectMapper.readTree(response);
            JsonNode output = root.get("output");
            if (output == null || !output.isArray() || output.isEmpty()) {
                throw new RuntimeException("output 필드가 없거나 비어있습니다.");
            }

            for (JsonNode stockData : output) {
                String stockName = stockData.get("hts_kor_isnm").asText();
                if (stockName.contains("선물") || stockName.contains("인버스")) {
                    continue;
                }
                String stockCode = stockData.get("stck_shrn_iscd").asText();
                String currentPrice = stockData.get("stck_prpr").asText();
                String priceChangeAmount = stockData.get("prdy_vrss").asText(); // 전일 대비 가격
                String priceChangeRate = stockData.get("prdy_ctrt").asText(); // 전일 대비 퍼센트
                String priceChangeSign = stockData.get("prdy_vrss_sign").asText(); // 전일 대비 부호

                allStocks.add(new StockRankingResponse(stockName, stockCode, currentPrice, priceChangeAmount, priceChangeRate, priceChangeSign));
            }

            // 등락률 기준으로 오름차순 정렬
            allStocks.sort(Comparator.comparing(stock -> Double.parseDouble(stock.getPriceChangeRate())));

            // 하위 5개 주식 추출
            return allStocks.stream().limit(5).collect(Collectors.toList());

        } catch (Exception e) {
            throw new RuntimeException("등락률 하위 5개 주식 데이터 파싱 실패", e);
        }
    }

    //Redis 저장
    @Scheduled(fixedRate = 3600000)
    public void saveRanking(){
        List<StockRankingResponse> topVolume = getTopVolume();
        try {
            Thread.sleep(1000);  // 1초 지연
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();  // 인터럽트 처리
            log.error("스레드가 중단되었습니다.", e);
        }
        List<StockRankingResponse> topChangeRate = getTopChangeRate(true);

        try {
            Thread.sleep(1000);  // 1초 지연
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();  // 인터럽트 처리
            log.error("스레드가 중단되었습니다.", e);
        }

        List<StockRankingResponse> bottomChangeRate = getTopChangeRate(false);

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
    public List<StockRankingResponse> getTopVolumeStocksFromRedis(){
        return (List<StockRankingResponse>) redisTemplate.opsForValue().get("topVolumeStocks");
    }

    //등락률 순위 가져오기
    public List<StockRankingResponse> getTopChangeStocksFromRedis(){
        return (List<StockRankingResponse>) redisTemplate.opsForValue().get("topChangeStocks");
    }

    //등락률 하위 순위 가져오기
    public List<StockRankingResponse> getBottomChangeStocksFromRedis(){
        return (List<StockRankingResponse>) redisTemplate.opsForValue().get("bottomChangeStocks");
    }

    //시가 총액 순위 가져오기
    public List<StockRankingResponse> getCapitalizationStocksFromRedis(){
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
    public Map<String, List<NewsSearchResponse>>  searchNewsForStock(String stockCode) {
        Map<String, List<NewsSearchResponse>> stockNewsMap = new HashMap<>();
        Stock stock = stockRepository.findByStockCode(stockCode)
                .orElseThrow(() -> new IllegalArgumentException("주식이 존재하지 않습니다."));

        String stockName = removeStockTypeSuffix(stock.getName());
        List<NewsSearchResponse> newsResponses = newsRepositoryQuerydsl.searchNewsTitleOrKeyword(stockName);
        stockNewsMap.put(stockName, newsResponses);

        return stockNewsMap;
    }
}
