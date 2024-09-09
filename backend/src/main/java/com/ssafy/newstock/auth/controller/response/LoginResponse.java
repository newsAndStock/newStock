package com.ssafy.newstock.auth.controller.response;

import com.ssafy.newstock.member.Member;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class LoginResponse {
    private String role;
    private String accessToken;
    private String refreshToken;

    public static LoginResponse from(Member member, String accessToken, String refreshToken) {
        return new LoginResponse(member.getRole().name(), accessToken, refreshToken);
    }
}
