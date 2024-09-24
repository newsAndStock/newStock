package com.ssafy.newstock.stock.repository;

import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.stock.domain.StockRecentSearchWord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface StockRecentSearchWordRepository extends JpaRepository<StockRecentSearchWord, Long> {
    List<StockRecentSearchWord> findByMemberOrderByDateDesc(Member member);
}
