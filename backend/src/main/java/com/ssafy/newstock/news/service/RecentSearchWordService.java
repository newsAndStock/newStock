package com.ssafy.newstock.news.service;

import com.ssafy.newstock.news.domain.RecentSearchWord;
import com.ssafy.newstock.news.repository.RecentSearchWordRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
public class RecentSearchWordService {

    private final RecentSearchWordRepository recentSearchWordRepository;

    public RecentSearchWordService(RecentSearchWordRepository recentSearchWordRepository) {
        this.recentSearchWordRepository = recentSearchWordRepository;
    }

    public List<String> getRecentSearchWord(Long memberId){
        List<RecentSearchWord> recentSearchWords=recentSearchWordRepository.findTop10ByMember_IdOrderByDateDesc(memberId);
        List<String> result = new ArrayList<>();
        for(RecentSearchWord recentSearchWord:recentSearchWords){
            result.add(recentSearchWord.getKeyword());
        }
        return result;
    }

    @Transactional
    public boolean deleteRecentSearchWord(Long memberId, String keyword){
        if(recentSearchWordRepository.existsByMemberIdAndKeyword(memberId, keyword)){
            recentSearchWordRepository.deleteByMemberIdAndKeyword(memberId, keyword);
            return true;
        }else {
            return false;
        }
    }
}
