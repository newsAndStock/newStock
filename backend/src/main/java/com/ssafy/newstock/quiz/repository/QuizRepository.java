package com.ssafy.newstock.quiz.repository;

import com.ssafy.newstock.quiz.domain.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;

public interface QuizRepository extends JpaRepository<Quiz, Integer> {
}
