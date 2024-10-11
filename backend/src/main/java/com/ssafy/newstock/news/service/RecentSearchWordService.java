package com.ssafy.newstock.news.service;

import com.ssafy.newstock.news.controller.response.RecentSearchWordResponse;
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

    public List<RecentSearchWordResponse> getRecentSearchWord(Long memberId){
        List<RecentSearchWord> recentSearchWords=recentSearchWordRepository.findTop10ByMember_IdOrderByDateDesc(memberId);
        List<RecentSearchWordResponse> result = new ArrayList<>();
        for(RecentSearchWord recentSearchWord:recentSearchWords){
            result.add(new RecentSearchWordResponse(recentSearchWord.getId(),recentSearchWord.getKeyword()));
        }
        return result;
    }

    @Transactional
    public boolean deleteRecentSearchWord(Long id){
        if(recentSearchWordRepository.existsById(id)){
            recentSearchWordRepository.deleteById(id);
            return true;
        }else {
            return false;
        }
    }
}
