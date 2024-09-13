package com.ssafy.newstock.member.service;

import com.ssafy.newstock.external.EmailSender;
import com.ssafy.newstock.member.controller.request.SignUpRequest;
import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class MemberService {
    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailSender emailSender;

    private final Map<String, String> temporaryPasswordMap = new ConcurrentHashMap<>();

    // TODO: 관리자 가입 추가
    @Transactional
    public void signUp(SignUpRequest request) {
        String encodedPassword = passwordEncoder.encode(request.getPassword());
        memberRepository.save(request.toEntity(encodedPassword));
    }

    public boolean isEmailDuplicated(String email) {
        return memberRepository.findByEmail(email).isPresent();
    }

    public boolean isNicknameDuplicated(String nickname) {
        return memberRepository.findByNickname(nickname).isPresent();
    }

    @Transactional
    public void sendPasswordEmail(String email) {
        memberRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("등록된 이메일이 없습니다."));

        String temporaryPassword = UUID.randomUUID().toString().substring(0, 6);
        String id = UUID.randomUUID().toString();
        temporaryPasswordMap.put(id, temporaryPassword);

        emailSender.sendTemporaryPassword(email, id, temporaryPassword);
    }

    @Transactional
    public void resetPassword(String email, String id) {
        String temporaryPassword = temporaryPasswordMap.get(id);
        if (temporaryPassword == null) throw new IllegalArgumentException("잘못된 id");

        Member member = memberRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("등록된 이메일이 없습니다."));

        member.updatePassword(passwordEncoder.encode(temporaryPassword));
        temporaryPasswordMap.remove(id);
    }
}
