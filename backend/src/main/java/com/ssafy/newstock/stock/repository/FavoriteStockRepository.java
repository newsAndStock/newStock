package com.ssafy.newstock.stock.repository;

import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.stock.domain.FavoriteStock;
import com.ssafy.newstock.stock.domain.Stock;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FavoriteStockRepository extends JpaRepository<FavoriteStock, Long> {
    List<FavoriteStock> findByMember(Member member);
    Optional<FavoriteStock> findByMemberAndStock(Member member, Stock stock);
}
