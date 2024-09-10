package com.ssafy.newstock.member.service;

import com.ssafy.newstock.member.controller.request.SignUpRequest;
import com.ssafy.newstock.member.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MemberService {
    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;

    // TODO: 관리자 가입 추가
    public void signUp(SignUpRequest request) {
        if (memberRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("이미 등록된 이메일입니다.");
        }
        String encodedPassword = passwordEncoder.encode(request.getPassword());
        memberRepository.save(request.toEntity(encodedPassword));
    }
}
