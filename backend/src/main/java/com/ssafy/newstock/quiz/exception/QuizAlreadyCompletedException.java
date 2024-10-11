package com.ssafy.newstock.quiz.exception;

import com.ssafy.newstock.common.exception.ErrorCode;
import com.ssafy.newstock.common.exception.NewStockException;

public class QuizAlreadyCompletedException extends NewStockException {
    public QuizAlreadyCompletedException(String message) {
        super(ErrorCode.QUIZ_ALREADY_COMPLETED, message);
    }
}
