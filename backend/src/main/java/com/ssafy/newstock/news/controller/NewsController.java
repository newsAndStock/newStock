package com.ssafy.newstock.news.controller;

import com.ssafy.newstock.news.controller.response.NewsDetailResponse;
import com.ssafy.newstock.news.controller.response.NewsRecentResponse;
import com.ssafy.newstock.news.controller.response.NewsResponse;
import com.ssafy.newstock.news.service.NewsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class NewsController {
    private final NewsService newsService;

    @GetMapping("/news/recent")
    public List<NewsRecentResponse> getRecentNews() {
        return newsService.getRecentNews();
    }

    @GetMapping("/news")
    public List<NewsResponse> getNewsByCategory(@RequestParam String category) {
        return newsService.findTop5NewsByCategory(category);
    }

    @GetMapping("/news/list")
    public List<NewsResponse> getNewsList() {
        return newsService.newsList();
    }

    @GetMapping("/news/detail")
    public NewsDetailResponse getNewsDetail(@RequestParam String newsId) {
        return newsService.getNewsDetail(newsId);
    }
}

