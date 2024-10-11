package com.ssafy.newstock.keyword.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "total_keyword")
@NoArgsConstructor
public class PopularWord {


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long totalKeywordId;

    @Column(name = "word", nullable = false)
    private String word;

    @Column(name = "count", nullable = false)
    private Long count;

    @Column(name = "date", nullable = false)
    private String date;

    public PopularWord(String word, Long count, String date) {
        this.word = word;
        this.count = count;
        this.date = date;
    }
}
