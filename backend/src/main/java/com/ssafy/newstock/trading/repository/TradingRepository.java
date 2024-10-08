package com.ssafy.newstock.trading.repository;

import com.ssafy.newstock.trading.domain.OrderType;
import com.ssafy.newstock.trading.domain.TradeType;
import com.ssafy.newstock.trading.domain.Trading;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TradingRepository extends JpaRepository<Trading,Long> {

    List<Trading> findByMemberIdAndIsCompletedFalse(Long memberId);

    // 거래 조회
    List<Trading> findByMemberIdAndIsCompletedFalseAndOrderTypeAndIsCanceledFalse(Long memberId, OrderType orderType);

    List<Trading> findByMemberIdAndStockCodeAndOrderCompleteTimeIsNull(Long memberId, String stockCode);


}
