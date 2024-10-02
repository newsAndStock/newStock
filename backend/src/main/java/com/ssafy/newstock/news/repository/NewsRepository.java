package com.ssafy.newstock.news.repository;

import com.ssafy.newstock.news.domain.News;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NewsRepository extends JpaRepository<News, String> {
    List<News> findTop10ByOrderByDateDesc();
    List<News> findTop5ByCategoryOrderByDateDesc(String category);
    List<News> findAllByOrderByDateDesc();
}
