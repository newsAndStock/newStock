package com.ssafy.newstock.stock.repository;

import com.ssafy.newstock.stock.domain.MinuteStockInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class MinuteStockInfoBulkInsertRepository {
    private final JdbcTemplate jdbcTemplate;

    public void bulkInsert(List<MinuteStockInfo> stockInfos) {
        String sql = "INSERT INTO minute_stock_info (stock_code, date, time, opening_price, closing_price, highest_price, lowest_price, volume) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        jdbcTemplate.batchUpdate(sql, stockInfos, stockInfos.size(),
                (ps, stockInfo) -> {
                    ps.setString(1, stockInfo.getStockCode());
                    ps.setObject(2, stockInfo.getDate());
                    ps.setString(3, stockInfo.getTime());
                    ps.setString(4, stockInfo.getOpeningPrice());
                    ps.setString(5, stockInfo.getClosingPrice());
                    ps.setString(6, stockInfo.getHighestPrice());
                    ps.setString(7, stockInfo.getLowestPrice());
                    ps.setLong(8, stockInfo.getVolume());
                });
    }
}