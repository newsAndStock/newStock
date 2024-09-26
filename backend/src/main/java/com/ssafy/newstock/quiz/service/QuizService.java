package com.ssafy.newstock.quiz.service;

import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.repository.MemberRepository;
import com.ssafy.newstock.quiz.controller.response.QuizResponse;
import com.ssafy.newstock.quiz.domain.QuizHistory;
import com.ssafy.newstock.quiz.repository.QuizHistoryRepository;
import com.ssafy.newstock.quiz.repository.QuizRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@Service
@RequiredArgsConstructor
public class QuizService {
    private final QuizRepository quizRepository;
    private final QuizHistoryRepository quizHistoryRepository;
    private final MemberRepository memberRepository;

    public QuizResponse getCurrentQuiz(Long memberId) {
        QuizHistory quizHistory = quizHistoryRepository.findByMemberId(memberId)
                .orElseGet(() -> createQuizHistory(memberId));

        int todayIndex = calculateIndexForToday();
        int currentIndex = quizHistory.getQuizIndex();

        if (currentIndex >= todayIndex + 3) throw new IllegalArgumentException("오늘 퀴즈 완료!");
        if (currentIndex < todayIndex) currentIndex = todayIndex;

        return QuizResponse.from(
                quizRepository.findById(currentIndex).orElseThrow(() -> new IllegalArgumentException("유효하지 않은 퀴즈 ID"))
        );
    }

    private int calculateIndexForToday() {
        LocalDate startDate = LocalDate.of(2024, 9, 26);
        long days = ChronoUnit.DAYS.between(startDate, LocalDate.now());

        return (int) (days * 3) + 1;
    }

    private QuizHistory createQuizHistory(Long memberId) {
        Member member = memberRepository.findById(memberId).get();
        return quizHistoryRepository.save(new QuizHistory(member, calculateIndexForToday()));
    }
}
