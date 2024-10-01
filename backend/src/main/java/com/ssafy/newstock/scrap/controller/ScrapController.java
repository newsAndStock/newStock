package com.ssafy.newstock.scrap.controller;

import com.ssafy.newstock.auth.supports.LoginMember;
import com.ssafy.newstock.scrap.controller.request.ScrapRequest;
import com.ssafy.newstock.scrap.controller.response.ScrapResponse;
import com.ssafy.newstock.scrap.domain.Scrap;
import com.ssafy.newstock.scrap.service.ScrapService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class ScrapController {
    private final ScrapService scrapService;

    @PostMapping("/scrap")
    public ResponseEntity<?> saveScrap(@RequestParam String newsId, @LoginMember Long memberId) {
        scrapService.saveScrap(newsId, memberId);
        return ResponseEntity.ok("저장 성공");
    }

    @PutMapping("/scrap")
    public ResponseEntity<?> updateScrap(@RequestBody ScrapRequest request) {
        scrapService.updateScrap(request.getScrapId(), request.getContent());
        return ResponseEntity.ok("수정 성공");
    }

    // 특정 회원의 스크랩 목록 조회
    @GetMapping("/scrap-list")
    public ResponseEntity<List<?>> getScrapsByMember(@LoginMember Long memberId) {
        List<ScrapResponse> scraps = scrapService.getScrapsByMember(memberId);
        return ResponseEntity.ok(scraps);
    }

    // 특정 스크랩 조회
    @GetMapping("/scrap/{scrapId}")
    public ResponseEntity<?> getScrapById(@PathVariable Long scrapId) {
        ScrapResponse scrap = scrapService.getScrapById(scrapId);
        return ResponseEntity.ok(scrap);
    }

    // 스크랩 삭제
    @DeleteMapping("/scrap/{scrapId}")
    public ResponseEntity<?> deleteScrap(@PathVariable Long scrapId) {
        scrapService.deleteScrap(scrapId);
        return ResponseEntity.noContent().build();
    }

}
