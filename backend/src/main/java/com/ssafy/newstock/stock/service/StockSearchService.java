package com.ssafy.newstock.stock.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.newstock.common.util.WebClientUtil;
import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.repository.MemberRepository;
import com.ssafy.newstock.stock.controller.response.TopVolumeResponse;
import com.ssafy.newstock.stock.domain.Stock;
import com.ssafy.newstock.stock.domain.StockRecentSearchWord;
import com.ssafy.newstock.stock.repository.StockRecentSearchWordRepository;
import com.ssafy.newstock.stock.repository.StockRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class StockSearchService {
    private final StockRecentSearchWordRepository recentSearchWordRepository;
    private final MemberRepository memberRepository;
    private final ObjectMapper objectMapper;
    private final WebClientUtil webClientUtil;
    private final StockRepository stockRepository;
    //최근 검색어 추가
    @Transactional
    public void addSearchKeyword(Long memberId, String keyword) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("해당 회원이 존재하지 않습니다."));
        StockRecentSearchWord recentSearchWord = new StockRecentSearchWord(keyword, new Date(), member);
        recentSearchWordRepository.save(recentSearchWord);
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
    //거래량 상위 5주식 종목명
    public List<TopVolumeResponse> getTopVolume() {
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
            return parseTop5Stocks(response);
        }catch (Exception e){
            throw new RuntimeException("거래량 상위 5개 주식 데이터 가져오기 실패", e);
        }
    }
    // 상위 5개 주식 추출
    private List<TopVolumeResponse> parseTop5Stocks(String response) {
        List<TopVolumeResponse> top5Stocks = new ArrayList<>();

        try {
            JsonNode root = objectMapper.readTree(response);
            JsonNode output = root.get("output");
            if (output == null || !output.isArray() || output.isEmpty()) {
                throw new RuntimeException("output 필드가 없거나 비어있습니다.");
            }

            // 거래량 상위 5개의 데이터를 가져옴
            for (int i = 0; i < Math.min(5, output.size()); i++) {
                JsonNode stockData = output.get(i);
                String stockName = stockData.get("hts_kor_isnm").asText();
                String stockCode = stockData.get("mksc_shrn_iscd").asText();
                top5Stocks.add(new TopVolumeResponse(stockName, stockCode));
            }
        } catch (Exception e) {
            throw new RuntimeException("거래량 상위 5개 주식 데이터 파싱 실패", e);
        }

        return top5Stocks;
    }

    public List<Stock> searchStock(String keyword) {
        return stockRepository.findByNameContaining(keyword);
    }
}
