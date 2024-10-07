package com.ssafy.newstock.notification.controller.response;

import com.ssafy.newstock.notification.domain.Notification;
import com.ssafy.newstock.trading.domain.OrderType;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class NotificationResponse {
    private Long id;
    private String stockName;
    private Long quantity;
    private OrderType orderType;
    private Integer price;
    private Boolean isRead;
    private LocalDateTime createdAt;

    @Builder
    public NotificationResponse(Notification notification) {
        this.id = notification.getId();
        this.stockName=notification.getStockName();
        this.quantity=notification.getQuantity();
        this.orderType=notification.getOrderType();
        this.price=notification.getPrice();
        this.isRead = notification.getIsRead();
        this.createdAt = notification.getCreatedAt();
    }

    public String toString(){
        return "[ receiverId: "+id+", stockName: "+stockName+", orderType: "+orderType+", quantity: "+quantity+", price: "+price+" ]";
    }

}