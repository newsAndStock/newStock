package com.ssafy.newstock.news.repository;

import com.querydsl.core.BooleanBuilder;
import com.querydsl.jpa.impl.JPAQueryFactory;
import com.ssafy.newstock.news.controller.response.NewsSearchResponse;
import com.ssafy.newstock.news.domain.Keyword;
import com.ssafy.newstock.news.domain.News;
import com.ssafy.newstock.news.domain.QKeyword;
import com.ssafy.newstock.news.domain.QNews;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.stream.Collectors;

@Repository
@RequiredArgsConstructor
public class NewsRepositoryQuerydsl {
    private final JPAQueryFactory queryFactory;

    public List<NewsSearchResponse> searchNewsTitleOrKeyword(String searchTerm) {
        QNews news = QNews.news;
        QKeyword keyword = QKeyword.keyword;

        //동적 검색 조건
        BooleanBuilder builder = new BooleanBuilder();
        builder.or(news.title.containsIgnoreCase(searchTerm));
        builder.or(keyword.word.containsIgnoreCase(searchTerm));

        List<News> newsList = queryFactory
                .selectFrom(news)
                .leftJoin(news.keywords, keyword)
                .fetchJoin()
                .where(builder)
                .distinct()
                .orderBy(news.date.desc())
                .fetch();

        return newsList.stream()
                .map(this::convertToDTO) // 엔티티 -> DTO 변환
                .collect(Collectors.toList());
    }

    private NewsSearchResponse convertToDTO(News news) {
        List<String> keywordList = news.getKeywords().stream()
                .map(Keyword::getWord) // 키워드의 word 필드만 가져오기
                .collect(Collectors.toList());

        return new NewsSearchResponse(
                news.getNewsId(),
                news.getCategory(),
                news.getTitle(),
                news.getDate(),
                news.getContent(),
                news.getPress(),
                news.getImageUrl(),
                keywordList // 키워드 목록 포함
        );
    }


}
