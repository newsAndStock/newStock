package com.ssafy.newstock.stock.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.newstock.common.util.WebClientUtil;
import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.repository.MemberRepository;
import com.ssafy.newstock.stock.controller.response.FavoriteStockResponse;
import com.ssafy.newstock.stock.controller.response.MemberFavoriteStockResponse;
import com.ssafy.newstock.stock.domain.FavoriteStock;
import com.ssafy.newstock.stock.domain.Stock;
import com.ssafy.newstock.stock.repository.FavoriteStockRepository;
import com.ssafy.newstock.stock.repository.StockRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.AbstractMap;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class FavoriteStockService {
    private final FavoriteStockRepository favoriteStockRepository;
    private final StockRepository stockRepository;
    private final MemberRepository memberRepository;
    private final ObjectMapper objectMapper;
    private final WebClientUtil webClientUtil;

    //관심 주식 추가
    @Transactional
    public void addFavoriteStock(Long memberId, String stockCode) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("해당 회원을 찾을 수 없습니다."));
        Stock stock = stockRepository.findById(stockCode)
                .orElseThrow(() -> new IllegalArgumentException("주식을 찾을 수 없습니다."));

        if(favoriteStockRepository.findByMemberAndStock(member, stock).isPresent()) {
            throw new IllegalArgumentException("이미 관심 목록에 등록된 주식입니다.");
        }

        FavoriteStock favoriteStock = new FavoriteStock(member, stock);
        favoriteStockRepository.save(favoriteStock);
    }

    //관심 주식 조회
    public MemberFavoriteStockResponse getFavoriteStockList(Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("해당 회원을 찾을 수 없습니다."));
        List<FavoriteStock> favoriteStockList = favoriteStockRepository.findByMember(member);


        List<FavoriteStockResponse> stockResponse = favoriteStockList.stream()
                .map(favoriteStock -> {
                    Map<String, String> stockInfo = getCurrentRate(favoriteStock.getStock().getStockCode());


                    return new FavoriteStockResponse(
                            favoriteStock.getStock().getStockCode(),
                            favoriteStock.getStock().getName(),
                            favoriteStock.getStock().getMarket(),
                            favoriteStock.getStock().getIndustry(),
                            stockInfo
                    );
                })
                .toList();

        return new MemberFavoriteStockResponse(
                member.getId(),
                member.getEmail(),
                member.getNickname(),
                stockResponse
        );
    }

    private Map<String, String> getCurrentRate(String stockCode){
        String url = "/uapi/domestic-stock/v1/quotations/inquire-price";

        Map<String, String> queryParams = Map.ofEntries(
                new AbstractMap.SimpleEntry<>("fid_cond_mrkt_div_code", "J"),
                new AbstractMap.SimpleEntry<>("fid_input_iscd", stockCode)
        );

        Map<String, String> headers = Map.ofEntries(
                new AbstractMap.SimpleEntry<>("tr_id", "FHKST01010100")  // 등락률 관련 tr_id 값
        );

        try {
            log.info("관심항목 주식 데이터 요청");
            String response = webClientUtil.sendRequest(url, queryParams, headers);
            return parseCurrentPrice(response);
        } catch (Exception e) {
            throw new RuntimeException("주식 현재가 데이터 가져오기 실패", e);
        }
    }

    private Map<String, String> parseCurrentPrice(String response){

        Map<String, String> stock = new HashMap<>();
        // JSON 파싱
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode root = objectMapper.readTree(response);

            // 필요한 필드 추출
            JsonNode output = root.path("output");
            String stckPrpr = output.path("stck_prpr").asText();    // 현재 주가
            String prdyCtrt = output.path("prdy_ctrt").asText();    // 전일 대비율
            String prdyVrss = output.path("prdy_vrss").asText(); //전일 대비가

            stock.put("currentPrice", stckPrpr);
            stock.put("changedPriceRate", prdyCtrt);
            stock.put("changedPrice", prdyVrss);
            log.info("주식 현재가 요청 성공");
        }catch (Exception e){
            log.error(e.getMessage());
        }
        return stock;
    }

    // 관심 주식 삭제
    @Transactional
    public void removeFavoriteStock(Long memberId, String stockCode) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("해당 회원을 찾을 수 없습니다."));
        Stock stock = stockRepository.findById(stockCode)
                .orElseThrow(() -> new IllegalArgumentException("해당 주식을 찾을 수 없습니다."));

        FavoriteStock favoriteStock = favoriteStockRepository.findByMemberAndStock(member, stock)
                .orElseThrow(() -> new IllegalArgumentException("관심 목록에 해당 주식이 없습니다."));
        favoriteStockRepository.delete(favoriteStock);
    }

    //주식의 좋아요 여부
    public boolean checkFavoriteStock(Long memberId, String stockCode) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("해당 회원을 찾을 수 없습니다."));
        Stock stock = stockRepository.findById(stockCode)
                .orElseThrow(() -> new IllegalArgumentException("주식을 찾을 수 없습니다."));
        if(favoriteStockRepository.findByMemberAndStock(member, stock).isPresent()) {
            return true;
        }
        return false;
    }
}
