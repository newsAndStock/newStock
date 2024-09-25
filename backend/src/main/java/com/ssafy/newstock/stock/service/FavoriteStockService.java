package com.ssafy.newstock.stock.service;

import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.repository.MemberRepository;
import com.ssafy.newstock.stock.controller.response.FavoriteStockResponse;
import com.ssafy.newstock.stock.controller.response.MemberFavoriteStockResponse;
import com.ssafy.newstock.stock.domain.FavoriteStock;
import com.ssafy.newstock.stock.domain.Stock;
import com.ssafy.newstock.stock.repository.FavoriteStockRepository;
import com.ssafy.newstock.stock.repository.StockRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FavoriteStockService {
    private final FavoriteStockRepository favoriteStockRepository;
    private final StockRepository stockRepository;
    private final MemberRepository memberRepository;

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
                .map(favoriteStock -> new FavoriteStockResponse(
                        favoriteStock.getStock().getStockCode(),
                        favoriteStock.getStock().getName(),
                        favoriteStock.getStock().getMarket(),
                        favoriteStock.getStock().getIndustry()
                ))
                .toList();


        return new MemberFavoriteStockResponse(
                member.getId(),
                member.getEmail(),
                member.getNickname(),
                stockResponse
        );
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
