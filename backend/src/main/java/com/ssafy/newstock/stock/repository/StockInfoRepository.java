package com.ssafy.newstock.stock.repository;

import com.ssafy.newstock.stock.domain.StockInfo;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StockInfoRepository extends JpaRepository<StockInfo, Integer> {
}
