package com.ssafy.newstock.stock.repository;

import com.ssafy.newstock.stock.domain.MinuteStockInfo;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface MinuteStockInfoRepository extends JpaRepository<MinuteStockInfo, Integer> {
    List<MinuteStockInfo> findByStockCodeAndDateBetween(String stockCode, LocalDate startDate, LocalDate endDate);
}
