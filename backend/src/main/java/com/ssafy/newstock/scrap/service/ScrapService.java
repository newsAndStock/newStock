package com.ssafy.newstock.scrap.service;

import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.repository.MemberRepository;
import com.ssafy.newstock.news.domain.News;
import com.ssafy.newstock.news.repository.NewsRepository;
import com.ssafy.newstock.scrap.controller.response.ScrapResponse;
import com.ssafy.newstock.scrap.domain.Scrap;
import com.ssafy.newstock.scrap.repository.ScrapRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ScrapService {
    private final ScrapRepository scrapRepository;
    private final NewsRepository newsRepository;
    private final MemberRepository memberRepository;

    //첫 스크랩 저장
    @Transactional
    public Long saveScrap(String newsId, Long memberId) {
        News news = newsRepository.findById(newsId)
                .orElseThrow(() -> new IllegalArgumentException("뉴스를 찾을 수 없습니다. ID: " + newsId));
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("회원을 찾을 수 없습니다. ID: " + memberId));
        Scrap scrap = new Scrap(news.getContent(), news, member);
        scrapRepository.save(scrap);
        return scrap.getId();
    }

    // 사용자의 스크랩 목록 조회
    @Transactional(readOnly = true)
    public List<ScrapResponse> getScrapsByMember(Long memberId, String sort) {
        List<Scrap> scraps = null;
        if(sort.equals("oldest")) {
            scraps = scrapRepository.findByMemberIdOrderByScrapDate(memberId);
        }else if(sort.equals("latest")) {
            scraps = scrapRepository.findByMemberIdOrderByScrapDateDesc(memberId); //최신순
        }
        return scraps.stream().map(scrap -> new ScrapResponse(
                scrap.getId(),
                scrap.getNews().getNewsId(),    // 지연 로딩된 News 엔티티 접근
                scrap.getNews().getTitle(),     // 지연 로딩된 News 엔티티의 필드 접근
                scrap.getScrapContent(),
                scrap.getScrapDate(),
                scrap.getNews().getImageUrl()
        )).collect(Collectors.toList());
    }

    //스크랩 수정
    @Transactional
    public void updateScrap(Long scrapId, String scrapContent) {
        Scrap scrap = scrapRepository.findById(scrapId)
                .orElseThrow(() -> new IllegalArgumentException("스크랩을 찾을 수 없습니다. ID: " + scrapId));
        scrap.updateScrapContent(scrapContent);
        scrapRepository.save(scrap);
    }

    // 스크랩 ID로 특정 스크랩 조회
    @Transactional(readOnly = true)
    public ScrapResponse getScrapById(Long scrapId) {
        Scrap scrap = scrapRepository.findById(scrapId)
                .orElseThrow(() -> new IllegalArgumentException("스크랩을 찾을 수 없습니다. ID: " + scrapId));

        return new ScrapResponse(
                scrap.getId(),
                scrap.getNews().getNewsId(),
                scrap.getNews().getTitle(),
                scrap.getScrapContent(),
                scrap.getScrapDate(),
                scrap.getNews().getImageUrl()
        );
    }

    // 스크랩 삭제
    @Transactional
    public void deleteScrap(Long scrapId) {
        Scrap scrap = scrapRepository.findById(scrapId)
                .orElseThrow(() -> new IllegalArgumentException("스크랩을 찾을 수 없습니다. ID: " + scrapId));
        scrapRepository.delete(scrap);
    }
}
