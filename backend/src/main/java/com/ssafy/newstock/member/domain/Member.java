package com.ssafy.newstock.member.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import static jakarta.persistence.EnumType.STRING;
import static lombok.AccessLevel.PROTECTED;

@Entity
@Getter
@Table(name = "member")
@NoArgsConstructor(access = PROTECTED)
public class Member {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "email", nullable = false, unique = true)
    private String email;

    @Column(name = "nickname", nullable = false, unique = true)
    private String nickname;

    @Column(name = "password", nullable = false)
    private String password;

    @Enumerated(value = STRING)
    @Column(name = "role", nullable = false)
    private Role role;

    @Column(name = "deposit", nullable = false)
    private Long deposit;

    public Member(String email, String nickname, String password, Role role) {
        this.email = email;
        this.nickname = nickname;
        this.password = password;
        this.role = role;
        this.deposit = 10_000_000L;
    }

    public void updatePassword(String password) {
        this.password = password;
    }

    public void plusDeposit(Long deposit) {
        this.deposit += deposit;
    }
}
