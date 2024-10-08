package com.ssafy.newstock.notification.domain;

import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.trading.domain.OrderType;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@NoArgsConstructor
@Getter
public class Notification{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name="receiver_id")
    private Long receiverId;

    @Column(name="stock_code")
    private String stockCode;

    @Column(name = "stock_name")
    private String stockName;

    @Column(name="quantity")
    private Long quantity;

    @Enumerated(EnumType.STRING)
    @Column(name="order_type")
    private OrderType orderType;

    @Column(name="price")
    private int price;

    @Column(name="created_at")
    private LocalDateTime createdAt;


    @Column(name="is_read")
    private boolean isRead;

    @Builder
    public Notification(Long receiverId, String stockCode, String stockName, Long quantity,OrderType orderType,int price) {
        this.receiverId = receiverId;
        this.stockCode=stockCode;
        this.stockName=stockName;
        this.quantity=quantity;
        this.createdAt=LocalDateTime.now();
        this.orderType=orderType;
        this.price=price;
        this.isRead = false;
    }

    public void read(){
        isRead = true;
    }

    public boolean getIsRead(){
        return isRead;
    }



}
