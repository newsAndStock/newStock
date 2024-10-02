package com.ssafy.newstock.news.service;

import com.ssafy.newstock.news.controller.response.NewsDetailResponse;
import com.ssafy.newstock.news.controller.response.NewsRecentResponse;
import com.ssafy.newstock.news.controller.response.NewsResponse;
import com.ssafy.newstock.news.domain.News;
import com.ssafy.newstock.news.repository.NewsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NewsService {
    private final NewsRepository newsRepository;

    public List<NewsRecentResponse> getRecentNews() {
        List<News> newsList = newsRepository.findTop10ByOrderByDateDesc();
        return newsList.stream()
                .map(NewsRecentResponse::from)
                .collect(Collectors.toList());
    }

    public List<NewsResponse> findTop5NewsByCategory(String category) {
        List<News> newsList = newsRepository.findTop5ByCategoryOrderByDateDesc(category);
        List<NewsResponse> responseList = new ArrayList<>();

        for (News news : newsList) {
            String formattedDate = calculateTime(news.getDate());
            NewsResponse response = NewsResponse.from(news);
            response.setDate(formattedDate);
            responseList.add(response);
        }
        return responseList;
    }

    public List<NewsResponse> newsList() {
        List<News> newsList = newsRepository.findAllByOrderByDateDesc();
        return newsList.stream()
                .map(NewsResponse::from)
                .collect(Collectors.toList());
    }

    public NewsDetailResponse getNewsDetail(String newsId) {
        Optional<News> optionalNews = newsRepository.findById(newsId);
        News news = optionalNews.orElseThrow(() -> new RuntimeException("News not found"));

        return new NewsDetailResponse(
                news.getNewsId(),
                news.getTitle(),
                news.getPress(),
                news.getDate(),
                news.getContent(),
                news.getImageUrl()
        );
    }

    public String calculateTime(String date) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy.MM.dd. a h:mm", Locale.KOREAN);
        LocalDateTime newsDate = LocalDateTime.parse(date, formatter);
        LocalDateTime now = LocalDateTime.now();

        long subDay = ChronoUnit.DAYS.between(newsDate, now); //날짜 차이 계산

        //만약 날짜가 오늘이면 몇 시간 전 인지 계산
        if (subDay == 0) {
            long hours = ChronoUnit.HOURS.between(newsDate, now);
            if (hours == 0) {
                long minutes = ChronoUnit.MINUTES.between(newsDate, now);
                return minutes + "분 전";
            } else {
                return hours + "시간 전";
            }
        }
        //날짜가 다르면 일 차이
        else {
            return subDay + "일 전";
        }
    }
}




