package com.ssafy.newstock.trading.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.ssafy.newstock.member.domain.Member;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name="trading")
@Getter
@NoArgsConstructor
public class Trading {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "stock_code", nullable = false)
    private String stockCode;

    @Column(name="quantity", nullable = false)
    private int quantity;

    @Column(name="bid", nullable = false)
    private int bid;

    @Enumerated(EnumType.STRING)
    @Column(name="order_type", nullable = false)
    private OrderType orderType;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    @Column(name = "order_time", nullable = false)
    private LocalDateTime orderTime;

    @Column(name = "order_complete_time")
    private LocalDateTime orderCompleteTime;

    @ManyToOne
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Enumerated(EnumType.STRING)
    @Column(name = "trade_type", nullable = false)
    private TradeType tradeType;

    @Column(name="is_completed", nullable = false)
    private boolean isCompleted=false;

    public Trading(String stockCode, int quantity, int bid, OrderType orderType, LocalDateTime orderTime, Member member, TradeType tradeType) {
        this.stockCode = stockCode;
        this.quantity = quantity;
        this.bid = bid;
        this.orderType = orderType;
        this.orderTime = orderTime;
        this.member = member;
        this.tradeType = tradeType;
    }

    public void tradeComplete(LocalDateTime orderCompleteTime) {

        this.orderCompleteTime = orderCompleteTime;
        this.isCompleted = true;
    }

    public void confirmBid(int bid) {
        this.bid = bid;
    }


}
