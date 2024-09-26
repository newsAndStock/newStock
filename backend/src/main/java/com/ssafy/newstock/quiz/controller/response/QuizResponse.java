package com.ssafy.newstock.quiz.controller.response;

import com.ssafy.newstock.quiz.domain.Quiz;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class QuizResponse {
    private int id;
    private String question;
    private String answer;

    public static QuizResponse from(Quiz quiz) {
        return new QuizResponse(quiz.getId(), quiz.getQuestion(), quiz.getAnswer());
    };
}
