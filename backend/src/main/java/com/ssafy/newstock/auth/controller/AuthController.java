package com.ssafy.newstock.auth.controller;

import com.ssafy.newstock.auth.controller.request.LoginRequest;
import com.ssafy.newstock.auth.controller.response.LoginResponse;
import com.ssafy.newstock.auth.controller.response.RefreshResponse;
import com.ssafy.newstock.auth.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;

    @PostMapping("/login")
    public LoginResponse login(@RequestBody LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/refresh")
    public RefreshResponse refresh(@RequestParam String refreshToken) {
        return authService.refresh(refreshToken);
    }
}
