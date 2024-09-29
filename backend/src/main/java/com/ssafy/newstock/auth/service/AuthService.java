package com.ssafy.newstock.auth.service;

import com.ssafy.newstock.auth.controller.request.LoginRequest;
import com.ssafy.newstock.auth.controller.response.LoginResponse;
import com.ssafy.newstock.auth.controller.response.RefreshResponse;
import com.ssafy.newstock.auth.exception.ExpiredRefreshTokenException;
import com.ssafy.newstock.auth.supports.JwtTokenProvider;
import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final RedisTemplate<String, String> redisTemplate;

    @Transactional
    public LoginResponse login(LoginRequest loginRequest) {
        Member member = memberRepository.findByEmail(loginRequest.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("등록된 이메일이 없습니다"));

        if (passwordEncoder.matches(loginRequest.getPassword(), member.getPassword())) {
            String accessToken = jwtTokenProvider.createAccessToken(member);
            String refreshToken = jwtTokenProvider.createRefreshToken(member);
            redisTemplate.opsForValue().set("refreshToken:" + member.getId(), refreshToken);
            return LoginResponse.from(member, accessToken, refreshToken);
        }
        throw new IllegalArgumentException("비밀번호가 틀렸습니다.");
    }

    @Transactional(readOnly = true)
    public RefreshResponse refresh(String token) {
        Long memberId = jwtTokenProvider.getMemberIdFromRefreshToken(token);
        String storedToken = redisTemplate.opsForValue().get("refreshToken:" + memberId);

        if (storedToken == null || !storedToken.equals(token)) {
            throw new IllegalArgumentException("유효하지 않은 리프레시 토큰");
        }

        if (jwtTokenProvider.validateRefreshToken(token)) {
            Member member = memberRepository.findById(memberId).get();
            String accessToken = jwtTokenProvider.createAccessToken(member);
            String newRefreshToken = jwtTokenProvider.createRefreshToken(member);

            redisTemplate.opsForValue().set("refreshToken:" + memberId, newRefreshToken);

            return new RefreshResponse(accessToken, newRefreshToken);
        }

        throw new ExpiredRefreshTokenException();
    }

}
