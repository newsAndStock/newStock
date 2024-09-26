package com.ssafy.newstock.quiz.service;

import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.repository.MemberRepository;
import com.ssafy.newstock.quiz.controller.response.QuizResponse;
import com.ssafy.newstock.quiz.domain.Quiz;
import com.ssafy.newstock.quiz.domain.QuizHistory;
import com.ssafy.newstock.quiz.repository.QuizHistoryRepository;
import com.ssafy.newstock.quiz.repository.QuizRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

        return QuizResponse.from(findQuizById(currentIndex));
    }

    @Transactional
    public boolean checkAnswer(Long memberId, int quizId, String answer) {
        findQuizHistoryByMemberId(memberId).updateIndex();

        boolean isCorrect = findQuizById(quizId).getAnswer().equals(answer);
        if (isCorrect) findMemberById(memberId).plusDeposit(100000L);

        return isCorrect;
    }

    @Transactional
    public void skipQuiz(Long memberId) {
        findQuizHistoryByMemberId(memberId).updateIndex();
    }

    private int calculateIndexForToday() {
        LocalDate startDate = LocalDate.of(2024, 9, 26);
        long days = ChronoUnit.DAYS.between(startDate, LocalDate.now());

        return (int) (days * 3) + 1;
    }

    private QuizHistory createQuizHistory(Long memberId) {
        Member member = findMemberById(memberId);
        return quizHistoryRepository.save(new QuizHistory(member, calculateIndexForToday()));
    }

    private Member findMemberById(Long memberId) {
        return memberRepository.findById(memberId)
                .orElseThrow(() -> new EntityNotFoundException("회원(memberId: " + memberId + ")이 존재하지 않습니다."));
    }

    private Quiz findQuizById(int quizId) {
        return quizRepository.findById(quizId)
                .orElseThrow(() -> new EntityNotFoundException("퀴즈(quizId: " + quizId + ")가 존재하지 않습니다."));
    }

    private QuizHistory findQuizHistoryByMemberId(Long memberId) {
        return quizHistoryRepository.findByMemberId(memberId)
                .orElseThrow(() -> new EntityNotFoundException("해당 회원(memberId: " + memberId + ")의 퀴즈 내역이 존재하지 않습니다"));
    }
}
