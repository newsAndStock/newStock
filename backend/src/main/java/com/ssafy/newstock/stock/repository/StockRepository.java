package com.ssafy.newstock.stock.repository;

import com.ssafy.newstock.stock.domain.Stock;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;


public interface StockRepository extends JpaRepository<Stock, String> {
    List<Stock> findByNameContaining(String name);
}
