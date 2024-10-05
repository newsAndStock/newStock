package com.ssafy.newstock.news.domain;

import com.ssafy.newstock.member.domain.Member;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Date;

@Getter
@Entity
@Table(name = "news_recent_search_words")
@NoArgsConstructor
public class RecentSearchWord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "keyword")
    private String keyword;

    @Column(name="date")
    private LocalDateTime date;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    public RecentSearchWord(String keyword, LocalDateTime date, Member member){
        this.keyword=keyword;
        this.date=date;
        this.member=member;
    }


}
