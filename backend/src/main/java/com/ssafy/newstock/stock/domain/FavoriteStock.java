package com.ssafy.newstock.stock.domain;

import com.ssafy.newstock.member.domain.Member;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@Table(name = "favorite_stock")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class FavoriteStock {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne
    @JoinColumn(name = "stock_code", referencedColumnName = "stock_code", nullable = false)
    private Stock stock;

    public FavoriteStock(Member member, Stock stock) {
        this.member = member;
        this.stock = stock;
    }
}
