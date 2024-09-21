package com.ssafy.newstock.stock.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@Table(name = "stock_info")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class StockInfo {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "date", nullable = false)
    private String date;

    @Column(name = "highest_price", nullable = false)
    private String highestPrice;

    @Column(name = "lowest_price", nullable = false)
    private String lowestPrice;

    @Column(name = "opening_price", nullable = false)
    private String openingPrice;

    @Column(name = "closing_price", nullable = false)
    private String closingPrice;

    @Column(name = "volume", nullable = false)
    private Long volume;

    @Column(name = "stock_code", nullable = false)
    private String stockCode;

    @Column(name = "period", nullable = false)
    private String period;

    public StockInfo(String date, String highestPrice, String lowestPrice, String openingPrice, String closingPrice, Long volume,
                     String stockCode, String period) {
        this.date = date;
        this.highestPrice = highestPrice;
        this.lowestPrice = lowestPrice;
        this.openingPrice = openingPrice;
        this.closingPrice = closingPrice;
        this.volume = volume;
        this.stockCode = stockCode;
        this.period = period;
    }
}
