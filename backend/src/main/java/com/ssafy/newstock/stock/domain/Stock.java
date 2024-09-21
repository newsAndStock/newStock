package com.ssafy.newstock.stock.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@Table(name = "stock")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Stock {

    @Id @Column(name = "stock_code", nullable = false)
    private String stockCode;

    @Column(name = "name")
    private String name;

    @Column(name = "market")
    private String market;

    @Column(name = "industry")
    private String industry;

    @Column(name = "listing_date")
    private String listingDate;

    @Column(name = "settlement_month")
    private String settlementMonth;

    @Column(name = "capital")
    private String capital;

    @Column(name = "issued_shares")
    private String issuedShares;
}
