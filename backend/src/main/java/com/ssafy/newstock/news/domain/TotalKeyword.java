package com.ssafy.newstock.news.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import static lombok.AccessLevel.PROTECTED;

@Entity
@Getter
@Table(name = "total_keyword")
@NoArgsConstructor(access = PROTECTED)
public class TotalKeyword {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long totalKeywordId;

    @Column(name = "word", nullable = false)
    private String word;

    @Column(name = "count", nullable = false)
    private Long count;

    @Column(name = "date", nullable = false)
    private String date;
}
