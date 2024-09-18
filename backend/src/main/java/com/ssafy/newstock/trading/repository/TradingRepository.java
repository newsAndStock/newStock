package com.ssafy.newstock.trading.repository;

import com.ssafy.newstock.trading.domain.Trading;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TradingRepository extends JpaRepository<Trading,Long> {


}
