package com.ssafy.newstock.rank.controller;

import com.ssafy.newstock.rank.controller.response.RankResponse;
import com.ssafy.newstock.rank.service.RankService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class RankController {

    private final RankService rankService;

    @GetMapping("/admin/makeRank")
    public HttpStatus makeRgitank(){
        rankService.makeRank();
        rankService.dealSameScore();
        return HttpStatus.OK;
    }

    @GetMapping("/rank")
    public ResponseEntity<RankResponse> stockRank(){
        return ResponseEntity.status(HttpStatus.OK).body(rankService.allRank());
    }



}
