package com.ssafy.newstock.memberstocks.domain;

import com.ssafy.newstock.member.domain.Member;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "member_stocks")
@NoArgsConstructor
public class MemberStock {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "stock_code", nullable = false)
    private String stockCode;

    @Column(name = "average_price", nullable = false)
    private float averagePrice;

    @Column(name = "holdings", nullable = false)
    private long holdings;

    @Column(name= "total_price", nullable = false)
    private double totalPrice;

    @ManyToOne
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Builder
    public MemberStock(String stockCode, int averagePrice, long holdings, long totalPrice, Member member){
        this.stockCode=stockCode;
        this.averagePrice=averagePrice;
        this.holdings=holdings;
        this.totalPrice=totalPrice;
        this.member=member;
    }

    @Builder
    public MemberStock(String stockCode, Member member){
        this.stockCode=stockCode;
        this.member=member;
    }

    public void updateAveragePrice(float averagePrice){
        this.averagePrice=averagePrice;
    }

    public void updateTotalPrice(double totalPrice){
        this.totalPrice=totalPrice;
    }

    public void sell(long quantity){
        holdings-=quantity;
    }

    public void buy(long quantity){
        holdings+=quantity;
    }


}
