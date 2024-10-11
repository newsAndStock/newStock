package com.ssafy.newstock.kis.domain;

import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.trading.domain.OrderType;
import com.ssafy.newstock.trading.domain.Trading;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class TradeItem implements Comparable<TradeItem>{

    private Member member;
    private int bid;
    private int quantity;
    private LocalDateTime orderTime;
    private Trading trading;

    private int remaining;

    public TradeItem(Member member,int bid, int quantity, int remaining, LocalDateTime orderTime, Trading trading) {
        this.member = member;
        this.bid = bid;
        this.quantity = quantity;
        this.remaining=remaining;
        this.orderTime = orderTime;
        this.trading = trading;
    }

    public void trade(int value){
        remaining-=value;
    }

    public void complete(){
        remaining=0;
    }

    @Override
    public int compareTo(TradeItem o) {
        if(trading.getOrderType().equals(OrderType.SELL)){
            if(this.bid!=o.bid){
                return this.bid-o.bid;
            }else {
                return this.orderTime.compareTo(o.orderTime);
            }
        }else{
            if(this.bid!=o.bid){
                return o.bid-this.bid;
            }else {
                return this.orderTime.compareTo(o.orderTime);
            }
        }
    }
}
