package com.ssafy.newstock.news.repository;

import com.ssafy.newstock.news.domain.RecentSearchWord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RecentSearchWordRepository extends JpaRepository<RecentSearchWord,Long> {

    List<RecentSearchWord> findTop10ByMember_IdOrderByDateDesc(Long memberId);

    boolean existsByMemberIdAndKeyword(Long memberId, String keyword);

    void deleteByMemberIdAndKeyword(Long memberId, String keyword);
}
