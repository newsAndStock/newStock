package com.ssafy.newstock.quiz.controller;

import com.ssafy.newstock.auth.supports.LoginMember;
import com.ssafy.newstock.quiz.controller.response.QuizResponse;
import com.ssafy.newstock.quiz.service.QuizService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class QuizController {
    private final QuizService quizService;

    @GetMapping("/questions")
    public QuizResponse getCurrentQuiz(@LoginMember Long memberId) {
        return quizService.getCurrentQuiz(memberId);
    }

    @PostMapping("/questions")
    public boolean checkAnswer(@LoginMember Long memberId, @RequestParam int quizId, @RequestParam String answer) {
        return quizService.checkAnswer(memberId, quizId, answer);
    }

    @PostMapping("/questions/skip")
    public ResponseEntity<String> skipQuiz(@LoginMember Long memberId) {
        quizService.skipQuiz(memberId);
        return ResponseEntity.ok("skip 완료");
    }
}
