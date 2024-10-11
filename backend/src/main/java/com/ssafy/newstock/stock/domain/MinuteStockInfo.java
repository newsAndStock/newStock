package com.ssafy.newstock.stock.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Entity
@Getter
@Table(name = "minute_stock_info")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MinuteStockInfo {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "stock_code", nullable = false)
    private String stockCode;

    @Column(name = "date", nullable = false)
    private LocalDate date;

    @Column(name = "time", nullable = false)
    private String time;

    @Column(name = "opening_price", nullable = false)
    private String openingPrice;

    @Column(name = "closing_price", nullable = false)
    private String closingPrice;

    @Column(name = "highest_price", nullable = false)
    private String highestPrice;

    @Column(name = "lowest_price", nullable = false)
    private String lowestPrice;

    @Column(name = "volume", nullable = false)
    private Long volume;

    public MinuteStockInfo(String stockCode, String time, String openingPrice, String closingPrice, String highestPrice,
                           String lowestPrice, Long volume) {
        this.stockCode = stockCode;
        this.date = LocalDate.now();
        this.time = time;
        this.openingPrice = openingPrice;
        this.closingPrice = closingPrice;
        this.highestPrice = highestPrice;
        this.lowestPrice = lowestPrice;
        this.volume = volume;
    }
}
