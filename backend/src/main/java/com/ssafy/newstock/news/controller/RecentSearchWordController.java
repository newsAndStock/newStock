package com.ssafy.newstock.news.controller;

import com.ssafy.newstock.auth.supports.LoginMember;
import com.ssafy.newstock.news.controller.response.RecentSearchWordResponse;
import com.ssafy.newstock.news.service.RecentSearchWordService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/news")
public class RecentSearchWordController {

    private final RecentSearchWordService recentSearchWordService;

    public RecentSearchWordController(RecentSearchWordService recentSearchWordService) {
        this.recentSearchWordService = recentSearchWordService;
    }


    @GetMapping("/recent-word")
    public ResponseEntity<List<RecentSearchWordResponse>> memberRecentSearchWord(@LoginMember Long memberId){
        return ResponseEntity.status(HttpStatus.OK).body(recentSearchWordService.getRecentSearchWord(memberId));
    }

    @DeleteMapping("/recent-word")
    public ResponseEntity<Void> deleteRecentSearchWord(@RequestParam Long id){
        if(recentSearchWordService.deleteRecentSearchWord(id)){
            return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).build();

    }
}
