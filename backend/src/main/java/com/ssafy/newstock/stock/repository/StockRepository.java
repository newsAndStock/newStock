package com.ssafy.newstock.stock.repository;

import com.ssafy.newstock.stock.domain.Stock;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;


public interface StockRepository extends JpaRepository<Stock, String> {
    List<Stock> findByNameContaining(String name);
    Optional<Stock> findByStockCode(String stockCode);
}
