package com.ssafy.newstock.news.controller;

import com.ssafy.newstock.auth.supports.LoginMember;
import com.ssafy.newstock.news.controller.response.NewsDetailResponse;
import com.ssafy.newstock.news.controller.response.NewsRecentResponse;
import com.ssafy.newstock.news.controller.response.NewsResponse;
import com.ssafy.newstock.news.controller.response.NewsSearchResponse;
import com.ssafy.newstock.news.service.NewsService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
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
    public Page<NewsDetailResponse> getNewsList(@RequestParam(required = false) String category, @PageableDefault(size = 30) Pageable pageable) {
        return newsService.newsList(category, pageable);
    }

    @GetMapping("/news/detail")
    public NewsDetailResponse getNewsDetail(@RequestParam String newsId) {
        return newsService.getNewsDetail(newsId);
    }

    @GetMapping("/news-search")
    public List<NewsSearchResponse> searchNews(@RequestParam String keyword, @LoginMember Long memberId) {
        return newsService.searchNews(keyword, memberId);
    }
}

