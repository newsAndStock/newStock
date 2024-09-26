package com.ssafy.newstock.trading.repository;

import com.ssafy.newstock.trading.domain.OrderType;
import com.ssafy.newstock.trading.domain.TradeType;
import com.ssafy.newstock.trading.domain.Trading;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TradingRepository extends JpaRepository<Trading,Long> {

    List<Trading> findByMemberIdAndIsCompletedFalse(Long memberId);

    // 매수중인 거래 조회
    List<Trading> findByMemberIdAndIsCompletedFalseAndOrderType(Long memberId, OrderType orderType);

    // 매도중인 거래 조회
    List<Trading> findByMemberIdAndIsCompletedFalseAndTradeType(Long memberId, OrderType orderType);

}
