package com.ssafy.newstock.stock.domain;

import com.ssafy.newstock.member.domain.Member;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.Date;

@Entity
@Getter
@Table(name = "stock_recent_search_word")
@NoArgsConstructor
public class StockRecentSearchWord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "keyword")
    private String keyword;

    @Column(name = "date")
    private Date date;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    Member member;

    public StockRecentSearchWord(String keyword, Date date, Member member) {
        this.keyword = keyword;
        this.date = date;
        this.member = member;
    }
}
