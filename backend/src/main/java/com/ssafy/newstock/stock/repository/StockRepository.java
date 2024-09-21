package com.ssafy.newstock.stock.repository;

import com.ssafy.newstock.stock.domain.Stock;
import org.springframework.data.jpa.repository.JpaRepository;


public interface StockRepository extends JpaRepository<Stock, String> {
}
