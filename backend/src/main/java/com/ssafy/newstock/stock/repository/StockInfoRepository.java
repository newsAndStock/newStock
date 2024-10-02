package com.ssafy.newstock.stock.repository;

import com.ssafy.newstock.stock.domain.StockInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface StockInfoRepository extends JpaRepository<StockInfo, Long> {

    @Query("select s from StockInfo s where s.date >= :startDate and s.stockCode = :stockCode and s.period = :period")
    List<StockInfo> findDataWithinRange(@Param("startDate") String startDate,
                                        @Param("stockCode") String stockCode,
                                        @Param("period") String period);
}
