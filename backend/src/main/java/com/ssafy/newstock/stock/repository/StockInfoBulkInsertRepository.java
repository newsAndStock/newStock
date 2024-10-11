package com.ssafy.newstock.stock.repository;

import com.ssafy.newstock.stock.domain.StockInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class StockInfoBulkInsertRepository {
    private final JdbcTemplate jdbcTemplate;

    public void bulkInsert(List<StockInfo> stockInfos) {
        String sql = "INSERT INTO stock_info (date, highest_price, lowest_price, opening_price, closing_price, volume, stock_code, period) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        jdbcTemplate.batchUpdate(sql, stockInfos, stockInfos.size(),
                (ps, stockInfo) -> {
                    ps.setString(1, stockInfo.getDate());
                    ps.setString(2, stockInfo.getHighestPrice());
                    ps.setString(3, stockInfo.getLowestPrice());
                    ps.setString(4, stockInfo.getOpeningPrice());
                    ps.setString(5, stockInfo.getClosingPrice());
                    ps.setLong(6, stockInfo.getVolume());
                    ps.setString(7, stockInfo.getStockCode());
                    ps.setString(8, stockInfo.getPeriod());
                });
    }
}
