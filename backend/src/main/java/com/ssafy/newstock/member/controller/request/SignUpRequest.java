package com.ssafy.newstock.member.controller.request;

import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.domain.Role;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class SignUpRequest {
    @NotBlank(message = "이메일 필수")
    private String email;

    @NotBlank(message = "닉네임 필수")
    private String nickname;

    @NotBlank(message = "비밀번호 필수")
    private String password;

    public Member toEntity(String password) {
        return new Member(email, nickname, password, Role.USER);
    }
}
