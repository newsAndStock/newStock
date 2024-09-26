package com.ssafy.newstock.memberstocks.repository;

import com.ssafy.newstock.memberstocks.domain.MemberStock;
import io.lettuce.core.dynamic.annotation.Param;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MemberStocksRepository extends JpaRepository<MemberStock,Long> {

    @Query("SELECT ms.holdings FROM MemberStock ms WHERE ms.member.id = :memberId AND ms.stockCode = :stockCode")
    Optional<Long> getHoldingsByMember_IdAndStockCode(@Param("memberId") Long memberId, @Param("stockCode") String stockCode);

    Optional<MemberStock> findByMember_IdAndStockCode(Long member_id, String stockCode);
    public Optional<MemberStock> getMemberStockByMember_IdAndStockCode(Long memberId,String stockCode);
}
