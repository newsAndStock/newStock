package com.ssafy.newstock.quiz.domain;

import com.ssafy.newstock.member.domain.Member;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import static lombok.AccessLevel.PROTECTED;

@Entity
@Getter
@Table(name = "quiz_history")
@NoArgsConstructor(access = PROTECTED)
public class QuizHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Column(name = "quiz_index", nullable = false)
    private int quizIndex;

    public QuizHistory(Member member, int quizIndex) {
        this.member = member;
        this.quizIndex = quizIndex;
    }

    public void updateIndex() {
        this.quizIndex++;
    }
}
