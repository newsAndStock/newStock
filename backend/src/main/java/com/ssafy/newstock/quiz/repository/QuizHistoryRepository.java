package com.ssafy.newstock.quiz.repository;

import com.ssafy.newstock.quiz.domain.QuizHistory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface QuizHistoryRepository extends JpaRepository<QuizHistory, Long> {
    Optional<QuizHistory> findByMemberId(Long memberId);
}
