package com.ssafy.newstock.scrap.domain;

import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.news.domain.News;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;


@Entity
@Table(name = "scrap")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Scrap {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "scrap_id")
    private Long id;

    @Column(name = "scrap_content", columnDefinition = "TEXT")
    private String scrapContent;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "news_id", referencedColumnName = "news_id", nullable = false)
    private News news;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", referencedColumnName = "id", nullable = false)
    private Member member;

    @Column(name = "scrap_date", nullable = false)
    private LocalDateTime scrapDate;

    public Scrap(String scrapContent, News news, Member member) {
        this.scrapContent = scrapContent;
        this.news = news;
        this.member = member;
        this.scrapDate = LocalDateTime.now();
    }

    public void updateScrapContent(String newContent) {
        this.scrapContent = newContent;
        this.scrapDate = LocalDateTime.now();
    }
}
