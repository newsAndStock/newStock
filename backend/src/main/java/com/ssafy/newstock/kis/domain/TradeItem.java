package com.ssafy.newstock.kis.domain;

import com.ssafy.newstock.member.domain.Member;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class TradeItem implements Comparable<TradeItem>{

    private Member member;
    private int bid;
    private int quantity;
    private LocalDateTime orderTime;

    private int remaining;

    public TradeItem(Member member,int bid, int quantity, int remaining, LocalDateTime orderTime) {
        this.member = member;
        this.bid = bid;
        this.quantity = quantity;
        this.remaining=remaining;
        this.orderTime = orderTime;
    }

    public void trade(int value){
        remaining-=value;
    }

    @Override
    public int compareTo(TradeItem o) {
        if(this.bid!=o.bid){
            return this.bid-o.bid;
        }else {
            return this.orderTime.compareTo(o.orderTime);
        }
    }
}
