package com.ssafy.newstock.news.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "news")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class News {

    @Id
    @Column(name = "news_id", nullable = false)
    private String newsId;

    @Column(name = "category", nullable = false)
    private String category;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "date", nullable = false)
    private String date;

    @Column(name = "content", nullable = false)
    private String content;

    @Column(name = "press", nullable = false)
    private String press;

    @Column(name = "image_url")
    private String imageUrl;
}
