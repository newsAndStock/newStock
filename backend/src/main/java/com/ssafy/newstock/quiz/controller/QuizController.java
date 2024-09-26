package com.ssafy.newstock.quiz.controller;

import com.ssafy.newstock.auth.supports.LoginMember;
import com.ssafy.newstock.quiz.controller.response.QuizResponse;
import com.ssafy.newstock.quiz.service.QuizService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class QuizController {
    private final QuizService quizService;

    @GetMapping("/questions")
    public QuizResponse getCurrentQuiz(@LoginMember Long memberId) {
        return quizService.getCurrentQuiz(memberId);
    }
}
